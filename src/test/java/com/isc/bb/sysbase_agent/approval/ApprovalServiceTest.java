package com.isc.bb.sysbase_agent.approval;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyBoolean;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Instant;
import java.util.Map;

import org.junit.jupiter.api.Test;
import org.springframework.ai.tool.ToolCallback;

import com.isc.bb.sysbase_agent.audit.AuditRepository;

import io.micrometer.core.instrument.simple.SimpleMeterRegistry;

/**
 * Cubre las ramas de {@link ApprovalService#approve} que IndexProcedureE2ETest
 * (feliz + reject) no ejerce: tool de escritura no registrada, y tool que
 * lanza una excepción en la ejecución real.
 */
class ApprovalServiceTest {

    private static ApprovalRequest pendingRequest(long id, String toolName) {
        return new ApprovalRequest(id, toolName, "{}", "requester", "PENDING",
                Instant.now(), null, null, null, null, null);
    }

    @Test
    void approve_unregisteredTool_autoRejectsWithoutExecuting() {
        var approvals = mock(ApprovalRepository.class);
        var audit = mock(AuditRepository.class);
        var meters = new SimpleMeterRegistry();
        var req = pendingRequest(1L, "unknown_tool");
        when(approvals.requirePending(1L)).thenReturn(req);
        when(approvals.get(1L)).thenReturn(new ApprovalRequest(1L, "unknown_tool", "{}", "requester",
                "REJECTED", Instant.now(), Instant.now(), "admin", null, null,
                "Tool de escritura no registrada: unknown_tool"));

        var service = new ApprovalService(approvals, audit, meters, Map.of());
        var result = service.approve(1L, "admin");

        assertThat(result.status()).isEqualTo("REJECTED");
        assertThat(result.error()).contains("no registrada");
        verify(approvals).decide(1L, "REJECTED", "admin", null, null,
                "Tool de escritura no registrada: unknown_tool");
        verify(audit, never()).recordTool(any(), any(), anyString(), anyString(), anyString(), anyBoolean(), anyInt(), any());
    }

    @Test
    void approve_toolThrows_marksApprovedButResultNotOk() {
        var approvals = mock(ApprovalRepository.class);
        var audit = mock(AuditRepository.class);
        var meters = new SimpleMeterRegistry();
        var req = pendingRequest(2L, "index_procedure");
        when(approvals.requirePending(2L)).thenReturn(req);
        when(approvals.get(2L)).thenReturn(new ApprovalRequest(2L, "index_procedure", "{}", "requester",
                "APPROVED", Instant.now(), Instant.now(), "admin", null, false, "boom"));

        var failingTool = mock(ToolCallback.class);
        when(failingTool.call(anyString())).thenThrow(new RuntimeException("boom"));

        var service = new ApprovalService(approvals, audit, meters, Map.of("index_procedure", failingTool));
        var result = service.approve(2L, "admin");

        assertThat(result.status()).isEqualTo("APPROVED");
        assertThat(result.resultOk()).isFalse();
        assertThat(result.error()).isEqualTo("boom");
        verify(approvals).decide(2L, "APPROVED", "admin", null, false, "boom");
        verify(audit).recordTool(any(), any(), org.mockito.ArgumentMatchers.eq("admin"),
                org.mockito.ArgumentMatchers.eq("index_procedure"), anyString(), org.mockito.ArgumentMatchers.eq(false),
                anyInt(), org.mockito.ArgumentMatchers.eq("boom"));
    }

    @Test
    void approve_toolSucceeds_marksApprovedWithResult() {
        var approvals = mock(ApprovalRepository.class);
        var audit = mock(AuditRepository.class);
        var meters = new SimpleMeterRegistry();
        var req = pendingRequest(3L, "index_procedure");
        when(approvals.requirePending(3L)).thenReturn(req);
        when(approvals.get(3L)).thenReturn(new ApprovalRequest(3L, "index_procedure", "{}", "requester",
                "APPROVED", Instant.now(), Instant.now(), "admin", "indexado correctamente", true, null));

        var okTool = mock(ToolCallback.class);
        when(okTool.call(anyString())).thenReturn("indexado correctamente");

        var service = new ApprovalService(approvals, audit, meters, Map.of("index_procedure", okTool));
        var result = service.approve(3L, "admin");

        assertThat(result.resultOk()).isTrue();
        assertThat(result.result()).isEqualTo("indexado correctamente");
        verify(approvals).decide(3L, "APPROVED", "admin", "indexado correctamente", true, null);
    }

    @Test
    void reject_delegatesToRepositoryAndAudits() {
        var approvals = mock(ApprovalRepository.class);
        var audit = mock(AuditRepository.class);
        var meters = new SimpleMeterRegistry();
        var req = pendingRequest(4L, "index_procedure");
        when(approvals.requirePending(4L)).thenReturn(req);
        when(approvals.get(4L)).thenReturn(new ApprovalRequest(4L, "index_procedure", "{}", "requester",
                "REJECTED", Instant.now(), Instant.now(), "admin", null, null, null));

        var service = new ApprovalService(approvals, audit, meters, Map.of());
        var result = service.reject(4L, "admin");

        assertThat(result.status()).isEqualTo("REJECTED");
        verify(approvals).decide(4L, "REJECTED", "admin", null, null, null);
        verify(audit).recordTool(any(), any(), org.mockito.ArgumentMatchers.eq("admin"),
                org.mockito.ArgumentMatchers.eq("index_procedure"), anyString(), org.mockito.ArgumentMatchers.eq(false),
                org.mockito.ArgumentMatchers.eq(0), org.mockito.ArgumentMatchers.eq("approval_rejected:4"));
    }

    @Test
    void approveOrReject_onNonPendingRequest_propagatesIllegalState() {
        var approvals = mock(ApprovalRepository.class);
        var audit = mock(AuditRepository.class);
        var meters = new SimpleMeterRegistry();
        when(approvals.requirePending(5L))
                .thenThrow(new IllegalStateException("Solicitud 5 no está pendiente (estado: REJECTED)"));

        var service = new ApprovalService(approvals, audit, meters, Map.of());

        assertThatThrownBy(() -> service.approve(5L, "admin"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("no está pendiente");
        assertThatThrownBy(() -> service.reject(5L, "admin"))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("no está pendiente");
    }
}
