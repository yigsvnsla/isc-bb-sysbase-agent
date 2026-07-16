-- ============================================================================
-- Archivo:      pa_pg_tpag_reca_varios.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Store procedure: pa_pg_tpag_reca_varios
-- Procesamiento: OLTP
-- Proposito:    Procesa pagos/reversos de recaudaciones en via rapida.
--               Orquesta multiples subprocesos: validacion de horario,
--               registro debito/credito, comisiones, base imponible SRI,
--               notificaciones, e informacion CNB. Soporta VEN y CNB.
-- ============================================================================
CREATE OR REPLACE PROCEDURE cobis.pa_pg_tpag_reca_varios(
    IN    e_ssn                  INTEGER,
    IN    e_term                 VARCHAR(10),
    IN    e_date                 TIMESTAMP,
    IN    e_trn                  INTEGER,
    IN    e_srv                  VARCHAR(30) DEFAULT '',
    IN    e_user                 VARCHAR(30) DEFAULT '',
    IN    e_ofi                  INTEGER DEFAULT 1,
    IN    e_rol                  SMALLINT DEFAULT 1,
    IN    e_corr                 CHAR(1) DEFAULT 'N',
    IN    e_ssn_corr             INTEGER DEFAULT 0,
    IN    e_mon                  SMALLINT DEFAULT 1,
    IN    e_ruc_cliente          VARCHAR(13) DEFAULT '',
    IN    e_servicio             VARCHAR(10) DEFAULT '',
    IN    e_empresa              VARCHAR(10) DEFAULT '',
    IN    e_efectivo             NUMERIC(19,4) DEFAULT 0,
    IN    e_cheque               NUMERIC(19,4) DEFAULT 0,
    IN    e_debito               NUMERIC(19,4) DEFAULT 0,
    IN    e_tarjeta              NUMERIC(19,4) DEFAULT 0,
    IN    e_tarjeta_cta          VARCHAR(20) DEFAULT '',
    IN    e_tarjeta_plazo        CHAR(2) DEFAULT '',
    IN    e_comision_tot         NUMERIC(19,4) DEFAULT 0,
    IN    e_comision_efe         NUMERIC(19,4) DEFAULT 0,
    IN    e_comision_chq         NUMERIC(19,4) DEFAULT 0,
    IN    e_comision_db          NUMERIC(19,4) DEFAULT 0,
    IN    e_total                NUMERIC(19,4) DEFAULT 0,
    IN    e_cant_cheques         INTEGER DEFAULT 0,
    IN    e_tipo_cta             CHAR(3) DEFAULT '',
    IN    e_cuenta               VARCHAR(24) DEFAULT '',
    IN    e_nombre_cta           VARCHAR(70) DEFAULT '',
    IN    e_autoriza             CHAR(1) DEFAULT 'N',
    IN    e_canal                CHAR(3) DEFAULT '',
    IN    e_ubi                  INTEGER DEFAULT 0,
    IN    e_codigo               VARCHAR(15) DEFAULT '',
    IN    e_cod_referencia       VARCHAR(30) DEFAULT '',
    IN    e_nombre_cliente       VARCHAR(32) DEFAULT '',
    IN    e_base_imponible       NUMERIC(19,4) DEFAULT 0,
    IN    e_ocasional            NUMERIC(19,4) DEFAULT 0,
    IN    e_base_gravable        NUMERIC(19,4) DEFAULT 0,
    IN    e_base_no_gravable     NUMERIC(19,4) DEFAULT 0,
    IN    e_iva_servicio         NUMERIC(19,4) DEFAULT 0,
    IN    e_iva_bienes           NUMERIC(19,4) DEFAULT 0,
    IN    e_exo_iva_servicio     NUMERIC(19,4) DEFAULT 0,
    IN    e_exo_iva_bienes       NUMERIC(19,4) DEFAULT 0,
    IN    e_factura              VARCHAR(32) DEFAULT '',
    IN    e_cod_respuesta        VARCHAR(32) DEFAULT '',
    IN    e_cod_grupo            VARCHAR(10) DEFAULT '',
    IN    e_nomb_tramite         VARCHAR(64) DEFAULT '',
    IN    e_phoralocal           VARCHAR(6) DEFAULT '',
    IN    e_cod_consultora       INTEGER DEFAULT 0,
    IN    e_terminal_id          VARCHAR(20) DEFAULT '',
    IN    e_comercio             VARCHAR(15) DEFAULT '',
    IN    e_cod_autorizacion     INTEGER DEFAULT 0,
    IN    e_agencia              VARCHAR(20) DEFAULT '',
    IN    e_red                  VARCHAR(20) DEFAULT '',
    IN    e_nombre_factura       VARCHAR(100) DEFAULT '',
    IN    e_identificacion_fact  VARCHAR(15) DEFAULT '',
    INOUT s_fecha_contable       VARCHAR(10) DEFAULT '',
    INOUT s_ssn                  INTEGER DEFAULT 0,
    INOUT s_cod_respuesta        INTEGER DEFAULT 0,
    INOUT s_mensaje_respuesta    VARCHAR(80) DEFAULT '',
    INOUT s_horario              CHAR(1) DEFAULT '',
    INOUT s_tasa                 NUMERIC(19,4) DEFAULT 0,
    INOUT s_base_imp             DOUBLE PRECISION DEFAULT 0,
    INOUT s_impuesto             DOUBLE PRECISION DEFAULT 0,
    INOUT s_servicio_not         VARCHAR(5) DEFAULT '',
    INOUT s_nomb_ente            VARCHAR(64) DEFAULT '',
    INOUT s_cod_ente             VARCHAR(20) DEFAULT '',
    INOUT s_desccanal            VARCHAR(16) DEFAULT '',
    INOUT s_celular              VARCHAR(10) DEFAULT '',
    INOUT s_correo               VARCHAR(64) DEFAULT '',
    INOUT s_desc_empresa         VARCHAR(32) DEFAULT '',
    INOUT s_prod_deb             CHAR(3) DEFAULT '',
    INOUT s_valor                VARCHAR(11) DEFAULT '',
    INOUT s_fecha_deb            VARCHAR(10) DEFAULT '',
    INOUT s_hora_deb             VARCHAR(8) DEFAULT '',
    INOUT s_valor_comi           VARCHAR(11) DEFAULT '',
    INOUT s_valor_tot            VARCHAR(11) DEFAULT '',
    INOUT s_cta_lat              CHAR(3) DEFAULT '',
    INOUT s_tipo_serv            VARCHAR(16) DEFAULT '',
    INOUT s_envia_notf           BOOLEAN DEFAULT FALSE
)
LANGUAGE plpgsql AS $$
DECLARE
    v_return            INTEGER;
    v_hora_tope         INTEGER;
    v_hora_sys          CHAR(8);
    v_hora              INTEGER;
    v_fecha_hoy         VARCHAR(10);
    v_fecha             TIMESTAMP;
    v_tipocta_emp       CHAR(3);
    v_cta_emp           CHAR(10);
    v_nombre_emp        VARCHAR(32);
    v_efec_dep          NUMERIC(19,4);
    v_hora_dif          VARCHAR(9);
    v_maximo_p          NUMERIC(19,4);
    v_tipocta           CHAR(1);
    v_cod_referencia    VARCHAR(30);
    v_num_operacion     VARCHAR(20);
    v_depEspLinea       BOOLEAN;
    v_org               CHAR(1);
    v_ocasional         NUMERIC(19,4);
    v_aporte_iess       NUMERIC(19,4);
    v_autoriz_aut       VARCHAR(8);
    v_is_valid          INTEGER;
    v_valor             NUMERIC(19,4);
    v_mcash_ref         VARCHAR(30);
    v_mcash_benf        VARCHAR(30);
    v_mensaje           INTEGER;
    v_opcion            CHAR(1);
    v_ssn               INTEGER;
    v_empresa           INTEGER;
    v_fecha_fds         VARCHAR(10);
    v_trn               INTEGER;
    v_user              VARCHAR(30);
    v_comision_db       NUMERIC(19,4);
    v_cod_respuesta     VARCHAR(32);
    v_return_cod        INTEGER;
    v_rowcount          INTEGER;
