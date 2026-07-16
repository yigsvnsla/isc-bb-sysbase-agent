package com.isc.bb.sysbase_agent.documentation.config;

import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.documentation.indexer.SchemaIndexer;

@Component
@ConditionalOnProperty(value = "app.docs.auto-index.enabled", havingValue = "true")
public class AutoIndexRunner implements CommandLineRunner {

    private static final Logger log = LoggerFactory.getLogger(AutoIndexRunner.class);

    private final SchemaIndexer schemaIndexer;
    private final boolean force;
    private final AtomicBoolean running = new AtomicBoolean(false);

    public AutoIndexRunner(SchemaIndexer schemaIndexer,
                           @org.springframework.beans.factory.annotation.Value("${app.docs.auto-index.force:false}") boolean force) {
        this.schemaIndexer = schemaIndexer;
        this.force = force;
    }

    @Override
    public void run(String... args) {
        log.info("Auto-index habilitado. Indexación inicial (run-on-startup)...");
        doIndex("startup");
    }

    @Scheduled(fixedDelayString = "${app.docs.auto-index.interval-ms:300000}")
    public void scheduledIndex() {
        doIndex("scheduled");
    }

    private void doIndex(String trigger) {
        if (!running.compareAndSet(false, true)) {
            log.warn("Auto-index saltado (hay una pasada en curso). trigger={}", trigger);
            return;
        }
        try {
            log.info("Auto-index iniciando... trigger={}", trigger);
            var result = schemaIndexer.indexAll(force, false, Set.of());
            log.info("Auto-index complete: {}", result.summary());
        } catch (Exception e) {
            log.error("Auto-index falló (trigger={}). Se reintentará en la próxima ventana.", trigger, e);
        } finally {
            running.set(false);
        }
    }
}