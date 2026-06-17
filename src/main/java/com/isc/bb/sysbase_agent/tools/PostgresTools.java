package com.isc.bb.sysbase_agent.tools;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import org.springframework.ai.tool.annotation.Tool;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

@Component
public class PostgresTools {

    private static final Pattern TABLE_REF = Pattern.compile(
            "(?:FROM|JOIN|UPDATE|INTO\\s+TABLE|INSERT\\s+INTO|DELETE\\s+FROM)\\s+([\"']?\\w+[\"']?(?:\\.\\w+)?)",
            Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);

    private final JdbcTemplate jdbc;

    public PostgresTools(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Tool(name = "search_procedures", description = "Busca stored procedures/functions por nombre (ILIKE)")
    public List<SpInfo> searchProcedures(String pattern) {
        var sql = """
                SELECT n.nspname AS schema_name, p.proname AS name,
                       pg_get_function_result(p.oid) AS result_type,
                       pg_catalog.pg_get_function_arguments(p.oid) AS args,
                       l.lanname AS language,
                       CASE p.prokind WHEN 'p' THEN 'procedure' WHEN 'f' THEN 'function' END AS kind
                FROM pg_catalog.pg_proc p
                JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
                JOIN pg_catalog.pg_language l ON l.oid = p.prolang
                WHERE p.proname ILIKE ?
                  AND n.nspname NOT IN ('pg_catalog', 'information_schema')
                  AND p.prokind IN ('p', 'f')
                ORDER BY n.nspname, p.proname
                LIMIT 20
                """;
        return jdbc.query(sql, (rs, row) -> new SpInfo(
                rs.getString("schema_name"),
                rs.getString("name"),
                rs.getString("result_type"),
                rs.getString("args"),
                rs.getString("language"),
                rs.getString("kind")), "%" + pattern + "%");
    }

    @Tool(name = "get_procedure_source", description = "Obtiene el código fuente SQL de un stored procedure o función")
    public String getProcedureSource(String schema, String name) {
        var sql = """
                SELECT pg_catalog.pg_get_functiondef(p.oid) AS source
                FROM pg_catalog.pg_proc p
                JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
                WHERE n.nspname = ? AND p.proname = ?
                """;
        var sources = jdbc.query(sql, (rs, row) -> rs.getString("source"), schema, name);
        return sources.isEmpty() ? "No se encontró el SP: " + schema + "." + name : sources.getFirst();
    }

    @Tool(name = "list_procedures", description = "Lista todos los SPs y funciones en un schema")
    public List<SpInfo> listProcedures(String schema) {
        var sql = """
                SELECT n.nspname AS schema_name, p.proname AS name,
                       pg_get_function_result(p.oid) AS result_type,
                       pg_catalog.pg_get_function_arguments(p.oid) AS args,
                       l.lanname AS language,
                       CASE p.prokind WHEN 'p' THEN 'procedure' WHEN 'f' THEN 'function' END AS kind
                FROM pg_catalog.pg_proc p
                JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
                JOIN pg_catalog.pg_language l ON l.oid = p.prolang
                WHERE n.nspname = ?
                  AND p.prokind IN ('p', 'f')
                ORDER BY p.proname
                """;
        return jdbc.query(sql, (rs, row) -> new SpInfo(
                rs.getString("schema_name"),
                rs.getString("name"),
                rs.getString("result_type"),
                rs.getString("args"),
                rs.getString("language"),
                rs.getString("kind")), schema);
    }

    @Tool(name = "get_dependencies", description = "Analiza las tablas y objetos que usa un SP o función (basado en el código fuente)")
    public List<String> getDependencies(String schema, String name) {
        var source = getProcedureSource(schema, name);
        if (source.startsWith("No se encontró")) {
            return List.of(source);
        }
        var matcher = TABLE_REF.matcher(source);
        var tables = new java.util.LinkedHashSet<String>();
        while (matcher.find()) {
            tables.add(matcher.group(1));
        }
        return new ArrayList<>(tables);
    }

    public record SpInfo(String schema, String name, String resultType, String args, String language, String kind) {
    }
}
