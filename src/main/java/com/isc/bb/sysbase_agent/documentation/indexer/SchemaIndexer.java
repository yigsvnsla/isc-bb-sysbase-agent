package com.isc.bb.sysbase_agent.documentation.indexer;

import java.nio.file.Files;
import java.nio.file.Path;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.documentation.generator.CompositeTypeDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.EnumDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.ProcedureDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.SchemaDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.SequenceDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.TableDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.TriggerDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.ViewDocGenerator;
import com.isc.bb.sysbase_agent.documentation.model.DocumentContent;
import com.isc.bb.sysbase_agent.documentation.port.DocumentPublisher;
import com.isc.bb.sysbase_agent.tools.PostgresTools;

@Component
public class SchemaIndexer {

    private static final Logger log = LoggerFactory.getLogger(SchemaIndexer.class);
    private static final Pattern HASH_PATTERN = Pattern.compile("source_hash:\\s*\"?(\\w+)\"?");

    private final PostgresTools postgresTools;
    private final ProcedureDocGenerator procedureDocGenerator;
    private final SchemaDocGenerator schemaDocGenerator;
    private final TableDocGenerator tableDocGenerator;
    private final ViewDocGenerator viewDocGenerator;
    private final TriggerDocGenerator triggerDocGenerator;
    private final SequenceDocGenerator sequenceDocGenerator;
    private final EnumDocGenerator enumDocGenerator;
    private final CompositeTypeDocGenerator compositeTypeDocGenerator;
    private final DocumentPublisher publisher;
    private final Path docsPath;

    public SchemaIndexer(PostgresTools postgresTools,
                         ProcedureDocGenerator procedureDocGenerator,
                         SchemaDocGenerator schemaDocGenerator,
                         TableDocGenerator tableDocGenerator,
                         ViewDocGenerator viewDocGenerator,
                         TriggerDocGenerator triggerDocGenerator,
                         SequenceDocGenerator sequenceDocGenerator,
                         EnumDocGenerator enumDocGenerator,
                         CompositeTypeDocGenerator compositeTypeDocGenerator,
                         DocumentPublisher publisher,
                         @org.springframework.beans.factory.annotation.Value("${app.docs.docusaurus.path:.container/docs}") String docsPath) {
        this.postgresTools = postgresTools;
        this.procedureDocGenerator = procedureDocGenerator;
        this.schemaDocGenerator = schemaDocGenerator;
        this.tableDocGenerator = tableDocGenerator;
        this.viewDocGenerator = viewDocGenerator;
        this.triggerDocGenerator = triggerDocGenerator;
        this.sequenceDocGenerator = sequenceDocGenerator;
        this.enumDocGenerator = enumDocGenerator;
        this.compositeTypeDocGenerator = compositeTypeDocGenerator;
        this.publisher = publisher;
        this.docsPath = Path.of(docsPath);
    }

    public IndexResult indexSchema(String schema, boolean force, boolean dryRun) {
        return indexSchema(schema, force, dryRun, Set.of());
    }

    public IndexResult indexSchema(String schema, boolean force, boolean dryRun, Set<String> types) {
        boolean all = types.isEmpty();
        log.info("Indexing schema: {} (force={}, dryRun={}, types={})", schema, force, dryRun,
                all ? "all" : types);
        var result = IndexResult.empty();

        if (all || types.contains("table")) {
            result = merge(result, indexTables(schema, force, dryRun));
        }
        if (all || types.contains("view")) {
            result = merge(result, indexViews(schema, force, dryRun));
        }
        if (all || types.contains("procedure")) {
            result = merge(result, indexProcedures(schema, force, dryRun));
        }
        if (all || types.contains("trigger")) {
            result = merge(result, indexTriggers(schema, force, dryRun));
        }
        if (all || types.contains("sequence")) {
            result = merge(result, indexSequences(schema, force, dryRun));
        }
        if (all || types.contains("enum")) {
            result = merge(result, indexEnums(schema, force, dryRun));
        }
        if (all || types.contains("type")) {
            result = merge(result, indexCompositeTypes(schema, force, dryRun));
        }

        if (!dryRun && (result.generated() > 0 || result.updated() > 0)) {
            try {
                var schemaDoc = schemaDocGenerator.generate(schema);
                publisher.publish(schemaDoc);
                log.info("Schema catalog updated: {}", schema);
            } catch (Exception e) {
                log.error("Error generating schema catalog for {}", schema, e);
            }
            try {
                publisher.buildIndex();
                log.info("Sidebar regenerado para schema: {}", schema);
            } catch (Exception e) {
                log.error("Error regenerating sidebar for {}", schema, e);
            }
        }

        return result;
    }

