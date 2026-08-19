package com.isc.bb.sysbase_agent.db;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.jdbc.core.JdbcTemplate;

class DatabaseRegistryTest {

    private DatabaseRegistry registry() {
        var props = new DbConnectionsProperties();
        props.setDefaultEngine("postgres");
        var mssql = new DbConnectionsProperties.ConnectionProps();
        mssql.setEngine("mssql");
        mssql.setUrl("jdbc:sqlserver://localhost:1433;databaseName=x;encrypt=false");
        mssql.setUsername("sa");
        mssql.setPassword("pwd");
        props.getConnections().put("mssql-qa", mssql);
        return new DatabaseRegistry(
                new JdbcTemplate(),
                props,
                new PostgresDialect(),
                new MsSqlDialect(),
                new OracleDialect(),
                new SybaseDialect());
    }

    @Test
    void nullResolvesToPostgres() {
        var s = registry().resolve(null);
        assertThat(s.engine()).isEqualTo("postgres");
        assertThat(s.dialect()).isInstanceOf(PostgresDialect.class);
    }

    @Test
    void postgresNameResolvesToPostgresDialect() {
        assertThat(registry().resolve("postgres").dialect()).isInstanceOf(PostgresDialect.class);
    }

    @Test
    void configuredConnectionResolvesToItsDialect() {
        var s = registry().resolve("mssql-qa");
        assertThat(s.engine()).isEqualTo("mssql-qa");
        assertThat(s.dialect()).isInstanceOf(MsSqlDialect.class);
    }

    @Test
    void unknownNameFallsBackToPostgres() {
        assertThat(registry().resolve("noexiste").dialect()).isInstanceOf(PostgresDialect.class);
    }

    @Test
    void knownNamesIncludesPostgresAndConnections() {
        var names = registry().knownNames();
        assertThat(names).contains("postgres", "mssql-qa");
    }

    @Test
    void disabledConnectionIsIgnored() {
        var props = new DbConnectionsProperties();
        var oracle = new DbConnectionsProperties.ConnectionProps();
        oracle.setEngine("oracle");
        oracle.setUrl("jdbc:oracle:thin:@//localhost:1521/XE");
        oracle.setEnabled(false);
        props.getConnections().put("oracle-off", oracle);
        var registry = new DatabaseRegistry(new JdbcTemplate(), props,
                new PostgresDialect(), new MsSqlDialect(), new OracleDialect(), new SybaseDialect());
        assertThat(registry.isKnown("oracle-off")).isFalse();
    }
}
