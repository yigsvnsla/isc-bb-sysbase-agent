-- ============================================================================
-- Archivo:      pa_con_ccertificado_pagos_gen.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Store procedure: pa_con_ccertificado_pagos_gen
-- Procesamiento: OLTP
-- Proposito:    Genera certificado de pagos: opcion 'F' retorna fechas
--               proceso, opcion 'C' consulta pagos del usuario con
--               paginacion usando tablas temporales.
-- ============================================================================
CREATE OR REPLACE PROCEDURE cobis.pa_con_ccertificado_pagos_gen(
    IN    e_fecha    TIMESTAMP,
    IN    e_causa    VARCHAR(10),
    IN    e_usuario  VARCHAR(10),
    IN    e_oficina  VARCHAR(10),
    IN    e_pagina   INTEGER,
    IN    e_limite   INTEGER,
    IN    e_opcion   VARCHAR(1),
    INOUT s_return  INTEGER DEFAULT 0,
    INOUT s_cursor  REFCURSOR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_fecha_anterior  DATE;
    v_inicio         INTEGER;
    v_fin            INTEGER;
BEGIN
    v_inicio := ((e_pagina - 1) * e_limite + 1);
    v_fin    := (e_pagina * e_limite);

    -- Validamos las Opciones disponibles
    -- F = CONSULTAR ULTIMA FECHA PROCESO
    -- C = CONSULTAR ULTIMOS PAGOS DEL USUARIO
    IF e_opcion NOT IN ('F', 'C') THEN
        s_return := 99999;
        RAISE NOTICE 'ERROR: Opcion no valida';
        RETURN;
    END IF;

    -- Extraemos fecha de ultimo dia habil
    v_fecha_anterior := NULL;
    CALL cobis.pa_con_tult_dia_habil_ant(v_fecha_anterior, e_fecha::DATE);

    IF e_opcion = 'F' THEN
        OPEN s_cursor FOR
            SELECT TO_CHAR(e_fecha, 'MM/DD/YYYY')           AS s_fecha_proceso,
                   TO_CHAR(v_fecha_anterior, 'MM/DD/YYYY')  AS s_fecha_proceso_anterior;
        s_return := 0;
        RETURN;
    END IF;

    -- Control tabla temporal: catalogo de transacciones
    DROP TABLE IF EXISTS _reca_tmp_trx_serv;
    CREATE TEMP TABLE _reca_tmp_trx_serv AS
    SELECT catalogo.codigo,
           trx.tn_descripcion AS valor
    FROM (
        SELECT c.codigo::INTEGER AS codigo
        FROM cobis.cl_catalogo c
        INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
        WHERE t.tabla = 'cl_trx_emp_pub'
          AND c.estado = 'V'
        UNION
        SELECT c.codigo::INTEGER AS codigo
        FROM cobis.cl_catalogo c
        INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
        WHERE t.tabla = 'cl_trx_emp_pri'
          AND c.estado = 'V'
    ) AS catalogo
    INNER JOIN cobis.cl_ttransaccion trx ON trx.tn_trn_code = catalogo.codigo;

    PERFORM 1 FROM _reca_tmp_trx_serv LIMIT 1;
    IF NOT FOUND THEN
        s_return := 5004011;
        RAISE NOTICE 'ERROR LECTURA CATALOGO sv_reca_concilia_trx_banred';
        RETURN;
    END IF;

    -- Control tabla temporal: transacciones del dia
    DROP TABLE IF EXISTS _reca_tmp_servicio;
    CREATE TEMP TABLE _reca_tmp_servicio AS
    SELECT ts_ssn_corr,
           ts_correccion,
           ts_hora,
           ts_causa,
           ts_tsfecha,
           ts_tipo_transaccion,
           ts_oficina,
           ts_secuencial,
           ts_referencia,
           ts_nombre,
           ts_saldo,
           ts_monto,
           ts_valor,
           ts_contratado
    FROM cob_cuentas.cc_tran_servicio
    WHERE ts_oficina = e_oficina::INTEGER
      AND ts_causa = e_causa
      AND ts_tsfecha = e_fecha
      AND ts_usuario = e_usuario
      AND ts_tipo_chequera IN ('VEN', 'VENEL')
    UNION
    SELECT ts_ssn_corr,
           ts_correccion,
           ts_hora,
           ts_causa,
           ts_tsfecha,
           ts_tipo_transaccion,
           ts_oficina,
           ts_secuencial,
           ts_referencia,
           ts_nombre,
           ts_saldo,
           ts_monto,
           ts_valor,
           ts_contratado
    FROM cob_cuentas.cc_tran_servicio_resp
    WHERE ts_oficina = e_oficina::INTEGER
      AND ts_causa = e_causa
      AND ts_tsfecha = v_fecha_anterior
      AND ts_usuario = e_usuario
      AND ts_tipo_chequera IN ('VEN', 'VENEL');

    PERFORM 1 FROM _reca_tmp_servicio LIMIT 1;
    IF NOT FOUND THEN
        s_return := 33333;
        RAISE NOTICE 'ERROR: Insertar Transacciones del dia';
        RETURN;
    END IF;

    -- Control tabla temporal: transacciones reversadas
    DROP TABLE IF EXISTS _reca_tmp_trx_reversadas;
    CREATE TEMP TABLE _reca_tmp_trx_reversadas AS
    SELECT ts_ssn_corr
    FROM _reca_tmp_servicio
    WHERE ts_correccion = 'S';

    -- Control tabla temporal: transacciones pagadas
    DROP TABLE IF EXISTS _reca_tmp_trx;
    CREATE TEMP TABLE _reca_tmp_trx (
        crtf_indice            SERIAL NOT NULL,
        crtf_tipo_transaccion  VARCHAR(50),
        crtf_ciudad            VARCHAR(50),
        crtf_nombre_empresa    VARCHAR(50),
        crtf_nombre_cliente    VARCHAR(50),
        crtf_suministro        VARCHAR(50),
        crtf_fecha_pago        VARCHAR(50),
        crtf_valor             NUMERIC(19,4)
    );

    INSERT INTO _reca_tmp_trx (
        crtf_tipo_transaccion,
        crtf_ciudad,
        crtf_nombre_empresa,
        crtf_nombre_cliente,
        crtf_suministro,
        crtf_fecha_pago,
        crtf_valor
    )
    SELECT trx.valor,
           ciudad.ci_descripcion,
           empresa.pe_nombre,
           servicio.ts_nombre,
           servicio.ts_referencia,
           servicio.ts_hora,
           COALESCE(servicio.ts_saldo, 0) +
           COALESCE(servicio.ts_monto, 0) +
           COALESCE(servicio.ts_valor, 0) +
           COALESCE(servicio.ts_contratado, 0)
    FROM _reca_tmp_servicio servicio
    RIGHT JOIN cobis.cl_oficina oficina
        ON oficina.of_oficina = servicio.ts_oficina
    RIGHT JOIN cobis.cl_ciudad ciudad
        ON ciudad.ci_ciudad = oficina.of_ciudad
    RIGHT JOIN cob_pagos.pg_person_empresa empresa
        ON empresa.pe_empresa = servicio.ts_causa::INTEGER
    LEFT JOIN _reca_tmp_trx_reversadas reversadas
        ON servicio.ts_secuencial = reversadas.ts_ssn_corr
    INNER JOIN _reca_tmp_trx_serv trx
        ON trx.codigo = servicio.ts_tipo_transaccion::VARCHAR
    WHERE reversadas.ts_ssn_corr IS NULL
      AND servicio.ts_correccion = 'N'
    ORDER BY servicio.ts_hora DESC;

    GET DIAGNOSTICS v_fin = ROW_COUNT;
    IF v_fin = 0 THEN
        s_return := 33333;
        RAISE NOTICE 'ERROR: Insertar Transacciones Empresa';
        RETURN;
    END IF;

    OPEN s_cursor FOR
        SELECT crtf_fecha_pago         AS "Fecha de Pago",
               crtf_suministro         AS "Suministro",
               crtf_nombre_cliente     AS "Nombre Cliente",
               crtf_valor              AS "Valor",
               crtf_nombre_empresa     AS "Nombre Empresa",
               crtf_tipo_transaccion   AS "Tipo Recaudacion",
               crtf_ciudad             AS "Ciudad"
        FROM _reca_tmp_trx crtf
        WHERE crtf.crtf_indice BETWEEN v_inicio AND v_fin;

    -- Control tablas temporales
    DROP TABLE IF EXISTS _reca_tmp_trx_serv;
    DROP TABLE IF EXISTS _reca_tmp_servicio;
    DROP TABLE IF EXISTS _reca_tmp_servicio_resp;
    DROP TABLE IF EXISTS _reca_tmp_trx_reversadas;
    DROP TABLE IF EXISTS _reca_tmp_trx_pagadas;
    DROP TABLE IF EXISTS _reca_tmp_trx;

    s_return := 0;
END;
$$;
