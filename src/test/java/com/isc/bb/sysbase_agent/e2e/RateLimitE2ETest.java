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
import org.springframework.test.context.TestPropertySource;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;

@AutoConfigureTestRestTemplate
@TestPropertySource(properties = "app.security.rate-limit.user-per-minute=5")
class RateLimitE2ETest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Test
    void userOverLimit_gets429() {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(tokenService.issue("rl-test-user", "READONLY"));

        for (int i = 0; i < 5; i++) {
            var resp = rest.postForEntity("/v1/agent/chat",
                    new HttpEntity<>("""
                            {"conversationId":"rl-1","message":"hola"}
                            """, headers), String.class);
            assertThat(resp.getStatusCode().is2xxSuccessful())
                    .as("llamada %d debe pasar", i + 1).isTrue();
        }

        var limited = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>("""
                        {"conversationId":"rl-1","message":"hola"}
                        """, headers), String.class);
        assertThat(limited.getStatusCode()).isEqualTo(HttpStatus.TOO_MANY_REQUESTS);
        assertThat(limited.getHeaders().getFirst("Retry-After")).isEqualTo("60");
    }
}
