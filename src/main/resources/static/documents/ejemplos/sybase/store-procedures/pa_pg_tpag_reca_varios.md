# pa_pg_tpag_reca_varios

## Ficha Técnica

| Atributo | Valor |
|----------|-------|
| **Nombre** | `pa_pg_tpag_reca_varios` |
| **Motor** | Sybase ASE |
| **Servidor** | HP-ACT |
| **Base de datos** | `cob_pagos` |
| **Aplicación** | CyberBank (Recaudaciones) |
| **Producto** | Recaudaciones |
| **Tipo** | Stored Procedure |
| **Complejidad** | Alta |
| **Procesamiento** | OLTP |

## Propósito

Procesa pagos/reversos de recaudaciones en vía rápida. Orquesta múltiples subprocesos:
validación de horario, registro débito/crédito, comisiones, base imponible SRI,
notificaciones, e información CNB. Soporta multicanal (VEN, CNB).

## Historial de Cambios

| Ref | Fecha | Autor | Razón |
|-----|-------|-------|-------|
| 1 | 05/May/2022 | J. Guerrero | Emisión inicial |
| 2 | 13/Dic/2022 | K. Bastidas | Add campo TC |
| 3 | 05/May/2023 | J. Guerrero | Pagos Mixtos ATX |
| 4 | 04/Jul/2023 | K. Bastidas | Migración Microservicio SRI |
| 5 | 21/Ago/2023 | K. Bastidas | Ajuste tipo pago Cheque/Efectivo |
| 6 | 13/Nov/2023 | J. Guerrero | Add campo retención |
| 7 | 06/Nov/2024 | L. Lozano | Flujo municipio Canal CNB |
| 8 | 19/Nov/2024 | C. Salazar | Campo tm_campo_alt_uno |
| 9 | 07/May/2025 | L. Lozano | Exonerar Empresa Arcsa |
| 10 | 08/Sep/2025 | J. Guerrero | MULTICASH MEDLOG |
| 11 | 25/Nov/2025 | J. Guzman | MULTICASH IMMOBILIARIO |
| 12 | 26/Nov/2025 | L. Lascano | SRI TD con TC |
| 13 | 22/Dic/2025 | J. Guerrero | Ajuste fecha proc VEN |
| 14 | 20/Mar/2025 | R. Macias | Ajuste fecha proceso recaudaciones |
| 15 | 28/Abr/2026 | K. Bastidas | Unicomer BackOffice |

## Parámetros

Más de 80 parámetros. Categorías:
- **Sistema (`@e_ssn`, `@e_srv`, `@e_user`, `@e_term`, `@e_date`, etc.)** — Sesión COBIS
- **Pago (`@e_efectivo`, `@e_cheque`, `@e_debito`, `@e_tarjeta`, `@e_total`)** — Montos
- **Comisión (`@e_comision_tot`, `@e_comision_efe`, `@e_comision_chq`, `@e_comision_db`)** — Costos
- **Cliente (`@e_ruc_cliente`, `@e_nombre_cliente`, `@e_servicio`, `@e_empresa`)** — Datos
- **CNB (`@e_terminal_id`, `@e_comercio`, `@e_cod_autorizacion`, `@e_agencia`, `@e_red`)** — Canal
- **Salida (`@s_fecha_contable`, `@s_ssn`, `@s_cod_respuesta`, `@s_mensaje_respuesta`, etc.)**

## Variables

Más de 20 variables `@v_` para: control flujo, horario, montos, referencias multicash, validaciones.

## Tablas Referenciadas (30+)

| Base de datos | Tabla | Uso |
|---------------|-------|-----|
| `cobis` | `ba_fecha_proceso` | Fecha proceso |
| `cobis` | `cl_catalogo` | Catálogos (horario, TRN, etc.) |
| `cobis` | `cl_tabla` | Catálogos |
| `cobis` | `cl_parametro` | Monto máximo |
| `cobis` | `cl_oficina` | Oficina |
| `cob_pagos` | `pg_person_empresa` | Datos empresa |
| `cob_cuentas` | `cc_tran_servicio` | Transacciones servicio |
| `cob_cuentas` | `cc_dias_laborables` | Días laborables |
| `cob_remesas` | `re_horario` | Horario diferido |

