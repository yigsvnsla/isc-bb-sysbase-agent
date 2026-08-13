package com.isc.bb.sysbase_agent.audit;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

class AuditPurgeJobTest {

    @Test
    void purgeUsesRetentionDaysCutoff() {
        var repo = mock(AuditRepository.class);
        when(repo.isPartitioned()).thenReturn(false);
        var job = new AuditPurgeJob(repo, 90, true);
        var before = Instant.now();

        job.purgeOldEvents();

        var captor = ArgumentCaptor.forClass(Instant.class);
        verify(repo).purgeBefore(captor.capture());
        var cutoff = captor.getValue();
        assertThat(cutoff).isBefore(before);
        assertThat(Instant.now().minus(90, ChronoUnit.DAYS))
                .isBetween(cutoff.minusSeconds(5), cutoff.plusSeconds(5));
    }

    @Test
    void dropsPartitions_onlyWhenAllExportedAndRangeExpired() {
        var repo = mock(AuditRepository.class);
        when(repo.isPartitioned()).thenReturn(true);
        when(repo.hasUnexportedBefore(any())).thenReturn(false);
        when(repo.partitionNames()).thenReturn(List.of("ai_audit_2026_01", "ai_audit_2026_08", "otra_cosa"));
        var job = new AuditPurgeJob(repo, 90, true);

        var dropped = job.dropFullyExpiredPartitions(Instant.now());

        assertThat(dropped).isEqualTo(1);
        verify(repo).dropPartition("ai_audit_2026_01");
        verify(repo, never()).dropPartition("ai_audit_2026_08");
        verify(repo, never()).dropPartition("otra_cosa");
    }

    @Test
    void doesNotDrop_whenUnexportedEventsRemain() {
        var repo = mock(AuditRepository.class);
        when(repo.isPartitioned()).thenReturn(true);
        when(repo.hasUnexportedBefore(any())).thenReturn(true);
        when(repo.partitionNames()).thenReturn(List.of("ai_audit_2026_01"));
        var job = new AuditPurgeJob(repo, 90, true);

        assertThat(job.dropFullyExpiredPartitions(Instant.now())).isZero();
        verify(repo, never()).dropPartition(any());
    }
}
