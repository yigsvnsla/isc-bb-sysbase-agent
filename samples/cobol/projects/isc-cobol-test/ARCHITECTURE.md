# Core Bancario COBOL — Arquitectura Completa

```
Sistema Bancario Legacy (Micro Focus COBOL)
Desarrollado 1995-2010 por equipos multiples
Inconsistencias estilisticas intencionales
```

---

## 1. Directorios

```
isc-cobol-test/
├── AGENTS.md
├── ARCHITECTURE.md
│
├── copybooks/             # COPYBOOKS compartidos
│   ├── cpy-common.cpy     # Constantes, codigos retorno, fechas
│   ├── cpy-screen.cpy     # Layouts de pantalla reusables
│   ├── cpy-error.cpy      # Rutinas de error estandar
│   ├── fd-customer.cpy    # FD + layout CUSTOMER
│   ├── fd-account.cpy     # FD + layout ACCOUNT
│   ├── fd-tranlog.cpy     # FD + layout TRANLOG
│   ├── fd-userprof.cpy    # FD + layout USERPROF
│   ├── fd-loanmast.cpy    # FD + layout LOANMAST
│   ├── fd-loanappl.cpy    # FD + layout LOANAPPL
│   ├── fd-depmast.cpy     # FD + layout DEPMAST
│   ├── fd-timedep.cpy     # FD + layout TIMEDEP
│   ├── fd-glmaster.cpy    # FD + layout GLMASTER
│   ├── fd-auditlog.cpy    # FD + layout AUDITLOG
│   ├── fd-batchctl.cpy    # FD + layout BATCHCTL
│   ├── fd-ratefile.cpy    # FD + layout RATEFILE
│   ├── fd-paramstr.cpy    # FD + layout PARAMSTR
│   ├── fd-feeschd.cpy     # FD + layout FEESCHED
│   ├── fd-chqbook.cpy     # FD + layout CHQBOOK
│   ├── fd-accountxr.cpy   # FD + layout ACCTXREF
│   └── fd-tellerec.cpy    # FD + layout TELLEREC
│
├── security/              # Seguridad y acceso
│   ├── SECMNU00.cbl       # Menu seguridad
│   ├── SECSGN00.cbl       # Sign-on / Login
│   ├── SECSGO00.cbl       # Sign-off
│   ├── SECUSR00.cbl       # Mantenimiento usuarios
│   ├── SECPWD00.cbl       # Cambio password
│   └── SECAUD00.cbl       # Auditoria sesiones
│
├── custmod/               # Modulo clientes
│   ├── CUSMNU00.cbl       # Menu clientes
│   ├── CUSINQ00.cbl       # Consulta cliente
│   ├── CUSMNT00.cbl       # Alta cliente
│   ├── CUSUPD00.cbl       # Modificacion cliente
│   ├── CUSSRH00.cbl       # Busqueda cliente
│   ├── CUSADR00.cbl       # Mantenimiento direcciones
│   ├── CUSREL00.cbl       # Relaciones cliente
│   └── CUSSTS00.cbl       # Estado / estatus cliente
│
├── acctmod/               # Modulo cuentas
│   ├── ACTMNU00.cbl       # Menu cuentas
│   ├── ACTINQ00.cbl       # Consulta cuenta
│   ├── ACTOPN00.cbl       # Apertura cuenta
│   ├── ACTCLS00.cbl       # Cierre cuenta
│   ├── ACTUPD00.cbl       # Modificacion cuenta
│   ├── ACTFRZ00.cbl       # Congelar / descongelar
│   ├── ACTBAL00.cbl       # Consulta saldo
│   └── ACTSTM00.cbl       # Estado cuenta (impresion)
│
├── teller/                # Modulo ventanilla / caja
│   ├── TLRMNU00.cbl       # Menu teller
│   ├── TLRSGN00.cbl       # Apertura caja / sign-on teller
│   ├── TLRDEP00.cbl       # Deposito
│   ├── TLRWTH00.cbl       # Retiro
│   ├── TLRTRF00.cbl       # Transferencia
│   ├── TLRPYM00.cbl       # Pago servicios
│   ├── TLRCHE00.cbl       # Cobro cheque
│   └── TLRSMG00.cbl       # Resumen / cuadre caja
│
├── loans/                 # Prestamos
│   ├── LONMNU00.cbl       # Menu prestamos
│   ├── LONINQ00.cbl       # Consulta prestamo
│   ├── LONAPL00.cbl       # Solicitud prestamo
│   ├── LONAPV00.cbl       # Aprobacion prestamo
│   ├── LONDIS00.cbl       # Desembolso
│   ├── LONPYM00.cbl       # Pago prestamo
│   ├── LONAMR00.cbl       # Tabla amortizacion
│   └── LONDEL00.cbl       # Gestion mora / castigo
│
├── deposits/              # Depositos / ahorros
│   ├── DEPMNU00.cbl       # Menu depositos
│   ├── DEPINQ00.cbl       # Consulta deposito
│   ├── DEPOPN00.cbl       # Apertura deposito
│   ├── DEPINT00.cbl       # Configuracion tasa
│   ├── DEPWTH00.cbl       # Reglas retiro
│   ├── DEPSTM00.cbl       # Estado deposito
│   └── DEPREN00.cbl       # Renovacion automatica
│
├── timedep/               # Depositos a plazo (CDs)
│   ├── TDMNU000.cbl       # Menu plazo
│   ├── TDOPN000.cbl       # Apertura CD
│   ├── TDINQ000.cbl       # Consulta CD
│   ├── TDCLS000.cbl       # Cierre / vencimiento
│   └── TDINT000.cbl       # Calculo interes
│
├── transfer/              # Transferencias
│   ├── FTMNU000.cbl       # Menu transferencias
│   ├── FTWIR000.cbl       # Transferencia wire
│   ├── FTACH000.cbl       # Transferencia ACH
│   ├── FTINT000.cbl       # Transferencia interna
│   └── FTSTS000.cbl       # Estado transferencia
│
├── batch/                 # Procesos batch nocturnos
│   ├── BCHMNU00.cbl       # Menu batch
│   ├── BCHDAY00.cbl       # Cierre diario
│   ├── BCHMTH00.cbl       # Cierre mensual
│   ├── BCHINT00.cbl       # Devengo intereses
│   ├── BCHGLI00.cbl       # Interface contable (GL)
│   ├── BCHODO00.cbl       # Calculo sobregiro / mora
│   └── BCHFEE00.cbl       # Comisiones periodicas
│
├── reports/               # Reportes / informes
│   ├── RPTMNU00.cbl       # Menu reportes
│   ├── RPTBAL00.cbl       # Balance general
│   ├── RPTTXN00.cbl       # Transacciones diarias
│   ├── RPTDEL00.cbl       # Cartera morosa
│   ├── RPTTLR00.cbl       # Cuadre cajeros
│   ├── RPTGLB00.cbl       # Mayor / trial balance
│   └── RPTREG00.cbl       # Reportes regulatorios
│
├── audit/                 # Auditoria
│   ├── AUDTRL00.cbl       # Captura pista auditoria
│   └── AUDINQ00.cbl       # Consulta pista auditoria
│
├── common/                # Programas utilitarios comunes
│   ├── COMMENU.cbl        # Menu principal
│   ├── COMDATE.cbl        # Rutinas fecha
│   ├── COMVFYL.cbl        # Validacion archivos
│   └── COMHELP.cbl        # Pantalla ayuda generica
│
├── data/                  # Definiciones archivos indexados
│   ├── files.def          # Mapas de archivos alfanumericos
│   └── sample-data.txt    # Datos muestra (opcional)
│
└── sql/                   # SQL embebido simulado
    ├── sql-exec.cbl       # Stub EXEC SQL
    └── sql-cursor.cbl     # Stub cursor
```

