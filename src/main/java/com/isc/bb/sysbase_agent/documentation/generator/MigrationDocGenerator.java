package com.isc.bb.sysbase_agent.documentation.generator;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.documentation.model.DocumentContent;
import com.isc.bb.sysbase_agent.documentation.model.DocumentMeta;
import com.isc.bb.sysbase_agent.documentation.model.DocumentType;
import com.isc.bb.sysbase_agent.tools.KnowledgeBaseTool;

@Component
public class MigrationDocGenerator {

    private static final Logger log = LoggerFactory.getLogger(MigrationDocGenerator.class);

    private final KnowledgeBaseTool knowledgeBaseTool;

    public MigrationDocGenerator(KnowledgeBaseTool knowledgeBaseTool) {
        this.knowledgeBaseTool = knowledgeBaseTool;
    }

    public DocumentContent generate(Path sourceFile, String targetEngine) {
        String sourceCode;
        try {
            sourceCode = Files.readString(sourceFile);
        } catch (IOException e) {
            throw new IllegalArgumentException("Cannot read source file: " + sourceFile, e);
        }

        var analysis = knowledgeBaseTool.analyzeSql(sourceCode, null);
        var sourceName = sourceFile.getFileName().toString().replaceFirst("\\.(txt|sql|sp)$", "");

        var slug = sourceName;
        var meta = new DocumentMeta(
                slug,
                "Migración: " + sourceName,
                "migraciones",
                "migraciones/index",
                DocumentType.MIGRATION,
                List.of("migracion", targetEngine),
                targetEngine,
                ZonedDateTime.now(),
                "1.0.0"
        );

        var frontMatter = Map.<String, Object>of(
                "sidebar_position", 1,
                "target_engine", targetEngine,
                "source_file", sourceFile.getFileName().toString()
        );

        var md = new StringBuilder();
        md.append("# Migración: ").append(sourceName).append("\n\n");

        md.append("## Archivo origen\n\n");
        md.append("- **Archivo**: `").append(sourceFile.getFileName()).append("`\n");
        md.append("- **Motor destino**: ").append(targetEngine).append("\n\n");

        md.append("## Análisis del código origen\n\n");
        md.append(analysis).append("\n\n");

        md.append("## Código origen\n\n");
        md.append("```sql\n");
        md.append(sourceCode);
        md.append("\n```\n\n");

        md.append("## Tabla de equivalencias\n\n");
        md.append("| Concepto Sybase | Equivalente ").append(capitalize(targetEngine)).append(" |\n");
        md.append("|-----------------|-----------------------|\n");
        md.append("| `@@rowcount` | `GET DIAGNOSTICS` o `NOT FOUND` |\n");
        md.append("| `@@error` | `EXCEPTION` block |\n");
        md.append("| `dateadd(day, n, date)` | `date + n` |\n");
        md.append("| `convert(varchar, date, 101)` | `date::text` o `TO_CHAR(date, 'MM/DD/YYYY')` |\n");
        md.append("| `raiserror` | `RAISE` |\n");
        md.append("| `PRINT` | `RAISE NOTICE` |\n");
        md.append("\n");

        return new DocumentContent(meta, md.toString(), frontMatter);
    }

    private String capitalize(String s) {
        return s == null || s.isEmpty() ? s : Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }
}
