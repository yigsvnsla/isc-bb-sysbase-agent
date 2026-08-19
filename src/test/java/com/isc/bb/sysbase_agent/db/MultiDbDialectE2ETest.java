package com.isc.bb.sysbase_agent.db;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.testcontainers.mssqlserver.MSSQLServerContainer;
import org.testcontainers.oracle.OracleContainer;
import org.testcontainers.utility.DockerImageName;

/**
 * Validación real de los dialectos MSSQL/Oracle con Testcontainers.
 * OPT-IN: no corre en la suite por defecto (imágenes ~1.5GB).
 *
 *   RUN_MULTIDB_TESTS=true ./mvnw test -Dtest=MultiDbDialectE2ETest
 */
@EnabledIfEnvironmentVariable(named = "RUN_MULTIDB_TESTS", matches = "true")
class MultiDbDialectE2ETest {

    @Test
    void mssql_listsSchemasTablesAndProcedureSource() {
        try (var mssql = new MSSQLServerContainer(DockerImageName.parse("mcr.microsoft.com/mssql/server:2022-latest"))
                .acceptLicense()
                .withPassword("Str0ng_P@ssw0rd!")) {
            mssql.start();
            var jdbc = new JdbcTemplate(
                    new org.springframework.jdbc.datasource.DriverManagerDataSource(
                            mssql.getJdbcUrl(), mssql.getUsername(), mssql.getPassword()));
            jdbc.execute("""
                    CREATE TABLE dbo.empleados (id INT PRIMARY KEY, nombre NVARCHAR(100) NOT NULL)
                    """);
            jdbc.execute("""
                    CREATE PROCEDURE dbo.sp_buscar_empleados AS SELECT id, nombre FROM dbo.empleados
                    """);

            var dialect = new MsSqlDialect();
            assertThat(dialect.listSchemas(jdbc)).contains("dbo");
            assertThat(dialect.listTables(jdbc, "dbo")).extracting(t -> t.name()).contains("empleados");
            assertThat(dialect.listProcedures(jdbc, "dbo")).extracting(p -> p.name())
                    .contains("sp_buscar_empleados");
            assertThat(dialect.getProcedureSource(jdbc, "dbo", "sp_buscar_empleados"))
                    .contains("SELECT id, nombre");
        }
    }

    @Test
    void oracle_listsSchemasAndTables() {
        try (var oracle = new OracleContainer(DockerImageName.parse("gvenzl/oracle-free:23.5-slim"))
                .withUsername("agent")
                .withPassword("Str0ng_P@ssw0rd!")) {
            oracle.start();
            var jdbc = new JdbcTemplate(
                    new org.springframework.jdbc.datasource.DriverManagerDataSource(
                            oracle.getJdbcUrl(), oracle.getUsername(), oracle.getPassword()));
            jdbc.execute("CREATE TABLE empleados (id NUMBER PRIMARY KEY, nombre VARCHAR2(100) NOT NULL)");

            var dialect = new OracleDialect();
            assertThat(dialect.listSchemas(jdbc)).isNotEmpty();
            assertThat(dialect.listTables(jdbc, "AGENT")).extracting(t -> t.name()).contains("EMPLEADOS");
        }
    }
}
