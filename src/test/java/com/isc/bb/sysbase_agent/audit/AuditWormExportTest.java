package com.isc.bb.sysbase_agent.audit;

import static org.assertj.core.api.Assertions.assertThat;

import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;

@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class AuditWormExportTest extends AbstractIntegrationTest {

    @Autowired
    AuditWormExportService worm;

    @Autowired
    AuditRepository audit;

    @Autowired
    JdbcTemplate jdbc;

    @DynamicPropertySource
    static void wormDir(DynamicPropertyRegistry registry) {
        registry.add("app.audit.worm.dir", () -> "/tmp/opencode/worm-test-" + System.nanoTime());
        registry.add("app.audit.worm.enabled", () -> "true");
    }

    private void insertOldEvent(String userId, int daysAgo) {
        jdbc.update("INSERT INTO ai_audit (event_type, event_ts, user_id) VALUES ('TURN', now() - interval '"
                + daysAgo + " days', ?)", userId);
    }

    @Test
    @Order(1)
    void exportMarksAndPurgeDeletesOnlyExported() throws Exception {
        var cutoff = Instant.now().minus(90, ChronoUnit.DAYS);
        audit.purgeBefore(cutoff);

        insertOldEvent("worm-old-1", 120);
        insertOldEvent("worm-old-2", 100);
        insertOldEvent("worm-recent", 10);

        int exported = worm.exportPending(cutoff);
        assertThat(exported).isGreaterThanOrEqualTo(2);

        var chunks = audit.wormChunks();
        assertThat(chunks).isNotEmpty();
        var last = chunks.get(chunks.size() - 1);
        if (chunks.size() == 1) {
            assertThat(last.prevHash()).isNull();
        } else {
            assertThat(last.prevHash()).isEqualTo(chunks.get(chunks.size() - 2).chunkHash());
        }
        assertThat(last.chunkHash()).isNotBlank();
        assertThat(last.eventCount()).isGreaterThanOrEqualTo(2);

        var dir = wormTestDir();
        var file = dir.resolve(last.fileName());
        assertThat(file).exists();
        assertThat(Files.readAllLines(file).size()).isGreaterThanOrEqualTo(2);

        var verify = worm.verify();
        assertThat(verify.ok()).as(verify.problems().toString()).isTrue();

        int deleted = audit.purgeBefore(cutoff);
        assertThat(deleted).isGreaterThanOrEqualTo(2);
        assertThat(audit.search(null, "worm-recent", null, 10)).isNotEmpty();
    }

    @Test
    @Order(2)
    void tamperedLine_breaksHashChain() throws Exception {
        var cutoff = Instant.now().minus(90, ChronoUnit.DAYS);
        insertOldEvent("worm-tamper", 120);
        worm.exportPending(cutoff);

        var chunks = audit.wormChunks();
        var chunk = chunks.get(chunks.size() - 1);
        var dir = wormTestDir();
        var file = dir.resolve(chunk.fileName());
        var lines = Files.readAllLines(file);
        var tampered = lines.get(0).replace("\"worm-tamper\"", "\"worm-tampered\"");
        Files.write(file, java.util.List.of(tampered));
        for (int i = 1; i < lines.size(); i++) {
            Files.writeString(file, "\n" + lines.get(i), java.nio.file.StandardOpenOption.APPEND);
        }

        var verify = worm.verify();
        assertThat(verify.ok()).isFalse();
        assertThat(verify.problems()).anyMatch(p -> p.contains("Hash roto"));
    }

    private Path wormTestDir() throws Exception {
        return Files.list(Path.of("/tmp/opencode")).toList().stream()
                .filter(p -> p.getFileName().toString().startsWith("worm-test-"))
                .findFirst().orElseThrow();
    }
}
