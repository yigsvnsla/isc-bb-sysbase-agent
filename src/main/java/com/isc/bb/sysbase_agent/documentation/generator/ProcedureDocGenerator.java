package com.isc.bb.sysbase_agent.documentation.generator;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.documentation.model.DocumentContent;
import com.isc.bb.sysbase_agent.documentation.model.DocumentMeta;
import com.isc.bb.sysbase_agent.documentation.model.DocumentType;
import com.isc.bb.sysbase_agent.tools.PostgresTools;

@Component
public class ProcedureDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(ProcedureDocGenerator.class);

    private final PostgresTools postgresTools;
    private final JdbcTemplate jdbc;

    public ProcedureDocGenerator(PostgresTools postgresTools, JdbcTemplate jdbc) {
        this.postgresTools = postgresTools;
        this.jdbc = jdbc;
    }

    public DocumentContent generate(String schema, String name) {
        var source = postgresTools.getProcedureSource(schema, name);
        if (source.startsWith("No se encontró")) {
            throw new IllegalArgumentException("Procedure not found: " + schema + "." + name);
        }

        var info = postgresTools.searchProcedures(name).stream()
                .filter(s -> s.schema().equals(schema) && s.name().equals(name))
                .findFirst().orElse(null);

        var dependencies = postgresTools.getDependencies(schema, name);

        var slug = schema + "_" + name;
        var meta = new DocumentMeta(
                slug,
                name,
                "procedimientos/" + schema,
                "procedimientos/index",
                DocumentType.PROCEDURE,
                List.of(schema, info != null ? info.kind() : "procedure"),
                "postgresql",
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "sidebar_position", 1,
                "schema", schema,
                "language", info != null ? info.language() : "plpgsql",
                "kind", info != null ? info.kind() : "procedure"
        );

        var md = new StringBuilder();
        md.append("# ").append(name).append("\n\n");

        if (info != null) {
            md.append("## Ficha técnica\n\n");
            md.append("| Campo | Valor |\n");
            md.append("|-------|-------|\n");
            md.append("| Schema | ").append(info.schema()).append(" |\n");
            md.append("| Tipo | ").append(info.kind()).append(" |\n");
            md.append("| Lenguaje | ").append(info.language()).append(" |\n");
            md.append("| Argumentos | `").append(escapeParam(info.args())).append("` |\n");
            if (info.resultType() != null && !info.resultType().isBlank() && !"-".equals(info.resultType())) {
                md.append("| Retorna | `").append(info.resultType()).append("` |\n");
            }
            md.append("\n");
        }

        md.append("## Código fuente\n\n");
        md.append("```sql\n");
        md.append(source);
        md.append("\n```\n\n");

        if (!dependencies.isEmpty() && !dependencies.stream().allMatch(s -> s.startsWith("No se"))) {
            md.append("## Dependencias\n\n");
            for (var dep : dependencies) {
                md.append("- `").append(dep).append("`\n");
            }
            md.append("\n");
        }

        return new DocumentContent(meta, md.toString(), frontMatter);
    }

    private String escapeParam(String args) {
        return args == null ? "" : args.replace("|", "\\|");
    }
}