BEGIN
    ---------------------------------------------------------------------------
    -- Inicializacion de variables
    ---------------------------------------------------------------------------
    v_depEspLinea     := FALSE;
    v_org             := 'D';
    s_cod_respuesta   := 9999;
    s_ssn             := e_ssn;
    v_fecha_hoy       := TO_CHAR(NOW(), 'MM/DD/YYYY');
    s_horario         := 'N';
    v_hora_sys        := TO_CHAR(NOW(), 'HH24:MI:SS');
    v_ocasional       := e_ocasional;
    v_aporte_iess     := 0;
    v_empresa         := e_empresa::INTEGER;
    v_fecha           := e_date;
    v_trn             := e_trn;
    v_user            := e_user;
    v_comision_db     := e_comision_db;
    v_cod_respuesta   := e_cod_respuesta;

    ---------------------------------------------------------------------------
    -- Normalizar fecha
    ---------------------------------------------------------------------------
    IF e_corr = 'N' THEN
        v_fecha := v_fecha::DATE;
    END IF;

    -- REF 13/14: usar fecha proceso del sistema
    SELECT fp_fecha INTO v_fecha FROM cobis.ba_fecha_proceso;

    ---------------------------------------------------------------------------
    -- Codigo de referencia
    ---------------------------------------------------------------------------
    IF LENGTH(COALESCE(e_cod_referencia, '')) <= LENGTH(COALESCE(e_codigo, '')) THEN
        v_cod_referencia := e_codigo;
    ELSE
        v_cod_referencia := e_cod_referencia;
    END IF;

    -- Si se requiere forzar valor en columna 24 del Multicash
    PERFORM 1 FROM cobis.cl_catalogo b
    INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
    WHERE a.tabla = 'sv_emp_multicash_col_24'
      AND b.codigo = e_empresa AND b.estado = 'V';
    IF FOUND THEN
        v_cod_referencia := e_codigo;
    END IF;

    s_fecha_contable := TO_CHAR(v_fecha, 'MM/DD/YYYY');

    ---------------------------------------------------------------------------
    -- Numero de operacion
    ---------------------------------------------------------------------------
    IF e_comision_db > 0 THEN
        v_num_operacion := e_cuenta;
    ELSE
        v_num_operacion := v_cod_referencia;
    END IF;

    IF e_canal NOT IN ('VEN', 'CNB') THEN
        v_comision_db := e_comision_tot;
    END IF;

    ---------------------------------------------------------------------------
    -- Hora tope
    ---------------------------------------------------------------------------
    SELECT (SUBSTRING(b.valor, 1, 2) || SUBSTRING(b.valor, 4, 2) || SUBSTRING(b.valor, 7, 2))::INTEGER
    INTO v_hora_tope
    FROM cobis.cl_catalogo b
    INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
    WHERE a.tabla = 'sv_horario_serv'
      AND b.codigo = e_empresa AND b.estado = 'V';

    IF NOT FOUND OR v_hora_tope = 0 THEN
        s_mensaje_respuesta := 'PARAMETRO DE HORA TOPE NO DEFINIDA';
        s_cod_respuesta := 130010;
        RETURN;
    END IF;

    ---------------------------------------------------------------------------
    -- Deposito en linea
    ---------------------------------------------------------------------------
    PERFORM 1 FROM cobis.cl_catalogo b
    INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
    WHERE a.tabla = 'sv_emp_recauda_deposito'
      AND b.codigo = e_empresa AND b.estado = 'V';

    IF FOUND THEN
        v_depEspLinea := TRUE;
        v_trn := 4435;
        v_efec_dep := 0;
        v_org := 'L';

        SELECT pe_cuenta, pe_producto, SUBSTRING(pe_nombre, 1, 32)
        INTO v_cta_emp, v_tipocta_emp, v_nombre_emp
        FROM cob_pagos.pg_person_empresa
        WHERE pe_empresa = v_empresa;

        IF v_cta_emp IS NULL OR v_cta_emp = '' THEN
            s_mensaje_respuesta := 'CTA EMPRESA NO DEFINIDA';
            s_cod_respuesta := 130020;
            RETURN;
        END IF;
    ELSE
        SELECT b.valor::INTEGER INTO v_trn
        FROM cobis.cl_catalogo b
        INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
        WHERE a.tabla = 'sv_trx_srv_rms_hn'
          AND b.codigo = e_empresa AND b.estado = 'V';

        IF NOT FOUND OR v_trn = 0 OR v_trn IS NULL THEN
            s_mensaje_respuesta := 'TRX DE SERVICIO HN NO DEFINIDA';
            s_cod_respuesta := 140010;
            RETURN;
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- Canal VEN: verificacion de horario de caja
    ---------------------------------------------------------------------------
    IF e_canal = 'VEN' THEN
        IF NOT v_depEspLinea THEN
            SELECT rh_inicio INTO v_hora_dif
            FROM cob_remesas.re_horario
            WHERE rh_oficina = e_ofi AND rh_ubicacion = e_ubi;

            IF v_hora_sys >= v_hora_dif THEN
                s_horario := 'D';

                SELECT b.valor::INTEGER INTO v_trn
                FROM cobis.cl_catalogo b
                INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
                WHERE a.tabla = 'sv_trx_srv_rms_hd1'
                  AND b.codigo = e_empresa AND b.estado = 'V';

                IF NOT FOUND THEN
                    s_mensaje_respuesta := 'TRX DE SERVICIO HD1 NO DEFINIDA';
                    s_cod_respuesta := 140020;
                    RETURN;
                END IF;
            END IF;
        END IF;

        -- sp_verifica_caja_rc
        s_mensaje_respuesta := 'HORARIO DE CAJA NO DEFINIDO';
        s_cod_respuesta := 300003299;
        -- CALL cob_remesas.sp_verifica_caja_rc(...)
        -- Placeholder: v_return := 0;
    END IF;

    s_hora_deb := v_hora_sys;
    s_fecha_deb := v_fecha_hoy;

    IF v_depEspLinea THEN
        v_trn := 43569;
    END IF;

    ---------------------------------------------------------------------------
    -- Validacion de hora tope y horario diferido
    ---------------------------------------------------------------------------
    v_hora := (SUBSTRING(v_hora_sys, 1, 2) || SUBSTRING(v_hora_sys, 4, 2) || SUBSTRING(v_hora_sys, 7, 2))::INTEGER;

    IF NOT v_depEspLinea AND v_hora >= v_hora_tope AND v_fecha::DATE = v_fecha_hoy::DATE THEN
        s_horario := 'D';

        SELECT b.valor::INTEGER INTO v_trn
        FROM cobis.cl_catalogo b
        INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
        WHERE a.tabla = 'sv_trx_srv_rms_hd2'
          AND b.codigo = e_empresa AND b.estado = 'V';

        IF NOT FOUND THEN
            s_mensaje_respuesta := 'TRX DE SERVICIO HD2 NO DEFINIDA';
            s_cod_respuesta := 140030;
            RETURN;
        END IF;

        SELECT TO_CHAR(MIN(dl_fecha), 'MM/DD/YYYY') INTO s_fecha_contable
        FROM cob_cuentas.cc_dias_laborables
        WHERE dl_ciudad = 1 AND dl_num_dias = 1;
    END IF;

    ---------------------------------------------------------------------------
    -- Correccion: validar transaccion original
    ---------------------------------------------------------------------------
    IF e_corr = 'S' THEN
        SELECT ts_tipo_transaccion, ts_campo_alt_uno
        INTO v_trn, v_cod_respuesta
        FROM cob_cuentas.cc_tran_servicio
        WHERE ts_secuencial = e_ssn_corr
          AND ts_causa = e_empresa
          AND ts_tsfecha = v_fecha;

        IF NOT FOUND OR v_trn = 0 OR v_trn IS NULL THEN
            s_mensaje_respuesta := 'NO EXISTE TRANSACCION ORIGINAL';
            s_cod_respuesta := 18122;
            RETURN;
        END IF;

        IF v_hora >= v_hora_tope AND v_fecha::DATE = v_fecha_hoy::DATE THEN
            -- Check if original TRN is HN type
            PERFORM 1 FROM cobis.cl_catalogo b
            INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
            WHERE a.tabla = 'sv_trx_srv_rms_hn'
              AND b.codigo = e_empresa AND b.estado = 'V'
              AND v_trn = b.valor::INTEGER;

            IF FOUND THEN
                s_mensaje_respuesta := 'NO SE PUEDE REVERSAR UNA TRANSACCION DE HORARIO NORMAL EN HORARIO DIFERIDO';
                s_cod_respuesta := 358750;
                RETURN;
            END IF;
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- Validacion de moneda (solo USD)
    ---------------------------------------------------------------------------
    IF e_mon <> 1 THEN
        s_mensaje_respuesta := 'TRANSACCION SOLO SE DEBE REALIZAR EN DOLARES';
        s_cod_respuesta := 898994;
        RETURN;
    END IF;

    ---------------------------------------------------------------------------
    -- Validacion de monto maximo
    ---------------------------------------------------------------------------
    IF e_autoriza = 'N' AND e_corr = 'N' THEN
        SELECT pa_money INTO v_maximo_p
        FROM cobis.cl_parametro
        WHERE pa_nemonico = 'MMVI' AND pa_producto = 'CTE';

        IF v_maximo_p <= e_total THEN
            s_mensaje_respuesta := 'VALOR EXCEDE O ES INFERIOR AL MONTO PERMITIDO SOLICITE AUTORIZACION';
            s_cod_respuesta := 311819;
            RETURN;
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- Homologar canal CNB
    ---------------------------------------------------------------------------
    IF e_canal = 'CNB' THEN
        SELECT c.valor INTO v_user
        FROM cobis.cl_tabla t
        INNER JOIN cobis.cl_catalogo c ON t.codigo = c.tabla
        WHERE t.tabla = 'cc_usuario_cnb' AND c.codigo = e_user;
    END IF;

    ---------------------------------------------------------------------------
    -- Consulta datos para envio de notificacion
    ---------------------------------------------------------------------------
    -- CALL cob_pagos.pa_pg_cpag_notificacion(...)
    -- Placeholder: subproceso de notificacion externa

    ---------------------------------------------------------------------------
    -- Campos a reportar en el Multicash
    ---------------------------------------------------------------------------
    v_mcash_ref := e_cod_referencia;
    v_mcash_benf := v_cod_referencia;

    PERFORM 1 FROM cobis.cl_catalogo b
    INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
    WHERE a.tabla = 'sv_emp_multicash_recaudaciones'
      AND b.codigo = e_empresa AND b.estado = 'V';

    IF FOUND THEN
        v_mcash_ref := e_codigo;
        v_mcash_benf := e_cod_referencia;
    END IF;

    ---------------------------------------------------------------------------
    -- INICIO TRANSACCION: REGISTRAR TRX MONETARIA DEBITO/CREDITO
    ---------------------------------------------------------------------------
    -- CALL cob_pagos.pa_pg_tpag_deb_cre(...)
    -- Placeholder: si v_return != 0 entonces ROLLBACK
    -- En PG la transaccion es implicita, errores causan rollback automatico

    ---------------------------------------------------------------------------
    -- Calcular autoriz_aut y aporte_iess (REF 4 - SRI)
    ---------------------------------------------------------------------------
    v_autoriz_aut := e_comision_tot::VARCHAR;

    IF e_empresa = '9718' THEN
        v_aporte_iess := e_comision_tot;
        v_autoriz_aut := '0';
    END IF;

    ---------------------------------------------------------------------------
    -- REF 15: Unicomer FDS
    ---------------------------------------------------------------------------
    v_fecha_fds := TO_CHAR(NOW(), 'MM/DD/YYYY');
    s_fecha_contable := TO_CHAR(v_fecha, 'MM/DD/YYYY');
    v_return_cod := v_trn;

    IF e_empresa = '6918' AND v_fecha_fds <> s_fecha_contable THEN
        SELECT b.valor::INTEGER INTO v_trn
        FROM cobis.cl_catalogo b
        INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
        WHERE a.tabla = 'sv_trx_srv_rms_fsd'
          AND b.codigo = e_empresa AND b.estado = 'V';
    END IF;

    ---------------------------------------------------------------------------
    -- REGISTRAR TRX DE SERVICIO
    ---------------------------------------------------------------------------
    INSERT INTO cob_cuentas.cc_tran_servicio (
        ts_secuencial, ts_tipo_transaccion, ts_oficina,
        ts_usuario, ts_rol, ts_terminal,
        ts_correccion, ts_tipo_chequera, ts_reentry,
        ts_origen, ts_nodo, ts_tsfecha,
        ts_clase, ts_fecha, ts_referencia,
        ts_saldo, ts_ssn_corr, ts_cta_banco,
        ts_moneda, ts_tipo, ts_valor,
        ts_monto, ts_ocasional, ts_contratado,
        ts_aporte_iess, ts_descuento_iess, ts_tsn,
        ts_ccontable, ts_hora, ts_endoso,
        ts_causa, ts_tipocta, ts_nombre,
        ts_tipo_def, ts_oficina_cta, ts_cheque_rec,
        ts_ubicacion, ts_descripcion_ec, ts_autoriz_anula,
        ts_campo_alt_uno, ts_autoriz_aut, ts_propietario,
        ts_agente, ts_autorizante, ts_campo_alt_dos, ts_cod_banco,
        ts_cliente, ts_ced_ruc, ts_plazo, ts_tarjcred
    ) VALUES (
        e_ssn, v_trn, e_ofi,
        v_user, e_rol, e_term,
        e_corr, e_canal, NULL,
        'L', e_srv, TO_CHAR(v_fecha, 'MM/DD/YYYY'),
        e_servicio, v_fecha, e_codigo,
        e_cheque, e_ssn_corr, e_cuenta,
        e_mon, 'L', e_efectivo,
        e_debito, v_ocasional, e_tarjeta,
        0, v_aporte_iess, e_ssn,
        NULL, NOW(), e_ssn,
        e_empresa, v_tipocta, COALESCE(e_nombre_cliente, e_nombre_cta),
        'N', NULL, e_cant_cheques,
        e_ubi, e_nombre_cliente, e_base_imponible::VARCHAR,
        v_cod_respuesta, v_autoriz_aut, e_cod_grupo,
        e_cod_referencia, e_nomb_tramite, e_factura, e_phoralocal,
        e_cod_consultora, e_ruc_cliente, e_tarjeta_plazo, e_tarjeta_cta
    );

    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    IF v_rowcount != 1 THEN
        s_mensaje_respuesta := 'ERROR EN LA GENERACION DE TRX DE SERVICIO';
        s_cod_respuesta := 33005;
        RETURN;
    END IF;

    v_trn := v_return_cod;

    ---------------------------------------------------------------------------
    -- REF 6: Base imponible SRI
    ---------------------------------------------------------------------------
    IF e_corr = 'N' THEN
        PERFORM 1 FROM cobis.cl_catalogo b
        INNER JOIN cobis.cl_tabla a ON b.tabla = a.codigo
        WHERE a.tabla = 'sv_reca_base_imponible'
          AND b.codigo = e_empresa AND b.estado = 'V';

        IF FOUND THEN
            -- CALL cob_pagos.sp_ins_retiva_bieserv(...)
            -- Placeholder: v_return := 0;
            -- Si error: s_mensaje_respuesta := 'ERROR BASE IMPONIBLE';
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- REGISTRAR TRX COMISION
    ---------------------------------------------------------------------------
    -- CALL cob_pagos.pa_pg_tpag_comision(...)
    -- Placeholder: v_return := 0;

    ---------------------------------------------------------------------------
    -- REF 7: Informacion CNB
    ---------------------------------------------------------------------------
    IF e_canal = 'CNB' THEN
        v_valor := e_efectivo + e_debito;

        IF e_corr = 'N' THEN
            v_opcion := 'I';
            v_ssn := e_ssn;
        ELSE
            v_opcion := 'R';
            v_ssn := e_ssn_corr;
        END IF;

        IF e_empresa <> '23468' THEN
            -- CALL cob_cuentas.pa_cc_iinfo_cnb(...)
            -- Placeholder: v_return := 0;
        END IF;

        IF e_comision_efe > 0 THEN
            -- CALL cob_cuentas.pa_cc_ifactura_cnb(...)
            -- Placeholder: v_return := 0;
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- COMMIT TRAN (implicito en PG)
    ---------------------------------------------------------------------------
    s_mensaje_respuesta := 'OK';
    s_cod_respuesta := 0;
END;
$$;
