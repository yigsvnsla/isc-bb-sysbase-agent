package com.isc.bb.sysbase_agent.security;

import java.io.IOException;
import java.time.Duration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class RateLimitFilter extends OncePerRequestFilter {

    private final StringRedisTemplate redis;
    private final boolean enabled;
    private final int userPerMinute;
    private final int ipPerMinute;

    public RateLimitFilter(StringRedisTemplate redis,
                           @Value("${app.security.rate-limit.enabled:true}") boolean enabled,
                           @Value("${app.security.rate-limit.user-per-minute:60}") int userPerMinute,
                           @Value("${app.security.rate-limit.ip-per-minute:20}") int ipPerMinute) {
        this.redis = redis;
        this.enabled = enabled;
        this.userPerMinute = userPerMinute;
        this.ipPerMinute = ipPerMinute;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        if (!enabled) {
            chain.doFilter(request, response);
            return;
        }
        var auth = SecurityContextHolder.getContext().getAuthentication();
        boolean hasUser = auth != null && auth.isAuthenticated()
                && !(auth instanceof AnonymousAuthenticationToken);
        String key;
        int limit;
        if (hasUser) {
            key = "rl:user:" + auth.getName() + ":" + windowBucket();
            limit = userPerMinute;
        } else {
            key = "rl:ip:" + clientIp(request) + ":" + windowBucket();
            limit = ipPerMinute;
        }
        Long count = redis.opsForValue().increment(key);
        if (count != null && count == 1L) {
            redis.expire(key, Duration.ofSeconds(60));
        }
        if (count != null && count > limit) {
            response.setStatus(429);
            response.setHeader("Retry-After", "60");
            response.getWriter().write("Rate limit exceeded");
            return;
        }
        chain.doFilter(request, response);
    }

    private String windowBucket() {
        return String.valueOf(System.currentTimeMillis() / 60_000);
    }

    private String clientIp(HttpServletRequest request) {
        var forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    // TODO(futuro): Bucket4j token-bucket con almacén Redis para ráfagas suaves.
    // TODO(futuro): confiar en X-Forwarded-For solo detrás de proxy de confianza (trust-proxy config).

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        var uri = request.getRequestURI();
        return uri != null && (uri.contains("/actuator/") || uri.endsWith("/models"));
    }
}
