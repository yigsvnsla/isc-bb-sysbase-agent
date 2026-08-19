package com.isc.bb.sysbase_agent.db;

import java.util.ArrayList;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.db.SchemaObjects.ColumnDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.ConstraintDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.IndexDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.SequenceRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.SpInfo;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TableInfo;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TableRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TriggerRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.ViewRef;

@Component
public class MsSqlDialect implements CatalogDialect {

    @Override
    public EngineType engine() {
        return EngineType.MSSQL;
    }

    @Override
    public List<SpInfo> searchProcedures(JdbcTemplate jdbc, String pattern) {
        var sql = """
                SELECT s.name AS schema_name, o.name AS name,
                       CASE o.type WHEN 'P' THEN 'procedure' WHEN 'PC' THEN 'procedure' ELSE 'function' END AS kind,
                       STUFF((SELECT ', ' + p.name + ' ' + TYPE_NAME(p.user_type_id)
                              FROM sys.parameters p
                              WHERE p.object_id = o.object_id AND p.parameter_id > 0
                              FOR XML PATH('')), 1, 2, '') AS args
                FROM sys.objects o
                JOIN sys.schemas s ON o.schema_id = s.schema_id
                WHERE o.type IN ('P', 'PC', 'FN', 'IF', 'TF')
                  AND o.name LIKE ?
                  AND s.name NOT IN ('sys', 'INFORMATION_SCHEMA')
                ORDER BY s.name, o.name
                OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY
                """;
        return jdbc.query(sql, (rs, row) -> new SpInfo(
                rs.getString("schema_name"), rs.getString("name"), null,
                rs.getString("args"), "T-SQL", rs.getString("kind")), "%" + pattern + "%");
    }

    @Override
    public String getProcedureSource(JdbcTemplate jdbc, String schema, String name) {
        var sql = "SELECT OBJECT_DEFINITION(OBJECT_ID(?)) AS source";
        var sources = jdbc.query(sql, (rs, row) -> rs.getString("source"), schema + "." + name);
        return (sources.isEmpty() || sources.getFirst() == null)
                ? "No se encontró el SP: " + schema + "." + name
                : sources.getFirst();
    }

    @Override
    public List<SpInfo> listProcedures(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT s.name AS schema_name, o.name AS name,
                       CASE o.type WHEN 'P' THEN 'procedure' WHEN 'PC' THEN 'procedure' ELSE 'function' END AS kind,
                       STUFF((SELECT ', ' + p.name + ' ' + TYPE_NAME(p.user_type_id)
                              FROM sys.parameters p
                              WHERE p.object_id = o.object_id AND p.parameter_id > 0
                              FOR XML PATH('')), 1, 2, '') AS args
                FROM sys.objects o
                JOIN sys.schemas s ON o.schema_id = s.schema_id
                WHERE o.type IN ('P', 'PC', 'FN', 'IF', 'TF')
                  AND s.name = ?
                ORDER BY o.name
                """;
        return jdbc.query(sql, (rs, row) -> new SpInfo(
                rs.getString("schema_name"), rs.getString("name"), null,
                rs.getString("args"), "T-SQL", rs.getString("kind")), schema);
    }

    @Override
    public List<String> listSchemas(JdbcTemplate jdbc) {
        var sql = """
                SELECT DISTINCT s.name
                FROM sys.objects o
                JOIN sys.schemas s ON o.schema_id = s.schema_id
                WHERE o.type IN ('P', 'PC', 'FN', 'IF', 'TF')
                  AND s.name NOT IN ('sys', 'INFORMATION_SCHEMA')
                ORDER BY s.name
                """;
        return jdbc.query(sql, (rs, row) -> rs.getString("name"));
    }

    @Override
    public List<String> listAllSchemas(JdbcTemplate jdbc) {
        var sql = """
                SELECT name FROM sys.schemas
                WHERE name NOT IN ('sys', 'INFORMATION_SCHEMA', 'guest')
                ORDER BY name
                """;
        return jdbc.query(sql, (rs, row) -> rs.getString("name"));
    }

    @Override
    public List<TableRef> listTables(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT s.name AS schema_name, t.name AS name
                FROM sys.tables t
                JOIN sys.schemas s ON t.schema_id = s.schema_id
                WHERE s.name = ?
                ORDER BY t.name
                """;
        return jdbc.query(sql, (rs, row) -> new TableRef(
                rs.getString("schema_name"), rs.getString("name")), schema);
    }

