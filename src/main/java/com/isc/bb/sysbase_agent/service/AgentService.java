package com.isc.bb.sysbase_agent.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.tool.ToolCallback;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;

import com.isc.bb.sysbase_agent.audit.AuditRepository;
import com.isc.bb.sysbase_agent.router.ModelRouter;
import com.isc.bb.sysbase_agent.router.RouterDecision;
import com.isc.bb.sysbase_agent.router.Tier;
import com.isc.bb.sysbase_agent.security.ToolAccessGuard;
import com.isc.bb.sysbase_agent.util.MarkdownFixer;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.opentelemetry.api.trace.Span;
import io.opentelemetry.api.trace.Tracer;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.math.BigDecimal;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.UUID;

@Service
public class AgentService {

    private static final Logger log = LoggerFactory.getLogger(AgentService.class);

    private final ChatClient cheapClient;
    private final ChatClient expensiveClient;
    private final ModelRouter router;
    private final ChatMemory chatMemory;
    private final MeterRegistry meterRegistry;
    private final AuditRepository audit;
    private final TokenBudgetService budget;
    private final Tracer tracer;
    private final ToolCallback[] toolCallbacks;
    private final ToolAccessGuard guard;

    public AgentService(@Qualifier("chatClientCheap") ChatClient cheapClient,
                        @Qualifier("chatClientExpensive") ChatClient expensiveClient,
                        ModelRouter router,
                        ChatMemory chatMemory,
                        MeterRegistry meterRegistry,
                        AuditRepository audit,
                        TokenBudgetService budget,
                        @Qualifier("otelTracer") Tracer tracer,
                        @Qualifier("agentToolCallbacks") ToolCallback[] toolCallbacks,
                        ToolAccessGuard guard) {
        this.cheapClient = cheapClient;
        this.expensiveClient = expensiveClient;
        this.router = router;
        this.chatMemory = chatMemory;
        this.meterRegistry = meterRegistry;
        this.audit = audit;
        this.budget = budget;
        this.tracer = tracer;
        this.toolCallbacks = toolCallbacks;
        this.guard = guard;
    }

    public String chat(String conversationId, String message) {
        log.debug("→ chat: conv={}, msg={}", conversationId, message);
        var traceId = UUID.randomUUID().toString();
        try {
            var attrs = RequestContextHolder.getRequestAttributes();
            if (attrs != null) {
                attrs.setAttribute("sysbase-trace", traceId, RequestAttributes.SCOPE_REQUEST);
                attrs.setAttribute("sysbase-session", conversationId, RequestAttributes.SCOPE_REQUEST);
            }
        } catch (Exception ignored) {
        }
        var budgetUser = currentUser();
        if (!budget.allowRequest(budgetUser)) {
            return "Límite diario de peticiones alcanzado para este usuario. Intenta mañana.";
        }
        if (!budget.allowMessage(conversationId)) {
            return "Límite de mensajes alcanzado para esta conversación.";
        }
        var decision = decide(conversationId, message);
        var client = decision.tier() == Tier.EXPENSIVE ? expensiveClient : cheapClient;
        var span = tracer.spanBuilder("agent.chat").startSpan();
        span.setAttribute("conv", conversationId);
        span.setAttribute("tier", decision.tier().name());
        span.setAttribute("router.reason", String.valueOf(decision.reason()));
        var sample = Timer.start(meterRegistry);
        var startNanos = System.nanoTime();
        try (var scope = span.makeCurrent()) {
            var filteredTools = toolsForRole(currentRole());
            var response = client.prompt()
                    .user(message)
                    .advisors(a -> a.param("chat_memory_conversation_id", conversationId))
                    .tools(filteredTools)
                    .call()
                    .content();
            log.debug("← respuesta: conv={}, chars={}", conversationId, response.length());
            span.setAttribute("response.chars", response.length());
            var fixed = MarkdownFixer.fix(response);
            budget.recordChars(budgetUser, response.length());
            recordTurn(decision, conversationId, traceId, message, fixed, startNanos, null);
            return fixed;
        } catch (Exception e) {
            log.error("Error en chat: conv={} tier={}", conversationId, decision.tier(), e);
            span.recordException(e);
            recordTurn(decision, conversationId, traceId, message, null, startNanos, e.getMessage());
            return "Lo siento, ocurrió un error al procesar tu consulta: " + e.getMessage();
        } finally {
            span.end();
            recordOutcome(decision, sample);
        }
    }

