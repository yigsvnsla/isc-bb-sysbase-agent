package com.isc.bb.sysbase_agent.loader;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.document.Document;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class SpDocLoader implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(SpDocLoader.class);

    private final VectorStore vectorStore;
    private final Path docsPath;

    public SpDocLoader(VectorStore vectorStore,
                       @Value("${app.sp-docs.path:sp_docs}") String docsPath) {
        this.vectorStore = vectorStore;
        this.docsPath = Path.of(docsPath);
    }

    @Override
    public void run(String... args) {
        if (!Files.isDirectory(docsPath)) {
            log.info("Directorio de docs no encontrado: {}. Omitiendo ingesta.", docsPath);
            return;
        }
        try (var files = Files.walk(docsPath)) {
            var sqlFiles = files.filter(f -> f.toString().endsWith(".sql")).toList();
            if (sqlFiles.isEmpty()) {
                log.info("No se encontraron archivos .sql en {}", docsPath);
                return;
            }
            var docs = new ArrayList<Document>();
            for (var file : sqlFiles) {
                docs.addAll(parseFile(file));
            }
            vectorStore.add(docs);
            log.info("Ingesta completada: {} documentos cargados desde {} archivos", docs.size(), sqlFiles.size());
        } catch (IOException e) {
            log.error("Error durante ingesta de documentos", e);
        }
    }

    @Tool(name = "index_procedure", description = "Indexa un SP en el vector store para búsqueda semántica")
    public void indexProcedure(String name, String source, String schema) {
        var doc = new Document(source, Map.of(
                "name", name,
                "schema", schema != null ? schema : "public",
                "type", "stored_procedure"));
        vectorStore.add(List.of(doc));
        log.info("SP indexado: {}.{}", schema != null ? schema : "public", name);
    }

    private List<Document> parseFile(Path file) throws IOException {
        var content = Files.readString(file);
        var statements = splitStatements(content);
        var docs = new ArrayList<Document>();
        for (var stmt : statements) {
            var name = extractName(stmt);
            var doc = new Document(stmt, Map.of(
                    "name", name != null ? name : "unknown",
                    "file", file.getFileName().toString(),
                    "type", "stored_procedure"));
            docs.add(doc);
        }
        return docs;
    }

    private List<String> splitStatements(String content) {
        var statements = new ArrayList<String>();
        var lines = content.split("\n");
        var buf = new StringBuilder();
        for (var line : lines) {
            buf.append(line).append("\n");
            var trimmed = line.strip().toUpperCase();
            if (trimmed.equals("/") || trimmed.startsWith("GO")) {
                if (!buf.toString().isBlank()) {
                    statements.add(buf.toString());
                }
                buf = new StringBuilder();
            }
        }
        var remaining = buf.toString().strip();
        if (!remaining.isBlank() && !remaining.equals("/")) {
            statements.add(remaining);
        }
        return statements;
    }

    private String extractName(String sql) {
        var upper = sql.stripLeading().toUpperCase();
        var markers = new String[] {
            "CREATE OR ALTER PROCEDURE ", "CREATE OR REPLACE PROCEDURE ",
            "CREATE PROCEDURE ", "CREATE OR ALTER FUNCTION ", "CREATE FUNCTION "
        };
        for (var marker : markers) {
            if (upper.startsWith(marker)) {
                var rest = sql.stripLeading().substring(marker.length()).strip();
                var endIdx = rest.indexOf('(');
                if (endIdx == -1) endIdx = rest.indexOf(' ');
                if (endIdx == -1) endIdx = rest.indexOf('\n');
                if (endIdx == -1) endIdx = rest.indexOf('\r');
                if (endIdx == -1) endIdx = rest.length();
                var name = rest.substring(0, endIdx).strip();
                var dotIdx = name.indexOf('.');
                return dotIdx >= 0 ? name.substring(dotIdx + 1) : name;
            }
        }
        return null;
    }
}
