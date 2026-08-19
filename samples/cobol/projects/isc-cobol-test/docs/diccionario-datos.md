# Diccionario de Datos — Sistema Bancario COBOL

## Convenciones

| Abreviatura | Significado                        |
|-------------|------------------------------------|
| PK          | Primary Key (clave primaria)       |
| AK          | Alternate Key (clave alternativa)  |
| IX          | Indexed (indice secundario)        |
| COMP-3      | Packed Decimal (BCD)               |
| 88          | Condition name (nivel 88)          |

Los campos marcados con COMP-3 almacenan valores financieros en formato packed decimal.
Los niveles 88 definen valores constantes con nombre.

---

## 1. CUSTOMER — Maestro de Clientes

**Archivo**: CUSTOMER.DAT
**Organizacion**: INDEXED
**Registro**: CUSTOMER-RECORD
**Longitud**: 300 caracteres
**Clave primaria**: CUS-ID (X(10))

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              | Valores / Notas                    |
|----------------------|------------------|--------|-----|------------------------------------------|------------------------------------|
| CUS-ID               | X(10)            |        |     | Identificador unico del cliente          | Generado por el sistema            |
| CUS-ID-TYPE          | X(02)            |        |  3  | Tipo de persona                          | PF=Fisica, PM=Moral, GO=Gobierno   |
| CUS-NAME             | X(60)            |        |     | Nombre o razon social                    |                                    |
| CUS-FIRST-LASTNAME   | X(30)            |        |     | Apellido paterno                         |                                    |
| CUS-SECOND-LASTNAME  | X(30)            |        |     | Apellido materno                         |                                    |
| CUS-SHORT-NAME       | X(40)            |        |     | Nombre corto / alias                     |                                    |
| CUS-RFC              | X(13)            |        |     | Registro Federal de Contribuyentes       | Formato: AAAA000101XXX             |
| CUS-CURP             | X(18)            |        |     | Clave Unica de Registro de Poblacion     | 18 caracteres alfanumericos        |
| CUS-REGISTRO-FISCAL  | X(20)            |        |     | Registro fiscal (personas morales)       |                                    |
| CUS-STRET            | X(40)            |        |     | Calle                                   |                                    |
| CUS-NUM-EXT          | X(10)            |        |     | Numero exterior                          |                                    |
| CUS-NUM-INT          | X(10)            |        |     | Numero interior                          |                                    |
| CUS-COLONIA          | X(30)            |        |     | Colonia                                 |                                    |
| CUS-CIUDAD           | X(30)            |        |     | Ciudad                                   |                                    |
| CUS-ESTADO           | X(20)            |        |     | Estado                                   |                                    |
| CUS-PAIS             | X(20)            |        |     | Pais                                     |                                    |
| CUS-CP               | X(05)            |        |     | Codigo Postal                            |                                    |
| CUS-TELEFONO1        | X(15)            |        |     | Telefono fijo                            |                                    |
| CUS-TELEFONO2        | X(15)            |        |     | Telefono alternativo                     |                                    |
| CUS-CELULAR          | X(15)            |        |     | Celular                                  |                                    |
| CUS-EMAIL            | X(50)            |        |     | Correo electronico                       |                                    |
| CUS-EMPRESA          | X(40)            |        |     | Empresa donde labora                     |                                    |
| CUS-PUESTO           | X(30)            |        |     | Puesto                                   |                                    |
| CUS-INGRESO-MENSUAL  | 9(09)V99         | SI     |     | Ingreso mensual declarado                |                                    |
| CUS-SEGMENTO         | X(02)            |        |  5  | Segmento del cliente                     | 01=Basico, 02=Medio, 03=Alto, 04=Premier, 05=Empresarial |
| CUS-RIESGO-CATEGORIA | X(01)            |        |  4  | Categoria de riesgo                      | A=Bajo, B=Medio, C=Alto, D=Maximo |
| CUS-STATUS           | X(01)            |        |  4  | Estatus del cliente                      | A=Activo, I=Inactivo, B=Bloqueado, F=Fallecido |
| CUS-FECHA-ALTA       | 9(08)            |        |     | Fecha de alta (AAAAMMDD)                 |                                    |
| CUS-FECHA-ULT-MOD    | 9(08)            |        |     | Fecha ultima modificacion                |                                    |
| CUS-FECHA-ULT-OP     | 9(08)            |        |     | Fecha ultima operacion                   |                                    |
| CUS-USUARIO-ALTA     | X(08)            |        |     | Usuario que dio de alta                  |                                    |
| CUS-USUARIO-ULT-MOD  | X(08)            |        |     | Usuario ultima modificacion              |                                    |
| CUS-FECHA-NACIMIENTO | 9(08)            |        |     | Fecha de nacimiento                      |                                    |
| CUS-SEXO             | X(01)            |        |  2  | Sexo                                     | M=Masculino, F=Femenino            |
| CUS-NACIONALIDAD     | X(03)            |        |     | Nacionalidad (ISO 3166-1)                | MEX, USA, etc.                     |
| CUS-ACTIVIDAD-ECONOMICA | X(06)        |        |     | Actividad economica (SAT)                |                                    |
| CUS-FILLER           | X(20)            |        |     | Reservado                                |                                    |

**88 levels**: 16 en total (3+5+4+4+2)
**COMP-3**: 1 campo (ingreso mensual)
**Total fields**: 38

---

## 2. ACCOUNT — Maestro de Cuentas

**Archivo**: ACCOUNT.DAT
**Organizacion**: INDEXED
**Registro**: ACCOUNT-RECORD
**Longitud**: 200 caracteres
**Clave primaria**: ACT-NBR (X(10))

| Campo                  | PIC              | COMP-3 | 88s | Descripcion                              | Valores / Notas                    |
|------------------------|------------------|--------|-----|------------------------------------------|------------------------------------|
| ACT-NBR                | X(10)            |        |     | Numero de cuenta                         | Generado por el sistema            |
| ACT-TYPE               | X(02)            |        |  4  | Tipo de cuenta                           | CH=Cheques, AH=Ahorro, NO=Nomina, IN=Inversion |
| ACT-CURRENCY           | X(03)            |        |  3  | Moneda                                   | MXN, USD, EUR                      |
| ACT-BALANCE            | S9(13)V99        | SI     |     | Saldo actual                             |                                    |
| ACT-BALANCE-DISPONIBLE | S9(13)V99        | SI     |     | Saldo disponible                         | balance - retenido                 |
| ACT-BALANCE-RETENIDO   | S9(13)V99        | SI     |     | Saldo retenido                           |                                    |
| ACT-BALANCE-SOBREGIRO  | S9(13)V99        | SI     |     | Saldo en sobregiro                       |                                    |
| ACT-BALANCE-PROMEDIO   | S9(13)V99        | SI     |     | Saldo promedio                           |                                    |
| ACT-BALANCE-ANTERIOR   | S9(13)V99        | SI     |     | Saldo anterior                           |                                    |
| ACT-OVERDRAFT-LIMIT    | S9(09)V99        | SI     |     | Limite de sobregiro                      |                                    |
| ACT-OVERDRAFT-RATE     | 9(03)V9(04)      | SI     |     | Tasa de sobregiro                        |                                    |
| ACT-INTEREST-RATE      | 9(03)V9(04)      | SI     |     | Tasa de interes                          |                                    |
| ACT-INTEREST-ACCRUED   | S9(09)V99        | SI     |     | Interes devengado no pagado              |                                    |
| ACT-MONTHLY-FEE        | 9(07)V99         | SI     |     | Comision mensual                         |                                    |
| ACT-DATE-OPEN          | 9(08)            |        |     | Fecha de apertura                        | AAAAMMDD                           |
| ACT-DATE-CLOSE         | 9(08)            |        |     | Fecha de cierre                          |                                    |
| ACT-DATE-LAST-ACTIVITY | 9(08)            |        |     | Fecha ultima actividad                   |                                    |
| ACT-DATE-LAST-INT-CALC | 9(08)            |        |     | Fecha ultimo calculo de interes          |                                    |
| ACT-DATE-LAST-STATEMENT| 9(08)            |        |     | Fecha ultimo estado de cuenta            |                                    |
| ACT-STATUS             | X(01)            |        |  5  | Estatus de cuenta                        | A=Activa, I=Inactiva, C=Cerrada, F=Congelada, D=Dormant |
| ACT-BRANCH-OPEN        | X(04)            |        |     | Sucursal de apertura                     |                                    |
| ACT-OFFICER            | X(08)            |        |     | Ejecutivo de cuenta                      |                                    |
| ACT-USER-LAST-MOD      | X(08)            |        |     | Usuario ultima modificacion              |                                    |
| ACT-TXN-COUNT-TODAY    | 9(06)            |        |     | Transacciones del dia                    |                                    |
| ACT-TXN-COUNT-MONTH    | 9(06)            |        |     | Transacciones del mes                    |                                    |
| ACT-CHECKS-ISSUED      | 9(06)            |        |     | Cheques emitidos                         |                                    |
| ACT-CHECKS-BOUNCED     | 9(06)            |        |     | Cheques rebotados                        |                                    |
| ACT-CHQBOOK-NBR        | X(10)            |        |     | Chequera actual                          |                                    |
| ACT-CHQ-NEXT           | 9(07)            |        |     | Siguiente cheque a usar                  |                                    |
| ACT-CHQ-LAST-USED      | 9(07)            |        |     | Ultimo cheque usado                      |                                    |
| ACT-CHQ-STOP-COUNT     | 9(03)            |        |     | Contador cheques suspendidos             |                                    |
| ACT-FILLER             | X(15)            |        |     | Reservado                                |                                    |

