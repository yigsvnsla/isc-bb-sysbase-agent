-- ============================================================================
-- Sybase ASE 16.x — Ejemplos avanzados: triggers, cursores, manejo errores
-- ============================================================================

-- ============================================================================
-- Trigger: Auditoría automática de movimientos
-- ============================================================================
CREATE TRIGGER TRG__movimiento__auditar
ON movimiento
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @operacion CHAR(1)
    DECLARE @cod_mov NUMERIC(12,0)
    DECLARE @datos_anteriores TEXT
    DECLARE @datos_nuevos TEXT

    -- Insert
    IF EXISTS (SELECT 1 FROM INSERTED) AND NOT EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        SELECT @operacion = 'I'
        DECLARE cur_ins CURSOR FOR SELECT cod_movimiento FROM INSERTED
        OPEN cur_ins
        FETCH cur_ins INTO @cod_mov
        WHILE @@SQLSTATUS = 0
        BEGIN
            SELECT @datos_nuevos = (SELECT * FROM INSERTED WHERE cod_movimiento = @cod_mov FOR XML RAW)
            INSERT INTO auditoria (tabla, operacion, cod_registro, datos_nuevos, usuario, terminal)
            VALUES ('movimiento', @operacion, CONVERT(VARCHAR(30), @cod_mov),
                    @datos_nuevos, SYSTEM_USER, HOST_NAME())
            FETCH cur_ins INTO @cod_mov
        END
        CLOSE cur_ins
        DEALLOCATE CURSOR cur_ins
    END

    -- Delete
    IF EXISTS (SELECT 1 FROM DELETED) AND NOT EXISTS (SELECT 1 FROM INSERTED)
    BEGIN
        SELECT @operacion = 'D'
        DECLARE cur_del CURSOR FOR SELECT cod_movimiento FROM DELETED
        OPEN cur_del
        FETCH cur_del INTO @cod_mov
        WHILE @@SQLSTATUS = 0
        BEGIN
            SELECT @datos_anteriores = (SELECT * FROM DELETED WHERE cod_movimiento = @cod_mov FOR XML RAW)
            INSERT INTO auditoria (tabla, operacion, cod_registro, datos_anteriores, usuario, terminal)
            VALUES ('movimiento', @operacion, CONVERT(VARCHAR(30), @cod_mov),
                    @datos_anteriores, SYSTEM_USER, HOST_NAME())
            FETCH cur_del INTO @cod_mov
        END
        CLOSE cur_del
        DEALLOCATE CURSOR cur_del
    END

    -- Update
    IF EXISTS (SELECT 1 FROM INSERTED) AND EXISTS (SELECT 1 FROM DELETED)
    BEGIN
        SELECT @operacion = 'U'
        DECLARE cur_upd CURSOR FOR
            SELECT i.cod_movimiento FROM INSERTED i INNER JOIN DELETED d ON i.cod_movimiento = d.cod_movimiento
        OPEN cur_upd
        FETCH cur_upd INTO @cod_mov
        WHILE @@SQLSTATUS = 0
        BEGIN
            SELECT @datos_anteriores = (SELECT * FROM DELETED WHERE cod_movimiento = @cod_mov FOR XML RAW)
            SELECT @datos_nuevos = (SELECT * FROM INSERTED WHERE cod_movimiento = @cod_mov FOR XML RAW)
            INSERT INTO auditoria (tabla, operacion, cod_registro, datos_anteriores, datos_nuevos, usuario, terminal)
            VALUES ('movimiento', @operacion, CONVERT(VARCHAR(30), @cod_mov),
                    @datos_anteriores, @datos_nuevos, SYSTEM_USER, HOST_NAME())
            FETCH cur_upd INTO @cod_mov
        END
        CLOSE cur_upd
        DEALLOCATE CURSOR cur_upd
    END
END
GO

-- ============================================================================
-- Trigger: Evitar saldo negativo en cuentas
-- ============================================================================
CREATE TRIGGER TRG__cuenta__validar_saldo
ON cuenta
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON

    IF EXISTS (SELECT 1 FROM INSERTED WHERE saldo < 0 AND estado = 'A')
    BEGIN
        RAISERROR 50020 'La cuenta no puede tener saldo negativo'
        ROLLBACK TRIGGER
        RETURN
    END
END
GO

-- ============================================================================
-- Función escalar: Calcular edad del cliente
-- ============================================================================
CREATE FUNCTION fn_cliente_calcular_edad
    (@fecha_nac SMALLDATETIME)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @fecha_nac, GETDATE()) -
           CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @fecha_nac, GETDATE()), @fecha_nac) > GETDATE()
                THEN 1 ELSE 0
           END
END
GO

-- ============================================================================
-- Procedimiento: Cierre contable diario (con cursor y savepoint)
-- ============================================================================
CREATE PROCEDURE sp_contabilidad_cierre_diario
    @fecha_cierre DATETIME,
    @cod_usuario  VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON
    SET CHAINED ON

    DECLARE @cod_cuenta  CHAR(16)
    DECLARE @saldo_actual NUMERIC(18,2)
    DECLARE @total_movs  NUMERIC(18,2)
    DECLARE @err INT

    SAVE TRANSACTION antes_cierre

    DECLARE cur_ctas CURSOR FOR
        SELECT cod_cuenta, saldo
        FROM cuenta
        WHERE estado = 'A'

    OPEN cur_ctas
    FETCH cur_ctas INTO @cod_cuenta, @saldo_actual

    WHILE @@SQLSTATUS = 0
    BEGIN
        SELECT @total_movs = ISNULL(SUM(
            CASE signo WHEN 'C' THEN monto ELSE monto * -1 END
        ), 0)
        FROM movimiento
        WHERE cod_cuenta = @cod_cuenta
          AND CONVERT(DATETIME, CONVERT(CHAR(10), fecha_mov, 102)) = @fecha_cierre

        IF ABS(@total_movs) > 0.005
        BEGIN
            UPDATE cuenta
            SET saldo = @saldo_actual
            WHERE cod_cuenta = @cod_cuenta

            SELECT @err = @@ERROR
            IF @err <> 0
            BEGIN
                ROLLBACK TRANSACTION antes_cierre
                CLOSE cur_ctas
                DEALLOCATE CURSOR cur_ctas
                RETURN @err
            END
        END

        FETCH cur_ctas INTO @cod_cuenta, @saldo_actual
    END

    CLOSE cur_ctas
    DEALLOCATE CURSOR cur_ctas

    COMMIT
    RETURN 0
END
GO
