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
    error TEXT
);

CREATE INDEX IF NOT EXISTS idx_ai_audit_ts ON ai_audit (event_ts DESC);
CREATE INDEX IF NOT EXISTS idx_ai_audit_user ON ai_audit (user_id);
CREATE INDEX IF NOT EXISTS idx_ai_audit_tool ON ai_audit (tool_name);
