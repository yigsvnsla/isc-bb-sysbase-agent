-- ============================================================================
-- Archivo:      cc_tran_servicio.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        cc_tran_servicio
-- Esquema:      cob_cuentas
-- Proposito:    Maestro de transacciones de servicio (recaudaciones)
-- ============================================================================

CREATE TABLE IF NOT EXISTS cob_cuentas.cc_tran_servicio (
    ts_secuencial        INTEGER NOT NULL,
    ts_cod_alterno       INTEGER,
    ts_tipo_transaccion  INTEGER NOT NULL,
    ts_clase             VARCHAR(3),
    ts_tsfecha           DATE NOT NULL,
    ts_tabla             SMALLINT,
    ts_usuario           VARCHAR(255),
    ts_terminal          VARCHAR(255),
    ts_rol               SMALLINT,
    ts_correccion        CHAR(1),
    ts_ssn_corr          INTEGER,
    ts_reentry           CHAR(1),
    ts_origen            CHAR(1),
    ts_nodo              VARCHAR(30),
    ts_referencia        VARCHAR(15),
    ts_remoto_ssn        INTEGER,
    ts_cheque_rec        INTEGER,
    ts_ctacte            INTEGER,
    ts_cta_banco         VARCHAR(24),
    ts_filial            SMALLINT,
    ts_oficina           SMALLINT,
    ts_oficial           SMALLINT,
    ts_fecha_aper        DATE,
    ts_cliente           INTEGER,
    ts_ced_ruc           VARCHAR(20),
    ts_estado            CHAR(1),
    ts_direccion_ec      SMALLINT,
    ts_descripcion_ec    VARCHAR(100),
    ts_ciclo             CHAR(1),
    ts_categoria         CHAR(1),
    ts_producto          SMALLINT,
    ts_tipo              CHAR(1),
    ts_indicador         SMALLINT,
    ts_moneda            SMALLINT,
    ts_default           INTEGER,
    ts_tipo_def          CHAR(1),
    ts_rol_ente          CHAR(1),
    ts_tipo_promedio     CHAR(1),
    ts_numero            SMALLINT,
    ts_fecha             DATE,
    ts_autorizante       VARCHAR(255),
    ts_causa             VARCHAR(6),
    ts_servicio          VARCHAR(3),
    ts_saldo             NUMERIC(19,4),
    ts_fecha_uso         DATE,
    ts_monto             NUMERIC(19,4),
    ts_fecha_ven         DATE,
    ts_filial_aut        SMALLINT,
    ts_ofi_aut           SMALLINT,
    ts_autoriz_aut       VARCHAR(255),
    ts_filial_anula      SMALLINT,
    ts_ofi_anula         SMALLINT,
    ts_autoriz_anula     VARCHAR(255),
    ts_cheque_desde      INTEGER,
    ts_cheque_hasta      INTEGER,
    ts_chequera          SMALLINT,
    ts_num_cheques       SMALLINT,
    ts_departamento      SMALLINT,
    ts_cta_gir           VARCHAR(24),
    ts_endoso            INTEGER,
    ts_cod_banco         VARCHAR(8),
    ts_corresponsal      VARCHAR(8),
    ts_propietario       VARCHAR(8),
    ts_carta             INTEGER,
    ts_sec_correccion    INTEGER,
    ts_cheque            INTEGER,
    ts_cta_banco_dep     VARCHAR(24),
    ts_oficina_pago      SMALLINT,
    ts_contratado        NUMERIC(19,4),
    ts_valor             NUMERIC(19,4),
    ts_ocasional         NUMERIC(19,4),
    ts_banco             SMALLINT,
    ts_ccontable         VARCHAR(20),
    ts_cta_funcionario   CHAR(1),
    ts_mercantil         CHAR(1),
    ts_cta_asociada      VARCHAR(24),
    ts_tipocta           CHAR(1),
    ts_fecha_eimp        DATE,
    ts_fecha_rimp        DATE,
    ts_fecha_rofi        DATE,
    ts_tipo_chequera     VARCHAR(5),
    ts_stick_imp         CHAR(12),
    ts_tipo_imp          CHAR(1),
    ts_tarjcred          VARCHAR(20),
    ts_aporte_iess       NUMERIC(19,4),
    ts_descuento_iess    NUMERIC(19,4),
    ts_fonres_iess       NUMERIC(19,4),
    ts_agente            VARCHAR(30),
    ts_nombre            VARCHAR(100),
    ts_debito            CHAR(1),
    ts_hora              VARCHAR(50),
    ts_oficina_cta       SMALLINT,
    ts_tsn               INTEGER,
    ts_tipo_contable     CHAR(2),
    ts_estado_sob        CHAR(3),
    ts_tipo_credito      CHAR(1),
    ts_plazo             CHAR(2),
    ts_tipo_sobregiro    CHAR(1),
    ts_campo_alt_uno     VARCHAR(30),
    ts_campo_alt_dos     VARCHAR(30),
    ts_ubicacion         SMALLINT,
    CONSTRAINT pk_cc_tran_servicio PRIMARY KEY (ts_secuencial)
);

CREATE INDEX IF NOT EXISTS ix_cc_tran_servicio_secuencial
    ON cob_cuentas.cc_tran_servicio (ts_secuencial);
CREATE INDEX IF NOT EXISTS ix_cc_tran_servicio_fecha
    ON cob_cuentas.cc_tran_servicio (ts_tsfecha, ts_causa, ts_usuario);
CREATE INDEX IF NOT EXISTS ix_cc_tran_servicio_ssn_corr
    ON cob_cuentas.cc_tran_servicio (ts_secuencial, ts_causa, ts_tsfecha);

COMMENT ON TABLE cob_cuentas.cc_tran_servicio IS 'Maestro de transacciones de servicio (recaudaciones)';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_secuencial IS 'Secuencial unico de la transaccion';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_tipo_transaccion IS 'Tipo de transaccion (TRN)';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_tsfecha IS 'Fecha de la transaccion';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_correccion IS 'N=Normal, S=Correccion';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_tipo_chequera IS 'Canal (VEN, VENEL, CNB)';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_causa IS 'Codigo empresa';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_usuario IS 'Usuario que realizo la transaccion';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_oficina IS 'Oficina';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_referencia IS 'Referencia (suministro)';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_nombre IS 'Nombre del cliente';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_saldo IS 'Monto cheque';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_monto IS 'Monto debito';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_valor IS 'Monto efectivo';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_contratado IS 'Monto tarjeta';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_ocasional IS 'Monto ocasional';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_hora IS 'Hora de la transaccion';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_ssn_corr IS 'SSN de correccion';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_campo_alt_uno IS 'Campo alterno 1 (codigo respuesta)';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_autoriz_aut IS 'Autorizacion';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_aporte_iess IS 'Aporte IESS';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_descripcion_ec IS 'Descripcion (nombre cliente)';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_cta_banco IS 'Cuenta bancaria';
COMMENT ON COLUMN cob_cuentas.cc_tran_servicio.ts_ubicacion IS 'Ubicacion';
