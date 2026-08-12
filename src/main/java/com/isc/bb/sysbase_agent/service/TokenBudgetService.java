package com.isc.bb.sysbase_agent.service;

import java.time.Duration;
import java.time.LocalDate;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
public class TokenBudgetService {

    private final StringRedisTemplate redis;
    private final boolean enabled;
    private final long requestsPerDay;
    private final long charsPerDay;
    private final int msgsPerConversation;

    public TokenBudgetService(StringRedisTemplate redis,
                              @Value("${app.ai.budget.enabled:true}") boolean enabled,
                              @Value("${app.ai.budget.requests-per-day:500}") long requestsPerDay,
                              @Value("${app.ai.budget.chars-per-day:400000}") long charsPerDay,
                              @Value("${app.ai.budget.msgs-per-conversation:100}") int msgsPerConversation) {
        this.redis = redis;
        this.enabled = enabled;
        this.requestsPerDay = requestsPerDay;
        this.charsPerDay = charsPerDay;
        this.msgsPerConversation = msgsPerConversation;
    }

    /** null user = contexto local (CLI) → sin límite. */
    public boolean allowRequest(String userId) {
        if (!enabled || userId == null) {
            return true;
        }
        return incrementAndCheck("budget:req:" + userId + ":" + dayKey(), requestsPerDay);
    }

    public boolean allowMessage(String conversationId) {
        if (!enabled || conversationId == null) {
            return true;
        }
        return incrementAndCheck("budget:conv:" + conversationId, msgsPerConversation);
    }

    public void recordChars(String userId, int chars) {
        if (!enabled || userId == null || chars <= 0) {
            return;
        }
        var key = "budget:chars:" + userId + ":" + dayKey();
        var total = redis.opsForValue().increment(key, chars);
        if (total != null && total == chars) {
            redis.expire(key, Duration.ofDays(1));
        }
        if (total != null && total > charsPerDay) {
            // TODO(futuro): alerta Prometheus al 80% del presupuesto y rechazo proactivo.
        }
    }

    private boolean incrementAndCheck(String key, long limit) {
        var count = redis.opsForValue().increment(key);
        if (count != null && count == 1L) {
            redis.expire(key, Duration.ofDays(1));
        }
        return count == null || count <= limit;
    }

    private String dayKey() {
        return LocalDate.now().toString();
    }

    // TODO(futuro): presupuesto real de tokens vía usage() del LLM (Spring AI no expone en call() aún).
}
