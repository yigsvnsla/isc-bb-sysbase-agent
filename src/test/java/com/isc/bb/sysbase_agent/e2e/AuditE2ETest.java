package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;
import com.isc.bb.sysbase_agent.audit.AuditRepository;
import com.isc.bb.sysbase_agent.security.ApiKeyRepository;

@AutoConfigureTestRestTemplate
class AuditE2ETest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Autowired
    AuditRepository audit;

    @Autowired
    ApiKeyRepository apiKeyRepository;

    @Test
    void chat_recordsTurnAndAuthSuccessEvents() {
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"audit-e2e-1","message":"hola"}
                        """, authHeaders()), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();

        var turns = audit.search(null, "e2e-tests", "TURN", 10);
        assertThat(turns).isNotEmpty();
        assertThat(turns.getFirst().promptHash()).isNotBlank();
        assertThat(turns.getFirst().promptTruncated()).isEqualTo("hola");
        assertThat(turns.getFirst().responseHash()).isNotBlank();
        assertThat(turns.getFirst().tier()).isNotBlank();

        var auths = audit.search(null, "e2e-tests", "AUTH", 10);
        assertThat(auths).anyMatch(a -> "jwt".equals(a.authMethod()) && Boolean.TRUE.equals(a.authOk()));
    }

    @Test
    void noAuth_recordsAuthFailureEvent() {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"audit-e2e-2","message":"hola"}
                        """, headers), String.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);

        var auths = audit.search(null, null, "AUTH", 50);
        assertThat(auths).anyMatch(a -> Boolean.FALSE.equals(a.authOk()));
    }

    @Test
    void apiKeyToolFlow_recordsToolAndApiKeyAuthEvents() {
        var plain = apiKeyRepository.create("audit-key", "READONLY", null);
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("X-API-Key", plain);
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"audit-e2e-3","message":"listame los procedures del schema public"}
                        """, headers), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful())
                .as("status=%s body=%s", resp.getStatusCode(), resp.getBody())
                .isTrue();

        var tools = audit.search("search_procedures", "audit-key", "TOOL", 10);
        assertThat(tools).isNotEmpty();
        assertThat(tools).anyMatch(t -> Boolean.TRUE.equals(t.toolOk()));
        assertThat(tools.getFirst().toolArgs()).contains("pattern");

        var auths = audit.search(null, "audit-key", "AUTH", 10);
        assertThat(auths).anyMatch(a -> "api-key".equals(a.authMethod()) && Boolean.TRUE.equals(a.authOk()));
    }
}
