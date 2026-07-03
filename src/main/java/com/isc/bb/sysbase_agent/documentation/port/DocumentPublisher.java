package com.isc.bb.sysbase_agent.documentation.port;

import java.util.List;
import java.util.Optional;

import com.isc.bb.sysbase_agent.documentation.model.DocumentContent;
import com.isc.bb.sysbase_agent.documentation.model.DocumentMeta;
import com.isc.bb.sysbase_agent.documentation.model.PublishResult;

public interface DocumentPublisher {

    PublishResult publish(DocumentContent content);

    PublishResult update(String docId, DocumentContent content);

    boolean exists(String docId);

    Optional<DocumentMeta> findById(String docId);

    List<DocumentMeta> listByCategory(String category);

    PublishResult buildIndex();

    String adapterType();
}
