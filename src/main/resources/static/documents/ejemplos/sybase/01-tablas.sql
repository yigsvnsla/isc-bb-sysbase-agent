-- ============================================================================
-- Sybase ASE 16.x — Ejemplos de tablas bancarias
-- Convenciones: snake_case, nombres descriptivos, prefijo tipo objeto
-- ============================================================================

-- ============================================================================
-- 1. Tabla maestra de clientes
-- ============================================================================
CREATE TABLE cliente (
    cod_cliente     CHAR(8)         NOT NULL,
    nombre          VARCHAR(80)     NOT NULL,
    tipo_documento  CHAR(3)         NOT NULL,   -- DNI, RUC, CE, PAS
    num_documento   VARCHAR(20)     NOT NULL,
    direccion       VARCHAR(120)    NULL,
    telefono        VARCHAR(15)     NULL,
    email           VARCHAR(60)     NULL,
    fecha_nac       SMALLDATETIME   NULL,
    fecha_alta      DATETIME        NOT NULL DEFAULT GETDATE(),
    estado          CHAR(1)         NOT NULL DEFAULT 'A',  -- A=Activo, I=Inactivo, B=Baja
    CONSTRAINT PK__cliente PRIMARY KEY CLUSTERED (cod_cliente)
)
LOCK ALLPAGES
WITH IDENTITY_GAP = 1000
GO

CREATE UNIQUE INDEX AK__cliente_tipdoc_numdoc
    ON cliente (tipo_documento, num_documento)
GO

-- ============================================================================
-- 2. Tabla de cuentas (ahorro, corriente, plazo fijo)
-- ============================================================================
CREATE TABLE cuenta (
    cod_cuenta      CHAR(16)        NOT NULL,
    cod_cliente     CHAR(8)         NOT NULL,
    tipo_cuenta     CHAR(3)         NOT NULL,   -- AHO, CTE, PLZ
    moneda          CHAR(3)         NOT NULL,   -- PEN, USD, EUR
    saldo           NUMERIC(18,2)   NOT NULL DEFAULT 0,
    fecha_apertura  DATETIME        NOT NULL DEFAULT GETDATE(),
    fecha_vencimiento DATETIME      NULL,
    estado          CHAR(1)         NOT NULL DEFAULT 'A',
    CONSTRAINT PK__cuenta PRIMARY KEY CLUSTERED (cod_cuenta),
    CONSTRAINT FK__cuenta__cliente FOREIGN KEY (cod_cliente)
        REFERENCES cliente (cod_cliente)
)
LOCK DATAPAGES
GO

CREATE INDEX IX__cuenta__cod_cliente ON cuenta (cod_cliente)
GO

-- ============================================================================
-- 3. Tabla de movimientos contables
-- ============================================================================
CREATE TABLE movimiento (
    cod_movimiento  NUMERIC(12,0)   IDENTITY NOT NULL,
    cod_cuenta      CHAR(16)        NOT NULL,
    fecha_mov       DATETIME        NOT NULL DEFAULT GETDATE(),
    tipo_mov        CHAR(3)         NOT NULL,   -- DEP, RET, TRA, PAG, INT
    monto           NUMERIC(18,2)   NOT NULL,
    signo           CHAR(1)         NOT NULL,   -- C=Credito, D=Debito
    referencia      VARCHAR(60)     NULL,
    cod_usuario     VARCHAR(20)     NOT NULL,
    cod_autorizacion VARCHAR(20)    NULL,
    CONSTRAINT PK__movimiento PRIMARY KEY CLUSTERED (cod_movimiento),
    CONSTRAINT FK__movimiento__cuenta FOREIGN KEY (cod_cuenta)
        REFERENCES cuenta (cod_cuenta)
)
LOCK DATAPAGES
GO

CREATE INDEX IX__movimiento__fecha ON movimiento (fecha_mov)
GO
CREATE INDEX IX__movimiento__cod_cuenta ON movimiento (cod_cuenta)
GO

-- ============================================================================
-- 4. Tabla de parámetros del sistema
-- ============================================================================
CREATE TABLE parametro (
    cod_param       VARCHAR(30)     NOT NULL,
    valor           VARCHAR(255)    NOT NULL,
    descripcion     VARCHAR(120)    NULL,
    fecha_actualiza DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK__parametro PRIMARY KEY CLUSTERED (cod_param)
)
LOCK ALLPAGES
GO

-- ============================================================================
-- 5. Tabla de auditoría (con campos de solo lectura)
-- ============================================================================
CREATE TABLE auditoria (
    cod_auditoria   NUMERIC(12,0)   IDENTITY NOT NULL,
    tabla           VARCHAR(30)     NOT NULL,
    operacion       CHAR(1)         NOT NULL,   -- I=Insert, U=Update, D=Delete
    cod_registro    VARCHAR(30)     NOT NULL,
    datos_anteriores TEXT           NULL,
    datos_nuevos    TEXT            NULL,
    usuario         VARCHAR(20)     NOT NULL,
    fecha           DATETIME        NOT NULL DEFAULT GETDATE(),
    terminal        VARCHAR(30)     NULL,
    CONSTRAINT PK__auditoria PRIMARY KEY CLUSTERED (cod_auditoria)
)
LOCK DATAPAGES
GO

CREATE INDEX IX__auditoria__fecha ON auditoria (fecha)
GO
CREATE INDEX IX__auditoria__tabla ON auditoria (tabla)
GO
