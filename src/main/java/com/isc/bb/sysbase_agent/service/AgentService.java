package com.isc.bb.sysbase_agent.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.stereotype.Service;

@Service
public class AgentService {

    private static final Logger log = LoggerFactory.getLogger(AgentService.class);

    private final ChatClient chatClient;

    public AgentService(ChatClient chatClient, ChatMemory chatMemory) {
        this.chatClient = chatClient.mutate()
                .defaultAdvisors(MessageChatMemoryAdvisor.builder(chatMemory).build())
                .build();
    }

    public String chat(String conversationId, String message) {
        log.debug("→ chat: conv={}, msg={}", conversationId, message);
        var response = chatClient.prompt()
                .user(message)
                .advisors(a -> a.param("chat_memory_conversation_id", conversationId))
                .call()
                .content();
        log.debug("← respuesta: conv={}, chars={}", conversationId, response.length());
        return response;
    }
}
