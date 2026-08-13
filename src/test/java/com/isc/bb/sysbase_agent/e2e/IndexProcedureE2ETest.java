package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;
import com.isc.bb.sysbase_agent.approval.ApprovalRequest;
import com.isc.bb.sysbase_agent.approval.ApprovalService;
import com.isc.bb.sysbase_agent.audit.AuditRepository;

@AutoConfigureTestRestTemplate
class IndexProcedureE2ETest extends AbstractIntegrationTest {

    @Autowired
    TestRestTemplate rest;

    @Autowired
    ApprovalService approvals;

    @Autowired
    AuditRepository audit;

    private HttpHeaders headers(String role) {
        var h = new HttpHeaders();
        h.setContentType(MediaType.APPLICATION_JSON);
        h.setBearerAuth(tokenService.issue("e2e-" + role.toLowerCase(), role));
        return h;
    }

    @Test
    void docRole_writeTool_goesToApprovalQueue_andAdminApproves_executesTool() {
        var body = """
                {"conversationId":"e2e-index-1","message":"indexa el procedure xyz"}
                """;
        var chat = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>(body, headers("DOC")), String.class);
        assertThat(chat.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(chat.getBody()).contains("en espera de aprobación");

        var pending = rest.exchange("/v1/admin/approvals", HttpMethod.GET,
                new HttpEntity<>(headers("ADMIN")),
                new org.springframework.core.ParameterizedTypeReference<java.util.List<ApprovalRequest>>() {
                });
        assertThat(pending.getStatusCode().is2xxSuccessful()).isTrue();
        var list = pending.getBody();
        assertThat(list).isNotEmpty();
        var req = list.stream()
                .filter(r -> r.toolName().equals("index_procedure"))
                .findFirst().orElseThrow();
        assertThat(req.pending()).isTrue();
        assertThat(req.requester()).isEqualTo("e2e-doc");

        var approved = rest.postForEntity("/v1/admin/approvals/" + req.id() + "/approve",
                new HttpEntity<>(headers("ADMIN")), ApprovalRequest.class);
        assertThat(approved.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(approved.getBody().status()).isEqualTo("APPROVED");
        assertThat(approved.getBody().resultOk()).isTrue();
        assertThat(approved.getBody().result()).contains("indexado correctamente");
        assertThat(approved.getBody().decidedBy()).isEqualTo("e2e-admin");

        assertThat(audit.search("index_procedure", "e2e-doc", "TOOL", 10))
                .anyMatch(e -> e.error() != null && e.error().startsWith("approval_pending:"));
        assertThat(audit.search("index_procedure", "e2e-admin", "TOOL", 10))
                .anyMatch(e -> Boolean.TRUE.equals(e.toolOk()));
    }

    @Test
    void adminRole_canRejectPendingRequest() {
        var body = """
                {"conversationId":"e2e-index-2","message":"indexa el procedure xyz"}
                """;
        var chat = rest.postForEntity("/v1/agent/chat",
                new HttpEntity<>(body, headers("DOC")), String.class);
        assertThat(chat.getStatusCode().is2xxSuccessful()).isTrue();

        var pending = rest.exchange("/v1/admin/approvals", HttpMethod.GET,
                new HttpEntity<>(headers("ADMIN")),
                new org.springframework.core.ParameterizedTypeReference<java.util.List<ApprovalRequest>>() {
                });
        var req = pending.getBody().stream()
                .filter(r -> r.toolName().equals("index_procedure"))
                .findFirst().orElseThrow();

        var rejected = rest.postForEntity("/v1/admin/approvals/" + req.id() + "/reject",
                new HttpEntity<>(headers("ADMIN")), ApprovalRequest.class);
        assertThat(rejected.getStatusCode().is2xxSuccessful()).isTrue();
        assertThat(rejected.getBody().status()).isEqualTo("REJECTED");

        ResponseEntity<String> twice = rest.postForEntity("/v1/admin/approvals/" + req.id() + "/reject",
                new HttpEntity<>(headers("ADMIN")), String.class);
        assertThat(twice.getStatusCode().is4xxClientError()).isTrue();
    }

    @Test
    void nonAdmin_cannotListOrApprove() {
        ResponseEntity<String> list = rest.exchange("/v1/admin/approvals", HttpMethod.GET,
                new HttpEntity<>(headers("READONLY")), String.class);
        assertThat(list.getStatusCode().is4xxClientError()).isTrue();
    }
}