    @Override
    public TableInfo getTableInfo(JdbcTemplate jdbc, String schema, String table) {
        var qualified = schema + "." + table;

        var columnSql = """
                SELECT c.column_id AS ordinal, c.name AS name, TYPE_NAME(c.user_type_id) AS type,
                       c.is_nullable AS nullable, dc.definition AS default_val
                FROM sys.columns c
                LEFT JOIN sys.default_constraints dc
                       ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
                WHERE c.object_id = OBJECT_ID(?)
                ORDER BY c.column_id
                """;
        var cols = jdbc.query(columnSql, (rs, row) -> new ColumnDef(
                rs.getInt("ordinal"), rs.getString("name"), rs.getString("type"),
                rs.getBoolean("nullable"), rs.getString("default_val")), qualified);

        var indexSql = """
                SELECT i.name AS name, i.type_desc AS index_type, i.is_unique AS "unique"
                FROM sys.indexes i
                WHERE i.object_id = OBJECT_ID(?) AND i.name IS NOT NULL
                ORDER BY i.name
                """;
        var idxs = jdbc.query(indexSql, (rs, row) -> new IndexDef(
                rs.getString("name"), List.of(), rs.getString("index_type"),
                rs.getBoolean("unique"), null), qualified);

        var constraintSql = """
                SELECT kc.name AS name, 'PRIMARY KEY' AS type, NULL AS definition
                FROM sys.key_constraints kc WHERE kc.type = 'PK' AND kc.parent_object_id = OBJECT_ID(?)
                UNION ALL
                SELECT kc.name, 'UNIQUE', NULL FROM sys.key_constraints kc
                WHERE kc.type = 'UQ' AND kc.parent_object_id = OBJECT_ID(?)
                UNION ALL
                SELECT fk.name, 'FOREIGN KEY', NULL FROM sys.foreign_keys fk
                WHERE fk.parent_object_id = OBJECT_ID(?)
                UNION ALL
                SELECT cc.name, 'CHECK', cc.definition FROM sys.check_constraints cc
                WHERE cc.parent_object_id = OBJECT_ID(?)
                ORDER BY name
                """;
        var cons = jdbc.query(constraintSql, (rs, row) -> new ConstraintDef(
                rs.getString("name"), rs.getString("type"), rs.getString("definition")),
                qualified, qualified, qualified, qualified);

        var triggerSql = """
                SELECT tr.name AS name, OBJECT_DEFINITION(tr.object_id) AS definition
                FROM sys.triggers tr
                WHERE tr.parent_id = OBJECT_ID(?) AND tr.parent_class = 1
                ORDER BY tr.name
                """;
        var trigs = new ArrayList<TriggerRef>();
        for (var tr : jdbc.query(triggerSql, (rs, row) -> new String[] {
                rs.getString("name"), rs.getString("definition") }, qualified)) {
            trigs.add(parseTrigger(schema, table, tr[0], tr[1]));
        }

        var ddl = buildDdl(schema, table, cols);
        return new TableInfo(schema, table, ddl, cols, idxs, cons, trigs);
    }

