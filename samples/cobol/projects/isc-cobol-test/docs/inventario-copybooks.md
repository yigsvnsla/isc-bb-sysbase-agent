# Inventario de COPYBOOKS — Sistema Bancario COBOL

## Resumen

| #  | Copybook       | FD Record        | Longitud | Campos | Clave Primaria       | 88s | COMP-3 | Programas Usuarios                  |
|----|----------------|------------------|----------|--------|----------------------|-----|--------|-------------------------------------|
| 1  | fd-customer    | CUSTOMER-RECORD  | 300      | 38     | CUS-ID               | 16  | 1      | CUSMNT00, CUSINQ00, CUSUPD00,      |
|    |                |                  |          |        |                      |     |        | CUSSRH00, CUSADR00, CUSSTS00,       |
|    |                |                  |          |        |                      |     |        | LONAPL00                            |
| 2  | fd-account     | ACCOUNT-RECORD   | 200      | 32     | ACT-NBR              | 12  | 14     | ACTINQ00, ACTOPN00, ACTUPD00,       |
|    |                |                  |          |        |                      |     |        | ACTCLS00, ACTFRZ00, ACTBAL00,       |
|    |                |                  |          |        |                      |     |        | ACTSTM00, TLRDEP00, TLRWTH00,       |
|    |                |                  |          |        |                      |     |        | TLRTRF00, TLRPYM00, TLRCHE00,       |
|    |                |                  |          |        |                      |     |        | BCHINT00, BCHGLI00, BCHODO00,       |
|    |                |                  |          |        |                      |     |        | BCHFEE00, RPTBAL00, RPTREG00,       |
|    |                |                  |          |        |                      |     |        | FTINT000, FTWIR000, FTACH000        |
| 3  | fd-tranlog     | TRANLOG-RECORD   | 150      | 25     | TRN-SEQ (AK: ACT)    | 18  | 7      | ACTSTM00, TLRDEP00, TLRWTH00,       |
|    |                |                  |          |        |                      |     |        | TLRTRF00, TLRPYM00, TLRCHE00,       |
|    |                |                  |          |        |                      |     |        | LONPYM00, TDOPN000, FTINT000,       |
|    |                |                  |          |        |                      |     |        | FTWIR000, FTACH000, FTSTS000,       |
|    |                |                  |          |        |                      |     |        | BCHINT00, BCHGLI00, BCHODO00,       |
|    |                |                  |          |        |                      |     |        | BCHFEE00, RPTTXN00                  |
| 4  | fd-card        | CARD-RECORD      | 250      | 34     | CRD-NBR              | 19  | 13     | (programas de tarjetas)             |
| 5  | fd-loanmast    | LOANMAST-RECORD  | 350      | 48     | LON-NBR              | 28  | 18     | LONINQ00, LONPYM00, LONDEL00,       |
|    |                |                  |          |        |                      |     |        | RPTDEL00, RPTREG00                  |
| 6  | fd-loanappl    | LOANAPPL-RECORD  | 280      | 27     | LAP-APPL-ID          | 16  | 10     | LONAPL00, LONAPV00, LONDIS00        |
| 7  | fd-branch      | BRANCH-RECORD    | 200      | 27     | BRH-CODE             | 3   | 2      | (programas administrativos)         |
| 8  | fd-userprof    | USERPROF-RECORD  | 180      | 26     | USR-ID               | 15  | 0      | BNK0001, SECUSR00, SECPWD00,        |
|    |                |                  |          |        |                      |     |        | COMSECF                             |
| 9  | fd-security    | SECURITY-RECORD  | 120      | 11     | SEC-SEQ              | 12  | 0      | SECAUD00, COMSECF                   |
| 10 | fd-paramstr    | PARAMSTR-RECORD  | 150      | 11     | PAR-CODIGO           | 12  | 1      | (varios programas)                  |
| 11 | fd-currency    | CURRENCY-RECORD  | 80       | 12     | CUR-CODIGO           | 8   | 3      | (programas de cambios)              |
| 12 | fd-messages    | MESSAGES-RECORD  | 300      | 17     | MSG-ID               | 18  | 0      | COMMSGF                             |
| 13 | fd-ratefile    | RATEFILE-RECORD  | 100      | 18     | RAT-CODIGO           | 8   | 7      | LONAPL00, DEPOPN00, DEPINT00,       |
|    |                |                  |          |        |                      |     |        | DEPREN00, TDOPN000, BCHINT00,       |
|    |                |                  |          |        |                      |     |        | BCHODO00                            |
| 14 | fd-depmast     | DEPMAST-RECORD   | 200      | 23     | DEP-NBR              | 9   | 7      | DEPINQ00, DEPOPN00, DEPWTH00,       |
|    |                |                  |          |        |                      |     |        | DEPSTM00, DEPREN00, RPTREG00        |
| 15 | fd-timedep     | TIMEDEP-RECORD   | 180      | 22     | TD-NBR               | 14  | 8      | TDOPN000, TDINQ000, TDCLS000,       |
|    |                |                  |          |        |                      |     |        | TDINT000                            |
| 16 | fd-glmaster    | GLMASTER-RECORD  | 160      | 18     | GL-ACCOUNT           | 12  | 7      | BCHINT00, BCHGLI00, RPTBAL00,       |
|    |                |                  |          |        |                      |     |        | RPTGLB00                            |
| 17 | fd-auditlog    | AUDITLOG-RECORD  | 200      | 14     | AUD-SEQ              | 21  | 0      | AUDTRL00, AUDINQ00                  |
| 18 | fd-batchctl    | BATCHCTL-RECORD  | 150      | 18     | BCH-FECHA-PROCESO    | 7   | 0      | BCHDAY00, BCHMTH00                  |
| 19 | fd-feeschd     | FEESCHED-RECORD  | 120      | 16     | FEE-CODIGO           | 13  | 4      | BCHFEE00                            |
| 20 | fd-chqbook     | CHQBOOK-RECORD   | 100      | 14     | CHQ-NBR              | 6   | 0      | ACTOPN00                            |
| 21 | fd-accountxr   | ACCTXREF-RECORD  | 80       | 10     | AXR-ID (compuesta)   | 9   | 1      | CUSINQ00, CUSREL00, ACTINQ00,       |
|    |                |                  |          |        |                      |     |        | ACTOPN00                            |
| 22 | fd-tellerec    | TELLEREC-RECORD  | 150      | 25     | TLR-ID + TLR-DATE    | 5   | 12     | TLRMNU00, TLRSGN00, TLRDEP00,       |
|    |                |                  |          |        |                      |     |        | TLRWTH00, TLRTRF00, TLRPYM00,       |
|    |                |                  |          |        |                      |     |        | TLRCHE00, TLRSMG00, RPTTLR00        |
| -- | cpy-common     | (Working-Storage) | N/A     | 110    | N/A                  | 40+ | 1      | TODOS los programas                  |
| -- | cpy-screen     | (Screen Section)  | N/A     | 66     | N/A                  | 12+ | 0      | Programas con SCREEN SECTION         |
| -- | cpy-error      | (Error Handling)  | N/A     | 60     | N/A                  | 12+ | 0      | Programas con I/O indexado           |
| -- | cpy-codtab     | (Code Tables)     | N/A     | 67     | N/A                  | 0   | 2      | Programas con validacion de codigos  |

