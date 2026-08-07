package com.isc.bb.sysbase_agent.audit;

import java.math.BigDecimal;
import java.time.Instant;

public record AuditEvent(
        Long id,
        String eventType,
        Instant eventTs,
        String traceId,
        String sessionId,
        String userId,
        String channel,
        String tier,
        BigDecimal routerScore,
        String routerReason,
        Boolean cacheHit,
        String promptHash,
        String promptTruncated,
        String responseHash,
        Integer latencyMs,
        String toolName,
        String toolArgs,
        Boolean toolOk,
        String authMethod,
        Boolean authOk,
        String error) {

    public static final String TYPE_TURN = "TURN";
    public static final String TYPE_TOOL = "TOOL";
    public static final String TYPE_AUTH = "AUTH";

    // TODO(futuro): retención automática (particionado por mes + purge > 90 días).
    // TODO(futuro): exportación inmutable (WORM) para cumplimiento.
    // TODO(futuro): tokens_in/tokens_out cuando Spring AI exponga usage en call().
}
