# Mapa de Navegacion — Sistema Bancario COBOL

## Leyenda de PF-keys

| PF-key   | Accion General           | Descripcion                              |
|----------|--------------------------|------------------------------------------|
| PF1      | Accion 1 / Ayuda         | Primera opcion de modulo o ayuda         |
| PF2      | Accion 2                 | Segunda opcion de modulo                 |
| PF3      | Accion 3                 | Tercera opcion de modulo                 |
| PF4      | Accion 4                 | Cuarta opcion de modulo                  |
| PF5      | Accion 5                 | Quinta opcion de modulo                  |
| PF6      | Accion 6                 | Sexta opcion de modulo                   |
| PF7      | Accion 7 / Pagina Ant    | Septima opcion o pagina anterior         |
| PF8      | Pagina Siguiente         | Avanza pagina en BNK0010                 |
| PF9      | Accion 9                 | Novena opcion de modulo                  |
| PF10     | Accion 10                | Decima opcion de modulo                  |
| PF11     | Ayuda Contextual         | CALL 'COMHELP' con codigo de ayuda       |
| PF12     | Salir / Retorno          | Retorna al menu anterior o cierra sesion |

**Regla general**: PF12 siempre retorna al CALLER. PF11 siempre muestra ayuda contextual.
Enter confirma captura. Clear (PF00) limpia campos y mensajes de error.

---

## Arbol Completo de Navegacion

```
INICIO
  │
  ▼
BNK0001 (LOGIN - Pantalla de Autenticacion)
  │  PF1=Ayuda  PF12=Salir  Enter=Validar
  │  [login exitoso] ──────────────────────────────┐
  │  [password expirado] ───► BNK0001 (cambio pwd) │
  └─────────────────────────────────────────────────┘
                                                    │
                                                    ▼
                              ┌──────────────────────────────────────┐
                              │        BNK0010 / COMMENU             │
                              │    MENU PRINCIPAL DE OPERACIONES     │
                              │  (PF1-PF12, 60 opciones en 3 pag)   │
                              └──────────────────────────────────────┘
                                        │
           ┌──────────┬──────────┬──────┼──────┬──────────┬──────────┐
           │          │          │      │      │          │          │
           ▼          ▼          ▼      ▼      ▼          ▼          ▼
       CUSMNU00  ACTMNU00  TLRMNU00  LONMNU00 DEPMNU00  TDMNU000  FTMNU000
       CLIENTES  CUENTAS   VENTANILLA PREST.  DEPOSITOS PLAZO FIJO TRANSF.
           │          │          │      │          │          │          │
           │          │          │      │          │          │          │
           ▼          ▼          ▼      ▼          ▼          ▼          ▼
       BCHMNU00  RPTMNU00  SECMNU00  COMHELP   SECSGN00
       BATCH     REPORTES  SEGURIDAD AYUDA     SALIR
           │          │          │
           │          │          │
           ▼          ▼          ▼
     (submenus)  (submenus)  (submenus)
```

---

### BNK0001 — LOGIN (Pantalla de Acceso)

```
BNK0001 (LOGIN)
  │
  ├── PF1   → CALL 'COMHELP' USING 'LOGIN'
  ├── PF12  → Salir del sistema (STOP RUN)
  ├── ENTER → Validar credenciales
  │            ├── OK → BNK0001 set LS-RETCODE=00 → COMMENU/BNK0010
  │            ├── Password expirado → BNK0001 (cambio password)
  │            │     ├── Enter → Validar y actualizar password
  │            │     ├── PF12  → Cancelar cambio, retornar login
  │            │     └── OK    → Continuar a sesion
  │            ├── Usuario bloqueado → Mensaje, no acceso
  │            └── 3 intentos fallidos → BLOQUEAR USUARIO
  └── CLEAR → Limpiar campos
```

---

### COMMENU / BNK0010 — MENU PRINCIPAL

