package com.isc.bb.sysbase_agent.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;

class JwtRotationTest {

    private static final String CURRENT = "current-secret-32-bytes-minimum-abcdefghij";
    private static final String PREVIOUS = "previous-secret-32-bytes-minimum-1234567890";
    private static final String UNKNOWN = "unknown-secret-32-bytes-minimum-9999999999";

    @Test
    void tokenSignedWithPreviousSecret_stillValid() {
        var issuer = new JwtTokenService(PREVIOUS, 60);
        var decoder = JwtDecoders.withFallback(CURRENT, PREVIOUS);

        var jwt = decoder.decode(issuer.issue("user-1", "READONLY"));

        assertThat(jwt.getSubject()).isEqualTo("user-1");
        assertThat(jwt.getClaimAsString("role")).isEqualTo("READONLY");
    }

    @Test
    void tokenSignedWithCurrentSecret_valid() {
        var issuer = new JwtTokenService(CURRENT, 60);
        var decoder = JwtDecoders.withFallback(CURRENT, PREVIOUS);

        var jwt = decoder.decode(issuer.issue("user-2", "DOC"));

        assertThat(jwt.getSubject()).isEqualTo("user-2");
        assertThat(jwt.getClaimAsString("role")).isEqualTo("DOC");
    }

    @Test
    void tokenSignedWithUnknownSecret_rejected() {
        var issuer = new JwtTokenService(UNKNOWN, 60);
        var decoder = JwtDecoders.withFallback(CURRENT, PREVIOUS);

        assertThatThrownBy(() -> decoder.decode(issuer.issue("user-3", "READONLY")))
                .isInstanceOf(JwtException.class);
    }

    @Test
    void noPreviousSecret_singleDecoderStillWorks() {
        var issuer = new JwtTokenService(CURRENT, 60);
        var decoder = JwtDecoders.withFallback(CURRENT, "");

        assertThat(decoder.decode(issuer.issue("user-4", "ADMIN")).getSubject()).isEqualTo("user-4");
    }
}
