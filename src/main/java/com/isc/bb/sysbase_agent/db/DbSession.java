package com.isc.bb.sysbase_agent.db;

import org.springframework.jdbc.core.JdbcTemplate;

/**
 * Motor resuelto para una operación de catálogo: JDBC + dialecto + nombre.
 */
public record DbSession(JdbcTemplate jdbc, CatalogDialect dialect, String engine) {
}
