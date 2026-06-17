package com.isc.bb.sysbase_agent.memory;

import java.time.Duration;
import java.util.List;
import java.util.Map;

import org.springframework.ai.chat.memory.ChatMemoryRepository;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.MessageType;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.data.redis.core.StringRedisTemplate;

import tools.jackson.databind.ObjectMapper;

public class RedisChatMemoryRepository implements ChatMemoryRepository {

    private static final String CONVERSATION_PREFIX = "chat:memory:";
    private static final String CONVERSATION_IDS_KEY = "chat:memory:ids";
    private static final Duration TTL = Duration.ofHours(24);

    private final StringRedisTemplate redisTemplate;
    private final ObjectMapper objectMapper;

    public RedisChatMemoryRepository(StringRedisTemplate redisTemplate, ObjectMapper objectMapper) {
        this.redisTemplate = redisTemplate;
        this.objectMapper = objectMapper;
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

    String serialize(Message msg) {
        try {
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
            var text = (String) map.get("text");
            return switch (type) {
                case USER -> new UserMessage(text);
                case ASSISTANT -> new AssistantMessage(text);
                case SYSTEM -> new SystemMessage(text);
                default -> throw new IllegalArgumentException("Unsupported MessageType: " + type);
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
