package com.isc.bb.sysbase_agent.tools;

import java.util.List;

import org.springframework.ai.tool.annotation.Tool;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.db.DatabaseRegistry;
import com.isc.bb.sysbase_agent.db.EngineContext;
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
 * Fachada de las tools de exploración de catálogo (multi-motor, F1).
 * Cada tool resuelve el motor actual ({@link EngineContext}) y delega en el
 * dialecto correspondiente. Los nombres/descripciones/parámetros se mantienen
 * estables para no alterar el schema visible por el LLM.
 */
@Component
public class PostgresTools {

    private final DatabaseRegistry registry;

    public PostgresTools(DatabaseRegistry registry) {
        this.registry = registry;
    }

    private com.isc.bb.sysbase_agent.db.DbSession session() {
        return registry.resolve(EngineContext.current());
    }

    @Tool(name = "search_procedures", description = "Busca stored procedures/functions por nombre (ILIKE)")
    public List<SpInfo> searchProcedures(String pattern) {
        var s = session();
        return s.dialect().searchProcedures(s.jdbc(), pattern);
    }

    @Tool(name = "get_procedure_source", description = "Obtiene el código fuente SQL de un stored procedure o función")
    public String getProcedureSource(String schema, String name) {
        var s = session();
        return s.dialect().getProcedureSource(s.jdbc(), schema, name);
    }

    @Tool(name = "list_procedures", description = "Lista todos los SPs y funciones en un schema")
    public List<SpInfo> listProcedures(String schema) {
        var s = session();
        return s.dialect().listProcedures(s.jdbc(), schema);
    }

    @Tool(name = "list_schemas", description = "Lista schemas de base de datos que contienen SPs o funciones")
    public List<String> listSchemas() {
        var s = session();
        return s.dialect().listSchemas(s.jdbc());
    }

    @Tool(name = "list_all_schemas", description = "Lista todos los schemas de usuario (no del sistema)")
    public List<String> listAllSchemas() {
        var s = session();
        return s.dialect().listAllSchemas(s.jdbc());
    }

    @Tool(name = "list_tables", description = "Lista todas las tablas de usuario en un schema")
    public List<TableRef> listTables(String schema) {
        var s = session();
        return s.dialect().listTables(s.jdbc(), schema);
    }

    @Tool(name = "get_table_info", description = "Obtiene DDL, columnas, índices, constraints y triggers de una tabla")
    public TableInfo getTableInfo(String schema, String table) {
        var s = session();
        return s.dialect().getTableInfo(s.jdbc(), schema, table);
    }

    @Tool(name = "list_views", description = "Lista todas las vistas en un schema")
    public List<ViewRef> listViews(String schema) {
        var s = session();
        return s.dialect().listViews(s.jdbc(), schema);
    }

    @Tool(name = "get_view_definition", description = "Obtiene la definición SQL de una vista")
    public String getViewDefinition(String schema, String view) {
        var s = session();
        return s.dialect().getViewDefinition(s.jdbc(), schema, view);
    }

    @Tool(name = "get_view_columns", description = "Obtiene las columnas de una vista")
    public List<ColumnDef> getViewColumns(String schema, String view) {
        var s = session();
        return s.dialect().getViewColumns(s.jdbc(), schema, view);
    }

    @Tool(name = "list_triggers", description = "Lista todos los triggers en un schema")
    public List<TriggerRef> listTriggers(String schema) {
        var s = session();
        return s.dialect().listTriggers(s.jdbc(), schema);
    }

    @Tool(name = "get_trigger_definition", description = "Obtiene la definición SQL de un trigger")
    public String getTriggerDefinition(String schema, String trigger) {
        var s = session();
        return s.dialect().getTriggerDefinition(s.jdbc(), schema, trigger);
    }

    @Tool(name = "list_sequences", description = "Lista todas las secuencias en un schema")
    public List<SequenceRef> listSequences(String schema) {
        var s = session();
        return s.dialect().listSequences(s.jdbc(), schema);
    }

    @Tool(name = "list_enums", description = "Lista todos los tipos ENUM en un schema")
    public List<EnumRef> listEnums(String schema) {
        var s = session();
        return s.dialect().listEnums(s.jdbc(), schema);
    }

    @Tool(name = "get_enum_values", description = "Obtiene los valores de un tipo ENUM")
    public List<String> getEnumValues(String schema, String enumName) {
        var s = session();
        return s.dialect().getEnumValues(s.jdbc(), schema, enumName);
    }

    @Tool(name = "list_composite_types", description = "Lista tipos compuestos en un schema")
    public List<CompositeTypeRef> listCompositeTypes(String schema) {
        var s = session();
        return s.dialect().listCompositeTypes(s.jdbc(), schema);
    }

    @Tool(name = "get_composite_type_attrs", description = "Obtiene los atributos de un tipo compuesto")
    public List<AttrDef> getCompositeTypeAttrs(String schema, String typeName) {
        var s = session();
        return s.dialect().getCompositeTypeAttrs(s.jdbc(), schema, typeName);
    }

    @Tool(name = "get_dependencies", description = "Analiza las tablas y objetos que usa un SP o función (basado en el código fuente)")
    public List<String> getDependencies(String schema, String name) {
        var s = session();
        return s.dialect().getDependencies(s.jdbc(), schema, name);
    }
}
