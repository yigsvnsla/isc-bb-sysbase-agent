# pa_con_ccertificado_pagos_gen

## Ficha Técnica

| Atributo | Valor |
|----------|-------|
| **Nombre** | `pa_con_ccertificado_pagos_gen` |
| **Motor** | Sybase ASE |
| **Base de datos** | cob_cuentas |
| **Tipo** | Stored Procedure |
| **Complejidad** | Media-Baja |
| **Procesamiento** | OLTP |

## Propósito

Genera certificado de pagos: opción `F` retorna fechas proceso, opción `C` consulta pagos del usuario con paginación usando tablas temporales.

## Parámetros

| Nombre | Tipo | Modo | Descripción |
|--------|------|------|-------------|
| `@e_fecha` | `DATETIME` | IN | Fecha de referencia |
| `@e_causa` | `VARCHAR(10)` | IN | Causa (código empresa) |
| `@e_usuario` | `VARCHAR(10)` | IN | Usuario |
| `@e_oficina` | `VARCHAR(10)` | IN | Oficina |
| `@e_pagina` | `INT` | IN | Página (paginación) |
| `@e_limite` | `INT` | IN | Filas por página |
| `@e_opcion` | `VARCHAR(1)` | IN | `F`=fechas, `C`=pagos |

## Variables

| Nombre | Tipo | Uso |
|--------|------|-----|
| `@v_fecha_anterior` | `DATETIME` | Último día hábil |
| `@v_return` | `INT` | Código retorno |
| `@v_incio` | `INT` | Inicio rango paginación |
| `@v_fin` | `INT` | Fin rango paginación |

## Tablas Referenciadas

| Base de datos | Tabla | Tipo |
|---------------|-------|------|
| `cobis` | `cl_catalogo` | Catálogo |
| `cobis` | `cl_tabla` | Catálogo |
| `cobis` | `cl_ttransaccion` | Maestro |
| `cobis` | `cl_oficina` | Maestro |
| `cobis` | `cl_ciudad` | Maestro |
| `cob_pagos` | `pg_person_empresa` | Maestro |
| `cob_cuentas` | `cc_tran_servicio` | Transacción |
| `cob_cuentas` | `cc_tran_servicio_resp` | Transacción |

## Flujo

```mermaid
flowchart TD
    A[INICIO] --> B[SET NOCOUNT ON]
    B --> C[Calcular @v_incio/@v_fin paginación]
    C --> D{@e_opcion IN ('F','C')?}
    D -->|No| E[RETURN 99999 - Opción no válida]
    D -->|Sí| F[EXEC sp_ult_dia_habil_ant]
    F --> G{@e_opcion = 'F'?}
    G -->|Sí| H[SELECT fechas proceso]
    H --> I[RETURN 0]
    G -->|No| J[Crear #reca_tmp_trx_serv]
    J --> K[Crear #reca_tmp_servicio]
    K --> L[Crear #reca_tmp_trx_reversadas]
    L --> M[Crear tabla #reca_tmp_trx]
    M --> N[INSERT pagos con JOINs]
    N --> O[SELECT paginado con BETWEEN]
    O --> P[DROP tablas temporales]
    P --> Q[RETURN 0]
```

## Validación ARQT-EST-001

| Regla | Estado | Nota |
|-------|--------|------|
| Prefijo `pa_` | ✅ Usa `pa_` | Correcto |
| Nemónico `con` | ✅ Aplica Contabilidad | Correcto |
| Parámetros `@e_`/`@s_` | ✅ Usa `@e_` entrada | Correcto |
| Variables `@v_` | ✅ Usa `@v_` | Correcto |
| Manejo transacciones | ❌ No tiene BEGIN TRAN/COMMIT | Solo consultas SELECT/INSERT a temp |
| Control errores `@@error` | ✅ `@@error` después cada operación | Correcto |
| Comentario cabecera | ❌ Sin cabecera estándar | |
| Tablas temporales prefijo `#` | ✅ `#reca_tmp_` | Correcto |
| Cleanup temp tables | ✅ DROP en cleanup | Correcto |