---

## Detalle por Copybook

---

### fd-customer.cpy

**Propósito**: FD + layout del archivo maestro de clientes
**FD**: CUSTOMER-FILE
**01**: CUSTOMER-RECORD
**Longitud**: 300 caracteres
**Clave primaria**: CUS-ID (X(10))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 38    |
| Campos COMP-3     | 1     |
| Niveles 88        | 16    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: CUSMNT00, CUSINQ00, CUSUPD00, CUSSRH00, CUSADR00, CUSSTS00, LONAPL00

---

### fd-account.cpy

**Propósito**: FD + layout del archivo maestro de cuentas
**FD**: ACCOUNT-FILE
**01**: ACCOUNT-RECORD
**Longitud**: 200 caracteres
**Clave primaria**: ACT-NBR (X(10))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 32    |
| Campos COMP-3     | 14    |
| Niveles 88        | 12    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: ACTINQ00, ACTOPN00, ACTUPD00, ACTCLS00, ACTFRZ00, ACTBAL00, ACTSTM00, TLRDEP00, TLRWTH00, TLRTRF00, TLRPYM00, TLRCHE00, BCHINT00, BCHGLI00, BCHODO00, BCHFEE00, RPTBAL00, RPTREG00, FTINT000, FTWIR000, FTACH000

