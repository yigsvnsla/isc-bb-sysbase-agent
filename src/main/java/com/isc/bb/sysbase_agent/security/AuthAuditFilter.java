package com.isc.bb.sysbase_agent.security;

import java.io.IOException;

import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.isc.bb.sysbase_agent.audit.AuditRepository;

import io.micrometer.core.instrument.MeterRegistry;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class AuthAuditFilter extends OncePerRequestFilter {

    private final AuditRepository audit;
    private final MeterRegistry meters;

    public AuthAuditFilter(AuditRepository audit, MeterRegistry meters) {
        this.audit = audit;
        this.meters = meters;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        chain.doFilter(request, response);
        if (request.getAttribute("auth-audited") != null) {
            return;
        }
        request.setAttribute("auth-audited", Boolean.TRUE);
        var auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.isAuthenticated() && !(auth instanceof AnonymousAuthenticationToken)) {
            var authorization = request.getHeader("Authorization");
            var method = authorization != null && authorization.startsWith("Bearer ") ? "jwt" : "api-key";
            try {
                audit.recordAuth(method, auth.getName(), true);
                meters.counter("ai_auth_events_total", "method", method, "result", "success").increment();
            } catch (Exception ignored) {
            }
        }
    }

    // TODO(futuro): skip audit para status 429 y rutas actuator — reintentar con filtro de una sola cadena.
    // (causa 401: el filtro se registra en la cadena servlet Y en la security chain — cambios anteriores lo rompían).
}
