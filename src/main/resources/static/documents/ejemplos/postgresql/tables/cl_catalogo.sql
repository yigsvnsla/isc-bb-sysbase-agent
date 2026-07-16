-- ============================================================================
-- Archivo:      cl_catalogo.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_catalogo
-- Proposito:    Catalogo de valores parametricos del sistema
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_catalogo (
    codigo  VARCHAR(30) NOT NULL,
    tabla   INTEGER NOT NULL,
    valor   VARCHAR(255),
    estado  CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_catalogo PRIMARY KEY (tabla, codigo),
    CONSTRAINT fk_cl_catalogo_tabla FOREIGN KEY (tabla)
        REFERENCES cobis.cl_tabla(codigo),
    CONSTRAINT ck_cl_catalogo_estado CHECK (estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_catalogo IS 'Catalogo de valores parametricos del sistema';
COMMENT ON COLUMN cobis.cl_catalogo.codigo IS 'Codigo del valor';
COMMENT ON COLUMN cobis.cl_catalogo.tabla IS 'FK a cl_tabla';
COMMENT ON COLUMN cobis.cl_catalogo.valor IS 'Valor o descripcion';
COMMENT ON COLUMN cobis.cl_catalogo.estado IS 'Estado: V=Vigente, I=Inactivo';