**88 levels**: 12 en total (4+3+5)
**COMP-3**: 14 campos
**Total fields**: 32

---

## 3. TRANLOG — Bitacora de Transacciones

**Archivo**: TRANLOG.DAT
**Organizacion**: INDEXED
**Registro**: TRANLOG-RECORD
**Longitud**: 150 caracteres
**Clave primaria**: TRN-SEQ (9(10))
**Clave alternativa**: TRN-ACCOUNT-NBR

| Campo               | PIC              | COMP-3 | 88s | Descripcion                              | Valores / Notas                    |
|---------------------|------------------|--------|-----|------------------------------------------|------------------------------------|
| TRN-SEQ             | 9(10)            |        |     | Secuencia unica de transaccion           | Generado por sistema               |
| TRN-DATE            | 9(08)            |        |     | Fecha de la transaccion                  | AAAAMMDD                           |
| TRN-TIME            | 9(06)            |        |     | Hora de la transaccion                   | HHMMSS                             |
| TRN-TYPE            | X(03)            |        | 10  | Tipo de transaccion                      | DEP=Deposito, RET=Retiro, TRF=Transferencia, PAG=Pago, CHQ=Cheque, INT=Interes, COM=Comision, AJU=Ajuste, APE=Apertura, CIE=Cierre |
| TRN-ACCOUNT-NBR     | X(10)            |        |     | Cuenta origen                            | AK                                 |
| TRN-ACCOUNT-DEST    | X(10)            |        |     | Cuenta destino                           |                                    |
| TRN-CUSTOMER-ID     | X(10)            |        |     | Cliente asociado                         |                                    |
| TRN-AMOUNT          | S9(13)V99        | SI     |     | Monto de la transaccion                  |                                    |
| TRN-AMOUNT-TAX      | S9(09)V99        | SI     |     | Impuesto                                 |                                    |
| TRN-AMOUNT-TOTAL    | S9(13)V99        | SI     |     | Monto total                              |                                    |
| TRN-AMOUNT-ORIGINAL | S9(13)V99        | SI     |     | Monto original (para reversos)           |                                    |
| TRN-FEE-AMOUNT      | S9(07)V99        | SI     |     | Comision cobrada                         |                                    |
| TRN-FEE-CODE        | X(04)            |        |     | Codigo de comision                       |                                    |
| TRN-BRANCH          | X(04)            |        |     | Sucursal                                 |                                    |
| TRN-TELLER-ID       | X(08)            |        |     | Cajero que proceso                       |                                    |
| TRN-USER-ID         | X(08)            |        |     | Usuario que autorizo                     |                                    |
| TRN-TERMINAL        | X(08)            |        |     | Terminal                                 |                                    |
| TRN-CHANNEL         | X(02)            |        |  4  | Canal                                    | 01=Ventanilla, 02=Cajero, 03=Banca Electronica, 04=Batch |
| TRN-REFERENCE       | X(20)            |        |     | Referencia externa                       |                                    |
| TRN-CHQ-NBR         | 9(10)            |        |     | Numero de cheque                         |                                    |
| TRN-CHQ-BANK        | X(10)            |        |     | Banco del cheque                         |                                    |
| TRN-CHQ-ACCOUNT     | X(10)            |        |     | Cuenta del cheque                        |                                    |
| TRN-STATUS          | X(01)            |        |  4  | Estatus de la transaccion                | P=Pendiente, C=Confirmado, R=Rechazado, V=Reversado |
| TRN-REVERSE-SEQ     | 9(10)            |        |     | Secuencia de la transaccion reversada    |                                    |
| TRN-DESCRIPTION     | X(30)            |        |     | Descripcion                              |                                    |
| TRN-FILLER          | X(10)            |        |     | Reservado                                |                                    |

**88 levels**: 18 en total (10+4+4)
**COMP-3**: 7 campos
**Total fields**: 25

---

## 4. CARD — Tarjetas de Debito/Credito

**Archivo**: CARD.DAT
**Organizacion**: INDEXED
**Registro**: CARD-RECORD
**Longitud**: 250 caracteres
**Clave primaria**: CRD-NBR (X(16))

| Campo                  | PIC              | COMP-3 | 88s | Descripcion                              |
|------------------------|------------------|--------|-----|------------------------------------------|
| CRD-NBR                | X(16)            |        |     | Numero de tarjeta (PAN)                  |
| CRD-EMBOSSED-NAME      | X(30)            |        |     | Nombre en relieve                        |
| CRD-TYPE               | X(02)            |        |  4  | Tipo: DB=Debito, CR=Credito, PP=Prepagado, CO=Corporativa |
| CRD-PRODUCT            | X(04)            |        |  4  | Producto: CLAS, GOLD, PLAT, BLCK         |
| CRD-CUSTOMER-ID        | X(10)            |        |     | Cliente titular                          |
| CRD-ACCOUNT-NBR        | X(10)            |        |     | Cuenta asociada                          |
| CRD-BRANCH             | X(04)            |        |     | Sucursal emisora                         |
| CRD-DATE-ISSUE         | 9(08)            |        |     | Fecha de emision                         |
| CRD-DATE-EXPIRY        | 9(08)            |        |     | Fecha de vencimiento                     |
| CRD-DATE-LAST-USED     | 9(08)            |        |     | Fecha ultimo uso                         |
| CRD-DATE-LAST-PIN-CHG  | 9(08)            |        |     | Fecha ultimo cambio PIN                  |
| CRD-LIMIT-CASH         | 9(09)V99         | SI     |     | Limite de disposicion efectivo           |
| CRD-LIMIT-PURCHASE     | 9(09)V99         | SI     |     | Limite de compras                        |
| CRD-LIMIT-DAILY-CASH   | 9(09)V99         | SI     |     | Limite diario efectivo                   |
| CRD-LIMIT-DAILY-PURCHASE| 9(09)V99        | SI     |     | Limite diario compras                    |
| CRD-LIMIT-MONTHLY      | 9(09)V99         | SI     |     | Limite mensual                           |
| CRD-BALANCE-CURRENT    | S9(09)V99        | SI     |     | Saldo actual (credito)                   |
| CRD-BALANCE-AVAILABLE  | S9(09)V99        | SI     |     | Saldo disponible                         |
| CRD-BALANCE-PAST-DUE   | S9(09)V99        | SI     |     | Saldo vencido                            |
| CRD-MINIMUM-PAYMENT    | S9(09)V99        | SI     |     | Pago minimo                              |
| CRD-INTEREST-RATE      | 9(03)V9(04)      | SI     |     | Tasa de interes                          |
| CRD-CUT-DAY            | 9(02)            |        |     | Dia de corte                             |
| CRD-PAYMENT-DAY        | 9(02)            |        |     | Dia de pago                              |
| CRD-PIN-OFFSET         | X(06)            |        |     | Offset PIN                               |
| CRD-CVV                | X(04)            |        |     | Codigo de validacion                     |
| CRD-PIN-TRIES          | 9(02)            |        |     | Intentos PIN fallidos                    |
| CRD-PIN-BLOCKED        | X(01)            |        |  2  | PIN bloqueado?                           |
| CRD-STATUS             | X(01)            |        |  7  | Estatus: A=Activa, I=Inactiva, B=Bloqueada, E=Expirada, S=Robada, L=Perdida, C=Cancelada |
| CRD-REASON-LAST-CHANGE | X(40)            |        |     | Motivo ultimo cambio                     |
| CRD-ISSUE-COUNT        | 9(02)            |        |     | Contador de reposiciones                 |
| CRD-ATM-DAILY-COUNT    | 9(03)            |        |     | Transacciones ATM hoy                    |
| CRD-ATM-DAILY-AMOUNT   | 9(09)V99         | SI     |     | Monto ATM hoy                            |
| CRD-CONTACTLESS        | X(01)            |        |  2  | Contactless activo?                      |
| CRD-FILLER             | X(15)            |        |     | Reservado                                |

