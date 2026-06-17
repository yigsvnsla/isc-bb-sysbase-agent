package com.isc.bb.sysbase_agent.cli;

import java.util.UUID;

import org.springframework.shell.core.command.annotation.Command;
import org.springframework.shell.core.command.annotation.Option;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.service.AgentService;

@Component
public class AgentCli {

    private final AgentService agentService;

    public AgentCli(AgentService agentService) {
        this.agentService = agentService;
    }

    @Command(name = "ask", description = "Pregunta al agente sobre stored procedures")
    public String ask(
            @Option(longName = "conv", description = "ID de conversación (opcional)") String conversationId,
            @Option(longName = "msg", description = "Mensaje o pregunta") String message) {
        var convId = conversationId != null ? conversationId : UUID.randomUUID().toString();
        return agentService.chat(convId, message);
    }

    @Command(name = "chat", description = "Inicia una conversación interactiva")
    public void chat() {
        var convId = UUID.randomUUID().toString();
        var prompt = "> ";
        System.out.println("ID: " + convId);
        System.out.println("Escribe 'salir' o 'exit' para terminar.");
        try (var scanner = new java.util.Scanner(System.in)) {
            while (true) {
                System.out.print(prompt);
                var input = scanner.nextLine();
                if ("salir".equalsIgnoreCase(input) || "exit".equalsIgnoreCase(input)) {
                    break;
                }
                try {
                    var response = agentService.chat(convId, input);
                    System.out.println(response);
                } catch (Exception e) {
                    System.err.println("Error: " + e.getMessage());
                }
            }
        }
    }
}
