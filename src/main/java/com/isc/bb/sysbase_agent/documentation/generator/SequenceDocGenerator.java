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
public class SequenceDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(SequenceDocGenerator.class);

    public DocumentContent generate(PostgresTools.SequenceRef seq) {
        var slug = seq.schema() + "_" + seq.name();
        var meta = new DocumentMeta(
                slug,
                seq.name(),
                "secuencias/" + seq.schema(),
                "secuencias/index",
                DocumentType.SEQUENCE,
                List.of(seq.schema(), "secuencia"),
                "postgresql",
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "schema", seq.schema(),
                "type", "SEQUENCE"
        );

        var md = new StringBuilder();
        md.append("# ").append(seq.name()).append("\n\n");

        md.append("## Ficha técnica\n\n");
        md.append("| Campo | Valor |\n");
        md.append("|-------|-------|\n");
        md.append("| Schema | ").append(seq.schema()).append(" |\n");
        md.append("| Tipo de dato | ").append(seq.dataType()).append(" |\n");
        md.append("| Inicio | ").append(seq.startValue()).append(" |\n");
        md.append("| Mínimo | ").append(seq.minValue()).append(" |\n");
        md.append("| Máximo | ").append(seq.maxValue()).append(" |\n");
        md.append("| Incremento | ").append(seq.increment()).append(" |\n");
        md.append("\n");

        md.append("## Uso\n\n");
        md.append("```sql\n");
        md.append("SELECT nextval('").append(seq.schema()).append(".").append(seq.name()).append("');\n");
        md.append("-- o\n");
        md.append("SELECT currval('").append(seq.schema()).append(".").append(seq.name()).append("');\n");
        md.append("```\n\n");

        return new DocumentContent(meta, md.toString(), frontMatter);
    }
}
