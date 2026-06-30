# Estándares de desarrollo de Programación de Base de Datos ARQT-EST-001 v5.3

**Versión:** 5.3 — 30/11/2022
**Motores:** Sybase ASE, SQL Server, Oracle
**Elaborado por:** Arquitectura y Soporte de TI

---

## 1. Condiciones Generales

| Motor | Aplicaciones |
|-------|-------------|
| Sybase | Cobis - Core bancario |
| Oracle | Cyberbank, Tarifario |
| SqlServer | VDT, MonitorPlus, otros |

---

## 2. Sybase y SQL Server

### 2.1 Normas Generales
- Objetos en **minúsculas**, **singular**
- Nombres cortos, descriptivos, usar `_` separador
- No usar espacios ni `$`, `#`, etc.

### 2.2 Bases de Datos
- Máx. 25 caracteres, singular
- Prefijo `cob_` para aplicaciones COBIS, `db_` para no Cobis
- Históricas sufijo `_his`
- Ej: `cob_cuentas`, `cob_cuentas_his`, `db_sat_his`

### 2.3 Tablas
- Máx. 25 caracteres, singular, significativo
- Formato: `{nemónico}_{tipo}_{descripción}`
- Tipos transaccionales: `m` maestro, `r` relacional, `t` transacción, `c` cabecera, `d` detalle, `h` histórico, `p` parámetro, `s` secuencial, `l` log, `o` paso BCP
- Tipos analíticos: `d` dimensión, `h` hecho, `r` reporting, `o` operaciones, `t` transacciones, `e` externas, `i` internas, `p` plantilla
- Ej: `con_m_cuenta`, `aho_t_servicio`, `aho_h_bloqueo`

### 2.4 Tablas Temporales
- Prefijo `#` + nemónico + `_tmp_` + descripción
- Ej: `#con_tmp_producto`
- No crear en transacciones
- tempdb límite: 5GB data, 3GB log

### 2.5 Campos de Tablas
- Máx. 25 caracteres
- Prefijo (2 letras de tabla) + `_` + descripción
- Ej: `ch_cuenta`, `ch_chequera`, `ch_fecha_emision`

### 2.6 Constraints
| Tipo | Prefijo | Ejemplo |
|------|---------|---------|
| PK | `pk_` + nombre_tabla | `pk_con_m_cuenta` |
| FK | `fk_` + origen + `_` + ref | `fk_tcabfact_mclient` |
| NULL | `nu_` + tabla + `_` + campo | `nu_mcliente_codiprov` |
| NOT NULL | `nn_` + tabla + `_` + campo | `nn_mcliente_codigo` |
| UNIQUE | `uq_` + tabla + `_` + campo | `uq_mcliente_codiprov` |
| DEFAULT | `df_` + tabla + `_` + campo | `df_mcliente_fecha` |
| CHECK | `ck_` + tabla + `_` + campo | `ck_mcliente_estado` |
- Máx. 30 caracteres para constraint names
- No índice compuesto como PK

### 2.7 Índices
- Prefijo `i_` + nombre_tabla + `_` + secuencia
- Ej: `i_con_m_cuentas_01`
- Máx. 4 índices por tabla OLTP (incluye PK)
- Campos numéricos, not null preferidos
- Compuestos: campo más selectivo primero

### 2.8 Procedimientos Almacenados
- Máx. 30 caracteres
- Formato: `pa_` + nemónico + `_` + tipo + descripción
- Tipos:
  - `i` Ingreso
  - `a` Actualización
  - `e` Eliminación
  - `c` Consulta específica
  - `g` Consulta general
  - `p` Proceso cálculo
  - `t` Proceso transaccional (OLTP)
  - `b` Proceso batch
  - `d` Depuración
- NO usar opciones — SP por especialidad
- Ej: `pa_con_iprovincia`, `pa_con_aprovincia`, `pa_con_ccliente_gen`

### 2.9 Parámetros
- Máx. 25 caracteres
- `@e_` = entrada, `@s_` = salida
- Ej: `@e_cuenta`, `@s_mensaje`

### 2.10 Variables
- Máx. 25 caracteres
- `@v_` = variable de trabajo
- Ej: `@v_oficina`

### 2.11 Funciones
- Prefijo `fu_` + nemónico + `_` + descripción
- Máx. 30 caracteres
- NO invocar en sentencias DML
- Ej: `fu_con_ultimoDiaMes`

### 2.12 Vistas
- Prefijo `vs_` + nemónico + `_` + descripción
- Máx. 30 caracteres
- Ej: `vs_con_abono`

### 2.13 Programas SQR
- Máx. 8 caracteres
- Parámetro `-XC` para SPs, `-XP` para evitar SPs dinámicos
- Ej: `intdevch.sqr`

### 2.14 Nombres Físicos
- COBIS: máx. 8 caracteres, extensión `.sp`
- NO COBIS: nombre lógico, extensión `.sp`
- Ej: `pa_int_iempleado.sp`

### 2.15 Scripts
- Máx. 8 caracteres, extensión `.sql`
- Formato: nemónico + iniciales autor + secuencial
- Ej: `conwr001.sql`

### 2.16 Referencia de Cambios
- `--<REF #` inicio bloque, `--REF #>` fin
- Comentario inline: `/*<REF #, comentario REF #>*/`
- Comentario bloque: `/*<REF # ... REF #>*/`

---

## 3. Oracle

