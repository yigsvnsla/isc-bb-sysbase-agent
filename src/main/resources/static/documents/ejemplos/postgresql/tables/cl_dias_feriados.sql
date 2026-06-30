-- ============================================================================
-- Archivo:      cl_dias_feriados.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cl_dias_feriados
-- Proposito:    Calendario de feriados por ciudad
-- ============================================================================

CREATE TABLE IF NOT EXISTS cobis.cl_dias_feriados (
    df_fecha       DATE NOT NULL,
    df_ciudad      INTEGER NOT NULL DEFAULT 1,
    df_descripcion VARCHAR(100),
    df_activo      CHAR(1) DEFAULT 'S',
    CONSTRAINT pk_cl_dias_feriados PRIMARY KEY (df_fecha, df_ciudad),
    CONSTRAINT ck_cl_dias_feriados_activo CHECK (df_activo IN ('S', 'N'))
);

COMMENT ON TABLE cobis.cl_dias_feriados IS 'Calendario de feriados por ciudad';
COMMENT ON COLUMN cobis.cl_dias_feriados.df_fecha IS 'Fecha feriado';
COMMENT ON COLUMN cobis.cl_dias_feriados.df_ciudad IS 'Codigo de ciudad';
COMMENT ON COLUMN cobis.cl_dias_feriados.df_descripcion IS 'Descripcion del feriado';
COMMENT ON COLUMN cobis.cl_dias_feriados.df_activo IS 'Activo: S=Si, N=No';
