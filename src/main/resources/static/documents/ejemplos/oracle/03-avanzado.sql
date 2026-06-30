-- ============================================================================
-- Oracle Database 23c — Ejemplos avanzados
-- Paquetes, funciones, triggers, pipelined, colecciones
-- ============================================================================

-- ============================================================================
-- Paquete: Gestión de clientes (encapsulación lógica de negocio)
-- ============================================================================
CREATE OR REPLACE PACKAGE pkg_cliente AS

    -- Constantes
    c_estado_activo   CONSTANT CHAR(1) := 'A';
    c_estado_inactivo CONSTANT CHAR(1) := 'I';
    c_estado_baja     CONSTANT CHAR(1) := 'B';

    -- Tipos
    TYPE r_cliente IS RECORD (
        cod_cliente     CHAR(8),
        nombre          VARCHAR2(80),
        tipo_documento  CHAR(3),
        num_documento   VARCHAR2(20),
        estado          CHAR(1)
    );

    TYPE t_cliente_list IS TABLE OF r_cliente;

    -- Procedimientos públicos
    PROCEDURE registrar (
        p_cod_cliente    IN  CHAR,
        p_nombre         IN  VARCHAR2,
        p_tipo_documento IN  CHAR,
        p_num_documento  IN  VARCHAR2,
        p_direccion      IN  VARCHAR2 DEFAULT NULL,
        p_telefono       IN  VARCHAR2 DEFAULT NULL,
        p_email          IN  VARCHAR2 DEFAULT NULL
    );

    FUNCTION calcular_edad (
        p_fecha_nac IN DATE
    ) RETURN NUMBER;

    FUNCTION buscar_por_documento (
        p_tipo_documento IN CHAR,
        p_num_documento  IN VARCHAR2
    ) RETURN r_cliente;

END pkg_cliente;
/

CREATE OR REPLACE PACKAGE BODY pkg_cliente AS

    PROCEDURE registrar (
        p_cod_cliente    IN  CHAR,
        p_nombre         IN  VARCHAR2,
        p_tipo_documento IN  CHAR,
        p_num_documento  IN  VARCHAR2,
        p_direccion      IN  VARCHAR2 DEFAULT NULL,
        p_telefono       IN  VARCHAR2 DEFAULT NULL,
        p_email          IN  VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        INSERT INTO cliente (cod_cliente, nombre, tipo_documento, num_documento,
                             direccion, telefono, email)
        VALUES (p_cod_cliente, p_nombre, p_tipo_documento, p_num_documento,
                p_direccion, p_telefono, p_email);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20030, 'Cliente duplicado');
        WHEN OTHERS THEN
            RAISE;
    END registrar;

    FUNCTION calcular_edad (
        p_fecha_nac IN DATE
    ) RETURN NUMBER
    IS
    BEGIN
        RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, p_fecha_nac) / 12);
    END calcular_edad;

    FUNCTION buscar_por_documento (
        p_tipo_documento IN CHAR,
        p_num_documento  IN VARCHAR2
    ) RETURN r_cliente
    IS
        v_result r_cliente;
    BEGIN
        SELECT cod_cliente, nombre, tipo_documento, num_documento, estado
        INTO v_result
        FROM cliente
        WHERE tipo_documento = p_tipo_documento
          AND num_documento = p_num_documento
          AND ROWNUM = 1;

        RETURN v_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END buscar_por_documento;

END pkg_cliente;
/

-- ============================================================================
-- Función PIPELINED: Generar reporte de movimientos como tabla
-- ============================================================================
CREATE OR REPLACE PACKAGE pkg_reporte AS

    TYPE r_mov_reporte IS RECORD (
        cod_cuenta      CHAR(16),
        fecha           DATE,
        total_movs      NUMBER,
        monto_promedio  NUMBER(18,2),
        cantidad_debitos NUMBER,
        cantidad_creditos NUMBER
    );

    TYPE t_mov_reporte IS TABLE OF r_mov_reporte;

    FUNCTION generar_reporte_mensual (
        p_anio  IN NUMBER,
        p_mes   IN NUMBER
    ) RETURN t_mov_reporte PIPELINED;

END pkg_reporte;
/

CREATE OR REPLACE PACKAGE BODY pkg_reporte AS

    FUNCTION generar_reporte_mensual (
        p_anio  IN NUMBER,
        p_mes   IN NUMBER
    ) RETURN t_mov_reporte PIPELINED
    IS
        CURSOR c_mov IS
            SELECT cod_cuenta,
                   TRUNC(fecha_mov) AS fecha,
                   COUNT(*) AS total_movs,
                   AVG(monto) AS monto_promedio,
                   SUM(CASE signo WHEN 'D' THEN 1 ELSE 0 END) AS cantidad_debitos,
                   SUM(CASE signo WHEN 'C' THEN 1 ELSE 0 END) AS cantidad_creditos
            FROM movimiento
            WHERE EXTRACT(YEAR FROM fecha_mov) = p_anio
              AND EXTRACT(MONTH FROM fecha_mov) = p_mes
            GROUP BY cod_cuenta, TRUNC(fecha_mov)
            ORDER BY cod_cuenta, fecha;
    BEGIN
        FOR rec IN c_mov LOOP
            PIPE ROW (rec);
        END LOOP;
        RETURN;
    END generar_reporte_mensual;

