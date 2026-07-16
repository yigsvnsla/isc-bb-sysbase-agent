package com.isc.bb.sysbase_agent.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import com.isc.bb.sysbase_agent.router.ModelRouter;
import com.isc.bb.sysbase_agent.router.RouterDecision;
import com.isc.bb.sysbase_agent.router.Tier;
import com.isc.bb.sysbase_agent.util.MarkdownFixer;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Service
public class AgentService {

    private static final Logger log = LoggerFactory.getLogger(AgentService.class);

    private final ChatClient cheapClient;
    private final ChatClient expensiveClient;
    private final ModelRouter router;
    private final ChatMemory chatMemory;
    private final MeterRegistry meterRegistry;

    public AgentService(@Qualifier("chatClientCheap") ChatClient cheapClient,
                        @Qualifier("chatClientExpensive") ChatClient expensiveClient,
                        ModelRouter router,
                        ChatMemory chatMemory,
                        MeterRegistry meterRegistry) {
        this.cheapClient = cheapClient;
        this.expensiveClient = expensiveClient;
        this.router = router;
        this.chatMemory = chatMemory;
        this.meterRegistry = meterRegistry;
    }

    public String chat(String conversationId, String message) {
        log.debug("→ chat: conv={}, msg={}", conversationId, message);
        var decision = decide(conversationId, message);
        var client = decision.tier() == Tier.EXPENSIVE ? expensiveClient : cheapClient;
        var sample = Timer.start(meterRegistry);
        try {
            var response = client.prompt()
                    .user(message)
                    .advisors(a -> a.param("chat_memory_conversation_id", conversationId))
                    .call()
                    .content();
            log.debug("← respuesta: conv={}, chars={}", conversationId, response.length());
            return MarkdownFixer.fix(response);
        } catch (Exception e) {
            log.error("Error en chat: conv={} tier={}", conversationId, decision.tier(), e);
            return "Lo siento, ocurrió un error al procesar tu consulta: " + e.getMessage();
        } finally {
            recordOutcome(decision, sample);
        }
    }

    public Flux<String> streamChat(String conversationId, String message) {
        log.debug("→ stream(sync-fallback): conv={}, msg={}", conversationId, message);
        return Mono.fromCallable(() -> chat(conversationId, message))
                .flatMapMany(Mono::just);
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
}