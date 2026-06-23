package com.isc.bb.sysbase_agent.loader;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.reader.PdfDocumentReader;

@Component
public class KnowledgeBaseLoader implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(KnowledgeBaseLoader.class);

    private final VectorStore vectorStore;
    private final String pdfDir;
    private final ResourcePatternResolver resourceResolver;
    private final TokenTextSplitter splitter;

    public KnowledgeBaseLoader(VectorStore vectorStore,
                               @Value("${app.knowledge-base.pdf-dir:classpath:static/documents}") String pdfDir,
                               ResourcePatternResolver resourceResolver) {
        this.vectorStore = vectorStore;
        this.pdfDir = pdfDir;
        this.resourceResolver = resourceResolver;
        this.splitter = TokenTextSplitter.builder()
                .withChunkSize(500)
                .withMinChunkSizeChars(350)
                .withMinChunkLengthToEmbed(5)
                .withMaxNumChunks(10_000)
                .build();
    }

    @Override
    public void run(String... args) {
        var pdfs = resolvePdfFiles();
        if (pdfs.isEmpty()) {
            log.info("No se encontraron PDFs en: {}", pdfDir);
            return;
        }
        for (var file : pdfs) {
            indexFile(file);
        }
    }

    private List<Path> resolvePdfFiles() {
        var pattern = pdfDir.startsWith("classpath:")
                ? pdfDir.replaceFirst("^classpath:", "classpath*:") + "/**/*.pdf"
                : null;
        if (pattern != null) {
            try {
                var resources = resourceResolver.getResources(pattern);
                var paths = Arrays.stream(resources)
                        .map(r -> {
                            try { return r.getFile().toPath(); }
                            catch (Exception e) { return null; }
                        })
                        .filter(Objects::nonNull)
                        .toList();
                if (!paths.isEmpty()) {
                    log.info("PDFs encontrados via classpath: {} archivos", paths.size());
                    return paths;
                }
            } catch (IOException e) {
                log.debug("No se pudieron resolver PDFs del classpath: {}", pattern);
            }
        }
        var dir = Path.of(pdfDir.replaceFirst("^classpath:", ""));
        if (!Files.isDirectory(dir)) {
            return List.of();
        }
        try (var files = Files.walk(dir)) {
            var paths = files.filter(f -> f.toString().endsWith(".pdf")).toList();
            if (!paths.isEmpty()) {
                log.info("PDFs encontrados via filesystem ({}): {} archivos", dir, paths.size());
            }
            return paths;
        } catch (IOException e) {
            return List.of();
        }
    }

    public void indexFile(Path file) {
        try {
            var reader = new PdfDocumentReader(file);
            var docs = reader.read();
            var chunks = splitter.split(docs);
            vectorStore.add(chunks);
            log.info("PDF indexado: {} ({} chunks)", file.getFileName(), chunks.size());
        } catch (Exception e) {
            log.error("Error indexando PDF: {}", file.getFileName(), e);
        }
    }

    public int reindexAll() {
        var pdfs = resolvePdfFiles();
        for (var file : pdfs) {
            indexFile(file);
        }
        return pdfs.size();
    }
}