---

## 2. Inventario de Programas (67 total)

Cada programa listado con su ID, nombre, tipo y breve descripcion:

| #  | ID        | Programa            | Submodulo       | Descripcion                                    |
|----|-----------|---------------------|-----------------|------------------------------------------------|
| 1  | COMMENU   | Menu Principal      | Common          | Menu principal del sistema (PF1-PF12)          |
| 2  | COMDATE   | Fechas              | Common          | Rutinas validacion y conversion fechas         |
| 3  | COMVFYL   | Validar Archivos    | Common          | Verifica apertura archivos indexados           |
| 4  | COMHELP   | Ayuda               | Common          | Pantalla ayuda generica por codigo             |
| 5  | SECSGN00  | Sign-On             | Security        | Autenticacion usuario/password                 |
| 6  | SECSGO00  | Sign-Off            | Security        | Cierre sesion                                  |
| 7  | SECMNU00  | Menu Seguridad      | Security        | Menu admin usuarios                            |
| 8  | SECUSR00  | User Maint          | Security        | Alta/baja/modif usuarios                       |
| 9  | SECPWD00  | Password Change     | Security        | Cambio password obligatorio/voluntario         |
| 10 | SECAUD00  | Security Audit      | Security        | Consulta intentos acceso y sesiones            |
| 11 | CUSMNU00  | Menu Clientes       | Custmod         | Menu operaciones cliente                       |
| 12 | CUSINQ00  | Cliente Inquiry     | Custmod         | Consulta detalle cliente                       |
| 13 | CUSMNT00  | Cliente Add         | Custmod         | Alta nuevo cliente                             |
| 14 | CUSUPD00  | Cliente Update      | Custmod         | Modificacion datos fijos cliente               |
| 15 | CUSSRH00  | Cliente Search      | Custmod         | Busqueda por nombre/RFC/tel                   |
| 16 | CUSADR00  | Address Maint       | Custmod         | Mantenimiento direcciones multiples            |
| 17 | CUSREL00  | Customer Rel        | Custmod         | Relaciones beneficiarios/firmas               |
| 18 | CUSSTS00  | Customer Status     | Custmod         | Cambio estatus cliente (activo/inactivo)       |
| 19 | ACTMNU00  | Menu Cuentas        | Acctmod         | Menu operaciones cuentas                       |
| 20 | ACTINQ00  | Account Inquiry     | Acctmod         | Consulta datos generales cuenta                |
| 21 | ACTOPN00  | Account Open        | Acctmod         | Apertura nueva cuenta                          |
| 22 | ACTCLS00  | Account Close       | Acctmod         | Cierre cuenta con saldo cero                   |
| 23 | ACTUPD00  | Account Update      | Acctmod         | Modif datos cuenta (tasa, sobregiro, etc.)     |
| 24 | ACTFRZ00  | Freeze Account      | Acctmod         | Congelar/descongelar por fraude o orden        |
| 25 | ACTBAL00  | Balance Inquiry     | Acctmod         | Saldo actual, disponible, retenido             |
| 26 | ACTSTM00  | Account Statement   | Acctmod         | Genera spool estado cuenta                     |
| 27 | TLRMNU00  | Menu Teller         | Teller          | Menu transacciones ventanilla                  |
| 28 | TLRSGN00  | Teller Sign-On      | Teller          | Apertura caja con fondo                        |
| 29 | TLRDEP00  | Deposit             | Teller          | Deposito efectivo/cheque                       |
| 30 | TLRWTH00  | Withdrawal          | Teller          | Retiro efectivo                                |
| 31 | TLRTRF00  | Transfer            | Teller          | Transferencia entre cuentas                    |
| 32 | TLRPYM00  | Payment             | Teller          | Pago servicios (luz, agua, etc.)               |
| 33 | TLRCHE00  | Cheque Encashment   | Teller          | Cobro cheque propio/de terceros                |
| 34 | TLRSMG00  | Teller Summary      | Teller          | Cuadre diario / cierre caja                    |
| 35 | LONMNU00  | Menu Prestamos      | Loans           | Menu operaciones prestamo                      |
| 36 | LONINQ00  | Loan Inquiry        | Loans           | Consulta estado prestamo                        |
| 37 | LONAPL00  | Loan Application    | Loans           | Solicitud con scoring                          |
| 38 | LONAPV00  | Loan Approval       | Loans           | Aprobacion en niveles                          |
| 39 | LONDIS00  | Loan Disbursement   | Loans           | Desembolso a cuenta                            |
| 40 | LONPYM00  | Loan Payment        | Loans           | Pago cuota (extraordinario/total)              |
| 41 | LONAMR00  | Amortization        | Loans           | Tabla frances/aleman                           |
| 42 | LONDEL00  | Delinquency         | Loans           | Gestion mora, castigo, refinanciamiento        |
| 43 | DEPMNU00  | Menu Depositos      | Deposits        | Menu operaciones deposito                      |
| 44 | DEPINQ00  | Deposit Inquiry     | Deposits        | Consulta deposito a plazo                      |
| 45 | DEPOPN00  | Deposit Open        | Deposits        | Apertura deposito ahorro/plazo                |
| 46 | DEPINT00  | Interest Setup      | Deposits        | Configuracion tasas x producto                 |
| 47 | DEPWTH00  | Withdrawal Rules    | Deposits        | Penalizacion retiro anticipado                 |
| 48 | DEPSTM00  | Deposit Statement   | Deposits        | Estado movimiento deposito                     |
| 49 | DEPREN00  | Auto Renewal        | Deposits        | Renovacion automatica al vencimiento           |
| 50 | TDMNU000  | Menu TimeDep        | Timedep         | Menu depositos a plazo fijo                    |
| 51 | TDOPN000  | TD Open             | Timedep         | Apertura certificado deposito                  |
| 52 | TDINQ000  | TD Inquiry          | Timedep         | Consulta CD                                    |
| 53 | TDCLS000  | TD Close            | Timedep         | Liquidacion anticipada/vencimiento             |
| 54 | TDINT000  | TD Interest         | Timedep         | Calculo interes CD                             |
| 55 | FTMNU000  | Menu Transfers      | Transfer        | Menu transferencias                            |
| 56 | FTWIR000  | Wire Transfer       | Transfer        | Transferencia SWIFT                            |
| 57 | FTACH000  | ACH Transfer        | Transfer        | Transferencia ACH / camara compen              |
| 58 | FTINT000  | Internal Transfer   | Transfer        | Transferencia propia entre cuentas             |
| 59 | FTSTS000  | Transfer Status     | Transfer        | Consulta estado transferencia                  |
| 60 | BCHMNU00  | Menu Batch          | Batch           | Menu procesos batch                            |
| 61 | BCHDAY00  | Day End             | Batch           | Cierre diario: intereses, fees, spool         |
| 62 | BCHMTH00  | Month End           | Batch           | Cierre mensual: GL, reportes regulatorios      |
| 63 | BCHINT00  | Interest Accrual    | Batch           | Devengo diario intereses pasivos/activos       |
| 64 | BCHGLI00  | GL Interface        | Batch           | Pase asientos a contabilidad                   |
| 65 | BCHODO00  | Overdraft Calc      | Batch           | Calculo comisiones sobregiro/mora              |
| 66 | BCHFEE00  | Fee Assessment      | Batch           | Comisiones mantenimiento/periodicas            |
| 67 | RPTMNU00  | Menu Reports        | Reports         | Menu seleccion reportes                        |
| 68 | RPTBAL00  | Balance Report      | Reports         | Balance general con saldos                     |
| 69 | RPTTXN00  | Transaction Report  | Reports         | Transacciones por rango fechas                 |
| 70 | RPTDEL00  | Delinquency Report  | Reports         | Cartera vencida por antiguedad                 |
| 71 | RPTTLR00  | Teller Report       | Reports         | Cuadre diario por cajero                       |
| 72 | RPTGLB00  | GL Trial Balance    | Reports         | Mayor general / trial balance                  |
| 73 | RPTREG00  | Reg Report          | Reports         | Reportes regulatorios (CNBV, SAT, etc.)        |
| 74 | AUDTRL00  | Audit Trail         | Audit           | Escritura log auditoria                        |
| 75 | AUDINQ00  | Audit Query         | Audit           | Consulta pista auditoria                       |

