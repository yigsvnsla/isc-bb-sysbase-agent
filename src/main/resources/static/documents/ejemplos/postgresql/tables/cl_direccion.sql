-- ============================================================================
-- Archivo:      cl_direccion.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_direccion
-- Proposito:    Maestro de direcciones de entes
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_direccion (
    di_ente         INTEGER NOT NULL,
    di_direccion    SMALLINT NOT NULL,
    di_descripcion  VARCHAR(100),
    di_estado       CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_direccion PRIMARY KEY (di_ente, di_direccion),
    CONSTRAINT fk_cl_direccion_ente FOREIGN KEY (di_ente)
        REFERENCES cobis.cl_ente(en_ente),
    CONSTRAINT ck_cl_direccion_estado CHECK (di_estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_direccion IS 'Maestro de direcciones de entes';
COMMENT ON COLUMN cobis.cl_direccion.di_ente IS 'FK a cl_ente';
COMMENT ON COLUMN cobis.cl_direccion.di_direccion IS 'Secuencial de direccion';
COMMENT ON COLUMN cobis.cl_direccion.di_descripcion IS 'Descripcion de la direccion';
