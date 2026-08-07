package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;

@AutoConfigureTestRestTemplate
class AgentApiContractTest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Test
    void modelsEndpoint_returnsSysbaseAgentModel() {
        var resp = rest.getForEntity("/models", String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).contains("sysbase-agent");
    }

    @Test
    void v2Chat_validPayload_returnsOk() {
        var headers = authHeaders();
        var body = """
                {"conversationId":"e2e-contract-1","message":"hola"}
                """;
        var resp = rest.postForEntity("/v2/agent/chat",
                new HttpEntity<>(body, headers), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    void v1Chat_malformedJson_returns400() {
        var headers = authHeaders();
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("not-json", headers), String.class);
        assertThat(resp.getStatusCode().is4xxClientError()).isTrue();
    }

    @Test
    void modelsEndpoint_corsAllowed() {
        var headers = authHeaders();
        headers.setOrigin("http://localhost:3000");
        var resp = rest.exchange("/models", HttpMethod.GET,
                new HttpEntity<>(headers), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getHeaders().getAccessControlAllowOrigin()).isNotNull();
    }
}
