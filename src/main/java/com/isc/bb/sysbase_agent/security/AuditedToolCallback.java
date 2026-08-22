package com.isc.bb.sysbase_agent.security;

import org.springframework.ai.chat.model.ToolContext;
import org.springframework.ai.tool.ToolCallback;
import org.springframework.ai.tool.definition.ToolDefinition;
import org.springframework.ai.tool.metadata.ToolMetadata;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;

import com.isc.bb.sysbase_agent.approval.ApprovalService;
import com.isc.bb.sysbase_agent.audit.AuditRepository;

import io.micrometer.core.instrument.MeterRegistry;
import io.opentelemetry.api.trace.Tracer;
import tools.jackson.databind.ObjectMapper;

public class AuditedToolCallback implements ToolCallback {

    private final ToolCallback delegate;
    private final ToolAccessGuard guard;
    private final AuditRepository audit;
    private final ApprovalService approvals;
    private final ObjectMapper objectMapper;
    private final MeterRegistry meters;
    private final Tracer tracer;

    public AuditedToolCallback(ToolCallback delegate, ToolAccessGuard guard, AuditRepository audit,
                               ApprovalService approvals,
                               ObjectMapper objectMapper, MeterRegistry meters, Tracer tracer) {
        this.delegate = delegate;
        this.guard = guard;
        this.audit = audit;
        this.approvals = approvals;
        this.objectMapper = objectMapper;
        this.meters = meters;
        this.tracer = tracer;
    }

    @Override
    public ToolDefinition getToolDefinition() {
        return delegate.getToolDefinition();
    }

    @Override
    public ToolMetadata getToolMetadata() {
        return delegate.getToolMetadata();
    }

    @Override
    public String call(String toolInput) {
        return guardedCall(toolInput, null);
    }

    @Override
    public String call(String toolInput, ToolContext toolContext) {
        return guardedCall(toolInput, toolContext);
    }

    private String guardedCall(String toolInput, ToolContext toolContext) {
        var role = currentRole();
        var name = delegate.getToolDefinition().name();
        if (!guard.canInvoke(role, name)) {
            throw new SecurityException("Tool '" + name + "' no permitida para rol: " + role);
        }
        if (guard.isWriteTool(name) && role != null && approvals != null) {
            var req = approvals.submit(name, toolInput, currentUser());
            return wrapRetrievedData("⚠️ Solicitud #" + req.id() + " de " + name
                    + " en espera de aprobación humana. NO se ejecutó. "
                    + "El administrador la aprueba vía GET /v1/admin/approvals.");
        }
        var startNanos = System.nanoTime();
        var span = tracer.spanBuilder("agent.tool." + name).startSpan();
        span.setAttribute("tool", name);
        span.setAttribute("role", String.valueOf(role));
        try (var scope = span.makeCurrent()) {
            var raw = toolContext != null ? delegate.call(toolInput, toolContext) : delegate.call(toolInput);
            var wrapped = wrapRetrievedData(raw);
            recordTool(name, toolInput, true, startNanos, null);
            return wrapped;
        } catch (Throwable t) {
            span.recordException(t);
            recordTool(name, toolInput, false, startNanos, t.getMessage());
            throw t;
        } finally {
            span.end();
        }
    }

    private void recordTool(String name, String toolInput, boolean ok, long startNanos, String error) {
        try {
            var latencyMs = (int) ((System.nanoTime() - startNanos) / 1_000_000);
            audit.recordTool(currentSession(), currentTrace(), currentUser(), name, toolInput, ok, latencyMs, error);
            meters.counter("ai_tool_calls_total", "tool", name, "ok", String.valueOf(ok)).increment();
        } catch (Exception ignored) {
        }
    }

    private String wrapRetrievedData(String raw) {
        if (raw == null || raw.isBlank()) {
            return raw;
        }
        return "<retrieved_data>\n" + raw + "\n</retrieved_data>";
    }

    private String currentRole() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) {
            return null;
        }
        for (GrantedAuthority ga : auth.getAuthorities()) {
            var a = ga.getAuthority();
            if (a != null && a.startsWith("ROLE_")) {
                return a.substring("ROLE_".length());
            }
        }
        return null;
    }

    private String currentUser() {
        try {
            var auth = SecurityContextHolder.getContext().getAuthentication();
            return auth != null ? auth.getName() : null;
        } catch (Exception e) {
            return null;
        }
    }

    private String currentTrace() {
        try {
            var attrs = RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                return (String) attrs.getAttribute("sysbase-trace", RequestAttributes.SCOPE_REQUEST);
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    private String currentSession() {
        try {
            var attrs = RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                return (String) attrs.getAttribute("sysbase-session", RequestAttributes.SCOPE_REQUEST);
            }
        } catch (Exception ignored) {
        }
        return null;
    }

    // TODO(futuro): detector post-hoc de tool-calls inyectados (LLM-judge sobre la cadena de llamadas).
}