```
COMMENU (MENU PRINCIPAL)
  Linea 1: BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO [fecha] [hora]
  Linea 2: MENU PRINCIPAL                              [usuario] [sucursal]

  PF1  → CALL 'CUSMNU00'  — Clientes (Altas/Consultas/Bajas)
  PF2  → CALL 'ACTMNU00'  — Cuentas (Apertura/Cierre/Modificacion)
  PF3  → CALL 'TLRMNU00'  — Ventanilla (Depositos/Retiros/Pagos)
  PF4  → CALL 'LONMNU00'  — Prestamos (Solicitud/Aprobacion/Pago)
  PF5  → CALL 'DEPMNU00'  — Depositos (Ahorro/Plazo/Renovacion)
  PF6  → CALL 'TDMNU000'  — Plazo Fijo (Certificados/CDs)
  PF7  → CALL 'FTMNU000'  — Transferencias (Wire/ACH/Interna)
  PF8  → CALL 'BCHMNU00'  — Procesos Batch (Cierre/Intereses)
  PF9  → CALL 'RPTMNU00'  — Reportes (Balance/TXN/Delincuencia)
  PF10 → CALL 'SECMNU00'  — Seguridad (Usuarios/Auditoria)
  PF11 → CALL 'COMHELP' USING 'GENERAL' — Ayuda General
  PF12 → CALL 'SECSGN00'  — Salir del Sistema (STOP RUN)
```

**BNK0010** (variante con 60 opciones numeradas en 3 paginas):

```
BNK0010 (MENU PRINCIPAL - 60 OPCIONES)
  Pagina 1 (opciones 01-22):
    01 Alta Cliente          02 Consulta Cliente
    03 Modificacion Cliente  04 Baja Cliente
    05 Busqueda Cliente      06 Direcciones
    07 Relaciones            08 Cambio Estatus
    09 Apertura Cuenta       10 Consulta Cuenta
    11 Modificacion Cuenta   12 Cierre Cuenta
    13 Congelar/Descongelar  14 Consulta Saldo
    15 Estado Cuenta         16 Chequeras
    17 Apertura Caja         18 Deposito
    19 Retiro                20 Transferencia
    21 Pago Servicios        22 Cobro Cheque

  Pagina 2 (opciones 23-44):
    23 Pago Prestamo         24 Cierre Caja
    25 Solicitud Prestamo    26 Aprobacion
    27 Desembolso            28 Consulta Prestamo
    29 Pago Cuota            30 Amortizacion
    31 Gestion Mora          32 Apertura Deposito
    33 Consulta Deposito     34 Tasas Interes
    35 Renovacion Deposito   36 Cancelacion Deposito
    37 Apertura CD           38 Consulta CD
    39 Liquidacion CD        40 Calculo Interes CD
    41 Transferencia Interna 42 Transferencia Wire
    43 Transferencia ACH     44 Consulta Transferencia

  Pagina 3 (opciones 45-61):
    45 Cierre Diario         46 Cierre Mensual
    47 Intereses y Mora      48 Pase Contable GL
    49 Comisiones Periodicas 50 Balance General
    51 Transacciones Diarias 52 Cartera Vencida
    53 Cuadre Caja           54 Trial Balance
    55 Reportes Regulatorios 56 Alta Usuario
    57 Consulta Usuario      58 Cambio Password
    59 Auditoria Sesiones    60 Parametros Sistema
                            99 Salir

  PF1-PF3: Cambiar pagina    PF7: Pagina anterior
  PF8: Pagina siguiente       PF11: Ayuda    PF12: Salir
  Enter: Ejecutar opcion por codigo numerico
```

---

### CUSMNU00 — MODULO CLIENTES (submenu)

