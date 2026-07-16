package com.isc.bb.sysbase_agent.router;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import org.springframework.ai.chat.client.ChatClient;

@Component
@ConditionalOnProperty(value = "app.ai.router.classifier.enabled", havingValue = "true", matchIfMissing = true)
public class LlmClassifier {

    private static final Logger log = LoggerFactory.getLogger(LlmClassifier.class);

    private static final String CLASSIFY_PROMPT = """
            Clasifica la complejidad de procesar el siguiente prompt de un usuario de bases de datos.
            Responde UNA sola palabra, sin signos de puntuacion, exactamente CHEAP o EXPENSIVE.
            CHEAP: saludo, pregunta simple, listado simple, factoid, sigla, comando trivial.
            EXPENSIVE: analisis, explicacion tecnica, migracion, refactorizacion, multi-paso,
            razonamiento sobre codigo fuente, generacion de documentacion estructurada.

            Prompt del usuario:
            """;

    private final ChatClient classifierClient;

    public LlmClassifier(@Qualifier("chatClientClassifier") ChatClient classifierClient) {
        this.classifierClient = classifierClient;
    }

    /**
     * @return Tier decidido por LLM, o null si falla/timeout/respuesta no parseable.
     */
    public Tier classify(String userMsg) {
        if (userMsg == null || userMsg.isBlank()) return null;
        try {
            var truncated = userMsg.length() > 2000 ? userMsg.substring(0, 2000) : userMsg;
            var response = classifierClient.prompt()
                    .user(CLASSIFY_PROMPT + truncated)
                    .call()
                    .content();
            return parse(response);
        } catch (Exception e) {
            log.warn("LlmClassifier fail: {}", e.getMessage());
            return null;
        }
    }

    private Tier parse(String response) {
        if (response == null || response.isBlank()) return null;
        var upper = response.toUpperCase().trim();
        if (upper.contains("EXPENSIVE")) return Tier.EXPENSIVE;
        if (upper.contains("CHEAP")) return Tier.CHEAP;
        log.warn("LlmClassifier respuesta no parseable: '{}'", response);
        return null;
    }
}