package com.isc.bb.sysbase_agent.cli;

import org.springframework.shell.core.command.annotation.Command;
import org.springframework.shell.core.command.annotation.Option;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.approval.ApprovalService;

/** Operación manual de la cola de aprobación HITL (el shell tiene confianza total). */
@Component
public class ApprovalCli {

    private final ApprovalService approvals;

    public ApprovalCli(ApprovalService approvals) {
        this.approvals = approvals;
    }

    @Command(name = "approvals-list", description = "Lista las solicitudes de escritura pendientes de aprobación (HITL)")
    public String list() {
        var pending = approvals.listPending();
        if (pending.isEmpty()) {
            return "Sin solicitudes pendientes.";
        }
        var sb = new StringBuilder("Solicitudes pendientes:\n");
        for (var r : pending) {
            sb.append("#").append(r.id()).append(" ").append(r.toolName())
                    .append(" args=").append(r.args())
                    .append(" por=").append(r.requester())
                    .append(" creada=").append(r.createdAt()).append("\n");
        }
        return sb.toString();
    }

    @Command(name = "approvals-approve", description = "Aprueba y ejecuta una solicitud pendiente")
    public String approve(@Option(required = true) long id) {
        try {
            var req = approvals.approve(id, "shell");
            var ok = Boolean.TRUE.equals(req.resultOk());
            return "Aprobada #" + id + " → " + req.status()
                    + (ok ? " resultado: " + req.result() : " falló: " + req.error());
        } catch (Exception e) {
            return "Error aprobando #" + id + ": " + e.getMessage();
        }
    }

    @Command(name = "approvals-reject", description = "Rechaza una solicitud pendiente")
    public String reject(@Option(required = true) long id) {
        try {
            approvals.reject(id, "shell");
            return "Rechazada #" + id;
        } catch (Exception e) {
            return "Error rechazando #" + id + ": " + e.getMessage();
        }
    }
}
