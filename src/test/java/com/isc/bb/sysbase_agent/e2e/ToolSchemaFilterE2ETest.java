package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;

/**
 * F3: el schema de tools enviado al LLM debe filtrarse por rol del llamante.
 * READONLY no debe ver la tool de escritura (index_procedure); DOC sí.
 */
@AutoConfigureTestRestTemplate
class ToolSchemaFilterE2ETest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Test
    void readonlyRole_llmSchema_omitsWriteTool() {
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"e2e-f3-readonly-1","message":"listame los procedures (rol readonly)"}
                        """, authHeaders()), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();

        var reqBody = llmRequestContaining("rol readonly");
        assertThat(reqBody).contains("\"name\":\"search_procedures\"");
        assertThat(reqBody).contains("\"name\":\"search_knowledge_base\"");
        assertThat(reqBody).doesNotContain("\"name\":\"index_procedure\"");
    }

    @Test
    void docRole_llmSchema_includesWriteTool() {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(tokenService.issue("e2e-f3-doc", "DOC"));

        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"e2e-f3-doc-1","message":"listame los procedures (rol doc)"}
                        """, headers), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();

        var reqBody = llmRequestContaining("rol doc");
        assertThat(reqBody).contains("\"name\":\"search_procedures\"");
        assertThat(reqBody).contains("\"name\":\"index_procedure\"");
    }

    private String llmRequestContaining(String marker) {
        return wiremock().getAllServeEvents().stream()
                .map(e -> e.getRequest().getBodyAsString())
                .filter(body -> body.contains(marker))
                .findFirst()
                .orElseThrow(() -> new AssertionError("No hubo request al LLM con: " + marker));
    }
}
