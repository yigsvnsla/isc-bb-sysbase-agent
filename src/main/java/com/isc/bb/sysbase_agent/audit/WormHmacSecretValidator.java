package com.isc.bb.sysbase_agent.audit;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/**
 * Igual que JwtSecretValidator pero para la clave HMAC de la cadena WORM: sin
 * ella, cualquiera con acceso de escritura al filesystem puede recalcular la
 * cadena SHA-256 (que no lleva secreto) y falsificar exports enteros sin que
 * `verify()` lo detecte.
 */
@Component
public class WormHmacSecretValidator {

    private static final Logger log = LoggerFactory.getLogger(WormHmacSecretValidator.class);
    private static final String DEV_DEFAULT = "dev-only-worm-hmac-secret-cambiar-en-produccion-32b";

    public WormHmacSecretValidator(@Value("${app.audit.worm.hmac-secret}") String secret, Environment environment) {
        boolean prod = Arrays.asList(environment.getActiveProfiles()).contains("prod");
        if (prod && (DEV_DEFAULT.equals(secret)
                || secret.getBytes(StandardCharsets.UTF_8).length < 32)) {
            throw new IllegalStateException(
                    "WORM_HMAC_SECRET inválido para producción: definir WORM_HMAC_SECRET con ≥32 bytes (no usar el default de desarrollo).");
        }
        if (!prod && environment.getActiveProfiles().length == 0 && DEV_DEFAULT.equals(secret)) {
            log.warn("WORM_HMAC_SECRET usa el valor por defecto de desarrollo y no hay ningún perfil Spring activo. "
                    + "Si esto es un despliegue real, definir SPRING_PROFILES_ACTIVE=prod y WORM_HMAC_SECRET (≥32 bytes) "
                    + "para que esta validación rechace el arranque.");
        }
    }
}
