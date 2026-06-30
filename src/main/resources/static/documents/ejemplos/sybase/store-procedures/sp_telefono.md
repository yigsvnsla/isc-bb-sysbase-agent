# sp_telefono

## Ficha Técnica

| Atributo | Valor |
|----------|-------|
| **Nombre** | `sp_telefono` |
| **Motor** | Sybase ASE |
| **Base de datos** | cobis |
| **Tipo** | Stored Procedure |
| **Complejidad** | Media-Alta |
| **Procesamiento** | OLTP |

## Propósito

CRUD completo de teléfonos de clientes. Opera por `@i_operacion`:
- `I` (Insert) — Ingreso con TRN 111
- `U` (Update) — Actualización con TRN 112
- `S` (Search) — Búsqueda con TRN 147
- `Q` (Query) — Consulta específica con TRN 147
- `D` (Delete) — Eliminación con TRN 148
- `B` (Banca Virtual) — Consulta paginada para BV con TRN 147

Incluye validaciones: existencia ente, producto, dirección, tipo teléfono, región, longitud.
Envía notificaciones al cliente por cambios (ref20/ref21).

## Parámetros Destacados

| Nombre | Tipo | Modo | Descripción |
|--------|------|------|-------------|
| `@i_operacion` | `char(1)` | IN | I/U/S/Q/D/B |
| `@i_ente` | `int` | IN | Código ente |
| `@i_valor` | `varchar(12)` | IN | Número teléfono |
| `@i_tipo_telefono` | `char(1)` | IN | Tipo catálogo |
| `@o_secuencial` | `tinyint` | OUT | Secuencia asignada |
| `@o_msj_error` | `varchar(132)` | OUT | Mensaje error |
| `@e_ssn` a `@i_canal` | varios | IN | Parámetros sistema COBIS |

## Variables

Usa `@w_` para trabajo y `@v_` para valores anteriores en UPDATE (comparación cambio).

## Tablas Referenciadas

| Base de datos | Tabla | Operación |
|---------------|-------|-----------|
| `cobis` | `cl_telefono` | I/U/S/Q/D/B |
| `cobis` | `ts_telefono` | I/U/D (historial transacciones) |
| `cobis` | `cl_ente` | I/U/D |
| `cobis` | `cl_producto` | I/U/D |
| `cobis` | `cl_direccion` | I/U/D |
| `cobis` | `cl_catalogo` | I/U/D/S/Q/B |
| `cobis` | `cl_tabla` | I/U/D/S/Q/B |
| `cobis` | `cl_ttelefono` | I/U (catálogo) |
| `cobis` | `cl_direccion_email` | I/U/D |
| `cobis` | `cl_parametro` | I/U |
| `cobis` | `cl_region_telefono` | I/U/Q |
| `cobis` | `ba_fecha_proceso` | I (via sp_ult_dia_habil_ant) |

## Flujo por Operación

```mermaid
flowchart TD
    A[INICIO sp_telefono] --> B[Declarar variables + SET NOCOUNT ON]
    B --> C{@i_operacion?}
    
    C -->|I - Insert| D[Validar FK: producto, dirección, tipo_tel, región, longitud]
    D --> E[Obtener secuencial + INICIO TRAN]
    E --> F[INSERT cl_telefono + ts_telefono]
    F --> G[Notificación si aplica]
    G --> H[COMMIT TRAN + RETURN 0]
    
    C -->|U - Update| I[Validar FK + obtener valores actuales cl_telefono]
    I --> J[Comparar cambio x cambio]
    J --> K[INICIO TRAN + UPDATE cl_telefono]
    K --> L[INSERT ts_telefono (valores previos + nuevos)]
    L --> G
    
    C -->|D - Delete| M[Validar + obtener valores cl_telefono]
    M --> N[INICIO TRAN + DELETE cl_telefono]
    N --> O[INSERT ts_telefono (valores eliminados)]
    O --> G
    
    C -->|S - Search| P[SELECT con JOIN catálogos]
    P --> Q[RETURN con set de resultados]
    
    C -->|Q - Query| R[SELECT a variables + SELECT final]
    R --> Q
    
    C -->|B - Banca Virtual| S[SELECT paginado con rowcount 20]
    S --> Q
```

## Validación ARQT-EST-001

| Regla | Estado | Nota |
|-------|--------|------|
| Prefijo `pa_` | ❌ Usa `sp_` | Debería ser `pa_mis_ttelefono` |
| Parámetros `@e_`/`@s_` | ❌ Usa `@i_`/`@o_`/`@s_`/`@p_`/`@t_` | Mezcla convenciones COBIS |
| Variables `@v_` | ⚠ Mezcla `@w_` y `@v_` | COBIS usa `@w_` para todo |
| Manejo transacciones | ✅ BEGIN TRAN/COMMIT + ROLLBACK | Correcto |
| Control errores `@@error` | ✅ Después cada operación | Correcto |
| Comentario cabecera | ❌ Sin cabecera estándar | |
| Referencia cambios | ✅ `--<REF #` / `--REF #>` | Correcto |
| GOTO para errores | ✅ `mensaje_error` label | Correcto |
| Longitud nombre | ⚠ `sp_telefono` (10 car.) | < 30, OK |
