package com.isc.bb.sysbase_agent.cli;

import java.nio.file.Path;

import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.shell.core.command.annotation.Command;
import org.springframework.shell.core.command.annotation.Option;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.loader.KnowledgeBaseLoader;

@Component
public class KnowledgeBaseCli {

    private final KnowledgeBaseLoader loader;
    private final VectorStore vectorStore;

    public KnowledgeBaseCli(KnowledgeBaseLoader loader, VectorStore vectorStore) {
        this.loader = loader;
        this.vectorStore = vectorStore;
    }

    @Command(name = "kb-index", description = "Indexa PDFs en la base de conocimientos")
    public String index(
            @Option(longName = "file", description = "PDF específico a indexar") String file,
            @Option(longName = "reboot", description = "Reindexar todo (ignora caché)") boolean reboot) {
        if (file != null) {
            loader.indexFile(Path.of(file));
            return "Indexado: " + file;
        }
        if (reboot) {
            var count = loader.reindexAll();
            return "Reindexados: " + count + " PDFs";
        }
        var count = loader.reindexAll();
        return "Indexados: " + count + " PDFs";
    }

    @Command(name = "kb-status", description = "Muestra estado de la base de conocimientos")
    public String status() {
        var results = vectorStore.similaritySearch(SearchRequest.builder()
                .query("dummy").topK(1).similarityThresholdAll().build());
        var totalDocs = vectorStore.similaritySearch(SearchRequest.builder()
                .query("").topK(10_000).similarityThresholdAll().build());
        return "Base de conocimientos: %d chunks indexados".formatted(totalDocs.size());
    }
}