**88 levels**: 19 en total (4+4+2+7+2)
**COMP-3**: 13 campos
**Total fields**: 34

---

## 5. LOANMAST — Maestro de Prestamos

**Archivo**: LOANMAST.DAT
**Organizacion**: INDEXED
**Registro**: LOANMAST-RECORD
**Longitud**: 350 caracteres
**Clave primaria**: LON-NBR (X(10))

| Campo                     | PIC              | COMP-3 | 88s | Descripcion                              |
|---------------------------|------------------|--------|-----|------------------------------------------|
| LON-NBR                   | X(10)            |        |     | Numero de prestamo                       |
| LON-APPL-ID               | X(10)            |        |     | ID solicitud original                    |
| LON-CUSTOMER-ID           | X(10)            |        |     | Cliente                                  |
| LON-TYPE                  | X(02)            |        |  6  | Tipo: PL, HI, AU, CO, PR, RE            |
| LON-PRODUCT-CODE          | X(04)            |        |     | Codigo de producto                       |
| LON-AMOUNT-APPROVED       | 9(13)V99         | SI     |     | Monto autorizado                         |
| LON-AMOUNT-DISBURSED      | 9(13)V99         | SI     |     | Monto desembolsado                       |
| LON-BALANCE               | 9(13)V99         | SI     |     | Saldo insoluto                           |
| LON-BALANCE-PAST-DUE      | 9(13)V99         | SI     |     | Saldo vencido                            |
| LON-AMOUNT-INTEREST       | 9(13)V99         | SI     |     | Interes devengado                        |
| LON-AMOUNT-PENALTY        | 9(09)V99         | SI     |     | Penalizacion                             |
| LON-MINIMUM-PAYMENT       | 9(09)V99         | SI     |     | Pago minimo                              |
| LON-INTEREST-RATE         | 9(03)V9(04)      | SI     |     | Tasa de interes anual                    |
| LON-INTEREST-LATE         | 9(03)V9(04)      | SI     |     | Tasa moratoria                           |
| LON-INTEREST-MORA         | 9(03)V9(04)      | SI     |     | Tasa de mora                             |
| LON-COMISION-APERTURA     | 9(07)V99         | SI     |     | Comision por apertura                    |
| LON-TERM-MONTHS           | 9(04)            |        |     | Plazo en meses                           |
| LON-TERM-DAYS             | 9(04)            |        |     | Plazo en dias                            |
| LON-FREQUENCY             | X(01)            |        |  5  | Frecuencia pago: S, Q, M, B, T          |
| LON-PAYMENTS-TOTAL        | 9(04)            |        |     | Total de pagos                           |
| LON-PAYMENTS-MADE         | 9(04)            |        |     | Pagos realizados                         |
| LON-PAYMENTS-OVERDUE      | 9(04)            |        |     | Pagos vencidos                           |
| LON-AMORT-TYPE            | X(01)            |        |  4  | Tipo amortizacion: F=Francesa, A=Alemana, M=Americana, C=Cuota Fija |
| LON-INSTALLMENT-AMOUNT    | 9(09)V99         | SI     |     | Monto de cuota                           |
| LON-INSTALLMENT-DUE-DAY   | 9(02)            |        |     | Dia de pago                              |
| LON-DATE-APPROVAL         | 9(08)            |        |     | Fecha de aprobacion                      |
| LON-DATE-DISBURSEMENT     | 9(08)            |        |     | Fecha de desembolso                      |
| LON-DATE-FIRST-PAYMENT    | 9(08)            |        |     | Fecha primer pago                        |
| LON-DATE-LAST-PAYMENT     | 9(08)            |        |     | Fecha ultimo pago                        |
| LON-DATE-MATURITY         | 9(08)            |        |     | Fecha de vencimiento                     |
| LON-DATE-LAST-CALC        | 9(08)            |        |     | Fecha ultimo calculo                     |
| LON-COLLATERAL-TYPE       | X(02)            |        |     | Tipo de garantia                         |
| LON-COLLATERAL-DESC       | X(40)            |        |     | Descripcion garantia                     |
| LON-COLLATERAL-VALUE      | 9(13)V99         | SI     |     | Valor de garantia                        |
| LON-ACCOUNT-DEBIT         | X(10)            |        |     | Cuenta para cargo                        |
| LON-ACCOUNT-DISBURSEMENT  | X(10)            |        |     | Cuenta para desembolso                   |
| LON-INSTALLMENT-TABLE     | OCCURS 360       |        |     | Tabla de cuotas (360 cuotas max)         |
| LON-INST-NBR              | 9(04)            |        |     | Numero de cuota                          |
| LON-INST-DUE-DATE         | 9(08)            |        |     | Fecha de vencimiento cuota               |
| LON-INST-AMOUNT           | 9(09)V99         | SI     |     | Monto de cuota                           |
| LON-INST-PRINCIPAL        | 9(09)V99         | SI     |     | Amortizacion de capital                  |
| LON-INST-INTEREST         | 9(09)V99         | SI     |     | Interes de cuota                         |
| LON-INST-BALANCE          | 9(09)V99         | SI     |     | Saldo despues de cuota                   |
| LON-INST-STATUS           | X(01)            |        |  4  | Estatus cuota: P=Pendiente, C=Pagada, V=Vencida, R=Refinanciada |
| LON-STATUS                | X(01)            |        |  5  | Estatus prestamo: A=Activo, P=Pagado, C=Castigado, R=Reestructurado, L=Legal |
| LON-CLASSIFICATION        | X(01)            |        |  4  | Clasificacion: 1=Normal, 2=Substandard, 3=Contencioso, 4=Perdida |
| LON-OFFICER               | X(08)            |        |     | Oficial de credito                       |
| LON-USER-LAST-MOD         | X(08)            |        |     | Usuario ultima modificacion              |
| LON-DATE-LAST-MOD         | 9(08)            |        |     | Fecha ultima modificacion                |
| LON-FILLER                | X(30)            |        |     | Reservado                                |

**88 levels**: 28 en total (6+5+4+4+5+4)
**COMP-3**: 18 campos
**Total fields**: 48

---

## 6. LOANAPPL — Solicitudes de Prestamo

**Archivo**: LOANAPPL.DAT
**Organizacion**: INDEXED
**Registro**: LOANAPPL-RECORD
**Longitud**: 280 caracteres
**Clave primaria**: LAP-APPL-ID (X(10))

