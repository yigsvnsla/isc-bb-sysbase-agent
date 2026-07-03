package com.isc.bb.sysbase_agent.documentation.indexer;

import java.util.ArrayList;
import java.util.List;

public record IndexResult(
        int generated,
        int updated,
        int skipped,
        int errors,
        List<String> details) {

    public IndexResult {
        if (details == null) details = new ArrayList<>();
    }

    public static IndexResult empty() {
        return new IndexResult(0, 0, 0, 0, new ArrayList<>());
    }

    public IndexResult addGenerated(String detail) {
        var newDetails = new ArrayList<>(details);
        newDetails.add("[GEN] " + detail);
        return new IndexResult(generated + 1, updated, skipped, errors, newDetails);
    }

    public IndexResult addUpdated(String detail) {
        var newDetails = new ArrayList<>(details);
        newDetails.add("[UPD] " + detail);
        return new IndexResult(generated, updated + 1, skipped, errors, newDetails);
    }

    public IndexResult addSkipped(String detail) {
        var newDetails = new ArrayList<>(details);
        newDetails.add("[SKIP] " + detail);
        return new IndexResult(generated, updated, skipped + 1, errors, newDetails);
    }

    public IndexResult addError(String detail) {
        var newDetails = new ArrayList<>(details);
        newDetails.add("[ERR] " + detail);
        return new IndexResult(generated, updated, skipped, errors + 1, newDetails);
    }

    public String summary() {
        return "IndexResult{generated=%d, updated=%d, skipped=%d, errors=%d}"
                .formatted(generated, updated, skipped, errors);
    }
}
