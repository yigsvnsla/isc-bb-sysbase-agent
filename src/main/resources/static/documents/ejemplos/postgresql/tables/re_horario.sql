-- ============================================================================
-- Archivo:      re_horario.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        re_horario
-- Esquema:      cob_remesas
-- Proposito:    Horario de atencion diferido por oficina y ubicacion
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS cob_remesas;

CREATE TABLE IF NOT EXISTS cob_remesas.re_horario (
    rh_oficina   INTEGER NOT NULL,
    rh_ubicacion INTEGER NOT NULL,
    rh_inicio    VARCHAR(9),
    rh_fin       VARCHAR(9),
    rh_estado    CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_re_horario PRIMARY KEY (rh_oficina, rh_ubicacion),
    CONSTRAINT ck_re_horario_estado CHECK (rh_estado IN ('V', 'I'))
);

COMMENT ON TABLE cob_remesas.re_horario IS 'Horario de atencion diferido por oficina y ubicacion';
COMMENT ON COLUMN cob_remesas.re_horario.rh_oficina IS 'Codigo de oficina';
COMMENT ON COLUMN cob_remesas.re_horario.rh_ubicacion IS 'Codigo de ubicacion';
COMMENT ON COLUMN cob_remesas.re_horario.rh_inicio IS 'Hora inicio (HH:MM:SS)';
COMMENT ON COLUMN cob_remesas.re_horario.rh_fin IS 'Hora fin (HH:MM:SS)';