```
CUSMNU00 (MENU CLIENTES)
  Linea 1: BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO [fecha] [hora]
  Linea 2: MODULO CLIENTES - MENU PRINCIPAL           [usuario] [sucursal]

  PF1  → CALL 'CUSSRH00'  — Busqueda de Cliente
  PF2  → CALL 'CUSINQ00'  — Consulta de Cliente
  PF3  → CALL 'CUSMNT00'  — Alta de Cliente
  PF4  → CALL 'CUSUPD00'  — Modificacion de Cliente
  PF5  → CALL 'CUSADR00'  — Mantenimiento Direcciones
  PF6  → CALL 'CUSREL00'  — Relaciones / Beneficiarios
  PF7  → CALL 'CUSSTS00'  — Cambio de Estatus
  PF11 → CALL 'COMHELP' USING 'CLIENTES' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010

  PF1=SRH  PF2=INQ  PF3=ALT  PF4=UPD  PF5=ADR  PF6=REL  PF7=STS  PF11=AYU  PF12=RET
```

**Subprogramas Customer:**

```
CUSSRH00 (Busqueda)
  ─ Entrada: tipo busqueda (ID/Nombre/RFC)
  ─ Salida: lista de clientes encontrados
  ─ PF12 → retorna a CUSMNU00

CUSINQ00 (Consulta)
  ─ Entrada: CUS-ID
  ─ Salida: todos los datos del cliente
  ─ Puede CALL 'ACTINQ00' para ver cuentas asociadas
  ─ PF12 → retorna a CUSMNU00

CUSMNT00 (Alta)
  ─ Entrada: todos los campos del cliente
  ─ Validacion: RFC formato, CURP, duplicados
  ─ WRITE CUSTOMER, puede WRITE ACCTXREF
  ─ CALL 'AUDTRL00' para auditar
  ─ PF12 → retorna a CUSMNU00

CUSUPD00 (Modificacion)
  ─ Entrada: CUS-ID, campos a modificar
  ─ REWRITE CUSTOMER
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a CUSMNU00

CUSADR00 (Direcciones)
  ─ Entrada: CUS-ID, direccion
  ─ READ/WRITE CUSTOMER (direcciones)
  ─ PF12 → retorna a CUSMNU00

CUSREL00 (Relaciones)
  ─ Entrada: CUS-ID, relacion
  ─ READ/WRITE ACCTXREF
  ─ PF12 → retorna a CUSMNU00

CUSSTS00 (Estatus)
  ─ Entrada: CUS-ID, nuevo estatus
  ─ REWRITE CUSTOMER (status)
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a CUSMNU00
```

---

### ACTMNU00 — MODULO CUENTAS (submenu)

```
ACTMNU00 (MENU CUENTAS)
  Linea 1: BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO [fecha] [hora]
  Linea 2: MODULO CUENTAS - MENU PRINCIPAL           [usuario] [sucursal]

  PF1  → CALL 'ACTINQ00'  — Consulta de Cuenta
  PF2  → CALL 'ACTOPN00'  — Apertura de Cuenta
  PF3  → CALL 'ACTUPD00'  — Modificacion de Cuenta
  PF4  → CALL 'ACTCLS00'  — Cierre de Cuenta
  PF5  → CALL 'ACTFRZ00'  — Congelar / Descongelar
  PF6  → CALL 'ACTBAL00'  — Consulta de Saldo
  PF7  → CALL 'ACTSTM00'  — Estado de Cuenta
  PF11 → CALL 'COMHELP' USING 'CUENTAS' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010

  PF1=INQ  PF2=APERT  PF3=UPD  PF4=CIERRE  PF5=FRZ  PF6=BAL  PF7=STM  PF11=AYU  PF12=RET
```

**Subprogramas Account:**

