-- ============================================================================
-- Archivo:      ba_fecha_proceso.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        ba_fecha_proceso
-- Proposito:    Fecha de proceso activa del sistema
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS cobis;

CREATE TABLE IF NOT EXISTS cobis.ba_fecha_proceso (
    fp_fecha  DATE NOT NULL DEFAULT CURRENT_DATE,
    fp_estado CHAR(1) DEFAULT 'A',
    CONSTRAINT pk_ba_fecha_proceso PRIMARY KEY (fp_fecha),
    CONSTRAINT ck_ba_fecha_proceso_estado CHECK (fp_estado IN ('A', 'I'))
);

COMMENT ON TABLE cobis.ba_fecha_proceso IS 'Fecha de proceso activa del sistema';
COMMENT ON COLUMN cobis.ba_fecha_proceso.fp_fecha IS 'Fecha de proceso';
COMMENT ON COLUMN cobis.ba_fecha_proceso.fp_estado IS 'Estado: A=Activo, I=Inactivo';
