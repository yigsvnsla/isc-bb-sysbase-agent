package com.isc.bb.sysbase_agent.db;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.stereotype.Component;

/**
 * Registro de conexiones por motor. El nombre "postgres" (reservado) usa el
 * DataSource primario de la app; el resto se construyen desde
 * {@code app.databases.connections.*}.
 */
@Component
public class DatabaseRegistry {

    private static final Logger log = LoggerFactory.getLogger(DatabaseRegistry.class);

    public static final String POSTGRES = "postgres";

    private final JdbcTemplate primaryJdbc;
    private final DbConnectionsProperties props;
    private final Map<EngineType, CatalogDialect> dialects;
    private final Map<String, JdbcTemplate> connections = new LinkedHashMap<>();
    private final Map<String, EngineType> engineByConnection = new LinkedHashMap<>();

    public DatabaseRegistry(JdbcTemplate primaryJdbc,
                            DbConnectionsProperties props,
                            PostgresDialect postgres,
                            MsSqlDialect mssql,
                            OracleDialect oracle,
                            SybaseDialect sybase) {
        this.primaryJdbc = primaryJdbc;
        this.props = props;
        this.dialects = Map.of(
                EngineType.POSTGRES, postgres,
                EngineType.MSSQL, mssql,
                EngineType.ORACLE, oracle,
                EngineType.SYBASE, sybase);
        buildConnections();
    }

    private void buildConnections() {
        for (var entry : props.getConnections().entrySet()) {
            var cp = entry.getValue();
            if (cp == null || !cp.isEnabled()) {
                continue;
            }
            var type = EngineType.fromName(cp.getEngine());
            if (type == null) {
                log.warn("Motor desconocido '{}' para conexión '{}' — se ignora",
                        cp.getEngine(), entry.getKey());
                continue;
            }
            var ds = new DriverManagerDataSource(cp.getUrl(), cp.getUsername(), cp.getPassword());
            ds.setDriverClassName(type.driverClass());
            connections.put(entry.getKey(), new JdbcTemplate(ds));
            engineByConnection.put(entry.getKey(), type);
            log.info("Motor registrado: {} ({}): {}", entry.getKey(), type, cp.getUrl());
        }
    }

    /**
     * Resuelve el motor por nombre. Nombre null/blank o "postgres" → primario.
     * Nombre desconocido → fallback al primario (con warning).
     */
    public DbSession resolve(String name) {
        if (name == null || name.isBlank() || POSTGRES.equalsIgnoreCase(name)) {
            return new DbSession(primaryJdbc, dialects.get(EngineType.POSTGRES), POSTGRES);
        }
        var jdbc = connections.get(name);
        if (jdbc == null) {
            log.warn("Motor '{}' no configurado — fallback a postgres", name);
            return new DbSession(primaryJdbc, dialects.get(EngineType.POSTGRES), POSTGRES);
        }
        return new DbSession(jdbc, dialects.get(engineByConnection.get(name)), name);
    }

    public boolean isKnown(String name) {
        return name != null && (POSTGRES.equalsIgnoreCase(name) || connections.containsKey(name));
    }

    public Set<String> knownNames() {
        var names = new java.util.LinkedHashSet<String>();
        names.add(POSTGRES);
        names.addAll(connections.keySet());
        return names;
    }

    public String defaultEngine() {
        return props.getDefaultEngine();
    }
}