END pkg_reporte;
/

-- ============================================================================
-- Trigger: Auditoría automática de movimientos
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_movimiento_auditar
    AFTER INSERT OR UPDATE OR DELETE ON movimiento
    FOR EACH ROW
DECLARE
    v_operacion CHAR(1);
BEGIN
    v_operacion := CASE
        WHEN INSERTING THEN 'I'
        WHEN UPDATING  THEN 'U'
        WHEN DELETING  THEN 'D'
    END;

    INSERT INTO auditoria (
        cod_auditoria, tabla, operacion, cod_registro,
        datos_anteriores, datos_nuevos, usuario, terminal, sesion_id
    ) VALUES (
        seq_auditoria_cod.NEXTVAL,
        'MOVIMIENTO',
        v_operacion,
        TO_CHAR(COALESCE(:NEW.cod_movimiento, :OLD.cod_movimiento)),
        CASE WHEN :OLD.cod_movimiento IS NOT NULL THEN
            '{"cod_movimiento":"' || :OLD.cod_movimiento || '","cod_cuenta":"' || :OLD.cod_cuenta ||
            '","monto":' || :OLD.monto || ',"signo":"' || :OLD.signo || '"}'
        END,
        CASE WHEN :NEW.cod_movimiento IS NOT NULL THEN
            '{"cod_movimiento":"' || :NEW.cod_movimiento || '","cod_cuenta":"' || :NEW.cod_cuenta ||
            '","monto":' || :NEW.monto || ',"signo":"' || :NEW.signo || '"}'
        END,
        USER, SYS_CONTEXT('USERENV', 'TERMINAL'), SYS_CONTEXT('USERENV', 'SESSIONID')
    );
END trg_movimiento_auditar;
/

-- ============================================================================
-- Trigger: Validar saldo negativo antes de actualizar
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_cuenta_validar_saldo
    BEFORE UPDATE OF saldo ON cuenta
    FOR EACH ROW
BEGIN
    IF :NEW.saldo < 0 AND :NEW.estado = 'A' THEN
        RAISE_APPLICATION_ERROR(-20040, 'La cuenta no puede tener saldo negativo');
    END IF;
END trg_cuenta_validar_saldo;
/

-- ============================================================================
-- Función con colecciones: Procesar múltiples IDs
-- ============================================================================
CREATE OR REPLACE TYPE t_cod_cuenta_list AS TABLE OF CHAR(16);
/

CREATE OR REPLACE FUNCTION fn_cuenta_saldo_total (
    p_cod_cuentas IN t_cod_cuenta_list
) RETURN NUMBER
IS
    v_total NUMBER(18,2) := 0;
BEGIN
    SELECT SUM(saldo) INTO v_total
    FROM cuenta
    WHERE cod_cuenta IN (SELECT COLUMN_VALUE FROM TABLE(p_cod_cuentas))
      AND estado = 'A';

    RETURN NVL(v_total, 0);
END fn_cuenta_saldo_total;
/

-- ============================================================================
-- Ejemplo: Uso de MERGE (UPSERT) para sincronización
-- ============================================================================
CREATE OR REPLACE PROCEDURE p_cuenta_sincronizar_saldos (
    p_cod_cuenta    IN CHAR,
    p_nuevo_saldo   IN NUMBER,
    p_cod_usuario   IN VARCHAR2
) AS
BEGIN
    MERGE INTO cuenta c
    USING (SELECT p_cod_cuenta AS cod_cuenta FROM DUAL) src
    ON (c.cod_cuenta = src.cod_cuenta)
    WHEN MATCHED THEN
        UPDATE SET saldo = p_nuevo_saldo,
                   estado = 'A'
    WHEN NOT MATCHED THEN
        INSERT (cod_cuenta, cod_cliente, tipo_cuenta, moneda, saldo)
        VALUES (p_cod_cuenta, 'DESCONOCIDO', 'AHO', 'PEN', p_nuevo_saldo);

    INSERT INTO movimiento (cod_movimiento, cod_cuenta, tipo_mov, monto, signo, cod_usuario)
    VALUES (seq_movimiento_cod.NEXTVAL, p_cod_cuenta, 'AJU',
            ABS(p_nuevo_saldo), CASE WHEN p_nuevo_saldo >= 0 THEN 'C' ELSE 'D' END,
            p_cod_usuario);
END p_cuenta_sincronizar_saldos;
/
