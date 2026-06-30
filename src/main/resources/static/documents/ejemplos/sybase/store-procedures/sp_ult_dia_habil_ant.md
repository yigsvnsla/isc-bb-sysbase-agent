# sp_ult_dia_habil_ant

## Ficha Técnica

| Atributo | Valor |
|----------|-------|
| **Nombre** | `sp_ult_dia_habil_ant` |
| **Motor** | Sybase ASE |
| **Base de datos** | cob_cuentas |
| **Tipo** | Stored Procedure |
| **Complejidad** | Baja |
| **Procesamiento** | OLTP |

## Propósito

Retorna la fecha del último día hábil anterior a una fecha dada, consultando la tabla de feriados (`cl_dias_feriados`).

## Parámetros

| Nombre | Tipo | Modo | Descripción |
|--------|------|------|-------------|
| `@i_fecha` | `datetime` | IN | Fecha de referencia (null → fecha proceso) |
| `@i_fch_habil` | `datetime` | OUT | Último día hábil anterior |

## Variables

| Nombre | Tipo | Uso |
|--------|------|-----|
| `@w_verdadero` | `char(1)` | Control del bucle |
| `@w_dia_habil` | `varchar(12)` | Fecha hábil temporal |
| `@w_fecha_cobro` | `varchar(12)` | (sin uso) |
| `@i_ciudad` | `int` | Ciudad para filtro (default 1) |

## Tablas Referenciadas

| Base de datos | Tabla | Tipo |
|---------------|-------|------|
| `cobis` | `ba_fecha_proceso` | Parámetro |
| `cobis` | `cl_dias_feriados` | Maestro |

## Flujo

```mermaid
flowchart TD
    A[INICIO] --> B{@i_fecha IS NULL?}
    B -->|Sí| C[Obtener fp_fecha de ba_fecha_proceso]
    B -->|No| D[Usar @i_fecha]
    C --> D
    D --> E[Set @i_ciudad = 1]
    E --> F[Set @w_verdadero = 'S']
    F --> G{@w_verdadero = 'S'?}
    G -->|Sí| H[Buscar df_fecha en cl_dias_feriados]
    H --> I{@@rowcount = 0?}
    I -->|No es feriado → Sí| J[Set @w_verdadero = 'N']
    J --> K[Set @i_fch_habil = @i_fecha]
    K --> L[RETURN]
    I -->|Es feriado → No| M[Restar 1 día: @i_fecha - 1]
    M --> G
```

## Validación ARQT-EST-001

| Regla | Estado | Nota |
|-------|--------|------|
| Prefijo `pa_` | ❌ Usa `sp_` | Debería ser `pa_con_tult_dia_habil_ant` |
| Parámetros `@e_`/`@s_` | ❌ Usa `@i_`/`@o_` | COBIS usa `@i_`/`@o_` (estándar interno) |
| Variables `@v_` | ❌ Usa `@w_` | COBIS usa `@w_` para variables trabajo |
| Manejo transacciones | ⚠ No tiene BEGIN TRAN | Simple consulta, no requiere |
| Control errores `@@error` | ❌ Solo `@@rowcount` | Sin validación de errores |
| Comentario cabecera | ❌ Sin cabecera estándar | |
