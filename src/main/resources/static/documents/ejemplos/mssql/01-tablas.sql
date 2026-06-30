-- ============================================================================
-- Microsoft SQL Server 2022 — Ejemplos de tablas bancarias
-- Convenciones: PascalCase, esquema dbo, prefijo tipo objeto
-- ============================================================================

-- ============================================================================
-- 1. Tabla maestra de clientes
-- ============================================================================
CREATE TABLE dbo.Cliente (
    CodCliente      NCHAR(8)        NOT NULL,
    Nombre          NVARCHAR(80)    NOT NULL,
    TipoDocumento   NCHAR(3)        NOT NULL,   -- DNI, RUC, CE, PAS
    NumDocumento    NVARCHAR(20)    NOT NULL,
    Direccion       NVARCHAR(120)   NULL,
    Telefono        NVARCHAR(15)    NULL,
    Email           NVARCHAR(60)    NULL,
    FechaNac        DATE            NULL,
    FechaAlta       DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    Estado          NCHAR(1)        NOT NULL DEFAULT 'A',  -- A=Activo, I=Inactivo, B=Baja
    CONSTRAINT PK__Cliente PRIMARY KEY CLUSTERED (CodCliente)
)
GO

CREATE UNIQUE INDEX AK__Cliente_TipoDoc_NumDoc
    ON dbo.Cliente (TipoDocumento, NumDocumento)
    WHERE Estado = 'A'
GO

-- ============================================================================
-- 2. Tabla de cuentas
-- ============================================================================
CREATE TABLE dbo.Cuenta (
    CodCuenta       NCHAR(16)       NOT NULL,
    CodCliente      NCHAR(8)        NOT NULL,
    TipoCuenta      NCHAR(3)        NOT NULL,   -- AHO, CTE, PLZ
    Moneda          NCHAR(3)        NOT NULL,   -- PEN, USD, EUR
    Saldo           DECIMAL(18,2)   NOT NULL DEFAULT 0,
    FechaApertura   DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    FechaVencimiento DATETIME2      NULL,
    Estado          NCHAR(1)        NOT NULL DEFAULT 'A',
    RowVersion      ROWVERSION      NOT NULL,
    CONSTRAINT PK__Cuenta PRIMARY KEY CLUSTERED (CodCuenta),
    CONSTRAINT FK__Cuenta__Cliente FOREIGN KEY (CodCliente)
        REFERENCES dbo.Cliente (CodCliente)
)
GO

CREATE INDEX IX__Cuenta__CodCliente ON dbo.Cuenta (CodCliente)
    INCLUDE (Saldo, Estado)
GO

-- ============================================================================
-- 3. Tabla de movimientos contables
-- ============================================================================
CREATE TABLE dbo.Movimiento (
    CodMovimiento   BIGINT          IDENTITY(1000000,1) NOT NULL,
    CodCuenta       NCHAR(16)       NOT NULL,
    FechaMov        DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    TipoMov         NCHAR(3)        NOT NULL,   -- DEP, RET, TRA, PAG, INT
    Monto           DECIMAL(18,2)   NOT NULL,
    Signo           NCHAR(1)        NOT NULL,   -- C=Credito, D=Debito
    Referencia      NVARCHAR(60)    NULL,
    CodUsuario      NVARCHAR(20)    NOT NULL,
    CodAutorizacion NVARCHAR(20)    NULL,
    CONSTRAINT PK__Movimiento PRIMARY KEY CLUSTERED (CodMovimiento),
    CONSTRAINT FK__Movimiento__Cuenta FOREIGN KEY (CodCuenta)
        REFERENCES dbo.Cuenta (CodCuenta)
)
GO

CREATE INDEX IX__Movimiento__Fecha ON dbo.Movimiento (FechaMov DESC)
    INCLUDE (CodCuenta, Monto, Signo)
GO

CREATE INDEX IX__Movimiento__CodCuenta ON dbo.Movimiento (CodCuenta, FechaMov DESC)
GO

-- ============================================================================
-- 4. Tabla de parámetros del sistema
-- ============================================================================
CREATE TABLE dbo.Parametro (
    CodParam        NVARCHAR(30)    NOT NULL,
    Valor           NVARCHAR(255)   NOT NULL,
    Descripcion     NVARCHAR(120)   NULL,
    FechaActualiza  DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK__Parametro PRIMARY KEY CLUSTERED (CodParam)
)
GO

-- ============================================================================
-- 5. Tabla de auditoría con particionado implícito (vistas)
-- ============================================================================
CREATE TABLE dbo.Auditoria (
    CodAuditoria    BIGINT          IDENTITY(1,1) NOT NULL,
    Tabla           NVARCHAR(30)    NOT NULL,
    Operacion       NCHAR(1)        NOT NULL,   -- I=Insert, U=Update, D=Delete
    CodRegistro     NVARCHAR(30)    NOT NULL,
    DatosAnteriores NVARCHAR(MAX)   NULL,
    DatosNuevos     NVARCHAR(MAX)   NULL,
    Usuario         NVARCHAR(20)    NOT NULL,
    Fecha           DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
    Terminal        NVARCHAR(30)    NULL,
    SesionID        INT             NULL,
    CONSTRAINT PK__Auditoria PRIMARY KEY CLUSTERED (CodAuditoria)
)
GO

CREATE INDEX IX__Auditoria__Fecha ON dbo.Auditoria (Fecha DESC)
GO
CREATE INDEX IX__Auditoria__Tabla ON dbo.Auditoria (Tabla, Fecha DESC)
GO
