package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;

@AutoConfigureTestRestTemplate
class AgentToolFlowE2ETest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Test
    void toolCall_searchProcedures_runsRealPgAndReturnsFinalAnswer() {
        var headers = authHeaders();
        var body = """
                {"conversationId":"e2e-tools-1","message":"listame los procedures del schema public"}
                """;
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>(body, headers), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).contains("finalizada con éxito");
    }
}
