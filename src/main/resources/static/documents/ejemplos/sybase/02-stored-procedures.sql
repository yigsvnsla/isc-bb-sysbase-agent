-- ============================================================================
-- Sybase ASE 16.x — Ejemplos de stored procedures bancarios
-- Convenciones: sp_<modulo>_<accion>, parámetros @prefijo, @@error control
-- ============================================================================

-- ============================================================================
-- SP: Consulta de saldo de cuenta
-- ============================================================================
CREATE PROCEDURE sp_cuenta_consultar_saldo
    @cod_cuenta CHAR(16),
    @saldo      NUMERIC(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    SELECT @saldo = saldo
    FROM cuenta
    WHERE cod_cuenta = @cod_cuenta
      AND estado = 'A'

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR 50001 'Cuenta no encontrada o inactiva'
        RETURN -1
    END

    RETURN 0
END
GO

-- ============================================================================
-- SP: Transferencia entre cuentas (con transacción)
-- ============================================================================
CREATE PROCEDURE sp_cuenta_transferir
    @cuenta_origen  CHAR(16),
    @cuenta_destino CHAR(16),
    @monto          NUMERIC(18,2),
    @referencia     VARCHAR(60) = NULL,
    @cod_usuario    VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON
    SET CHAINED ON  -- Inicia transacción implícita

    DECLARE @saldo_origen NUMERIC(18,2)
    DECLARE @err INT

    -- Validar cuentas
    SELECT @saldo_origen = saldo
    FROM cuenta
    WHERE cod_cuenta = @cuenta_origen
      AND estado = 'A'

    IF @@ROWCOUNT = 0 OR @saldo_origen IS NULL
    BEGIN
        RAISERROR 50001 'Cuenta origen no encontrada o inactiva'
        ROLLBACK
        RETURN -1
    END

    -- Validar saldo suficiente
    IF @saldo_origen < @monto
    BEGIN
        RAISERROR 50002 'Saldo insuficiente en cuenta origen'
        ROLLBACK
        RETURN -2
    END

    -- Débito en cuenta origen
    UPDATE cuenta
    SET saldo = saldo - @monto
    WHERE cod_cuenta = @cuenta_origen

    SELECT @err = @@ERROR
    IF @err <> 0
    BEGIN
        RAISERROR 50003 'Error al debitar cuenta origen'
        ROLLBACK
        RETURN @err
    END

    -- Crédito en cuenta destino
    UPDATE cuenta
    SET saldo = saldo + @monto
    WHERE cod_cuenta = @cuenta_destino
      AND estado = 'A'

    SELECT @err = @@ERROR
    IF @err <> 0
    BEGIN
        RAISERROR 50004 'Error al acreditar cuenta destino'
        ROLLBACK
        RETURN @err
    END

    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR 50005 'Cuenta destino no encontrada o inactiva'
        ROLLBACK
        RETURN -3
    END

    -- Registrar movimientos
    INSERT INTO movimiento (cod_cuenta, tipo_mov, monto, signo, referencia, cod_usuario)
    VALUES (@cuenta_origen, 'TRA', @monto, 'D', @referencia, @cod_usuario)

    SELECT @err = @@ERROR
    IF @err <> 0
    BEGIN
        ROLLBACK
        RETURN @err
    END

    INSERT INTO movimiento (cod_cuenta, tipo_mov, monto, signo, referencia, cod_usuario)
    VALUES (@cuenta_destino, 'TRA', @monto, 'C', @referencia, @cod_usuario)

    SELECT @err = @@ERROR
    IF @err <> 0
    BEGIN
        ROLLBACK
        RETURN @err
    END

    COMMIT
    RETURN 0
END
GO

-- ============================================================================
-- SP: Consulta de movimientos por rango de fechas
-- ============================================================================
CREATE PROCEDURE sp_movimiento_consultar_por_fecha
    @cod_cuenta CHAR(16),
    @fecha_desde DATETIME,
    @fecha_hasta DATETIME
AS
BEGIN
    SET NOCOUNT ON

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
    WHERE m.cod_cuenta = @cod_cuenta
      AND m.fecha_mov >= @fecha_desde
      AND m.fecha_mov < DATEADD(DAY, 1, @fecha_hasta)
    ORDER BY m.fecha_mov DESC, m.cod_movimiento DESC

    RETURN 0
END
GO

-- ============================================================================
-- SP: Registro de nuevo cliente con validación
-- ============================================================================
CREATE PROCEDURE sp_cliente_registrar
    @cod_cliente    CHAR(8),
    @nombre         VARCHAR(80),
    @tipo_documento CHAR(3),
    @num_documento  VARCHAR(20),
    @direccion      VARCHAR(120) = NULL,
    @telefono       VARCHAR(15)  = NULL,
    @email          VARCHAR(60)  = NULL
AS
BEGIN
    SET NOCOUNT ON

    -- Validar que no exista el cliente
    IF EXISTS (SELECT 1 FROM cliente WHERE cod_cliente = @cod_cliente)
    BEGIN
        RAISERROR 50010 'El codigo de cliente ya existe'
        RETURN -1
    END

    -- Validar documento único
    IF EXISTS (SELECT 1 FROM cliente
               WHERE tipo_documento = @tipo_documento
                 AND num_documento = @num_documento)
    BEGIN
        RAISERROR 50011 'Ya existe un cliente con ese documento'
        RETURN -2
    END

    INSERT INTO cliente (cod_cliente, nombre, tipo_documento, num_documento,
                         direccion, telefono, email)
    VALUES (@cod_cliente, @nombre, @tipo_documento, @num_documento,
            @direccion, @telefono, @email)

    IF @@ERROR <> 0
    BEGIN
        RAISERROR 50012 'Error al registrar cliente'
        RETURN -3
    END

    RETURN SCOPE_IDENTITY()
END
GO
