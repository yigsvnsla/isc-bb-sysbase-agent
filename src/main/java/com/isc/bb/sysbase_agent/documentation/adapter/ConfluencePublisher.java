package com.isc.bb.sysbase_agent.documentation.adapter;

import java.util.List;
import java.util.Optional;

import com.isc.bb.sysbase_agent.documentation.model.DocumentContent;
import com.isc.bb.sysbase_agent.documentation.model.DocumentMeta;
import com.isc.bb.sysbase_agent.documentation.model.PublishResult;
import com.isc.bb.sysbase_agent.documentation.port.DocumentPublisher;

public class ConfluencePublisher implements DocumentPublisher {

    @Override
    public PublishResult publish(DocumentContent content) {
        return PublishResult.fail(content.meta().id(), "Confluence adapter not yet implemented");
    }

    @Override
    public PublishResult update(String docId, DocumentContent content) {
        return PublishResult.fail(docId, "Confluence adapter not yet implemented");
    }

    @Override
    public boolean exists(String docId) {
        return false;
    }

    @Override
    public Optional<DocumentMeta> findById(String docId) {
        return Optional.empty();
    }

    @Override
    public List<DocumentMeta> listByCategory(String category) {
        return List.of();
    }

    @Override
    public PublishResult buildIndex() {
        return PublishResult.fail("index", "Confluence adapter not yet implemented");
    }

    @Override
    public String adapterType() {
        return "confluence";
    }
}
