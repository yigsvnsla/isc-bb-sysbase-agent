package com.isc.bb.sysbase_agent.documentation.cli;

import java.nio.file.Path;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.shell.core.command.annotation.Command;
import org.springframework.shell.core.command.annotation.Option;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.documentation.generator.MigrationDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.ProcedureDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.SchemaDocGenerator;
import com.isc.bb.sysbase_agent.documentation.generator.StandardsDocGenerator;
import com.isc.bb.sysbase_agent.documentation.indexer.SchemaIndexer;
import com.isc.bb.sysbase_agent.documentation.model.DocumentContent;
import com.isc.bb.sysbase_agent.documentation.port.DocumentPublisher;

@Component
public class DocumentationCli {

    private static final Logger log = LoggerFactory.getLogger(DocumentationCli.class);

    private final DocumentPublisher publisher;
    private final ProcedureDocGenerator procedureDocGenerator;
    private final SchemaDocGenerator schemaDocGenerator;
    private final MigrationDocGenerator migrationDocGenerator;
    private final StandardsDocGenerator standardsDocGenerator;
    private final SchemaIndexer schemaIndexer;

    public DocumentationCli(DocumentPublisher publisher,
                            ProcedureDocGenerator procedureDocGenerator,
                            SchemaDocGenerator schemaDocGenerator,
                            MigrationDocGenerator migrationDocGenerator,
                            StandardsDocGenerator standardsDocGenerator,
                            SchemaIndexer schemaIndexer) {
        this.publisher = publisher;
        this.procedureDocGenerator = procedureDocGenerator;
        this.schemaDocGenerator = schemaDocGenerator;
        this.migrationDocGenerator = migrationDocGenerator;
        this.standardsDocGenerator = standardsDocGenerator;
        this.schemaIndexer = schemaIndexer;
    }

    @Command(name = "doc-generate", description = "Genera documentación y la publica")
    public String generate(
            @Option(longName = "type", required = true, description = "Tipo: procedure, schema, migration, standards") String type,
            @Option(longName = "schema", description = "Schema de base de datos") String schema,
            @Option(longName = "name", description = "Nombre del procedimiento") String name,
            @Option(longName = "source", description = "Archivo fuente Sybase (.txt) para migración") String source,
            @Option(longName = "engine", description = "Motor destino: postgresql, mssql, oracle", defaultValue = "postgresql") String engine,
            @Option(longName = "publish", description = "Publicar después de generar", defaultValue = "true") boolean publish) {

        DocumentContent doc;
        try {
            doc = generateDocument(type, schema, name, source, engine);
            if (doc == null) {
                return "Tipo no válido: " + type + ". Use: procedure, schema, migration, standards";
            }
        } catch (IllegalArgumentException e) {
            return "Error: " + e.getMessage();
        } catch (Exception e) {
            log.error("Error generating doc", e);
            return "Error: " + e.getMessage();
        }

        var sb = new StringBuilder();
        sb.append("Documento generado: ").append(doc.meta().title()).append("\n");
        sb.append("  ID: ").append(doc.meta().id()).append("\n");
        sb.append("  Categoría: ").append(doc.meta().category()).append("\n");
        sb.append("  Tipo: ").append(doc.meta().type()).append("\n");
        sb.append("  Tags: ").append(doc.meta().tags()).append("\n");

        if (publish) {
            var result = publisher.publish(doc);
            if (result.success()) {
                sb.append("  Publicado: ").append(result.url()).append("\n");
            } else {
                sb.append("  Error publicando: ").append(result.message()).append("\n");
            }
        } else {
            sb.append("  (no publicado — usar doc-publish)\n");
        }

        return sb.toString();
    }

    @Command(name = "doc-publish", description = "Publica documentos generados y regenera índice")
    public String publish(
            @Option(longName = "rebuild", description = "Regenerar sidebars.js después de publicar", defaultValue = "true") boolean rebuild) {

        if (rebuild) {
            var result = publisher.buildIndex();
            if (result.success()) {
                return "Índice regenerado: " + result.url();
            } else {
                return "Error regenerando índice: " + result.message();
            }
        }
        return "Usar --rebuild para regenerar el índice";
    }

    @Command(name = "doc-index", description = "Indexa objetos de base de datos y genera documentación")
    public String index(
            @Option(longName = "schema", description = "Schema específico (requerido si no --all)") String schema,
            @Option(longName = "all", description = "Indexar todos los schemas", defaultValue = "false") boolean all,
            @Option(longName = "types", description = "Tipos a indexar: table,view,procedure,trigger,sequence,enum,type") String types,
            @Option(longName = "force", description = "Regenerar todo ignorando hash", defaultValue = "false") boolean force,
            @Option(longName = "dry-run", description = "Mostrar qué se indexaría sin escribir", defaultValue = "false") boolean dryRun) {

        if (!all && (schema == null || schema.isBlank())) {
            return "Usar --schema <nombre> o --all";
        }

        var typeSet = parseTypes(types);
        var result = all
                ? schemaIndexer.indexAll(force, dryRun, typeSet)
                : schemaIndexer.indexSchema(schema, force, dryRun, typeSet);

        var sb = new StringBuilder();
        sb.append(result.summary()).append("\n");
        sb.append("Generados: ").append(result.generated()).append("\n");
        sb.append("Actualizados: ").append(result.updated()).append("\n");
        sb.append("Saltados: ").append(result.skipped()).append("\n");
        sb.append("Errores: ").append(result.errors()).append("\n");

        if (!result.details().isEmpty()) {
            sb.append("\nDetalle:\n");
            for (var detail : result.details()) {
                sb.append("  ").append(detail).append("\n");
            }
        }

        if (dryRun) {
            sb.append("\nDRY-RUN: no se escribió nada. Usar sin --dry-run para ejecutar.\n");
        }

        return sb.toString();
    }

    private java.util.Set<String> parseTypes(String types) {
        if (types == null || types.isBlank()) return java.util.Set.of();
        return java.util.Set.of(types.split("\\s*,\\s*"));
    }

    @Command(name = "doc-status", description = "Muestra estado de la documentación generada")
    public String status() {
        var sb = new StringBuilder();
        sb.append("Document Publisher: ").append(publisher.adapterType()).append("\n");

        var categories = new String[]{"procedimientos", "esquemas", "migraciones", "estandares", "diagramas"};
        for (var cat : categories) {
            var docs = publisher.listByCategory(cat);
            sb.append("\n## ").append(cat).append(" (").append(docs.size()).append(" docs)\n");
            for (var doc : docs) {
                var exists = publisher.exists(doc.id()) ? "publicado" : "pendiente";
                sb.append("  - ").append(doc.title()).append(" [").append(exists).append("]\n");
            }
        }
        return sb.toString();
    }

    private DocumentContent generateDocument(String type, String schema, String name,
                                              String source, String engine) {
        return switch (type.toLowerCase()) {
            case "procedure" -> {
                if (schema == null || name == null)
                    throw new IllegalArgumentException("--schema y --name requeridos para type=procedure");
                yield procedureDocGenerator.generate(schema, name);
            }
            case "schema" -> {
                if (schema == null)
                    throw new IllegalArgumentException("--schema requerido para type=schema");
                yield schemaDocGenerator.generate(schema);
            }
            case "migration" -> {
                if (source == null)
                    throw new IllegalArgumentException("--source requerido para type=migration");
                yield migrationDocGenerator.generate(Path.of(source), engine);
            }
            case "standards" -> standardsDocGenerator.generate(engine);
            default -> null;
        };
    }
}
