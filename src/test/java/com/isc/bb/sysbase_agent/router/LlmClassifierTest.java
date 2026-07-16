package com.isc.bb.sysbase_agent.router;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.ChatClient.ChatClientRequestSpec;
import org.springframework.ai.chat.client.ChatClient.CallResponseSpec;

class LlmClassifierTest {

    @SuppressWarnings("unchecked")
    private LlmClassifier newClassifier(String llmResponse) {
        var client = mock(ChatClient.class);
        var req = (ChatClientRequestSpec) mock(ChatClientRequestSpec.class, Mockito.RETURNS_DEEP_STUBS);
        var call = mock(CallResponseSpec.class);
        when(client.prompt()).thenReturn(req);
        // deep stubs: req.user(anyString).call().content()
        when(req.user(anyString())).thenReturn(req);
        when(req.call()).thenReturn(call);
        when(call.content()).thenReturn(llmResponse);
        return new LlmClassifier(client);
    }

    @Test
    void classify_parsesCheap() {
        var c = newClassifier("CHEAP");
        assertThat(c.classify("¿qué hace X?")).isEqualTo(Tier.CHEAP);
    }

    @Test
    void classify_parsesExpensive() {
        var c = newClassifier("EXPENSIVE");
        assertThat(c.classify("explica la migracion")).isEqualTo(Tier.EXPENSIVE);
    }

    @Test
    void classify_caseInsensitive() {
        var c = newClassifier("cheap");
        assertThat(c.classify("x")).isEqualTo(Tier.CHEAP);
    }

    @Test
    void classify_unparseable_returnsNull() {
        var c = newClassifier("maybe");
        assertThat(c.classify("x")).isNull();
    }

    @Test
    void classify_blankReturnsNull() {
        var c = newClassifier("CHEAP");
        assertThat(c.classify("")).isNull();
        assertThat(c.classify(null)).isNull();
    }

    @Test
    void classify_exceptionReturnsNull() {
        var client = mock(ChatClient.class);
        when(client.prompt()).thenThrow(new RuntimeException("boom"));
        var c = new LlmClassifier(client);
        assertThat(c.classify("algo")).isNull();
    }
}