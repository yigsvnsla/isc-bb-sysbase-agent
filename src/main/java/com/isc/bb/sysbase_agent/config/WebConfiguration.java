package com.isc.bb.sysbase_agent.config;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfiguration implements WebMvcConfigurer {

    private final List<String> corsOrigins;

    public WebConfiguration(@Value("${app.security.cors-origins:http://localhost:3000}") List<String> corsOrigins) {
        this.corsOrigins = corsOrigins;
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        // TODO(futuro): definir dominios reales de producción y quitar el wildcard de origen.
        registry.addMapping("/**")
                .allowedOriginPatterns(corsOrigins.toArray(String[]::new))
                .allowedMethods("GET", "POST", "OPTIONS")
                .allowedHeaders("*");
    }
}
