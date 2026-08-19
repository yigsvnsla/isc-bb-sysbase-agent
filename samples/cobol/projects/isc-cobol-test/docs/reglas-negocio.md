# Reglas de Negocio — Sistema Bancario COBOL

## 1. Reglas de Cliente (Customer)

### CUS-01: Formato RFC
El RFC (Registro Federal de Contribuyentes) debe cumplir:
- Persona fisica: 13 caracteres, formato `XXXX000101XXX`
  - 4 letras (apellido paterno + materno + inicial nombre)
  - 6 digitos (fecha nacimiento AAMMDD)
  - 3 caracteres (homoclave)
- Persona moral: 12 caracteres, formato `XXX000101XXX`
  - 3 letras (iniciales razon social)
  - 6 digitos (fecha constitucion AAMMDD)
  - 3 caracteres (homoclave)
- Validacion de digito verificador contra el SAT (simulado)
- No se permiten RFC duplicados en el sistema
- RFC generico `XAXX010101000` permitido solo para extranjeros

### CUS-02: Validacion CURP
La CURP (Clave Unica de Registro de Poblacion) debe cumplir:
- 18 caracteres alfanumericos
- Formato: `AAAA000101HBCVRS00`
  - 4 letras (apellido paterno + materno + inicial nombre)
  - 6 digitos (fecha nacimiento AAMMDD)
  - 1 letra (sexo: H/M)
  - 2 letras (entidad federativa)
  - 3 letras (consonantes internas)
  - 2 caracteres (homoclave + digito)
- Validacion de los 18 caracteres contra algoritmo oficial
- Solo obligatoria para personas fisicas mexicanas
- Extranjeros: campo opcional, puede quedar vacio

### CUS-03: Segmento de Cliente
Asignacion automatica basada en ingreso mensual:
- `01` BASICO: Ingreso < $10,000 MXN
- `02` MEDIO: Ingreso $10,000 - $29,999 MXN
- `03` ALTO: Ingreso $30,000 - $99,999 MXN
- `04` PREMIER: Ingreso $100,000 - $499,999 MXN
- `05` EMPRESARIAL: Ingreso >= $500,000 MXN
- El segmento puede ser modificado manualmente por un supervisor
- El segmento afecta limites de productos, tasas preferenciales y comisiones

### CUS-04: Clasificacion de Riesgo
La categoria de riesgo se asigna segun:
- `A` (Bajo): historial crediticio limpio, antiguedad > 2 anos
- `B` (Medio): algun retraso < 30 dias, antiguedad > 1 ano
- `C` (Alto): retrasos 31-60 dias, sobregiros frecuentes
- `D` (Maximo): mora > 60 dias, castigos previos, demanda judicial
- La clasificacion se recalcula cada mes durante el batch nocturno
- Un cliente con categoria `D` no puede obtener nuevos productos

### CUS-05: Cambios de Estatus
Transiciones permitidas de estatus de cliente:
- `A` (Activo) → `I` (Inactivo): solicitud del cliente, 0 productos activos
- `A` (Activo) → `B` (Bloqueado): fraude, orden judicial, riesgo alto
- `A` (Activo) → `F` (Fallecido): acta de defuncion oficial
- `I` (Inactivo) → `A` (Activo): reactivacion con nueva operacion
- `B` (Bloqueado) → `A` (Activo): solo por supervisor/autoridad
- `F` (Fallecido) → irrevocable, cuenta bloqueada permanentemente

---

## 2. Reglas de Cuenta (Account)

### ACT-01: Deposito Minimo de Apertura
Monto minimo para apertura segun tipo de cuenta:
- `CH` (Cheques): $1,000 MXN / $100 USD
- `AH` (Ahorro): $500 MXN / $50 USD
- `NO` (Nomina): $0 (apertura automatica por empresa)
- `IN` (Inversion): $10,000 MXN / $1,000 USD
- El deposito inicial debe ser en efectivo o transferencia
- No se permite abrir cuenta con cheque de terceros