| Campo                     | PIC              | COMP-3 | 88s | Descripcion                              |
|---------------------------|------------------|--------|-----|------------------------------------------|
| LAP-APPL-ID               | X(10)            |        |     | ID de solicitud                          |
| LAP-CUSTOMER-ID           | X(10)            |        |     | Cliente solicitante                      |
| LAP-TYPE                  | X(02)            |        |  4  | Tipo: PL, HI, AU, CO                    |
| LAP-PRODUCT-CODE          | X(04)            |        |     | Codigo de producto                       |
| LAP-AMOUNT-REQUESTED      | 9(13)V99         | SI     |     | Monto solicitado                         |
| LAP-TERM-MONTHS           | 9(04)            |        |     | Plazo solicitado                         |
| LAP-PAYMENT-FREQ          | X(01)            |        |  3  | Frecuencia: S, Q, M                     |
| LAP-PROPOSED-RATE         | 9(03)V9(04)      | SI     |     | Tasa propuesta                           |
| LAP-SCORE                 | 9(03)            |        |     | Puntaje scoring                          |
| LAP-SCORE-APROBACION      | 9(03)            |        |     | Puntaje minimo aprobacion                |
| LAP-SCORE-RIESGO          | X(01)            |        |  3  | Riesgo: B=Bajo, M=Medio, A=Alto         |
| LAP-INGRESO-MENSUAL       | 9(09)V99         | SI     |     | Ingreso mensual                          |
| LAP-INGRESO-CONYUGAL      | 9(09)V99         | SI     |     | Ingreso conyugal                         |
| LAP-OTROS-INGRESOS        | 9(09)V99         | SI     |     | Otros ingresos                           |
| LAP-EGRESOS-MENSUALES     | 9(09)V99         | SI     |     | Egresos mensuales                        |
| LAP-GARANTE-ID            | X(10)            |        |     | ID del aval/garante                      |
| LAP-GARANTE-INGRESO       | 9(09)V99         | SI     |     | Ingreso del garante                      |
| LAP-GARANTIA-TIPO         | X(02)            |        |     | Tipo de garantia                         |
| LAP-GARANTIA-VALOR        | 9(11)V99         | SI     |     | Valor de la garantia                     |
| LAP-STATUS                | X(01)            |        |  6  | Estatus: B=Borrador, R=En Revision, A=Aprobado, Z=Rechazado, C=Cancelado, D=Desembolsado |
| LAP-FECHA-SOLICITUD       | 9(08)            |        |     | Fecha de solicitud                       |
| LAP-FECHA-APROBACION      | 9(08)            |        |     | Fecha de aprobacion                      |
| LAP-FECHA-VENCIMIENTO     | 9(08)            |        |     | Fecha de vencimiento                     |
| LAP-USUARIO-SOLICITA      | X(08)            |        |     | Usuario que solicita                     |
| LAP-USUARIO-APRUEBA       | X(08)            |        |     | Usuario que aprueba                      |
| LAP-OBSERVACIONES         | X(60)            |        |     | Observaciones                            |
| LAP-FILLER                | X(20)            |        |     | Reservado                                |

**88 levels**: 16 en total (4+3+3+6)
**COMP-3**: 10 campos
**Total fields**: 27

---

## 7. BRANCH — Sucursales

**Archivo**: BRANCH.DAT
**Organizacion**: INDEXED
**Registro**: BRANCH-RECORD
**Longitud**: 200 caracteres
**Clave primaria**: BRH-CODE (X(04))

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              |
|----------------------|------------------|--------|-----|------------------------------------------|
| BRH-CODE             | X(04)            |        |     | Codigo de sucursal                       |
| BRH-NAME             | X(40)            |        |     | Nombre de sucursal                       |
| BRH-SHORT-NAME       | X(15)            |        |     | Nombre corto                             |
| BRH-STREET           | X(40)            |        |     | Calle                                    |
| BRH-EXT-NUM          | X(10)            |        |     | Numero exterior                          |
| BRH-COLONY           | X(30)            |        |     | Colonia                                  |
| BRH-CITY             | X(30)            |        |     | Ciudad                                   |
| BRH-STATE            | X(20)            |        |     | Estado                                   |
| BRH-ZIP              | X(05)            |        |     | Codigo postal                            |
| BRH-PHONE            | X(15)            |        |     | Telefono                                 |
| BRH-MANAGER          | X(08)            |        |     | Gerente (ID usuario)                     |
| BRH-OPEN-TIME        | 9(04)            |        |     | Hora apertura                            |
| BRH-CLOSE-TIME       | 9(04)            |        |     | Hora cierre                              |
| BRH-SATURDAY-OPEN    | 9(04)            |        |     | Hora apertura sabado                     |
| BRH-SATURDAY-CLOSE   | 9(04)            |        |     | Hora cierre sabado                       |
| BRH-SUNDAY-OPEN      | 9(04)            |        |     | Hora apertura domingo                    |
| BRH-SUNDAY-CLOSE     | 9(04)            |        |     | Hora cierre domingo                      |
| BRH-BALANCE-CASH     | 9(11)V99         | SI     |     | Efectivo en caja                         |
| BRH-BALANCE-LIMIT    | 9(11)V99         | SI     |     | Limite de efectivo                       |
| BRH-GL-CODE          | X(08)            |        |     | Codigo contable                          |
| BRH-REGION           | X(02)            |        |     | Region                                   |
| BRH-STATUS           | X(01)            |        |  3  | Estatus: O=Abierta, C=Cerrada, T=Temporal|
| BRH-DATE-OPENED      | 9(08)            |        |     | Fecha de apertura                        |
| BRH-TERMINAL-COUNT   | 9(04)            |        |     | Numero de terminales                     |
| BRH-ATM-COUNT        | 9(02)            |        |     | Numero de cajeros ATM                    |
| BRH-EMPLOYEE-COUNT   | 9(06)            |        |     | Numero de empleados                      |
| BRH-FILLER           | X(30)            |        |     | Reservado                                |

**88 levels**: 3 en total
**COMP-3**: 2 campos
**Total fields**: 27

---

## 8. USERPROF — Perfiles de Usuario

**Archivo**: USERPROF.DAT
**Organizacion**: INDEXED
**Registro**: USERPROF-RECORD
**Longitud**: 180 caracteres
**Clave primaria**: USR-ID (X(08))

| Campo                   | PIC              | COMP-3 | 88s | Descripcion                              |
|-------------------------|------------------|--------|-----|------------------------------------------|
| USR-ID                  | X(08)            |        |     | ID de usuario                            |
| USR-NAME                | X(40)            |        |     | Nombre completo                          |
| USR-LAST-NAME           | X(30)            |        |     | Apellidos                                |
| USR-FIRST-NAME          | X(30)            |        |     | Nombre(s)                                |
| USR-PASSWORD            | X(20)            |        |     | Password (hash)                          |
| USR-PASSWORD-EXP-DATE   | 9(08)            |        |     | Fecha expiracion password                |
| USR-PASSWORD-LAST-CHG   | 9(08)            |        |     | Fecha ultimo cambio password             |
| USR-PASSWORD-TRIES      | 9(02)            |        |     | Intentos fallidos                        |
| USR-PASSWORD-BLOCKED    | X                |        |  2  | Bloqueado?                               |
| USR-PASSWORD-RESET      | X                |        |  2  | Reset obligatorio?                       |
| USR-ROLE                | X(03)            |        |  7  | Rol: ADM, GER, SUP, CAJ, OFI, AUD, CON  |
| USR-BRANCH              | X(04)            |        |     | Sucursal asignada                        |
| USR-DEPARTMENT          | X(04)            |        |     | Departamento                             |
| USR-LOGIN-TIME-FROM     | 9(04)            |        |     | Hora inicio permitida                    |
| USR-LOGIN-TIME-TO       | 9(04)            |        |     | Hora fin permitida                       |
| USR-LOGIN-IP-RANGE      | X(15)            |        |     | Rango IP permitido                       |
| USR-LOGIN-ATTEMPT-MAX   | 9(02)            |        |     | Maximo intentos (default 3)              |
| USR-SESSION-TIMEOUT     | 9(04)            |        |     | Timeout sesion segundos (default 600)    |
| USR-EMAIL               | X(50)            |        |     | Correo electronico                       |
| USR-PHONE               | X(15)            |        |     | Telefono                                 |
| USR-EXTENSION           | X(05)            |        |     | Extension                                |
| USR-STATUS              | X(01)            |        |  4  | Estatus: A=Activo, I=Inactivo, S=Suspendido, T=Terminado |
| USR-DATE-HIRED          | 9(08)            |        |     | Fecha contratacion                       |
| USR-DATE-TERMINATED     | 9(08)            |        |     | Fecha baja                               |
| USR-DATE-LAST-LOGIN     | 9(08)            |        |     | Fecha ultimo login                       |
| USR-TIME-LAST-LOGIN     | 9(06)            |        |     | Hora ultimo login                        |
| USR-FILLER              | X(20)            |        |     | Reservado                                |

**88 levels**: 15 en total (2+2+7+4)
**COMP-3**: 0
**Total fields**: 26

---

## 9. SECURITY — Registro de Auditoria de Seguridad

