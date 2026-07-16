-- ============================================================================
-- Archivo:      pg_person_empresa.sql
-- Motor de Base: POSTGRESQL 16
-- Base de datos: sp_docs
-- Servidor:     localhost
-- Aplicacion:   sysbase-agent
-- Tabla:        pg_person_empresa
-- Esquema:      cob_pagos
-- Proposito:    Relacion persona-empresa para recaudaciones
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS cob_pagos;

CREATE TABLE IF NOT EXISTS cob_pagos.pg_person_empresa (
    pe_empresa   INTEGER NOT NULL,
    pe_nombre    VARCHAR(32),
    pe_cuenta    VARCHAR(10),
    pe_producto  CHAR(3),
    pe_estado    CHAR(1) DEFAULT 'V',
    CONSTRAINT pk_pg_person_empresa PRIMARY KEY (pe_empresa),
    CONSTRAINT ck_pg_person_empresa_estado CHECK (pe_estado IN ('V', 'I'))
);

COMMENT ON TABLE cob_pagos.pg_person_empresa IS 'Relacion persona-empresa para recaudaciones';
COMMENT ON COLUMN cob_pagos.pg_person_empresa.pe_empresa IS 'Codigo de empresa';
COMMENT ON COLUMN cob_pagos.pg_person_empresa.pe_nombre IS 'Nombre de la empresa';
COMMENT ON COLUMN cob_pagos.pg_person_empresa.pe_cuenta IS 'Numero de cuenta';
COMMENT ON COLUMN cob_pagos.pg_person_empresa.pe_producto IS 'Tipo de producto';
