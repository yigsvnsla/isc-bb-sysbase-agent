package com.isc.bb.sysbase_agent.cli;

import java.nio.file.Path;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.shell.core.command.annotation.Command;
import org.springframework.shell.core.command.annotation.Option;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.loader.KnowledgeBaseLoader;

@Component
public class KnowledgeBaseCli {

    private final KnowledgeBaseLoader loader;
    private final JdbcTemplate jdbcTemplate;

    public KnowledgeBaseCli(KnowledgeBaseLoader loader, JdbcTemplate jdbcTemplate) {
        this.loader = loader;
        this.jdbcTemplate = jdbcTemplate;
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
        var count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM vector_store", Long.class);
        return "Base de conocimientos: %d chunks indexados".formatted(count != null ? count : 0);
    }
}