```
ACTINQ00 (Consulta Cuenta)
  ─ Entrada: ACT-NBR
  ─ Salida: datos generales, saldos, estatus
  ─ PF12 → retorna a ACTMNU00

ACTOPN00 (Apertura)
  ─ CALL 'CUSSRH00' para buscar cliente titular
  ─ Entrada: tipo cuenta, moneda, cliente, deposito inicial
  ─ WRITE ACCOUNT, WRITE ACCTXREF, WRITE CHQBOOK (si aplica)
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a ACTMNU00

ACTUPD00 (Modificacion)
  ─ Entrada: ACT-NBR, campos a modificar (tasa, limite sobregiro)
  ─ REWRITE ACCOUNT
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a ACTMNU00

ACTCLS00 (Cierre)
  ─ Verifica saldo cero
  ─ REWRITE ACCOUNT (status = 'C')
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a ACTMNU00

ACTFRZ00 (Congelar)
  ─ Entrada: ACT-NBR, motivo
  ─ REWRITE ACCOUNT (status = 'F')
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a ACTMNU00

ACTBAL00 (Saldo)
  ─ Entrada: ACT-NBR
  ─ Salida: saldo actual, disponible, retenido
  ─ Si sobregiro, CALL 'BCHODO00' para calcular comision
  ─ PF12 → retorna a ACTMNU00

ACTSTM00 (Estado Cuenta)
  ─ Entrada: ACT-NBR, periodo
  ─ Genera spool / impresion
  ─ PF12 → retorna a ACTMNU00
```

---

### TLRMNU00 — MODULO VENTANILLA / CAJA

```
TLRMNU00 (MENU CAJA / VENTANILLA)
  Linea 1: BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO [fecha] [hora]
  Linea 2: MODULO DE CAJA / VENTANILLA                 [usuario] [sucursal]

  PF1  → CALL 'TLRSGN00'  — Apertura de Caja (Sign-On)
  PF2  → CALL 'TLRDEP00'  — Deposito en Efectivo/Cheque
  PF3  → CALL 'TLRWTH00'  — Retiro en Efectivo
  PF4  → CALL 'TLRTRF00'  — Transferencia entre Cuentas
  PF5  → CALL 'TLRPYM00'  — Pago de Servicios
  PF6  → CALL 'TLRCHE00'  — Cobro de Cheque
  PF7  → CALL 'TLRSMG00'  — Resumen / Cierre de Caja
  PF11 → CALL 'COMHELP' USING 'CAJA' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010

  NOTA: PF2-PF7 requieren sesion de caja activa (PF1 primero)

  PF1=APERT  PF2=DEP  PF3=RET  PF4=TRF  PF5=PAG  PF6=CHQ  PF7=CIE  PF12=SALIR
```

**Subprogramas Teller:**

```
TLRSGN00 (Apertura Caja)
  ─ Entrada: monto fondo inicial
  ─ WRITE TELLEREC (status='O')
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a TLRMNU00

TLRDEP00 (Deposito)
  ─ CALL 'ACTINQ00' para validar cuenta destino
  ─ Entrada: cuenta, monto, tipo (efectivo/cheque)
  ─ READ/REWRITE ACCOUNT (incrementa saldo)
  ─ WRITE TRANLOG
  ─ REWRITE TELLEREC (incrementa fondo)
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a TLRMNU00

TLRWTH00 (Retiro)
  ─ CALL 'ACTBAL00' verifica saldo suficiente
  ─ Entrada: cuenta, monto
  ─ READ/REWRITE ACCOUNT (decrementa saldo)
  ─ WRITE TRANLOG
  ─ REWRITE TELLEREC (decrementa fondo)
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a TLRMNU00

TLRTRF00 (Transferencia)
  ─ CALL 'ACTINQ00' valida cuentas origen/destino
  ─ READ/REWRITE ambas cuentas
  ─ WRITE TRANLOG
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a TLRMNU00

TLRPYM00 (Pago Servicios)
  ─ CALL 'ACTBAL00' verifica fondos
  ─ Entrada: cuenta, servicio, monto
  ─ REWRITE ACCOUNT, WRITE TRANLOG
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a TLRMNU00

TLRCHE00 (Cobro Cheque)
  ─ CALL 'ACTINQ00' verifica cuenta y fondos
  ─ READ/REWRITE ACCOUNT
  ─ WRITE TRANLOG
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a TLRMNU00

TLRSMG00 (Resumen/Cierre)
  ─ READ TELLEREC (totales del dia)
  ─ CALL 'RPTTLR00' genera spool de cuadre
  ─ Muestra resumen en pantalla
  ─ PF12 → retorna a TLRMNU00
```

---

