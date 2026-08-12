package com.isc.bb.sysbase_agent.security;

import java.nio.charset.StandardCharsets;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;

public final class JwtDecoders {

    private JwtDecoders() {
    }

    /**
     * Decoder HS256 con fallback a un secreto anterior (rotación sin invalidar
     * tokens emitidos con el secreto viejo durante la transición).
     */
    public static JwtDecoder withFallback(String secret, String previousSecret) {
        var primary = base(secret);
        if (previousSecret == null || previousSecret.isBlank()) {
            return primary;
        }
        var previous = base(previousSecret);
        return token -> {
            try {
                return primary.decode(token);
            } catch (JwtException e) {
                return previous.decode(token);
            }
        };
    }

    private static JwtDecoder base(String secret) {
        SecretKey key = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        return NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build();
    }
}
