package com.isc.bb.sysbase_agent.security;

import java.util.Set;

import org.springframework.stereotype.Component;

@Component
public class ToolAccessGuard {

    private static final Set<String> PG_TOOLS = Set.of(
            "search_procedures", "get_procedure_source", "list_procedures",
            "list_schemas", "list_all_schemas", "list_tables", "get_table_info",
            "list_views", "get_view_definition", "get_view_columns",
            "list_triggers", "get_trigger_definition", "list_sequences",
            "list_enums", "get_enum_values", "list_composite_types",
            "get_composite_type_attrs", "get_dependencies");

    private static final Set<String> KB_TOOLS = Set.of(
            "search_knowledge_base", "analyze_sql");

    private static final Set<String> DOC_TOOLS = Set.of("index_procedure");

    /** Tools de escritura: requieren aprobación humana (HITL) en contexto HTTP. */
    public boolean isWriteTool(String toolName) {
        return DOC_TOOLS.contains(toolName);
    }

    /**
     * role == null → contexto local (CLI/Shell) = confianza total.
     * Usado como backstop en {@link AuditedToolCallback#call}; el filtrado real del
     * schema visible al LLM ocurre antes, en {@code AgentService.toolsForRole}.
     */
    public boolean canInvoke(String role, String toolName) {
        if (role == null) {
            return true;
        }
        return switch (role.toUpperCase()) {
            case "ADMIN" -> true;
            case "DOC" -> PG_TOOLS.contains(toolName) || KB_TOOLS.contains(toolName) || DOC_TOOLS.contains(toolName);
            case "READONLY" -> PG_TOOLS.contains(toolName) || KB_TOOLS.contains(toolName);
            default -> false;
        };
    }

    // TODO(futuro): matriz de permisos configurable (propiedad YAML/BD) en vez de hardcode.
}
