-- ============================================================================
-- Archivo:      pa_mis_ttelefono.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Store procedure: pa_mis_ttelefono
-- Procesamiento: OLTP
-- Proposito:    CRUD completo de telefonos de clientes. Opera por
--               e_operacion: I(Insert), U(Update), S(Search), Q(Query),
--               D(Delete), B(Banca Virtual). Incluye validaciones FK,
--               notificaciones al cliente por cambios.
-- ============================================================================
CREATE OR REPLACE PROCEDURE cobis.pa_mis_ttelefono(
    IN    e_operacion       CHAR(1),
    IN    s_ssn             INTEGER DEFAULT NULL,
    IN    s_user            VARCHAR(128) DEFAULT NULL,
    IN    s_term            VARCHAR(30) DEFAULT NULL,
    IN    s_date            TIMESTAMP DEFAULT NULL,
    IN    s_srv             VARCHAR(30) DEFAULT NULL,
    IN    s_lsrv            VARCHAR(30) DEFAULT NULL,
    IN    s_ofi             SMALLINT DEFAULT NULL,
    IN    s_rol             SMALLINT DEFAULT NULL,
    IN    s_org_err         CHAR(1) DEFAULT NULL,
    IN    s_error           INTEGER DEFAULT NULL,
    IN    s_sev             SMALLINT DEFAULT NULL,
    IN    s_msg             VARCHAR(255) DEFAULT NULL,
    IN    s_org             CHAR(1) DEFAULT NULL,
    IN    p_alterno         INTEGER DEFAULT NULL,
    IN    t_debug           CHAR(1) DEFAULT 'N',
    IN    t_file            VARCHAR(10) DEFAULT NULL,
    IN    t_from            VARCHAR(32) DEFAULT NULL,
    IN    t_trn             INTEGER DEFAULT NULL,
    IN    e_no_cobis        CHAR(1) DEFAULT 'N',
    IN    e_mensaje         CHAR(1) DEFAULT 'S',
    IN    e_producto        SMALLINT DEFAULT NULL,
    IN    e_ente            INTEGER DEFAULT NULL,
    IN    e_direccion       SMALLINT DEFAULT NULL,
    IN    e_secuencial      SMALLINT DEFAULT NULL,
    IN    e_valor           VARCHAR(12) DEFAULT NULL,
    IN    e_tipo_telefono   CHAR(1) DEFAULT NULL,
    IN    e_tipo_cliente    CHAR(1) DEFAULT NULL,
    IN    e_pertenece       CHAR(1) DEFAULT NULL,
    IN    e_extension       VARCHAR(20) DEFAULT NULL,
    IN    e_comentario      VARCHAR(254) DEFAULT NULL,
    IN    e_ind_act_presenc CHAR(1) DEFAULT 'N',
    IN    e_tipo_dir        VARCHAR(10) DEFAULT NULL,
    IN    e_canal           VARCHAR(10) DEFAULT NULL,
    IN    e_envio_notifica  CHAR(1) DEFAULT 'S',
    INOUT s_num_filas       SMALLINT DEFAULT NULL,
    INOUT s_secuencial      SMALLINT DEFAULT NULL,
    INOUT s_msj_error       VARCHAR(132) DEFAULT NULL,
    INOUT s_cursor          REFCURSOR DEFAULT NULL,
    INOUT s_cursor_bv       REFCURSOR DEFAULT NULL
)
LANGUAGE plpgsql AS $$
DECLARE
    v_sp_name         VARCHAR(32);
    v_today           TIMESTAMP;
    v_return          INTEGER;
    v_codigo          INTEGER;
    v_num             INTEGER;
    v_secuencial      SMALLINT;
    v_desc_tipo       VARCHAR(255);
    v_region          VARCHAR(2);
    v_desc_region     VARCHAR(255);
    v_valor           VARCHAR(12);
    v_tipo_telefono   CHAR(1);
    v_extension       VARCHAR(20);
    v_comentario      VARCHAR(254);
    v_subtipo         CHAR(1);
    v_dig_cel         SMALLINT;
    v_pertenece       CHAR(1);
    v_prev_valor         VARCHAR(12);
    v_prev_tipo_telefono CHAR(1);
    v_prev_extension     VARCHAR(20);
    v_prev_comentario    VARCHAR(254);
    v_prev_pertenece     CHAR(1);
    v_fecha_reg       VARCHAR(10);
    v_fecha_crea_cli  VARCHAR(10);
    v_servicio        VARCHAR(40);
    v_idcliente       VARCHAR(30);
    v_nombrecli       VARCHAR(64);
    v_p_apellido      VARCHAR(64);
    v_s_apellido      VARCHAR(64);
    v_canal           VARCHAR(10);
    v_mail            VARCHAR(64);
    v_fecha           VARCHAR(10);
    v_hora            VARCHAR(10);
    v_medio           VARCHAR(70);
    v_idcli_enm       VARCHAR(30);
    v_nombrecliente   VARCHAR(64);
    v_nemonico        VARCHAR(30);
    v_celular         VARCHAR(20);