**Total: 75 programas COBOL**

---

## 3. Archivos Indexados (17 archivos)

| Archivo      | Organizacion | Clave          | Descripcion                           |
|-------------|-------------|----------------|---------------------------------------|
| CUSTOMER    | INDEXED     | CUS-ID         | Datos cliente (persona fisica/moral)  |
| ACCOUNT     | INDEXED     | ACT-NBR        | Cuentas de deposito                   |
| ACCTXREF    | INDEXED     | CUS-ID + ACT   | Cliente-cuenta relacion               |
| TRANLOG     | INDEXED     | TRN-SEQ        | Bitacora transacciones                |
| USERPROF    | INDEXED     | USR-ID         | Perfiles y passwords                  |
| LOANMAST    | INDEXED     | LON-NBR        | Prestamos vigentes                    |
| LOANAPPL    | INDEXED     | LON-APPL-ID    | Solicitudes prestamo                  |
| DEPMAST     | INDEXED     | DEP-NBR        | Depositos a plazo                     |
| TIMEDEP     | INDEXED     | TD-NBR         | Certificados deposito                 |
| GLMASTER    | INDEXED     | GL-ACCT        | Cuentas contables                     |
| AUDITLOG    | INDEXED     | AUD-SEQ        | Log pista auditoria                   |
| BATCHCTL    | INDEXED     | BCH-DATE       | Control procesos batch                |
| RATEFILE    | INDEXED     | RAT-CODE       | Tabla tasas interes                   |
| PARAMSTR    | SEQUENTIAL  | PAR-COD        | Parametros sistema                    |
| FEESCHED    | INDEXED     | FEE-COD        | Tabla comisiones                      |
| CHQBOOK     | INDEXED     | CHQ-NBR        | Chequeras emitidas                    |
| TELLEREC    | INDEXED     | TLR-ID+DATE    | Fondo/cierre por cajero               |

