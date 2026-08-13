package com.isc.bb.sysbase_agent.audit;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import io.micrometer.core.instrument.MeterRegistry;
import tools.jackson.databind.ObjectMapper;

/**
 * Export WORM de ai_audit: vuelca los eventos viejos a archivos JSONL
 * append-only con hash chain (SHA-256). Cada línea encadena el hash de la
 * anterior; el purge solo elimina eventos marcados como exportados, de modo
 * que nada se borra sin evidencia inmutable previa.
 */
@Service
public class AuditWormExportService {

    private static final Logger log = LoggerFactory.getLogger(AuditWormExportService.class);

    private final AuditRepository audit;
    private final ObjectMapper objectMapper;
    private final MeterRegistry meters;
    private final Path wormDir;
    private final boolean enabled;
    private final int batchSize;

    public AuditWormExportService(AuditRepository audit,
                                  ObjectMapper objectMapper,
                                  MeterRegistry meters,
                                  @Value("${app.audit.worm.dir:data/worm}") String wormDir,
                                  @Value("${app.audit.worm.enabled:true}") boolean enabled,
                                  @Value("${app.audit.worm.batch-size:500}") int batchSize) {
        this.audit = audit;
        this.objectMapper = objectMapper;
        this.meters = meters;
        this.wormDir = Path.of(wormDir);
        this.enabled = enabled;
        this.batchSize = batchSize;
    }

    @Scheduled(cron = "${app.audit.worm.cron:0 0 2 * * *}")
    public void scheduledExport() {
        if (!enabled) {
            return;
        }
        try {
            var cutoff = Instant.now().minus(90, java.time.temporal.ChronoUnit.DAYS);
            int exported = exportPending(cutoff);
            log.info("WORM export: {} eventos exportados", exported);
        } catch (Exception e) {
            meters.counter("ai_audit_worm_export_failures_total").increment();
            log.error("Fallo export WORM", e);
        }
    }

    /** Exporta (en lotes) todos los eventos sin exportar anteriores al cutoff. */
    public int exportPending(Instant cutoff) throws IOException {
        if (!enabled) {
            log.warn("WORM export deshabilitado (app.audit.worm.enabled=false)");
            return 0;
        }
        Files.createDirectories(wormDir);
        int total = 0;
        while (true) {
            var events = audit.listUnexportedBefore(cutoff, batchSize);
            if (events.isEmpty()) {
                break;
            }
            total += exportBatch(events);
            if (events.size() < batchSize) {
                break;
            }
        }
        return total;
    }

    private int exportBatch(List<AuditEvent> events) throws IOException {
        var first = events.get(0);
        var last = events.get(events.size() - 1);
        var fileName = String.format("audit-worm-%d-%d.jsonl", first.id(), last.id());
        var file = wormDir.resolve(fileName);
        if (Files.exists(file)) {
            throw new IOException("Chunk ya existe (ejecución duplicada): " + fileName);
        }
        var chunks = audit.wormChunks();
        var prevHash = chunks.isEmpty() ? null : chunks.get(chunks.size() - 1).chunkHash();

        var lines = new ArrayList<String>();
        for (var event : events) {
            var payload = objectMapper.writeValueAsString(event);
            var hash = hash(prevHash, payload);
            lines.add(objectMapper.writeValueAsString(new WormLine(prevHash, event, hash)));
            prevHash = hash;
        }
        Files.write(file, lines, StandardCharsets.UTF_8,
                StandardOpenOption.CREATE_NEW, StandardOpenOption.WRITE);

        var chunkHash = hashChain(chunks.isEmpty() ? null : chunks.get(chunks.size() - 1).chunkHash(), lines);
        audit.recordWormChunk(fileName, first.id(), last.id(),
                first.eventTs(), last.eventTs(),
                chunks.isEmpty() ? null : chunks.get(chunks.size() - 1).chunkHash(),
                chunkHash, events.size());
        audit.markExported(events.stream().map(AuditEvent::id).toList());
        meters.counter("ai_audit_worm_exported_total").increment(events.size());
        log.info("WORM chunk: {} ({} eventos, {} bytes)", fileName, events.size(), lines.size());
        return events.size();
    }

    private String hashChain(String seed, List<String> lines) {
        String h = seed;
        for (var line : lines) {
            h = sha256(h == null ? line : h + "|" + line);
        }
        return h;
    }

    private String hash(String prevHash, String payload) {
        return sha256(prevHash == null ? payload : prevHash + "|" + payload);
    }

    private String sha256(String input) {
        try {
            var digest = MessageDigest.getInstance("SHA-256");
            var bytes = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            var sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    /** Verifica la integridad de todos los chunks (hash chain + encadenamiento). */
    public WormVerifyResult verify() throws IOException {
        var chunks = audit.wormChunks();
        var problems = new ArrayList<String>();
        var expectedPrev = (String) null;
        int linesChecked = 0;
        for (var chunk : chunks) {
            var file = wormDir.resolve(chunk.fileName());
            if (!Files.exists(file)) {
                problems.add("Chunk ausente: " + chunk.fileName());
                continue;
            }
            var text = Files.readString(file);
            var lines = List.of(text.split("\n"));
            var nonBlank = lines.stream().filter(l -> !l.isBlank()).toList();
            String h = expectedPrev;
            for (var line : nonBlank) {
                var parsed = objectMapper.readValue(line, WormLine.class);
                var recomputed = hash(parsed.prevHash(), objectMapper.writeValueAsString(parsed.event()));
                if (!recomputed.equals(parsed.hash())) {
                    problems.add("Hash roto en " + chunk.fileName() + ": línea con evento "
                            + parsed.event().id());
                }
                if (parsed.prevHash() != null && !parsed.prevHash().equals(h)) {
                    problems.add("Cadena rota en " + chunk.fileName() + " (prev_hash no encadena)");
                }
                h = parsed.hash();
                linesChecked++;
            }
            if (!hashChain(expectedPrev, nonBlank).equals(chunk.chunkHash())) {
                problems.add("Chunk hash no coincide: " + chunk.fileName());
            }
            expectedPrev = chunk.chunkHash();
        }
        return new WormVerifyResult(chunks.size(), linesChecked, problems);
    }

    public record WormLine(String prevHash, AuditEvent event, String hash) {
    }

    public record WormVerifyResult(int chunks, int lines, List<String> problems) {
        public boolean ok() {
            return problems.isEmpty();
        }
    }
}
