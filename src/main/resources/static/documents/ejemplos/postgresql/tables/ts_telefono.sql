-- ============================================================================
-- Archivo:      ts_telefono.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        ts_telefono
-- Proposito:    Historico de transacciones de telefonos
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.ts_telefono (
    id               SERIAL PRIMARY KEY,
    secuencial       INTEGER,
    tipo_transaccion INTEGER,
    alterno          INTEGER,
    clase            CHAR(1),
    fecha            TIMESTAMP,
    usuario          VARCHAR(128),
    terminal         VARCHAR(30),
    srv              VARCHAR(30),
    lsrv             VARCHAR(30),
    origen           INTEGER,
    rol              SMALLINT,
    ente             INTEGER,
    direccion        SMALLINT,
    telefono         SMALLINT,
    valor            VARCHAR(12),
    tipo             CHAR(1),
    extension        VARCHAR(20),
    comentario       VARCHAR(254),
    pertenece        CHAR(1),
    canal            VARCHAR(10)
);

COMMENT ON TABLE cobis.ts_telefono IS 'Historico de transacciones de telefonos';
COMMENT ON COLUMN cobis.ts_telefono.secuencial IS 'Secuencial de la transaccion';
COMMENT ON COLUMN cobis.ts_telefono.tipo_transaccion IS 'Tipo de transaccion (111,112,148)';
COMMENT ON COLUMN cobis.ts_telefono.clase IS 'N=Nuevo, P=Previo, A=Actual, B=Borrado';
COMMENT ON COLUMN cobis.ts_telefono.ente IS 'FK a cl_ente';
COMMENT ON COLUMN cobis.ts_telefono.canal IS 'Canal de origen';