---

## 4. COPYBOOKS (19 copybooks)

### 4.1 Estructurales (FD + registro)

| Copybook       | Contenido                                    |
|----------------|----------------------------------------------|
| fd-customer    | FD CUSTOMER, 01 CUSTOMER-REC, 88 levels    |
| fd-account     | FD ACCOUNT, 01 ACCOUNT-REC, COMP-3 saldos  |
| fd-tranlog     | FD TRANLOG, 01 TRANLOG-REC, campos fecha   |
| fd-userprof    | FD USERPROF, 01 USERPROF-REC, password hash|
| fd-loanmast    | FD LOANMAST, 01 LOANMAST-REC, OCCURS cuotas|
| fd-loanappl    | FD LOANAPPL, 01 LOANAPPL-REC               |
| fd-depmast     | FD DEPMAST, 01 DEPMAST-REC                 |
| fd-timedep     | FD TIMEDEP, 01 TIMEDEP-REC, COMP-3 monto  |
| fd-glmaster    | FD GLMASTER, 01 GLMASTER-REC               |
| fd-auditlog    | FD AUDITLOG, 01 AUDITLOG-REC               |
| fd-batchctl    | FD BATCHCTL, 01 BATCHCTL-REC               |
| fd-ratefile    | FD RATEFILE, 01 RATEFILE-REC               |
| fd-paramstr    | FD PARAMSTR, 01 PARAMSTR-REC               |
| fd-feeschd     | FD FEESCHED, 01 FEESCHED-REC               |
| fd-chqbook     | FD CHQBOOK, 01 CHQBOOK-REC                 |
| fd-accountxr   | FD ACCTXREF, 01 ACCTXREF-REC               |
| fd-tellerec    | FD TELLEREC, 01 TELLEREC-REC               |

### 4.2 Funcionales

| Copybook     | Contenido                                       |
|--------------|-------------------------------------------------|
| cpy-common   | WS- prefijos, codigos retorno, 88 niveles       |
| cpy-screen   | SCREEN SECTION layouts reusables                |
| cpy-error    | Rutina CALL 'COMHELP', mensajes error           |

---

## 5. Mapa de CALL entre Programas

### 5.1 Menu Principal → Flujo Global

```
 COMMENU (menu principal)
    |
    ├──> CALL 'SECSGN00'   (si no autenticado)
    ├──> CALL 'CUSMNU00'   (PF1  - clientes)
    ├──> CALL 'ACTMNU00'   (PF2  - cuentas)
    ├──> CALL 'TLRMNU00'   (PF3  - teller/ventanilla)
    ├──> CALL 'LONMNU00'   (PF4  - prestamos)
    ├──> CALL 'DEPMNU00'   (PF5  - depositos)
    ├──> CALL 'TDMNU000'   (PF6  - plazo fijo)
    ├──> CALL 'FTMNU000'   (PF7  - transferencias)
    ├──> CALL 'BCHMNU00'   (PF8  - batch)
    ├──> CALL 'RPTMNU00'   (PF9  - reportes)
    ├──> CALL 'SECMNU00'   (PF10 - seguridad)
    ├──> CALL 'COMHELP'    (PF11 - ayuda)
    └──> CALL 'SECSGO00'   (PF12 - salir)

    COMMENU -> COMDATE     (fecha/hora status bar)
    COMMENU -> COMVFYL     (verifica archivos al inicio)
```

### 5.2 Security

```
 SECMNU00 (menu seguridad)
    ├──> CALL 'SECUSR00'   (PF1 - usuarios)
    ├──> CALL 'SECPWD00'   (PF2 - password)
    ├──> CALL 'SECAUD00'   (PF3 - auditoria)
    └──> RETROCEDE COMMENU

 SECSGN00
    ├──> CALL 'SECAUD00'   (registra intento)
    ├──> CALL 'COMDATE'    (validacion vigencia password)
    └──> RETORNA a COMMENU

 SECUSR00
    ├──> READ USERPROF
    ├──> WRITE USERPROF
    ├──> CALL 'AUDTRL00'   (audita cambio)
    └──> CALL 'COMHELP'    (help contextual)
```

### 5.3 Customer

```
 CUSMNU00 (menu clientes)
    ├──> CALL 'CUSSRH00'   (PF1 - buscar)
    ├──> CALL 'CUSINQ00'   (PF2 - consulta)
    ├──> CALL 'CUSMNT00'   (PF3 - alta)
    ├──> CALL 'CUSUPD00'   (PF4 - modificacion)
    ├──> CALL 'CUSADR00'   (PF5 - direcciones)
    ├──> CALL 'CUSREL00'   (PF6 - relaciones)
    ├──> CALL 'CUSSTS00'   (PF7 - estatus)
    └──> RETROCEDE COMMENU

 CUSMNT00
    ├──> READ CUSTOMER (dupe check)
    ├──> WRITE CUSTOMER
    ├──> WRITE ACCTXREF (si aplica)
    ├──> CALL 'AUDTRL00'
    └──> CALL 'COMDATE'

 CUSINQ00
    ├──> READ CUSTOMER
    ├──> READ ACCTXREF (lista cuentas)
    ├──> IF cuenta CALL 'ACTINQ00'
    └──> CALL 'COMHELP'
```

### 5.4 Account

