package com.isc.bb.sysbase_agent.db;

/**
 * Motores de BD soportados por el agente para exploración de catálogo.
 */
public enum EngineType {
    POSTGRES("org.postgresql.Driver"),
    MSSQL("com.microsoft.sqlserver.jdbc.SQLServerDriver"),
    ORACLE("oracle.jdbc.OracleDriver"),
    SYBASE("net.sourceforge.jtds.jdbc.Driver");

    private final String driverClass;

    EngineType(String driverClass) {
        this.driverClass = driverClass;
    }

    public String driverClass() {
        return driverClass;
    }

    public static EngineType fromName(String name) {
        if (name == null) {
            return null;
        }
        return switch (name.trim().toLowerCase()) {
            case "postgres", "postgresql", "pg" -> POSTGRES;
            case "mssql", "sqlserver", "sql-server" -> MSSQL;
            case "oracle" -> ORACLE;
            case "sybase", "sybasease", "ase" -> SYBASE;
            default -> null;
        };
    }
}
