package com.isc.bb.sysbase_agent.config;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtException;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.intercept.AuthorizationFilter;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.isc.bb.sysbase_agent.audit.AuditRepository;
import com.isc.bb.sysbase_agent.security.ApiKeyAuthFilter;
import com.isc.bb.sysbase_agent.security.ApiKeyRepository;
import com.isc.bb.sysbase_agent.security.AsyncSecurityContextRestoreFilter;
import com.isc.bb.sysbase_agent.security.AuthAuditFilter;
import com.isc.bb.sysbase_agent.security.JwtDecoders;
import com.isc.bb.sysbase_agent.security.RateLimitFilter;

import io.micrometer.core.instrument.MeterRegistry;
import jakarta.servlet.http.HttpServletResponse;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // TODO(futuro): rate limiting por usuario/token (Bucket4j o Spring Cloud Gateway).

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http,
                                            ApiKeyAuthFilter apiKeyAuthFilter,
                                            AuthAuditFilter authAuditFilter,
                                            RateLimitFilter rateLimitFilter,
                                            AuditRepository audit,
                                            MeterRegistry meters,
                                            JwtAuthenticationConverter jwtAuthenticationConverter) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/models", "/actuator/health", "/actuator/prometheus").permitAll()
                        .requestMatchers("/v1/admin/**").hasRole("ADMIN")
                        .anyRequest().authenticated())
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter))
                        .authenticationEntryPoint(auditEntryPoint(audit, meters)))
                .exceptionHandling(ex -> ex.authenticationEntryPoint(auditEntryPoint(audit, meters)))
                .addFilterBefore(apiKeyAuthFilter, org.springframework.security.oauth2.server.resource.web.authentication.BearerTokenAuthenticationFilter.class)
                .addFilterAfter(rateLimitFilter, AuthorizationFilter.class)
                .addFilterAfter(authAuditFilter, RateLimitFilter.class);
        return http.build();
    }

    @Bean
    ApiKeyAuthFilter apiKeyAuthFilter(ApiKeyRepository apiKeyRepository,
                                      @Value("${app.security.api-keys.enabled:true}") boolean enabled) {
        return new ApiKeyAuthFilter(apiKeyRepository, enabled);
    }

    /**
     * Filtro plano (fuera de la cadena de seguridad) que restaura la auth por
     * API key en los dispatches ASYNC/ERROR — sin él, el SSE se abortaba con
     * AccessDenied tras commit (Security 7 salta los filtros en async dispatch).
     */
    @Bean
    org.springframework.boot.web.servlet.FilterRegistrationBean<AsyncSecurityContextRestoreFilter> asyncSecurityContextRestoreFilter() {
        var registration = new org.springframework.boot.web.servlet.FilterRegistrationBean<>(
                new AsyncSecurityContextRestoreFilter());
        registration.setOrder(AsyncSecurityContextRestoreFilter.ORDER);
        return registration;
    }

    private AuthenticationEntryPoint auditEntryPoint(AuditRepository audit, MeterRegistry meters) {
        return (request, response, ex) -> {
            try {
                audit.recordAuth(null, null, false);
                meters.counter("ai_auth_events_total", "method", "unknown", "result", "failure").increment();
            } catch (Exception ignored) {
            }
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized");
        };
    }

    @Bean
    JwtDecoder jwtDecoder(@Value("${app.security.jwt.secret}") String secret,
                          @Value("${app.security.jwt.previous-secret:}") String previousSecret,
                          @Value("${app.security.jwt.key-id:current}") String keyId,
                          @Value("${app.security.jwt.previous-key-id:previous}") String previousKeyId,
                          @Value("${app.security.oidc.issuer-uri:}") String oidcIssuer) {
        var own = JwtDecoders.withKid(keyId, secret, previousKeyId, previousSecret);
        if (oidcIssuer == null || oidcIssuer.isBlank()) {
            return own;
        }
        var oidc = org.springframework.security.oauth2.jwt.JwtDecoders.fromIssuerLocation(oidcIssuer);
        return token -> {
            try {
                return own.decode(token);
            } catch (JwtException e) {
                return oidc.decode(token);
            }
        };
    }

    @Bean
    JwtAuthenticationConverter jwtAuthenticationConverter() {
        var converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(jwt -> {
            var role = jwt.getClaimAsString("role");
            if (role != null) {
                return List.of(new SimpleGrantedAuthority("ROLE_" + role));
            }
            var realmAccess = jwt.getClaimAsMap("realm_access");
            if (realmAccess != null && realmAccess.get("roles") instanceof List<?> raw) {
                var authorities = new ArrayList<org.springframework.security.core.GrantedAuthority>();
                for (Object r : raw) {
                    if (r instanceof String s
                            && (s.equals("READONLY") || s.equals("DOC") || s.equals("ADMIN"))) {
                        authorities.add(new SimpleGrantedAuthority("ROLE_" + s));
                    }
                }
                if (!authorities.isEmpty()) {
                    return authorities;
                }
            }
            return List.of();
        });
        return converter;
    }
}
