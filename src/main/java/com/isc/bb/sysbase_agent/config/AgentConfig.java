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
import com.isc.bb.sysbase_agent.tools.KnowledgeBaseTool;
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
                .maxMessages(20)
                .build();
    }

    @Bean
    ChatClient chatClient(ChatClient.Builder builder, PostgresTools postgresTools, KnowledgeBaseTool knowledgeBaseTool) {
        return builder
                .defaultSystem("""
                    Eres un asistente experto en bases de datos PostgreSQL.
                    Ayudas a desarrolladores con stored procedures y
                    documentación técnica.
                    Tienes acceso a las siguientes herramientas:
                    - search_procedures / list_procedures: buscar/listar SPs
                    - get_procedure_source: ver código fuente de un SP
                    - get_dependencies: analizar dependencias de un SP
                    - search_knowledge_base: buscar documentación en PDFs
                    - index_procedure: indexar un SP manualmente
                    Cuando te pidan documentación técnica o manuales,
                    DEBES usar search_knowledge_base.
                    Cuando uses search_knowledge_base, SOLO respondes con la
                    información que devuelve la herramienta. Si no hay
                    resultados suficientes, indícale al usuario. NO uses tu
                    conocimiento previo sobre el contenido de los documentos.
                    Cuando te pidan un diagrama, genera SOLO código Mermaid
                    dentro de un bloque ```mermaid.
                    Para diagramas de flujo usa flowchart TD.
                    Para dependencias usa graph LR.
                    """)
                .defaultTools(postgresTools, knowledgeBaseTool)
                .build();
    }
}
