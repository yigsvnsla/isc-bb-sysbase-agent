package com.isc.bb.sysbase_agent.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.opentelemetry.api.trace.Tracer;
import io.opentelemetry.exporter.otlp.http.trace.OtlpHttpSpanExporter;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.SimpleSpanProcessor;

@Configuration
public class OtelConfig {

    @Bean(destroyMethod = "close")
    SdkTracerProvider otelTracerProvider(@Value("${management.otlp.tracing.endpoint:}") String endpoint) {
        var builder = SdkTracerProvider.builder();
        if (endpoint != null && !endpoint.isBlank()) {
            var exporter = OtlpHttpSpanExporter.builder()
                    .setEndpoint(endpoint + "/v1/traces")
                    .build();
            builder.addSpanProcessor(SimpleSpanProcessor.create(exporter));
        }
        return builder.build();
    }

    @Bean
    Tracer otelTracer(SdkTracerProvider tracerProvider) {
        return tracerProvider.get("sysbase-agent");
    }

    // TODO(futuro): sampling configurable por entorno (hoy 100%).
}