```
 ACTMNU00 (menu cuentas)
    ├──> CALL 'ACTINQ00'   (PF1 - consulta)
    ├──> CALL 'ACTOPN00'   (PF2 - apertura)
    ├──> CALL 'ACTUPD00'   (PF3 - modificacion)
    ├──> CALL 'ACTCLS00'   (PF4 - cierre)
    ├──> CALL 'ACTFRZ00'   (PF5 - congelar)
    ├──> CALL 'ACTBAL00'   (PF6 - saldo)
    ├──> CALL 'ACTSTM00'   (PF7 - estado cta)
    └──> RETROCEDE COMMENU

 ACTOPN00
    ├──> CALL 'CUSSRH00'   (busca cliente titular)
    ├──> READ ACCOUNT (dupe alternate key)
    ├──> WRITE ACCOUNT
    ├──> WRITE ACCTXREF
    ├──> WRITE CHQBOOK (si chequera)
    ├──> CALL 'AUDTRL00'
    ├──> CALL 'COMDATE'
    └──> CALL 'BCHGLI00'? (solo en batch - NO directo)

 ACTBAL00
    ├──> READ ACCOUNT
    ├──> IF sobregiro CALL 'BCHODO00' (actualiza)
    └──> DISPLAY saldo disponible
```

### 5.5 Teller

```
 TLRMNU00 (menu teller)
    ├──> CALL 'TLRSGN00'   (PF1 - apertura caja)
    ├──> CALL 'TLRDEP00'   (PF2 - deposito)
    ├──> CALL 'TLRWTH00'   (PF3 - retiro)
    ├──> CALL 'TLRTRF00'   (PF4 - transferencia)
    ├──> CALL 'TLRPYM00'   (PF5 - pago servicios)
    ├──> CALL 'TLRCHE00'   (PF6 - cobro cheque)
    ├──> CALL 'TLRSMG00'   (PF7 - resumen)
    └──> RETROCEDE COMMENU

 TLRDEP00
    ├──> CALL 'ACTINQ00'   (valida cuenta destino)
    ├──> READ ACCOUNT
    ├──> REWRITE ACCOUNT (actualiza saldo)
    ├──> WRITE TRANLOG
    ├──> REWRITE TELLEREC (incrementa fondo)
    ├──> CALL 'AUDTRL00'
    ├──> CALL 'COMDATE'
    └──> CALL 'COMHELP'    (si error)

 TLRWTH00
    ├──> CALL 'ACTBAL00'   (verifica saldo suficiente)
    ├──> READ ACCOUNT
    ├──> REWRITE ACCOUNT
    ├──> WRITE TRANLOG
    ├──> REWRITE TELLEREC
    ├──> CALL 'AUDTRL00'
    └──> CALL 'BCHODO00'   (si aplica comision)

 TLRSMG00
    ├──> READ TELLEREC
    ├──> CALL 'COMDATE'
    ├──> CALL 'RPTTLR00'   (spool reporte cuadre)
    └──> DISPLAY resumen
```

### 5.6 Loans

```
 LONMNU00 (menu prestamos)
    ├──> CALL 'LONINQ00'   (PF1 - consulta)
    ├──> CALL 'LONAPL00'   (PF2 - solicitud)
    ├──> CALL 'LONAPV00'   (PF3 - aprobacion)
    ├──> CALL 'LONDIS00'   (PF4 - desembolso)
    ├──> CALL 'LONPYM00'   (PF5 - pago)
    ├──> CALL 'LONAMR00'   (PF6 - amortizacion)
    ├──> CALL 'LONDEL00'   (PF7 - mora)
    └──> RETROCEDE COMMENU

 LONAPL00
    ├──> CALL 'CUSSRH00'   (busca cliente)
    ├──> READ RATEFILE (tasa actual)
    ├──> WRITE LOANAPPL
    ├──> CALL 'AUDTRL00'
    └──> CALL 'COMDATE'

 LONAPV00
    ├──> READ LOANAPPL
    ├──> REWRITE LOANAPPL (estatus aprobado/rechazado)
    ├──> CALL 'AUDTRL00'
    └──> CALL 'COMHELP'

 LONDIS00
    ├──> READ LOANAPPL (aprobada)
    ├──> DELETE LOANAPPL
    ├──> WRITE LOANMAST
    ├──> CALL 'TLRTRF00' (abona a cuenta cliente)
    ├──> CALL 'AUDTRL00'
    └──> CALL 'COMDATE'

 LONPYM00
    ├──> READ LOANMAST
    ├──> CALL 'LONAMR00' (calcula cuota)
    ├──> CALL 'TLRDEP00' ?  O procesa pago directo
    ├──> REWRITE LOANMAST
    ├──> WRITE TRANLOG
    ├──> CALL 'AUDTRL00'
    └──> CALL 'COMDATE'
```

### 5.7 Deposits

```
 DEPMNU00 (menu depositos)
    ├──> CALL 'DEPINQ00'   (PF1 - consulta)
    ├──> CALL 'DEPOPN00'   (PF2 - apertura)
    ├──> CALL 'DEPINT00'   (PF3 - tasas)
    ├──> CALL 'DEPWTH00'   (PF4 - retiros)
    ├──> CALL 'DEPSTM00'   (PF5 - estado)
    ├──> CALL 'DEPREN00'   (PF6 - renovacion)
    └──> RETROCEDE COMMENU

 DEPOPN00
    ├──> CALL 'CUSSRH00'
    ├──> READ RATEFILE
    ├──> WRITE DEPMAST
    ├──> CALL 'AUDTRL00'
    └──> CALL 'COMDATE'
```

### 5.8 Time Deposits

```
 TDMNU000
    ├──> CALL 'TDOPN000'   (PF1)
    ├──> CALL 'TDINQ000'   (PF2)
    ├──> CALL 'TDCLS000'   (PF3)
    ├──> CALL 'TDINT000'   (PF4)
    └──> RETROCEDE COMMENU

 TDOPN000
    ├──> CALL 'CUSSRH00'
    ├──> READ RATEFILE
    ├──> WRITE TIMEDEP
    ├──> WRITE TRANLOG
    ├──> CALL 'AUDTRL00'
    └──> CALL 'COMDATE'
```