---

### fd-tranlog.cpy

**Propósito**: FD + layout de bitacora de transacciones
**FD**: TRANLOG-FILE
**01**: TRANLOG-RECORD
**Longitud**: 150 caracteres
**Clave primaria**: TRN-SEQ (9(10))
**Clave alternativa**: TRN-ACCOUNT-NBR

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 25    |
| Campos COMP-3     | 7     |
| Niveles 88        | 18    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: ACTSTM00, TLRDEP00, TLRWTH00, TLRTRF00, TLRPYM00, TLRCHE00, LONPYM00, TDOPN000, FTINT000, FTWIR000, FTACH000, FTSTS000, BCHINT00, BCHGLI00, BCHODO00, BCHFEE00, RPTTXN00

---

### fd-card.cpy

**Propósito**: FD + layout de tarjetas de debito/credito
**FD**: CARD-FILE
**01**: CARD-RECORD
**Longitud**: 250 caracteres
**Clave primaria**: CRD-NBR (X(16))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 34    |
| Campos COMP-3     | 13    |
| Niveles 88        | 19    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: (programas del modulo cards/ — por crear)

---

### fd-loanmast.cpy

**Propósito**: FD + layout de prestamos vigentes
**FD**: LOANMAST-FILE
**01**: LOANMAST-RECORD
**Longitud**: 350 caracteres
**Clave primaria**: LON-NBR (X(10))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 48    |
| Campos COMP-3     | 18    |
| Niveles 88        | 28    |
| OCCURS            | 1 (tabla cuotas 360) |
| REDEFINES         | 0     |

**Usado por**: LONINQ00, LONPYM00, LONDEL00, RPTDEL00, RPTREG00

---

### fd-loanappl.cpy

**Propósito**: FD + layout de solicitudes de prestamo
**FD**: LOANAPPL-FILE
**01**: LOANAPPL-RECORD
**Longitud**: 280 caracteres
**Clave primaria**: LAP-APPL-ID (X(10))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 27    |
| Campos COMP-3     | 10    |
| Niveles 88        | 16    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: LONAPL00, LONAPV00, LONDIS00

---

### fd-branch.cpy

**Propósito**: FD + layout de sucursales
**FD**: BRANCH-FILE
**01**: BRANCH-RECORD
**Longitud**: 200 caracteres
**Clave primaria**: BRH-CODE (X(04))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 27    |
| Campos COMP-3     | 2     |
| Niveles 88        | 3     |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: (programas administrativos)

---

### fd-userprof.cpy

**Propósito**: FD + layout de perfiles de usuario
**FD**: USERPROF-FILE
**01**: USERPROF-RECORD
**Longitud**: 180 caracteres
**Clave primaria**: USR-ID (X(08))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 26    |
| Campos COMP-3     | 0     |
| Niveles 88        | 15    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: BNK0001, SECUSR00, SECPWD00, COMSECF

---

### fd-security.cpy

