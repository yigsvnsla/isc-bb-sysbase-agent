package com.isc.bb.sysbase_agent.reader;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;

import org.springframework.ai.document.Document;
import org.springframework.stereotype.Component;

@Component
public class SqlFileReader {

    public List<Document> read(Path file) {
        try {
            var content = Files.readString(file);
            var engine = detectEngine(file);
            var pathStr = file.toString();
            var doc = new Document(content, Map.of(
                "source", file.getFileName().toString(),
                "engine", engine,
                "path", pathStr,
                "tipo", "ejemplo_sql"
            ));
            return List.of(doc);
        } catch (IOException e) {
            throw new RuntimeException("Error leyendo archivo SQL: " + file, e);
        }
    }

    private String detectEngine(Path file) {
        var path = file.toString().toLowerCase();
        if (path.contains("sybase")) return "sybase";
        if (path.contains("mssql")) return "mssql";
        if (path.contains("oracle")) return "oracle";
        return "desconocido";
    }
}
