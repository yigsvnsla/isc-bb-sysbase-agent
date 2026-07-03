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
public class CompositeTypeDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(CompositeTypeDocGenerator.class);

    private final PostgresTools postgresTools;

    public CompositeTypeDocGenerator(PostgresTools postgresTools) {
        this.postgresTools = postgresTools;
    }

    public DocumentContent generate(PostgresTools.CompositeTypeRef typeRef) {
        var attrs = postgresTools.getCompositeTypeAttrs(typeRef.schema(), typeRef.name());

        var slug = typeRef.schema() + "_" + typeRef.name();
        var meta = new DocumentMeta(
                slug,
                typeRef.name(),
                "tipos/" + typeRef.schema(),
                "tipos/index",
                DocumentType.COMPOSITE_TYPE,
                List.of(typeRef.schema(), "tipo_compuesto"),
                "postgresql",
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "schema", typeRef.schema(),
                "type", "COMPOSITE_TYPE"
        );

        var md = new StringBuilder();
        md.append("# ").append(typeRef.name()).append("\n\n");

        md.append("## Ficha técnica\n\n");
        md.append("| Campo | Valor |\n");
        md.append("|-------|-------|\n");
        md.append("| Schema | ").append(typeRef.schema()).append(" |\n");
        md.append("| Atributos | ").append(attrs.size()).append(" |\n");
        md.append("\n");

        md.append("## Atributos\n\n");
        md.append("| # | Nombre | Tipo |\n");
        md.append("|---|--------|------|\n");
        for (int i = 0; i < attrs.size(); i++) {
            var attr = attrs.get(i);
            md.append("| ").append(i + 1)
                    .append(" | `").append(attr.name()).append("`")
                    .append(" | ").append(attr.type())
                    .append(" |\n");
        }
        md.append("\n");

        md.append("## Definición SQL\n\n");
        md.append("```sql\n");
        md.append("CREATE TYPE ").append(typeRef.schema()).append(".").append(typeRef.name())
                .append(" AS (\n");
        for (int i = 0; i < attrs.size(); i++) {
            var attr = attrs.get(i);
            md.append("    ").append(attr.name()).append(" ").append(attr.type());
            if (i < attrs.size() - 1) md.append(",");
            md.append("\n");
        }
        md.append(");\n");
        md.append("```\n\n");

        return new DocumentContent(meta, md.toString(), frontMatter);
    }
}
