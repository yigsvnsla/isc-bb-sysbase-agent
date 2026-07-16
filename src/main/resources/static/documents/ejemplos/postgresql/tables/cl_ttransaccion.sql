-- ============================================================================
-- Archivo:      cl_ttransaccion.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_ttransaccion
-- Proposito:    Catalogo de tipos de transaccion del sistema
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_ttransaccion (
    tn_trn_code     INTEGER NOT NULL,
    tn_descripcion  VARCHAR(50),
    tn_estado       CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_ttransaccion PRIMARY KEY (tn_trn_code),
    CONSTRAINT ck_cl_ttransaccion_estado CHECK (tn_estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_ttransaccion IS 'Catalogo de tipos de transaccion del sistema';
COMMENT ON COLUMN cobis.cl_ttransaccion.tn_trn_code IS 'Codigo de transaccion';
COMMENT ON COLUMN cobis.cl_ttransaccion.tn_descripcion IS 'Descripcion de la transaccion';
COMMENT ON COLUMN cobis.cl_ttransaccion.tn_estado IS 'Estado: V=Vigente, I=Inactivo';
