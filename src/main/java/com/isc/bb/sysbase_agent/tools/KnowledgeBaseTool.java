package com.isc.bb.sysbase_agent.tools;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.springframework.ai.document.Document;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import tools.jackson.databind.ObjectMapper;

@Component
public class KnowledgeBaseTool {

    private final VectorStore vectorStore;
    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public KnowledgeBaseTool(VectorStore vectorStore, JdbcTemplate jdbcTemplate, ObjectMapper objectMapper) {
        this.vectorStore = vectorStore;
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = objectMapper;
    }

    @Tool(name = "search_knowledge_base", description = "Busca documentación técnica indexada en PDFs. Útil para consultar manuales, guías, documentación sobre PostgreSQL, stored procedures, tablas, configuraciones, etc.")
    public String searchKnowledgeBase(String query) {
        var vectorResults = vectorStore.similaritySearch(
                SearchRequest.builder().query(query).topK(12).similarityThreshold(0.25).build());

        var seen = new HashSet<String>();
        var combined = new ArrayList<Document>();
        for (var d : vectorResults) {
            if (seen.add(d.getText())) {
                combined.add(d);
            }
        }

        if (combined.size() < 5) {
            var keywordResults = searchByKeyword(query);
            for (var d : keywordResults) {
                if (seen.add(d.getText())) {
                    combined.add(d);
                }
            }
        }

        if (combined.isEmpty()) {
            return "No se encontraron resultados relevantes en la base de conocimientos para: " + query;
        }

        return combined.stream()
                .map(d -> {
                    var src = d.getMetadata().getOrDefault("source", "?");
                    var page = d.getMetadata().getOrDefault("page", "?");
                    var score = d.getScore() != null ? String.format("%.2f", d.getScore()) : "?";
                    return "[%s pág.%s (score:%s)]:\n%s".formatted(src, page, score, d.getText());
                })
                .collect(Collectors.joining("\n\n---\n\n"));
    }

    @Tool(name = "analyze_sql", description = "Analiza código SQL: detecta dialecto (Sybase ASE, MSSQL, Oracle, PostgreSQL), identifica estructura, tablas referenciadas, parámetros, y valida contra naming conventions. engineHint opcional: 'sybase', 'mssql', 'oracle', 'postgresql' o vacío para auto-detectar.")
    public String analyzeSql(String sqlCode, String engineHint) {
        if (sqlCode == null || sqlCode.isBlank()) {
            return "No se proporcionó código SQL para analizar.";
        }

        var dialect = detectDialect(sqlCode);
        var engine = (engineHint != null && !engineHint.isBlank())
                ? engineHint.toLowerCase() : dialect.engine;
        var structure = parseStructure(sqlCode);
        var tables = extractTables(sqlCode);
        var params = extractParameters(sqlCode, engine);
        var validation = validateConventions(sqlCode, dialect.engine);

        var sb = new StringBuilder();
        sb.append("## Dialecto detectado: ").append(dialect.name).append("\n");
        sb.append("## Certeza: ").append(dialect.confidence).append("\n\n");

        sb.append("### Estructura\n");
        sb.append("- Tipo: ").append(structure).append("\n");
        if (!params.isEmpty()) {
            sb.append("- Parámetros: ").append(String.join(", ", params)).append("\n");
        }
        if (!tables.isEmpty()) {
            sb.append("- Tablas referenciadas: ").append(String.join(", ", tables)).append("\n");
        }
        var operations = detectOperations(sqlCode);
        if (!operations.isEmpty()) {
            sb.append("- Operaciones: ").append(String.join(", ", operations)).append("\n");
        }
        sb.append("\n");

        sb.append("### Validación naming conventions\n");
        sb.append("- Motor: ").append(validation.motor).append("\n");
        sb.append("- Nombres: ").append(validation.nombres).append("\n");
        sb.append("- Parámetros: ").append(validation.parametros).append("\n");
        sb.append("- Transacciones: ").append(validation.transacciones).append("\n");
        sb.append("- Observaciones: ").append(validation.observaciones).append("\n");
        sb.append("\n");

        var arqtValidation = validateArqtEst001(sqlCode, dialect.engine);
        if (!arqtValidation.isEmpty()) {
            sb.append("### Validación ARQT-EST-001\n");
            for (var entry : arqtValidation) {
                sb.append("- ").append(entry).append("\n");
            }
            sb.append("\n");
        }

        if (!tables.isEmpty()) {
            var searchTerms = tables.size() > 3
                    ? tables.stream().limit(3).collect(Collectors.joining(" "))
                    : String.join(" ", tables);
            var searchQuery = engine + " " + searchTerms;

            var relatedDocs = vectorStore.similaritySearch(
                    SearchRequest.builder().query(searchQuery).topK(3).similarityThreshold(0.25).build());

            if (!relatedDocs.isEmpty()) {
                sb.append("### Documentación relacionada\n");
                for (var doc : relatedDocs) {
                    var src = doc.getMetadata().getOrDefault("source", "?");
                    var score = doc.getScore() != null ? String.format("%.2f", doc.getScore()) : "?";
                    sb.append("- [").append(src).append(" (score:").append(score).append(")]\n");
                }
                sb.append("\n");
            }
        }

        return sb.toString();
    }

