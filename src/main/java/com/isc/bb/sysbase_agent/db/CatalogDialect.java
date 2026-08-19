package com.isc.bb.sysbase_agent.db;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.regex.Pattern;

import org.springframework.jdbc.core.JdbcTemplate;

import com.isc.bb.sysbase_agent.db.SchemaObjects.AttrDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.ColumnDef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.CompositeTypeRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.EnumRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.SequenceRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.SpInfo;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TableInfo;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TableRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.TriggerRef;
import com.isc.bb.sysbase_agent.db.SchemaObjects.ViewRef;

/**
 * Abstracción de consultas de catálogo por motor de BD.
 * Los dialectos son stateless: reciben el {@link JdbcTemplate} del motor resuelto.
 */
public interface CatalogDialect {

    Pattern TABLE_REF = Pattern.compile(
            "(?:FROM|JOIN|UPDATE|INTO\\s+TABLE|INSERT\\s+INTO|DELETE\\s+FROM)\\s+([\"']?\\w+[\"']?(?:\\.\\w+)?)",
            Pattern.CASE_INSENSITIVE | Pattern.MULTILINE);

    EngineType engine();

    List<SpInfo> searchProcedures(JdbcTemplate jdbc, String pattern);

    String getProcedureSource(JdbcTemplate jdbc, String schema, String name);

    List<SpInfo> listProcedures(JdbcTemplate jdbc, String schema);

    List<String> listSchemas(JdbcTemplate jdbc);

    List<String> listAllSchemas(JdbcTemplate jdbc);

    List<TableRef> listTables(JdbcTemplate jdbc, String schema);

    TableInfo getTableInfo(JdbcTemplate jdbc, String schema, String table);

    List<ViewRef> listViews(JdbcTemplate jdbc, String schema);

    String getViewDefinition(JdbcTemplate jdbc, String schema, String view);

    List<ColumnDef> getViewColumns(JdbcTemplate jdbc, String schema, String view);

    List<TriggerRef> listTriggers(JdbcTemplate jdbc, String schema);

    String getTriggerDefinition(JdbcTemplate jdbc, String schema, String trigger);

    List<SequenceRef> listSequences(JdbcTemplate jdbc, String schema);

    /** PG-specific: vacío en motores sin ENUMs. */
    default List<EnumRef> listEnums(JdbcTemplate jdbc, String schema) {
        return List.of();
    }

    /** PG-specific: vacío en motores sin ENUMs. */
    default List<String> getEnumValues(JdbcTemplate jdbc, String schema, String enumName) {
        return List.of();
    }

    /** PG-specific: vacío en motores sin tipos compuestos. */
    default List<CompositeTypeRef> listCompositeTypes(JdbcTemplate jdbc, String schema) {
        return List.of();
    }

    /** PG-specific: vacío en motores sin tipos compuestos. */
    default List<AttrDef> getCompositeTypeAttrs(JdbcTemplate jdbc, String schema, String typeName) {
        return List.of();
    }

    /** Motor-agnóstico: regex sobre el código fuente. */
    default List<String> getDependencies(JdbcTemplate jdbc, String schema, String name) {
        var source = getProcedureSource(jdbc, schema, name);
        if (source == null || source.startsWith("No se encontró")) {
            return List.of(source == null ? "No se encontró el SP: " + schema + "." + name : source);
        }
        var matcher = TABLE_REF.matcher(source);
        var tables = new LinkedHashSet<String>();
        while (matcher.find()) {
            tables.add(matcher.group(1));
        }
        return new ArrayList<>(tables);
    }
}