### 5.9 Transfers

```
 FTMNU000
    ├──> CALL 'FTINT000'   (PF1 - interna)
    ├──> CALL 'FTWIR000'   (PF2 - wire)
    ├──> CALL 'FTACH000'   (PF3 - ACH)
    ├──> CALL 'FTSTS000'   (PF4 - estados)
    └──> RETROCEDE COMMENU

 FTWIR000
    ├──> CALL 'ACTBAL00'   (fondos suficientes)
    ├──> CALL 'ACTUPD00'   (cargo cuenta)
    ├──> WRITE TRANLOG
    ├──> CALL 'AUDTRL00'
    └──> CALL 'COMHELP'
```

### 5.10 Batch

```
 BCHMNU00
    ├──> CALL 'BCHDAY00'   (PF1 - diario)
    ├──> CALL 'BCHMTH00'   (PF2 - mensual)
    ├──> CALL 'BCHINT00'   (PF3 - intereses)
    ├──> CALL 'BCHGLI00'   (PF4 - GL)
    ├──> CALL 'BCHODO00'   (PF5 - sobregiro)
    ├──> CALL 'BCHFEE00'   (PF6 - comisiones)
    └──> RETROCEDE COMMENU

 BCHDAY00
    ├──> CALL 'BCHINT00'   (devengo)
    ├──> CALL 'BCHODO00'   (mora/sobre)
    ├──> CALL 'BCHFEE00'   (comisiones)
    ├──> CALL 'BCHGLI00'   (pase contable)
    ├──> CALL 'RPTTXN00'   (spool diario)
    ├──> CALL 'RPTBAL00'   (spool balances)
    ├──> READ/WRITE BATCHCTL
    ├──> CALL 'AUDTRL00'
    └──> CALL 'COMDATE'

 BCHINT00
    ├──> START ACCOUNT key >=
    ├──> READ NEXT ACCOUNT
    ├──> COMPUTE interes (COMP-3)
    ├──> REWRITE ACCOUNT
    ├──> WRITE TRANLOG
    ├──> READ/WRITE GLMASTER
    └──> AT END CLOSE
```

### 5.11 Reports

```
 RPTMNU00
    ├──> CALL 'RPTBAL00'   (PF1)
    ├──> CALL 'RPTTXN00'   (PF2)
    ├──> CALL 'RPTDEL00'   (PF3)
    ├──> CALL 'RPTTLR00'   (PF4)
    ├──> CALL 'RPTGLB00'   (PF5)
    ├──> CALL 'RPTREG00'   (PF6)
    └──> RETROCEDE COMMENU

 RPTBAL00
    ├──> START ACCOUNT key >=
    ├──> READ NEXT ACCOUNT
    ├──> DISPLAY UPON PRINTER / spool file
    ├──> CALL 'COMDATE'
    └──> AT END CLOSE
```

### 5.12 Audit

```
 AUDTRL00 (llamado por TODOS los programas transaccionales)
    ├──> WRITE AUDITLOG
    └──> EXIT PROGRAM

 AUDINQ00
    ├──> START AUDITLOG key >= fecha
    ├──> READ NEXT AUDITLOG
    ├──> DISPLAY en pantalla
    ├──> CALL 'COMDATE'
    └──> AT END CLOSE
```

---

## 6. Mapa de Navegacion (Pantallas 80x24)

### 6.1 Arbol completo

```
SECSGN00 ──>[login ok]──> COMMENU
                              │
                              ├── PF1: CUSMNU00
                              │        ├── PF1: CUSSRH00
                              │        ├── PF2: CUSINQ00
                              │        ├── PF3: CUSMNT00
                              │        ├── PF4: CUSUPD00
                              │        ├── PF5: CUSADR00
                              │        ├── PF6: CUSREL00
                              │        ├── PF7: CUSSTS00
                              │        └── PF12: RETORNO
                              │
                              ├── PF2: ACTMNU00
                              │        ├── PF1: ACTINQ00
                              │        ├── PF2: ACTOPN00
                              │        ├── PF3: ACTUPD00
                              │        ├── PF4: ACTCLS00
                              │        ├── PF5: ACTFRZ00
                              │        ├── PF6: ACTBAL00
                              │        ├── PF7: ACTSTM00
                              │        └── PF12: RETORNO
                              │
                              ├── PF3: TLRMNU00
                              │        ├── PF1: TLRSGN00
                              │        ├── PF2: TLRDEP00
                              │        ├── PF3: TLRWTH00
                              │        ├── PF4: TLRTRF00
                              │        ├── PF5: TLRPYM00
                              │        ├── PF6: TLRCHE00
                              │        ├── PF7: TLRSMG00
                              │        └── PF12: RETORNO
                              │
                              ├── PF4: LONMNU00
                              │        ├── PF1: LONINQ00
                              │        ├── PF2: LONAPL00
                              │        ├── PF3: LONAPV00
                              │        ├── PF4: LONDIS00
                              │        ├── PF5: LONPYM00
                              │        ├── PF6: LONAMR00
                              │        ├── PF7: LONDEL00
                              │        └── PF12: RETORNO
                              │
                              ├── PF5: DEPMNU00
                              │        ├── PF1: DEPINQ00
                              │        ├── PF2: DEPOPN00
                              │        ├── PF3: DEPINT00
                              │        ├── PF4: DEPWTH00
                              │        ├── PF5: DEPSTM00
                              │        ├── PF6: DEPREN00
                              │        └── PF12: RETORNO
                              │
                              ├── PF6: TDMNU000
                              │        ├── PF1: TDOPN000
                              │        ├── PF2: TDINQ000
                              │        ├── PF3: TDCLS000
                              │        ├── PF4: TDINT000
                              │        └── PF12: RETORNO
                              │
                              ├── PF7: FTMNU000
                              │        ├── PF1: FTINT000
                              │        ├── PF2: FTWIR000
                              │        ├── PF3: FTACH000
                              │        ├── PF4: FTSTS000
                              │        └── PF12: RETORNO
                              │
                              ├── PF8: BCHMNU00
                              │        ├── PF1: BCHDAY00
                              │        ├── PF2: BCHMTH00
                              │        ├── PF3: BCHINT00
                              │        ├── PF4: BCHGLI00
                              │        ├── PF5: BCHODO00
                              │        ├── PF6: BCHFEE00
                              │        └── PF12: RETORNO
                              │
                              ├── PF9: RPTMNU00
                              │        ├── PF1: RPTBAL00
                              │        ├── PF2: RPTTXN00
                              │        ├── PF3: RPTDEL00
                              │        ├── PF4: RPTTLR00
                              │        ├── PF5: RPTGLB00
                              │        ├── PF6: RPTREG00
                              │        └── PF12: RETORNO
                              │
                              ├── PF10: SECMNU00
                              │         ├── PF1: SECUSR00
                              │         ├── PF2: SECPWD00
                              │         ├── PF3: SECAUD00
                              │         └── PF12: RETORNO
                              │
                              ├── PF11: COMHELP (contextual)
                              │
                              └── PF12: SECSGO00 (salir)
```

