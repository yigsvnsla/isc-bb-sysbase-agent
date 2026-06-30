package com.isc.bb.sysbase_agent.controller;

import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicBoolean;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import com.isc.bb.sysbase_agent.dto.OpenAiChunk;
import com.isc.bb.sysbase_agent.dto.OpenAiChunk.Choice;
import com.isc.bb.sysbase_agent.dto.OpenAiChunk.Delta;
import com.isc.bb.sysbase_agent.dto.OpenAiChatRequest;
import com.isc.bb.sysbase_agent.dto.OpenAiChatRequest.Message;
import com.isc.bb.sysbase_agent.dto.OpenAiModel;
import com.isc.bb.sysbase_agent.dto.OpenAiModelList;
import com.isc.bb.sysbase_agent.service.AgentService;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import com.isc.bb.sysbase_agent.util.MarkdownFixer;

@RestController
public class OpenAiCompatController {

    private static final Logger log = LoggerFactory.getLogger(OpenAiCompatController.class);

    private final AgentService agentService;
    private final ObjectMapper objectMapper;

    public OpenAiCompatController(AgentService agentService, ObjectMapper objectMapper) {
        this.agentService = agentService;
        this.objectMapper = objectMapper;
    }

    @GetMapping("/models")
    public ResponseEntity<OpenAiModelList> listModels() {
        var model = new OpenAiModel("sysbase-agent", "model", System.currentTimeMillis() / 1000, "sysbase");
        return ResponseEntity.ok(new OpenAiModelList("list", List.of(model)));
    }

    @PostMapping("/chat/completions")
    public ResponseEntity<Flux<String>> chatCompletions(@RequestBody OpenAiChatRequest req) {
        var convId = resolveConversationId(req);
        var userMsg = extractLastUserMessage(req.messages());

        if (userMsg == null) {
            return ResponseEntity.badRequest().body(Flux.just("{\"error\":\"No user message found\"}"));
        }

        log.debug("→ chat/completions: conv={}, msg={}", convId, truncate(userMsg));

        var model = req.model() != null ? req.model() : "sysbase-agent";
        var chunkId = "chatcmpl-" + UUID.randomUUID().toString().substring(0, 8);
        var created = System.currentTimeMillis() / 1000;
        var isFirstChunk = new AtomicBoolean(true);

        var lineBuf = new StringBuilder();

        var sseFlux = agentService.streamChat(convId, userMsg)
                .map(chunk -> {
                    lineBuf.append(chunk);
                    var text = lineBuf.toString();
                    int nl = text.lastIndexOf('\n');
                    if (nl < 0) return "";
                    var ready = text.substring(0, nl + 1);
                    lineBuf.setLength(0);
                    lineBuf.append(text.substring(nl + 1));
                    return MarkdownFixer.fix(ready);
                })
                .concatWith(Mono.defer(() -> {
                    if (lineBuf.length() > 0) {
                        var remaining = lineBuf.toString();
                        lineBuf.setLength(0);
                        return Mono.just(MarkdownFixer.fix(remaining));
                    }
                    return Mono.empty();
                }))
                .filter(content -> !content.isBlank())
                .map(content -> {
                    var role = isFirstChunk.getAndSet(false) ? "assistant" : null;
                    var chunk = new OpenAiChunk(
                            chunkId, "chat.completion.chunk", created, model,
                            List.of(new Choice(0, new Delta(role, content), null)));
                    return toJson(chunk);
                })
                .concatWith(Mono.just(toJson(new OpenAiChunk(
                        chunkId, "chat.completion.chunk", created, model,
                        List.of(new Choice(0, new Delta(null, null), "stop"))))))
                .concatWith(Mono.just("[DONE]"))
                .onErrorResume(e -> {
                    log.error("Error streaming chat completions", e);
                    return Flux.just("{\"error\":\"" + escapeJson(e.getMessage()) + "\"}", "[DONE]");
                });

        return ResponseEntity.ok()
                .contentType(MediaType.TEXT_EVENT_STREAM)
                .body(sseFlux);
    }

    private String resolveConversationId(OpenAiChatRequest req) {
        if (req.conversationId() != null && !req.conversationId().isBlank()) {
            return req.conversationId();
        }
        if (req.messages() != null) {
            return UUID.nameUUIDFromBytes(req.messages().toString().getBytes(StandardCharsets.UTF_8)).toString();
        }
        return UUID.randomUUID().toString();
    }

    private String extractLastUserMessage(List<Message> messages) {
        if (messages == null) return null;
        for (var i = messages.size() - 1; i >= 0; i--) {
            var msg = messages.get(i);
            if ("user".equals(msg.role()) && msg.content() != null && !msg.content().isBlank()) {
                return msg.content();
            }
        }
        return null;
    }

    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JacksonException e) {
            log.error("Error serializing SSE chunk", e);
            return "{\"error\":\"serialization error\"}";
        }
    }

    private String escapeJson(String raw) {
        if (raw == null) return "";
        return raw.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }

    private String truncate(String s) {
        return s != null && s.length() > 100 ? s.substring(0, 100) + "..." : s;
    }
}