### 3.1 Normas Generales
- Minúsculas en declaración (Oracle almacena mayúsculas)
- Máx. 30 caracteres
- Usar `_`, sin espacios ni caracteres especiales
- Sin comillas en nombres

### 3.2 Código PL/SQL
- Máx. 30 caracteres objetos almacenados
- NO objetos inválidos en producción
- Manejo de errores con EXCEPTION
- Usar `DBMS_UTILITY.format_error_backtrace`

### 3.3 Bases de Datos
- Máx. 8 caracteres, singular
- Históricas sufijo `his`
- Juego caracteres: AL32UTF8
- 30% RAM para SO, 70% para SGA+PGA

### 3.4 Roles
- Prefijo `ROL_` + descripción
- Ej: `ROL_arquitectura`

### 3.5 Tablespaces
- Prefijo `TS_` + nombre + `_` + tipo
- Tipos: DAT (datos), IND (índices), LOB (segmentos)
- EXTENT MANAGEMENT LOCAL, SEGMENT SPACE MANAGEMENT AUTO
- Ej: `TS_REPORT_CENTER_DAT`

### 3.6 Esquemas
- Prefijo `DB_` + descripción
- Históricos sufijo `_his`
- Ej: `DB_ENUMERADOS_CORE`

### 3.7 Tablas
- Máx. 25 caracteres, singular
- Formato: nemónico + `_` + tipo + `_` + descripción
- Mismos tipos que Sybase/SQL Server
- Siempre especificar tablespace datos e índices
- LOB usar SecureFile
- NO particionamiento ni compresión (licenciamiento)
- Ej: `CON_M_CUENTA`

### 3.8 Tablas Temporales
- Formato: nemónico + `_tmp_` + descripción
- Usar CREATE GLOBAL TEMPORARY TABLE
- >10GB: tablespace temporal específico
- Ej: `con_tmp_producto`

### 3.9 Campos
- Máx. 25 caracteres, máx. 1000 columnas
- NO LONG, LONG RAW, RAW — usar LOB
- Prefijo (2 letras tabla) + `_` + descripción

### 3.10 Constraints
- Mismos prefijos que Sybase: `pk_`, `fk_`, `uq_`, `ck_`
- Todos habilitados y validados
- FK deben tener índice
- Especificar USING INDEX TABLESPACE

### 3.11 Secuencias
- Prefijo `sq_` + abreviatura tabla + `_` + campo
- Cache: 20 default, 100 para millones, 1000 para cientos millones
- NO usar ORDER (RAC)

### 3.12 Índices
- Prefijo `i_` + nombre_tabla + `_` + secuencia
- Máx. 4 índices OLTP (incluye PK)
- Máx. 16 campos por índice compuesto
- Especificar tablespace de índices
- NOPARALLEL

### 3.13 Triggers
- Prefijo `tr_` + abreviatura tabla + `_` + descripción
- Ej: `tr_mcliente_inserta_alta`

### 3.14 Paquetes
- Prefijo `pc_` + nemónico + `_` + descripción

### 3.15 Procedimientos
- Prefijo `pa_` + nemónico + `_` + descripción
- Ej: `pa_con_consultacheques`

### 3.16 Funciones
- Prefijo `fu_` + nemónico + `_` + descripción
- NO invocar en sentencias SQL

### 3.17 Parámetros
- `e_` entrada, `s_` salida
- Ej: `e_cuenta`, `s_mensaje`

### 3.18 Variables
- Prefijo `v_` = variable de trabajo
- Ej: `v_oficina`

### 3.19 Vistas
- Prefijo `vs_` + nemónico + `_` + descripción
- Revisar plan de ejecución

### 3.20 Sentencias SQL
- Revisar plan de ejecución
- Evitar TABLE ACCESS FULL, MERGE JOIN CARTESIAN, INDEX FAST FULL SCAN
- Usar variables en vez de constantes
- NO funciones en columnas indexadas
- NO SELECT *, NO DISTINCT
- UNION ALL preferido a UNION
- Evitar SELECT FOR UPDATE
- UPDATE solo columnas cambiadas

---

## 4. Nemónicos de Aplicación

| Nemónico | Aplicación |
|----------|-----------|
| AHO | Cuenta de Ahorros |
| BAT | Batch |
| BIB | Banca Internet Bolivariano |
| BMO | 24Movil |
| BPM | Business Process Management |
| CON | Contabilidad |
| COB | Cobranzas |
| CRE | Crédito |
| CTE | Cuenta Corriente |
| DWH | Datawarehouse |
| INT | Internet |
| IVA | Anexos IVA |
| MIS | Master Information Subsystem |
| PAG | Pagos |
| RECA | Recaudaciones |
| TES | Tesorería |
| ... (ver documento completo) |

---

## 5. Cabecera Obligatoria (ANEXO 1)

Etiquetas requeridas en cabecera de SPs:
- `Archivo:` nombre físico del programa
- `Motor de Base:` SYBASE / SQLSERVER / ORACLE
- `Base de datos:` nombre BD
- `Servidor:` nombre servidor
- `Aplicación:` nombre aplicación
- `Store procedure:` nombre SP
- `Procesamiento:` OLTP / BATCH / BATCH ESPECIAL
- `Ult.ControlTarea:` código tarea
- `Ult.Referencia:` REF # control cambios
- `PROPOSITO:` descripción de uso

---

## 6. Restricciones de Diseño

Cualquier sugerencia o duda: dirigirse a Subgerencia de Arquitectura y Soporte de TI.