    public Flux<String> streamChat(String conversationId, String message) {
        log.debug("→ stream(sync-fallback): conv={}, msg={}", conversationId, message);
        return Mono.fromCallable(() -> chat(conversationId, message))
                .flatMapMany(Mono::just);
    }

    public void deleteConversation(String conversationId) {
        try {
            chatMemory.clear(conversationId);
            audit.deleteBySessionId(conversationId);
        } catch (Exception e) {
            log.warn("Error borrando conversación {}: {}", conversationId, e.getMessage());
        }
    }

    private RouterDecision decide(String conversationId, String message) {
        int historySize = 0;
        try {
            historySize = chatMemory.get(conversationId).size();
        } catch (Exception ignored) {
            // conversación nueva o repository issue — tratar como 0
        }
        var decision = router.route(message, historySize);
        log.info("router tier={} score={} reason={} conv={} hist={}",
                decision.tier(), String.format(java.util.Locale.ROOT, "%.2f", decision.score()),
                decision.reason(), conversationId, historySize);
        return decision;
    }

    private void recordOutcome(RouterDecision decision, Timer.Sample sample) {
        try {
            meterRegistry.counter("ai_router_decisions_total",
                    "tier", decision.tier().name().toLowerCase()).increment();
            sample.stop(Timer.builder("ai_chat_duration_seconds")
                    .tag("tier", decision.tier().name().toLowerCase())
                    .register(meterRegistry));
        } catch (Exception ignored) {
            // métricas no críticas — no romper flujo
        }
    }

    private void recordTurn(RouterDecision decision, String conversationId, String traceId,
                            String message, String response, long startNanos, String error) {
        try {
            var latencyMs = (int) ((System.nanoTime() - startNanos) / 1_000_000);
            var userId = currentUser();
            var channel = RequestContextHolder.getRequestAttributes() != null ? "http" : "cli";
            var truncated = message.length() > 500 ? message.substring(0, 500) : message;
            audit.recordTurn(conversationId, traceId, userId, channel,
                    decision.tier().name(), BigDecimal.valueOf(decision.score()), decision.reason(),
                    "cache-hit".equals(decision.reason()),
                    sha256(message), truncated, response != null ? sha256(response) : null,
                    latencyMs, error);
        } catch (Exception ignored) {
            // auditoría no crítica
        }
    }

    private String currentUser() {
        try {
            var auth = SecurityContextHolder.getContext().getAuthentication();
            return auth != null ? auth.getName() : null;
        } catch (Exception e) {
            return null;
        }
    }

    private String currentRole() {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null) {
            return null;
        }
        for (var ga : auth.getAuthorities()) {
            var a = ga.getAuthority();
            if (a != null && a.startsWith("ROLE_")) {
                return a.substring("ROLE_".length());
            }
        }
        return null;
    }

    private ToolCallback[] toolsForRole(String role) {
        if (role == null) {
            return toolCallbacks;
        }
        return java.util.Arrays.stream(toolCallbacks)
                .filter(tc -> guard.canInvoke(role, tc.getToolDefinition().name()))
                .toArray(ToolCallback[]::new);
    }

    private static String sha256(String raw) {
        try {
            var md = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(md.digest(raw.getBytes(java.nio.charset.StandardCharsets.UTF_8)));
        } catch (Exception e) {
            return null;
        }
    }
}