    @Override
    public List<ViewRef> listViews(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT s.name AS schema_name, v.name AS name
                FROM sys.views v
                JOIN sys.schemas s ON v.schema_id = s.schema_id
                WHERE s.name = ?
                ORDER BY v.name
                """;
        return jdbc.query(sql, (rs, row) -> new ViewRef(
                rs.getString("schema_name"), rs.getString("name")), schema);
    }

    @Override
    public String getViewDefinition(JdbcTemplate jdbc, String schema, String view) {
        var sql = "SELECT OBJECT_DEFINITION(OBJECT_ID(?)) AS definition";
        var results = jdbc.query(sql, (rs, row) -> rs.getString("definition"), schema + "." + view);
        return (results.isEmpty() || results.getFirst() == null)
                ? "Vista no encontrada: " + schema + "." + view
                : results.getFirst();
    }

    @Override
    public List<ColumnDef> getViewColumns(JdbcTemplate jdbc, String schema, String view) {
        var sql = """
                SELECT c.column_id AS ordinal, c.name AS name, TYPE_NAME(c.user_type_id) AS type,
                       c.is_nullable AS nullable, NULL AS default_val
                FROM sys.columns c
                WHERE c.object_id = OBJECT_ID(?)
                ORDER BY c.column_id
                """;
        return jdbc.query(sql, (rs, row) -> new ColumnDef(
                rs.getInt("ordinal"), rs.getString("name"), rs.getString("type"),
                rs.getBoolean("nullable"), null), schema + "." + view);
    }

    @Override
    public List<TriggerRef> listTriggers(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT tr.name AS name, OBJECT_NAME(tr.parent_id) AS table_name,
                       OBJECT_DEFINITION(tr.object_id) AS definition
                FROM sys.triggers tr
                JOIN sys.schemas s ON s.schema_id = OBJECT_SCHEMA_ID(tr.parent_id)
                WHERE s.name = ? AND tr.parent_class = 1
                ORDER BY tr.name
                """;
        var trigs = new ArrayList<TriggerRef>();
        for (var row : jdbc.query(sql, (rs, i) -> new String[] {
                rs.getString("name"), rs.getString("table_name"), rs.getString("definition") }, schema)) {
            trigs.add(parseTrigger(schema, row[1], row[0], row[2]));
        }
        return trigs;
    }

    @Override
    public String getTriggerDefinition(JdbcTemplate jdbc, String schema, String trigger) {
        var sql = "SELECT OBJECT_DEFINITION(OBJECT_ID(?)) AS definition";
        var results = jdbc.query(sql, (rs, row) -> rs.getString("definition"), schema + "." + trigger);
        return (results.isEmpty() || results.getFirst() == null) ? null : results.getFirst();
    }

    @Override
    public List<SequenceRef> listSequences(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT sq.name AS name, TYPE_NAME(sq.user_type_id) AS data_type,
                       CAST(sq.start_value AS bigint) AS start_value,
                       CAST(sq.minimum_value AS bigint) AS minimum_value,
                       CAST(sq.maximum_value AS bigint) AS maximum_value,
                       CAST(sq.increment AS bigint) AS increment
                FROM sys.sequences sq
                JOIN sys.schemas s ON sq.schema_id = s.schema_id
                WHERE s.name = ?
                ORDER BY sq.name
                """;
        return jdbc.query(sql, (rs, row) -> new SequenceRef(
                schema, rs.getString("name"), rs.getString("data_type"),
                rs.getLong("start_value"), rs.getLong("minimum_value"),
                rs.getLong("maximum_value"), rs.getLong("increment")), schema);
    }

    private TriggerRef parseTrigger(String schema, String table, String name, String definition) {
        var upper = definition == null ? "" : definition.toUpperCase();
        var timing = upper.contains("INSTEAD OF") ? "INSTEAD OF" : "AFTER";
        var event = upper.contains("DELETE") ? "DELETE"
                : upper.contains("UPDATE") ? "UPDATE"
                : upper.contains("INSERT") ? "INSERT" : "UNKNOWN";
        return new TriggerRef(schema, name, table, timing, event, "", true);
    }

    private String buildDdl(String schema, String table, List<ColumnDef> cols) {
        var sb = new StringBuilder("CREATE TABLE ").append(schema).append('.').append(table).append(" (\n");
        for (int i = 0; i < cols.size(); i++) {
            var c = cols.get(i);
            sb.append("    ").append(c.name()).append(' ').append(c.type());
            if (!c.nullable()) {
                sb.append(" NOT NULL");
            }
            if (c.defaultVal() != null) {
                sb.append(" DEFAULT ").append(c.defaultVal());
            }
            sb.append(i < cols.size() - 1 ? ",\n" : "\n");
        }
        sb.append(");");
        return sb.toString();
    }
}
