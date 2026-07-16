package com.isc.bb.sysbase_agent.router;

import java.security.MessageDigest;
import java.time.Duration;
import java.util.HexFormat;
import java.util.Optional;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Component;

import io.micrometer.core.instrument.MeterRegistry;

@Component
@ConditionalOnProperty(value = "app.ai.router.enabled", havingValue = "true", matchIfMissing = true)
public class ModelRouter {

    private static final Logger log = LoggerFactory.getLogger(ModelRouter.class);

    private static final Pattern INTENT_SIMPLE = Pattern.compile(
            "^(hola|buenos|buenas|hey|saludos|\\s*¿?qu[eé] hace|list[a-zá]+|mu[eé]strame|muestra|qu[ií]en|dime)\\b",
            Pattern.CASE_INSENSITIVE);

    private static final Pattern KEYWORDS_EXPENSIVE = Pattern.compile(
            "(migr(a|aci[oó]n|ar)|refactor|expl[ií]came|analiza|diagrama|dependencias|"
                    + "est[aá]ndar|performance|optimiza|compara|sybase.*postgres|plan de migraci[oó]n|ase|"
                    + "dise[ñn]a|estructura|arquitectura|revisa)",
            Pattern.CASE_INSENSITIVE);

    private final double threshold;
    private final double grayLow;
    private final double grayHigh;
    private final Tier fallback;
    private final ObjectProvider<LlmClassifier> classifierProvider;
    private final ObjectProvider<StringRedisTemplate> redisProvider;
    private final ObjectProvider<MeterRegistry> meterRegistryProvider;
    private final boolean cacheEnabled;
    private final Duration cacheTtl;

    public ModelRouter(
            @Value("${app.ai.router.score-threshold:0.6}") double threshold,
            @Value("${app.ai.router.gray-low:0.35}") double grayLow,
            @Value("${app.ai.router.gray-high:0.55}") double grayHigh,
            @Value("${app.ai.router.fallback-tier:cheap}") String fallback,
            ObjectProvider<LlmClassifier> classifierProvider,
            ObjectProvider<StringRedisTemplate> redisProvider,
            ObjectProvider<MeterRegistry> meterRegistryProvider,
            @Value("${app.ai.router.cache.enabled:true}") boolean cacheEnabled,
            @Value("${app.ai.router.cache.ttl-min:60}") long cacheTtlMin) {
        this.threshold = threshold;
        this.grayLow = grayLow;
        this.grayHigh = grayHigh;
        this.fallback = "expensive".equalsIgnoreCase(fallback) ? Tier.EXPENSIVE : Tier.CHEAP;
        this.classifierProvider = classifierProvider;
        this.redisProvider = redisProvider;
        this.meterRegistryProvider = meterRegistryProvider;
        this.cacheEnabled = cacheEnabled;
        this.cacheTtl = Duration.ofMinutes(cacheTtlMin);
    }

    public RouterDecision route(String userMsg, int historySize) {
        if (userMsg == null || userMsg.isBlank()) {
            return new RouterDecision(fallback, 0.0, "empty-msg");
        }

        var cacheKey = cacheKey(userMsg, historySize);
        if (cacheEnabled) {
            var cached = cacheGet(cacheKey);
            if (cached != null) {
                cacheCounter("hit");
                log.debug("router cache hit: key={} tier={}", cacheKey, cached);
                return new RouterDecision(cached, -1.0, "cache-hit");
            }
            cacheCounter("miss");
        }

        var heuristic = routeHeuristic(userMsg, historySize);

        if (isGray(heuristic.score())) {
            var classifier = classifierProvider.getIfAvailable();
            if (classifier != null) {
                classifierCounter("attempt");
                var llmTier = classifier.classify(userMsg);
                if (llmTier != null) {
                    classifierCounter("hit");
                    var decision = new RouterDecision(llmTier, heuristic.score(),
                            "classifier:" + heuristic.reason());
                    cachePut(cacheKey, llmTier);
                    return decision;
                }
                classifierCounter("fail");
                cacheCounter("fail");
                var dedup = new RouterDecision(fallback, heuristic.score(),
                        heuristic.reason() + "|classifier-fail");
                cachePut(cacheKey, fallback);
                return dedup;
            }
            // sin bean classifier -> usa threshold directo
        }

        cachePut(cacheKey, heuristic.tier());
        return heuristic;
    }

    private RouterDecision routeHeuristic(String userMsg, int historySize) {
        var len = userMsg.length();

        if (len < 80 && INTENT_SIMPLE.matcher(userMsg).find()) {
            return new RouterDecision(Tier.CHEAP, 0.0, "intent-simple");
        }

        double score = 0.0;
        var reasons = new java.util.ArrayList<String>();

        var kwMatcher = KEYWORDS_EXPENSIVE.matcher(userMsg);
        int kwHits = 0;
        while (kwMatcher.find()) kwHits++;
        if (kwHits > 0) {
            double kwScore = Math.min(0.8, kwHits * 0.4);
            score += kwScore;
            reasons.add("keywords=" + kwHits + "(+" + String.format(java.util.Locale.ROOT, "%.2f", kwScore) + ")");
        }

        if (len > 1500) {
            score += 0.3;
            reasons.add("len>1500(+0.30)");
        } else if (len >= 200) {
            score += 0.15;
            reasons.add("len=" + len + "(+0.15)");
        }

        if (historySize >= 10) {
            score += 0.15;
            reasons.add("hist=" + historySize + "(+0.15)");
        }

        score = Math.max(0.0, Math.min(1.0, score));
        var tier = score >= threshold ? Tier.EXPENSIVE : Tier.CHEAP;
        var reason = reasons.isEmpty() ? "default" : String.join("|", reasons);
        return new RouterDecision(tier, score, reason);
    }

    public boolean isGray(double score) {
        return score >= grayLow && score < grayHigh;
    }

    private String cacheKey(String userMsg, int historySize) {
        var bucket = historySize >= 10 ? "h10" : "h0";
        var input = userMsg + "|" + bucket;
        try {
            var md = MessageDigest.getInstance("SHA-256");
            return "router:dec:" + HexFormat.of().formatHex(md.digest(input.getBytes())).substring(0, 32);
        } catch (Exception e) {
            return "router:dec:nohash:" + (userMsg.hashCode() & 0x7fffffff);
        }
    }

    private Tier cacheGet(String key) {
        try {
            var redis = redisProvider.getIfAvailable();
            if (redis == null) return null;
            var v = redis.opsForValue().get(key);
            if (v == null) return null;
            return "EXPENSIVE".equalsIgnoreCase(v) ? Tier.EXPENSIVE : Tier.CHEAP;
        } catch (Exception e) {
            log.debug("cache get fail: {}", e.getMessage());
            return null;
        }
    }

    private void cachePut(String key, Tier tier) {
        if (!cacheEnabled) return;
        try {
            var redis = redisProvider.getIfAvailable();
            if (redis == null) return;
            redis.opsForValue().set(key, tier.name(), cacheTtl);
        } catch (Exception e) {
            log.debug("cache put fail: {}", e.getMessage());
        }
    }

    private void cacheCounter(String result) {
        try {
            var mr = meterRegistryProvider.getIfAvailable();
            if (mr == null) return;
            mr.counter("ai_router_cache_total", "result", result).increment();
        } catch (Exception ignored) {
        }
    }

    private void classifierCounter(String outcome) {
        try {
            var mr = meterRegistryProvider.getIfAvailable();
            if (mr == null) return;
            mr.counter("ai_router_classifier_calls_total", "outcome", outcome).increment();
        } catch (Exception ignored) {
        }
    }
}