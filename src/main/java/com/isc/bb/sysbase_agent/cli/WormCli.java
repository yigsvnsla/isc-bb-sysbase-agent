package com.isc.bb.sysbase_agent.cli;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.shell.core.command.annotation.Command;
import org.springframework.shell.core.command.annotation.Option;
import org.springframework.stereotype.Component;

import com.isc.bb.sysbase_agent.audit.AuditWormExportService;

@Component
public class WormCli {

    private final AuditWormExportService worm;
    private final long retentionDays;

    public WormCli(AuditWormExportService worm,
                   @Value("${app.audit.retention-days:90}") long retentionDays) {
        this.worm = worm;
        this.retentionDays = retentionDays;
    }

    @Command(name = "worm-export", description = "Exporta los eventos de auditoría pendientes a un chunk WORM (hash chain)")
    public String wormExport(@Option(defaultValue = "0") long days) {
        try {
            var cutoff = days > 0
                    ? Instant.now().minus(days, ChronoUnit.DAYS)
                    : Instant.now().minus(retentionDays, ChronoUnit.DAYS);
            int exported = worm.exportPending(cutoff);
            return exported > 0
                    ? "Export WORM completado: " + exported + " eventos"
                    : "Sin eventos pendientes de exportar.";
        } catch (Exception e) {
            return "Error en export WORM: " + e.getMessage();
        }
    }

    @Command(name = "worm-verify", description = "Verifica la integridad de la cadena de hashes de todos los chunks WORM")
    public String wormVerify() {
        try {
            var result = worm.verify();
            if (result.ok()) {
                return "WORM íntegro: " + result.chunks() + " chunks, " + result.lines() + " líneas verificadas";
            }
            return "INTEGRIDAD WORM COMPROMETIDA:\n" + String.join("\n", result.problems());
        } catch (Exception e) {
            return "Error verificando WORM: " + e.getMessage();
        }
    }
}
