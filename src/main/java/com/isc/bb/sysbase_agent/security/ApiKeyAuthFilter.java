package com.isc.bb.sysbase_agent.security;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import com.isc.bb.sysbase_agent.audit.AuditRepository;

import io.micrometer.core.instrument.MeterRegistry;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class ApiKeyAuthFilter extends OncePerRequestFilter {

    private final ApiKeyRepository repository;
    private final boolean enabled;
    private final AuditRepository audit;
    private final MeterRegistry meters;

    public ApiKeyAuthFilter(ApiKeyRepository repository,
                            @Value("${app.security.api-keys.enabled:true}") boolean enabled,
                            AuditRepository audit,
                            MeterRegistry meters) {
        this.repository = repository;
        this.enabled = enabled;
        this.audit = audit;
        this.meters = meters;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, java.io.IOException {
        if (!enabled) {
            chain.doFilter(request, response);
            return;
        }
        var header = request.getHeader("X-API-Key");
        String consumedBearer = null;
        if (header == null || header.isBlank()) {
            // Compatibilidad OpenAI: clientes (p.ej. OpenWebUI) envían la API key
            // como Authorization: Bearer <key>. Si no es un JWT, el lookup por hash
            // fallará y la cadena sigue al decoder JWT normalmente.
            var bearer = request.getHeader("Authorization");
            if (bearer != null && bearer.regionMatches(true, 0, "Bearer ", 0, 7)) {
                header = bearer.substring(7).trim();
                consumedBearer = header;
            }
        }
        if (header == null || header.isBlank()) {
            chain.doFilter(request, response);
            return;
        }
        if (SecurityContextHolder.getContext().getAuthentication() != null
                && SecurityContextHolder.getContext().getAuthentication().isAuthenticated()) {
            chain.doFilter(request, response);
            return;
        }
        var hash = sha256Hex(header);
        var apiKey = repository.findByHash(hash);
        if (apiKey != null && apiKey.active() && !isExpired(apiKey)) {
            var auth = new UsernamePasswordAuthenticationToken(
                    apiKey.name(), null, List.of(new SimpleGrantedAuthority("ROLE_" + apiKey.role())));
            SecurityContextHolder.getContext().setAuthentication(auth);
            request.setAttribute(AsyncSecurityContextRestoreFilter.AUTH_ATTRIBUTE, auth);
            if (consumedBearer != null) {
                // BearerTokenAuthenticationFilter (Security 7) no chequea el contexto y
                // pisaría la auth con un 401 al ver el bearer no-JWT. Ocultar el header.
                request = new BearerStrippingRequest(request);
            }
        } else {
            // Se presentó una key y no matcheó ninguna activa/vigente — a diferencia de
            // "sin credencial", esto es una señal de credential-stuffing/brute-force que
            // vale la pena distinguir en la auditoría (antes cascadeaba a un 401 genérico
            // "método desconocido" vía el entry point de SecurityConfig).
            recordFailedAttempt();
        }
        chain.doFilter(request, response);
    }

    private void recordFailedAttempt() {
        try {
            audit.recordAuth("api-key", null, false);
            meters.counter("ai_auth_events_total", "method", "api-key", "result", "failure").increment();
        } catch (Exception ignored) {
        }
    }

    /** Wrapper que oculta el header Authorization una vez consumido como API key. */
    private static final class BearerStrippingRequest extends jakarta.servlet.http.HttpServletRequestWrapper {
        BearerStrippingRequest(HttpServletRequest request) {
            super(request);
        }

        @Override
        public String getHeader(String name) {
            return "authorization".equalsIgnoreCase(name) ? null : super.getHeader(name);
        }

        @Override
        public java.util.Enumeration<String> getHeaders(String name) {
            return "authorization".equalsIgnoreCase(name)
                    ? java.util.Collections.emptyEnumeration()
                    : super.getHeaders(name);
        }

        @Override
        public java.util.Enumeration<String> getHeaderNames() {
            var names = java.util.Collections.list(super.getHeaderNames());
            names.removeIf(n -> "authorization".equalsIgnoreCase(n));
            return java.util.Collections.enumeration(names);
        }
    }

    private boolean isExpired(ApiKeyRepository.ApiKey apiKey) {
        return apiKey.expiresAt() != null && apiKey.expiresAt().isBefore(java.time.Instant.now());
    }

    static String sha256Hex(String raw) {
        try {
            var md = java.security.MessageDigest.getInstance("SHA-256");
            return java.util.HexFormat.of().formatHex(md.digest(raw.getBytes(java.nio.charset.StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

}