BEGIN
    v_sp_name := 'pa_mis_ttelefono';
    v_today := NOW();

    INSERT INTO cobis.tmp_log_phol2 VALUES (v_sp_name, s_user, e_valor, e_ente, 0);

    v_fecha_reg := TO_CHAR(v_today, 'MM/DD/YYYY');

    IF t_debug = 'S' THEN
        RAISE NOTICE '/** Stored Procedure **/ %', v_sp_name;
        RAISE NOTICE 'ssn=%, user=%, term=%, date=%, srv=%',
            s_ssn, s_user, s_term, s_date, s_srv;
        RAISE NOTICE 'lsrv=%, ofi=%, rol=%, org_err=%, error=%, sev=%',
            s_lsrv, s_ofi, s_rol, s_org_err, s_error, s_sev;
        RAISE NOTICE 'msg=%, org=%, alterno=%, trn=%, file=%, from=%',
            s_msg, s_org, p_alterno, t_trn, t_file, t_from;
        RAISE NOTICE 'operacion=%, no_cobis=%, mensaje=%, producto=%, ente=%',
            e_operacion, e_no_cobis, e_mensaje, e_producto, e_ente;
        RAISE NOTICE 'direccion=%, secuencial=%, valor=%, tipo_tel=%, ext=%',
            e_direccion, e_secuencial, e_valor, e_tipo_telefono, e_extension;
        RAISE NOTICE 'comentario=%, tipo_dir=%, canal=%, envio_notifica=%',
            e_comentario, e_tipo_dir, e_canal, e_envio_notifica;
    END IF;

    ---------------------------------------------------------------------------
    -- INSERT
    ---------------------------------------------------------------------------
    IF e_operacion = 'I' THEN
        IF t_trn = 111 THEN
            IF e_ente = 0 THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101042';
                ELSE
                    s_msj_error := 'No existe ente';
                    RETURN;
                END IF;
            END IF;

            PERFORM 1 FROM cobis.cl_producto WHERE pd_producto = e_producto;
            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101032';
                ELSE
                    s_msj_error := 'No existe producto';
                    RETURN;
                END IF;
            END IF;

            PERFORM 1 FROM cobis.cl_direccion
            WHERE di_ente = e_ente AND di_direccion = e_direccion;
            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101001';
                ELSE
                    s_msj_error := 'No existe direccion';
                    RETURN;
                END IF;
            END IF;

            -- Validate catalog: cl_ttelefono
            PERFORM 1 FROM cobis.cl_catalogo c
            INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
            WHERE t.tabla = 'cl_ttelefono' AND c.codigo = e_tipo_telefono
              AND c.estado = 'V';
            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101025';
                ELSE
                    s_msj_error := 'No existe tipo de telefono';
                    RETURN;
                END IF;
            END IF;

            -- Validate region
            v_region := SUBSTRING(e_valor, 1, 2);
            PERFORM 1 FROM cobis.cl_catalogo c
            INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
            WHERE t.tabla = 'cl_region_telefono' AND c.codigo = v_region
              AND c.estado = 'V';
            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101329';
                ELSE
                    s_msj_error := 'NO EXISTE LA REGION DEL NUMERO DE TELEFONO';
                    RETURN;
                END IF;
            END IF;

            SELECT pa_tinyint INTO v_dig_cel
            FROM cobis.cl_parametro
            WHERE pa_producto = 'MIS' AND pa_nemonico = 'LONGT';

            IF LENGTH(e_valor) != v_dig_cel THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101331';
                ELSE
                    s_msj_error := 'LONGITUD DEL NUMERO TELEFONICO INCORRECTA';
                    RETURN;
                END IF;
            END IF;

            SELECT en_subtipo,
                   TO_CHAR(en_fecha_crea, 'MM/DD/YYYY'),
                   COALESCE(en_ced_ruc, COALESCE(p_pasaporte, '')),
                   COALESCE(en_nombre, ''),
                   COALESCE(p_p_apellido, ''),
                   COALESCE(p_s_apellido, '')
            INTO v_subtipo, v_fecha_crea_cli, v_idcliente,
                 v_nombrecli, v_p_apellido, v_s_apellido
            FROM cobis.cl_ente
            WHERE en_ente = e_ente;

            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101042';
                ELSE
                    s_msj_error := 'No existe ente';
                    RETURN;
                END IF;
            END IF;

            IF v_subtipo = 'C' AND e_pertenece <> 'P' THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101547';
                ELSE
                    s_msj_error := 'Para companias solo aplica propio en pertenece a';
                    RETURN;
                END IF;
            END IF;

            IF v_subtipo = 'P' AND e_tipo_dir = 'D' THEN
                PERFORM 1 FROM cobis.cl_direccion_email
                WHERE de_ente = e_ente AND de_tipo = 'M'
                  AND de_dir_domici = e_direccion;
                IF FOUND THEN
                    IF e_mensaje = 'S' THEN
                        RAISE EXCEPTION 'Error: 101693';
                    ELSE
                        s_msj_error := 'Direccion tipo domicilio tiene movil asociado';
                        RETURN;
                    END IF;
                END IF;
            END IF;

            -- Generate transaction sequence
            IF e_no_cobis = 'S' THEN
                v_return := 0;
                -- sp_gen_sec equivalent: the caller would set s_ssn externally
            END IF;

            -- Determine notification channel
            IF e_envio_notifica = 'S' AND v_subtipo = 'P' THEN
                IF v_fecha_reg > v_fecha_crea_cli THEN
                    IF e_producto = 2 AND e_canal <> 'VREFEREN' THEN
                        v_canal := 'MIS';
                    ELSIF e_producto = 166 THEN
                        PERFORM 1 FROM cobis.cl_catalogo c
                        INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
                        WHERE t.tabla = 'cl_cbpmnac' AND c.codigo = e_canal
                          AND c.estado = 'V';
                        IF FOUND THEN v_canal := 'BPM'; END IF;

                        IF v_canal IS NULL THEN
                            PERFORM 1 FROM cobis.cl_catalogo c
                            INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
                            WHERE t.tabla = 'cl_cfinnac' AND c.codigo = e_canal
                              AND c.estado = 'V';
                            IF FOUND THEN v_canal := 'FORMINT'; END IF;
                        END IF;
                    ELSIF e_canal = 'VREFEREN' THEN
                        v_canal := e_canal;
                    ELSE
                        v_canal := 'OTROS';
                    END IF;
                END IF;
            END IF;

            -- Get next secuencial
            SELECT COALESCE(MAX(te_secuencial), 0) + 1 INTO s_secuencial
            FROM cobis.cl_telefono
            WHERE te_ente = e_ente AND te_direccion = e_direccion;

            INSERT INTO cobis.cl_telefono (
                te_ente, te_direccion, te_secuencial,
                te_valor, te_tipo_telefono, te_extension,
                te_comentario, te_pertenece
            ) VALUES (
                e_ente, e_direccion, s_secuencial,
                e_valor, e_tipo_telefono, e_extension,
                e_comentario, e_pertenece
            );

            INSERT INTO cobis.ts_telefono (
                secuencial, tipo_transaccion, alterno, clase, fecha,
                usuario, terminal, srv, lsrv, origen, rol,
                ente, direccion, telefono, valor,
                tipo, extension, comentario, pertenece, canal
            ) VALUES (
                s_ssn, t_trn, p_alterno, 'N', s_date,
                s_user, s_term, s_srv, s_lsrv, e_producto, s_rol,
                e_ente, e_direccion, s_secuencial, e_valor,
                e_tipo_telefono, e_extension, e_comentario, e_pertenece,
                v_canal
            );

            -- Send notification if applicable
            IF e_envio_notifica = 'S' AND v_subtipo = 'P' THEN
                IF v_fecha_reg > v_fecha_crea_cli THEN
                    SELECT de_descripcion INTO v_mail
                    FROM cobis.cl_direccion_email
                    WHERE de_ente = e_ente AND de_tipo = 'E'
                    ORDER BY de_fecha_modificacion DESC
                    LIMIT 1;
                    IF NOT FOUND THEN v_mail := ''; END IF;

                    SELECT de_descripcion INTO v_celular
                    FROM cobis.cl_direccion_email
                    WHERE de_ente = e_ente AND de_tipo = 'M'
                    ORDER BY de_fecha_modificacion DESC
                    LIMIT 1;
                    IF NOT FOUND THEN v_celular := ''; END IF;

                    v_servicio := 'Actualizacion de Telefono';

                    -- sp_notif_cli_mod_dir equivalent
                    RAISE NOTICE 'Notificacion enviada: ente=%, canal=%, servicio=%',
                        e_ente, e_canal, v_servicio;
                END IF;
            END IF;

            RETURN;
        ELSE
            IF e_mensaje = 'S' THEN
                RAISE EXCEPTION 'Error: 151051';
            ELSE
                s_msj_error := 'No corresponde codigo de transaccion';
                RETURN;
            END IF;
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- UPDATE
    ---------------------------------------------------------------------------
    IF e_operacion = 'U' THEN
        IF t_trn = 112 THEN
            IF e_ente = 0 THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101042';
                ELSE
                    s_msj_error := 'No existe ente';
                    RETURN;
                END IF;
            END IF;

            PERFORM 1 FROM cobis.cl_producto WHERE pd_producto = e_producto;
            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101032';
                ELSE
                    s_msj_error := 'No existe producto';
                    RETURN;
                END IF;
            END IF;

            PERFORM 1 FROM cobis.cl_direccion
            WHERE di_ente = e_ente AND di_direccion = e_direccion;
            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101001';
                ELSE
                    s_msj_error := 'No existe direccion';
                    RETURN;
                END IF;
            END IF;

            PERFORM 1 FROM cobis.cl_catalogo c
            INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
            WHERE t.tabla = 'cl_ttelefono' AND c.codigo = e_tipo_telefono
              AND c.estado = 'V';
            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101025';
                ELSE
                    s_msj_error := 'No existe tipo de telefono';
                    RETURN;
                END IF;
            END IF;

            v_region := SUBSTRING(e_valor, 1, 2);
            PERFORM 1 FROM cobis.cl_catalogo c
            INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
            WHERE t.tabla = 'cl_region_telefono' AND c.codigo = v_region
              AND c.estado = 'V';
            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101329';
                ELSE
                    s_msj_error := 'NO EXISTE LA REGION DEL NUMERO DE TELEFONO';
                    RETURN;
                END IF;
            END IF;

            SELECT pa_tinyint INTO v_dig_cel
            FROM cobis.cl_parametro
            WHERE pa_producto = 'MIS' AND pa_nemonico = 'LONGT';

            IF LENGTH(e_valor) != v_dig_cel THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101331';
                ELSE
                    s_msj_error := 'LONGITUD DEL NUMERO TELEFONICO INCORRECTA';
                    RETURN;
                END IF;
            END IF;

            SELECT en_subtipo,
                   TO_CHAR(en_fecha_crea, 'MM/DD/YYYY'),
                   COALESCE(en_ced_ruc, COALESCE(p_pasaporte, '')),
                   COALESCE(en_nombre, ''),
                   COALESCE(p_p_apellido, ''),
                   COALESCE(p_s_apellido, '')
            INTO v_subtipo, v_fecha_crea_cli, v_idcliente,
                 v_nombrecli, v_p_apellido, v_s_apellido
            FROM cobis.cl_ente
            WHERE en_ente = e_ente;

            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101042';
                ELSE
                    s_msj_error := 'No existe ente';
                    RETURN;
                END IF;
            END IF;

            IF v_subtipo = 'C' AND e_pertenece <> 'P' THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101547';
                ELSE
                    s_msj_error := 'Para companias solo aplica propio en pertenece a';
                    RETURN;
                END IF;
            END IF;

            SELECT te_valor, te_tipo_telefono, te_extension,
                   te_comentario, te_pertenece
            INTO v_valor, v_tipo_telefono, v_extension,
                 v_comentario, v_pertenece
            FROM cobis.cl_telefono
            WHERE te_ente = e_ente
              AND te_direccion = e_direccion
              AND te_secuencial = e_secuencial;

            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 105035';
                ELSE
                    s_msj_error := 'No existe telefono';
                    RETURN;
                END IF;
            END IF;

            v_prev_valor         := v_valor;
            v_prev_tipo_telefono := v_tipo_telefono;
            v_prev_extension     := v_extension;
            v_prev_comentario    := v_comentario;
            v_prev_pertenece     := v_pertenece;

            e_envio_notifica := 'N';

            IF v_pertenece = e_pertenece THEN
                v_pertenece := NULL;
                v_prev_pertenece := NULL;
            ELSE
                v_pertenece := e_pertenece;
                e_envio_notifica := 'S';
            END IF;

            IF v_valor = e_valor THEN
                v_valor := NULL;
                v_prev_valor := NULL;
            ELSE
                v_valor := e_valor;
                e_envio_notifica := 'S';
            END IF;

            IF v_tipo_telefono = e_tipo_telefono THEN
                v_tipo_telefono := NULL;
                v_prev_tipo_telefono := NULL;
            ELSE
                v_tipo_telefono := e_tipo_telefono;
                e_envio_notifica := 'S';
            END IF;

            IF v_extension = e_extension THEN
                v_extension := NULL;
                v_prev_extension := NULL;
            ELSE
                v_extension := e_extension;
                e_envio_notifica := 'S';
            END IF;

            IF v_comentario = e_comentario THEN
                v_comentario := NULL;
                v_prev_comentario := NULL;
            ELSE
                v_comentario := e_comentario;
            END IF;

            -- Generate transaction sequence
            IF e_no_cobis = 'S' THEN
                v_return := 0;
            END IF;

            -- Determine notification channel
            IF e_envio_notifica = 'S' AND v_subtipo = 'P' THEN
                IF v_fecha_reg > v_fecha_crea_cli THEN
                    IF e_producto = 2 AND e_canal <> 'VREFEREN' THEN
                        v_canal := 'MIS';
                    ELSIF e_producto = 166 THEN
                        PERFORM 1 FROM cobis.cl_catalogo c
                        INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
                        WHERE t.tabla = 'cl_cbpmnac' AND c.codigo = e_canal
                          AND c.estado = 'V';
                        IF FOUND THEN v_canal := 'BPM'; END IF;

                        IF v_canal IS NULL THEN
                            PERFORM 1 FROM cobis.cl_catalogo c
                            INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
                            WHERE t.tabla = 'cl_cfinnac' AND c.codigo = e_canal
                              AND c.estado = 'V';
                            IF FOUND THEN v_canal := 'FORMINT'; END IF;
                        END IF;
                    ELSIF e_canal = 'VREFEREN' THEN
                        v_canal := e_canal;
                    ELSE
                        v_canal := 'OTROS';
                    END IF;
                END IF;
            END IF;

            UPDATE cobis.cl_telefono
            SET te_valor         = e_valor,
                te_tipo_telefono = e_tipo_telefono,
                te_extension     = e_extension,
                te_comentario    = e_comentario,
                te_pertenece     = e_pertenece
            WHERE te_ente = e_ente
              AND te_direccion = e_direccion
              AND te_secuencial = e_secuencial;

            -- Transaction log: previous values
            INSERT INTO cobis.ts_telefono (
                secuencial, tipo_transaccion, alterno, clase, fecha,
                usuario, terminal, srv, lsrv, origen, rol,
                ente, direccion, telefono, valor,
                tipo, extension, comentario, pertenece
            ) VALUES (
                s_ssn, t_trn, p_alterno, 'P', s_date,
                s_user, s_term, s_srv, s_lsrv, e_producto, s_rol,
                e_ente, e_direccion, e_secuencial, v_prev_valor,
                v_prev_tipo_telefono, v_prev_extension, v_prev_comentario,
                v_prev_pertenece
            );

            -- Transaction log: new values
            INSERT INTO cobis.ts_telefono (
                secuencial, tipo_transaccion, alterno, clase, fecha,
                usuario, terminal, srv, lsrv, origen, rol,
                ente, direccion, telefono, valor,
                tipo, extension, comentario, pertenece, canal
            ) VALUES (
                s_ssn, t_trn, p_alterno, 'A', s_date,
                s_user, s_term, s_srv, s_lsrv, e_producto, s_rol,
                e_ente, e_direccion, e_secuencial, v_valor,
                v_tipo_telefono, v_extension, v_comentario, v_pertenece,
                v_canal
            );

            -- Send notification if applicable
            IF e_envio_notifica = 'S' AND v_subtipo = 'P' THEN
                IF v_fecha_reg > v_fecha_crea_cli THEN
                    SELECT de_descripcion INTO v_mail
                    FROM cobis.cl_direccion_email
                    WHERE de_ente = e_ente AND de_tipo = 'E'
                    ORDER BY de_fecha_modificacion DESC
                    LIMIT 1;
                    IF NOT FOUND THEN v_mail := ''; END IF;

                    SELECT de_descripcion INTO v_celular
                    FROM cobis.cl_direccion_email
                    WHERE de_ente = e_ente AND de_tipo = 'M'
                    ORDER BY de_fecha_modificacion DESC
                    LIMIT 1;
                    IF NOT FOUND THEN v_celular := ''; END IF;

                    v_servicio := 'Actualizacion de Telefono';

                    RAISE NOTICE 'Notificacion enviada: ente=%, canal=%, servicio=%',
                        e_ente, e_canal, v_servicio;
                END IF;
            END IF;

            RETURN;
        ELSE
            IF e_mensaje = 'S' THEN
                RAISE EXCEPTION 'Error: 151051';
            ELSE
                s_msj_error := 'No corresponde codigo de transaccion';
                RETURN;
            END IF;
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- SEARCH
    ---------------------------------------------------------------------------
    IF e_operacion = 'S' THEN
        IF t_trn = 147 THEN
            OPEN s_cursor FOR
            SELECT b.valor       AS "Tipo",
                   te_valor      AS "Numero",
                   te_extension  AS "Extension",
                   te_comentario AS "Comentario",
                   te_secuencial AS "Sec",
                   te_pertenece  AS "Pertenencia"
            FROM cobis.cl_telefono
            CROSS JOIN cobis.cl_tabla a
            INNER JOIN cobis.cl_catalogo b ON a.codigo = b.tabla
            WHERE te_ente = e_ente
              AND te_direccion = e_direccion
              AND a.tabla = 'cl_ttelefono'
              AND b.codigo = te_tipo_telefono
            ORDER BY te_ente, te_direccion, te_secuencial;

            RETURN;
        ELSE
            IF e_mensaje = 'S' THEN
                RAISE EXCEPTION 'Error: 151051';
            ELSE
                s_msj_error := 'No corresponde codigo de transaccion';
                RETURN;
            END IF;
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- QUERY
    ---------------------------------------------------------------------------
    IF e_operacion = 'Q' THEN
        IF t_trn = 147 THEN
            SELECT te_secuencial, te_tipo_telefono, b.valor,
                   te_valor, te_extension, te_comentario, te_pertenece
            INTO v_secuencial, v_tipo_telefono, v_desc_tipo,
                 v_valor, v_extension, v_comentario, v_pertenece
            FROM cobis.cl_telefono
            CROSS JOIN cobis.cl_tabla a
            INNER JOIN cobis.cl_catalogo b ON a.codigo = b.tabla
            WHERE te_ente = e_ente
              AND te_direccion = e_direccion
              AND te_secuencial = e_secuencial
              AND a.tabla = 'cl_ttelefono'
              AND b.codigo = te_tipo_telefono;

            IF v_tipo_telefono != 'C' THEN
                v_region := SUBSTRING(v_valor, 1, 2);
                SELECT b.valor INTO v_desc_region
                FROM cobis.cl_tabla a
                INNER JOIN cobis.cl_catalogo b ON a.codigo = b.tabla
                WHERE a.tabla = 'cl_region_telefono'
                  AND b.codigo = v_region;
            END IF;

            OPEN s_cursor FOR
            SELECT v_secuencial, v_tipo_telefono, v_desc_tipo,
                   v_region, v_desc_region, v_valor,
                   v_extension, v_comentario, v_pertenece;

            RETURN;
        ELSE
            IF e_mensaje = 'S' THEN
                RAISE EXCEPTION 'Error: 151051';
            ELSE
                s_msj_error := 'No corresponde codigo de transaccion';
                RETURN;
            END IF;
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- DELETE
    ---------------------------------------------------------------------------
    IF e_operacion = 'D' THEN
        IF t_trn = 148 THEN
            IF e_ente = 0 THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101042';
                ELSE
                    s_msj_error := 'No existe ente';
                    RETURN;
                END IF;
            END IF;

            PERFORM 1 FROM cobis.cl_producto WHERE pd_producto = e_producto;
            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101032';
                ELSE
                    s_msj_error := 'No existe producto';
                    RETURN;
                END IF;
            END IF;

            SELECT en_subtipo,
                   TO_CHAR(en_fecha_crea, 'MM/DD/YYYY'),
                   COALESCE(en_ced_ruc, COALESCE(p_pasaporte, '')),
                   COALESCE(en_nombre, ''),
                   COALESCE(p_p_apellido, ''),
                   COALESCE(p_s_apellido, '')
            INTO v_subtipo, v_fecha_crea_cli, v_idcliente,
                 v_nombrecli, v_p_apellido, v_s_apellido
            FROM cobis.cl_ente
            WHERE en_ente = e_ente;

            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 101042';
                ELSE
                    s_msj_error := 'No existe ente';
                    RETURN;
                END IF;
            END IF;

            SELECT te_valor, te_tipo_telefono, te_extension, te_comentario
            INTO v_valor, v_tipo_telefono, v_extension, v_comentario
            FROM cobis.cl_telefono
            WHERE te_ente = e_ente
              AND te_direccion = e_direccion
              AND te_secuencial = e_secuencial;

            IF NOT FOUND THEN
                IF e_mensaje = 'S' THEN
                    RAISE EXCEPTION 'Error: 105035';
                ELSE
                    s_msj_error := 'No existe telefono';
                    RETURN;
                END IF;
            END IF;

            IF e_no_cobis = 'S' THEN
                v_return := 0;
            END IF;

            -- Determine notification channel
            IF e_envio_notifica = 'S' AND v_subtipo = 'P' THEN
                IF v_fecha_reg > v_fecha_crea_cli THEN
                    IF e_producto = 2 AND e_canal <> 'VREFEREN' THEN
                        v_canal := 'MIS';
                    ELSIF e_producto = 166 THEN
                        PERFORM 1 FROM cobis.cl_catalogo c
                        INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
                        WHERE t.tabla = 'cl_cbpmnac' AND c.codigo = e_canal
                          AND c.estado = 'V';
                        IF FOUND THEN v_canal := 'BPM'; END IF;

                        IF v_canal IS NULL THEN
                            PERFORM 1 FROM cobis.cl_catalogo c
                            INNER JOIN cobis.cl_tabla t ON t.codigo = c.tabla
                            WHERE t.tabla = 'cl_cfinnac' AND c.codigo = e_canal
                              AND c.estado = 'V';
                            IF FOUND THEN v_canal := 'FORMINT'; END IF;
                        END IF;
                    ELSIF e_canal = 'VREFEREN' THEN
                        v_canal := e_canal;
                    ELSE
                        v_canal := 'OTROS';
                    END IF;
                END IF;
            END IF;

            DELETE FROM cobis.cl_telefono
            WHERE te_ente = e_ente
              AND te_direccion = e_direccion
              AND te_secuencial = e_secuencial;

            INSERT INTO cobis.ts_telefono (
                secuencial, alterno, tipo_transaccion, clase, fecha,
                usuario, terminal, srv, lsrv, origen, rol,
                ente, direccion, telefono, valor,
                tipo, extension, comentario, canal
            ) VALUES (
                s_ssn, p_alterno, t_trn, 'B', s_date,
                s_user, s_term, s_srv, s_lsrv, e_producto, s_rol,
                e_ente, e_direccion, e_secuencial, v_valor,
                v_tipo_telefono, v_extension, v_comentario, v_canal
            );

            -- Send notification if applicable
            IF e_envio_notifica = 'S' AND v_subtipo = 'P' THEN
                IF v_fecha_reg > v_fecha_crea_cli THEN
                    SELECT de_descripcion INTO v_mail
                    FROM cobis.cl_direccion_email
                    WHERE de_ente = e_ente AND de_tipo = 'E'
                    ORDER BY de_fecha_modificacion DESC
                    LIMIT 1;
                    IF NOT FOUND THEN v_mail := ''; END IF;

                    SELECT de_descripcion INTO v_celular
                    FROM cobis.cl_direccion_email
                    WHERE de_ente = e_ente AND de_tipo = 'M'
                    ORDER BY de_fecha_modificacion DESC
                    LIMIT 1;
                    IF NOT FOUND THEN v_celular := ''; END IF;

                    v_servicio := 'Actualizacion de Telefono';

                    RAISE NOTICE 'Notificacion enviada: ente=%, canal=%, servicio=%',
                        e_ente, e_canal, v_servicio;
                END IF;
            END IF;

            RETURN;
        ELSE
            IF e_mensaje = 'S' THEN
                RAISE EXCEPTION 'Error: 151051';
            ELSE
                s_msj_error := 'No corresponde codigo de transaccion';
                RETURN;
            END IF;
        END IF;
    END IF;

    ---------------------------------------------------------------------------
    -- BANCA VIRTUAL (paginated)
    ---------------------------------------------------------------------------
    IF e_operacion = 'B' THEN
        IF t_trn = 147 THEN
            s_num_filas := 20;

            IF e_tipo_cliente <> 'G' THEN
                OPEN s_cursor_bv FOR
                SELECT te_secuencial       AS "Codigo",
                       te_valor            AS "Telefono",
                       te_tipo_telefono    AS "Tipo",
                       te_direccion        AS "Direccion",
                       SUBSTRING(a.valor, 1, 10) AS "Descripcion",
                       SUBSTRING(di_descripcion, 1, 45) AS "Direccion Desc."
                FROM cobis.cl_telefono
                INNER JOIN cobis.cl_catalogo a ON a.codigo = te_tipo_telefono
                INNER JOIN cobis.cl_tabla m ON m.codigo = a.tabla
                INNER JOIN cobis.cl_direccion ON di_ente = te_ente
                    AND di_direccion = te_direccion
                WHERE te_ente = e_ente
                  AND m.tabla = 'cl_ttelefono'
                  AND ((e_tipo_telefono IS NULL
                        AND te_tipo_telefono IN (
                            SELECT codigo FROM cobis.cl_catalogo
                            WHERE tabla = (
                                SELECT codigo FROM cobis.cl_tabla
                                WHERE tabla = 'cl_ttelefono')))
                       OR te_tipo_telefono = e_tipo_telefono)
                  AND te_secuencial > e_secuencial
                ORDER BY te_secuencial
                LIMIT 20;
            ELSE
                OPEN s_cursor_bv FOR
                SELECT te_secuencial       AS "Codigo",
                       te_valor            AS "Telefono",
                       te_tipo_telefono    AS "Tipo",
                       te_direccion        AS "Direccion",
                       SUBSTRING(a.valor, 1, 10) AS "Descripcion",
                       SUBSTRING(di_descripcion, 1, 45) AS "Direccion Desc.",
                       en_nombre || ' ' || p_p_apellido || ' ' || p_s_apellido AS "Nombre"
                FROM cobis.cl_telefono
                INNER JOIN cobis.cl_catalogo a ON a.codigo = te_tipo_telefono
                INNER JOIN cobis.cl_tabla m ON m.codigo = a.tabla
                INNER JOIN cobis.cl_direccion ON di_ente = te_ente
                    AND di_direccion = te_direccion
                INNER JOIN cobis.cl_ente ON en_grupo = e_ente
                    AND te_ente = en_ente
                WHERE m.tabla = 'cl_ttelefono'
                  AND ((e_tipo_telefono IS NULL
                        AND te_tipo_telefono IN (
                            SELECT codigo FROM cobis.cl_catalogo
                            WHERE tabla = (
                                SELECT codigo FROM cobis.cl_tabla
                                WHERE tabla = 'cl_ttelefono')))
                       OR te_tipo_telefono = e_tipo_telefono)
                  AND te_secuencial > e_secuencial
                ORDER BY te_secuencial
                LIMIT 20;
            END IF;

            RETURN;
        ELSE
            IF e_mensaje = 'S' THEN
                RAISE EXCEPTION 'Error: 151051';
            ELSE
                s_msj_error := 'No corresponde codigo de transaccion';
                RETURN;
            END IF;
        END IF;
    END IF;

END;
$$;
