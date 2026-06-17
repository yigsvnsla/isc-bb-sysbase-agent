package com.isc.bb.sysbase_agent.controller;

import org.springframework.http.ResponseEntity;
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
        var response = agentService.chat(req.conversationId(), req.message());
        return ResponseEntity.ok(new ChatResponse(response));
    }

    public record ChatRequest(String conversationId, String message) {
    }

    public record ChatResponse(String content) {
    }
}