**Archivo**: SECURITY.DAT
**Organizacion**: INDEXED
**Registro**: SECURITY-RECORD
**Longitud**: 120 caracteres
**Clave primaria**: SEC-SEQ (9(10))

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              |
|----------------------|------------------|--------|-----|------------------------------------------|
| SEC-SEQ              | 9(10)            |        |     | Secuencia de evento                      |
| SEC-DATE             | 9(08)            |        |     | Fecha del evento                         |
| SEC-TIME             | 9(06)            |        |     | Hora del evento                          |
| SEC-USER-ID          | X(08)            |        |     | Usuario                                  |
| SEC-EVENT-TYPE       | X(02)            |        |  9  | Tipo: LI, LO, FA, LC, PC, PR, TO, UA, AD|
| SEC-IP-ADDRESS       | X(15)            |        |     | Direccion IP                             |
| SEC-TERMINAL         | X(08)            |        |     | Terminal                                 |
| SEC-BROWSER          | X(20)            |        |     | Navegador / aplicacion                   |
| SEC-RESULT           | X(01)            |        |  3  | Resultado: S=Success, F=Failure, B=Bloqueado |
| SEC-DETAILS          | X(40)            |        |     | Detalles adicionales                     |
| SEC-FILLER           | X(10)            |        |     | Reservado                                |

**88 levels**: 12 en total (9+3)
**COMP-3**: 0
**Total fields**: 11

---

## 10. PARAMSTR — Parametros del Sistema

**Archivo**: PARAMSTR.DAT
**Organizacion**: INDEXED
**Registro**: PARAMSTR-RECORD
**Longitud**: 150 caracteres
**Clave primaria**: PAR-CODIGO (X(08))

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              |
|----------------------|------------------|--------|-----|------------------------------------------|
| PAR-CODIGO           | X(08)            |        |     | Codigo del parametro                     |
| PAR-GRUPO            | X(10)            |        |  6  | Grupo: GENERAL, TASAS, LIMITES, HORARIO, COMISION, SEGURIDAD, CONTABLE |
| PAR-DESCRIPCION      | X(40)            |        |     | Descripcion                              |
| PAR-VALOR-TEXTO      | X(40)            |        |     | Valor en texto                           |
| PAR-VALOR-NUMERICO   | S9(13)V99        | SI     |     | Valor numerico                           |
| PAR-VALOR-FECHA      | 9(08)            |        |     | Valor fecha                              |
| PAR-TIPO-DATO        | X(01)            |        |  4  | Tipo: T=Texto, N=Numerico, F=Fecha, B=Booleano |
| PAR-MODIFICABLE      | X(01)            |        |  2  | Modificable?                             |
| PAR-FECHA-MOD        | 9(08)            |        |     | Fecha de modificacion                    |
| PAR-USUARIO-MOD      | X(08)            |        |     | Usuario que modifico                     |
| PAR-FILLER           | X(05)            |        |     | Reservado                                |

**88 levels**: 12 en total (6+4+2)
**COMP-3**: 1 campo
**Total fields**: 11

---

## 11. CURRENCY — Monedas / Tipos de Cambio

**Archivo**: CURRENCY.DAT
**Organizacion**: INDEXED
**Registro**: CURRENCY-RECORD
**Longitud**: 80 caracteres
**Clave primaria**: CUR-CODIGO (X(03))

| Campo                  | PIC              | COMP-3 | 88s | Descripcion                              |
|------------------------|------------------|--------|-----|------------------------------------------|
| CUR-CODIGO             | X(03)            |        |     | Codigo ISO de moneda                     |
| CUR-DESCRIPCION        | X(30)            |        |     | Descripcion                              |
| CUR-SIMBOLO            | X(03)            |        |     | Simbolo monetario                        |
| CUR-PAIS               | X(20)            |        |     | Pais                                     |
| CUR-EXCHANGE-RATE-BUY  | 9(07)V9(06)      | SI     |     | Tipo de cambio compra                    |
| CUR-EXCHANGE-RATE-SELL | 9(07)V9(06)      | SI     |     | Tipo de cambio venta                     |
| CUR-EXCHANGE-RATE-FIX  | 9(07)V9(06)      | SI     |     | Tipo de cambio fijo                      |
| CUR-EXCHANGE-DATE      | 9(08)            |        |     | Fecha del tipo de cambio                 |
| CUR-DECIMALES          | 9(01)            |        |  3  | Decimales: 2, 3, 4                      |
| CUR-STATUS             | X(01)            |        |  3  | Estatus: A=Activa, I=Inactiva, S=Suspendida |
| CUR-ES-BASE            | X(01)            |        |  2  | Es moneda base?                          |
| CUR-FILLER             | X(04)            |        |     | Reservado                                |

**88 levels**: 8 en total (3+3+2)
**COMP-3**: 3 campos
**Total fields**: 12

---

## 12. MESSAGES — Mensajes / Notificaciones

**Archivo**: MESSAGES.DAT
**Organizacion**: INDEXED
**Registro**: MESSAGES-RECORD
**Longitud**: 300 caracteres
**Clave primaria**: MSG-ID (9(08))

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              |
|----------------------|------------------|--------|-----|------------------------------------------|
| MSG-ID               | 9(08)            |        |     | ID del mensaje                           |
| MSG-TYPE             | X(02)            |        |  6  | Tipo: AL, NO, PR, CA, AB, SE            |
| MSG-PRIORITY         | X(01)            |        |  3  | Prioridad: H=Alta, M=Media, L=Baja      |
| MSG-CUSTOMER-ID      | X(10)            |        |     | Cliente destino                          |
| MSG-ACCOUNT-NBR      | X(10)            |        |     | Cuenta asociada                          |
| MSG-USER-ID          | X(08)            |        |     | Usuario destino                          |
| MSG-BRANCH           | X(04)            |        |     | Sucursal                                 |
| MSG-CHANNEL          | X(02)            |        |  4  | Canal: SM=SMS, EM=Email, PU=Push, PA=Pantalla |
| MSG-SUBJECT          | X(40)            |        |     | Asunto                                   |
| MSG-BODY             | X(150)           |        |     | Cuerpo del mensaje                       |
| MSG-REFERENCE        | X(20)            |        |     | Referencia                               |
| MSG-DATE-CREATED     | 9(08)            |        |     | Fecha creacion                           |
| MSG-DATE-SENT        | 9(08)            |        |     | Fecha envio                              |
| MSG-DATE-READ        | 9(08)            |        |     | Fecha lectura                            |
| MSG-DATE-EXPIRES     | 9(08)            |        |     | Fecha expiracion                         |
| MSG-STATUS           | X(01)            |        |  5  | Estatus: P=Pendiente, S=Enviado, R=Leido, F=Fallido, C=Cancelado |
| MSG-FILLER           | X(15)            |        |     | Reservado                                |

**88 levels**: 18 en total (6+3+4+5)
**COMP-3**: 0
**Total fields**: 17

---

## 13. RATEFILE — Tabla de Tasas de Interes

**Archivo**: RATEFILE.DAT
**Organizacion**: INDEXED
**Registro**: RATEFILE-RECORD
**Longitud**: 100 caracteres
**Clave primaria**: RAT-CODIGO (X(06))

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              |
|----------------------|------------------|--------|-----|------------------------------------------|
| RAT-CODIGO           | X(06)            |        |     | Codigo de tasa                           |
| RAT-DESCRIPCION      | X(35)            |        |     | Descripcion                              |
| RAT-TIPO             | X(02)            |        |  5  | Tipo: AC, PA, PE, MO, RF                |
| RAT-PRODUCT          | X(04)            |        |     | Producto asociado                        |
| RAT-PLAZO-MIN        | 9(04)            |        |     | Plazo minimo (dias)                      |
| RAT-PLAZO-MAX        | 9(04)            |        |     | Plazo maximo (dias)                      |
| RAT-MONTO-MIN        | 9(11)V99         | SI     |     | Monto minimo                             |
| RAT-MONTO-MAX        | 9(11)V99         | SI     |     | Monto maximo                             |
| RAT-TASA-ANUAL       | 9(03)V9(06)      | SI     |     | Tasa anual                               |
| RAT-TASA-MENSUAL     | 9(03)V9(06)      | SI     |     | Tasa mensual                             |
| RAT-TASA-DIARIA      | 9(03)V9(06)      | SI     |     | Tasa diaria                              |
| RAT-TASA-CAT         | 9(03)V9(06)      | SI     |     | CAT (Costo Anual Total)                  |
| RAT-FECHA-INICIO     | 9(08)            |        |     | Fecha vigencia inicio                    |
| RAT-FECHA-FIN        | 9(08)            |        |     | Fecha vigencia fin                       |
| RAT-STATUS           | X(01)            |        |  3  | Estatus: V=Vigente, H=Historico, P=Pendiente |
| RAT-USUARIO-ALTA     | X(08)            |        |     | Usuario alta                             |
| RAT-FECHA-ALTA       | 9(08)            |        |     | Fecha alta                               |
| RAT-FILLER           | X(10)            |        |     | Reservado                                |