    public IndexResult indexAll(boolean force, boolean dryRun) {
        return indexAll(force, dryRun, Set.of());
    }

    public IndexResult indexAll(boolean force, boolean dryRun, Set<String> types) {
        var result = IndexResult.empty();
        var schemas = postgresTools.listAllSchemas();
        log.info("Indexing all schemas: {} (force={}, dryRun={}, types={})",
                schemas, force, dryRun, types.isEmpty() ? "all" : types);

        for (var schema : schemas) {
            var schemaResult = indexSchema(schema, force, dryRun, types);
            result = merge(result, schemaResult);
        }

        if (!dryRun && (result.generated() > 0 || result.updated() > 0)) {
            publisher.buildIndex();
            log.info("Sidebar regenerado");
        }

        return result;
    }

    // ── Tablas ──

    private IndexResult indexTables(String schema, boolean force, boolean dryRun) {
        var result = IndexResult.empty();
        var tables = postgresTools.listTables(schema);
        for (var table : tables) {
            try {
                var info = postgresTools.getTableInfo(schema, table.name());
                var hash = sha256(info.ddl());
                var docFile = docsPath.resolve("tablas").resolve(schema)
                        .resolve(schema + "_" + table.name() + ".md");

                if (!force && Files.exists(docFile) && hash.equals(readSourceHash(docFile))) {
                    result = result.addSkipped(schema + "." + table.name() + " (sin cambios)");
                    continue;
                }
                if (dryRun) {
                    result = result.addGenerated(schema + "." + table.name() + " (dry-run)");
                    continue;
                }

                var content = tableDocGenerator.generate(info);
                content = addSourceHash(content, hash);
                var pub = publisher.publish(content);
                result = pub.success()
                        ? (Files.exists(docFile) ? result.addUpdated(schema + "." + table.name())
                                                   : result.addGenerated(schema + "." + table.name()))
                        : result.addError(schema + "." + table.name() + " — " + pub.message());
            } catch (Exception e) {
                log.error("Error indexing table {}.{}", schema, table.name(), e);
                result = result.addError(schema + "." + table.name() + " — " + e.getMessage());
            }
        }
        return result;
    }

    // ── Vistas ──

    private IndexResult indexViews(String schema, boolean force, boolean dryRun) {
        var result = IndexResult.empty();
        var views = postgresTools.listViews(schema);
        for (var view : views) {
            try {
                var def = postgresTools.getViewDefinition(schema, view.name());
                var cols = postgresTools.getViewColumns(schema, view.name());
                var hash = sha256(def);
                var docFile = docsPath.resolve("vistas").resolve(schema)
                        .resolve(schema + "_" + view.name() + ".md");

                if (!force && Files.exists(docFile) && hash.equals(readSourceHash(docFile))) {
                    result = result.addSkipped(schema + "." + view.name() + " (sin cambios)");
                    continue;
                }
                if (dryRun) {
                    result = result.addGenerated(schema + "." + view.name() + " (dry-run)");
                    continue;
                }

                var content = viewDocGenerator.generate(view, def, cols);
                content = addSourceHash(content, hash);
                var pub = publisher.publish(content);
                result = pub.success()
                        ? (Files.exists(docFile) ? result.addUpdated(schema + "." + view.name())
                                                   : result.addGenerated(schema + "." + view.name()))
                        : result.addError(schema + "." + view.name() + " — " + pub.message());
            } catch (Exception e) {
                log.error("Error indexing view {}.{}", schema, view.name(), e);
                result = result.addError(schema + "." + view.name() + " — " + e.getMessage());
            }
        }
        return result;
    }

    // ── Procedimientos ──

