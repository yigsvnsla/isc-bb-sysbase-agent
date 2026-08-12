package com.isc.bb.sysbase_agent.security;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class ToolAccessGuardTest {

    private final ToolAccessGuard guard = new ToolAccessGuard();

    @Test
    void readonly_allowsPgTool() {
        assertThat(guard.canInvoke("READONLY", "search_procedures")).isTrue();
        assertThat(guard.canInvoke("READONLY", "get_table_info")).isTrue();
    }

    @Test
    void readonly_allowsKnowledgeBaseTools() {
        assertThat(guard.canInvoke("READONLY", "search_knowledge_base")).isTrue();
        assertThat(guard.canInvoke("READONLY", "analyze_sql")).isTrue();
    }

    @Test
    void readonly_deniesDocTool() {
        assertThat(guard.canInvoke("READONLY", "index_procedure")).isFalse();
    }

    @Test
    void doc_allowsDocTool() {
        assertThat(guard.canInvoke("DOC", "index_procedure")).isTrue();
        assertThat(guard.canInvoke("DOC", "search_procedures")).isTrue();
    }

    @Test
    void admin_allowsAnything() {
        assertThat(guard.canInvoke("ADMIN", "index_procedure")).isTrue();
        assertThat(guard.canInvoke("ADMIN", "any_future_tool")).isTrue();
    }

    @Test
    void nullRole_localTrust_allowAll() {
        assertThat(guard.canInvoke(null, "index_procedure")).isTrue();
        assertThat(guard.canInvoke(null, "anything")).isTrue();
    }

    @Test
    void unknownRole_denies() {
        assertThat(guard.canInvoke("GUEST", "search_procedures")).isFalse();
    }
}
