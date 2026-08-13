package com.isc.bb.sysbase_agent.approval;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.List;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Repository;

@Repository
public class ApprovalRepository {

    private static final String COLUMNS = "id, tool_name, args::text, requester, status, created_at, "
            + "decided_at, decided_by, result::text, result_ok, error";

    private final JdbcTemplate jdbc;

    public ApprovalRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public ApprovalRequest create(String toolName, String args, String requester) {
        var keyHolder = new GeneratedKeyHolder();
        jdbc.update(con -> {
            var ps = con.prepareStatement(
                    "INSERT INTO approval_requests (tool_name, args, requester) VALUES (?, ?::jsonb, ?)",
                    new String[] { "id" });
            ps.setString(1, toolName);
            ps.setString(2, args);
            ps.setString(3, requester);
            return ps;
        }, keyHolder);
        return get(keyHolder.getKey().longValue());
    }

    public ApprovalRequest get(long id) {
        return jdbc.queryForObject("SELECT " + COLUMNS + " FROM approval_requests WHERE id = ?",
                (rs, i) -> map(rs), id);
    }

    public List<ApprovalRequest> listPending() {
        return jdbc.query("SELECT " + COLUMNS + " FROM approval_requests WHERE status = 'PENDING' "
                        + "ORDER BY created_at ASC, id ASC",
                (rs, i) -> map(rs));
    }

    public ApprovalRequest requirePending(long id) {
        var req = get(id);
        if (!req.pending()) {
            throw new IllegalStateException(
                    "Solicitud " + id + " no está pendiente (estado: " + req.status() + ")");
        }
        return req;
    }

    public void decide(long id, String status, String decidedBy, String result, Boolean resultOk, String error) {
        jdbc.update("UPDATE approval_requests SET status = ?, decided_at = now(), decided_by = ?, "
                        + "result = ?, result_ok = ?, error = ? WHERE id = ?",
                status, decidedBy, result, resultOk, error, id);
    }

    private ApprovalRequest map(ResultSet rs) throws SQLException {
        return new ApprovalRequest(
                rs.getLong("id"),
                rs.getString("tool_name"),
                rs.getString("args"),
                rs.getString("requester"),
                rs.getString("status"),
                toInstant(rs, "created_at"),
                toInstant(rs, "decided_at"),
                rs.getString("decided_by"),
                rs.getString("result"),
                rs.getBoolean("result_ok"),
                rs.getString("error"));
    }

    private Instant toInstant(ResultSet rs, String column) throws SQLException {
        var ts = rs.getTimestamp(column);
        return ts != null ? ts.toInstant() : null;
    }
}
