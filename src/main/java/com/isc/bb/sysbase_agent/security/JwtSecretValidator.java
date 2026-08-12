package com.isc.bb.sysbase_agent.security;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
public class JwtSecretValidator {

    private static final String DEV_DEFAULT = "dev-only-secret-cambiar-en-produccion-32bytes";

    public JwtSecretValidator(@Value("${app.security.jwt.secret}") String secret, Environment environment) {
        boolean prod = Arrays.asList(environment.getActiveProfiles()).contains("prod");
        if (prod && (DEV_DEFAULT.equals(secret)
                || secret.getBytes(StandardCharsets.UTF_8).length < 32)) {
            throw new IllegalStateException(
                    "JWT_SECRET inválido para producción: definir JWT_SECRET con ≥32 bytes (no usar el default de desarrollo).");
        }
    }
}
