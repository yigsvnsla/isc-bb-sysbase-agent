package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;
import com.isc.bb.sysbase_agent.audit.AuditRepository;

@AutoConfigureTestRestTemplate
class IndexProcedureE2ETest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Autowired
    AuditRepository audit;

    @Test
    void docRole_indexProcedure_executesToolAndAuditsOk() {
        var headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(tokenService.issue("e2e-doc", "DOC"));

        var body = """
                {"conversationId":"e2e-index-1","message":"indexa el procedure xyz"}
                """;
        var resp = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>(body, headers), String.class);

        assertThat(resp.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(resp.getBody()).contains("indexado correctamente");
        assertThat(audit.search("index_procedure", "e2e-doc", "TOOL", 10))
                .anyMatch(e -> Boolean.TRUE.equals(e.toolOk()));
    }
}
