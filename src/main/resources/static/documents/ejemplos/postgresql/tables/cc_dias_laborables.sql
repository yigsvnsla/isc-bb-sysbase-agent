-- ============================================================================
-- Archivo:      cc_dias_laborables.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cc_dias_laborables
-- Esquema:      cob_cuentas
-- Proposito:    Calendario de dias laborables por ciudad
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS cob_cuentas;

CREATE TABLE IF NOT EXISTS cob_cuentas.cc_dias_laborables (
    dl_ciudad   INTEGER NOT NULL,
    dl_fecha    DATE NOT NULL,
    dl_num_dias INTEGER DEFAULT 0,
    CONSTRAINT pk_cc_dias_laborables PRIMARY KEY (dl_ciudad, dl_fecha)
);

COMMENT ON TABLE cob_cuentas.cc_dias_laborables IS 'Calendario de dias laborables por ciudad';
COMMENT ON COLUMN cob_cuentas.cc_dias_laborables.dl_ciudad IS 'Codigo de ciudad';
COMMENT ON COLUMN cob_cuentas.cc_dias_laborables.dl_fecha IS 'Fecha laborable';
COMMENT ON COLUMN cob_cuentas.cc_dias_laborables.dl_num_dias IS 'Numero de dias desplazamiento';
