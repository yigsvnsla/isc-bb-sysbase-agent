package com.isc.bb.sysbase_agent.reader;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.ai.document.Document;
import org.springframework.stereotype.Component;

@Component
public class SqlFileReader {

    public List<Document> read(Path file) {
        try {
            var content = Files.readString(file);
            var metadata = buildMetadata(file, "sql");
            return List.of(new Document(content, metadata));
        } catch (IOException e) {
            throw new RuntimeException("Error leyendo archivo SQL: " + file, e);
        }
    }

    public List<Document> readText(Path file) {
        try {
            var content = Files.readString(file);
            var metadata = buildMetadata(file, "txt");
            return List.of(new Document(content, metadata));
        } catch (IOException e) {
            throw new RuntimeException("Error leyendo archivo TXT: " + file, e);
        }
    }

    private Map<String, Object> buildMetadata(Path file, String extension) {
        var pathStr = file.toString().toLowerCase();
        var parts = pathStr.replace('\\', '/').split("/");
        var meta = new HashMap<String, Object>();

        meta.put("source", file.getFileName().toString());
        meta.put("path", file.toString());
        meta.put("engine", detectEngine(file));

        for (int i = 0; i < parts.length; i++) {
            var part = parts[i];
            if (part.equals("table") && i + 1 < parts.length) {
                var qualified = parts[i + 1];
                meta.put("object_type", "table");
                var dotIdx = qualified.indexOf('.');
                if (dotIdx >= 0) {
                    meta.put("schema", qualified.substring(0, dotIdx));
                    meta.put("table_name", qualified.substring(dotIdx + 1));
                }
                if (i + 2 < parts.length) {
                    meta.put("artifact", parts[i + 2]);
                }
            }
            if (part.equals("store-procedures") && i + 1 < parts.length) {
                meta.put("object_type", "store_procedure");
                var next = parts[i + 1];
                meta.put("procedure_name", next.contains(".") ? next.substring(0, next.lastIndexOf('.')) : next);
            }
            if (part.equals("queryplan")) {
                meta.put("artifact", "queryplan");
            }
        }

        for (int i = 0; i < parts.length - 1; i++) {
            if (isEngineDir(parts[i]) && i + 1 < parts.length
                    && !isTypeDir(parts[i + 1])
                    && !parts[i + 1].contains(".")) {
                meta.putIfAbsent("app", parts[i + 1]);
                break;
            }
        }

        if (!meta.containsKey("artifact")) {
            for (int i = parts.length - 2; i >= 0; i--) {
                if (isTypeDir(parts[i])
                        || (meta.containsKey("schema") && meta.containsKey("table_name") && parts[i].contains("."))) {
                    continue;
                }
                if (!isEngineDir(parts[i])) {
                    meta.putIfAbsent("artifact", parts[i]);
                    break;
                }
            }
        }

        var tipo = extension.equals("txt") ? "referencia_txt" : "ejemplo_sql";
        if (meta.containsKey("object_type")) {
            var ot = meta.get("object_type").toString();
            tipo = extension.equals("txt") ? ot + "_txt" : ot + "_sql";
        }
        if ("queryplan".equals(meta.get("artifact"))) {
            tipo = extension.equals("txt") ? "queryplan_result" : "queryplan_sql";
        }
        meta.put("tipo", tipo);

        return meta;
    }

    private boolean isEngineDir(String part) {
        return part.equals("sybase") || part.equals("mssql")
                || part.equals("oracle") || part.equals("postgresql");
    }

    private boolean isTypeDir(String part) {
        return part.equals("table") || part.equals("queryplan") || part.equals("dll")
                || part.equals("store-procedures") || part.equals("tables")
                || part.equals("ejemplos") || part.equals("documents")
                || part.equals("static");
    }

    private String detectEngine(Path file) {
        var path = file.toString().toLowerCase();
        if (path.contains("sybase")) return "sybase";
        if (path.contains("mssql")) return "mssql";
        if (path.contains("oracle")) return "oracle";
        if (path.contains("postgresql")) return "postgresql";
        return "desconocido";
    }
}
