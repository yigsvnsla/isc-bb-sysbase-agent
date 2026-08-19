# Casos de Prueba — Sistema Bancario COBOL

## Convenciones

- **TC-XXX**: ID unico del caso de prueba
- **Precondicion**: Estado del sistema antes de ejecutar
- **Pasos**: Secuencia de acciones del operador
- **Resultado Esperado**: Comportamiento esperado del sistema
- **Datos**: Valores especificos utilizados

---

## 1. Casos Positivos (Happy Path)

### TC-001: Login Exitoso

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Security                                 |
| Escenario        | Usuario valido, password correcto        |
| Programa         | BNK0001 (LOGIN)                          |

**Precondicion**: Usuario COBOL01 existe en USERPROF, status 'A', password no expirado.

**Pasos**:
1. Iniciar COMMENU (automaticamente CALL SECSGN00)
2. Ingresar USUARIO = "COBOL01"
3. Ingresar CONTRASENA = "PASS1234"
4. Presionar ENTER

**Resultado Esperado**:
- Validacion exitosa
- Login registrado en SECURITY (EVENT-TYPE = 'LI', RESULT = 'S')
- Pantalla de sesion con nombre de usuario y sucursal
- Acceso al menu principal COMMENU/BNK0010
- Bienvenida: "ACCESO AUTORIZADO - BIENVENIDO"

---

### TC-002: Alta de Cliente (Persona Fisica)

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Customer                                 |
| Escenario        | Creacion de cliente persona fisica       |
| Programa         | CUSMNT00                                 |

**Precondicion**: Usuario autenticado en CUSMNU00.

**Pasos**:
1. Presionar PF3 en CUSMNU00 (Alta de Cliente)
2. Ingresar Tipo Persona = "PF"
3. Ingresar Nombre = "JUAN PEREZ LOPEZ"
4. Ingresar RFC = "PELJ850101XXX"
5. Ingresar CURP = "PELJ850101HDFRRN00"
6. Ingresar Fecha Nacimiento = "19850101"
7. Ingresar Sexo = "M"
8. Ingresar Nacionalidad = "MEX"
9. Ingresar Ingreso Mensual = 25000.00
10. Ingresar Telefono = "5555555555"
11. Ingresar Email = "juan@email.com"
12. Presionar ENTER

**Resultado Esperado**:
- Validacion de RFC y CURP exitosa
- CUSTOMER-RECORD creado con CUS-ID generado
- Segmento asignado automaticamente: '02' (MEDIO)
- Riesgo categoria: 'A' (por default)
- Status: 'A' (Activo)
- Auditoria registrada en AUDITLOG
- Mensaje: "CLIENTE CREADO EXITOSAMENTE"
- Retorno a CUSMNU00

---

### TC-003: Apertura de Cuenta de Cheques

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Account                                  |
| Escenario        | Apertura de cuenta de cheques            |
| Programa         | ACTOPN00                                 |

**Precondicion**: Cliente existe (CUS-ID = "CUS0000001").

**Pasos**:
1. Presionar PF2 en ACTMNU00 (Apertura de Cuenta)
2. Presionar PF1 para buscar cliente
3. Seleccionar cliente "CUS0000001"
4. Ingresar Tipo Cuenta = "CH" (Cheques)
5. Ingresar Moneda = "MXN"
6. Ingresar Deposito Inicial = 5000.00
7. Seleccionar Solicitar Chequera = "S"
8. Presionar ENTER

**Resultado Esperado**:
- Cuenta creada con ACT-NBR generado
- Deposito inicial registrado en balance
- Relacion ACCTXREF creada (cliente-cuenta)
- Chequera CHQBOOK creada si se solicito
- Auditoria registrada en AUDITLOG
- Mensaje: "CUENTA CREADA EXITOSAMENTE"

---

### TC-004: Deposito en Efectivo

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Teller                                   |
| Escenario        | Deposito en efectivo                     |
| Programa         | TLRDEP00                                 |

**Precondicion**: Cajero ha abierto sesion (TLRSGN00). Cuenta "ACT0000001" existe con saldo 5000.00.

**Pasos**:
1. Presionar PF2 en TLRMNU00 (Deposito)
2. Ingresar Cuenta destino = "ACT0000001"
3. Ingresar Monto = 3000.00
4. Presionar ENTER

