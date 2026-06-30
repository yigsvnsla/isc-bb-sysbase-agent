-- ============================================================================
-- Oracle Database 23c — Ejemplos de tablas bancarias
-- Convenciones: snake_case, prefijo T_ para tablas, esquema por defecto
-- ============================================================================

-- ============================================================================
-- 1. Tabla maestra de clientes
-- ============================================================================
CREATE TABLE cliente (
    cod_cliente     CHAR(8)         NOT NULL,
    nombre          VARCHAR2(80)    NOT NULL,
    tipo_documento  CHAR(3)         NOT NULL,   -- DNI, RUC, CE, PAS
    num_documento   VARCHAR2(20)    NOT NULL,
    direccion       VARCHAR2(120)   NULL,
    telefono        VARCHAR2(15)    NULL,
    email           VARCHAR2(60)    NULL,
    fecha_nac       DATE            NULL,
    fecha_alta      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    estado          CHAR(1)         DEFAULT 'A' NOT NULL,  -- A=Activo, I=Inactivo, B=Baja
    CONSTRAINT pk_cliente PRIMARY KEY (cod_cliente)
)
PCTFREE 10
INITRANS 2
STORAGE (INITIAL 64K NEXT 64K)
TABLESPACE ts_datos
/

CREATE UNIQUE INDEX ak_cliente_tipdoc_numdoc
    ON cliente (tipo_documento, num_documento)
    TABLESPACE ts_indices
/

COMMENT ON TABLE cliente IS 'Maestro de clientes del banco';
COMMENT ON COLUMN cliente.tipo_documento IS 'DNI, RUC, CE, PAS';
COMMENT ON COLUMN cliente.estado IS 'A=Activo, I=Inactivo, B=Baja';
/

-- ============================================================================
-- 2. Tabla de cuentas
-- ============================================================================
CREATE TABLE cuenta (
    cod_cuenta          CHAR(16)        NOT NULL,
    cod_cliente         CHAR(8)         NOT NULL,
    tipo_cuenta         CHAR(3)         NOT NULL,   -- AHO, CTE, PLZ
    moneda              CHAR(3)         NOT NULL,   -- PEN, USD, EUR
    saldo               NUMBER(18,2)    DEFAULT 0 NOT NULL,
    fecha_apertura      TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    fecha_vencimiento   DATE            NULL,
    estado              CHAR(1)         DEFAULT 'A' NOT NULL,
    CONSTRAINT pk_cuenta PRIMARY KEY (cod_cuenta),
    CONSTRAINT fk_cuenta_cliente FOREIGN KEY (cod_cliente)
        REFERENCES cliente (cod_cliente)
)
PCTFREE 5
TABLESPACE ts_datos
/

CREATE INDEX ix_cuenta_cod_cliente ON cuenta (cod_cliente)
    TABLESPACE ts_indices
/

CREATE SEQUENCE seq_cuenta_cod
    START WITH 1000000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
/

-- ============================================================================
-- 3. Tabla de movimientos contables (particionada por mes)
-- ============================================================================
CREATE TABLE movimiento (
    cod_movimiento      NUMBER(12,0)    NOT NULL,
    cod_cuenta          CHAR(16)        NOT NULL,
    fecha_mov           TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    tipo_mov            CHAR(3)         NOT NULL,   -- DEP, RET, TRA, PAG, INT
    monto               NUMBER(18,2)    NOT NULL,
    signo               CHAR(1)         NOT NULL,   -- C=Credito, D=Debito
    referencia          VARCHAR2(60)    NULL,
    cod_usuario         VARCHAR2(20)    NOT NULL,
    cod_autorizacion    VARCHAR2(20)    NULL,
    CONSTRAINT pk_movimiento PRIMARY KEY (cod_movimiento, fecha_mov),
    CONSTRAINT fk_movimiento_cuenta FOREIGN KEY (cod_cuenta)
        REFERENCES cuenta (cod_cuenta)
)
PARTITION BY RANGE (fecha_mov)
INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))
(
    PARTITION p_mov_historicos VALUES LESS THAN (DATE '2025-01-01')
)
TABLESPACE ts_datos
/

CREATE INDEX ix_movimiento_cuenta_fecha ON movimiento (cod_cuenta, fecha_mov DESC)
    LOCAL TABLESPACE ts_indices
/

CREATE SEQUENCE seq_movimiento_cod
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
/

-- ============================================================================
-- 4. Tabla de parámetros del sistema
-- ============================================================================
CREATE TABLE parametro (
    cod_param       VARCHAR2(30)    NOT NULL,
    valor           VARCHAR2(255)   NOT NULL,
    descripcion     VARCHAR2(120)   NULL,
    fecha_actualiza TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_parametro PRIMARY KEY (cod_param)
)
TABLESPACE ts_datos
/

-- ============================================================================
-- 5. Tabla de auditoría con particionado y LOB segments
-- ============================================================================
CREATE TABLE auditoria (
    cod_auditoria   NUMBER(12,0)    NOT NULL,
    tabla           VARCHAR2(30)    NOT NULL,
    operacion       CHAR(1)         NOT NULL,   -- I=Insert, U=Update, D=Delete
    cod_registro    VARCHAR2(30)    NOT NULL,
    datos_anteriores CLOB           NULL,
    datos_nuevos    CLOB            NULL,
    usuario         VARCHAR2(20)    NOT NULL,
    fecha           TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    terminal        VARCHAR2(30)    NULL,
    sesion_id       NUMBER          NULL,
    CONSTRAINT pk_auditoria PRIMARY KEY (cod_auditoria)
)
LOB (datos_anteriores, datos_nuevos) STORE AS SECUREFILE (
    TABLESPACE ts_lobs
    ENABLE STORAGE IN ROW
    CHUNK 8192
    RETENTION AUTO
)
TABLESPACE ts_datos
/

CREATE INDEX ix_auditoria_fecha ON auditoria (fecha DESC)
    TABLESPACE ts_indices
/
CREATE INDEX ix_auditoria_tabla ON auditoria (tabla, fecha DESC)
    TABLESPACE ts_indices
/

CREATE SEQUENCE seq_auditoria_cod
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE
/
