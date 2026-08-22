package com.isc.bb.sysbase_agent.security;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
public class JwtSecretValidator {

    private static final Logger log = LoggerFactory.getLogger(JwtSecretValidator.class);
    private static final String DEV_DEFAULT = "dev-only-secret-cambiar-en-produccion-32bytes";

    public JwtSecretValidator(@Value("${app.security.jwt.secret}") String secret, Environment environment) {
        boolean prod = Arrays.asList(environment.getActiveProfiles()).contains("prod");
        if (prod && (DEV_DEFAULT.equals(secret)
                || secret.getBytes(StandardCharsets.UTF_8).length < 32)) {
            throw new IllegalStateException(
                    "JWT_SECRET inválido para producción: definir JWT_SECRET con ≥32 bytes (no usar el default de desarrollo).");
        }
        // Sin `prod` explícito no podemos rechazar el arranque (rompería el quickstart local
        // sin SPRING_PROFILES_ACTIVE), pero si además no hay NINGÚN perfil activo y el secreto
        // es el default de desarrollo, es la firma típica de un despliegue que olvidó fijar
        // SPRING_PROFILES_ACTIVE=prod — dejarlo pasar en silencio es el hueco real.
        if (!prod && environment.getActiveProfiles().length == 0 && DEV_DEFAULT.equals(secret)) {
            log.warn("JWT_SECRET usa el valor por defecto de desarrollo y no hay ningún perfil Spring activo. "
                    + "Si esto es un despliegue real, definir SPRING_PROFILES_ACTIVE=prod y JWT_SECRET (≥32 bytes) "
                    + "para que esta validación rechace el arranque.");
        }
    }
}
