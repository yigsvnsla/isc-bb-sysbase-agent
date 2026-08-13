package com.isc.bb.sysbase_agent.wiremock;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Guardia: los bodyPatterns de los stubs de WireMock NO deben aparecer como
 * subcadena del system prompt. Si el prompt contiene un matcher de un stub,
 * WireMock puede secuestrar flujos de tests (prioridad de empate) — bug real
 * con "information_schema" en el prompt vs chat_completions_loop_step2.
 */
class StubPromptCollisionTest {

    @Test
    void stubContainsPatterns_doNotCollideWithSystemPrompt() throws IOException {
        var mapper = new ObjectMapper();
        var prompt = new String(new ClassPathResource("prompts/system.md")
                .getInputStream().readAllBytes());
        var collisions = new ArrayList<String>();

        var dir = new ClassPathResource("wiremock/mappings").getFile();
        try (var files = java.nio.file.Files.list(dir.toPath())) {
            var list = files.toList();
            for (var f : list) {
                JsonNode root = mapper.readTree(f.toFile());
                for (JsonNode p : root.path("request").path("bodyPatterns")) {
                    var contains = p.path("contains").asText("");
                    if (!contains.isEmpty() && prompt.contains(contains)) {
                        collisions.add(f.getFileName() + " -> \"" + contains + "\"");
                    }
                }
            }
        }
        assertThat(collisions)
                .as("bodyPatterns de stubs no deben existir en prompts/system.md")
                .isEmpty();
    }
}
