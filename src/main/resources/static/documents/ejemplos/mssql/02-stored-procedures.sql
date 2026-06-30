-- ============================================================================
-- Microsoft SQL Server 2022 — Ejemplos de stored procedures bancarios
-- Convenciones: usp_<Modulo>_<Accion>, TRY/CATCH, transacciones anidadas
-- ============================================================================

-- ============================================================================
-- SP: Consulta de saldo de cuenta
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Cuenta_ConsultarSaldo
    @CodCuenta  NCHAR(16),
    @Saldo      DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        SELECT @Saldo = Saldo
        FROM dbo.Cuenta
        WHERE CodCuenta = @CodCuenta
          AND Estado = 'A'

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('Cuenta no encontrada o inactiva', 16, 1)
            RETURN -1
        END

        RETURN 0
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
        RETURN -99
    END CATCH
END
GO

-- ============================================================================
-- SP: Transferencia entre cuentas (con manejo moderno de errores)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Cuenta_Transferir
    @CuentaOrigen   NCHAR(16),
    @CuentaDestino  NCHAR(16),
    @Monto          DECIMAL(18,2),
    @Referencia     NVARCHAR(60) = NULL,
    @CodUsuario     NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @SaldoOrigen DECIMAL(18,2)

        -- Validar cuenta origen
        SELECT @SaldoOrigen = Saldo
        FROM dbo.Cuenta WITH (ROWLOCK, XLOCK)
        WHERE CodCuenta = @CuentaOrigen
          AND Estado = 'A'

        IF @@ROWCOUNT = 0
            THROW 50001, 'Cuenta origen no encontrada o inactiva', 1

        IF @SaldoOrigen < @Monto
            THROW 50002, 'Saldo insuficiente en cuenta origen', 1

        -- Débito
        UPDATE dbo.Cuenta
        SET Saldo = Saldo - @Monto
        WHERE CodCuenta = @CuentaOrigen

        IF @@ROWCOUNT = 0
            THROW 50003, 'Error al debitar cuenta origen', 1

        -- Crédito
        UPDATE dbo.Cuenta
        SET Saldo = Saldo + @Monto
        WHERE CodCuenta = @CuentaDestino
          AND Estado = 'A'

        IF @@ROWCOUNT = 0
            THROW 50004, 'Cuenta destino no encontrada o inactiva', 1

        -- Registrar movimientos
        INSERT INTO dbo.Movimiento (CodCuenta, TipoMov, Monto, Signo, Referencia, CodUsuario)
        VALUES (@CuentaOrigen, 'TRA', @Monto, 'D', @Referencia, @CodUsuario)

        INSERT INTO dbo.Movimiento (CodCuenta, TipoMov, Monto, Signo, Referencia, CodUsuario)
        VALUES (@CuentaDestino, 'TRA', @Monto, 'C', @Referencia, @CodUsuario)

        COMMIT TRANSACTION
        RETURN 0
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION

        DECLARE @ErrMsg NVARCHAR(4000) = CONCAT(
            'Error en transferencia: ', ERROR_MESSAGE(),
            ' (Linea: ', ERROR_LINE(), ')')
        RAISERROR(@ErrMsg, 16, 1)
        RETURN -99
    END CATCH
END
GO

-- ============================================================================
-- SP: Consulta de movimientos con paginación
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Movimiento_ConsultarPaginado
    @CodCuenta  NCHAR(16),
    @FechaDesde DATE,
    @FechaHasta DATE,
    @Pagina     INT = 1,
    @Filas      INT = 50
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @Offset INT = (@Pagina - 1) * @Filas

    SELECT m.CodMovimiento,
           m.FechaMov,
           m.TipoMov,
           m.Monto,
           m.Signo,
           m.Referencia,
           CASE m.Signo
               WHEN 'D' THEN m.Monto * -1
               ELSE m.Monto
           END AS MontoNeto,
           COUNT(*) OVER() AS TotalFilas
    FROM dbo.Movimiento m
    WHERE m.CodCuenta = @CodCuenta
      AND m.FechaMov >= @FechaDesde
      AND m.FechaMov < DATEADD(DAY, 1, @FechaHasta)
    ORDER BY m.FechaMov DESC, m.CodMovimiento DESC
    OFFSET @Offset ROWS
    FETCH NEXT @Filas ROWS ONLY

    RETURN 0
END
GO

-- ============================================================================
-- SP: Registro de nuevo cliente
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Cliente_Registrar
    @CodCliente     NCHAR(8),
    @Nombre         NVARCHAR(80),
    @TipoDocumento  NCHAR(3),
    @NumDocumento   NVARCHAR(20),
    @Direccion      NVARCHAR(120) = NULL,
    @Telefono       NVARCHAR(15) = NULL,
    @Email          NVARCHAR(60) = NULL,
    @NuevoCodCliente NCHAR(8) OUTPUT
AS
BEGIN
    SET NOCOUNT ON

    BEGIN TRY
        -- Validar cliente duplicado
        IF EXISTS (SELECT 1 FROM dbo.Cliente WHERE CodCliente = @CodCliente)
            THROW 50010, 'El codigo de cliente ya existe', 1

        -- Validar documento único
        IF EXISTS (SELECT 1 FROM dbo.Cliente
                   WHERE TipoDocumento = @TipoDocumento
                     AND NumDocumento = @NumDocumento
                     AND Estado = 'A')
            THROW 50011, 'Ya existe un cliente activo con ese documento', 1

        INSERT INTO dbo.Cliente (CodCliente, Nombre, TipoDocumento, NumDocumento,
                                  Direccion, Telefono, Email)
        VALUES (@CodCliente, @Nombre, @TipoDocumento, @NumDocumento,
                @Direccion, @Telefono, @Email)

        SET @NuevoCodCliente = @CodCliente
        RETURN 0
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = CONCAT(
            'Error al registrar cliente: ', ERROR_MESSAGE())
        RAISERROR(@ErrMsg, 16, 1)
        RETURN -99
    END CATCH
END
GO
