-- ============================================================================
-- Archivo:      cl_ente.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_ente
-- Proposito:    Maestro de entes (personas y companias)
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_ente (
    en_ente         INTEGER NOT NULL,
    en_grupo        INTEGER,
    en_subtipo      CHAR(1) DEFAULT 'P',
    en_fecha_crea   TIMESTAMP DEFAULT NOW(),
    en_ced_ruc      VARCHAR(13),
    en_nombre       VARCHAR(64),
    p_pasaporte     VARCHAR(20),
    p_p_apellido    VARCHAR(64),
    p_s_apellido    VARCHAR(64),
    en_estado       CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_cl_ente PRIMARY KEY (en_ente),
    CONSTRAINT fk_cl_ente_grupo FOREIGN KEY (en_grupo)
        REFERENCES cobis.cl_ente(en_ente),
    CONSTRAINT ck_cl_ente_subtipo CHECK (en_subtipo IN ('P', 'C')),
    CONSTRAINT ck_cl_ente_estado CHECK (en_estado IN ('V', 'I'))
);

COMMENT ON TABLE cobis.cl_ente IS 'Maestro de entes (personas y companias)';
COMMENT ON COLUMN cobis.cl_ente.en_ente IS 'Codigo del ente';
COMMENT ON COLUMN cobis.cl_ente.en_grupo IS 'Grupo al que pertenece';
COMMENT ON COLUMN cobis.cl_ente.en_subtipo IS 'P=Persona, C=Compania';
COMMENT ON COLUMN cobis.cl_ente.en_fecha_crea IS 'Fecha de creacion';
COMMENT ON COLUMN cobis.cl_ente.en_ced_ruc IS 'Cedula o RUC';
COMMENT ON COLUMN cobis.cl_ente.en_nombre IS 'Nombre del ente';