    private IndexResult indexProcedures(String schema, boolean force, boolean dryRun) {
        var result = IndexResult.empty();
        var procedures = postgresTools.listProcedures(schema);
        for (var proc : procedures) {
            try {
                var source = postgresTools.getProcedureSource(schema, proc.name());
                if (source.startsWith("No se encontró")) {
                    result = result.addError(schema + "." + proc.name() + " — " + source);
                    continue;
                }
                var hash = sha256(source);
                var docFile = docsPath.resolve("procedimientos").resolve(schema)
                        .resolve(schema + "_" + proc.name() + ".md");

                if (!force && Files.exists(docFile) && hash.equals(readSourceHash(docFile))) {
                    result = result.addSkipped(schema + "." + proc.name() + " (sin cambios)");
                    continue;
                }
                if (dryRun) {
                    result = result.addGenerated(schema + "." + proc.name() + " (dry-run)");
                    continue;
                }

                var content = procedureDocGenerator.generate(schema, proc.name());
                content = addSourceHash(content, hash);
                var pub = publisher.publish(content);
                result = pub.success()
                        ? (Files.exists(docFile) ? result.addUpdated(schema + "." + proc.name())
                                                   : result.addGenerated(schema + "." + proc.name()))
                        : result.addError(schema + "." + proc.name() + " — " + pub.message());
            } catch (Exception e) {
                log.error("Error indexing {}.{}", schema, proc.name(), e);
                result = result.addError(schema + "." + proc.name() + " — " + e.getMessage());
            }
        }
        return result;
    }

    // ── Triggers ──

    private IndexResult indexTriggers(String schema, boolean force, boolean dryRun) {
        var result = IndexResult.empty();
        var triggers = postgresTools.listTriggers(schema);
        for (var trigger : triggers) {
            try {
                var def = postgresTools.getTriggerDefinition(schema, trigger.name());
                var hash = sha256(def != null ? def : trigger.name());
                var docFile = docsPath.resolve("triggers").resolve(schema)
                        .resolve(schema + "_" + trigger.name() + ".md");

                if (!force && Files.exists(docFile) && hash.equals(readSourceHash(docFile))) {
                    result = result.addSkipped(schema + "." + trigger.name() + " (sin cambios)");
                    continue;
                }
                if (dryRun) {
                    result = result.addGenerated(schema + "." + trigger.name() + " (dry-run)");
                    continue;
                }

                var content = triggerDocGenerator.generate(trigger);
                content = addSourceHash(content, hash);
                var pub = publisher.publish(content);
                result = pub.success()
                        ? (Files.exists(docFile) ? result.addUpdated(schema + "." + trigger.name())
                                                   : result.addGenerated(schema + "." + trigger.name()))
                        : result.addError(schema + "." + trigger.name() + " — " + pub.message());
            } catch (Exception e) {
                log.error("Error indexing trigger {}.{}", schema, trigger.name(), e);
                result = result.addError(schema + "." + trigger.name() + " — " + e.getMessage());
            }
        }
        return result;
    }

    // ── Secuencias ──

    private IndexResult indexSequences(String schema, boolean force, boolean dryRun) {
        var result = IndexResult.empty();
        var sequences = postgresTools.listSequences(schema);
        for (var seq : sequences) {
            try {
                var hash = sha256(seq.name());
                var docFile = docsPath.resolve("secuencias").resolve(schema)
                        .resolve(schema + "_" + seq.name() + ".md");

                if (!force && Files.exists(docFile) && hash.equals(readSourceHash(docFile))) {
                    result = result.addSkipped(schema + "." + seq.name() + " (sin cambios)");
                    continue;
                }
                if (dryRun) {
                    result = result.addGenerated(schema + "." + seq.name() + " (dry-run)");
                    continue;
                }

                var content = sequenceDocGenerator.generate(seq);
                content = addSourceHash(content, hash);
                var pub = publisher.publish(content);
                result = pub.success()
                        ? (Files.exists(docFile) ? result.addUpdated(schema + "." + seq.name())
                                                   : result.addGenerated(schema + "." + seq.name()))
                        : result.addError(schema + "." + seq.name() + " — " + pub.message());
            } catch (Exception e) {
                log.error("Error indexing sequence {}.{}", schema, seq.name(), e);
                result = result.addError(schema + "." + seq.name() + " — " + e.getMessage());
            }
        }
        return result;
    }