**Resultado Esperado**:
- Saldo de cuenta incrementado: 5000.00 + 3000.00 = 8000.00
- TRANLOG registrado (TRN-TYPE = 'DEP', TRN-AMOUNT = 3000.00)
- TELLEREC actualizado (TLR-TOTAL-DEPOSITOS = 3000.00)
- Auditoria registrada en AUDITLOG
- Mensaje: "DEPOSITO EXITOSO"

---

### TC-005: Retiro en Efectivo

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Teller                                   |
| Escenario        | Retiro en efectivo                       |
| Programa         | TLRWTH00                                 |

**Precondicion**: Cajero con sesion activa. Cuenta "ACT0000001" con saldo 8000.00.

**Pasos**:
1. Presionar PF3 en TLRMNU00 (Retiro)
2. Ingresar Cuenta = "ACT0000001"
3. Ingresar Monto = 2000.00
4. Presionar ENTER

**Resultado Esperado**:
- Saldo de cuenta decrementado: 8000.00 - 2000.00 = 6000.00
- TRANLOG registrado (TRN-TYPE = 'RET')
- TELLEREC actualizado (TLR-TOTAL-RETIROS = 2000.00)
- Efectivo entregado al cliente
- Mensaje: "RETIRO EXITOSO"

---

### TC-006: Transferencia entre Cuentas

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Teller                                   |
| Escenario        | Transferencia entre cuentas propias      |
| Programa         | TLRTRF00                                 |

**Precondicion**: Cajero activo. Cuenta origen "ACT0000001" saldo 6000.00.
Cuenta destino "ACT0000002" saldo 3000.00.

**Pasos**:
1. Presionar PF4 en TLRMNU00 (Transferencia)
2. Ingresar Cuenta Origen = "ACT0000001"
3. Ingresar Cuenta Destino = "ACT0000002"
4. Ingresar Monto = 1500.00
5. Presionar ENTER

**Resultado Esperado**:
- Saldo origen: 6000.00 - 1500.00 = 4500.00
- Saldo destino: 3000.00 + 1500.00 = 4500.00
- TRANLOG registrado (TRN-TYPE = 'TRF')
- TELLEREC actualizado
- Mensaje: "TRANSFERENCIA EXITOSA"

---

### TC-007: Solicitud de Prestamo

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Loans                                    |
| Escenario        | Solicitud de prestamo personal           |
| Programa         | LONAPL00                                 |

**Precondicion**: Cliente "CUS0000001" existe. Tasa vigente en RATEFILE.

**Pasos**:
1. Presionar PF2 en LONMNU00 (Solicitud)
2. Buscar cliente (PF1) = "CUS0000001"
3. Ingresar Tipo = "PL" (Personal)
4. Ingresar Monto Solicitado = 100000.00
5. Ingresar Plazo = 12 meses
6. Ingresar Ingreso Mensual = 35000.00
7. Ingresar Egresos Mensuales = 15000.00
8. Presionar ENTER

**Resultado Esperado**:
- Scoring calculado: ratio 15000/35000 = 42.8%
- Score asignado (> 600, aprobacion automatica por monto < 100k)
- LOANAPPL creado (LAP-STATUS = 'R' = En Revision, o 'A' = Aprobado)
- Auditoria registrada
- Mensaje con puntaje y resultado

---

### TC-008: Aprobacion de Prestamo

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Loans                                    |
| Escenario        | Aprobacion de prestamo                   |
| Programa         | LONAPV00                                 |

**Precondicion**: Solicitud LAP-APPL-ID = "LAP0000001" existe, status 'R'.

**Pasos**:
1. Presionar PF3 en LONMNU00 (Aprobacion)
2. Ingresar ID Solicitud = "LAP0000001"
3. Verificar datos del solicitante y scoring
4. Ingresar Resultado = "A" (Aprobar)
5. Presionar ENTER

**Resultado Esperado**:
- LOANAPPL actualizado: LAP-STATUS = 'A', LAP-USUARIO-APRUEBA = usuario actual
- Fecha de aprobacion registrada
- Auditoria en AUDITLOG
- Mensaje: "PRESTAMO APROBADO"

---

### TC-009: Desembolso de Prestamo

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Loans                                    |
| Escenario        | Desembolso a cuenta del cliente          |
| Programa         | LONDIS00                                 |

