package com.isc.bb.sysbase_agent.documentation.model;

import java.util.HashMap;
import java.util.Map;

public record DocumentContent(
        DocumentMeta meta,
        String markdown,
        Map<String, Object> frontMatter) {

    public DocumentContent {
        if (meta == null) throw new IllegalArgumentException("meta is required");
        if (markdown == null || markdown.isBlank()) throw new IllegalArgumentException("markdown is required");
        if (frontMatter == null) frontMatter = new HashMap<>();
    }

    public DocumentContent(DocumentMeta meta, String markdown) {
        this(meta, markdown, new HashMap<>());
    }
}
