package com.isc.bb.sysbase_agent.e2e;

import java.time.Duration;
import java.util.regex.Pattern;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.openai.OpenAiChatOptions;

/**
 * Evaluador de calidad de respuestas del agente usando un LLM real (LLM-as-judge).
 * Pide un puntaje 0-5 con una rúbrica estricta (relevancia, exactitud, formato, esfuerzo).
 * Solo para uso en tests con IA_API_KEY real (ver EvalHarnessTest).
 */
public class LlmJudge {

    private static final Pattern INTEGER = Pattern.compile("\\d+");

    private static final int MAX_AGENT_RESPONSE_CHARS = 3000;

    private final ChatClient judge;

    public LlmJudge(ChatClient.Builder builder, String model) {
        this.judge = builder.clone()
                .defaultOptions(OpenAiChatOptions.builder()
                        .model(model)
                        .maxTokens(2048)
                        .temperature(0.0)
                        .timeout(Duration.ofSeconds(60)))
                .defaultSystem("""
                        Eres un evaluador estricto de la calidad de respuestas de un agente experto en
                        bases de datos (Sybase ASE, PostgreSQL, migración de esquemas). Puntúa la
                        respuesta del agente del 0 al 5 según:
                        - relevancia: responde exactamente lo pedido por el usuario
                        - exactitud técnica: no inventa APIs, cláusulas, objetos ni conceptos
                        - formato: markdown limpio, código SQL en bloques
                        - esfuerzo: aborda la pregunta. Si el agente pide una aclaración necesaria
                        (p.ej. qué schema usar, cuando su regla de producto lo exige) y la pregunta
                        es pertinente, la respuesta es correcta: NO la penalices por no ejecutar
                        de inmediato
                        Responde ÚNICAMENTE con un número entero del 0 al 5. Nada más.
                        """)
                .build();
    }

    /** Puntúa la respuesta del agente. Devuelve 0-5. Falla si el judge no devuelve un entero. */
    public int score(String scenario, String userPrompt, String agentResponse) {
        var truncated = agentResponse.length() > MAX_AGENT_RESPONSE_CHARS
                ? agentResponse.substring(0, MAX_AGENT_RESPONSE_CHARS) + "\n[...truncado]"
                : agentResponse;
        var resp = judge.prompt()
                .user("Pregunta del usuario:\n" + userPrompt
                        + "\n\nRespuesta del agente a evaluar:\n" + truncated)
                .call()
                .chatResponse();
        var reply = resp.getResult().getOutput().getText();
        if (reply == null || reply.isBlank()) {
            var reasoning = resp.getResult().getOutput().getMetadata().get("reasoningContent");
            if (reasoning instanceof String r && !r.isBlank()) {
                reply = r;
            }
        }
        if (reply == null || reply.isBlank()) {
            throw new IllegalStateException("Judge sin respuesta para " + scenario + ": " + resp);
        }
        var m = INTEGER.matcher(reply);
        if (!m.find()) {
            throw new IllegalStateException(
                    "Judge no devolvió un entero para " + scenario + ": '" + reply.trim() + "'");
        }
        return Math.min(5, Integer.parseInt(m.group()));
    }
}