**88 levels**: 8 en total (5+3)
**COMP-3**: 7 campos
**Total fields**: 18

---

## 14. DEPMAST — Maestro de Depositos

**Archivo**: DEPMAST.DAT
**Organizacion**: INDEXED
**Registro**: DEPMAST-RECORD
**Longitud**: 200 caracteres
**Clave primaria**: DEP-NBR (X(10))

| Campo                  | PIC              | COMP-3 | 88s | Descripcion                              |
|------------------------|------------------|--------|-----|------------------------------------------|
| DEP-NBR                | X(10)            |        |     | Numero de deposito                       |
| DEP-CUSTOMER-ID        | X(10)            |        |     | Cliente                                  |
| DEP-TYPE               | X(02)            |        |  3  | Tipo: AH=Ahorro, PL=Plazo, RC=Recurrente|
| DEP-PRODUCT            | X(04)            |        |     | Codigo de producto                       |
| DEP-BALANCE            | 9(13)V99         | SI     |     | Saldo actual                             |
| DEP-BALANCE-MIN        | 9(13)V99         | SI     |     | Saldo minimo requerido                   |
| DEP-BALANCE-PROMEDIO   | 9(13)V99         | SI     |     | Saldo promedio                           |
| DEP-INTEREST-ACCRUED   | 9(09)V99         | SI     |     | Interes devengado                        |
| DEP-INTEREST-RATE      | 9(03)V9(04)      | SI     |     | Tasa de interes                          |
| DEP-DATE-OPEN          | 9(08)            |        |     | Fecha apertura                           |
| DEP-DATE-LAST-INT      | 9(08)            |        |     | Fecha ultimo interes                     |
| DEP-DATE-MATURITY      | 9(08)            |        |     | Fecha vencimiento                        |
| DEP-DATE-LAST-TXN      | 9(08)            |        |     | Fecha ultima transaccion                 |
| DEP-DATE-LAST-STATEMENT| 9(08)            |        |     | Fecha ultimo estado cuenta               |
| DEP-TERM-DAYS          | 9(04)            |        |     | Plazo en dias                            |
| DEP-TERM-MONTHS        | 9(03)            |        |     | Plazo en meses                           |
| DEP-RENEWAL-COUNT      | 9(03)            |        |     | Renovaciones                             |
| DEP-RENEWAL-AUTO       | X(01)            |        |  2  | Renovacion automatica?                   |
| DEP-STATUS             | X(01)            |        |  4  | Estatus: A=Activo, C=Cerrado, F=Congelado, M=Vencido |
| DEP-BRANCH             | X(04)            |        |     | Sucursal                                 |
| DEP-OFFICER            | X(08)            |        |     | Oficial                                  |
| DEP-ACCOUNT-LINKED     | X(10)            |        |     | Cuenta ligada                            |
| DEP-FILLER             | X(20)            |        |     | Reservado                                |

**88 levels**: 9 en total (3+2+4)
**COMP-3**: 7 campos
**Total fields**: 23

---

## 15. TIMEDEP — Certificados de Deposito a Plazo (CDs)

**Archivo**: TIMEDEP.DAT
**Organizacion**: INDEXED
**Registro**: TIMEDEP-RECORD
**Longitud**: 180 caracteres
**Clave primaria**: TD-NBR (X(12))

| Campo                   | PIC              | COMP-3 | 88s | Descripcion                              |
|-------------------------|------------------|--------|-----|------------------------------------------|
| TD-NBR                  | X(12)            |        |     | Numero de CD                             |
| TD-CUSTOMER-ID          | X(10)            |        |     | Cliente                                  |
| TD-CERTIFICATE-NBR      | X(15)            |        |     | Numero de certificado                    |
| TD-TYPE                 | X(02)            |        |  3  | Tipo: FI, RE, CA                        |
| TD-AMOUNT               | 9(13)V99         | SI     |     | Monto                                    |
| TD-AMOUNT-INTEREST      | 9(13)V99         | SI     |     | Interes generado                         |
| TD-AMOUNT-TOTAL         | 9(13)V99         | SI     |     | Monto total (capital + intereses)        |
| TD-AMOUNT-MIN           | 9(13)V99         | SI     |     | Monto minimo                             |
| TD-INTEREST-RATE        | 9(03)V9(06)      | SI     |     | Tasa de interes                          |
| TD-INTEREST-TYPE        | X(01)            |        |  2  | Tipo interes: S=Simple, C=Compuesto      |
| TD-PAYMENT-FREQ         | X(01)            |        |  4  | Frecuencia pago: M, T, S, V             |
| TD-TERM-DAYS            | 9(04)            |        |     | Plazo en dias                            |
| TD-TERM-MONTHS          | 9(03)            |        |     | Plazo en meses                           |
| TD-DATE-ISSUE           | 9(08)            |        |     | Fecha de emision                         |
| TD-DATE-MATURITY        | 9(08)            |        |     | Fecha de vencimiento                     |
| TD-DATE-LAST-INT-PAYMENT| 9(08)            |        |     | Fecha ultimo pago interes                |
| TD-STATUS               | X(01)            |        |  5  | Estatus: A=Activo, M=Vencido, C=Cancelado, R=Renovado, E=Liquidacion Anticipada |
| TD-RENEWAL-COUNT        | 9(02)            |        |     | Renovaciones                             |
| TD-EARLY-PENALTY-RATE   | 9(03)V9(04)      | SI     |     | Penalizacion por cancelacion anticipada  |
| TD-ACCOUNT-DEST         | X(10)            |        |     | Cuenta destino liquidacion               |
| TD-BRANCH               | X(04)            |        |     | Sucursal                                 |
| TD-FILLER               | X(15)            |        |     | Reservado                                |

**88 levels**: 14 en total (3+2+4+5)
**COMP-3**: 8 campos
**Total fields**: 22

---

## 16. GLMASTER — Cuentas Contables (Mayor)

**Archivo**: GLMASTER.DAT
**Organizacion**: INDEXED
**Registro**: GLMASTER-RECORD
**Longitud**: 160 caracteres
**Clave primaria**: GL-ACCOUNT (X(08))

| Campo                   | PIC              | COMP-3 | 88s | Descripcion                              |
|-------------------------|------------------|--------|-----|------------------------------------------|
| GL-ACCOUNT              | X(08)            |        |     | Numero de cuenta contable                |
| GL-DESCRIPTION          | X(40)            |        |     | Descripcion                              |
| GL-TYPE                 | X(01)            |        |  6  | Tipo: 1=Activo, 2=Pasivo, 3=Capital, 4=Ingreso, 5=Gasto, 6=Orden |
| GL-LEVEL                | 9(01)            |        |  3  | Nivel: 1=Mayor, 2=Subcuenta, 3=Auxiliar |
| GL-BALANCE-INICIAL      | S9(13)V99        | SI     |     | Saldo inicial                            |
| GL-BALANCE-CURRENT      | S9(13)V99        | SI     |     | Saldo actual                             |
| GL-BALANCE-DEBIT        | S9(13)V99        | SI     |     | Movimiento debito                        |
| GL-BALANCE-CREDIT       | S9(13)V99        | SI     |     | Movimiento credito                       |
| GL-BALANCE-PERIOD-ANT   | S9(13)V99        | SI     |     | Saldo periodo anterior                   |
| GL-BALANCE-YTD          | S9(13)V99        | SI     |     | Saldo acumulado anual                    |
| GL-CURRENCY             | X(03)            |        |     | Moneda                                   |
| GL-BRANCH               | X(04)            |        |     | Sucursal                                 |
| GL-CENTER-COST          | X(06)            |        |     | Centro de costos                         |
| GL-STATUS               | X(01)            |        |  3  | Estatus: A=Activo, I=Inactivo, B=Bloqueada |
| GL-DATE-LAST-ACTIVITY   | 9(08)            |        |     | Fecha ultima actividad                   |
| GL-DATE-LAST-CIERRE     | 9(08)            |        |     | Fecha ultimo cierre                      |
| GL-USER-LAST-MOD        | X(08)            |        |     | Usuario ultima modificacion              |
| GL-FILLER               | X(20)            |        |     | Reservado                                |

