-- ============================================================================
-- Archivo:      cl_tabla.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_tabla
-- Proposito:    Catalogo maestro de tablas parametricas
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS cobis;

CREATE TABLE IF NOT EXISTS cobis.cl_tabla (
    codigo  INTEGER NOT NULL,
    tabla   VARCHAR(50) NOT NULL,
    estado  CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_tabla PRIMARY KEY (codigo),
    CONSTRAINT uq_cl_tabla UNIQUE (tabla),
    CONSTRAINT ck_cl_tabla_estado CHECK (estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_tabla IS 'Catalogo maestro de tablas parametricas';
COMMENT ON COLUMN cobis.cl_tabla.codigo IS 'Codigo interno';
COMMENT ON COLUMN cobis.cl_tabla.tabla IS 'Nombre de la tabla';
COMMENT ON COLUMN cobis.cl_tabla.estado IS 'Estado: V=Vigente, I=Inactivo';
