package com.isc.bb.sysbase_agent.security;

import org.springframework.core.Ordered;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Filtro servlet PLANO (no forma parte de la cadena Spring Security) que corre
 * en TODOS los dispatches (REQUEST, ASYNC, ERROR) y restaura la identidad
 * autenticada por API key. En el async dispatch del SSE la cadena de seguridad
 * se re-ejecuta con filtros salteados y contexto anónimo (Security 7), lo que
 * abortaba el stream con AccessDenied tras commit.
 */
public class AsyncSecurityContextRestoreFilter extends OncePerRequestFilter {

    public static final String AUTH_ATTRIBUTE = ApiKeyAuthFilter.class.getName() + ".AUTH";
    public static final int ORDER = Ordered.HIGHEST_PRECEDENCE + 1;

    @Override
    protected boolean shouldNotFilterAsyncDispatch() {
        return false;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, java.io.IOException {
        var dispatcher = request.getDispatcherType();
        if (dispatcher == jakarta.servlet.DispatcherType.ASYNC
                || dispatcher == jakarta.servlet.DispatcherType.ERROR) {
            var saved = (Authentication) request.getAttribute(AUTH_ATTRIBUTE);
            if (saved != null
                    && (SecurityContextHolder.getContext().getAuthentication() == null
                    || !SecurityContextHolder.getContext().getAuthentication().isAuthenticated())) {
                SecurityContextHolder.getContext().setAuthentication(saved);
                // SecurityContextHolderFilter (siguiente en la cadena) cargaría anónimo
                // y pisaría el restore — inyectar también en SU repositorio (atributo).
                var context = org.springframework.security.core.context.SecurityContextHolder
                        .createEmptyContext();
                context.setAuthentication(saved);
                request.setAttribute(
                        org.springframework.security.web.context.RequestAttributeSecurityContextRepository
                                .DEFAULT_REQUEST_ATTR_NAME,
                        context);
            }
        }
        chain.doFilter(request, response);
    }
}
