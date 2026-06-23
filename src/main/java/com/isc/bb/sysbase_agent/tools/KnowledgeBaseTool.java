package com.isc.bb.sysbase_agent.tools;

import java.util.stream.Collectors;

import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Component;

@Component
public class KnowledgeBaseTool {

    private final VectorStore vectorStore;

    public KnowledgeBaseTool(VectorStore vectorStore) {
        this.vectorStore = vectorStore;
    }

    @Tool(name = "search_knowledge_base", description = "Busca documentación técnica indexada en PDFs. Útil para consultar manuales, guías, documentación sobre PostgreSQL, stored procedures, tablas, configuraciones, etc.")
    public String searchKnowledgeBase(String query) {
        var results = vectorStore.similaritySearch(
                SearchRequest.builder().query(query).topK(3).similarityThreshold(0.5).build());
        if (results.isEmpty()) {
            return "No se encontraron resultados relevantes en la base de conocimientos para: " + query;
        }
        return results.stream()
                .map(d -> {
                    var src = d.getMetadata().getOrDefault("source", "?");
                    var page = d.getMetadata().getOrDefault("page", "?");
                    var score = d.getScore() != null ? String.format("%.2f", d.getScore()) : "?";
                    return "[%s pág.%s (score:%s)]:\n%s".formatted(src, page, score, d.getText());
                })
                .collect(Collectors.joining("\n\n---\n\n"));
    }
}
