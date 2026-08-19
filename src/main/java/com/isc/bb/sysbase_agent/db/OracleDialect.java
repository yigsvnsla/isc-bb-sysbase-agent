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
public class OracleDialect implements CatalogDialect {

    private static final String SYSTEM_USERS =
            "('SYS','SYSTEM','MDSYS','XDB','CTXSYS','ORDSYS','ORDDATA','OLAPSYS','WMSYS','EXFSYS',"
            + "'DBSNMP','OUTLN','APPQOSSYS','SYSMAN','ANONYMOUS','GSMADMIN_INTERNAL','XS$NULL',"
            + "'OJVMSYS','DVF','DVSYS','LBACSYS','AUDSYS','GSMCATUSER','MDDATA','SYSBACKUP',"
            + "'SYSDG','SYSKM','SYSRAC','REMOTE_SCHEDULER_AGENT','SYS$UMF')";

    @Override
    public EngineType engine() {
        return EngineType.ORACLE;
    }

    @Override
    public List<SpInfo> searchProcedures(JdbcTemplate jdbc, String pattern) {
        var sql = """
                SELECT o.owner AS schema_name, o.object_name AS name,
                       CASE o.object_type WHEN 'PROCEDURE' THEN 'procedure' ELSE 'function' END AS kind
                FROM ALL_OBJECTS o
                WHERE o.object_type IN ('PROCEDURE', 'FUNCTION')
                  AND o.object_name LIKE '%' || UPPER(?) || '%'
                  AND o.owner NOT IN %s
                ORDER BY o.owner, o.object_name
                FETCH FIRST 20 ROWS ONLY
                """.formatted(SYSTEM_USERS);
        return jdbc.query(sql, (rs, row) -> new SpInfo(
                rs.getString("schema_name"), rs.getString("name"), null,
                null, "PL/SQL", rs.getString("kind")), pattern);
    }

    @Override
    public String getProcedureSource(JdbcTemplate jdbc, String schema, String name) {
        var sql = """
                SELECT text FROM ALL_SOURCE
                WHERE owner = UPPER(?) AND name = UPPER(?)
                  AND type IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY')
                ORDER BY type, line
                """;
        var lines = jdbc.query(sql, (rs, row) -> rs.getString("text"), schema, name);
        if (lines.isEmpty()) {
            return "No se encontró el SP: " + schema + "." + name;
        }
        return String.join("", lines);
    }

    @Override
    public List<SpInfo> listProcedures(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT o.owner AS schema_name, o.object_name AS name,
                       CASE o.object_type WHEN 'PROCEDURE' THEN 'procedure' ELSE 'function' END AS kind
                FROM ALL_OBJECTS o
                WHERE o.object_type IN ('PROCEDURE', 'FUNCTION')
                  AND o.owner = UPPER(?)
                ORDER BY o.object_name
                """;
        return jdbc.query(sql, (rs, row) -> new SpInfo(
                rs.getString("schema_name"), rs.getString("name"), null,
                null, "PL/SQL", rs.getString("kind")), schema);
    }

    @Override
    public List<String> listSchemas(JdbcTemplate jdbc) {
        var sql = """
                SELECT DISTINCT owner
                FROM ALL_OBJECTS
                WHERE object_type IN ('PROCEDURE', 'FUNCTION')
                  AND owner NOT IN %s
                ORDER BY owner
                """.formatted(SYSTEM_USERS);
        return jdbc.query(sql, (rs, row) -> rs.getString("owner"));
    }

    @Override
    public List<String> listAllSchemas(JdbcTemplate jdbc) {
        var sql = """
                SELECT username FROM ALL_USERS
                WHERE username NOT IN %s
                ORDER BY username
                """.formatted(SYSTEM_USERS);
        return jdbc.query(sql, (rs, row) -> rs.getString("username"));
    }

    @Override
    public List<TableRef> listTables(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT owner AS schema_name, table_name AS name
                FROM ALL_TABLES
                WHERE owner = UPPER(?)
                ORDER BY table_name
                """;
        return jdbc.query(sql, (rs, row) -> new TableRef(
                rs.getString("schema_name"), rs.getString("name")), schema);
    }