**Precondicion**: Solicitud "LAP0000001" aprobada (status 'A').

**Pasos**:
1. Presionar PF4 en LONMNU00 (Desembolso)
2. Ingresar ID Solicitud = "LAP0000001"
3. Ingresar Cuenta Desembolso = "ACT0000001"
4. Presionar ENTER

**Resultado Esperado**:
- LOANAPPL eliminado (DELETE)
- LOANMAST creado (LON-STATUS = 'A')
- Transferencia a cuenta del cliente (CALL TLRTRF00)
- Saldo de cuenta incrementado
- Auditoria en AUDITLOG
- Mensaje: "DESEMBOLSO EXITOSO"

---

### TC-010: Pago de Prestamo

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Loans                                    |
| Escenario        | Pago de cuota mensual                    |
| Programa         | LONPYM00                                 |

**Precondicion**: Prestamo "LON0000001" activo, cuota mensual 9000.00.

**Pasos**:
1. Presionar PF5 en LONMNU00 (Pago)
2. Ingresar Prestamo = "LON0000001"
3. Confirmar monto de cuota calculado (CALL LONAMR00)
4. Presionar ENTER

**Resultado Esperado**:
- LOANMAST actualizado: LON-BALANCE reducido
- LON-PAYMENTS-MADE incrementado
- TRANLOG registrado (TRN-TYPE = 'PAG')
- Si ultimo pago: LON-STATUS = 'P'
- Auditoria en AUDITLOG

---

### TC-011: Bloqueo de Tarjeta por Robo

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Cards                                    |
| Escenario        | Reporte de tarjeta robada                |
| Programa         | CRDBLK00 (asumido)                       |

**Precondicion**: Tarjeta "4000000000000001" activa.

**Pasos**:
1. Ingresar Numero Tarjeta = "4000000000000001"
2. Seleccionar Motivo = "ROBO"
3. Confirmar bloqueo
4. Presionar ENTER

**Resultado Esperado**:
- CRD-STATUS = 'S' (Stolen)
- CRD-REASON-LAST-CHANGE = "ROBO REPORTADO"
- Tarjeta no autoriza transacciones
- Auditoria en AUDITLOG
- Mensaje: "TARJETA BLOQUEADA POR ROBO"

---

## 2. Casos Negativos (Error Handling)

### TC-101: Login con Password Incorrecto

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Security                                 |
| Escenario        | Password erroneo, menos de 3 intentos   |
| Programa         | BNK0001                                  |

**Precondicion**: Usuario "COBOL01" existe, password real = "PASS1234".

**Pasos**:
1. Ingresar USUARIO = "COBOL01"
2. Ingresar CONTRASENA = "WRONG567"
3. Presionar ENTER

**Resultado Esperado**:
- Mensaje: "CONTRASENA INCORRECTA - INTENTO 1 DE 3"
- Intento fallido registrado en USERPROF (USR-PASSWORD-TRIES = 1)
- Evento SECURITY registrado (EVENT-TYPE = 'FA')
- Retorno a pantalla de login

---

### TC-102: Bloqueo por Intentos Excedidos

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Security                                 |
| Escenario        | 3 intentos fallidos consecutivos        |
| Programa         | BNK0001                                  |

**Precondicion**: Usuario "COBOL02" con 2 intentos fallidos previos.

**Pasos**:
1. Repetir login incorrecto 1 vez mas
2. Intentar con password incorrecto

**Resultado Esperado**:
- Tercer intento fallido
- Mensaje: "USUARIO BLOQUEADO - CONTACTE AL ADMINISTRADOR"
- USR-PASSWORD-BLOCKED = 'Y'
- Evento SECURITY (EVENT-TYPE = 'LC')
- No se permite acceso aunque se intente password correcto

---

### TC-103: Fondos Insuficientes para Retiro

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Teller                                   |
| Escenario        | Retiro mayor al saldo disponible         |
| Programa         | TLRWTH00                                 |

**Precondicion**: Cuenta "ACT0000001" saldo 1000.00. No hay sobregiro.

**Pasos**:
1. Ingresar Cuenta = "ACT0000001"
2. Ingresar Monto = 5000.00
3. Presionar ENTER

**Resultado Esperado**:
- CALL ACTBAL00 detecta saldo insuficiente
- Mensaje: "FONDOS INSUFICIENTES"
- Transaccion NO registrada en TRANLOG
- Saldo no modificado
- Retorno a TLRMNU00

