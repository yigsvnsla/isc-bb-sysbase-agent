package com.isc.bb.sysbase_agent.db;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class EngineTypeTest {

    @Test
    void fromName_mapsKnownAliases() {
        assertThat(EngineType.fromName("postgres")).isEqualTo(EngineType.POSTGRES);
        assertThat(EngineType.fromName("postgresql")).isEqualTo(EngineType.POSTGRES);
        assertThat(EngineType.fromName("mssql")).isEqualTo(EngineType.MSSQL);
        assertThat(EngineType.fromName("SQLServer")).isEqualTo(EngineType.MSSQL);
        assertThat(EngineType.fromName("oracle")).isEqualTo(EngineType.ORACLE);
        assertThat(EngineType.fromName("sybase")).isEqualTo(EngineType.SYBASE);
        assertThat(EngineType.fromName("ASE")).isEqualTo(EngineType.SYBASE);
    }

    @Test
    void fromName_unknownReturnsNull() {
        assertThat(EngineType.fromName("mysql")).isNull();
        assertThat(EngineType.fromName(null)).isNull();
    }
}