    @Override
    public TableInfo getTableInfo(JdbcTemplate jdbc, String schema, String table) {
        var columnSql = """
                SELECT column_id AS ordinal, column_name AS name, data_type AS type,
                       nullable AS nullable, data_default AS default_val
                FROM ALL_TAB_COLUMNS
                WHERE owner = UPPER(?) AND table_name = UPPER(?)
                ORDER BY column_id
                """;
        var cols = jdbc.query(columnSql, (rs, row) -> new ColumnDef(
                rs.getInt("ordinal"), rs.getString("name"), rs.getString("type"),
                "Y".equals(rs.getString("nullable")), rs.getString("default_val")), schema, table);

        var indexSql = """
                SELECT index_name AS name, index_type AS index_type, uniqueness AS "unique"
                FROM ALL_INDEXES
                WHERE table_owner = UPPER(?) AND table_name = UPPER(?)
                ORDER BY index_name
                """;
        var idxs = jdbc.query(indexSql, (rs, row) -> new IndexDef(
                rs.getString("name"), List.of(), rs.getString("index_type"),
                "UNIQUE".equals(rs.getString("unique")), null), schema, table);

        var constraintSql = """
                SELECT constraint_name AS name, constraint_type AS type
                FROM ALL_CONSTRAINTS
                WHERE owner = UPPER(?) AND table_name = UPPER(?)
                ORDER BY constraint_name
                """;
        var cons = jdbc.query(constraintSql, (rs, row) -> new ConstraintDef(
                rs.getString("name"), decodeType(rs.getString("type")), null), schema, table);

        var triggerSql = """
                SELECT trigger_name AS name, trigger_type AS type, triggering_event AS event
                FROM ALL_TRIGGERS
                WHERE table_owner = UPPER(?) AND table_name = UPPER(?)
                ORDER BY trigger_name
                """;
        var trigs = jdbc.query(triggerSql, (rs, row) -> new TriggerRef(
                schema, rs.getString("name"), table,
                "BEFORE".equalsIgnoreCase(rs.getString("type")) ? "BEFORE" : "AFTER",
                rs.getString("event"), "", true), schema, table);

        var ddl = fetchDdl(jdbc, schema, table);
        return new TableInfo(schema, table, ddl, cols, idxs, cons, trigs);
    }

    @Override
    public List<ViewRef> listViews(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT owner AS schema_name, view_name AS name
                FROM ALL_VIEWS
                WHERE owner = UPPER(?)
                ORDER BY view_name
                """;
        return jdbc.query(sql, (rs, row) -> new ViewRef(
                rs.getString("schema_name"), rs.getString("name")), schema);
    }

    @Override
    public String getViewDefinition(JdbcTemplate jdbc, String schema, String view) {
        var sql = "SELECT text FROM ALL_VIEWS WHERE owner = UPPER(?) AND view_name = UPPER(?)";
        var results = jdbc.query(sql, (rs, row) -> rs.getString("text"), schema, view);
        return results.isEmpty() || results.getFirst() == null
                ? "Vista no encontrada: " + schema + "." + view
                : results.getFirst();
    }

    @Override
    public List<ColumnDef> getViewColumns(JdbcTemplate jdbc, String schema, String view) {
        var sql = """
                SELECT column_id AS ordinal, column_name AS name, data_type AS type,
                       nullable AS nullable, NULL AS default_val
                FROM ALL_TAB_COLUMNS
                WHERE owner = UPPER(?) AND table_name = UPPER(?)
                ORDER BY column_id
                """;
        return jdbc.query(sql, (rs, row) -> new ColumnDef(
                rs.getInt("ordinal"), rs.getString("name"), rs.getString("type"),
                "Y".equals(rs.getString("nullable")), null), schema, view);
    }

    @Override
    public List<TriggerRef> listTriggers(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT trigger_name AS name, table_name AS table_name,
                       trigger_type AS type, triggering_event AS event
                FROM ALL_TRIGGERS
                WHERE owner = UPPER(?)
                ORDER BY trigger_name
                """;
        return jdbc.query(sql, (rs, row) -> new TriggerRef(
                schema, rs.getString("name"), rs.getString("table_name"),
                "BEFORE".equalsIgnoreCase(rs.getString("type")) ? "BEFORE" : "AFTER",
                rs.getString("event"), "", true), schema);
    }

    @Override
    public String getTriggerDefinition(JdbcTemplate jdbc, String schema, String trigger) {
        var sql = """
                SELECT DBMS_METADATA.GET_DDL('TRIGGER', trigger_name, owner) AS definition
                FROM ALL_TRIGGERS WHERE owner = UPPER(?) AND trigger_name = UPPER(?)
                """;
        var results = jdbc.query(sql, (rs, row) -> rs.getString("definition"), schema, trigger);
        return results.isEmpty() ? null : results.getFirst();
    }

    @Override
    public List<SequenceRef> listSequences(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT sequence_name AS name, min_value, max_value, increment_by
                FROM ALL_SEQUENCES
                WHERE sequence_owner = UPPER(?)
                ORDER BY sequence_name
                """;
        return jdbc.query(sql, (rs, row) -> new SequenceRef(
                schema, rs.getString("name"), "NUMBER",
                rs.getLong("min_value"), rs.getLong("min_value"),
                rs.getLong("max_value"), rs.getLong("increment_by")), schema);
    }

    private String fetchDdl(JdbcTemplate jdbc, String schema, String table) {
        try {
            var sql = "SELECT DBMS_METADATA.GET_DDL('TABLE', UPPER(?), UPPER(?)) AS ddl FROM dual";
            var rows = jdbc.query(sql, (rs, row) -> rs.getString("ddl"), table, schema);
            return rows.isEmpty() || rows.getFirst() == null ? "" : rows.getFirst();
        } catch (Exception e) {
            return "DDL no disponible: " + e.getMessage();
        }
    }

    private String decodeType(String ct) {
        if (ct == null) {
            return "CONSTRAINT";
        }
        return switch (ct) {
            case "P" -> "PRIMARY KEY";
            case "R" -> "FOREIGN KEY";
            case "U" -> "UNIQUE";
            case "C" -> "CHECK";
            default -> ct;
        };
    }
}