---

### TC-104: Operacion en Cuenta Congelada

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Teller                                   |
| Escenario        | Deposito en cuenta congelada             |
| Programa         | TLRDEP00                                 |

**Precondicion**: Cuenta "ACT0000003" status 'F' (Frozen).

**Pasos**:
1. Ingresar Cuenta = "ACT0000003"
2. Ingresar Monto = 1000.00
3. Presionar ENTER

**Resultado Esperado**:
- CALL ACTINQ00 retorna cuenta congelada
- Mensaje: "CUENTA CONGELADA - NO PERMITE OPERACIONES"
- Transaccion rechazada
- Retorno a TLRMNU00

---

### TC-105: Cliente Inexistente

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Customer                                 |
| Escenario        | Consulta de cliente que no existe        |
| Programa         | CUSINQ00                                 |

**Precondicion**: Cliente "CUS9999999" no existe en CUSTOMER.

**Pasos**:
1. Presionar PF2 en CUSMNU00 (Consulta)
2. Ingresar CUS-ID = "CUS9999999"
3. Presionar ENTER

**Resultado Esperado**:
- READ CUSTOMER con INVALID KEY
- Mensaje: "CLIENTE NO ENCONTRADO"
- Retorno a CUSMNU00

---

### TC-106: Tarjeta Expirada

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Cards                                    |
| Escenario        | Transaccion con tarjeta vencida          |
| Programa         | (programa de autorizacion)               |

**Precondicion**: Tarjeta "4000000000000002" CRD-DATE-EXPIRY < fecha actual.

**Pasos**:
1. Ingresar Tarjeta = "4000000000000002"
2. Ingresar Monto = 500.00
3. Presionar ENTER

**Resultado Esperado**:
- Validacion de fecha expiracion
- CRD-STATUS = 'E' (Expired)
- Mensaje: "TARJETA EXPIRADA - RENUEVE SU PLASTICO"
- Transaccion rechazada

---

### TC-107: Limite de Sobregiro Excedido

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Account                                  |
| Escenario        | Retiro excede saldo + limite sobregiro   |
| Programa         | ACTBAL00 / TLRWTH00                      |

**Precondicion**: Cuenta "ACT0000004" saldo 0, limite sobregiro 5000.00.

**Pasos**:
1. Intentar retiro de 10000.00
2. Presionar ENTER

**Resultado Esperado**:
- ACT-BALANCE-DISPONIBLE = 0 + 5000 = 5000.00
- Monto 10000 > 5000
- Mensaje: "SOBREGIRO MAXIMO EXCEDIDO"
- Transaccion rechazada

---

### TC-108: Password No Cumple Longitud Minima

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Security                                 |
| Escenario        | Cambio password con < 6 caracteres       |
| Programa         | SECPWD00 / BNK0001                        |

**Precondicion**: Usuario en pantalla de cambio de password.

**Pasos**:
1. Ingresar Password Nuevo = "AB12"
2. Ingresar Confirmacion = "AB12"
3. Presionar ENTER

**Resultado Esperado**:
- Validacion: password menor a 6 caracteres
- Mensaje: "CONTRASENA DEBE TENER AL MENOS 6 CARACTERES"
- Password no actualizado
- Retorno a pantalla de cambio

---

## 3. Casos de Borde (Edge Cases)

### TC-201: Transaccion con Monto Cero

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Teller                                   |
| Escenario        | Deposito de $0                           |
| Programa         | TLRDEP00                                 |

**Precondicion**: Cajero con sesion activa.

**Pasos**:
1. Ingresar Cuenta = "ACT0000001"
2. Ingresar Monto = 0.00
3. Presionar ENTER

**Resultado Esperado**:
- Validacion: monto debe ser > 0
- Mensaje: "MONTO DEBE SER MAYOR A CERO"
- Transaccion no procesada

---

### TC-202: Operacion en Cuenta Cerrada

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Teller                                   |
| Escenario        | Deposito en cuenta cerrada               |
| Programa         | TLRDEP00                                 |

**Precondicion**: Cuenta "ACT0000005" status 'C' (Closed).

**Pasos**:
1. Ingresar Cuenta = "ACT0000005"
2. Ingresar Monto = 100.00
3. Presionar ENTER