### 6.2 Convenciones pantalla

- Todas 80x24 terminal
- Linea 1:  cabecera (sistema, fecha, hora, usuario)
- Linea 2:  titulo programa / submodulo
- Lineas 3-22: area datos / mensajes
- Linea 23: linea separadora
- Linea 24: indicador PF-keys / mensajes error
- PF1-PF7:  acciones de modulo
- PF11:     ayuda contextual (CALL 'COMHELP')
- PF12:     retorno al menu anterior (o COMMENU)
- Colores:  monitor monocromatico verde/ambar legacy

### 6.3 Patron de pantalla tipico (menu nivel 2)

```
+----------------------------------------------------------------------+
|  BANCO NACIONAL 01/01/2006 14:30:25  USR: COBOL01                    |
+----------------------------------------------------------------------+
|                           MENU PRESTAMOS                              |
|                                                                       |
|   PF1 - Consulta Prestamo                                             |
|   PF2 - Solicitud Prestamo                                            |
|   PF3 - Aprobacion Prestamo                                           |
|   PF4 - Desembolso                                                    |
|   PF5 - Pago Prestamo                                                 |
|   PF6 - Tabla Amortizacion                                            |
|   PF7 - Gestion Mora                                                  |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|                                                                       |
|  Opcion: _                                                           |
+----------------------------------------------------------------------+
| PF1-Consulta  PF2-Solicitud  PF3-Aprob  PF4-Desemb  PF11-Ayu PF12-Ret|
+----------------------------------------------------------------------+
```

---

## 7. Dependencias y Orden Construccion

