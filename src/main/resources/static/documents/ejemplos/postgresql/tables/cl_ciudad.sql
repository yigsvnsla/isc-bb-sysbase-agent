-- ============================================================================
-- Archivo:      cl_ciudad.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_ciudad
-- Proposito:    Maestro de ciudades
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_ciudad (
    ci_ciudad       INTEGER NOT NULL,
    ci_descripcion  VARCHAR(50),
    ci_estado       CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_ciudad PRIMARY KEY (ci_ciudad),
    CONSTRAINT ck_cl_ciudad_estado CHECK (ci_estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_ciudad IS 'Maestro de ciudades';
COMMENT ON COLUMN cobis.cl_ciudad.ci_ciudad IS 'Codigo de ciudad';
COMMENT ON COLUMN cobis.cl_ciudad.ci_descripcion IS 'Nombre de la ciudad';
