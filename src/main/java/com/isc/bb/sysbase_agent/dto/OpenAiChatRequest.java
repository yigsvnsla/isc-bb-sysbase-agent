package com.isc.bb.sysbase_agent.dto;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonAlias;

public record OpenAiChatRequest(
    String model,
    List<Message> messages,
    Boolean stream,
    @JsonAlias("conversation_id") String conversationId
) {
    public record Message(String role, String content) {}
}
