package com.isc.bb.sysbase_agent.config;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Arrays;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.MessageChatMemoryAdvisor;
import org.springframework.ai.chat.memory.ChatMemory;
import org.springframework.ai.chat.memory.MessageWindowChatMemory;
import org.springframework.ai.openai.OpenAiChatOptions;
import org.springframework.ai.support.ToolCallbacks;
import org.springframework.ai.tool.ToolCallback;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.util.StreamUtils;

import io.micrometer.core.instrument.MeterRegistry;

import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.json.JsonMapper;
import com.isc.bb.sysbase_agent.audit.AuditRepository;
import com.isc.bb.sysbase_agent.memory.RedisChatMemoryRepository;
import com.isc.bb.sysbase_agent.security.AuditedToolCallback;
import com.isc.bb.sysbase_agent.security.ToolAccessGuard;
import com.isc.bb.sysbase_agent.tools.KnowledgeBaseTool;
import com.isc.bb.sysbase_agent.tools.PostgresTools;

@Configuration
public class AgentConfig {

    private static final String SYSTEM_PROMPT = loadSystemPrompt();

    private static String loadSystemPrompt() {
        try {
            return StreamUtils.copyToString(
                    new ClassPathResource("prompts/system.md").getInputStream(),
                    StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new IllegalStateException("Falta classpath:prompts/system.md", e);
        }
    }

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
    ToolCallback[] agentToolCallbacks(PostgresTools postgresTools,
                                      KnowledgeBaseTool knowledgeBaseTool,
                                      ToolAccessGuard guard,
                                      AuditRepository audit,
                                      ObjectMapper objectMapper,
                                      MeterRegistry meters) {
        return Arrays.stream(ToolCallbacks.from(postgresTools, knowledgeBaseTool))
                .map(tc -> new AuditedToolCallback(tc, guard, audit, objectMapper, meters))
                .toArray(ToolCallback[]::new);
    }

    @Bean(name = "chatClientCheap")
    ChatClient chatClientCheap(ChatClient.Builder builder,
                               ToolCallback[] toolCallbacks,
                               ChatMemory chatMemory,
                               @Value("${app.ai.router.cheap-model:deepseek-v4-flash}") String cheapModel) {
        return configureClient(builder, toolCallbacks, chatMemory, cheapModel);
    }

    @Bean(name = "chatClientExpensive")
    ChatClient chatClientExpensive(ChatClient.Builder builder,
                                   ToolCallback[] toolCallbacks,
                                   ChatMemory chatMemory,
                                   @Value("${app.ai.router.expensive-model:deepseek-v4-pro}") String expensiveModel) {
        return configureClient(builder, toolCallbacks, chatMemory, expensiveModel);
    }

    private ChatClient configureClient(ChatClient.Builder builder,
                                       ToolCallback[] toolCallbacks,
                                       ChatMemory chatMemory,
                                       String model) {
        return builder.clone()
                .defaultOptions(OpenAiChatOptions.builder().model(model))
                .defaultSystem(SYSTEM_PROMPT)
                .defaultAdvisors(MessageChatMemoryAdvisor.builder(chatMemory).build())
                .defaultTools((Object[]) toolCallbacks)
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