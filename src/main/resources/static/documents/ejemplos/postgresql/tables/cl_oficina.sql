-- ============================================================================
-- Archivo:      cl_oficina.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_oficina
-- Proposito:    Maestro de oficinas del banco
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_oficina (
    of_oficina   INTEGER NOT NULL,
    of_ciudad    INTEGER NOT NULL,
    of_nombre    VARCHAR(64),
    of_estado    CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_oficina PRIMARY KEY (of_oficina),
    CONSTRAINT ck_cl_oficina_estado CHECK (of_estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_oficina IS 'Maestro de oficinas del banco';
COMMENT ON COLUMN cobis.cl_oficina.of_oficina IS 'Codigo de oficina';
COMMENT ON COLUMN cobis.cl_oficina.of_ciudad IS 'Codigo de ciudad';
COMMENT ON COLUMN cobis.cl_oficina.of_nombre IS 'Nombre de la oficina';
