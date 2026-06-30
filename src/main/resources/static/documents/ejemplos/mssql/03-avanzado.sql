-- ============================================================================
-- Microsoft SQL Server 2022 — Ejemplos avanzados
-- Funciones, CTEs, ventanas, triggers, SECURITY, JSON
-- ============================================================================

-- ============================================================================
-- Función escalar: Calcular edad exacta
-- ============================================================================
CREATE OR ALTER FUNCTION dbo.fn_Cliente_CalcularEdad
    (@FechaNac DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @FechaNac, GETUTCDATE()) -
           CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @FechaNac, GETUTCDATE()), @FechaNac) > GETUTCDATE()
                THEN 1 ELSE 0
           END
END
GO

-- ============================================================================
-- Función con tabla inline (iTVF): Resumen de movimientos por período
-- ============================================================================
CREATE OR ALTER FUNCTION dbo.fn_Movimiento_ResumenPorPeriodo
    (@CodCuenta NCHAR(16), @FechaInicio DATE, @FechaFin DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT TipoMov,
           COUNT(*)              AS Cantidad,
           SUM(Monto)            AS Total,
           SUM(CASE WHEN Signo = 'D' THEN Monto ELSE 0 END) AS TotalDebitos,
           SUM(CASE WHEN Signo = 'C' THEN Monto ELSE 0 END) AS TotalCreditos,
           MIN(FechaMov)         AS PrimeraFecha,
           MAX(FechaMov)         AS UltimaFecha
    FROM dbo.Movimiento
    WHERE CodCuenta = @CodCuenta
      AND FechaMov >= @FechaInicio
      AND FechaMov < DATEADD(DAY, 1, @FechaFin)
    GROUP BY TipoMov
)
GO

-- ============================================================================
-- CTE Recursiva: Jerarquía de productos financieros
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Producto_ObtenerJerarquia
    @CodProductoRaiz NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON

    WITH ProductosJerarquia AS (
        -- Ancla: producto raíz
        SELECT CodProducto, Nombre, CodProductoPadre, 0 AS Nivel,
               CAST(Nombre AS NVARCHAR(500)) AS Ruta
        FROM dbo.Producto
        WHERE CodProducto = @CodProductoRaiz

        UNION ALL

        -- Recursión: hijos
        SELECT p.CodProducto, p.Nombre, p.CodProductoPadre, hj.Nivel + 1,
               CAST(CONCAT(hj.Ruta, ' > ', p.Nombre) AS NVARCHAR(500))
        FROM dbo.Producto p
        INNER JOIN ProductosJerarquia hj ON p.CodProductoPadre = hj.CodProducto
    )
    SELECT * FROM ProductosJerarquia
    ORDER BY Ruta
END
GO

-- ============================================================================
-- Trigger: Auditoría automática con datos en formato JSON
-- ============================================================================
CREATE OR ALTER TRIGGER dbo.TRG_Movimiento_Auditar
ON dbo.Movimiento
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO dbo.Auditoria (Tabla, Operacion, CodRegistro,
                               DatosAnteriores, DatosNuevos, Usuario, Terminal, SesionID)
    SELECT 'Movimiento',
           CASE WHEN i.CodMovimiento IS NOT NULL AND d.CodMovimiento IS NULL THEN 'I'
                WHEN i.CodMovimiento IS NULL AND d.CodMovimiento IS NOT NULL THEN 'D'
                ELSE 'U'
           END,
           COALESCE(CAST(i.CodMovimiento AS NVARCHAR(30)), CAST(d.CodMovimiento AS NVARCHAR(30))),
           CASE WHEN d.CodMovimiento IS NOT NULL
                THEN (SELECT CAST(JSON_QUERY((SELECT * FROM DELETED AS inner_d
                                             WHERE inner_d.CodMovimiento = d.CodMovimiento
                                             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), '$') AS NVARCHAR(MAX)))
                ELSE NULL
           END,
           CASE WHEN i.CodMovimiento IS NOT NULL
                THEN (SELECT CAST(JSON_QUERY((SELECT * FROM INSERTED AS inner_i
                                             WHERE inner_i.CodMovimiento = i.CodMovimiento
                                             FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), '$') AS NVARCHAR(MAX)))
                ELSE NULL
           END,
           SYSTEM_USER, HOST_NAME(), @@SPID
    FROM INSERTED i
    FULL OUTER JOIN DELETED d ON i.CodMovimiento = d.CodMovimiento
END
GO

-- ============================================================================
-- Función ventana: Saldo acumulado por cuenta (running total)
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.usp_Movimiento_SaldoAcumulado
    @CodCuenta NCHAR(16),
    @FechaDesde DATE,
    @FechaHasta DATE
AS
BEGIN
    SET NOCOUNT ON

    ;WITH MovOrdenados AS (
        SELECT CodMovimiento, CodCuenta, FechaMov, TipoMov, Monto, Signo, Referencia,
               CASE Signo WHEN 'C' THEN Monto ELSE -Monto END AS MontoNeto,
               ROW_NUMBER() OVER (PARTITION BY CodCuenta ORDER BY FechaMov, CodMovimiento) AS RN
        FROM dbo.Movimiento
        WHERE CodCuenta = @CodCuenta
          AND FechaMov >= @FechaDesde
          AND FechaMov < DATEADD(DAY, 1, @FechaHasta)
    )
    SELECT CodMovimiento, FechaMov, TipoMov, Monto, Signo, Referencia, MontoNeto,
           SUM(MontoNeto) OVER (PARTITION BY CodCuenta
                                ORDER BY FechaMov, CodMovimiento
                                ROWS UNBOUNDED PRECEDING) AS SaldoAcumulado
    FROM MovOrdenados
    ORDER BY FechaMov, CodMovimiento
END
GO

-- ============================================================================
-- Vista materializada (indexada): Resumen diario de cuentas
-- ============================================================================
CREATE OR ALTER VIEW dbo.vw_Cuenta_ResumenDiario WITH SCHEMABINDING
AS
SELECT CodCuenta,
       CONVERT(DATE, FechaMov) AS Fecha,
       COUNT_BIG(*)            AS TotalMovimientos,
       SUM(CASE WHEN Signo = 'C' THEN Monto ELSE 0 END) AS TotalCreditos,
       SUM(CASE WHEN Signo = 'D' THEN Monto ELSE 0 END) AS TotalDebitos
FROM dbo.Movimiento
GROUP BY CodCuenta, CONVERT(DATE, FechaMov)
GO

-- Para convertirla en vista materializada (SQL Server Enterprise):
-- CREATE UNIQUE CLUSTERED INDEX IX_vw_Cuenta_ResumenDiario
--     ON dbo.vw_Cuenta_ResumenDiario (CodCuenta, Fecha)
-- GO
