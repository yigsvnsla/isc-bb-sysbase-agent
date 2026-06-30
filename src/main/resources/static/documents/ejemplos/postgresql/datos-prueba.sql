-- ============================================================================
-- Archivo:      datos-prueba.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Proposito:    Datos de prueba para pa_con_tult_dia_habil_ant
-- ============================================================================

-- Insertar fecha de proceso activa (hoy)
INSERT INTO cobis.ba_fecha_proceso (fp_fecha, fp_estado)
VALUES (CURRENT_DATE, 'A')
ON CONFLICT (fp_fecha) DO NOTHING;

-- Insertar feriados de ejemplo (ciudad 1)
INSERT INTO cobis.cl_dias_feriados (df_fecha, df_ciudad, df_descripcion, df_activo)
VALUES
    (CURRENT_DATE - 1, 1, 'Feriado simulado: ayer', 'S'),
    (CURRENT_DATE - 3, 1, 'Feriado simulado: anteayer', 'S'),
    ('2026-01-01', 1, 'Ano Nuevo', 'S'),
    ('2026-05-01', 1, 'Dia del Trabajo', 'S'),
    ('2026-12-25', 1, 'Navidad', 'S')
ON CONFLICT (df_fecha, df_ciudad) DO NOTHING;
