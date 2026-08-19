package com.isc.bb.sysbase_agent.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.isc.bb.sysbase_agent.service.AgentService;

@RestController
@RequestMapping("/v1/agent")
public class AgentController {

    private final AgentService agentService;

    public AgentController(AgentService agentService) {
        this.agentService = agentService;
    }

    @PostMapping("/chat")
    public ResponseEntity<ChatResponse> chat(@RequestBody ChatRequest req) {
        var response = agentService.chat(req.conversationId(), req.message(), req.engine());
        return ResponseEntity.ok(new ChatResponse(response));
    }

    @DeleteMapping("/conversations/{conversationId}")
    public ResponseEntity<Void> deleteConversation(@PathVariable String conversationId) {
        agentService.deleteConversation(conversationId);
        return ResponseEntity.noContent().build();
    }

    public record ChatRequest(String conversationId, String message, String engine) {
    }

    public record ChatResponse(String content) {
    }
}
