package com.isc.bb.sysbase_agent.cli;

import org.springframework.shell.core.command.annotation.Command;
import org.springframework.shell.core.command.annotation.Option;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.audit.AuditEvent;
import com.isc.bb.sysbase_agent.audit.AuditRepository;

@Component
public class AuditCli {

    private final AuditRepository audit;

    public AuditCli(AuditRepository audit) {
        this.audit = audit;
    }

    @Command(name = "audit-tail", description = "Últimos eventos de auditoría (TURN/TOOL/AUTH)")
    public String tail(@Option(longName = "limit", description = "Número de eventos (default 20)") Integer limit) {
        var events = audit.tail(limit != null ? limit : 20);
        return format(events);
    }

    @Command(name = "audit-search", description = "Busca eventos de auditoría por tool, usuario o tipo")
    public String search(
            @Option(longName = "tool", description = "Filtro por nombre de tool") String tool,
            @Option(longName = "user", description = "Filtro por usuario") String user,
            @Option(longName = "type", description = "TURN | TOOL | AUTH") String type,
            @Option(longName = "limit", description = "Límite (default 50)") Integer limit) {
        return format(audit.search(tool, user, type, limit != null ? limit : 50));
    }

    private String format(java.util.List<AuditEvent> events) {
        if (events.isEmpty()) {
            return "Sin eventos.";
        }
        var sb = new StringBuilder();
        for (var e : events) {
            sb.append(String.format("#%d %s %s user=%s", e.id(), e.eventType(), e.eventTs(), e.userId()));
            if (e.tier() != null) sb.append(" tier=").append(e.tier());
            if (e.toolName() != null) sb.append(" tool=").append(e.toolName()).append(" ok=").append(e.toolOk());
            if (e.authMethod() != null) sb.append(" method=").append(e.authMethod()).append(" ok=").append(e.authOk());
            if (e.latencyMs() != null) sb.append(" ms=").append(e.latencyMs());
            if (e.error() != null) sb.append(" error=").append(e.error());
            sb.append('\n');
        }
        return sb.toString();
    }
}
