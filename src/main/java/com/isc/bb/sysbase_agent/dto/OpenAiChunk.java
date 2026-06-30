package com.isc.bb.sysbase_agent.dto;

import java.util.List;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;

public record OpenAiChunk(
    String id,
    String object,
    long created,
    String model,
    List<Choice> choices
) {
    public record Choice(
        int index,
        Delta delta,
        @JsonInclude(Include.NON_NULL) String finish_reason
    ) {}
    public record Delta(
        @JsonInclude(Include.NON_NULL) String role,
        @JsonInclude(Include.NON_NULL) String content
    ) {}
}
