package com.isc.bb.sysbase_agent.router;

public record RouterDecision(Tier tier, double score, String reason) {
}