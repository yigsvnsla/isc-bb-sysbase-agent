package com.isc.bb.sysbase_agent.db;

import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.db.SchemaObjects.SpInfo;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TableInfo;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TableRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.ViewRef;

/**
 * Sybase ASE (core): solo exploración esencial — procedimientos, esquemas,
 * tablas y vistas. El resto de operaciones de catálogo no está soportado.
 */
@Component
public class SybaseDialect implements CatalogDialect {

    @Override
    public EngineType engine() {
        return EngineType.SYBASE;
    }

    @Override
    public List<SpInfo> searchProcedures(JdbcTemplate jdbc, String pattern) {
        var sql = """
                SELECT u.name AS schema_name, o.name AS name,
                       CASE o.type WHEN 'P' THEN 'procedure' ELSE 'function' END AS kind
                FROM sysobjects o, sysusers u
                WHERE o.uid = u.uid AND o.type IN ('P', 'FN', 'IF', 'TF')
                  AND o.name LIKE ?
                ORDER BY u.name, o.name
                """;
        return jdbc.query(sql, (rs, row) -> new SpInfo(
                rs.getString("schema_name"), rs.getString("name"), null,
                null, "T-SQL", rs.getString("kind")), "%" + pattern + "%");
    }

    @Override
    public String getProcedureSource(JdbcTemplate jdbc, String schema, String name) {
        var sql = """
                SELECT text FROM syscomments
                WHERE id = OBJECT_ID(?)
                ORDER BY colid, textcol
                """;
        var lines = jdbc.query(sql, (rs, row) -> rs.getString("text"), schema + "." + name);
        if (lines.isEmpty()) {
            return "No se encontró el SP: " + schema + "." + name;
        }
        return String.join("", lines);
    }

    @Override
    public List<SpInfo> listProcedures(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT u.name AS schema_name, o.name AS name,
                       CASE o.type WHEN 'P' THEN 'procedure' ELSE 'function' END AS kind
                FROM sysobjects o, sysusers u
                WHERE o.uid = u.uid AND o.type IN ('P', 'FN', 'IF', 'TF')
                  AND u.name = ?
                ORDER BY o.name
                """;
        return jdbc.query(sql, (rs, row) -> new SpInfo(
                rs.getString("schema_name"), rs.getString("name"), null,
                null, "T-SQL", rs.getString("kind")), schema);
    }

    @Override
    public List<String> listSchemas(JdbcTemplate jdbc) {
        var sql = """
                SELECT DISTINCT u.name
                FROM sysobjects o, sysusers u
                WHERE o.uid = u.uid AND o.type IN ('P', 'FN', 'IF', 'TF')
                ORDER BY u.name
                """;
        return jdbc.query(sql, (rs, row) -> rs.getString("name"));
    }

    @Override
    public List<String> listAllSchemas(JdbcTemplate jdbc) {
        var sql = "SELECT name FROM sysusers WHERE suid > 1 ORDER BY name";
        return jdbc.query(sql, (rs, row) -> rs.getString("name"));
    }

    @Override
    public List<TableRef> listTables(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT u.name AS schema_name, o.name AS name
                FROM sysobjects o, sysusers u
                WHERE o.uid = u.uid AND o.type = 'U' AND u.name = ?
                ORDER BY o.name
                """;
        return jdbc.query(sql, (rs, row) -> new TableRef(
                rs.getString("schema_name"), rs.getString("name")), schema);
    }

    @Override
    public TableInfo getTableInfo(JdbcTemplate jdbc, String schema, String table) {
        return new TableInfo(schema, table,
                "get_table_info no soportado en Sybase ASE (alcance core). "
                        + "Usa list_tables y get_procedure_source.",
                List.of(), List.of(), List.of(), List.of());
    }

    @Override
    public List<ViewRef> listViews(JdbcTemplate jdbc, String schema) {
        var sql = """
                SELECT u.name AS schema_name, o.name AS name
                FROM sysobjects o, sysusers u
                WHERE o.uid = u.uid AND o.type = 'V' AND u.name = ?
                ORDER BY o.name
                """;
        return jdbc.query(sql, (rs, row) -> new ViewRef(
                rs.getString("schema_name"), rs.getString("name")), schema);
    }

    @Override
    public String getViewDefinition(JdbcTemplate jdbc, String schema, String view) {
        var sql = """
                SELECT text FROM syscomments
                WHERE id = OBJECT_ID(?)
                ORDER BY colid, textcol
                """;
        var lines = jdbc.query(sql, (rs, row) -> rs.getString("text"), schema + "." + view);
        return lines.isEmpty() ? "Vista no encontrada: " + schema + "." + view : String.join("", lines);
    }

    @Override
    public List<SchemaObjects.ColumnDef> getViewColumns(JdbcTemplate jdbc, String schema, String view) {
        return List.of();
    }

    @Override
    public List<SchemaObjects.TriggerRef> listTriggers(JdbcTemplate jdbc, String schema) {
        return List.of();
    }

    @Override
    public String getTriggerDefinition(JdbcTemplate jdbc, String schema, String trigger) {
        return null;
    }

    @Override
    public List<SchemaObjects.SequenceRef> listSequences(JdbcTemplate jdbc, String schema) {
        return List.of();
    }
}