### LONMNU00 — MODULO PRESTAMOS

```
LONMNU00 (MENU PRESTAMOS)
  Linea 1: BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO [fecha] [hora]
  Linea 2: MODULO PRESTAMOS - MENU PRINCIPAL          [usuario] [sucursal]

  PF1  → CALL 'LONINQ00'  — Consulta de Prestamo
  PF2  → CALL 'LONAPL00'  — Solicitud de Prestamo
  PF3  → CALL 'LONAPV00'  — Aprobacion de Prestamo
  PF4  → CALL 'LONDIS00'  — Desembolso
  PF5  → CALL 'LONPYM00'  — Pago de Prestamo
  PF6  → CALL 'LONAMR00'  — Tabla de Amortizacion
  PF7  → CALL 'LONDEL00'  — Gestion de Mora / Castigo
  PF11 → CALL 'COMHELP' USING 'PRESTAMOS' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010

  PF1=INQ  PF2=APL  PF3=APV  PF4=DIS  PF5=PYM  PF6=AMR  PF7=DEL  PF11=AYU  PF12=RET
```

**Subprogramas Loans:**

```
LONINQ00 (Consulta)
  ─ Entrada: LON-NBR
  ─ READ LOANMAST
  ─ Salida: datos prestamo, saldo, cuotas pagadas
  ─ PF12 → retorna a LONMNU00

LONAPL00 (Solicitud)
  ─ CALL 'CUSSRH00' busca cliente
  ─ Entrada: tipo, monto, plazo, ingresos
  ─ Scoring (ingreso/deuda)
  ─ WRITE LOANAPPL
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a LONMNU00

LONAPV00 (Aprobacion)
  ─ READ LOANAPPL
  ─ Si monto > 250,000 requiere doble firma
  ─ REWRITE LOANAPPL (status='A' o 'Z')
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a LONMNU00

LONDIS00 (Desembolso)
  ─ READ LOANAPPL (solo aprobadas, status='A')
  ─ DELETE LOANAPPL
  ─ WRITE LOANMAST
  ─ CALL 'TLRTRF00' para abonar a cuenta cliente
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a LONMNU00

LONPYM00 (Pago)
  ─ READ LOANMAST
  ─ CALL 'LONAMR00' calcula cuota
  ─ REWRITE LOANMAST (actualiza saldo, cuotas)
  ─ WRITE TRANLOG
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a LONMNU00

LONAMR00 (Amortizacion)
  ─ Entrada: monto, tasa, plazo, tipo (Frances/Alemana/Americana)
  ─ Calcula tabla de cuotas
  ─ Display en pantalla
  ─ PF12 → retorna a LONMNU00

LONDEL00 (Mora/Castigo)
  ─ Entrada: LON-NBR
  ─ Calcula dias mora, clasifica bucket
  ─ Si 180+ dias, castigo (status='C')
  ─ CALL 'AUDTRL00'
  ─ PF12 → retorna a LONMNU00
```

---

### DEPMNU00 — MODULO DEPOSITOS

```
DEPMNU00 (MENU DEPOSITOS)
  PF1  → CALL 'DEPINQ00'  — Consulta de Deposito
  PF2  → CALL 'DEPOPN00'  — Apertura de Deposito
  PF3  → CALL 'DEPINT00'  — Tasas de Interes
  PF4  → CALL 'DEPWTH00'  — Reglas de Retiro
  PF5  → CALL 'DEPSTM00'  — Estado de Deposito
  PF6  → CALL 'DEPREN00'  — Renovacion Automatica
  PF11 → CALL 'COMHELP' USING 'DEPOSITOS' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010
```

---

### TDMNU000 — MODULO PLAZO FIJO (CDs)

```
TDMNU000 (MENU PLAZO FIJO)
  PF1  → CALL 'TDOPN000'  — Apertura de CD
  PF2  → CALL 'TDINQ000'  — Consulta de CD
  PF3  → CALL 'TDCLS000'  — Liquidacion / Vencimiento
  PF4  → CALL 'TDINT000'  — Calculo de Interes
  PF11 → CALL 'COMHELP' USING 'PLAZOFIJO' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010
```

