package com.isc.bb.sysbase_agent.config;

import java.nio.charset.StandardCharsets;
import java.util.UUID;


import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.core.io.buffer.DefaultDataBufferFactory;
import org.springframework.web.reactive.function.client.WebClient;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@Configuration
@ConditionalOnProperty(value = "app.ai.stream-fix-id", havingValue = "true", matchIfMissing = true)
public class StreamFixConfig {


    @Bean
    public WebClient.Builder webClientBuilder() {
        return WebClient.builder()
                .filter((request, next) -> {
                    var contentType = request.headers().getContentType();
                    var isStreamEndpoint = contentType == null
                            || request.url().getPath().contains("completions");

                    if (!isStreamEndpoint) {
                        return next.exchange(request);
                    }

                    var streamId = "chatcmpl-" + UUID.randomUUID().toString().substring(0, 8);
                    return next.exchange(request)
                            .flatMap(response -> Mono.just(
                                    response.mutate()
                                            .body(transformBody(response.bodyToFlux(DataBuffer.class), streamId))
                                            .build()));
                });
    }

    private Flux<DataBuffer> transformBody(Flux<DataBuffer> body, String streamId) {
        return body.flatMap(buffer -> {
            var content = buffer.toString(StandardCharsets.UTF_8);
            var fixed = fixMissingId(content, streamId);
            var factory = new DefaultDataBufferFactory();
            return Mono.just(factory.wrap(fixed.getBytes(StandardCharsets.UTF_8)));
        });
    }

    private String fixMissingId(String chunk, String streamId) {
        var trimmed = chunk.trim();
        if (trimmed.isEmpty()) return chunk;
        if (!trimmed.contains("\"object\":\"chat.completion.chunk\"")) return chunk;
        if (trimmed.contains("\"id\":\"")) return chunk;
        return chunk.replaceFirst("\\{", "{\"id\":\"" + streamId + "\",");
    }
}
