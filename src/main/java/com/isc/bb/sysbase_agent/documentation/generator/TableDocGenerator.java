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
import com.isc.bb.sysbase_agent.tools.PostgresTools.TableInfo;

@Component
public class TableDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(TableDocGenerator.class);

    public DocumentContent generate(TableInfo info) {
        var slug = info.schema() + "_" + info.name();
        var meta = new DocumentMeta(
                slug,
                info.name(),
                "tablas/" + info.schema(),
                "tablas/index",
                DocumentType.TABLE,
                List.of(info.schema(), "tabla"),
                "postgresql",
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "schema", info.schema(),
                "type", "TABLE",
                "columns", info.columns().size()
        );

        var md = new StringBuilder();
        md.append("# ").append(info.name()).append("\n\n");

        md.append("## Ficha técnica\n\n");
        md.append("| Campo | Valor |\n");
        md.append("|-------|-------|\n");
        md.append("| Schema | ").append(info.schema()).append(" |\n");
        md.append("| Columnas | ").append(info.columns().size()).append(" |\n");
        md.append("| Índices | ").append(info.indexes().size()).append(" |\n");
        md.append("| Constraints | ").append(info.constraints().size()).append(" |\n");
        md.append("\n");

        md.append("## Columnas\n\n");
        md.append("| # | Nombre | Tipo | Null | Default |\n");
        md.append("|---|--------|------|------|--------|\n");
        for (var col : info.columns()) {
            md.append("| ").append(col.ordinal())
                    .append(" | `").append(col.name()).append("`")
                    .append(" | ").append(col.type())
                    .append(" | ").append(col.nullable() ? "SI" : "NO")
                    .append(" | ").append(col.defaultVal() != null ? "`" + col.defaultVal() + "`" : "—")
                    .append(" |\n");
        }
        md.append("\n");

        if (!info.constraints().isEmpty()) {
            md.append("## Constraints\n\n");
            md.append("| Nombre | Tipo | Definición |\n");
            md.append("|--------|------|-----------|\n");
            for (var c : info.constraints()) {
                md.append("| `").append(c.name()).append("`")
                        .append(" | ").append(c.type())
                        .append(" | `").append(escape(c.definition())).append("` |\n");
            }
            md.append("\n");
        }

        if (!info.indexes().isEmpty()) {
            md.append("## Índices\n\n");
            md.append("| Nombre | Columnas | Tipo | Unique |\n");
            md.append("|--------|----------|------|--------|\n");
            for (var idx : info.indexes()) {
                md.append("| `").append(idx.name()).append("`")
                        .append(" | ").append(String.join(", ", idx.columns()))
                        .append(" | ").append(idx.indexType())
                        .append(" | ").append(idx.unique() ? "SI" : "NO")
                        .append(" |\n");
            }
            md.append("\n");
        }

        md.append("## DDL\n\n");
        md.append("```sql\n");
        md.append(info.ddl());
        md.append("\n```\n\n");

        md.append("## Diagrama ER\n\n");
        md.append("```mermaid\n");
        md.append("erDiagram\n");
        md.append("    ").append(info.name()).append(" {\n");
        for (var col : info.columns()) {
            md.append("        ").append(col.type()).append(" ").append(col.name()).append("\n");
        }
        md.append("    }\n");
        md.append("```\n\n");

        return new DocumentContent(meta, md.toString(), frontMatter);
    }

    private String escape(String s) {
        return s == null ? "" : s.replace("|", "\\|").replace("\n", " ");
    }
}
