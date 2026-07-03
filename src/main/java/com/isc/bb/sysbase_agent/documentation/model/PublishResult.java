package com.isc.bb.sysbase_agent.documentation.model;

public record PublishResult(
        String id,
        String url,
        boolean success,
        String message) {

    public static PublishResult ok(String id, String url) {
        return new PublishResult(id, url, true, "Published: " + url);
    }

    public static PublishResult fail(String id, String error) {
        return new PublishResult(id, null, false, error);
    }
}
