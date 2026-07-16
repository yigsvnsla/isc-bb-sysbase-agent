-- ============================================================================
-- Archivo:      cl_producto.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_producto
-- Proposito:    Catalogo de productos del sistema
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_producto (
    pd_producto     SMALLINT NOT NULL,
    pd_descripcion  VARCHAR(64),
    pd_estado       CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_producto PRIMARY KEY (pd_producto),
    CONSTRAINT ck_cl_producto_estado CHECK (pd_estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_producto IS 'Catalogo de productos del sistema';
COMMENT ON COLUMN cobis.cl_producto.pd_producto IS 'Codigo de producto';
COMMENT ON COLUMN cobis.cl_producto.pd_descripcion IS 'Descripcion del producto';
COMMENT ON COLUMN cobis.cl_producto.pd_estado IS 'Estado: V=Vigente, I=Inactivo';
