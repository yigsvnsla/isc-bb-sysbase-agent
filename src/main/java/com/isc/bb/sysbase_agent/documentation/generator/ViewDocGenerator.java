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
import com.isc.bb.sysbase_agent.tools.PostgresTools.ColumnDef;
import com.isc.bb.sysbase_agent.tools.PostgresTools.ViewRef;

@Component
public class ViewDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(ViewDocGenerator.class);

    public DocumentContent generate(ViewRef view, String definition, List<ColumnDef> columns) {
        var slug = view.schema() + "_" + view.name();
        var meta = new DocumentMeta(
                slug,
                view.name(),
                "vistas/" + view.schema(),
                "vistas/index",
                DocumentType.VIEW,
                List.of(view.schema(), "vista"),
                "postgresql",
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "schema", view.schema(),
                "type", "VIEW"
        );

        var md = new StringBuilder();
        md.append("# ").append(view.name()).append("\n\n");

        md.append("## Ficha técnica\n\n");
        md.append("| Campo | Valor |\n");
        md.append("|-------|-------|\n");
        md.append("| Schema | ").append(view.schema()).append(" |\n");
        if (!columns.isEmpty()) {
            md.append("| Columnas | ").append(columns.size()).append(" |\n");
        }
        md.append("\n");

        if (!columns.isEmpty()) {
            md.append("## Columnas\n\n");
            md.append("| # | Nombre | Tipo | Null |\n");
            md.append("|---|--------|------|------|\n");
            for (var col : columns) {
                md.append("| ").append(col.ordinal())
                        .append(" | `").append(col.name()).append("`")
                        .append(" | ").append(col.type())
                        .append(" | ").append(col.nullable() ? "SI" : "NO")
                        .append(" |\n");
            }
            md.append("\n");
        }

        md.append("## DDL\n\n");
        md.append("```sql\n");
        md.append("CREATE OR REPLACE VIEW ").append(view.schema()).append(".").append(view.name()).append(" AS\n");
        md.append(definition);
        md.append("\n```\n\n");

        return new DocumentContent(meta, md.toString(), frontMatter);
    }
}
