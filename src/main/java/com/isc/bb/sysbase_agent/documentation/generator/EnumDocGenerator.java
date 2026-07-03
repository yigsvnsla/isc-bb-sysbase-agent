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
public class EnumDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(EnumDocGenerator.class);

    private final PostgresTools postgresTools;

    public EnumDocGenerator(PostgresTools postgresTools) {
        this.postgresTools = postgresTools;
    }

    public DocumentContent generate(PostgresTools.EnumRef enumRef) {
        var values = postgresTools.getEnumValues(enumRef.schema(), enumRef.name());

        var slug = enumRef.schema() + "_" + enumRef.name();
        var meta = new DocumentMeta(
                slug,
                enumRef.name(),
                "enums/" + enumRef.schema(),
                "enums/index",
                DocumentType.ENUM,
                List.of(enumRef.schema(), "enum"),
                "postgresql",
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "schema", enumRef.schema(),
                "type", "ENUM",
                "values", values.size()
        );

        var md = new StringBuilder();
        md.append("# ").append(enumRef.name()).append("\n\n");

        md.append("## Ficha técnica\n\n");
        md.append("| Campo | Valor |\n");
        md.append("|-------|-------|\n");
        md.append("| Schema | ").append(enumRef.schema()).append(" |\n");
        md.append("| Valores | ").append(values.size()).append(" |\n");
        md.append("\n");

        md.append("## Valores\n\n");
        for (int i = 0; i < values.size(); i++) {
            md.append(i + 1).append(". `").append(values.get(i)).append("`\n");
        }
        md.append("\n");

        md.append("## Definición SQL\n\n");
        md.append("```sql\n");
        md.append("CREATE TYPE ").append(enumRef.schema()).append(".").append(enumRef.name())
                .append(" AS ENUM (\n");
        for (int i = 0; i < values.size(); i++) {
            md.append("    '").append(values.get(i)).append("'");
            if (i < values.size() - 1) md.append(",");
            md.append("\n");
        }
        md.append(");\n");
        md.append("```\n\n");

        return new DocumentContent(meta, md.toString(), frontMatter);
    }
}
