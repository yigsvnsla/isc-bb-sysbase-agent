package com.isc.bb.sysbase_agent.audit;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class AuditPurgeJob {

    private static final Logger log = LoggerFactory.getLogger(AuditPurgeJob.class);

    private final AuditRepository audit;
    private final long retentionDays;

    public AuditPurgeJob(AuditRepository audit,
                         @Value("${app.audit.retention-days:90}") long retentionDays) {
        this.audit = audit;
        this.retentionDays = retentionDays;
    }

    @Scheduled(cron = "${app.audit.purge-cron:0 0 3 * * *}")
    public void purgeOldEvents() {
        try {
            var cutoff = Instant.now().minus(retentionDays, ChronoUnit.DAYS);
            int deleted = audit.purgeBefore(cutoff);
            log.info("Purge ai_audit: {} eventos anteriores a {}", deleted, cutoff);
        } catch (Exception e) {
            log.error("Fallo purge ai_audit", e);
        }
    }

    // TODO(futuro): export CSV/Parquet antes de purgar (WORM para cumplimiento).
}
