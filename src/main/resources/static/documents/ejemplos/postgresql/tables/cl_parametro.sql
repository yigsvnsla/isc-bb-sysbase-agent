-- ============================================================================
-- Archivo:      cl_parametro.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_parametro
-- Proposito:    Maestro de parametros del sistema
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_parametro (
    pa_producto VARCHAR(10) NOT NULL,
    pa_nemonico VARCHAR(30) NOT NULL,
    pa_money    NUMERIC(19,4),
    pa_tinyint  SMALLINT,
    pa_valor    VARCHAR(255),
    pa_estado   CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_parametro PRIMARY KEY (pa_producto, pa_nemonico),
    CONSTRAINT ck_cl_parametro_estado CHECK (pa_estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_parametro IS 'Maestro de parametros del sistema';
COMMENT ON COLUMN cobis.cl_parametro.pa_producto IS 'Producto asociado';
COMMENT ON COLUMN cobis.cl_parametro.pa_nemonico IS 'Nemonico del parametro';
COMMENT ON COLUMN cobis.cl_parametro.pa_money IS 'Valor monetario';
COMMENT ON COLUMN cobis.cl_parametro.pa_tinyint IS 'Valor entero pequeno';
COMMENT ON COLUMN cobis.cl_parametro.pa_valor IS 'Valor texto';
