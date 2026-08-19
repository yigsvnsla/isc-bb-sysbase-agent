package com.isc.bb.sysbase_agent.db;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.db.SchemaObjects.AttrDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.ColumnDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.CompositeTypeRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.ConstraintDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.EnumRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.IndexDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.SequenceRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.SpInfo;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TableInfo;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TableRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TriggerRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.ViewRef;

@Component
public class PostgresDialect implements CatalogDialect {

    @Override
    public EngineType engine() {
        return EngineType.POSTGRES;
    }

    @Override
    public List<SpInfo> searchProcedures(JdbcTemplate jdbc, String pattern) {
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
                rs.getString("schema_name"), rs.getString("name"), rs.getString("result_type"),
                rs.getString("args"), rs.getString("language"), rs.getString("kind")),
                "%" + pattern + "%");
    }

    @Override
    public String getProcedureSource(JdbcTemplate jdbc, String schema, String name) {
        var sql = """
                SELECT pg_catalog.pg_get_functiondef(p.oid) AS source
                FROM pg_catalog.pg_proc p
                JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
                WHERE n.nspname = ? AND p.proname = ?
                """;
        var sources = jdbc.query(sql, (rs, row) -> rs.getString("source"), schema, name);
        return sources.isEmpty() ? "No se encontró el SP: " + schema + "." + name : sources.getFirst();
    }

    @Override
    public List<SpInfo> listProcedures(JdbcTemplate jdbc, String schema) {
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
                rs.getString("schema_name"), rs.getString("name"), rs.getString("result_type"),
                rs.getString("args"), rs.getString("language"), rs.getString("kind")), schema);
    }

    @Override
    public List<String> listSchemas(JdbcTemplate jdbc) {
        var sql = """
                SELECT DISTINCT n.nspname
                FROM pg_catalog.pg_proc p
                JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
                WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
                  AND p.prokind IN ('p', 'f')
                ORDER BY n.nspname
                """;
        return jdbc.query(sql, (rs, row) -> rs.getString("nspname"));
    }

    @Override
    public List<String> listAllSchemas(JdbcTemplate jdbc) {
        var sql = """
                SELECT DISTINCT n.nspname
                FROM pg_catalog.pg_namespace n
                WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
                  AND n.nspname NOT LIKE 'pg_%'
                  AND n.nspname NOT LIKE 'pg_toast%'
                ORDER BY n.nspname
                """;
        return jdbc.query(sql, (rs, row) -> rs.getString("nspname"));
    }

    @Override
    public List<TableRef> listTables(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT schemaname AS schema_name, tablename AS name
                FROM pg_catalog.pg_tables
                WHERE schemaname = ?
                ORDER BY tablename
                """;
        return jdbc.query(sql, (rs, row) -> new TableRef(
                rs.getString("schema_name"), rs.getString("name")), schema);
    }

    @Override
    public TableInfo getTableInfo(JdbcTemplate jdbc, String schema, String table) {
        var columnSql = """
                SELECT a.attnum AS ordinal, a.attname AS name,
                       pg_catalog.format_type(a.atttypid, a.atttypmod) AS type,
                       NOT a.attnotnull AS nullable,
                       pg_catalog.pg_get_expr(d.adbin, d.adrelid) AS default_val
                FROM pg_catalog.pg_attribute a
                LEFT JOIN pg_catalog.pg_attrdef d ON d.adrelid = a.attrelid AND d.adnum = a.attnum
                WHERE a.attrelid = ?::regclass
                  AND a.attnum > 0 AND NOT a.attisdropped
                ORDER BY a.attnum
                """;

        var indexSql = """
                SELECT i.relname AS name,
                       array_agg(a.attname ORDER BY k.i) AS columns,
                       am.amname AS index_type,
                       ix.indisunique AS "unique",
                       pg_catalog.pg_get_indexdef(i.oid) AS definition
                FROM pg_catalog.pg_index ix
                JOIN pg_catalog.pg_class i ON i.oid = ix.indexrelid
                JOIN pg_catalog.pg_am am ON am.oid = i.relam
                LEFT JOIN unnest(ix.indkey) WITH ORDINALITY AS k(attnum, i) ON true
                LEFT JOIN pg_catalog.pg_attribute a ON a.attrelid = ix.indrelid AND a.attnum = k.attnum
                WHERE ix.indrelid = ?::regclass
                GROUP BY i.relname, am.amname, ix.indisunique, i.oid
                ORDER BY i.relname
                """;

        var constraintSql = """
                SELECT con.conname AS name,
                       CASE con.contype
                           WHEN 'p' THEN 'PRIMARY KEY'
                           WHEN 'f' THEN 'FOREIGN KEY'
                           WHEN 'u' THEN 'UNIQUE'
                           WHEN 'c' THEN 'CHECK'
                           ELSE con.contype::text
                       END AS type,
                       pg_catalog.pg_get_constraintdef(con.oid) AS definition
                FROM pg_catalog.pg_constraint con
                WHERE con.conrelid = ?::regclass
                ORDER BY con.conname
                """;

        var triggerSql = """
                SELECT tgname AS name,
                       pg_catalog.pg_get_triggerdef(oid) AS definition
                FROM pg_catalog.pg_trigger
                WHERE tgrelid = ?::regclass AND NOT tgisinternal
                ORDER BY tgname
                """;

        var ddlSql = """
                SELECT 'CREATE TABLE ' || ? || '.' || ? || ' (' || E'\\n' ||
                       string_agg('    ' || a.attname || ' ' ||
                       pg_catalog.format_type(a.atttypid, a.atttypmod) ||
                       CASE WHEN a.attnotnull THEN ' NOT NULL' ELSE '' END ||
                       CASE WHEN d.adbin IS NOT NULL THEN ' DEFAULT ' ||
                       pg_catalog.pg_get_expr(d.adbin, d.adrelid) ELSE '' END,
                       ',' || E'\\n' ORDER BY a.attnum) || E'\\n);' AS ddl
                FROM pg_catalog.pg_attribute a
                LEFT JOIN pg_catalog.pg_attrdef d ON d.adrelid = a.attrelid AND d.adnum = a.attnum
                WHERE a.attrelid = ?::regclass AND a.attnum > 0 AND NOT a.attisdropped
                """;

        var qualified = schema + "." + table;
        var cols = jdbc.query(columnSql, (rs, row) -> new ColumnDef(
                rs.getInt("ordinal"), rs.getString("name"), rs.getString("type"),
                rs.getBoolean("nullable"), rs.getString("default_val")), qualified);
        var idxs = jdbc.query(indexSql, (rs, row) -> new IndexDef(
                rs.getString("name"),
                rs.getArray("columns") != null
                        ? List.of((String[]) rs.getArray("columns").getArray())
                        : List.of(),
                rs.getString("index_type"), rs.getBoolean("unique"),
                rs.getString("definition")), qualified);
        var cons = jdbc.query(constraintSql, (rs, row) -> new ConstraintDef(
                rs.getString("name"), rs.getString("type"),
                rs.getString("definition")), qualified);
        var trigs = jdbc.query(triggerSql, (rs, row) -> new TriggerRef(
                schema, rs.getString("name"), table,
                "manual", "manual", "manual", true), qualified);
        var ddlRow = jdbc.query(ddlSql, (rs, row) -> rs.getString("ddl"), schema, table, qualified);
        var ddl = ddlRow.isEmpty() ? "" : ddlRow.getFirst();

        return new TableInfo(schema, table, ddl, cols, idxs, cons, List.of());
    }

    @Override
    public List<ViewRef> listViews(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT schemaname AS schema_name, viewname AS name
                FROM pg_catalog.pg_views
                WHERE schemaname = ?
                ORDER BY viewname
                """;
        return jdbc.query(sql, (rs, row) -> new ViewRef(
                rs.getString("schema_name"), rs.getString("name")), schema);
    }

    @Override
    public String getViewDefinition(JdbcTemplate jdbc, String schema, String view) {
        var sql = """
                SELECT pg_catalog.pg_get_viewdef(?::regclass, true) AS definition
                """;
        var results = jdbc.query(sql, (rs, row) -> rs.getString("definition"), schema + "." + view);
        return results.isEmpty() ? "Vista no encontrada: " + schema + "." + view : results.getFirst();
    }

    @Override
    public List<ColumnDef> getViewColumns(JdbcTemplate jdbc, String schema, String view) {
        var sql = """
                SELECT a.attnum AS ordinal, a.attname AS name,
                       pg_catalog.format_type(a.atttypid, a.atttypmod) AS type,
                       NOT a.attnotnull AS nullable,
                       null AS default_val
                FROM pg_catalog.pg_attribute a
                WHERE a.attrelid = ?::regclass
                  AND a.attnum > 0 AND NOT a.attisdropped
                ORDER BY a.attnum
                """;
        return jdbc.query(sql, (rs, row) -> new ColumnDef(
                rs.getInt("ordinal"), rs.getString("name"), rs.getString("type"),
                rs.getBoolean("nullable"), null), schema + "." + view);
    }

    @Override
    public List<TriggerRef> listTriggers(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT tgname AS name,
                       relname AS table_name,
                       CASE WHEN tgfoid != 0 THEN proname ELSE '' END AS function_name,
                       pg_catalog.pg_get_triggerdef(t.oid, true) AS definition
                FROM pg_catalog.pg_trigger t
                JOIN pg_catalog.pg_class c ON c.oid = t.tgrelid
                JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
                LEFT JOIN pg_catalog.pg_proc p ON p.oid = t.tgfoid
                WHERE n.nspname = ? AND NOT t.tgisinternal
                ORDER BY tgname
                """;
        return jdbc.query(sql, (rs, row) -> {
            var def = rs.getString("definition");
            var timing = def != null && def.toUpperCase().contains("BEFORE") ? "BEFORE" : "AFTER";
            var event = def != null && def.toUpperCase().contains("DELETE") ? "DELETE"
                    : def != null && def.toUpperCase().contains("UPDATE") ? "UPDATE"
                    : def != null && def.toUpperCase().contains("INSERT") ? "INSERT" : "UNKNOWN";
            return new TriggerRef(schema, rs.getString("name"),
                    rs.getString("table_name"), timing, event,
                    rs.getString("function_name"), true);
        }, schema);
    }

    @Override
    public String getTriggerDefinition(JdbcTemplate jdbc, String schema, String trigger) {
        var sql = """
                SELECT pg_catalog.pg_get_triggerdef(t.oid, true) AS definition
                FROM pg_catalog.pg_trigger t
                JOIN pg_catalog.pg_class c ON c.oid = t.tgrelid
                JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
                WHERE n.nspname = ? AND t.tgname = ?
                """;
        var results = jdbc.query(sql, (rs, row) -> rs.getString("definition"), schema, trigger);
        return results.isEmpty() ? null : results.getFirst();
    }

    @Override
    public List<SequenceRef> listSequences(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT sequence_name AS name,
                       data_type, start_value, minimum_value, maximum_value, increment
                FROM information_schema.sequences
                WHERE sequence_schema = ?
                ORDER BY sequence_name
                """;
        return jdbc.query(sql, (rs, row) -> new SequenceRef(
                schema, rs.getString("name"), rs.getString("data_type"),
                rs.getLong("start_value"), rs.getLong("minimum_value"),
                rs.getLong("maximum_value"), rs.getLong("increment")), schema);
    }

    @Override
    public List<EnumRef> listEnums(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT t.typname AS name
                FROM pg_catalog.pg_type t
                JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
                WHERE n.nspname = ? AND t.typtype = 'e'
                ORDER BY t.typname
                """;
        return jdbc.query(sql, (rs, row) -> new EnumRef(schema, rs.getString("name")), schema);
    }

    @Override
    public List<String> getEnumValues(JdbcTemplate jdbc, String schema, String enumName) {
        var sql = """
                SELECT e.enumlabel
                FROM pg_catalog.pg_enum e
                JOIN pg_catalog.pg_type t ON t.oid = e.enumtypid
                JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
                WHERE n.nspname = ? AND t.typname = ?
                ORDER BY e.enumsortorder
                """;
        return jdbc.query(sql, (rs, row) -> rs.getString("enumlabel"), schema, enumName);
    }

    @Override
    public List<CompositeTypeRef> listCompositeTypes(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT t.typname AS name
                FROM pg_catalog.pg_type t
                JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
                WHERE n.nspname = ? AND t.typtype = 'c'
                  AND NOT EXISTS (
                      SELECT 1 FROM pg_catalog.pg_class c
                      WHERE c.relnamespace = n.oid
                        AND c.relname = t.typname
                        AND c.relkind = 'r'
                  )
                ORDER BY t.typname
                """;
        return jdbc.query(sql, (rs, row) -> new CompositeTypeRef(schema, rs.getString("name")), schema);
    }

    @Override
    public List<AttrDef> getCompositeTypeAttrs(JdbcTemplate jdbc, String schema, String typeName) {
        var sql = """
                SELECT a.attname AS name,
                       pg_catalog.format_type(a.atttypid, a.atttypmod) AS type
                FROM pg_catalog.pg_attribute a
                JOIN pg_catalog.pg_type t ON t.oid = a.attrelid
                JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
                WHERE n.nspname = ? AND t.typname = ?
                  AND a.attnum > 0 AND NOT a.attisdropped
                ORDER BY a.attnum
                """;
        return jdbc.query(sql, (rs, row) -> new AttrDef(
                rs.getString("name"), rs.getString("type")), schema, typeName);
    }
}
