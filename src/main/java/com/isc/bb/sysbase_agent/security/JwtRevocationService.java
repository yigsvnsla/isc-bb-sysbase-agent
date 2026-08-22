package com.isc.bb.sysbase_agent.security;

import java.time.Duration;
import java.time.Instant;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

/**
 * Denylist de JWT revocados en Redis, indexado por claim `jti`. Los JWT son
 * stateless por diseño (sin round-trip a BD en cada validación); esto agrega
 * la única excepción necesaria: poder invalidar un token específico antes de
 * su expiración natural (ej. compromiso de credenciales) sin tener que rotar
 * el secreto de firma completo (lo que invalidaría TODOS los tokens vigentes).
 */
@Service
public class JwtRevocationService {

    private static final String PREFIX = "jwt:revoked:";

    private final StringRedisTemplate redis;

    public JwtRevocationService(StringRedisTemplate redis) {
        this.redis = redis;
    }

    /**
     * Marca `jti` como revocado hasta `expiresAt` (TTL en Redis = tiempo restante de
     * vida del token — no tiene sentido conservar la entrada más allá de eso, ya que
     * el token expiraría igual por su propio claim `exp`).
     */
    public void revoke(String jti, Instant expiresAt) {
        if (jti == null || jti.isBlank()) {
            throw new IllegalArgumentException(
                    "El token no tiene claim 'jti' — no se puede revocar individualmente "
                            + "(fue emitido antes de habilitar jti, o corresponde a otro emisor).");
        }
        var ttl = expiresAt != null ? Duration.between(Instant.now(), expiresAt) : Duration.ofDays(1);
        if (ttl.isNegative() || ttl.isZero()) {
            return;
        }
        redis.opsForValue().set(PREFIX + jti, "1", ttl);
    }

    public boolean isRevoked(String jti) {
        return jti != null && Boolean.TRUE.equals(redis.hasKey(PREFIX + jti));
    }
}
