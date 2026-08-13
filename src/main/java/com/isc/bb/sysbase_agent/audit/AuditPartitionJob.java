package com.isc.bb.sysbase_agent.audit;

import java.time.YearMonth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Mantenimiento de particiones mensuales de ai_audit. Como ApplicationRunner
 * asegura la partición default + mes actual al arrancar (los INSERTs fallarían
 * sin partición); el cron mantiene los próximos meses.
 */
@Component
public class AuditPartitionJob implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(AuditPartitionJob.class);

    private final AuditRepository audit;
    private final boolean enabled;

    public AuditPartitionJob(AuditRepository audit,
                             @Value("${app.audit.partition-job-enabled:true}") boolean enabled) {
        this.audit = audit;
        this.enabled = enabled;
    }

    @Override
    public void run(ApplicationArguments args) {
        ensure();
    }

    @Scheduled(cron = "${app.audit.partition-cron:0 0 1 * * *}")
    public void ensurePartitions() {
        ensure();
    }

    private void ensure() {
        if (!enabled) {
            return;
        }
        if (!audit.isPartitioned()) {
            log.warn("ai_audit no está particionada (instalación previa al particionado). "
                    + "El mantenimiento de particiones se omite; migrar manualmente para producción.");
            return;
        }
        audit.ensureDefaultPartition();
        var now = YearMonth.now();
        for (int i = 0; i < 3; i++) {
            var month = now.plusMonths(i);
            audit.ensureMonthlyPartition(month);
            log.info("Partición asegurada: ai_audit_{}", AuditRepository.monthSuffix(month));
        }
    }
}
