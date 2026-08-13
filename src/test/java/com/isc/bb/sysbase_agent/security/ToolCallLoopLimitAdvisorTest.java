package com.isc.bb.sysbase_agent.security;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.ArrayList;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.ai.chat.client.ChatClientRequest;
import org.springframework.ai.chat.client.ChatClientResponse;
import org.springframework.ai.chat.client.advisor.api.CallAdvisorChain;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.ToolResponseMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.prompt.Prompt;

class ToolCallLoopLimitAdvisorTest {

    private final ToolCallLoopLimitAdvisor advisor = new ToolCallLoopLimitAdvisor(3);

    private final CallAdvisorChain passthrough = new CallAdvisorChain() {
        @Override
        public ChatClientResponse nextCall(ChatClientRequest r) {
            return null;
        }

        @Override
        public List<org.springframework.ai.chat.client.advisor.api.CallAdvisor> getCallAdvisors() {
            return List.of();
        }

        @Override
        public CallAdvisorChain copy(org.springframework.ai.chat.client.advisor.api.CallAdvisor advisor) {
            return this;
        }
    };
    private ChatClientRequest requestWith(List<Message> msgs) {
        return ChatClientRequest.builder().prompt(new Prompt(msgs)).build();
    }

    private AssistantMessage toolCallMessage() {
        return AssistantMessage.builder()
                .content("")
                .toolCalls(List.of(
                        new AssistantMessage.ToolCall("call_1", "loop_probe", "{}", "{}")))
                .build();
    }

    private ToolResponseMessage toolResponse(String id) {
        return ToolResponseMessage.builder()
                .responses(List.of(new ToolResponseMessage.ToolResponse(id, "ok", "ok")))
                .build();
    }

    @Test
    void belowLimit_passes() {
        var msgs = new ArrayList<Message>();
        msgs.add(new SystemMessage("s"));
        msgs.add(new UserMessage("hola"));
        msgs.add(toolCallMessage());
        msgs.add(toolResponse("call_1"));
        assertThat(advisor.adviseCall(requestWith(msgs), passthrough)).isNull();
    }

    @Test
    void overLimit_throwsSecurityException() {
        var msgs = new ArrayList<Message>();
        msgs.add(new SystemMessage("s"));
        msgs.add(new UserMessage("hola"));
        for (int i = 0; i < 4; i++) {
            msgs.add(toolCallMessage());
            msgs.add(toolResponse("call_" + i));
        }
        assertThatThrownBy(() -> advisor.adviseCall(requestWith(msgs), passthrough))
                .isInstanceOf(SecurityException.class)
                .hasMessageContaining("iteraciones");
    }

    @Test
    void previousTurnsToolCalls_doNotCountTowardCurrentTurn() {
        var msgs = new ArrayList<Message>();
        msgs.add(new SystemMessage("s"));
        msgs.add(new UserMessage("turno-1"));
        msgs.add(toolCallMessage());
        msgs.add(toolResponse("c1"));
        msgs.add(toolCallMessage());
        msgs.add(toolResponse("c2"));
        msgs.add(new UserMessage("turno-2"));
        msgs.add(toolCallMessage());
        msgs.add(toolCallMessage());
        msgs.add(toolCallMessage());
        // Turno actual: 3 tool calls con límite 3 → corte (3 >= 3).
        assertThatThrownBy(() -> advisor.adviseCall(requestWith(msgs), passthrough))
                .isInstanceOf(SecurityException.class)
                .hasMessageContaining("iteraciones");
    }
}
