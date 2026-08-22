package com.isc.bb.sysbase_agent.controller;

import java.security.Principal;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.isc.bb.sysbase_agent.approval.ApprovalRequest;
import com.isc.bb.sysbase_agent.approval.ApprovalService;

/**
 * Endpoints de aprobación humana (HITL) para tools de escritura. Solo ADMIN.
 * {@code @PreAuthorize} a nivel de clase es defensa en profundidad: la regla real
 * hoy vive en {@code SecurityConfig} (`/v1/admin/**` → hasRole("ADMIN")), pero si
 * ese path cambiara este controller seguiría protegido.
 */
@RestController
@RequestMapping("/v1/admin/approvals")
@PreAuthorize("hasRole('ADMIN')")
public class ApprovalController {

    private final ApprovalService approvals;

    public ApprovalController(ApprovalService approvals) {
        this.approvals = approvals;
    }

    @GetMapping
    public List<ApprovalRequest> pending() {
        return approvals.listPending();
    }

    @PostMapping("/{id}/approve")
    public ApprovalRequest approve(@PathVariable long id, Principal principal) {
        return approvals.approve(id, principal.getName());
    }

    @PostMapping("/{id}/reject")
    public ApprovalRequest reject(@PathVariable long id, Principal principal) {
        return approvals.reject(id, principal.getName());
    }

    @ResponseStatus(HttpStatus.CONFLICT)
    @org.springframework.web.bind.annotation.ExceptionHandler(IllegalStateException.class)
    public String conflict(IllegalStateException e) {
        return e.getMessage();
    }
}
