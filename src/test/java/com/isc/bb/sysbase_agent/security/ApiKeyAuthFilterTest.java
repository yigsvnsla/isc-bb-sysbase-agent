package com.isc.bb.sysbase_agent.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.context.SecurityContextHolder;

import com.isc.bb.sysbase_agent.audit.AuditRepository;

import io.micrometer.core.instrument.simple.SimpleMeterRegistry;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

class ApiKeyAuthFilterTest {

    @AfterEach
    void clearContext() {
        SecurityContextHolder.clearContext();
    }

    private HttpServletRequest request(String apiKeyHeader, String authorizationHeader) {
        var request = mock(HttpServletRequest.class);
        when(request.getHeader("X-API-Key")).thenReturn(apiKeyHeader);
        when(request.getHeader("Authorization")).thenReturn(authorizationHeader);
        return request;
    }

    @Test
    void invalidKey_recordsFailedAuditAndContinuesUnauthenticated() throws Exception {
        var repo = mock(ApiKeyRepository.class);
        when(repo.findByHash(anyString())).thenReturn(null);
        var audit = mock(AuditRepository.class);
        var filter = new ApiKeyAuthFilter(repo, true, audit, new SimpleMeterRegistry());
        var chain = mock(FilterChain.class);

        filter.doFilterInternal(request("bad-key", null), mock(HttpServletResponse.class), chain);

        verify(audit).recordAuth("api-key", null, false);
        verify(chain).doFilter(org.mockito.ArgumentMatchers.any(HttpServletRequest.class),
                org.mockito.ArgumentMatchers.any(HttpServletResponse.class));
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNull();
    }

    @Test
    void expiredKey_recordsFailedAudit() throws Exception {
        var repo = mock(ApiKeyRepository.class);
        var expired = new ApiKeyRepository.ApiKey(1L, "e2e", "READONLY",
                Instant.now().minus(2, ChronoUnit.DAYS), Instant.now().minus(1, ChronoUnit.DAYS), true);
        when(repo.findByHash(anyString())).thenReturn(expired);
        var audit = mock(AuditRepository.class);
        var filter = new ApiKeyAuthFilter(repo, true, audit, new SimpleMeterRegistry());

        filter.doFilterInternal(request("expired-key", null), mock(HttpServletResponse.class), mock(FilterChain.class));

        verify(audit).recordAuth("api-key", null, false);
    }

    @Test
    void noKeyPresented_doesNotAudit() throws Exception {
        var repo = mock(ApiKeyRepository.class);
        var audit = mock(AuditRepository.class);
        var filter = new ApiKeyAuthFilter(repo, true, audit, new SimpleMeterRegistry());
        var chain = mock(FilterChain.class);

        filter.doFilterInternal(request(null, null), mock(HttpServletResponse.class), chain);

        verify(audit, never()).recordAuth(anyString(), anyString(), org.mockito.ArgumentMatchers.anyBoolean());
        verify(chain).doFilter(org.mockito.ArgumentMatchers.any(HttpServletRequest.class),
                org.mockito.ArgumentMatchers.any(HttpServletResponse.class));
    }

    @Test
    void validKey_authenticatesAndDoesNotRecordFailure() throws Exception {
        var repo = mock(ApiKeyRepository.class);
        var valid = new ApiKeyRepository.ApiKey(2L, "e2e", "ADMIN", Instant.now(), null, true);
        when(repo.findByHash(anyString())).thenReturn(valid);
        var audit = mock(AuditRepository.class);
        var filter = new ApiKeyAuthFilter(repo, true, audit, new SimpleMeterRegistry());

        filter.doFilterInternal(request("good-key", null), mock(HttpServletResponse.class), mock(FilterChain.class));

        verify(audit, never()).recordAuth(anyString(), anyString(), org.mockito.ArgumentMatchers.anyBoolean());
        assertThat(SecurityContextHolder.getContext().getAuthentication()).isNotNull();
        assertThat(SecurityContextHolder.getContext().getAuthentication().getName()).isEqualTo("e2e");
    }
}
