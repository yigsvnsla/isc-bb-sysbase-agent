-- ============================================================================
-- Archivo:      pa_con_tult_dia_habil_ant.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Store procedure: pa_con_tult_dia_habil_ant
-- Procesamiento: OLTP
-- Proposito:    Retorna la fecha del ultimo dia habil anterior a una
--               fecha dada, consultando la tabla de feriados.
-- ============================================================================
CREATE OR REPLACE PROCEDURE cobis.pa_con_tult_dia_habil_ant(
    INOUT  s_fch_habil DATE,
    IN     e_fecha     DATE DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_verdadero   CHAR(1);
    v_dia_habil   DATE;
    v_fecha       DATE;
    v_ciudad      INTEGER;
BEGIN
    IF e_fecha IS NULL THEN
        SELECT fp_fecha INTO v_fecha
        FROM cobis.ba_fecha_proceso
        WHERE fp_estado = 'A'
        ORDER BY fp_fecha DESC
        LIMIT 1;
    ELSE
        v_fecha := e_fecha;
    END IF;

    v_ciudad    := 1;
    v_verdadero := 'S';

    WHILE v_verdadero = 'S' LOOP
        PERFORM 1
        FROM cobis.cl_dias_feriados
        WHERE df_fecha = v_fecha
          AND df_ciudad = v_ciudad
          AND df_activo = 'S';

        IF NOT FOUND THEN
            v_verdadero := 'N';
            v_dia_habil := v_fecha;
            s_fch_habil := v_fecha;
        ELSE
            v_fecha := v_fecha - 1;
        END IF;
    END LOOP;
END;
$$;