## Subprocesos Invocados

| SP | Base de datos | Propósito |
|----|---------------|-----------|
| `sp_verifica_caja_rc` | `cob_remesas` | Verificar horario caja |
| `pa_pg_cpag_notificacion` | `cob_pagos` | Datos notificación |
| `pa_pg_tpag_deb_cre` | `cob_pagos` | Registrar débito/crédito |
| `pa_pg_tpag_comision` | `cob_pagos` | Registrar comisión |
| `sp_ins_retiva_bieserv` | `cob_pagos` | Base imponible SRI |
| `pa_cc_iinfo_cnb` | `cob_cuentas` | Información CNB |
| `pa_cc_ifactura_cnb` | `cob_cuentas` | Factura CNB |

## Flujo Principal

```mermaid
flowchart TD
    A[INICIO] --> B[Inicializar variables + obtener fecha proceso]
    B --> C{@e_corr = 'N'?}
    C -->|Sí| D[Set @e_date = fecha proceso]
    C -->|No| E[Usar @e_date original]
    D --> F[Set @v_cod_referencia]
    F --> G[Obtener hora tope sv_horario_serv]
    G --> H{Depósito en línea?}
    H -->|Sí| I[Set @e_trn = 4435, @v_org = 'L']
    H -->|No| J[Obtener TRN desde sv_trx_srv_rms_hn]
    I --> K{Canal = VEN?}
    J --> K
    K -->|Sí| L[Verificar horario caja + diferido]
    K -->|No| M{Canal = CNB?}
    L --> N{Hora >= hora_tope?}
    M --> N
    N -->|Sí| O[Set @s_horario = 'D', TRN HD2]
    N -->|No| P{@e_corr = 'S'?}
    O --> P
    P -->|Sí| Q[Validar TRN original + restricciones]
    P -->|No| R[Validar moneda = USD]
    Q --> R
    R --> S[Validar monto máximo]
    S --> T[Consultar datos notificación]
    T --> U[INICIO TRAN]
    U --> V[EXEC pa_pg_tpag_deb_cre]
    V --> W{OK?}
    W -->|No| X[ROLLBACK + RETURN]
    W -->|Sí| Y[INSERT cc_tran_servicio]
    Y --> Z{Base imponible SRI?}
    Z -->|Sí| AA[EXEC sp_ins_retiva_bieserv]
    AA --> AB{Canal CNB?}
    Z --> AB
    AB -->|Sí| AC[EXEC pa_cc_iinfo_cnb + pa_cc_ifactura_cnb]
    AB -->|No| AD[COMMIT TRAN]
    AC --> AD
    AD --> AE[RETURN 0]
```

## Validación ARQT-EST-001

| Regla | Estado | Nota |
|-------|--------|------|
| Prefijo `pa_` | ✅ Usa `pa_` | Correcto |
| Nemónico `pg` | ✅ Pagos | Correcto |
| Parámetros `@e_`/`@s_` | ✅ `@e_` entrada, `@s_` salida | Correcto |
| Variables `@v_` | ✅ `@v_` variables trabajo | Correcto |
| Manejo transacciones | ✅ BEGIN TRAN + COMMIT + ROLLBACK | Correcto |
| Control errores `@@error` | ✅ `@@error` después cada operación | Correcto |
| Comentario cabecera | ✅ Cabecera completa con historia cambios | Correcto |
| Referencia cambios `--<REF #` | ✅ Marcado sistemático | Correcto |
| Tipo operación | ❌ No usa letra tipo (`t`, `p`, etc.) | Nombre sin sufijo operación |
| Longitud nombre | ❌ `pa_pg_tpag_reca_varios` > 30 car. | 28 caracteres → OK |
