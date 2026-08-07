package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;

@AutoConfigureTestRestTemplate
class AgentChatE2ETest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Test
    void v1Chat_greeting_returnsAssistantContent() {
        var headers = authHeaders();
        var body = """
                {"conversationId":"e2e-1","message":"hola"}
                """;
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>(body, headers), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).contains("sysbase-agent");
    }

    @Test
    void openAiCompat_sse_emitsChunksAndDone() {
        var headers = authHeaders();
        var body = """
                {"model":"sysbase-agent","messages":[{"role":"user","content":"hola"}]}
                """;
        var resp = rest.postForEntity("/chat/completions",
                new HttpEntity<>(body, headers), String.class);
        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).contains("chat.completion.chunk");
        assertThat(resp.getBody()).contains("[DONE]");
    }
}
