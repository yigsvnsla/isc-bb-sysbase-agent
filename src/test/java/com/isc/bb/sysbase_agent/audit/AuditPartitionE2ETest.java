package com.isc.bb.sysbase_agent.audit;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;

/** Ciclo completo de particionado mensual sobre PG real (Testcontainers, schema particionado). */
class AuditPartitionE2ETest extends AbstractIntegrationTest {

    @Autowired
    AuditRepository audit;

    @Autowired
    JdbcTemplate jdbc;

    @Test
    void monthlyPartitionLifecycle_createInsertDrop() {
        assertThat(audit.isPartitioned()).isTrue();

        var oldMonth = YearMonth.now().minusMonths(3);
        audit.ensureMonthlyPartition(oldMonth);
        assertThat(audit.partitionNames()).contains("ai_audit_" + AuditRepository.monthSuffix(oldMonth));

        jdbc.update("INSERT INTO ai_audit (event_type, event_ts, user_id) VALUES ('TURN', ?, 'part-old')",
                java.sql.Timestamp.from(oldMonth.atDay(10).atStartOfDay().toInstant(java.time.ZoneOffset.UTC)));
        jdbc.update("UPDATE ai_audit SET worm_exported_at = now() WHERE user_id = 'part-old'");

        var cutoff = Instant.now().minus(60, ChronoUnit.DAYS);
        assertThat(audit.purgeBefore(cutoff)).isGreaterThanOrEqualTo(1);

        var job = new AuditPurgeJob(audit, 90, true);
        var dropped = job.dropFullyExpiredPartitions(cutoff);
        assertThat(dropped).isGreaterThanOrEqualTo(1);
        assertThat(audit.partitionNames())
                .doesNotContain("ai_audit_" + AuditRepository.monthSuffix(oldMonth));

        var recentMonth = YearMonth.now();
        audit.ensureMonthlyPartition(recentMonth);
        assertThat(audit.partitionNames()).contains("ai_audit_" + AuditRepository.monthSuffix(recentMonth));
    }
}
