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
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.reader.MarkdownReader;
import com.isc.bb.sysbase_agent.reader.PdfDocumentReader;
import com.isc.bb.sysbase_agent.reader.SqlFileReader;

@Component
public class KnowledgeBaseLoader implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(KnowledgeBaseLoader.class);

    private final VectorStore vectorStore;
    private final String pdfDir;
    private final ResourcePatternResolver resourceResolver;
    private final JdbcTemplate jdbcTemplate;
    private final SqlFileReader sqlFileReader;
    private final MarkdownReader markdownReader;
    private final TokenTextSplitter splitter;

    public KnowledgeBaseLoader(VectorStore vectorStore,
                                @Value("${app.knowledge-base.pdf-dir:classpath:static/documents}") String pdfDir,
                                ResourcePatternResolver resourceResolver,
                                JdbcTemplate jdbcTemplate,
                                SqlFileReader sqlFileReader,
                                MarkdownReader markdownReader) {
        this.vectorStore = vectorStore;
        this.pdfDir = pdfDir;
        this.resourceResolver = resourceResolver;
        this.jdbcTemplate = jdbcTemplate;
        this.sqlFileReader = sqlFileReader;
        this.markdownReader = markdownReader;
        this.splitter = TokenTextSplitter.builder()
                .withChunkSize(1200)
                .withMinChunkSizeChars(350)
                .withMinChunkLengthToEmbed(5)
                .withMaxNumChunks(10_000)
                .withKeepSeparator(true)
                .build();
    }

    @Override
    public void run(String... args) {
        var pdfs = resolvePdfFiles();
        for (var file : pdfs) {
            indexFile(file);
        }
        var sqlFiles = resolveSqlFiles();
        for (var file : sqlFiles) {
            indexSqlFile(file);
        }
        var mdFiles = resolveMdFiles();
        for (var file : mdFiles) {
            indexMdFile(file);
        }
        if (pdfs.isEmpty() && sqlFiles.isEmpty() && mdFiles.isEmpty()) {
            log.info("No se encontraron archivos para indexar en: {}", pdfDir);
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
        jdbcTemplate.update("DELETE FROM vector_store");
        log.info("Vector store limpiado");
        var count = 0;
        var pdfs = resolvePdfFiles();
        for (var file : pdfs) {
            indexFile(file);
            count++;
        }
        var sqlFiles = resolveSqlFiles();
        for (var file : sqlFiles) {
            indexSqlFile(file);
            count++;
        }
        var mdFiles = resolveMdFiles();
        for (var file : mdFiles) {
            indexMdFile(file);
            count++;
        }
        return count;
    }

    private List<Path> resolveSqlFiles() {
        var classpathPattern = "classpath*:static/documents/ejemplos/**/*.sql";
        try {
            var resources = resourceResolver.getResources(classpathPattern);
            var paths = Arrays.stream(resources)
                    .map(r -> {
                        try { return r.getFile().toPath(); }
                        catch (Exception e) { return null; }
                    })
                    .filter(Objects::nonNull)
                    .toList();
            if (!paths.isEmpty()) {
                log.info("SQLs encontrados via classpath: {} archivos", paths.size());
                return paths;
            }
        } catch (IOException e) {
            log.debug("No se pudieron resolver SQLs del classpath: {}", classpathPattern);
        }
        var dir = Path.of(pdfDir.replaceFirst("^classpath:", ""));
        var ejemplosDir = dir.resolve("ejemplos");
        if (!Files.isDirectory(ejemplosDir)) {
            return List.of();
        }
        try (var files = Files.walk(ejemplosDir)) {
            var paths = files.filter(f -> f.toString().endsWith(".sql")).toList();
            if (!paths.isEmpty()) {
                log.info("SQLs encontrados en {}: {} archivos", ejemplosDir, paths.size());
            }
            return paths;
        } catch (IOException e) {
            return List.of();
        }
    }

    public void indexSqlFile(Path file) {
        try {
            var docs = sqlFileReader.read(file);
            var chunks = splitter.split(docs);
            vectorStore.add(chunks);
            log.info("SQL indexado: {} ({} chunks)", file.getFileName(), chunks.size());
        } catch (Exception e) {
            log.error("Error indexando SQL: {}", file.getFileName(), e);
        }
    }

    private List<Path> resolveMdFiles() {
        var classpathPattern = "classpath*:static/documents/**/*.md";
        try {
            var resources = resourceResolver.getResources(classpathPattern);
            var paths = Arrays.stream(resources)
                    .map(r -> {
                        try { return r.getFile().toPath(); }
                        catch (Exception e) { return null; }
                    })
                    .filter(Objects::nonNull)
                    .toList();
            if (!paths.isEmpty()) {
                log.info("MDs encontrados via classpath: {} archivos", paths.size());
                return paths;
            }
        } catch (IOException e) {
            log.debug("No se pudieron resolver MDs del classpath: {}", classpathPattern);
        }
        var dir = Path.of(pdfDir.replaceFirst("^classpath:", ""));
        if (!Files.isDirectory(dir)) {
            return List.of();
        }
        try (var files = Files.walk(dir)) {
            var paths = files.filter(f -> f.toString().endsWith(".md")).toList();
            if (!paths.isEmpty()) {
                log.info("MDs encontrados en {}: {} archivos", dir, paths.size());
            }
            return paths;
        } catch (IOException e) {
            return List.of();
        }
    }

    public void indexMdFile(Path file) {
        try {
            var docs = markdownReader.read(file);
            var chunks = splitter.split(docs);
            vectorStore.add(chunks);
            log.info("MD indexado: {} ({} chunks)", file.getFileName(), chunks.size());
        } catch (Exception e) {
            log.error("Error indexando MD: {}", file.getFileName(), e);
        }
    }
}
