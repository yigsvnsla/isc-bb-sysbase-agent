package com.isc.bb.sysbase_agent.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * clientIp()/isTrustedProxy() son privados; se ejercen indirectamente vía
 * doFilterInternal() capturando la key que llega a Redis.
 */
class RateLimitFilterTest {

    @SuppressWarnings("unchecked")
    private ValueOperations<String, String> valueOps(StringRedisTemplate redis) {
        var ops = (ValueOperations<String, String>) mock(ValueOperations.class);
        when(redis.opsForValue()).thenReturn(ops);
        when(ops.increment(anyString())).thenReturn(1L);
        return ops;
    }

    private HttpServletRequest request(String remoteAddr, String forwardedFor) {
        var request = mock(HttpServletRequest.class);
        when(request.getRemoteAddr()).thenReturn(remoteAddr);
        when(request.getHeader("X-Forwarded-For")).thenReturn(forwardedFor);
        when(request.getRequestURI()).thenReturn("/v1/agent/chat");
        return request;
    }

    @Test
    void untrustedRemote_ignoresForwardedFor_keysByRealRemoteAddr() throws Exception {
        var redis = mock(StringRedisTemplate.class);
        var ops = valueOps(redis);
        var filter = new RateLimitFilter(redis, true, 60, 20, "");
        var request = request("1.2.3.4", "9.9.9.9");

        filter.doFilterInternal(request, mock(HttpServletResponse.class), mock(FilterChain.class));

        var captor = ArgumentCaptor.forClass(String.class);
        verify(ops).increment(captor.capture());
        assertThat(captor.getValue()).startsWith("rl:ip:1.2.3.4:");
    }

    @Test
    void trustedProxyExactIp_usesForwardedFor() throws Exception {
        var redis = mock(StringRedisTemplate.class);
        var ops = valueOps(redis);
        var filter = new RateLimitFilter(redis, true, 60, 20, "1.2.3.4");
        var request = request("1.2.3.4", "9.9.9.9, 8.8.8.8");

        filter.doFilterInternal(request, mock(HttpServletResponse.class), mock(FilterChain.class));

        var captor = ArgumentCaptor.forClass(String.class);
        verify(ops).increment(captor.capture());
        assertThat(captor.getValue()).startsWith("rl:ip:9.9.9.9:");
    }

    @Test
    void trustedProxyCidr_matchesAndUsesForwardedFor() throws Exception {
        var redis = mock(StringRedisTemplate.class);
        var ops = valueOps(redis);
        var filter = new RateLimitFilter(redis, true, 60, 20, "10.0.0.0/24, 192.168.1.1");
        var request = request("10.0.0.55", "9.9.9.9");

        filter.doFilterInternal(request, mock(HttpServletResponse.class), mock(FilterChain.class));

        var captor = ArgumentCaptor.forClass(String.class);
        verify(ops).increment(captor.capture());
        assertThat(captor.getValue()).startsWith("rl:ip:9.9.9.9:");
    }

    @Test
    void untrustedRemoteOutsideCidr_ignoresForwardedFor() throws Exception {
        var redis = mock(StringRedisTemplate.class);
        var ops = valueOps(redis);
        var filter = new RateLimitFilter(redis, true, 60, 20, "10.0.0.0/24");
        var request = request("203.0.113.9", "9.9.9.9");

        filter.doFilterInternal(request, mock(HttpServletResponse.class), mock(FilterChain.class));

        var captor = ArgumentCaptor.forClass(String.class);
        verify(ops).increment(captor.capture());
        assertThat(captor.getValue()).startsWith("rl:ip:203.0.113.9:");
    }
}
