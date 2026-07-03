package com.isc.bb.sysbase_agent.documentation.model;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Map;

public record DocumentMeta(
        String id,
        String title,
        String category,
        String parentId,
        DocumentType type,
        List<String> tags,
        String engine,
        ZonedDateTime generatedAt,
        String generatorVersion) {

    public DocumentMeta {
        if (id == null || id.isBlank()) throw new IllegalArgumentException("id is required");
        if (title == null || title.isBlank()) throw new IllegalArgumentException("title is required");
        if (category == null || category.isBlank()) throw new IllegalArgumentException("category is required");
        if (type == null) throw new IllegalArgumentException("type is required");
    }
}
