package com.isc.bb.sysbase_agent.handler;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.function.ServerRequest;
import org.springframework.web.servlet.function.ServerResponse;

import com.isc.bb.sysbase_agent.controller.AgentController.ChatRequest;
import com.isc.bb.sysbase_agent.controller.AgentController.ChatResponse;
import com.isc.bb.sysbase_agent.service.AgentService;

@Component
public class AgentHandler {

    private final AgentService agentService;

    public AgentHandler(AgentService agentService) {
        this.agentService = agentService;
    }

    public ServerResponse chat(ServerRequest req) throws Exception {
        var body = req.body(ChatRequest.class);
        var response = agentService.chat(body.conversationId(), body.message());
        return ServerResponse.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .body(new ChatResponse(response));
    }
}
