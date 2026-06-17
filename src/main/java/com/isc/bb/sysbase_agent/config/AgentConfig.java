package com.isc.bb.sysbase_agent.config;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.StringRedisTemplate;

import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.json.JsonMapper;
import com.isc.bb.sysbase_agent.memory.RedisChatMemoryRepository;
import com.isc.bb.sysbase_agent.tools.PostgresTools;

@Configuration
public class AgentConfig {

    @Bean
    ObjectMapper objectMapper() {
        return JsonMapper.builder()
                .findAndAddModules()
                .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
                .build();
    }

    @Bean
    RedisChatMemoryRepository chatMemoryRepository(StringRedisTemplate redisTemplate, ObjectMapper objectMapper) {
        return new RedisChatMemoryRepository(redisTemplate, objectMapper);
    }

    @Bean
    ChatMemory chatMemory(RedisChatMemoryRepository repository) {
        return MessageWindowChatMemory.builder()
                .chatMemoryRepository(repository)
                .maxMessages(50)
                .build();
    }

    @Bean
    ChatClient chatClient(ChatClient.Builder builder, PostgresTools postgresTools) {
        return builder
                .defaultSystem("""
                    Eres un asistente experto en bases de datos PostgreSQL.
                    Ayudas a desarrolladores a entender stored procedures.
                    Tienes acceso a herramientas para buscar SPs, obtener su
                    código fuente, y analizar dependencias.
                    Cuando te pidan un diagrama, genera SOLO código Mermaid
                    dentro de un bloque ```mermaid.
                    Para diagramas de flujo usa flowchart TD.
                    Para dependencias usa graph LR.
                    Si no encuentras un SP, sugiere herramientas disponibles.
                    """)
                .defaultTools(postgresTools)
                .build();
    }
}
