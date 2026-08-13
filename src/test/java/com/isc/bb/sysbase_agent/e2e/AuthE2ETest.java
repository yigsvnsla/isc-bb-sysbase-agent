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
import com.isc.bb.sysbase_agent.security.ApiKeyRepository;

@AutoConfigureTestRestTemplate
class AuthE2ETest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Autowired
    ApiKeyRepository apiKeyRepository;

    @Test
    void noAuth_returns401() {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        var body = """
                {"conversationId":"auth-1","message":"hola"}
                """;
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>(body, headers), String.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    void jwtBearer_returns200() {
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"auth-2","message":"hola"}
                        """, authHeaders()), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).contains("sysbase-agent");
    }

    @Test
    void apiKeyHeader_returns200() {
        var plain = apiKeyRepository.create("e2e-key", "READONLY", null);
        var headers = authHeaders();
        headers.set("X-API-Key", plain);
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"auth-3","message":"hola"}
                        """, headers), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    void apiKeyAsBearerToken_returns200() {
        var plain = apiKeyRepository.create("e2e-key-bearer", "READONLY", null);
        var headers = authHeaders();
        headers.setBearerAuth(plain);
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"auth-5","message":"hola"}
                        """, headers), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
    }

    @Test
    void invalidApiKey_returns401() {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("X-API-Key", "invalid-key-value");
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"auth-4","message":"hola"}
                        """, headers), String.class);
        assertThat(resp.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }
}
