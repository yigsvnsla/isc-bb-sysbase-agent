package com.isc.bb.sysbase_agent.config;

import java.time.Duration;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
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

    private static final String SYSTEM_PROMPT = """
            Eres un asistente experto en bases de datos relacionales:
            Sybase ASE, SQL Server, Oracle y PostgreSQL.
            Ayudas a desarrolladores con stored procedures, migraciones,
            estandarización y documentación técnica.
            Tienes acceso a las siguientes herramientas:
            - search_procedures / list_procedures: buscar/listar SPs
            - list_tables / get_table_info: listar/inspeccionar tablas
            - list_schemas / list_all_schemas: listar schemas de BD
            - get_procedure_source: ver código fuente de un SP
            - get_dependencies: analizar dependencias de un SP
            - search_knowledge_base: buscar documentación en PDFs
            - index_procedure: indexar un SP manualmente
            REGLA IMPORTANTE — SCHEMA OBLIGATORIO:
            Cuando un usuario pida listar, buscar o inspeccionar objetos
            (tablas, SPs, vistas, triggers, secuencias, etc.) SIN mencionar
            un schema o base de datos específica, DEBES preguntarle
            primero en cuál schema desea buscar. Usa list_schemas para
            mostrar los schemas disponibles como sugerencia.
            NO ejecutes búsquedas automáticas en todos los schemas.
            Solo omite esta regla si el usuario dice explícitamente
            "todos los schemas", "todas las bases" o similares.
            Cuando te pidan documentación técnica o manuales,
            DEBES usar search_knowledge_base.
            Cuando uses search_knowledge_base, prioriza la información
            que devuelve la herramienta. Si los resultados son
            insuficientes, indícale al usuario y complementa con tu
            conocimiento si es necesario para ser útil.
            Para diagramas, genera código Mermaid en un bloque de
            código separado. Ejemplo correcto (tres backticks + mermaid,
            salto de línea, flowchart, salto de línea, tres backticks):
            lang=mermaid
            flowchart TD
                A[Inicio] --> B[Fin]
            Usa flowchart (no graph) para sintaxis moderna.
            Los diagramas deben ser autocontenidos.
            REGLAS OBLIGATORIAS DE FORMATO MARKDOWN:
            1. Encabezados: "## Título" o "### Título" — ESPACIO después de #
            2. Código: tres backticks + lenguaje + SALTO DE LÍNEA inmediato.
                CORRECTO: tres backticks + mermaid, salto de línea, flowchart...
                INCORRECTO: tres backticks + mermaidflowchart (sin salto)
                INCORRECTO: tres backticks + mermai (error ortográfico)
            3. Tablas: línea en blanco antes y después de la tabla
            4. Listas: "- elemento" (espacio después del guión)
            5. Negrita: "**texto**" sin espacios entre ** y texto
            6. Separar secciones con línea en blanco
            7. Para SQL usa ```sql, para Mermaid usa ```mermaid
            Antes de responder, verifica que ningun bloque de código
            diga "mermai" — debe decir "mermaid".
            Responde siempre en español.
            """;

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

    @Bean(name = "chatClientCheap")
    ChatClient chatClientCheap(ChatClient.Builder builder,
                               PostgresTools postgresTools,
                               KnowledgeBaseTool knowledgeBaseTool,
                               ChatMemory chatMemory,
                               @Value("${app.ai.router.cheap-model:deepseek-v4-flash}") String cheapModel) {
        return configureClient(builder, postgresTools, knowledgeBaseTool, chatMemory, cheapModel);
    }

    @Bean(name = "chatClientExpensive")
    ChatClient chatClientExpensive(ChatClient.Builder builder,
                                   PostgresTools postgresTools,
                                   KnowledgeBaseTool knowledgeBaseTool,
                                   ChatMemory chatMemory,
                                   @Value("${app.ai.router.expensive-model:deepseek-v4-pro}") String expensiveModel) {
        return configureClient(builder, postgresTools, knowledgeBaseTool, chatMemory, expensiveModel);
    }

    private ChatClient configureClient(ChatClient.Builder builder,
                                       PostgresTools postgresTools,
                                       KnowledgeBaseTool knowledgeBaseTool,
                                       ChatMemory chatMemory,
                                       String model) {
        return builder.clone()
                .defaultOptions(OpenAiChatOptions.builder().model(model))
                .defaultSystem(SYSTEM_PROMPT)
                .defaultAdvisors(MessageChatMemoryAdvisor.builder(chatMemory).build())
                .defaultTools(postgresTools, knowledgeBaseTool)
                .build();
    }

    @Bean(name = "chatClientClassifier")
    @ConditionalOnProperty(value = "app.ai.router.classifier.enabled", havingValue = "true", matchIfMissing = true)
    ChatClient chatClientClassifier(ChatClient.Builder builder,
                                     @Value("${app.ai.router.classifier.model:deepseek-v4-flash}") String classifierModel,
                                     @Value("${app.ai.router.classifier.max-tokens:8}") int maxTokens,
                                     @Value("${app.ai.router.classifier.timeout-ms:1500}") long timeoutMs) {
        return builder.clone()
                .defaultOptions(OpenAiChatOptions.builder()
                        .model(classifierModel)
                        .maxTokens(maxTokens)
                        .temperature(0.0)
                        .timeout(Duration.ofMillis(timeoutMs)))
                .defaultSystem("Clasificador de complejidad de prompts. Respondes UNA sola palabra: CHEAP o EXPENSIVE. Nada mas.")
                .build();
    }
}