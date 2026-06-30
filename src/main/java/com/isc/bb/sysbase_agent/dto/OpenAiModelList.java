package com.isc.bb.sysbase_agent.dto;

import java.util.List;

public record OpenAiModelList(String object, List<OpenAiModel> data) {
}
