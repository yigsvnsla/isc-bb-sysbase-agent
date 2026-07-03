package com.isc.bb.sysbase_agent.documentation.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.isc.bb.sysbase_agent.documentation.adapter.DocusaurusPublisher;
import com.isc.bb.sysbase_agent.documentation.port.DocumentPublisher;

@Configuration
public class DocumentationConfig {

    @Bean
    public DocumentPublisher documentPublisher(
            @Value("${app.docs.docusaurus.path:.container/docs}") String docsPath,
            @Value("${app.docs.docusaurus.site-path:.container/docusaurus}") String sitePath) {
        return new DocusaurusPublisher(docsPath, sitePath);
    }
}
