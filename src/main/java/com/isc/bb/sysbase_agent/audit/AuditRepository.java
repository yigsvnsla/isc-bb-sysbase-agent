package com.isc.bb.sysbase_agent.audit;

import java.math.BigDecimal;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import io.micrometer.core.instrument.MeterRegistry;

@Repository
public class AuditRepository {

    private final JdbcTemplate jdbc;
    private final MeterRegistry meters;

    public AuditRepository(JdbcTemplate jdbc, MeterRegistry meters) {
        this.jdbc = jdbc;
        this.meters = meters;
    }

    private static final String COLUMNS = "id, event_type, event_ts, trace_id, session_id, user_id, channel, "
            + "tier, router_score, router_reason, cache_hit, prompt_hash, prompt_truncated, response_hash, "
            + "latency_ms, tool_name, tool_args, tool_ok, auth_method, auth_ok, error";

    public void recordTurn(String sessionId, String traceId, String userId, String channel, String tier,
                           BigDecimal routerScore, String routerReason, Boolean cacheHit,
                           String promptHash, String promptTruncated, String responseHash,
                           Integer latencyMs, String error) {
        record("TURN", traceId, sessionId, userId, channel, tier, routerScore, routerReason, cacheHit,
                promptHash, promptTruncated, responseHash, latencyMs, null, null, null, null, null, error);
    }

    public void recordTool(String traceId, String userId, String toolName, String toolArgs,
                           boolean ok, Integer latencyMs, String error) {
        record("TOOL", traceId, null, userId, null, null, null, null, null,
                null, null, null, latencyMs, toolName, toolArgs, ok, null, null, error);
    }

    public void recordAuth(String method, String principal, boolean ok) {
        record("AUTH", null, null, principal, null, null, null, null, null,
                null, null, null, null, null, null, null, method, ok, null);
    }

    private void record(String eventType, String traceId, String sessionId, String userId, String channel,
                        String tier, BigDecimal routerScore, String routerReason, Boolean cacheHit,
                        String promptHash, String promptTruncated, String responseHash,
                        Integer latencyMs, String toolName, String toolArgs, Boolean toolOk,
                        String authMethod, Boolean authOk, String error) {
        try {
            jdbc.update("INSERT INTO ai_audit (" + COLUMNS + ") VALUES ("
                    + "DEFAULT, ?, now(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?::jsonb, ?, ?, ?, ?)",
                    eventType, traceId, sessionId, userId, channel, tier, routerScore, routerReason, cacheHit,
                    promptHash, promptTruncated, responseHash, latencyMs, toolName, toolArgs, toolOk,
                    authMethod, authOk, error);
        } catch (Exception e) {
            meters.counter("ai_audit_write_failures_total").increment();
            // auditoría nunca debe romper el flujo principal
        }
    }

    public List<AuditEvent> tail(int limit) {
        return jdbc.query("SELECT " + COLUMNS + " FROM ai_audit ORDER BY id DESC LIMIT ?",
                (rs, i) -> map(rs), limit);
    }

    public List<AuditEvent> search(String toolName, String userId, String eventType, int limit) {
        var sql = new StringBuilder("SELECT " + COLUMNS + " FROM ai_audit WHERE 1=1");
        var args = new java.util.ArrayList<Object>();
        if (toolName != null && !toolName.isBlank()) {
            sql.append(" AND tool_name = ?");
            args.add(toolName);
        }
        if (userId != null && !userId.isBlank()) {
            sql.append(" AND user_id = ?");
            args.add(userId);
        }
        if (eventType != null && !eventType.isBlank()) {
            sql.append(" AND event_type = ?");
            args.add(eventType);
        }
        sql.append(" ORDER BY id DESC LIMIT ?");
        args.add(limit);
        return jdbc.query(sql.toString(), (rs, i) -> map(rs), args.toArray());
    }

    private AuditEvent map(java.sql.ResultSet rs) throws java.sql.SQLException {
        var ts = rs.getTimestamp("event_ts");
        Boolean cacheHit = nullableBool(rs, "cache_hit");
        Integer latencyMs = nullableInt(rs, "latency_ms");
        Boolean toolOk = nullableBool(rs, "tool_ok");
        Boolean authOk = nullableBool(rs, "auth_ok");
        return new AuditEvent(
                rs.getLong("id"), rs.getString("event_type"),
                ts != null ? ts.toInstant() : null,
                rs.getString("trace_id"), rs.getString("session_id"), rs.getString("user_id"),
                rs.getString("channel"), rs.getString("tier"),
                rs.getBigDecimal("router_score"), rs.getString("router_reason"),
                cacheHit,
                rs.getString("prompt_hash"), rs.getString("prompt_truncated"), rs.getString("response_hash"),
                latencyMs,
                rs.getString("tool_name"), rs.getString("tool_args"),
                toolOk,
                rs.getString("auth_method"),
                authOk,
                rs.getString("error"));
    }

    private static Boolean nullableBool(java.sql.ResultSet rs, String column) throws java.sql.SQLException {
        boolean value = rs.getBoolean(column);
        return rs.wasNull() ? null : value;
    }

    private static Integer nullableInt(java.sql.ResultSet rs, String column) throws java.sql.SQLException {
        int value = rs.getInt(column);
        return rs.wasNull() ? null : value;
    }

    // TODO(futuro): export CSV/Parquet + purge por política de retención.
}
