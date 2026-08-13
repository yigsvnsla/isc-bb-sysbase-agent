package com.isc.bb.sysbase_agent.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Duration;

import org.junit.jupiter.api.Test;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

class TokenBudgetServiceTest {

    @SuppressWarnings("unchecked")
    private ValueOperations<String, String> valueOps() {
        return mock(ValueOperations.class);
    }

    private TokenBudgetService service(long requestsPerDay, long charsPerDay, int msgsPerConversation,
                                       ValueOperations<String, String> ops) {
        var redis = mock(StringRedisTemplate.class);
        when(redis.opsForValue()).thenReturn(ops);
        return new TokenBudgetService(redis, true, requestsPerDay, charsPerDay, msgsPerConversation, new io.micrometer.core.instrument.simple.SimpleMeterRegistry());
    }

    @Test
    void allowRequest_firstCall_okAndSetsExpiry() {
        var ops = valueOps();
        when(ops.increment(anyString())).thenReturn(1L);
        var redis = mock(StringRedisTemplate.class);
        when(redis.opsForValue()).thenReturn(ops);
        var service = new TokenBudgetService(redis, true, 500, 400_000, 100, new io.micrometer.core.instrument.simple.SimpleMeterRegistry());

        assertThat(service.allowRequest("user-1")).isTrue();
        verify(redis).expire(anyString(), any(Duration.class));
    }

    @Test
    void allowRequest_overLimit_denied() {
        var ops = valueOps();
        when(ops.increment(anyString())).thenReturn(501L);
        var service = service(500, 400_000, 100, ops);

        assertThat(service.allowRequest("user-1")).isFalse();
    }

    @Test
    void allowRequest_nullUser_localTrust_alwaysAllowed() {
        var ops = valueOps();
        var service = service(1, 1, 1, ops);
        assertThat(service.allowRequest(null)).isTrue();
        verify(ops, never()).increment(anyString());
    }

    @Test
    void allowMessage_overLimit_denied() {
        var ops = valueOps();
        when(ops.increment(anyString())).thenReturn(101L);
        var service = service(500, 400_000, 100, ops);
        assertThat(service.allowMessage("conv-1")).isFalse();
    }

    @Test
    void recordChars_incrementsByDelta() {
        var ops = valueOps();
        when(ops.increment(anyString(), any(Long.class))).thenReturn(100L);
        var service = service(500, 400_000, 100, ops);
        service.recordChars("user-1", 100);
        verify(ops).increment(anyString(), org.mockito.ArgumentMatchers.eq(100L));
    }
}
