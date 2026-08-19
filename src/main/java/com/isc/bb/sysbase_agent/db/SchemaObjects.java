package com.isc.bb.sysbase_agent.db;

import java.util.List;

/**
 * Tipos de retorno compartidos por todos los dialectos de catálogo.
 * Estables: forman el schema de las tools visibles por el LLM.
 */
public final class SchemaObjects {

    private SchemaObjects() {
    }

    public record SpInfo(String schema, String name, String resultType, String args, String language, String kind) {
    }

    public record TableRef(String schema, String name) {
    }

    public record ColumnDef(int ordinal, String name, String type, boolean nullable, String defaultVal) {
    }

    public record IndexDef(String name, List<String> columns, String indexType, boolean unique, String definition) {
    }

    public record ConstraintDef(String name, String type, String definition) {
    }

    public record TableInfo(String schema, String name, String ddl,
                             List<ColumnDef> columns, List<IndexDef> indexes,
                             List<ConstraintDef> constraints, List<TriggerRef> triggers) {
    }

    public record ViewRef(String schema, String name) {
    }

    public record TriggerRef(String schema, String name, String table, String timing,
                              String event, String function, boolean enabled) {
    }

    public record SequenceRef(String schema, String name, String dataType,
                               long startValue, long minValue, long maxValue, long increment) {
    }

    public record EnumRef(String schema, String name) {
    }

    public record CompositeTypeRef(String schema, String name) {
    }

    public record AttrDef(String name, String type) {
    }
}