---

### FTMNU000 — MODULO TRANSFERENCIAS

```
FTMNU000 (MENU TRANSFERENCIAS)
  PF1  → CALL 'FTINT000'  — Transferencia Interna
  PF2  → CALL 'FTWIR000'  — Transferencia Wire (SWIFT)
  PF3  → CALL 'FTACH000'  — Transferencia ACH
  PF4  → CALL 'FTSTS000'  — Estado de Transferencia
  PF11 → CALL 'COMHELP' USING 'TRANSFERENCIAS' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010
```

---

### BCHMNU00 — MODULO BATCH

```
BCHMNU00 (MENU BATCH)
  PF1  → CALL 'BCHDAY00'  — Cierre Diario
  PF2  → CALL 'BCHMTH00'  — Cierre Mensual
  PF3  → CALL 'BCHINT00'  — Devengo de Intereses
  PF4  → CALL 'BCHGLI00'  — Interface Contable (GL)
  PF5  → CALL 'BCHODO00'  — Calculo Sobregiro / Mora
  PF6  → CALL 'BCHFEE00'  — Comisiones Periodicas
  PF11 → CALL 'COMHELP' USING 'BATCH' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010
```

**Procesos Batch internos:**

```
BCHDAY00 (Cierre Diario)
  ├── CALL 'BCHINT00'  — Devengo diario intereses
  ├── CALL 'BCHODO00'  — Calculo mora/sobregiro
  ├── CALL 'BCHFEE00'  — Comisiones periodicas
  ├── CALL 'BCHGLI00'  — Pase contable
  ├── CALL 'RPTTXN00'  — Spool transacciones diarias
  ├── CALL 'RPTBAL00'  — Spool balances
  ├── READ/WRITE BATCHCTL (actualiza fecha proceso)
  └── CALL 'AUDTRL00'
```

---

### RPTMNU00 — MODULO REPORTES

```
RPTMNU00 (MENU REPORTES)
  PF1  → CALL 'RPTBAL00'  — Balance General
  PF2  → CALL 'RPTTXN00'  — Transacciones Diarias
  PF3  → CALL 'RPTDEL00'  — Cartera Vencida
  PF4  → CALL 'RPTTLR00'  — Cuadre de Caja
  PF5  → CALL 'RPTGLB00'  — Trial Balance / Mayor
  PF6  → CALL 'RPTREG00'  — Reportes Regulatorios
  PF11 → CALL 'COMHELP' USING 'REPORTES' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010
```

---

### SECMNU00 — MODULO SEGURIDAD

```
SECMNU00 (MENU SEGURIDAD)
  PF1  → CALL 'SECUSR00'  — Mantenimiento Usuarios
  PF2  → CALL 'SECPWD00'  — Cambio de Password
  PF3  → CALL 'SECAUD00'  — Auditoria de Sesiones
  PF11 → CALL 'COMHELP' USING 'SEGURIDAD' — Ayuda
  PF12 → Retorno a COMMENU / BNK0010
```

---

## Patron de Pantalla Estandar

```
+----------------------------------------------------------------------+
|  BANCO NACIONAL 01/01/2006 14:30:25  USR: COBOL01  SUC: S001        |
+----------------------------------------------------------------------+
|                        MENU PRESTAMOS                                |
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
|  Opcion: _                                                           |
+----------------------------------------------------------------------+
| PF1-Consulta  PF2-Solicitud  PF3-Aprob  PF4-Desemb  PF11-Ayu PF12-Ret|
+----------------------------------------------------------------------+
```

Linea 1: Cabecera (sistema, fecha, hora, usuario, sucursal)
Linea 2: Titulo del programa / submodulo
Lineas 3-22: Area de datos / menu / mensajes
Linea 23: Linea separadora
Linea 24: Indicador PF-keys / mensajes de error

Todas las pantallas son 80x24, monitor monocromatico verde/ambar.
