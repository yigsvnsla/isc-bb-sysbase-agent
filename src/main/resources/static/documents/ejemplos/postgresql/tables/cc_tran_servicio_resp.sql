-- ============================================================================
-- Archivo:      cc_tran_servicio_resp.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cc_tran_servicio_resp
-- Esquema:      cob_cuentas
-- Proposito:    Transacciones de servicio pendientes de respuesta
-- ============================================================================

CREATE TABLE IF NOT EXISTS cob_cuentas.cc_tran_servicio_resp (
    LIKE cob_cuentas.cc_tran_servicio INCLUDING ALL
);

COMMENT ON TABLE cob_cuentas.cc_tran_servicio_resp IS 'Transacciones de servicio pendientes de respuesta';
