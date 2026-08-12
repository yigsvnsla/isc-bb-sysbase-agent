package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;
import com.isc.bb.sysbase_agent.audit.AuditRepository;

@AutoConfigureTestRestTemplate
class GdprE2ETest extends AbstractIntegrationTest {

    private static final String CONV = "gdpr-e2e-1";

    @Autowired
    TestRestTemplate rest;

    @Autowired
    AuditRepository audit;

    @Autowired
    ChatMemory chatMemory;

    @Test
    void deleteConversation_clearsMemoryAndAudit() {
        var chat = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"%s","message":"hola"}
                        """.formatted(CONV), authHeaders()), String.class);
        assertThat(chat.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(chatMemory.get(CONV)).isNotEmpty();

        var del = rest.exchange("/v1/agent/conversations/" + CONV,
                HttpMethod.DELETE, new HttpEntity<>(authHeaders()), Void.class);
        assertThat(del.getStatusCode()).isEqualTo(HttpStatus.NO_CONTENT);

        assertThat(chatMemory.get(CONV)).isEmpty();

        var turns = audit.search(null, null, "TURN", 500);
        assertThat(turns).noneMatch(t -> CONV.equals(t.sessionId()));
    }
}