    // ── ENUMs ──

    private IndexResult indexEnums(String schema, boolean force, boolean dryRun) {
        var result = IndexResult.empty();
        var enums = postgresTools.listEnums(schema);
        for (var e : enums) {
            try {
                var vals = postgresTools.getEnumValues(schema, e.name());
                var hash = sha256(e.name());
                var docFile = docsPath.resolve("enums").resolve(schema)
                        .resolve(schema + "_" + e.name() + ".md");

                if (!force && Files.exists(docFile) && hash.equals(readSourceHash(docFile))) {
                    result = result.addSkipped(schema + "." + e.name() + " (sin cambios)");
                    continue;
                }
                if (dryRun) {
                    result = result.addGenerated(schema + "." + e.name() + " (dry-run)");
                    continue;
                }

                var content = enumDocGenerator.generate(e);
                content = addSourceHash(content, hash);
                var pub = publisher.publish(content);
                result = pub.success()
                        ? (Files.exists(docFile) ? result.addUpdated(schema + "." + e.name())
                                                   : result.addGenerated(schema + "." + e.name()))
                        : result.addError(schema + "." + e.name() + " — " + pub.message());
            } catch (Exception ex) {
                log.error("Error indexing enum {}.{}", schema, e.name(), ex);
                result = result.addError(schema + "." + e.name() + " — " + ex.getMessage());
            }
        }
        return result;
    }

    // ── Tipos compuestos ──

    private IndexResult indexCompositeTypes(String schema, boolean force, boolean dryRun) {
        var result = IndexResult.empty();
        var types = postgresTools.listCompositeTypes(schema);
        for (var t : types) {
            try {
                var hash = sha256(t.name());
                var docFile = docsPath.resolve("tipos").resolve(schema)
                        .resolve(schema + "_" + t.name() + ".md");

                if (!force && Files.exists(docFile) && hash.equals(readSourceHash(docFile))) {
                    result = result.addSkipped(schema + "." + t.name() + " (sin cambios)");
                    continue;
                }
                if (dryRun) {
                    result = result.addGenerated(schema + "." + t.name() + " (dry-run)");
                    continue;
                }

                var content = compositeTypeDocGenerator.generate(t);
                content = addSourceHash(content, hash);
                var pub = publisher.publish(content);
                result = pub.success()
                        ? (Files.exists(docFile) ? result.addUpdated(schema + "." + t.name())
                                                   : result.addGenerated(schema + "." + t.name()))
                        : result.addError(schema + "." + t.name() + " — " + pub.message());
            } catch (Exception ex) {
                log.error("Error indexing composite type {}.{}", schema, t.name(), ex);
                result = result.addError(schema + "." + t.name() + " — " + ex.getMessage());
            }
        }
        return result;
    }

    private DocumentContent addSourceHash(DocumentContent content, String hash) {
        var newFrontMatter = new java.util.HashMap<>(content.frontMatter());
        newFrontMatter.put("source_hash", hash);
        return new DocumentContent(content.meta(), content.markdown(), newFrontMatter);
    }

    private String sha256(String input) {
        try {
            var digest = MessageDigest.getInstance("SHA-256");
            var hash = digest.digest(input.getBytes());
            return HexFormat.of().formatHex(hash).substring(0, 16);
        } catch (Exception e) {
            return "";
        }
    }

    private String readSourceHash(Path file) {
        try {
            var content = Files.readString(file);
            var matcher = HASH_PATTERN.matcher(content);
            return matcher.find() ? matcher.group(1) : null;
        } catch (Exception e) {
            return null;
        }
    }

    private IndexResult merge(IndexResult a, IndexResult b) {
        var allDetails = new java.util.ArrayList<>(a.details());
        allDetails.addAll(b.details());
        return new IndexResult(
                a.generated() + b.generated(),
                a.updated() + b.updated(),
                a.skipped() + b.skipped(),
                a.errors() + b.errors(),
                allDetails);
    }
}
