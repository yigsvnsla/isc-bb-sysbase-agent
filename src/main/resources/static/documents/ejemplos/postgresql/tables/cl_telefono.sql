-- ============================================================================
-- Archivo:      cl_telefono.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_telefono
-- Proposito:    Maestro de telefonos de entes
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_telefono (
    te_ente          INTEGER NOT NULL,
    te_direccion     SMALLINT NOT NULL,
    te_secuencial    SMALLINT NOT NULL,
    te_valor         VARCHAR(12),
    te_tipo_telefono CHAR(1),
    te_extension     VARCHAR(20),
    te_comentario    VARCHAR(254),
    te_pertenece     CHAR(1),
    CONSTRAINT pk_cl_telefono PRIMARY KEY (te_ente, te_direccion, te_secuencial),
    CONSTRAINT fk_cl_telefono_direccion FOREIGN KEY (te_ente, te_direccion)
        REFERENCES cobis.cl_direccion(di_ente, di_direccion)
);

COMMENT ON TABLE cobis.cl_telefono IS 'Maestro de telefonos de entes';
COMMENT ON COLUMN cobis.cl_telefono.te_ente IS 'FK a cl_ente';
COMMENT ON COLUMN cobis.cl_telefono.te_direccion IS 'FK a cl_direccion';
COMMENT ON COLUMN cobis.cl_telefono.te_secuencial IS 'Secuencial de telefono';
COMMENT ON COLUMN cobis.cl_telefono.te_valor IS 'Numero de telefono';
COMMENT ON COLUMN cobis.cl_telefono.te_tipo_telefono IS 'Tipo de telefono (catalogo)';
COMMENT ON COLUMN cobis.cl_telefono.te_extension IS 'Extension';
COMMENT ON COLUMN cobis.cl_telefono.te_comentario IS 'Comentario';
COMMENT ON COLUMN cobis.cl_telefono.te_pertenece IS 'Pertenencia';
