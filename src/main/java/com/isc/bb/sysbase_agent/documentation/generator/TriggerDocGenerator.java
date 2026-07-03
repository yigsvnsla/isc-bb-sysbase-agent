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
public class TriggerDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(TriggerDocGenerator.class);

    private final PostgresTools postgresTools;

    public TriggerDocGenerator(PostgresTools postgresTools) {
        this.postgresTools = postgresTools;
    }

    public DocumentContent generate(PostgresTools.TriggerRef trigger) {
        var definition = postgresTools.getTriggerDefinition(trigger.schema(), trigger.name());

        var slug = trigger.schema() + "_" + trigger.name();
        var meta = new DocumentMeta(
                slug,
                trigger.name(),
                "triggers/" + trigger.schema(),
                "triggers/index",
                DocumentType.TRIGGER,
                List.of(trigger.schema(), "trigger", trigger.timing(), trigger.event()),
                "postgresql",
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "schema", trigger.schema(),
                "table", trigger.table(),
                "timing", trigger.timing(),
                "event", trigger.event(),
                "type", "TRIGGER"
        );

        var md = new StringBuilder();
        md.append("# ").append(trigger.name()).append("\n\n");

        md.append("## Ficha técnica\n\n");
        md.append("| Campo | Valor |\n");
        md.append("|-------|-------|\n");
        md.append("| Schema | ").append(trigger.schema()).append(" |\n");
        md.append("| Tabla | `").append(trigger.table()).append("` |\n");
        md.append("| Timing | ").append(trigger.timing()).append(" |\n");
        md.append("| Evento | ").append(trigger.event()).append(" |\n");
        md.append("| Función | `").append(trigger.function()).append("` |\n");
        md.append("| Habilitado | ").append(trigger.enabled() ? "SI" : "NO").append(" |\n");
        md.append("\n");

        if (definition != null) {
            md.append("## DDL\n\n");
            md.append("```sql\n");
            md.append(definition);
            md.append("\n```\n\n");
        }

        md.append("## Referencias\n\n");
        md.append("- Tabla: [").append(trigger.table()).append("](../../tablas/")
                .append(trigger.schema()).append("/").append(trigger.schema()).append("_")
                .append(trigger.table()).append(")\n");
        if (trigger.function() != null && !trigger.function().isBlank()) {
            md.append("- Función: [").append(trigger.function()).append("](../../procedimientos/")
                    .append(trigger.schema()).append("/").append(trigger.schema()).append("_")
                    .append(trigger.function()).append(")\n");
        }
        md.append("\n");

        return new DocumentContent(meta, md.toString(), frontMatter);
    }
}
