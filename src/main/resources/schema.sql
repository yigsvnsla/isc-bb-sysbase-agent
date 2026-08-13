CREATE TABLE IF NOT EXISTS api_keys (
    id BIGSERIAL PRIMARY KEY,
    key_hash CHAR(64) NOT NULL UNIQUE,
    name TEXT NOT NULL,
    role TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS ai_audit (
    id BIGSERIAL PRIMARY KEY,
    event_type TEXT NOT NULL,
    event_ts TIMESTAMPTZ NOT NULL DEFAULT now(),
    trace_id TEXT,
    session_id TEXT,
    user_id TEXT,
    channel TEXT,
    tier TEXT,
    router_score NUMERIC,
    router_reason TEXT,
    cache_hit BOOLEAN,
    prompt_hash TEXT,
    prompt_truncated TEXT,
    response_hash TEXT,
    latency_ms INT,
    tool_name TEXT,
    tool_args JSONB,
    tool_ok BOOLEAN,
    auth_method TEXT,
    auth_ok BOOLEAN,
    error TEXT,
    worm_exported_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_ai_audit_worm ON ai_audit (worm_exported_at) WHERE worm_exported_at IS NULL;

CREATE TABLE IF NOT EXISTS audit_worm_chunks (
    id BIGSERIAL PRIMARY KEY,
    file_name TEXT NOT NULL UNIQUE,
    first_event_id BIGINT NOT NULL,
    last_event_id BIGINT NOT NULL,
    first_event_ts TIMESTAMPTZ NOT NULL,
    last_event_ts TIMESTAMPTZ NOT NULL,
    prev_hash TEXT,
    chunk_hash TEXT NOT NULL,
    event_count INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_audit_ts ON ai_audit (event_ts DESC);
CREATE INDEX IF NOT EXISTS idx_ai_audit_user ON ai_audit (user_id);
CREATE INDEX IF NOT EXISTS idx_ai_audit_tool ON ai_audit (tool_name);

CREATE TABLE IF NOT EXISTS approval_requests (
    id BIGSERIAL PRIMARY KEY,
    tool_name TEXT NOT NULL,
    args JSONB NOT NULL,
    requester TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    decided_at TIMESTAMPTZ,
    decided_by TEXT,
    result TEXT,
    result_ok BOOLEAN,
    error TEXT
);
CREATE INDEX IF NOT EXISTS idx_approval_status ON approval_requests (status, created_at);
