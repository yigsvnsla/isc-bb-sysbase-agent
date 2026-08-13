package com.isc.bb.sysbase_agent.approval;

import java.time.Instant;

/** Solicitud de aprobación humana para una tool de escritura (HITL). */
public record ApprovalRequest(
        Long id,
        String toolName,
        String args,
        String requester,
        String status,
        Instant createdAt,
        Instant decidedAt,
        String decidedBy,
        String result,
        Boolean resultOk,
        String error) {

    public boolean pending() {
        return "PENDING".equals(status);
    }
}