**88 levels**: 12 en total (6+3+3)
**COMP-3**: 7 campos
**Total fields**: 18

---

## 17. AUDITLOG — Pista de Auditoria

**Archivo**: AUDITLOG.DAT
**Organizacion**: INDEXED
**Registro**: AUDITLOG-RECORD
**Longitud**: 200 caracteres
**Clave primaria**: AUD-SEQ (9(10))

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              |
|----------------------|------------------|--------|-----|------------------------------------------|
| AUD-SEQ              | 9(10)            |        |     | Secuencia de auditoria                   |
| AUD-DATE             | 9(08)            |        |     | Fecha del evento                         |
| AUD-TIME             | 9(06)            |        |     | Hora del evento                          |
| AUD-USUARIO          | X(08)            |        |     | Usuario                                  |
| AUD-TERMINAL         | X(08)            |        |     | Terminal                                 |
| AUD-PROGRAMA         | X(08)            |        |     | Programa que genero el evento            |
| AUD-EVENTO           | X(02)            |        |  9  | Evento: AL, BA, CA, CO, IM, RE, AU, CI, BL |
| AUD-ENTITY-TYPE      | X(02)            |        |  9  | Tipo entidad: CL, CT, PR, TJ, US, PA, TA, SU, TR |
| AUD-ENTITY-KEY       | X(20)            |        |     | Clave de la entidad afectada             |
| AUD-CAMPO-ANTERIOR   | X(60)            |        |     | Valor anterior                           |
| AUD-CAMPO-NUEVO      | X(60)            |        |     | Valor nuevo                              |
| AUD-RESULTADO        | X(01)            |        |  3  | Resultado: O=Ok, R=Rechazado, E=Error   |
| AUD-OBSERVACIONES    | X(30)            |        |     | Observaciones                            |
| AUD-FILLER           | X(15)            |        |     | Reservado                                |

**88 levels**: 21 en total (9+9+3)
**COMP-3**: 0
**Total fields**: 14

---

## 18. BATCHCTL — Control de Procesos Batch

**Archivo**: BATCHCTL.DAT
**Organizacion**: INDEXED
**Registro**: BATCHCTL-RECORD
**Longitud**: 150 caracteres
**Clave primaria**: BCH-FECHA-PROCESO (9(08))

| Campo                   | PIC              | COMP-3 | 88s | Descripcion                              |
|-------------------------|------------------|--------|-----|------------------------------------------|
| BCH-FECHA-PROCESO       | 9(08)            |        |     | Fecha de proceso                         |
| BCH-FECHA-CONTABLE      | 9(08)            |        |     | Fecha contable                           |
| BCH-FECHA-PROXIMA       | 9(08)            |        |     | Proxima fecha proceso                    |
| BCH-DIA-HABIL           | X(01)            |        |  2  | Es dia habil?                            |
| BCH-ESTADO-GENERAL      | X(01)            |        |  5  | Estado general: P=Pendiente, E=Ejecutando, C=Completado, R=Error, X=Cancelado |
| BCH-ST-INTERES          | X(01)            |        |     | Estado interes                           |
| BCH-ST-SOBREGIRO        | X(01)            |        |     | Estado sobregiro                         |
| BCH-ST-COMISIONES       | X(01)            |        |     | Estado comisiones                        |
| BCH-ST-GL               | X(01)            |        |     | Estado GL                                |
| BCH-ST-REPORTES         | X(01)            |        |     | Estado reportes                          |
| BCH-ST-CIERRE           | X(01)            |        |     | Estado cierre                            |
| BCH-HORA-INICIO         | 9(06)            |        |     | Hora inicio                              |
| BCH-HORA-FIN            | 9(06)            |        |     | Hora fin                                 |
| BCH-TRX-PROCESADAS      | 9(10)            |        |     | Transacciones procesadas                 |
| BCH-TRX-ERROR           | 9(06)            |        |     | Transacciones con error                  |
| BCH-USUARIO-EJECUTA     | X(08)            |        |     | Usuario que ejecuta                      |
| BCH-OBSERVACIONES       | X(40)            |        |     | Observaciones                            |
| BCH-FILLER              | X(10)            |        |     | Reservado                                |

**88 levels**: 7 en total (2+5)
**COMP-3**: 0
**Total fields**: 18

---

## 19. FEESCHED — Tabla de Comisiones y Tarifas

**Archivo**: FEESCHED.DAT
**Organizacion**: INDEXED
**Registro**: FEESCHED-RECORD
**Longitud**: 120 caracteres
**Clave primaria**: FEE-CODIGO (X(04))

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              |
|----------------------|------------------|--------|-----|------------------------------------------|
| FEE-CODIGO           | X(04)            |        |     | Codigo de comision                       |
| FEE-DESCRIPCION      | X(35)            |        |     | Descripcion                              |
| FEE-TIPO             | X(02)            |        |  3  | Tipo: FI=Fija, PO=Porcentaje, ES=Escalonada |
| FEE-AMOUNT-FIJO      | 9(07)V99         | SI     |     | Monto fijo                               |
| FEE-PORCENTAJE       | 9(03)V9(04)      | SI     |     | Porcentaje                               |
| FEE-MONTO-MIN        | 9(07)V99         | SI     |     | Monto minimo                             |
| FEE-MONTO-MAX        | 9(07)V99         | SI     |     | Monto maximo                             |
| FEE-FRECUENCIA       | X(01)            |        |  6  | Frecuencia: D, M, T, S, A, U            |
| FEE-PRODUCTO         | X(04)            |        |     | Producto asociado                        |
| FEE-TIPO-CUENTA      | X(02)            |        |     | Tipo de cuenta                           |
| FEE-EXENTO-PRIMER-MES| X(01)            |        |  2  | Exento primer mes?                       |
| FEE-STATUS           | X(01)            |        |  2  | Estatus: A=Activo, I=Inactivo            |
| FEE-FECHA-INICIO     | 9(08)            |        |     | Fecha vigencia inicio                    |
| FEE-FECHA-FIN        | 9(08)            |        |     | Fecha vigencia fin                       |
| FEE-USUARIO-MOD      | X(08)            |        |     | Usuario modificacion                     |
| FEE-FILLER           | X(10)            |        |     | Reservado                                |

**88 levels**: 13 en total (3+6+2+2)
**COMP-3**: 4 campos
**Total fields**: 16

---

## 20. CHQBOOK — Chequeras Emitidas

**Archivo**: CHQBOOK.DAT
**Organizacion**: INDEXED
**Registro**: CHQBOOK-RECORD
**Longitud**: 100 caracteres
**Clave primaria**: CHQ-NBR (X(10))

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              |
|----------------------|------------------|--------|-----|------------------------------------------|
| CHQ-NBR              | X(10)            |        |     | Numero de chequera                       |
| CHQ-ACCOUNT-NBR      | X(10)            |        |     | Cuenta asociada                          |
| CHQ-TYPE             | X(01)            |        |  2  | Tipo: N=Nombre, P=Al Portador            |
| CHQ-SERIE            | X(10)            |        |     | Serie de chequera                        |
| CHQ-FROM             | 9(07)            |        |     | Folio inicial                            |
| CHQ-TO               | 9(07)            |        |     | Folio final                              |
| CHQ-NEXT-TO-USE      | 9(07)            |        |     | Siguiente folio a usar                   |
| CHQ-TOTAL-HOJAS      | 9(05)            |        |     | Total de hojas                           |
| CHQ-DATE-ISSUED      | 9(08)            |        |     | Fecha de emision                         |
| CHQ-STATUS           | X(01)            |        |  4  | Estatus: A=Activa, C=Cancelada, R=Reportada, T=Terminada |
| CHQ-BRANCH           | X(04)            |        |     | Sucursal                                 |
| CHQ-USER-ISSUED      | X(08)            |        |     | Usuario que emitio                       |
| CHQ-STOP-COUNT       | 9(03)            |        |     | Suspensiones de pago                     |
| CHQ-FILLER           | X(10)            |        |     | Reservado                                |

