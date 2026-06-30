package com.isc.bb.sysbase_agent.reader;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;

import org.springframework.ai.document.Document;
import org.springframework.stereotype.Component;

@Component
public class MarkdownReader {

    public List<Document> read(Path file) {
        try {
            var content = Files.readString(file);
            var pathStr = file.toString();
            var doc = new Document(content, Map.of(
                "source", file.getFileName().toString(),
                "path", pathStr,
                "tipo", "documentacion"
            ));
            return List.of(doc);
        } catch (IOException e) {
            throw new RuntimeException("Error leyendo archivo MD: " + file, e);
        }
    }
}