### ACT-02: Limites de Sobregiro
El sobregiro esta limitado por tipo de cuenta y categoria de cliente:
- `CH` (Cheques): hasta 1 vez el saldo promedio mensual, max $50,000
- `AH` (Ahorro): no permite sobregiro
- `NO` (Nomina): hasta $5,000, solo si tiene nomina activa
- `IN` (Inversion): no aplica
- La tasa de sobregiro se calcula como Tasa de Referencia + 15% puntos
- El sobregiro debe liquidarse en maximo 30 dias

### ACT-03: Calculo de Interes (Saldo Diario)
El interes sobre cuentas de ahorro se calcula:
- Base: saldo al cierre de cada dia (inclusive sabados y domingos)
- Formula: `Interes_Diario = (Saldo_Dia * Tasa_Anual) / 360`
- Acumulacion diaria en ACT-INTEREST-ACCRUED
- Pago de intereses el primer dia habil de cada mes
- Registro contable: DB Gasto Interes / CR Interes por Pagar
- Tasa preferencial para saldos > $100,000

### ACT-04: Reglas de Dormancia
Una cuenta se considera "dormant" (inactiva) si:
- No tiene movimientos del titular en 6 meses (180 dias)
- Los movimientos automaticos (intereses, comisiones) no cuentan
- El estado `D` (Dormant) se asigna durante el batch nocturno
- Una cuenta dormant no permite retiros ni transferencias
- Solo depositos estan permitidos en cuentas dormant
- Reactivacion: el titular debe realizar una transaccion presencial
- Despues de 3 anos dormant, los fondos se transfieren a Cuentas por Cobrar

### ACT-05: Cierre de Cuenta
Requisitos para cierre:
- Saldo debe ser cero (se puede transferir a otra cuenta)
- No debe tener cheques en circulacion
- No debe tener tarjetas asociadas vigentes
- No debe tener prestamos activos como cuenta de cargo
- El cierre es irreversible
- Periodo de retencion de registros: 10 anos fiscales

---

## 3. Reglas de Caja / Ventanilla (Teller)

### TLR-01: Limite de Fondo de Caja
El fondo de efectivo asignado a cada cajero:
- Limite por defecto: $200,000 MXN / $20,000 USD
- Limite configurable por sucursal en PARAMSTR
- El cajero no puede exceder el limite en ningun momento
- Si el fondo excede el limite, debe realizar un "corte parcial"
- Transferencia de excedente a boveda central

### TLR-02: Tolerancia de Diferencias
Diferencia maxima permitida al cierre de caja:
- Limite: $50 MXN (o su equivalente en USD)
- Diferencias <= $50: registradas, no requieren accion
- Diferencias > $50 y <= $500: reporte inmediato al supervisor
- Diferencias > $500: investigacion por auditoria interna
- Diferencias recurrentes (3 en 30 dias): suspension del cajero

### TLR-03: Obligacion de Sign-On
- El cajero debe iniciar sesion en caja (TLRSGN00) antes de operar
- No se permite ninguna transaccion sin apertura de caja
- Cada cajero tiene su propio ID y registro (TLR-ID)
- Solo un cajero por registro por dia
- La apertura requiere registrar el monto del fondo inicial

### TLR-04: Cierre Diario Obligatorio
- Toda caja debe cerrarse al final del dia
- El cierre implica cuadrar el fondo fisico contra el registro
- Si el cierre no se realiza, el sistema reporta excepcion
- El batch nocturno no inicia si hay cajas abiertas
- El cierre genera un reporte de cuadre (RPTTLR00)

---

## 4. Reglas de Prestamos (Loans)

### LON-01: Scoring por Relacion Ingreso/Deuda
Modelo de scoring interno:
- Ratio = (Total Egresos Mensuales + Pago Estimado Cuota) / Ingreso Mensual
- Si ratio < 30%: puntaje alto, aprobacion automatica (< $100,000)
- Si ratio 30-45%: puntaje medio, requiere revision
- Si ratio > 45%: rechazo automatico
- Puntaje adicional por: antiguedad laboral, garantia, historial
- Score minimo para aprobar: 600 puntos (de 1000)

