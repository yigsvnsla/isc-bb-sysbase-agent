-- ============================================================================
-- Archivo:      cl_direccion_email.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_direccion_email
-- Proposito:    Maestro de direcciones electronicas (email, movil)
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_direccion_email (
    de_ente              INTEGER NOT NULL,
    de_tipo              CHAR(1) NOT NULL,
    de_secuencial        SMALLINT NOT NULL DEFAULT 1,
    de_descripcion       VARCHAR(64),
    de_fecha_modificacion TIMESTAMP DEFAULT NOW(),
    de_dir_domici        SMALLINT,
    de_estado            CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_direccion_email PRIMARY KEY (de_ente, de_tipo, de_secuencial),
    CONSTRAINT fk_cl_direccion_email_ente FOREIGN KEY (de_ente)
        REFERENCES cobis.cl_ente(en_ente),
    CONSTRAINT ck_cl_direccion_email_tipo CHECK (de_tipo IN ('E', 'M')),
    CONSTRAINT ck_cl_direccion_email_estado CHECK (de_estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_direccion_email IS 'Maestro de direcciones electronicas (email, movil)';
COMMENT ON COLUMN cobis.cl_direccion_email.de_ente IS 'FK a cl_ente';
COMMENT ON COLUMN cobis.cl_direccion_email.de_tipo IS 'E=Email, M=Movil';
COMMENT ON COLUMN cobis.cl_direccion_email.de_descripcion IS 'Email o numero de celular';
COMMENT ON COLUMN cobis.cl_direccion_email.de_fecha_modificacion IS 'Ultima modificacion';
COMMENT ON COLUMN cobis.cl_direccion_email.de_dir_domici IS 'Direccion domicilio asociada';
