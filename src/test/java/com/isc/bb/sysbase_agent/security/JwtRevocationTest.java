package com.isc.bb.sysbase_agent.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

import org.junit.jupiter.api.Test;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.security.oauth2.jwt.JwtException;

class JwtRevocationTest {

    private static final String SECRET = "current-secret-32-bytes-minimum-abcdefghij";

    @SuppressWarnings("unchecked")
    private ValueOperations<String, String> valueOps(StringRedisTemplate redis) {
        var ops = (ValueOperations<String, String>) mock(ValueOperations.class);
        when(redis.opsForValue()).thenReturn(ops);
        return ops;
    }

    @Test
    void revoke_setsKeyWithTtlUntilExpiry() {
        var redis = mock(StringRedisTemplate.class);
        var ops = valueOps(redis);
        var service = new JwtRevocationService(redis);
        var exp = Instant.now().plus(30, ChronoUnit.MINUTES);

        service.revoke("jti-1", exp);

        verify(ops).set(eq("jwt:revoked:jti-1"), eq("1"), any(Duration.class));
    }

    @Test
    void revoke_alreadyExpiredToken_isNoop() {
        var redis = mock(StringRedisTemplate.class);
        var ops = valueOps(redis);
        var service = new JwtRevocationService(redis);

        service.revoke("jti-2", Instant.now().minus(1, ChronoUnit.MINUTES));

        verify(ops, never()).set(anyString(), anyString(), any(Duration.class));
    }

    @Test
    void revoke_blankJti_throws() {
        var redis = mock(StringRedisTemplate.class);
        var service = new JwtRevocationService(redis);

        assertThatThrownBy(() -> service.revoke("", Instant.now().plusSeconds(60)))
                .isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> service.revoke(null, Instant.now().plusSeconds(60)))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void isRevoked_delegatesToHasKey() {
        var redis = mock(StringRedisTemplate.class);
        when(redis.hasKey("jwt:revoked:jti-3")).thenReturn(true);
        when(redis.hasKey("jwt:revoked:jti-4")).thenReturn(false);
        var service = new JwtRevocationService(redis);

        assertThat(service.isRevoked("jti-3")).isTrue();
        assertThat(service.isRevoked("jti-4")).isFalse();
        assertThat(service.isRevoked(null)).isFalse();
    }

    @Test
    void decoder_rejectsRevokedToken_acceptsNonRevoked() throws Exception {
        var issuer = new JwtTokenService(SECRET, 60, "current");
        var token = issuer.issue("user-1", "READONLY");
        var jti = com.nimbusds.jwt.SignedJWT.parse(token).getJWTClaimsSet().getJWTID();

        var acceptingDecoder = JwtDecoders.withKid("current", SECRET, "previous", "", j -> false);
        assertThat(acceptingDecoder.decode(token).getSubject()).isEqualTo("user-1");

        var revokingDecoder = JwtDecoders.withKid("current", SECRET, "previous", "", j -> j.equals(jti));
        assertThatThrownBy(() -> revokingDecoder.decode(token)).isInstanceOf(JwtException.class);
    }

    @Test
    void tokenIssued_alwaysHasJti() throws Exception {
        var issuer = new JwtTokenService(SECRET, 60, "current");
        var token = issuer.issue("user-2", "ADMIN");

        var jti = com.nimbusds.jwt.SignedJWT.parse(token).getJWTClaimsSet().getJWTID();

        assertThat(jti).isNotBlank();
    }
}