```
FASE 0: COPYBOOKS (base)
  cpy-common.cpy  → todos los programas
  fd-*.cpy        → programas que usan cada archivo

FASE 1: COMMON (utilitarios base)
  COMDATE.cbl     ← sin dependencias (solo COPYBOOKS)
  COMVFYL.cbl     ← sin dependencias
  COMHELP.cbl     ← sin dependencias
  COMMENU.cbl     ← CALL a todos los menus

FASE 2: AUDIT + SECURITY (base del sistema)
  AUDTRL00.cbl    ← sin dependencias
  AUDINQ00.cbl    ← sin dependencias
  SECSGN00.cbl    ← CALL 'AUDTRL00', 'COMDATE'
  SECSGO00.cbl    ← CALL 'AUDTRL00'
  SECUSR00.cbl    ← CALL 'AUDTRL00'
  SECPWD00.cbl    ← CALL 'AUDTRL00', 'COMDATE'
  SECAUD00.cbl    ← CALL 'COMDATE'
  SECMNU00.cbl    ← CALL a subprogramas security

FASE 3: CUSTOMER
  CUSSRH00.cbl    ← CALL 'AUDTRL00'
  CUSINQ00.cbl    ← CALL 'AUDTRL00', CALL 'ACTINQ00' (opcional)
  CUSMNT00.cbl    ← CALL 'AUDTRL00', 'COMDATE'
  CUSUPD00.cbl    ← CALL 'AUDTRL00', 'COMDATE'
  CUSADR00.cbl    ← CALL 'AUDTRL00'
  CUSREL00.cbl    ← CALL 'AUDTRL00'
  CUSSTS00.cbl    ← CALL 'AUDTRL00'
  CUSMNU00.cbl    ← CALL a todos los subprogramas customer

FASE 4: ACCOUNT
  ACTINQ00.cbl    ← CALL 'COMDATE'
  ACTBAL00.cbl    ← CALL 'AUDTRL00'
  ACTOPN00.cbl    ← CALL 'CUSSRH00', 'AUDTRL00', 'COMDATE'
  ACTUPD00.cbl    ← CALL 'AUDTRL00', 'COMDATE'
  ACTCLS00.cbl    ← CALL 'ACTBAL00', 'AUDTRL00'
  ACTFRZ00.cbl    ← CALL 'AUDTRL00'
  ACTSTM00.cbl    ← CALL 'COMDATE'
  ACTMNU00.cbl    ← CALL a subprogramas account

FASE 5: TELLER (depende de ACCOUNT)
  TLRSGN00.cbl    ← CALL 'AUDTRL00', 'COMDATE'
  TLRDEP00.cbl    ← CALL 'ACTINQ00', 'AUDTRL00', 'COMDATE'
  TLRWTH00.cbl    ← CALL 'ACTBAL00', 'AUDTRL00', 'BCHODO00'
  TLRTRF00.cbl    ← CALL 'ACTINQ00', 'AUDTRL00'
  TLRPYM00.cbl    ← CALL 'ACTBAL00', 'AUDTRL00'
  TLRCHE00.cbl    ← CALL 'ACTINQ00', 'AUDTRL00'
  TLRSMG00.cbl    ← CALL 'COMDATE', 'RPTTLR00'
  TLRMNU00.cbl    ← CALL a subprogramas teller

FASE 6: LOANS (depende de CUSTOMER, ACCOUNT)
  LONINQ00.cbl    ← CALL 'AUDTRL00'
  LONAMR00.cbl    ← CALL 'COMDATE'
  LONAPL00.cbl    ← CALL 'CUSSRH00', 'AUDTRL00', 'COMDATE'
  LONAPV00.cbl    ← CALL 'AUDTRL00'
  LONDIS00.cbl    ← CALL 'TLRTRF00', 'AUDTRL00', 'COMDATE'
  LONPYM00.cbl    ← CALL 'LONAMR00', 'AUDTRL00', 'COMDATE'
  LONDEL00.cbl    ← CALL 'AUDTRL00', 'COMDATE'
  LONMNU00.cbl    ← CALL a subprogramas loans

FASE 7: DEPOSITS (depende de CUSTOMER, ACCOUNT)
  DEPINQ00.cbl    ← CALL 'AUDTRL00'
  DEPOPN00.cbl    ← CALL 'CUSSRH00', 'AUDTRL00', 'COMDATE'
  DEPINT00.cbl    ← CALL 'AUDTRL00'
  DEPWTH00.cbl    ← CALL 'AUDTRL00'
  DEPSTM00.cbl    ← CALL 'COMDATE'
  DEPREN00.cbl    ← CALL 'AUDTRL00', 'COMDATE'
  DEPMNU00.cbl    ← CALL a subprogramas deposits

FASE 8: TIME DEPOSITS
  TDOPN000.cbl    ← CALL 'CUSSRH00', 'AUDTRL00', 'COMDATE'
  TDINQ000.cbl    ← CALL 'AUDTRL00'
  TDCLS000.cbl    ← CALL 'ACTBAL00', 'AUDTRL00'
  TDINT000.cbl    ← CALL 'COMDATE'
  TDMNU000.cbl    ← CALL a subprogramas timedep

FASE 9: TRANSFERS (depende de ACCOUNT)
  FTINT000.cbl    ← CALL 'ACTBAL00', 'AUDTRL00'
  FTWIR000.cbl    ← CALL 'ACTBAL00', 'ACTUPD00', 'AUDTRL00'
  FTACH000.cbl    ← CALL 'ACTBAL00', 'AUDTRL00'
  FTSTS000.cbl    ← CALL 'AUDTRL00'
  FTMNU000.cbl    ← CALL a subprogramas transfer

FASE 10: BATCH (depende de casi todo)
  BCHINT00.cbl    ← READ ACCOUNT, READ GLMASTER
  BCHODO00.cbl    ← READ ACCOUNT, READ RATEFILE
  BCHFEE00.cbl    ← READ ACCOUNT, READ FEESCHED
  BCHGLI00.cbl    ← READ ACCOUNT, READ/WRITE GLMASTER
  BCHDAY00.cbl    ← CALL 'BCHINT00', 'BCHODO00', 'BCHFEE00', 'BCHGLI00'
  BCHMTH00.cbl    ← CALL 'BCHINT00', CALL 'BCHGLI00'
  BCHMNU00.cbl    ← CALL a subprogramas batch

FASE 11: REPORTS (depende de ACCOUNT, LOAN, etc.)
  RPTBAL00.cbl    ← READ ACCOUNT, CALL 'COMDATE'
  RPTTXN00.cbl    ← READ TRANLOG, CALL 'COMDATE'
  RPTDEL00.cbl    ← READ LOANMAST, CALL 'COMDATE'
  RPTTLR00.cbl    ← READ TELLEREC, CALL 'COMDATE'
  RPTGLB00.cbl    ← READ GLMASTER, CALL 'COMDATE'
  RPTREG00.cbl    ← READ LOANMAST, ACCOUNT, CALL 'COMDATE'
  RPTMNU00.cbl    ← CALL a subprogramas reports
```

---

## 8. Convenciones Tecnicas

### 8.1 Prefijos variables

| Prefijo | Ambito                  |
|---------|-------------------------|
| WS-     | Working-Storage         |
| LS-     | Linkage Section         |
| CD-     | Condition (88)          |
| FD-     | File Description record |
| SC-     | Screen Section          |
| DB-     | Database (SQL simulado) |
| TX-     | Text / messages         |
| FL-     | File status             |
| SW-     | Switches                |
| CT-     | Counters                |
| SA-     | Saldos / COMP-3         |

### 8.2 Columnas COBOL

- Area A (8-11):   `PROGRAM-ID`, `DATA DIVISION`, `WORKING-STORAGE`, `PROCEDURE DIVISION`, `SECTION`, párrafos
- Area B (12-72):  sentencias, `MOVE`, `IF`, `CALL`, `READ`, `WRITE`, etc.
- Col 73-80:       opcional — numeracion secuencial o basura legacy

### 8.3 Patron I/O indexado

```
     SELECT ARCHIVO ASSIGN TO "ARCHIVO.DAT"
         ORGANIZATION IS INDEXED
         ACCESS MODE IS DYNAMIC
         RECORD KEY IS ARCHIVO-KEY
         FILE STATUS IS FL-STATUS.
```

### 8.4 Patron CALL

```
     CALL 'SUBPROG' USING WS-PARAM1
                            WS-PARAM2
                            WS-RETCODE.
```

---

## 9. Resumen Metricas

| Elemento               | Cantidad |
|------------------------|----------|
| Programas COBOL        | 75       |
| Submodulos             | 11       |
| Archivos indexados     | 17       |
| COPYBOOKS              | 19       |
| Relaciones CALL        | ~180     |
| Pantallas              | 75+      |
| Lineas codigo estimado | ~45,000  |
