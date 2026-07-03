package com.isc.bb.sysbase_agent.documentation.generator;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.documentation.model.DocumentContent;
import com.isc.bb.sysbase_agent.documentation.model.DocumentMeta;
import com.isc.bb.sysbase_agent.documentation.model.DocumentType;
import com.isc.bb.sysbase_agent.tools.PostgresTools;

@Component
public class SchemaDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(SchemaDocGenerator.class);

    private final PostgresTools postgresTools;

    public SchemaDocGenerator(PostgresTools postgresTools) {
        this.postgresTools = postgresTools;
    }

    public DocumentContent generate(String schema) {
        var procedures = postgresTools.listProcedures(schema);

        var slug = schema;
        var meta = new DocumentMeta(
                slug,
                "Esquema " + schema,
                "esquemas",
                "esquemas/index",
                DocumentType.SCHEMA,
                List.of(schema, "esquema"),
                "postgresql",
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "sidebar_position", 1,
                "schema", schema
        );

        var md = new StringBuilder();
        md.append("# Esquema: ").append(schema).append("\n\n");

        if (procedures.isEmpty()) {
            md.append("No se encontraron procedimientos o funciones en el esquema `")
                    .append(schema).append("`.\n\n");
        } else {
            md.append("## Procedimientos y funciones\n\n");
            md.append("| Nombre | Tipo | Lenguaje | Argumentos |\n");
            md.append("|--------|------|----------|------------|\n");

            for (var proc : procedures) {
                md.append("| `").append(proc.name()).append("` | ")
                        .append(proc.kind()).append(" | ")
                        .append(proc.language()).append(" | ")
                        .append("`").append(escape(proc.args())).append("` |\n");
            }
            md.append("\n");

            md.append("## Listado\n\n");
            for (var proc : procedures) {
                md.append("- [").append(proc.name()).append("](../procedimientos/")
                        .append(schema).append("/").append(schema).append("_").append(proc.name())
                        .append(")\n");
            }
            md.append("\n");
        }

        return new DocumentContent(meta, md.toString(), frontMatter);
    }

    private String escape(String s) {
        return s == null ? "" : s.replace("|", "\\|");
    }
}
