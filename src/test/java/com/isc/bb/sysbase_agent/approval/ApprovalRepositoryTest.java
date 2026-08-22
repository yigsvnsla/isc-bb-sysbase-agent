package com.isc.bb.sysbase_agent.approval;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;

/** create/get/listPending/decide/requirePending contra Postgres real (sin mocks). */
class ApprovalRepositoryTest extends AbstractIntegrationTest {

    @Autowired
    ApprovalRepository repository;

    @Autowired
    JdbcTemplate jdbc;

    @Test
    void create_thenGet_roundTrips() {
        var created = repository.create("repo_tool", "{\"a\":1}", "repo-tester");

        assertThat(created.id()).isNotNull();
        assertThat(created.toolName()).isEqualTo("repo_tool");
        assertThat(created.requester()).isEqualTo("repo-tester");
        assertThat(created.status()).isEqualTo("PENDING");
        assertThat(created.pending()).isTrue();

        var fetched = repository.get(created.id());
        assertThat(fetched).isEqualTo(created);
    }

    @Test
    void listPending_ordersByCreatedAtThenId_andExcludesDecided() {
        jdbc.update("DELETE FROM approval_requests");

        var first = repository.create("repo_tool_a", "{}", "tester");
        var second = repository.create("repo_tool_b", "{}", "tester");
        repository.decide(second.id(), "APPROVED", "admin", "ok", true, null);
        var third = repository.create("repo_tool_c", "{}", "tester");

        var pending = repository.listPending();

        assertThat(pending).extracting(ApprovalRequest::id).containsExactly(first.id(), third.id());
    }

    @Test
    void requirePending_onAlreadyDecidedRequest_throws() {
        var req = repository.create("repo_tool_d", "{}", "tester");
        repository.decide(req.id(), "REJECTED", "admin", null, null, null);

        assertThatThrownBy(() -> repository.requirePending(req.id()))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("no está pendiente")
                .hasMessageContaining("REJECTED");
    }

    @Test
    void decide_persistsResultAndDecidedBy() {
        var req = repository.create("repo_tool_e", "{}", "tester");

        repository.decide(req.id(), "APPROVED", "the-admin", "done", true, null);
        var decided = repository.get(req.id());

        assertThat(decided.status()).isEqualTo("APPROVED");
        assertThat(decided.decidedBy()).isEqualTo("the-admin");
        assertThat(decided.result()).isEqualTo("done");
        assertThat(decided.resultOk()).isTrue();
        assertThat(decided.decidedAt()).isNotNull();
        assertThat(decided.pending()).isFalse();
    }
}
