-- ============================================================================
-- Archivo:      tmp_log_phol2.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        tmp_log_phol2
-- Proposito:    Tabla temporal de log para debug de SP
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.tmp_log_phol2 (
    id        SERIAL PRIMARY KEY,
    sp_nombre VARCHAR(32),
    usuario   VARCHAR(128),
    valor     VARCHAR(12),
    ente      INTEGER,
    resultado INTEGER,
    fecha     TIMESTAMP DEFAULT NOW()
);

COMMENT ON TABLE cobis.tmp_log_phol2 IS 'Tabla temporal de log para debug de SP';
COMMENT ON COLUMN cobis.tmp_log_phol2.sp_nombre IS 'Nombre del stored procedure';
COMMENT ON COLUMN cobis.tmp_log_phol2.usuario IS 'Usuario';
COMMENT ON COLUMN cobis.tmp_log_phol2.valor IS 'Valor procesado';
COMMENT ON COLUMN cobis.tmp_log_phol2.ente IS 'Codigo de ente';
COMMENT ON COLUMN cobis.tmp_log_phol2.resultado IS 'Codigo de resultado';
