package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;
import com.isc.bb.sysbase_agent.audit.AuditRepository;

/**
 * El LLM (simulado por WireMock) encadena list_schemas en bucle infinito;
 * el ToolCallLoopLimitAdvisor debe cortar el turno tras max-tool-calls-per-turn.
 */
@AutoConfigureTestRestTemplate
class LoopLimitE2ETest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Autowired
    AuditRepository audit;

    @Test
    void runawayToolLoop_isCutByTurnLimit() {
        var headers = authHeaders();
        // Subject único para no mezclar eventos TOOL de otras clases (PG compartido).
        headers.setBearerAuth(tokenService.issue("e2e-loop", "READONLY"));
        var body = """
                {"conversationId":"e2e-loop-1","message":"ejecuta un bucle de herramientas"}
                """;
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>(body, headers), String.class);

        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).contains("iteraciones");

        var toolCalls = audit.search(null, "e2e-loop", "TOOL", 50);
        assertThat(toolCalls).size().isLessThanOrEqualTo(5);
    }
}
