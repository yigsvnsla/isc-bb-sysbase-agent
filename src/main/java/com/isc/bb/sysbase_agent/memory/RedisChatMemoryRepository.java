package com.isc.bb.sysbase_agent.memory;

import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import jakarta.annotation.PostConstruct;
import org.springframework.ai.chat.memory.ChatMemoryRepository;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.MessageType;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.ToolResponseMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.data.redis.core.StringRedisTemplate;

import tools.jackson.databind.ObjectMapper;

public class RedisChatMemoryRepository implements ChatMemoryRepository {

    private static final String CONVERSATION_PREFIX = "chat:memory:";
    private static final String CONVERSATION_IDS_KEY = "chat:memory:ids";
    private static final Duration TTL = Duration.ofHours(6);

    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

    public RedisChatMemoryRepository(StringRedisTemplate redisTemplate, ObjectMapper objectMapper) {
        this.redisTemplate = redisTemplate;
        this.objectMapper = objectMapper;
    }

    @PostConstruct
    void cleanupStaleIds() {
        var keys = redisTemplate.keys(CONVERSATION_PREFIX + "*");
        if (keys == null) return;
        var existing = keys.stream()
                .map(k -> k.substring(CONVERSATION_PREFIX.length()))
                .collect(Collectors.toSet());
        var stored = redisTemplate.opsForSet().members(CONVERSATION_IDS_KEY);
        if (stored == null) return;
        for (var id : stored) {
            if (!existing.contains(id)) {
                redisTemplate.opsForSet().remove(CONVERSATION_IDS_KEY, id);
            }
        }
    }

    @Override
    public List<String> findConversationIds() {
        var members = redisTemplate.opsForSet().members(CONVERSATION_IDS_KEY);
        return members == null ? List.of() : List.copyOf(members);
    }

    @Override
    public List<Message> findByConversationId(String conversationId) {
        var jsonList = redisTemplate.opsForList().range(CONVERSATION_PREFIX + conversationId, 0, -1);
        if (jsonList == null || jsonList.isEmpty()) {
            return List.of();
        }
        return jsonList.stream()
                .map(this::deserialize)
                .toList();
    }

    @Override
    public void saveAll(String conversationId, List<Message> messages) {
        var key = CONVERSATION_PREFIX + conversationId;
        var stored = messages.stream()
                .map(this::serialize)
                .toList();
        redisTemplate.opsForList().rightPushAll(key, stored);
        redisTemplate.expire(key, TTL);
        redisTemplate.opsForSet().add(CONVERSATION_IDS_KEY, conversationId);
    }

    @SuppressWarnings("unchecked")
    String serialize(Message msg) {
        try {
            if (msg.getMessageType() == MessageType.TOOL) {
                var trm = (ToolResponseMessage) msg;
                return objectMapper.writeValueAsString(Map.of(
                        "type", "TOOL",
                        "responses", trm.getResponses().stream()
                                .map(r -> Map.of("id", r.id(), "name", r.name(), "responseData", r.responseData()))
                                .toList(),
                        "metadata", msg.getMetadata()));
            }
            return objectMapper.writeValueAsString(Map.of(
                    "type", msg.getMessageType().name(),
                    "text", msg.getText(),
                    "metadata", msg.getMetadata()));
        } catch (Exception e) {
            throw new RuntimeException("Failed to serialize message", e);
        }
    }

    @SuppressWarnings("unchecked")
    Message deserialize(String raw) {
        try {
            var map = objectMapper.readValue(raw, Map.class);
            var type = MessageType.valueOf((String) map.get("type"));
            return switch (type) {
                case USER -> new UserMessage((String) map.get("text"));
                case ASSISTANT -> new AssistantMessage((String) map.get("text"));
                case SYSTEM -> new SystemMessage((String) map.get("text"));
                case TOOL -> {
                    var responses = ((List<Map<String, String>>) map.get("responses")).stream()
                            .map(r -> new ToolResponseMessage.ToolResponse(
                                    r.get("id"), r.get("name"), r.get("responseData")))
                            .toList();
                    var metadata = (Map<String, Object>) map.get("metadata");
                    yield ToolResponseMessage.builder().responses(responses).metadata(metadata).build();
                }
            };
        } catch (Exception e) {
            throw new RuntimeException("Failed to deserialize message", e);
        }
    }

    @Override
    public void deleteByConversationId(String conversationId) {
        redisTemplate.delete(CONVERSATION_PREFIX + conversationId);
        redisTemplate.opsForSet().remove(CONVERSATION_IDS_KEY, conversationId);
    }
}
