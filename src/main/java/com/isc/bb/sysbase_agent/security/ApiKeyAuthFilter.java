package com.isc.bb.sysbase_agent.security;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 5)
public class ApiKeyAuthFilter extends OncePerRequestFilter {

    private final ApiKeyRepository repository;
    private final boolean enabled;

    public ApiKeyAuthFilter(ApiKeyRepository repository,
                            @Value("${app.security.api-keys.enabled:true}") boolean enabled) {
        this.repository = repository;
        this.enabled = enabled;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, java.io.IOException {
        if (!enabled) {
            chain.doFilter(request, response);
            return;
        }
        var header = request.getHeader("X-API-Key");
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
        }
        chain.doFilter(request, response);
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

    // TODO(futuro): respuesta 401 inmediata con cabecera WWW-Authenticate cuando la key es inválida.
    // TODO(futuro): auditoría de intentos fallidos de autenticación.
}