### LON-02: Niveles de Aprobacion
Monto de prestamo determina nivel de autorizacion:
- Hasta $50,000: oficial de credito (unica firma)
- $50,001 - $250,000: gerente sucursal
- $250,001 - $1,000,000: comite de credito (doble firma)
- Mas de $1,000,000: direccion regional + comite
- Prestamos hipotecarios siempre requieren doble firma
- Excepciones requieren autorizacion del director general

### LON-03: Tipos de Amortizacion
El sistema soporta tres metodos:
- **Francesa** (Cuota Fija): cuota constante, mayor interes al inicio
  - Formula: `C = P * [i(1+i)^n] / [(1+i)^n - 1]`
  - Donde P=principal, i=tasa periodica, n=numero periodos
- **Alemana**: amortizacion constante, cuota decreciente
  - Cada periodo: amortizacion = P/n, interes sobre saldo
- **Americana**: solo pago de intereses durante el plazo, capital al final
  - No disponible para prestamos > 5 anos

### LON-04: Buckets de Mora
Clasificacion de prestamos por dias de vencido:
- `1-30` dias: temprana, notificacion automatica
- `31-60` dias: media, llamada telefono + carta
- `61-90` dias: alta, visita domiciliaria, reporte burb
- `91-180` dias: cobranza judicial/prejudicial
- `180+` dias: castigo (charge-off), provision 100%

### LON-05: Castigo (Charge-off)
Reglas para castigo de prestamo:
- Automatico a los 180 dias sin pago
- El prestamo se lleva a cuentas de orden
- Se cancela el registro en LOANMAST (status='C')
- Provision debe estar constituida al 100%
- El castigo no libera la obligacion legal del cliente
- Los intereses moratorios se registran en cuentas de orden

---

## 5. Reglas de Tarjetas (Cards)

### CRD-01: Limite de Intentos PIN
- Maximo 3 intentos fallidos de PIN (CRD-PIN-TRIES)
- Al tercer intento: CRD-PIN-BLOCKED = 'Y'
- Tarjeta bloqueada para transacciones ATM/POS
- Desbloqueo: solo presencial en sucursal
- El desbloqueo requiere verificacion de identidad
- Opcional: reimpresion de tarjeta con nuevo PIN

### CRD-02: Vigencia de Tarjeta
- Periodo de vigencia: 3 anos desde fecha de emision
- Formato: MM/AA en el plastico
- Renovacion automatica 60 dias antes del vencimiento
- La renovacion genera nuevo CRD-NBR (mismo PAN, nuevo CVV)
- Tarjetas vencidas: status 'E', no autorizan transacciones
- Renovacion a domicilio o recogida en sucursal

### CRD-03: Limite de Disposicion de Efectivo
El adelanto de efectivo (cash advance) esta limitado:
- Maximo: 50% del limite de credito total
- Ejemplo: limite $20,000 → cash advance max $10,000
- Afecta immediatamente el saldo disponible
- Tasa de interes para cash advance: 5% superior a tasa normal
- No tiene periodo de gracia (intereses desde el primer dia)

### CRD-04: Comision por Transaccion Extranjera
- Tasa: 2.5% sobre el monto de la transaccion
- Aplica a transacciones en moneda diferente a la de la cuenta
- Incluye compras en linea en sitios extranjeros
- No aplica a retiros en ATM en el extranjero (comision separada)
- La comision se registra como transaccion separada (TRN-TYPE = 'COM')

---

## 6. Reglas de Seguridad (Security)

### SEC-01: Vigencia de Password
- El password expira cada 90 dias
- Recordatorio: 15 dias antes de la expiracion
- Al expirar: cambio obligatorio en el siguiente login
- El usuario no puede usar sus ultimos 5 passwords
- Password minimo: 6 caracteres
- Debe contener: al menos 1 letra mayuscula, 1 minuscula, 1 digito

