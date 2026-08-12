package com.isc.bb.sysbase_agent.e2e;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;

import com.isc.bb.sysbase_agent.AbstractIntegrationTest;
import com.isc.bb.sysbase_agent.audit.AuditRepository;

@AutoConfigureTestRestTemplate
@Tag("load")
class LoadE2ETest extends AbstractIntegrationTest {

    private static final int CONVS = 100;
    private static final int MSGS_PER_CONV = 3;
    private static final int THREADS = 20;

    @Autowired
    TestRestTemplate rest;

    @Autowired
    AuditRepository audit;

    @Test
    void cienConversacionesConcurrentes_estables() throws Exception {
        var pool = Executors.newFixedThreadPool(THREADS);
        var latch = new CountDownLatch(CONVS * MSGS_PER_CONV);
        var latencies = Collections.synchronizedList(new ArrayList<Long>());
        var failures = Collections.synchronizedList(new ArrayList<String>());

        for (int c = 0; c < CONVS; c++) {
            final int ci = c;
            pool.submit(() -> {
                var headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_JSON);
                headers.setBearerAuth(tokenService.issue("load-u" + ci, "READONLY"));
                var body = """
                        {"conversationId":"load-%d","message":"hola"}
                        """.formatted(ci);
                for (int m = 0; m < MSGS_PER_CONV; m++) {
                    long t0 = System.nanoTime();
                    try {
                        var resp = rest.postForEntity("/v1/agent/chat",
                                new HttpEntity<>(body, headers), String.class);
                        latencies.add((System.nanoTime() - t0) / 1_000_000);
                        if (!resp.getStatusCode().is2xxSuccessful()) {
                            failures.add("conv " + ci + " msg " + m + " -> " + resp.getStatusCode());
                        }
                    } catch (Exception e) {
                        failures.add("conv " + ci + " msg " + m + " ex " + e.getMessage());
                    } finally {
                        latch.countDown();
                    }
                }
            });
        }

        assertThat(latch.await(180, TimeUnit.SECONDS))
                .as("carga debe completar en 180s").isTrue();
        pool.shutdown();

        assertThat(failures).as("cero fallos HTTP: %s", failures).isEmpty();

        var sorted = latencies.stream().sorted().toList();
        long p50 = sorted.get(sorted.size() / 2);
        long p95 = sorted.get(Math.max(0, (int) Math.ceil(0.95 * sorted.size()) - 1));
        long max = sorted.get(sorted.size() - 1);
        System.out.printf("LOAD: n=%d p50=%dms p95=%dms max=%dms%n",
                sorted.size(), p50, p95, max);
        // p95 incluye espera en cola del harness (300 req / 20 threads); servicio estable en p50 ~475ms.
        assertThat(p95).as("p95 bajo carga < 12s (cola de harness incluida)").isLessThan(12_000L);

        var turns = audit.search(null, null, "TURN", 500);
        long cacheHits = turns.stream()
                .filter(t -> "cache-hit".equals(t.routerReason()))
                .count();
        System.out.printf("LOAD: turns=%d cacheHits=%d%n", turns.size(), cacheHits);
        assertThat(cacheHits).as("cache del router activo bajo carga").isGreaterThan(50);
    }
}
