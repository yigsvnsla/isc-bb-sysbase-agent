package com.isc.bb.sysbase_agent.config;

import java.nio.charset.StandardCharsets;
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
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.intercept.AuthorizationFilter;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.isc.bb.sysbase_agent.audit.AuditRepository;
import com.isc.bb.sysbase_agent.security.ApiKeyAuthFilter;
import com.isc.bb.sysbase_agent.security.ApiKeyRepository;
import com.isc.bb.sysbase_agent.security.AuthAuditFilter;

import io.micrometer.core.instrument.MeterRegistry;
import jakarta.servlet.http.HttpServletResponse;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // TODO(futuro): migrar a Identity Provider externo (Keycloak/Auth0) — hoy JWT autogenerado HMAC.
    // TODO(futuro): rotación de JWT_SECRET sin downtime (2 keys activas con kid).
    // TODO(futuro): rate limiting por usuario/token (Bucket4j o Spring Cloud Gateway).

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http,
                                            ApiKeyAuthFilter apiKeyAuthFilter,
                                            AuthAuditFilter authAuditFilter,
                                            AuditRepository audit,
                                            MeterRegistry meters,
                                            JwtAuthenticationConverter jwtAuthenticationConverter) throws Exception {
        http
                .csrf(AbstractHttpConfigurer::disable)
                .cors(Customizer.withDefaults())
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/models", "/actuator/health").permitAll()
                        .anyRequest().authenticated())
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter))
                        .authenticationEntryPoint(auditEntryPoint(audit, meters)))
                .exceptionHandling(ex -> ex.authenticationEntryPoint(auditEntryPoint(audit, meters)))
                .addFilterBefore(apiKeyAuthFilter, UsernamePasswordAuthenticationFilter.class)
                .addFilterAfter(authAuditFilter, AuthorizationFilter.class);
        return http.build();
    }

    @Bean
    ApiKeyAuthFilter apiKeyAuthFilter(ApiKeyRepository apiKeyRepository,
                                      @Value("${app.security.api-keys.enabled:true}") boolean enabled) {
        return new ApiKeyAuthFilter(apiKeyRepository, enabled);
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
    JwtDecoder jwtDecoder(@Value("${app.security.jwt.secret}") String secret) {
        SecretKey key = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        return NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build();
    }

    @Bean
    JwtAuthenticationConverter jwtAuthenticationConverter() {
        var converter = new JwtAuthenticationConverter();
        converter.setJwtGrantedAuthoritiesConverter(jwt -> {
            var role = jwt.getClaimAsString("role");
            return role == null ? List.of() : List.of(new SimpleGrantedAuthority("ROLE_" + role));
        });
        return converter;
    }
}
