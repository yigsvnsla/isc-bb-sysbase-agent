package com.isc.bb.sysbase_agent.security;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.Base64;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ApiKeyRepository {

    private static final SecureRandom RANDOM = new SecureRandom();

    private final JdbcTemplate jdbc;

    public ApiKeyRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * Genera una key plana (se muestra UNA sola vez), persiste solo su SHA-256.
     */
    public String create(String name, String role, Instant expiresAt) {
        var bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        var plain = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        var hash = ApiKeyAuthFilter.sha256Hex(plain);
        jdbc.update("INSERT INTO api_keys (key_hash, name, role, expires_at) VALUES (?, ?, ?, ?)",
                hash, name, role, expiresAt);
        return plain;
    }

    public ApiKey findByHash(String hash) {
        var rows = jdbc.query(
                "SELECT id, key_hash, name, role, created_at, expires_at, active FROM api_keys WHERE key_hash = ?",
                (rs, i) -> new ApiKey(rs.getLong("id"), rs.getString("name"), rs.getString("role"),
                        rs.getTimestamp("created_at").toInstant(),
                        rs.getTimestamp("expires_at") != null ? rs.getTimestamp("expires_at").toInstant() : null,
                        rs.getBoolean("active")),
                hash);
        return rows.isEmpty() ? null : rows.getFirst();
    }

    public List<ApiKey> list() {
        return jdbc.query(
                "SELECT id, key_hash, name, role, created_at, expires_at, active FROM api_keys ORDER BY id",
                (rs, i) -> new ApiKey(rs.getLong("id"), rs.getString("name"), rs.getString("role"),
                        rs.getTimestamp("created_at").toInstant(),
                        rs.getTimestamp("expires_at") != null ? rs.getTimestamp("expires_at").toInstant() : null,
                        rs.getBoolean("active")));
    }

    public boolean revoke(long id) {
        return jdbc.update("UPDATE api_keys SET active = false WHERE id = ?", id) > 0;
    }

    public record ApiKey(long id, String name, String role, Instant createdAt, Instant expiresAt, boolean active) {
    }

    // TODO(futuro): scopes granulares por key (lista de tools permitidas por key).
    // TODO(futuro): límites de uso por key (costo/quota mensual) con alertas.
}
