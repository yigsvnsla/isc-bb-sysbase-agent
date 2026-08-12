package com.isc.bb.sysbase_agent.audit;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

class AuditPurgeJobTest {

    @Test
    void purgeUsesRetentionDaysCutoff() {
        var repo = mock(AuditRepository.class);
        var job = new AuditPurgeJob(repo, 90);
        var before = Instant.now();

        job.purgeOldEvents();

        var captor = ArgumentCaptor.forClass(Instant.class);
        verify(repo).purgeBefore(captor.capture());
        var cutoff = captor.getValue();
        assertThat(cutoff).isBefore(before);
        assertThat(Instant.now().minus(90, ChronoUnit.DAYS))
                .isBetween(cutoff.minusSeconds(5), cutoff.plusSeconds(5));
    }
}