**88 levels**: 6 en total (2+4)
**COMP-3**: 0
**Total fields**: 14

---

## 21. ACCTXREF — Cruce Cliente-Cuenta

**Archivo**: ACCTXREF.DAT
**Organizacion**: INDEXED
**Registro**: ACCTXREF-RECORD
**Longitud**: 80 caracteres
**Clave primaria**: AXR-ID (X(20)) = CUS-ID + ACT-NBR

| Campo                | PIC              | COMP-3 | 88s | Descripcion                              |
|----------------------|------------------|--------|-----|------------------------------------------|
| AXR-ID               | X(20)            |        |     | ID compuesto CUS-ID + ACT-NBR            |
| AXR-CUSTOMER-ID      | X(10)            |        |     | ID Cliente                               |
| AXR-ACCOUNT-NBR      | X(10)            |        |     | Numero de cuenta                         |
| AXR-ROL              | X(02)            |        |  6  | Rol: TI=Titular, CO=Cotitular, BE=Beneficiario, AU=Autorizado, FI=Firma, GA=Garante |
| AXR-PORCENTAJE       | 9(03)V99         | SI     |     | Porcentaje de titularidad                |
| AXR-FECHA-ALTA       | 9(08)            |        |     | Fecha alta relacion                      |
| AXR-FECHA-BAJA       | 9(08)            |        |     | Fecha baja relacion                      |
| AXR-STATUS           | X(01)            |        |  3  | Estatus: A=Activo, I=Inactivo, S=Suspendido |
| AXR-USUARIO-ALTA     | X(08)            |        |     | Usuario alta                             |
| AXR-FILLER           | X(17)            |        |     | Reservado                                |

**88 levels**: 9 en total (6+3)
**COMP-3**: 1 campo
**Total fields**: 10

---

## 22. TELLEREC — Registro de Caja / Fondo de Cajero

**Archivo**: TELLEREC.DAT
**Organizacion**: INDEXED
**Registro**: TELLEREC-RECORD
**Longitud**: 150 caracteres
**Clave primaria**: TLR-ID (X(08)) + TLR-DATE (9(08))

| Campo                  | PIC              | COMP-3 | 88s | Descripcion                              |
|------------------------|------------------|--------|-----|------------------------------------------|
| TLR-ID                 | X(08)            |        |     | ID del cajero                            |
| TLR-DATE               | 9(08)            |        |     | Fecha (AAAAMMDD)                         |
| TLR-BRANCH             | X(04)            |        |     | Sucursal                                 |
| TLR-FONDO-INICIAL      | 9(09)V99         | SI     |     | Fondo inicial asignado                   |
| TLR-FONDO-ACTUAL       | 9(09)V99         | SI     |     | Fondo actual                             |
| TLR-FONDO-CIERRE       | 9(09)V99         | SI     |     | Fondo al cierre                          |
| TLR-LIMITE-EFECTIVO    | 9(09)V99         | SI     |     | Limite de efectivo en caja               |
| TLR-TOTAL-DEPOSITOS    | 9(09)V99         | SI     |     | Total depositos                          |
| TLR-TOTAL-RETIROS      | 9(09)V99         | SI     |     | Total retiros                            |
| TLR-TOTAL-TRANSFERENCIAS| 9(09)V99        | SI     |     | Total transferencias                     |
| TLR-TOTAL-PAGOS        | 9(09)V99         | SI     |     | Total pagos                              |
| TLR-TOTAL-CHEQUES      | 9(09)V99         | SI     |     | Total cheques                            |
| TLR-COUNT-DEPOSITOS    | 9(05)            |        |     | Conteo depositos                         |
| TLR-COUNT-RETIROS      | 9(05)            |        |     | Conteo retiros                           |
| TLR-COUNT-TRANSFERENCIAS| 9(05)           |        |     | Conteo transferencias                    |
| TLR-COUNT-PAGOS        | 9(05)            |        |     | Conteo pagos                             |
| TLR-COUNT-CHEQUES      | 9(05)            |        |     | Conteo cheques                           |
| TLR-COUNT-TOTAL        | 9(05)            |        |     | Conteo total transacciones               |
| TLR-HORA-APERTURA      | 9(06)            |        |     | Hora apertura                            |
| TLR-HORA-CIERRE        | 9(06)            |        |     | Hora cierre                              |
| TLR-STATUS             | X(01)            |        |  3  | Estatus: O=Abierto, C=Cerrado, S=Suspendido |
| TLR-DIFERENCIA         | S9(09)V99        | SI     |     | Diferencia de cuadre                     |
| TLR-CUADRADO           | X(01)            |        |  2  | Cuadrado?                                |
| TLR-FILLER             | X(15)            |        |     | Reservado                                |

**88 levels**: 5 en total (3+2)
**COMP-3**: 12 campos
**Total fields**: 25

---

## Resumen General de Archivos

| #  | Archivo       | Organizacion | Longitud | Clave Primaria        | Campos | COMP-3 | 88s |
|----|---------------|-------------|----------|----------------------|--------|--------|-----|
| 1  | CUSTOMER      | INDEXED     | 300      | CUS-ID (X10)         | 38     | 1      | 16  |
| 2  | ACCOUNT       | INDEXED     | 200      | ACT-NBR (X10)        | 32     | 14     | 12  |
| 3  | TRANLOG       | INDEXED     | 150      | TRN-SEQ (9(10))      | 25     | 7      | 18  |
| 4  | CARD          | INDEXED     | 250      | CRD-NBR (X16)        | 34     | 13     | 19  |
| 5  | LOANMAST      | INDEXED     | 350      | LON-NBR (X10)        | 48     | 18     | 28  |
| 6  | LOANAPPL      | INDEXED     | 280      | LAP-APPL-ID (X10)    | 27     | 10     | 16  |
| 7  | BRANCH        | INDEXED     | 200      | BRH-CODE (X04)       | 27     | 2      | 3   |
| 8  | USERPROF      | INDEXED     | 180      | USR-ID (X08)         | 26     | 0      | 15  |
| 9  | SECURITY      | INDEXED     | 120      | SEC-SEQ (9(10))      | 11     | 0      | 12  |
| 10 | PARAMSTR      | INDEXED     | 150      | PAR-CODIGO (X08)     | 11     | 1      | 12  |
| 11 | CURRENCY      | INDEXED     | 80       | CUR-CODIGO (X03)     | 12     | 3      | 8   |
| 12 | MESSAGES      | INDEXED     | 300      | MSG-ID (9(08))       | 17     | 0      | 18  |
| 13 | RATEFILE      | INDEXED     | 100      | RAT-CODIGO (X06)     | 18     | 7      | 8   |
| 14 | DEPMAST       | INDEXED     | 200      | DEP-NBR (X10)        | 23     | 7      | 9   |
| 15 | TIMEDEP       | INDEXED     | 180      | TD-NBR (X12)         | 22     | 8      | 14  |
| 16 | GLMASTER      | INDEXED     | 160      | GL-ACCOUNT (X08)     | 18     | 7      | 12  |
| 17 | AUDITLOG      | INDEXED     | 200      | AUD-SEQ (9(10))      | 14     | 0      | 21  |
| 18 | BATCHCTL      | INDEXED     | 150      | BCH-FECHA-PROCESO    | 18     | 0      | 7   |
| 19 | FEESCHED      | INDEXED     | 120      | FEE-CODIGO (X04)     | 16     | 4      | 13  |
| 20 | CHQBOOK       | INDEXED     | 100      | CHQ-NBR (X10)        | 14     | 0      | 6   |
| 21 | ACCTXREF      | INDEXED     | 80       | AXR-ID (X20)         | 10     | 1      | 9   |
| 22 | TELLEREC      | INDEXED     | 150      | TLR-ID + TLR-DATE    | 25     | 12     | 5   |

**Totales**: 22 archivos, ~500 campos, ~115 COMP-3, ~281 niveles 88
