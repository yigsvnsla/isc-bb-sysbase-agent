package com.isc.bb.sysbase_agent.documentation.config;

import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.documentation.indexer.SchemaIndexer;

@Component
@ConditionalOnProperty(value = "app.docs.auto-index.enabled", havingValue = "true")
public class AutoIndexRunner implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(AutoIndexRunner.class);

    private final SchemaIndexer schemaIndexer;

    public AutoIndexRunner(SchemaIndexer schemaIndexer) {
        this.schemaIndexer = schemaIndexer;
    }

    @Override
    public void run(String... args) {
        log.info("Auto-indexing database objects...");
        var result = schemaIndexer.indexAll(false, false, Set.of());
        log.info("Auto-index complete: {}", result.summary());
    }
}