**Propósito**: FD + layout de auditoria de seguridad
**FD**: SECURITY-FILE
**01**: SECURITY-RECORD
**Longitud**: 120 caracteres
**Clave primaria**: SEC-SEQ (9(10))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 11    |
| Campos COMP-3     | 0     |
| Niveles 88        | 12    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: SECAUD00, COMSECF

---

### fd-paramstr.cpy

**Propósito**: FD + layout de parametros del sistema
**FD**: PARAMSTR-FILE
**01**: PARAMSTR-RECORD
**Longitud**: 150 caracteres
**Clave primaria**: PAR-CODIGO (X(08))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 11    |
| Campos COMP-3     | 1     |
| Niveles 88        | 12    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: (varios programas)

---

### fd-currency.cpy

**Propósito**: FD + layout de monedas/tipos de cambio
**FD**: CURRENCY-FILE
**01**: CURRENCY-RECORD
**Longitud**: 80 caracteres
**Clave primaria**: CUR-CODIGO (X(03))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 12    |
| Campos COMP-3     | 3     |
| Niveles 88        | 8     |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: (programas de cambios)

---

### fd-messages.cpy

**Propósito**: FD + layout de mensajes/notificaciones
**FD**: MESSAGES-FILE
**01**: MESSAGES-RECORD
**Longitud**: 300 caracteres
**Clave primaria**: MSG-ID (9(08))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 17    |
| Campos COMP-3     | 0     |
| Niveles 88        | 18    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: COMMSGF

---

### fd-ratefile.cpy

**Propósito**: FD + layout de tabla de tasas de interes
**FD**: RATEFILE-FILE
**01**: RATEFILE-RECORD
**Longitud**: 100 caracteres
**Clave primaria**: RAT-CODIGO (X(06))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 18    |
| Campos COMP-3     | 7     |
| Niveles 88        | 8     |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: LONAPL00, DEPOPN00, DEPINT00, DEPREN00, TDOPN000, BCHINT00, BCHODO00

---

### fd-depmast.cpy

**Propósito**: FD + layout de maestro de depositos
**FD**: DEPMAST-FILE
**01**: DEPMAST-RECORD
**Longitud**: 200 caracteres
**Clave primaria**: DEP-NBR (X(10))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 23    |
| Campos COMP-3     | 7     |
| Niveles 88        | 9     |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: DEPINQ00, DEPOPN00, DEPWTH00, DEPSTM00, DEPREN00, RPTREG00

---

### fd-timedep.cpy

**Propósito**: FD + layout de certificados de deposito a plazo
**FD**: TIMEDEP-FILE
**01**: TIMEDEP-RECORD
**Longitud**: 180 caracteres
**Clave primaria**: TD-NBR (X(12))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 22    |
| Campos COMP-3     | 8     |
| Niveles 88        | 14    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: TDOPN000, TDINQ000, TDCLS000, TDINT000

---

### fd-glmaster.cpy

**Propósito**: FD + layout de cuentas contables (mayor)
**FD**: GLMASTER-FILE
**01**: GLMASTER-RECORD
**Longitud**: 160 caracteres
**Clave primaria**: GL-ACCOUNT (X(08))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 18    |
| Campos COMP-3     | 7     |
| Niveles 88        | 12    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: BCHINT00, BCHGLI00, RPTBAL00, RPTGLB00

---

### fd-auditlog.cpy

**Propósito**: FD + layout de pista de auditoria
**FD**: AUDITLOG-FILE
**01**: AUDITLOG-RECORD
**Longitud**: 200 caracteres
**Clave primaria**: AUD-SEQ (9(10))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 14    |
| Campos COMP-3     | 0     |
| Niveles 88        | 21    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: AUDTRL00, AUDINQ00

---

### fd-batchctl.cpy

