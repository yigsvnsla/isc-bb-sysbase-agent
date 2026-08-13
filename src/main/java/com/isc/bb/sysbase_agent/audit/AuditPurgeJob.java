package com.isc.bb.sysbase_agent.audit;

import java.time.Instant;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class AuditPurgeJob {

    private static final Logger log = LoggerFactory.getLogger(AuditPurgeJob.class);

    private static final DateTimeFormatter PARTITION_SUFFIX =
            DateTimeFormatter.ofPattern("yyyy_MM");

    private final AuditRepository audit;
    private final long retentionDays;
    private final boolean partitionDropEnabled;

    public AuditPurgeJob(AuditRepository audit,
                         @Value("${app.audit.retention-days:90}") long retentionDays,
                         @Value("${app.audit.partition-drop-enabled:true}") boolean partitionDropEnabled) {
        this.audit = audit;
        this.retentionDays = retentionDays;
        this.partitionDropEnabled = partitionDropEnabled;
    }

    @Scheduled(cron = "${app.audit.purge-cron:0 0 3 * * *}")
    public void purgeOldEvents() {
        try {
            var cutoff = Instant.now().minus(retentionDays, ChronoUnit.DAYS);
            int deleted = audit.purgeBefore(cutoff);
            log.info("Purge ai_audit: {} eventos anteriores a {}", deleted, cutoff);
            if (partitionDropEnabled) {
                int dropped = dropFullyExpiredPartitions(cutoff);
                if (dropped > 0) {
                    log.info("Purge ai_audit: {} particiones mensuales eliminadas", dropped);
                }
            }
        } catch (Exception e) {
            log.error("Fallo purge ai_audit", e);
        }
    }

    /**
     * Elimina particiones mensuales cuyo rango completo terminó antes del cutoff,
     * solo si no queda ningún evento sin exportar (integridad WORM).
     */
    int dropFullyExpiredPartitions(Instant cutoff) {
        if (!audit.isPartitioned() || audit.hasUnexportedBefore(cutoff)) {
            return 0;
        }
        int dropped = 0;
        for (var name : audit.partitionNames()) {
            var monthEnd = monthEndFromName(name);
            if (monthEnd != null && monthEnd.isBefore(cutoff)) {
                audit.dropPartition(name);
                dropped++;
            }
        }
        return dropped;
    }

    private Instant monthEndFromName(String partitionName) {
        try {
            var suffix = partitionName.replaceFirst("^ai_audit_", "");
            var month = YearMonth.parse(suffix, PARTITION_SUFFIX);
            return month.plusMonths(1).atDay(1).atStartOfDay().toInstant(java.time.ZoneOffset.UTC);
        } catch (Exception e) {
            return null;
        }
    }
}
