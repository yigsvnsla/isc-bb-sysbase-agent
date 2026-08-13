package com.isc.bb.sysbase_agent.security;

import java.util.concurrent.atomic.AtomicInteger;

import org.springframework.ai.chat.client.ChatClientRequest;
import org.springframework.ai.chat.client.ChatClientResponse;
import org.springframework.ai.chat.client.advisor.api.Advisor;
import org.springframework.ai.chat.client.advisor.api.CallAdvisor;
import org.springframework.ai.chat.client.advisor.api.CallAdvisorChain;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.core.Ordered;

/**
 * Corta el loop de tool-calls del LLM (LLM06 / Unbounded Agency):
 * cuenta los assistant tool_calls del turno ACTUAL (desde el último mensaje
 * de usuario, para no contabilizar turnos anteriores de la memoria) y lanza
 * si el modelo pide más herramientas que el máximo configurado.
 */
public class ToolCallLoopLimitAdvisor implements CallAdvisor {

    private final int maxToolCalls;
    private final AtomicInteger loopGuard = new AtomicInteger();

    public ToolCallLoopLimitAdvisor(int maxToolCalls) {
        this.maxToolCalls = maxToolCalls;
    }

    @Override
    public ChatClientResponse adviseCall(ChatClientRequest request, CallAdvisorChain chain) {
        var messages = request.prompt().getInstructions();
        int from = 0;
        for (int i = 0; i < messages.size(); i++) {
            if (messages.get(i) instanceof UserMessage) {
                from = i + 1;
            }
        }
        long toolCalls = 0;
        for (int i = from; i < messages.size(); i++) {
            if (messages.get(i) instanceof AssistantMessage am
                    && am.getToolCalls() != null && !am.getToolCalls().isEmpty()) {
                toolCalls++;
            }
        }
        if (toolCalls >= maxToolCalls) {
            loopGuard.incrementAndGet();
            throw new SecurityException(
                    "Límite de iteraciones de herramientas excedido (" + maxToolCalls + " por turno)");
        }
        return chain.nextCall(request);
    }

    @Override
    public String getName() {
        return "ToolCallLoopLimitAdvisor";
    }

    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE - 10;
    }

    public int loopBreaches() {
        return loopGuard.get();
    }
}