    private record DialectResult(String name, String engine, String confidence) {}
    private record ValidationResult(String motor, String nombres, String parametros, String transacciones, String observaciones) {}

    private DialectResult detectDialect(String sql) {
        var upper = sql.toUpperCase();

        int sybaseScore = 0;
        if (Pattern.compile("@@ERROR\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 3;
        if (Pattern.compile("@@ROWCOUNT\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 3;
        if (Pattern.compile("@@SQLSTATUS\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 3;
        if (Pattern.compile("\\bLOCK\\s+(ALLPAGES|DATAPAGES|TABPAGES)\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 3;
        if (Pattern.compile("\\bIDENTITY_GAP\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 2;
        if (Pattern.compile("\\bPRINT\\s+'", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 2;
        if (Pattern.compile("\\bWAITFOR\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 1;
        if (Pattern.compile("\\bCHAINED\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 3;
        if (Pattern.compile("\\bDEALLOCATE\\s+CURSOR\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 1;
        if (Pattern.compile("\\bSCOPE_IDENTITY\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 2;
        if (Pattern.compile("\\bROLLBACK\\s+TRIGGER\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 3;
        if (Pattern.compile("\\bSET\\s+NOCOUNT\\s+ON\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 1;
        if (Pattern.compile("\\bRAISERROR\\s+\\d+", Pattern.CASE_INSENSITIVE).matcher(sql).find()) sybaseScore += 2;

        int mssqlScore = 0;
        if (Pattern.compile("\\bNVARCHAR\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 3;
        if (Pattern.compile("\\bDATETIME2\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 3;
        if (Pattern.compile("\\bUNIQUEIDENTIFIER\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 2;
        if (Pattern.compile("\\bBEGIN\\s+TRY\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 4;
        if (Pattern.compile("\\bCATCH\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 3;
        if (Pattern.compile("\\bTHROW\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 3;
        if (Pattern.compile("\\bdbo\\.", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 2;
        if (Pattern.compile("\\bTOP\\s*\\(", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 2;
        if (Pattern.compile("\\bOFFSET\\b.*\\bFETCH\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 2;
        if (Pattern.compile("\\bROWVERSION\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 2;
        if (Pattern.compile("\\bSYSUTCDATETIME\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 2;
        if (Pattern.compile("\\bROW_NUMBER\\s*\\(\\).*OVER\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 2;
        if (Pattern.compile("\\bFOR\\s+JSON\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 2;
        if (Pattern.compile("\\bOPENJSON\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) mssqlScore += 2;

        int oracleScore = 0;
        if (Pattern.compile("\\bVARCHAR2\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 4;
        if (Pattern.compile("\\bNUMBER\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 2;
        if (Pattern.compile("\\bPLS_INTEGER\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 2;
        if (Pattern.compile("\\bCLOB\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 2;
        if (Pattern.compile("\\bBLOB\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 2;
        if (Pattern.compile("\\bCREATE\\s+OR\\s+REPLACE\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 3;
        if (Pattern.compile("\\.NEXTVAL", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 3;
        if (Pattern.compile("\\.CURRVAL", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 2;
        if (Pattern.compile("\\bPRAGMA\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 3;
        if (Pattern.compile("\\bEXCEPTION\\s+WHEN\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 3;
        if (Pattern.compile("\\bPIPELINED\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 3;
        if (Pattern.compile("\\bRETURNING\\s+INTO\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 2;
        if (Pattern.compile("\\bSYSTIMESTAMP\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 2;
        if (Pattern.compile("\\bSYS_REFCURSOR\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 3;
        if (Pattern.compile("\\bAUTONOMOUS_TRANSACTION\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 3;
        if (Pattern.compile("\\bDUP_VAL_ON_INDEX\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 2;
        if (Pattern.compile("\\bNO_DATA_FOUND\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 2;
        if (Pattern.compile("\\bSAVEPOINT\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) oracleScore += 1;

        int pgScore = 0;
        if (Pattern.compile("\\bRETURNS\\s+TABLE\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) pgScore += 3;
        if (Pattern.compile("\\bRETURNS\\s+SETOF\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) pgScore += 3;
        if (Pattern.compile("\\bLANGUAGE\\s+plpgsql\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) pgScore += 4;
        if (Pattern.compile("\\bSERIAL\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) pgScore += 2;
        if (Pattern.compile("\\bBIGSERIAL\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) pgScore += 2;

        var maxScore = Math.max(Math.max(sybaseScore, mssqlScore), Math.max(oracleScore, pgScore));

        if (maxScore == 0) {
            return new DialectResult("Indeterminado", "desconocido", "baja");
        }

        String name, engine;
        if (sybaseScore == maxScore && sybaseScore > 0) {
            name = "Sybase ASE";
            engine = "sybase";
        } else if (mssqlScore == maxScore && mssqlScore > 0) {
            name = "Microsoft SQL Server";
            engine = "mssql";
        } else if (oracleScore == maxScore && oracleScore > 0) {
            name = "Oracle Database";
            engine = "oracle";
        } else {
            name = "PostgreSQL";
            engine = "postgresql";
        }

        var confidence = maxScore >= 8 ? "alta" : maxScore >= 4 ? "media" : "baja";
        return new DialectResult(name, engine, confidence);
    }

    private String parseStructure(String sql) {
        var upper = sql.trim().toUpperCase();

        if (upper.startsWith("CREATE TABLE") || upper.startsWith("CREATE GLOBAL TEMPORARY TABLE")) {
            return "DDL (CREATE TABLE)";
        }
        if (Pattern.compile("^CREATE\\s+(OR\\s+REPLACE\\s+)?PROCEDURE\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()
                || upper.startsWith("CREATE PROC")) {
            return "Stored Procedure";
        }
        if (Pattern.compile("^CREATE\\s+(OR\\s+REPLACE\\s+)?FUNCTION\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) {
            return "Function";
        }
        if (Pattern.compile("^CREATE\\s+(OR\\s+REPLACE\\s+)?PACKAGE\\s+BODY\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) {
            return "Package Body";
        }
        if (Pattern.compile("^CREATE\\s+(OR\\s+REPLACE\\s+)?PACKAGE\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) {
            return "Package";
        }
        if (Pattern.compile("^CREATE\\s+(OR\\s+REPLACE\\s+)?TRIGGER\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) {
            return "Trigger";
        }
        if (Pattern.compile("^CREATE\\s+(OR\\s+REPLACE\\s+)?VIEW\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) {
            return "View";
        }
        if (Pattern.compile("^CREATE\\s+(UNIQUE\\s+)?INDEX\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) {
            return "DDL (INDEX)";
        }
        if (Pattern.compile("^CREATE\\s+SEQUENCE\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) {
            return "DDL (SEQUENCE)";
        }
        if (upper.matches("^SELECT\\b.*")) {
            return "Query (SELECT)";
        }
        if (upper.startsWith("INSERT")) {
            return "DML (INSERT)";
        }
        if (upper.startsWith("UPDATE")) {
            return "DML (UPDATE)";
        }
        if (upper.startsWith("DELETE")) {
            return "DML (DELETE)";
        }
        if (upper.startsWith("MERGE")) {
            return "DML (MERGE)";
        }
        if (upper.startsWith("ALTER")) {
            return "DDL (ALTER)";
        }
        if (upper.startsWith("DROP")) {
            return "DDL (DROP)";
        }
        if (Pattern.compile("\\bDECLARE\\b.*\\bCURSOR\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) {
            return "Cursor";
        }

        return "Fragmento SQL";
    }

    private List<String> extractTables(String sql) {
        var tables = new LinkedHashSet<String>();
        var regexes = List.of(
            "FROM\\s+(\\w+(?:\\.\\w+)?)",
            "JOIN\\s+(\\w+(?:\\.\\w+)?)",
            "INTO\\s+(\\w+(?:\\.\\w+)?)",
            "UPDATE\\s+(\\w+(?:\\.\\w+)?)",
            "TABLE\\s+(\\w+(?:\\.\\w+)?)",
            "REFERENCES\\s+(\\w+(?:\\.\\w+)?)",
            "INSERT\\s+(?:INTO\\s+)?(\\w+(?:\\.\\w+)?)"
        );
        for (var regex : regexes) {
            var matcher = Pattern.compile(regex, Pattern.CASE_INSENSITIVE).matcher(sql);
            while (matcher.find()) {
                tables.add(matcher.group(1));
            }
        }
        return List.copyOf(tables);
    }

    private List<String> extractParameters(String sql, String engine) {
        var params = new LinkedHashSet<String>();
        if ("sybase".equals(engine) || "mssql".equals(engine)) {
            var matcher = Pattern.compile("@\\w+").matcher(sql);
            while (matcher.find()) {
                params.add(matcher.group());
            }
        } else if ("oracle".equals(engine)) {
            var matcher = Pattern.compile("p_\\w+").matcher(sql);
            while (matcher.find()) {
                params.add(matcher.group());
            }
        }
        return List.copyOf(params);
    }

    private List<String> detectOperations(String sql) {
        var ops = new LinkedHashSet<String>();
        if (Pattern.compile("\\bSELECT\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) ops.add("SELECT");
        if (Pattern.compile("\\bINSERT\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) ops.add("INSERT");
        if (Pattern.compile("\\bUPDATE\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) ops.add("UPDATE");
        if (Pattern.compile("\\bDELETE\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) ops.add("DELETE");
        if (Pattern.compile("\\bMERGE\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()) ops.add("MERGE");
        return List.copyOf(ops);
    }

    private ValidationResult validateConventions(String sql, String detectedEngine) {
        var upper = sql.toUpperCase();

        String motor, nombres, params, transacciones, observaciones;

        if ("sybase".equals(detectedEngine)) {
            motor = hasAny(upper, "@@ERROR", "@@ROWCOUNT", "RAISERROR", "LOCK ALLPAGES")
                    ? "✓ cumple (usa @@error, RAISERROR, LOCK)"
                    : "⚠ sintaxis genérica, faltan marcas Sybase ASE";

            nombres = upper.contains("SNAKE_CASE") || Pattern.compile("\\bsp_\\w+\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()
                    ? "✓ snake_case con prefijo sp_"
                    : "⚠ considera usar snake_case y prefijo sp_";

            params = Pattern.compile("@\\w+", Pattern.CASE_INSENSITIVE).matcher(sql).find()
                    ? "✓ @prefijo (convención Sybase/MSSQL)"
                    : "⚠ usa @param para parámetros";

            transacciones = hasAny(upper, "BEGIN TRAN", "COMMIT", "ROLLBACK", "SAVE TRANSACTION", "SET CHAINED ON")
                    ? "✓ manejo de transacciones presente"
                    : "⚠ no se detectó manejo de transacciones";

            observaciones = "Sybase ASE usa @@error para control de errores. "
                    + "Preferir RAISERROR con números > 50000 para errores personalizados. "
                    + "Usar LOCK ALLPAGES/DATAPAGES según concurrencia esperada.";

        } else if ("mssql".equals(detectedEngine)) {
            motor = hasAny(upper, "BEGIN TRY", "BEGIN CATCH", "THROW")
                    ? "✓ cumple (usa TRY/CATCH/THROW)"
                    : "⚠ considera usar TRY/CATCH/THROW en lugar de @@error";

            nombres = Pattern.compile("\\b(usp_|dbo\\.)", Pattern.CASE_INSENSITIVE).matcher(sql).find()
                    ? "✓ PascalCase con esquema dbo y prefijo usp_"
                    : "⚠ considera esquema dbo y prefijo usp_";

            params = Pattern.compile("@\\w+", Pattern.CASE_INSENSITIVE).matcher(sql).find()
                    ? "✓ @param (convención MSSQL)"
                    : "⚠ usa @param para parámetros";

            transacciones = hasAny(upper, "BEGIN TRANSACTION", "BEGIN TRAN", "COMMIT", "ROLLBACK", "XACT_ABORT")
                    ? "✓ manejo de transacciones presente"
                    : "⚠ no se detectó manejo de transacciones";

            observaciones = "MSSQL moderno usa TRY/CATCH/THROW. "
                    + "SET XACT_ABORT ON asegura rollback automático. "
                    + "Usar ROWVERSION para control de concurrencia.";

        } else if ("oracle".equals(detectedEngine)) {
            motor = hasAny(upper, "CREATE OR REPLACE", "EXCEPTION WHEN", "PRAGMA")
                    ? "✓ cumple (CREATE OR REPLACE, EXCEPTION, PRAGMA)"
                    : "⚠ faltan patrones Oracle típicos";

            nombres = Pattern.compile("\\bp_\\w+\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find()
                    ? "✓ prefijo p_ para procedimientos"
                    : "⚠ considera prefijo p_ para procedimientos";

            params = Pattern.compile("\\b(p_|IN\\s+|OUT\\s+)", Pattern.CASE_INSENSITIVE).matcher(sql).find()
                    ? "✓ p_prefijo con modos IN/OUT"
                    : "⚠ usa p_prefijo con modos IN/OUT explícitos";

            transacciones = hasAny(upper, "COMMIT", "ROLLBACK", "SAVEPOINT", "AUTONOMOUS_TRANSACTION", "PRAGMA AUTONOMOUS")
                    ? "✓ manejo de transacciones presente"
                    : "⚠ no se detectó manejo de transacciones";

            observaciones = "Oracle usa CREATE OR REPLACE. "
                    + "Encapsular lógica en paquetes (PACKAGE/PACKAGE BODY). "
                    + "Usar PRAGMA AUTONOMOUS_TRANSACTION para logging independiente.";

        } else {
            motor = "? no se pudo determinar el motor";
            nombres = "? sin referencia de motor";
            params = "? sin referencia de motor";
            transacciones = hasAny(upper, "COMMIT", "ROLLBACK", "BEGIN") ? "✓ posible manejo de transacciones" : "? no detectado";
            observaciones = "No se pudo validar contra naming conventions específicas. "
                    + "Usa engineHint ('sybase', 'mssql', 'oracle', 'postgresql') para validación precisa.";
        }

        return new ValidationResult(motor, nombres, params, transacciones, observaciones);
    }

    private List<String> validateArqtEst001(String sql, String engine) {
        var result = new ArrayList<String>();
        var upper = sql.toUpperCase();
        var isSybase = "sybase".equals(engine) || "mssql".equals(engine);
        var isOracle = "oracle".equals(engine);

        if ("sybase".equals(engine) || "mssql".equals(engine)) {
            var nameMatch = Pattern.compile("CREATE\\s+(PROC|PROCEDURE)\\s+(?:\\w+\\.)?(\\w+)", Pattern.CASE_INSENSITIVE).matcher(sql);
            if (nameMatch.find()) {
                var spName = nameMatch.group(2);
                if (spName.startsWith("pa_")) {
                    result.add("✅ Nombre SP: " + spName + " cumple prefijo pa_");
                    var parts = spName.split("_");
                    if (parts.length >= 3) {
                        result.add("✅ Formato pa_{nemónico}_{tipo}_{desc}: " + spName);
                    }
                } else if (spName.startsWith("sp_")) {
                    result.add("❌ Nombre SP: " + spName + " usa prefijo sp_ — debe ser pa_");
                } else {
                    result.add("⚠ Nombre SP: " + spName + " sin prefijo pa_ ni sp_");
                }
            }

            var hasE = Pattern.compile("@e_\\w+").matcher(sql).find();
            var hasS = Pattern.compile("@s_\\w+").matcher(sql).find();
            if (hasE && hasS) {
                result.add("✅ Parámetros: usa @e_ (entrada) y @s_ (salida)");
            } else if (hasE) {
                result.add("⚠ Parámetros: tiene @e_ pero falta @s_ salida");
            } else if (hasS) {
                result.add("⚠ Parámetros: tiene @s_ pero falta @e_ entrada");
            }

            var hasV = Pattern.compile("@v_\\w+").matcher(sql).find();
            if (hasV) {
                result.add("✅ Variables: usa @v_ para variables de trabajo");
            } else {
                var hasW = Pattern.compile("@w_\\w+").matcher(sql).find();
                if (hasW) {
                    result.add("⚠ Variables: usa @w_ (COBIS legacy) — estándar pide @v_");
                } else {
                    result.add("⚠ Variables: no se detectaron @v_ ni @w_");
                }
            }
        }

        if (isOracle) {
            var oracleName = Pattern.compile("CREATE\\s+(OR\\s+REPLACE\\s+)?PROCEDURE\\s+(\\w+)", Pattern.CASE_INSENSITIVE).matcher(sql);
            if (oracleName.find()) {
                var procName = oracleName.group(2);
                if (procName.startsWith("pa_")) {
                    result.add("✅ Nombre procedimiento Oracle: " + procName + " cumple pa_");
                } else {
                    result.add("⚠ Nombre procedimiento Oracle: " + procName + " debe empezar con pa_");
                }
            }
            var hasOraE = Pattern.compile("\\be_\\w+\\b").matcher(sql).find();
            var hasOraS = Pattern.compile("\\bs_\\w+\\b").matcher(sql).find();
            if (hasOraE && hasOraS) {
                result.add("✅ Parámetros Oracle: usa e_ (entrada) y s_ (salida)");
            }
            var hasOraV = Pattern.compile("\\bv_\\w+\\b").matcher(sql).find();
            if (hasOraV) {
                result.add("✅ Variables Oracle: usa v_ para variables trabajo");
            }
        }

        var hasRef = Pattern.compile("--?<REF\\s+\\d+|/\\*<REF\\s+\\d+", Pattern.CASE_INSENSITIVE).matcher(sql).find();
        if (hasRef) {
            result.add("✅ Referencia cambios: usa marcadores REF #");
        }

        var hasHeader = Pattern.compile("Archivo:|Motor de Base:|Propósito:", Pattern.CASE_INSENSITIVE).matcher(sql).find();
        if (hasHeader) {
            result.add("✅ Cabecera: incluye etiquetas estándar (Archivo, Motor, Propósito)");
        } else {
            result.add("⚠ Cabecera: no se detectaron etiquetas de cabecera estándar");
        }

        var hasTran = Pattern.compile("BEGIN\\s+(TRAN|TRANSACTION|TRANS)", Pattern.CASE_INSENSITIVE).matcher(sql).find();
        var hasCommit = Pattern.compile("\\bCOMMIT\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find();
        var hasRollback = Pattern.compile("\\bROLLBACK\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find();
        if (hasTran && hasCommit) {
            result.add("✅ Transacciones: BEGIN TRAN + COMMIT presente");
        }
        if (hasRollback) {
            result.add("✅ Rollback: manejo de error con ROLLBACK presente");
        }

        var hasErrorCheck = Pattern.compile("@@ERROR\\b", Pattern.CASE_INSENSITIVE).matcher(sql).find();
        if (hasErrorCheck) {
            result.add("✅ Control errores: usa @@error");
        }

        return result;
    }

    private boolean hasAny(String upper, String... keywords) {
        for (var kw : keywords) {
            if (upper.contains(kw)) return true;
        }
        return false;
    }

    @SuppressWarnings("unchecked")
    private List<Document> searchByKeyword(String query) {
        var sql = "SELECT id, content, metadata::text FROM vector_store WHERE content ILIKE ? LIMIT 5";
        try {
            return jdbcTemplate.query(sql, (rs, rowNum) -> {
                var content = rs.getString("content");
                var metaJson = rs.getString("metadata");
                Map<String, Object> meta;
                try {
                    meta = objectMapper.readValue(metaJson, Map.class);
                } catch (Exception e) {
                    meta = new java.util.HashMap<>();
                    meta.put("source", "keyword_search");
                }
                return new Document(content, meta);
            }, "%" + query + "%");
        } catch (Exception e) {
            return List.of();
        }
    }
}
