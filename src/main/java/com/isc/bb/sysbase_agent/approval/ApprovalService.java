package com.isc.bb.sysbase_agent.approval;

import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.tool.ToolCallback;
import org.springframework.stereotype.Service;

import com.isc.bb.sysbase_agent.audit.AuditRepository;

import io.micrometer.core.instrument.MeterRegistry;

/**
 * HITL (human-in-the-loop): las tools de escritura no se ejecutan directo
 * durante un chat; se crea una solicitud PENDING y un ADMIN aprueba o rechaza
 * vía REST/CLI. Al aprobar, la tool se ejecuta con los args originales y el
 * resultado queda en la solicitud (auditado como TOOL).
 */
@Service
public class ApprovalService {

    private static final Logger log = LoggerFactory.getLogger(ApprovalService.class);

    private final ApprovalRepository approvals;
    private final AuditRepository audit;
    private final MeterRegistry meters;
    private final Map<String, ToolCallback> writeToolCallbacks;

    public ApprovalService(ApprovalRepository approvals,
                           AuditRepository audit,
                           MeterRegistry meters,
                           Map<String, ToolCallback> writeToolCallbacks) {
        this.approvals = approvals;
        this.audit = audit;
        this.meters = meters;
        this.writeToolCallbacks = writeToolCallbacks;
    }

    /** Crea una solicitud PENDING (la tool NO se ejecuta). */
    public ApprovalRequest submit(String toolName, String toolInput, String requester) {
        var req = approvals.create(toolName, toolInput, requester);
        audit.recordTool(null, null, requester, toolName, toolInput, false, 0,
                "approval_pending:" + req.id());
        meters.counter("ai_approval_requests_total", "tool", toolName).increment();
        log.info("HITL: solicitud {} de {} por {}", req.id(), toolName, requester);
        return req;
    }

    public List<ApprovalRequest> listPending() {
        return approvals.listPending();
    }

    public ApprovalRequest get(long id) {
        return approvals.get(id);
    }

    /** Aprueba y ejecuta la tool con los args originales. El fallo técnico queda registrado. */
    public ApprovalRequest approve(long id, String admin) {
        var req = approvals.requirePending(id);
        var callback = writeToolCallbacks.get(req.toolName());
        if (callback == null) {
            approvals.decide(id, "REJECTED", admin, null, null,
                    "Tool de escritura no registrada: " + req.toolName());
            return approvals.get(id);
        }
        var startNanos = System.nanoTime();
        String result = null;
        String error = null;
        boolean ok;
        try {
            result = callback.call(req.args());
            ok = true;
        } catch (Throwable t) {
            ok = false;
            error = t.getMessage();
            log.warn("HITL: ejecución de {} (solicitud {}) falló: {}", req.toolName(), id, error);
        }
        var latencyMs = (int) ((System.nanoTime() - startNanos) / 1_000_000);
        approvals.decide(id, "APPROVED", admin, result, ok, error);
        audit.recordTool(null, null, admin, req.toolName(), req.args(), ok, latencyMs, error);
        meters.counter("ai_approval_decisions_total", "action", "approve",
                "ok", String.valueOf(ok)).increment();
        return approvals.get(id);
    }

    public ApprovalRequest reject(long id, String admin) {
        var req = approvals.requirePending(id);
        approvals.decide(id, "REJECTED", admin, null, null, null);
        audit.recordTool(null, null, admin, req.toolName(), req.args(), false, 0,
                "approval_rejected:" + id);
        meters.counter("ai_approval_decisions_total", "action", "reject",
                "ok", "true").increment();
        return approvals.get(id);
    }
}
