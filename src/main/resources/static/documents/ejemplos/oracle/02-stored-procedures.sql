-- ============================================================================
-- Oracle Database 23c — Ejemplos de stored procedures bancarios
-- Convenciones: p_<modulo>_<accion>, parámetros p_<nombre>, EXCEPTION handling
-- ============================================================================

-- ============================================================================
-- SP: Consulta de saldo de cuenta
-- ============================================================================
CREATE OR REPLACE PROCEDURE p_cuenta_consultar_saldo (
    p_cod_cuenta    IN  CHAR,
    p_saldo         OUT NUMBER
) AS
    v_estado        CHAR(1);
BEGIN
    SELECT saldo, estado
    INTO p_saldo, v_estado
    FROM cuenta
    WHERE cod_cuenta = p_cod_cuenta;

    IF v_estado != 'A' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cuenta inactiva');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cuenta no encontrada');
    WHEN OTHERS THEN
        RAISE;
END p_cuenta_consultar_saldo;
/

-- ============================================================================
-- SP: Transferencia entre cuentas (con transacción autónoma opcional)
-- ============================================================================
CREATE OR REPLACE PROCEDURE p_cuenta_transferir (
    p_cuenta_origen     IN  CHAR,
    p_cuenta_destino    IN  CHAR,
    p_monto             IN  NUMBER,
    p_referencia        IN  VARCHAR2 DEFAULT NULL,
    p_cod_usuario       IN  VARCHAR2
) AS
    v_saldo_origen  NUMBER(18,2);
    v_estado_dest   CHAR(1);
    v_cod_mov_origen NUMBER;
    v_cod_mov_destino NUMBER;
BEGIN
    SAVEPOINT antes_transferencia;

    -- Bloquear fila origen para evitar condiciones de carrera
    SELECT saldo, estado
    INTO v_saldo_origen, v_estado_dest
    FROM cuenta
    WHERE cod_cuenta = p_cuenta_origen
    FOR UPDATE;

    IF v_estado_dest != 'A' THEN
        RAISE_APPLICATION_ERROR(-20010, 'Cuenta origen inactiva');
    END IF;

    IF v_saldo_origen < p_monto THEN
        RAISE_APPLICATION_ERROR(-20011, 'Saldo insuficiente en cuenta origen');
    END IF;

    -- Debito
    UPDATE cuenta
    SET saldo = saldo - p_monto
    WHERE cod_cuenta = p_cuenta_origen;

    -- Verificar cuenta destino
    SELECT estado INTO v_estado_dest
    FROM cuenta
    WHERE cod_cuenta = p_cuenta_destino;

    IF v_estado_dest != 'A' THEN
        RAISE_APPLICATION_ERROR(-20012, 'Cuenta destino inactiva');
    END IF;

    -- Credito
    UPDATE cuenta
    SET saldo = saldo + p_monto
    WHERE cod_cuenta = p_cuenta_destino;

    -- Registrar movimientos
    SELECT seq_movimiento_cod.NEXTVAL INTO v_cod_mov_origen FROM DUAL;
    SELECT seq_movimiento_cod.NEXTVAL INTO v_cod_mov_destino FROM DUAL;

    INSERT INTO movimiento (cod_movimiento, cod_cuenta, tipo_mov, monto, signo, referencia, cod_usuario)
    VALUES (v_cod_mov_origen, p_cuenta_origen, 'TRA', p_monto, 'D', p_referencia, p_cod_usuario);

    INSERT INTO movimiento (cod_movimiento, cod_cuenta, tipo_mov, monto, signo, referencia, cod_usuario)
    VALUES (v_cod_mov_destino, p_cuenta_destino, 'TRA', p_monto, 'C', p_referencia, p_cod_usuario);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO antes_transferencia;
        RAISE;
END p_cuenta_transferir;
/

-- ============================================================================
-- SP: Consulta de movimientos con cursor REF CURSOR
-- ============================================================================
CREATE OR REPLACE PROCEDURE p_movimiento_consultar_por_fecha (
    p_cod_cuenta    IN  CHAR,
    p_fecha_desde   IN  DATE,
    p_fecha_hasta   IN  DATE,
    p_cursor        OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT m.cod_movimiento,
               m.fecha_mov,
               m.tipo_mov,
               m.monto,
               m.signo,
               m.referencia,
               CASE m.signo
                   WHEN 'D' THEN m.monto * -1
                   ELSE m.monto
               END AS monto_neto
        FROM movimiento m
        WHERE m.cod_cuenta = p_cod_cuenta
          AND m.fecha_mov >= p_fecha_desde
          AND m.fecha_mov < p_fecha_hasta + 1
        ORDER BY m.fecha_mov DESC, m.cod_movimiento DESC;
END p_movimiento_consultar_por_fecha;
/

-- ============================================================================
-- SP: Registro de nuevo cliente con validación
-- ============================================================================
CREATE OR REPLACE PROCEDURE p_cliente_registrar (
    p_cod_cliente    IN  CHAR,
    p_nombre         IN  VARCHAR2,
    p_tipo_documento IN  CHAR,
    p_num_documento  IN  VARCHAR2,
    p_direccion      IN  VARCHAR2 DEFAULT NULL,
    p_telefono       IN  VARCHAR2 DEFAULT NULL,
    p_email          IN  VARCHAR2 DEFAULT NULL
) AS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    -- Validar duplicado
    FOR dup IN (SELECT 1 FROM cliente WHERE cod_cliente = p_cod_cliente)
    LOOP
        RAISE_APPLICATION_ERROR(-20020, 'El codigo de cliente ya existe');
    END LOOP;

    -- Validar documento único
    FOR dup IN (SELECT 1 FROM cliente
                WHERE tipo_documento = p_tipo_documento
                  AND num_documento = p_num_documento)
    LOOP
        RAISE_APPLICATION_ERROR(-20021, 'Ya existe un cliente con ese documento');
    END LOOP;

    INSERT INTO cliente (cod_cliente, nombre, tipo_documento, num_documento,
                         direccion, telefono, email)
    VALUES (p_cod_cliente, p_nombre, p_tipo_documento, p_num_documento,
            p_direccion, p_telefono, p_email);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END p_cliente_registrar;
/
