package com.isc.bb.sysbase_agent.db;

import java.time.Duration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

/**
 * Resuelve el motor de BD por turno (F1-1C). Prioridad:
 * 1. motor explícito (campo "engine" del payload o header X-Engine)
 * 2. motor persistido por conversación (Redis)
 * 3. motor por defecto (app.databases.default-engine)
 */
@Component
public class EngineResolver {

    private static final Logger log = LoggerFactory.getLogger(EngineResolver.class);
    private static final Duration TTL = Duration.ofHours(6);

    private final StringRedisTemplate redis;
    private final DatabaseRegistry registry;

    public EngineResolver(StringRedisTemplate redis, DatabaseRegistry registry) {
        this.redis = redis;
        this.registry = registry;
    }

    public String resolve(String conversationId, String explicit, String header) {
        var requested = firstNonBlank(explicit, header);
        var engine = requested != null ? requested : persisted(conversationId);

        if (engine == null || !registry.isKnown(engine)) {
            engine = registry.defaultEngine();
            if (engine == null || !registry.isKnown(engine)) {
                engine = DatabaseRegistry.POSTGRES;
            }
            log.debug("motor no conocido/presente → default: {}", engine);
        }

        if (requested != null && conversationId != null) {
            persist(conversationId, engine);
        }
        return engine;
    }

    private String persisted(String conversationId) {
        if (conversationId == null) {
            return null;
        }
        try {
            return redis.opsForValue().get(key(conversationId));
        } catch (Exception e) {
            log.debug("no se pudo leer motor persistido de {}: {}", conversationId, e.getMessage());
            return null;
        }
    }

    private void persist(String conversationId, String engine) {
        try {
            redis.opsForValue().set(key(conversationId), engine, TTL);
        } catch (Exception e) {
            log.debug("no se pudo persistir motor de {}: {}", conversationId, e.getMessage());
        }
    }

    private String key(String conversationId) {
        return "chat:engine:" + conversationId;
    }

    private String firstNonBlank(String a, String b) {
        if (a != null && !a.isBlank()) {
            return a.trim();
        }
        if (b != null && !b.isBlank()) {
            return b.trim();
        }
        return null;
    }
}