### SEC-02: Limite de Intentos de Login
- Maximo 3 intentos fallidos de login
- Intentos contados en USR-PASSWORD-TRIES
- Al tercer intento: USR-PASSWORD-BLOCKED = 'Y'
- El desbloqueo solo puede hacerlo un administrador
- Los intentos fallidos se registran en SECURITY (EVENT-TYPE = 'FA')

### SEC-03: Timeout de Sesion
- Timeout por inactividad: 10 minutos (600 segundos)
- Configurable por usuario en USR-SESSION-TIMEOUT
- Al timeout: se cierra la sesion automaticamente
- Se registra evento SEC-EVENT-TIMEOUT en SECURITY
- El usuario debe volver a autenticarse

### SEC-04: Longitud Minima de Password
- Minimo: 6 caracteres
- Maximo: 20 caracteres
- No puede contener el nombre del usuario
- No puede ser igual al password anterior
- No puede ser igual al ID de usuario

---

## 7. Reglas de Batch Nocturno

### BCH-01: Horario de Ejecucion
- El proceso batch diario inicia a las 23:00 horas
- No debe ejecutarse si hay cajas abiertas
- No debe ejecutarse si hay transacciones pendientes
- El horario se puede configurar en PARAMSTR (GRUPO='HORARIO')
- Tiempo estimado: 15-30 minutos

### BCH-02: Devengo Diario de Intereses
Proceso BCHINT00:
- Calcula interes sobre saldo diario de cada cuenta
- Tasa vigente del RATEFILE
- Registro contable: DB Gasto Interes / CR Interes por Pagar
- Actualiza ACT-INTEREST-ACCRUED en cada cuenta
- Solo para cuentas con status 'A', 'D', 'I'
- Excluye cuentas cerradas o congeladas

### BCH-03: Evaluacion Mensual de Comisiones
Proceso BCHFEE00:
- Ejecuta el primer dia habil de cada mes
- Evalua todas las cuentas activas contra FEESCHED
- Comisiones por: mantenimiento, exceso de transacciones, inactividad
- Las comisiones se cargan automaticamente al saldo
- Si el saldo es insuficiente, registra sobregiro

### BCH-04: Posteo Contable Antes del Cierre Diario
Proceso BCHGLI00:
- El pase contable (GL posting) se ejecuta antes del cierre diario
- Todas las transacciones del dia se reflejan en GLMASTER
- Se genera un asiento contable por cada tipo de transaccion
- El balance GL debe cuadrar antes de cerrar el dia
- Si hay diferencias, el cierre se detiene y se notifica

---

## 8. Reglas Generales

### GEN-01: Moneda Base
- La moneda funcional del sistema es MXN (Peso Mexicano)
- Todas las transacciones se registran en MXN
- Las operaciones en otras monedas utilizan CUR-EXCHANGE-RATE
- El tipo de cambio se actualiza diariamente
- Redondeo: 2 decimales para transacciones, 4 para tasas

### GEN-02: Fecha Contable vs Fecha de Proceso
- Fecha de proceso: fecha real del sistema (WS-CURRENT-DATE)
- Fecha contable: fecha del dia habil actual (WS-BUSINESS-DATE)
- Las transacciones se registran con la fecha contable
- La fecha contable puede diferir de la fecha real (findes, festivos)
- Calendario de dias festivos configurable en PARAMSTR

### GEN-03: Auditoria de Cambios
- Todo cambio en datos maestros debe registrarse en AUDITLOG
- AUD-EVENTO define el tipo de cambio (AL/BA/CA)
- AUD-ENTITY-TYPE identifica la entidad afectada
- Se registran valores anterior y nuevo (AUD-CAMPO-ANTERIOR/NUEVO)
- La pista de auditoria no puede ser modificada ni eliminada
- Retencion minima: 5 anos
