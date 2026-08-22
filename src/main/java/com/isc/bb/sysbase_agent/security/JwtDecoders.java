package com.isc.bb.sysbase_agent.security;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;

import com.nimbusds.jose.JWSAlgorithm;
import com.nimbusds.jose.JWSHeader;
import com.nimbusds.jose.proc.JWSKeySelector;
import com.nimbusds.jose.proc.SecurityContext;
import com.nimbusds.jwt.proc.ConfigurableJWTProcessor;
import com.nimbusds.jwt.proc.DefaultJWTProcessor;

/**
 * Decoder HS256 con selección de clave por `kid` del header (rotación JWT sin
 * downtime): 2 claves activas durante la transición. Si el token no trae kid
 * (emitidos antes del rollout) o trae un kid desconocido, se prueban las
 * claves configuradas en orden hasta que la firma valide.
 */
public final class JwtDecoders {

    private JwtDecoders() {
    }

    /** Compat: fallback ciego a un secreto anterior, con kids por defecto. */
    public static JwtDecoder withFallback(String secret, String previousSecret) {
        return withKid("current", secret, "previous", previousSecret);
    }

    /** Decoder por kid: token→kid→clave; sin kid/desconocido → prueba todas en orden. */
    public static JwtDecoder withKid(String currentKid, String currentSecret,
                                     String previousKid, String previousSecret) {
        var keys = new LinkedHashMap<String, SecretKey>();
        keys.put(currentKid, key(currentSecret));
        if (previousSecret != null && !previousSecret.isBlank()) {
            keys.put(previousKid, key(previousSecret));
        }
        var ordered = new ArrayList<>(keys.values());

        JWSKeySelector<SecurityContext> selector = (JWSHeader header, SecurityContext context) -> {
            // Defensa en profundidad: solo HS256 es válido hoy (todas las claves son
            // simétricas); rechazar cualquier otro alg evita sorpresas si algún día se
            // agrega una clave de otro tipo (p.ej. RS256) sin restringir explícitamente.
            if (!JWSAlgorithm.HS256.equals(header.getAlgorithm())) {
                return new ArrayList<Key>();
            }
            var kid = header.getKeyID();
            if (kid != null && keys.containsKey(kid)) {
                var out = new ArrayList<Key>();
                out.add(keys.get(kid));
                for (var k : keys.values()) {
                    if (!k.equals(keys.get(kid))) {
                        out.add(k);
                    }
                }
                return out;
            }
            return new ArrayList<Key>(ordered);
        };
        ConfigurableJWTProcessor<SecurityContext> processor = new DefaultJWTProcessor<>();
        processor.setJWSKeySelector(selector);
        return new NimbusJwtDecoder(processor);
    }

    private static SecretKey key(String secret) {
        return new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
    }
}