**Resultado Esperado**:
- Mensaje: "CUENTA CERRADA - NO ACEPTA OPERACIONES"
- Transaccion rechazada

---

### TC-203: Transaccion en Cuenta Dormant

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Teller                                   |
| Escenario        | Retiro de cuenta dormant                 |
| Programa         | TLRWTH00                                 |

**Precondicion**: Cuenta "ACT0000006" status 'D' (Dormant), 8 meses sin actividad.

**Pasos**:
1. Ingresar Cuenta = "ACT0000006"
2. Ingresar Monto = 500.00
3. Presionar ENTER

**Resultado Esperado**:
- Mensaje: "CUENTA DORMANT - SOLO DEPOSITOS PERMITIDOS"
- Retiro rechazado
- Depositos si estan permitidos en cuentas dormant

---

### TC-204: Plazo Maximo de Prestamo

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Loans                                    |
| Escenario        | Solicitud con plazo maximo (360 meses)   |
| Programa         | LONAPL00                                 |

**Precondicion**: Cliente existe.

**Pasos**:
1. Ingresar Tipo = "HI" (Hipotecario)
2. Ingresar Monto = 2000000.00
3. Ingresar Plazo = 360 meses (30 anos)
4. Ingresar Ingresos = 80000.00
5. Presionar ENTER

**Resultado Esperado**:
- Plazo dentro del maximo permitido por producto
- Tabla amortizacion con 360 cuotas (OCCURS 360)
- Scoring calculado
- Solicitud registrada

---

### TC-205: Renovacion de Tarjeta por Vencimiento

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Cards                                    |
| Escenario        | Renovacion automatica 60 dias antes      |
| Programa         | CRDREN00 (asumido)                       |

**Precondicion**: Tarjeta "4000000000000003" vence en 45 dias.

**Pasos**:
1. Ejecutar proceso de renovacion batch
2. Sistema detecta tarjetas proximas a vencer

**Resultado Esperado**:
- Nueva tarjeta generada con mismo PAN
- Nuevo CRD-DATE-EXPIRY = fecha actual + 3 anos
- Nuevo CVV generado
- CRD-ISSUE-COUNT incrementado
- CRD-STATUS de tarjeta antigua = 'E'
- Auditoria registrada

---

### TC-206: Cierre de Caja con Diferencia

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Teller                                   |
| Escenario        | Cierre de caja con diferencia de $30    |
| Programa         | TLRSMG00                                 |

**Precondicion**: Cajero con fondo inicial 50000.00. Depositos=15000.00, Retiros=8000.00.
Fondo fisico contado = 57030.00 (diferencia -30.00).

**Pasos**:
1. Presionar PF7 (Resumen/Cierre)
2. Sistema muestra totales
3. Ingresar Fondo Fisico = 57030.00
4. Presionar ENTER

**Resultado Esperado**:
- Diferencia calculada = -30.00
- Diferencia dentro de tolerancia ($50)
- TLR-DIFERENCIA = -30.00
- TLR-CUADRADO = 'N'
- Cierre registrado (TLR-STATUS = 'C')
- Reporte RPTTLR00 generado
- Diferencia registrada pero no requiere accion

---

### TC-207: Prestamo Castigado (Charge-off)

| Campo            | Valor                                    |
|------------------|------------------------------------------|
| Modulo           | Loans                                    |
| Escenario        | Prestamo con 190+ dias de mora          |
| Programa         | LONDEL00 / BCHMNT00                     |

**Precondicion**: Prestamo "LON0000002" con 190 dias sin pago.

**Pasos**:
1. Ejecutar proceso de mora/castigo
2. Sistema detecta prestamo > 180 dias

**Resultado Esperado**:
- LON-STATUS = 'C' (Charged-off)
- LON-CLASSIFICATION = '4' (Loss)
- Saldo transferido a cuentas de orden
- Provision al 100%
- Auditoria registrada
- Notificacion a credit bureau (simulado)

---

## Resumen de Casos

| Tipo      | Cantidad | IDs                               |
|-----------|----------|-----------------------------------|
| Positivos | 11       | TC-001 a TC-011                   |
| Negativos | 8        | TC-101 a TC-108                   |
| Borde     | 7        | TC-201 a TC-207                   |
| **Total** | **26**   |                                   |
