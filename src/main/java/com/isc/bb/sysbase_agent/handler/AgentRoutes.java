package com.isc.bb.sysbase_agent.handler;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.function.RouterFunction;
import org.springframework.web.servlet.function.RouterFunctions;
import org.springframework.web.servlet.function.ServerResponse;

@Configuration
public class AgentRoutes {

    @Bean
    RouterFunction<ServerResponse> agentRouterFunction(AgentHandler handler) {
        return RouterFunctions.route()
                .POST("/api/v2/agent/chat", handler::chat)
                .build();
    }
}