**Propósito**: FD + layout de control de procesos batch
**FD**: BATCHCTL-FILE
**01**: BATCHCTL-RECORD
**Longitud**: 150 caracteres
**Clave primaria**: BCH-FECHA-PROCESO (9(08))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 18    |
| Campos COMP-3     | 0     |
| Niveles 88        | 7     |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: BCHDAY00, BCHMTH00

---

### fd-feeschd.cpy

**Propósito**: FD + layout de tabla de comisiones y tarifas
**FD**: FEESCHED-FILE
**01**: FEESCHED-RECORD
**Longitud**: 120 caracteres
**Clave primaria**: FEE-CODIGO (X(04))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 16    |
| Campos COMP-3     | 4     |
| Niveles 88        | 13    |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: BCHFEE00

---

### fd-chqbook.cpy

**Propósito**: FD + layout de chequeras emitidas
**FD**: CHQBOOK-FILE
**01**: CHQBOOK-RECORD
**Longitud**: 100 caracteres
**Clave primaria**: CHQ-NBR (X(10))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 14    |
| Campos COMP-3     | 0     |
| Niveles 88        | 6     |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: ACTOPN00

---

### fd-accountxr.cpy

**Propósito**: FD + layout de cruce cliente-cuenta
**FD**: ACCTXREF-FILE
**01**: ACCTXREF-RECORD
**Longitud**: 80 caracteres
**Clave primaria**: AXR-ID (X(20)) compuesta CUS-ID + ACT-NBR

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 10    |
| Campos COMP-3     | 1     |
| Niveles 88        | 9     |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: CUSINQ00, CUSREL00, ACTINQ00, ACTOPN00

---

### fd-tellerec.cpy

**Propósito**: FD + layout de registro de caja/fondo de cajero
**FD**: TELLEREC-FILE
**01**: TELLEREC-RECORD
**Longitud**: 150 caracteres
**Clave primaria**: TLR-ID (X(08)) + TLR-DATE (9(08))

| Metrica           | Valor |
|-------------------|-------|
| Campos totales    | 25    |
| Campos COMP-3     | 12    |
| Niveles 88        | 5     |
| OCCURS            | 0     |
| REDEFINES         | 0     |

**Usado por**: TLRMNU00, TLRSGN00, TLRDEP00, TLRWTH00, TLRTRF00, TLRPYM00, TLRCHE00, TLRSMG00, RPTTLR00

---

## Copybooks Funcionales

### cpy-common.cpy

**Propósito**: Constantes globales, codigos retorno, switches
**Tipo**: Working-Storage (no FD)
**Uso**: TODOS los programas del sistema

| Metrica           | Valor |
|-------------------|-------|
| Lineas totales    | 110   |
| Campos            | 25+   |
| Niveles 88        | 40+   |
| COMP-3            | 1     |
| OCCURS            | 0     |

### cpy-screen.cpy

**Propósito**: Layouts de pantalla reusables
**Tipo**: Screen Section / Working-Storage
**Uso**: Programas con SCREEN SECTION

| Metrica           | Valor |
|-------------------|-------|
| Lineas totales    | 66    |
| Campos            | 12+   |
| Niveles 88        | 12+   |
| OCCURS            | 1 (tabla busqueda 20) |

### cpy-error.cpy

**Propósito**: Manejo centralizado de errores de archivo
**Tipo**: Working-Storage
**Uso**: Programas con I/O indexado

| Metrica           | Valor |
|-------------------|-------|
| Lineas totales    | 60    |
| Campos            | 10+   |
| Niveles 88        | 12+   |
| OCCURS            | 1 (tabla errores 15) |

### cpy-codtab.cpy

**Propósito**: Tablas de codificacion compartidas
**Tipo**: Working-Storage
**Uso**: Programas con validacion de codigos

| Metrica           | Valor |
|-------------------|-------|
| Lineas totales    | 67    |
| Campos            | 15+   |
| Niveles 88        | 7     |
| COMP-3            | 2     |
| OCCURS            | 4 (productos 50, estados 32, actividades 99, motivos 20, tc 10) |
