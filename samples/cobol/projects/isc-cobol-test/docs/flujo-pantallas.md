# Flujo de Pantallas — Sistema Bancario COBOL

## Formato de Pantalla Estandar

Todas las pantallas siguen el formato 80x24:

```
Linea  1: Cabecera (sistema, fecha, hora, usuario, sucursal)
Linea  2: Titulo del programa / submodulo
Lineas 3-22: Contenido (datos, menu, formulario, resultados)
Linea 23: Linea separadora (---)
Linea 24: Indicador PF-keys / mensajes de error
```

---

## 1. BNK0001 — LOGIN (Pantalla de Acceso)

**Program ID**: BNK0001
**Nombre**: Modulo de Acceso al Sistema

### Input Fields (ACCEPT)

| Campo                 | PIC      | Descripcion                    | Validacion                          |
|-----------------------|----------|--------------------------------|-------------------------------------|
| WS-USUARIO            | X(08)    | ID de usuario                  | No vacio, debe existir en USERPROF  |
| WS-CONTRASENA         | X(20)    | Password (SECURE)              | No vacio, no igual al usuario       |

### Output Fields (DISPLAY)

| Campo                 | PIC      | Descripcion                    |
|-----------------------|----------|--------------------------------|
| WS-VERSION            | X(06)    | Version del programa           |
| WS-MENSAJE            | X(60)    | Mensaje informativo            |
| WS-MENSAJE-ERROR      | X(60)    | Mensaje de error (BLINK)       |

### Validation Rules

1. Usuario no puede estar vacio
2. Password no puede estar vacio
3. Password no puede ser igual al usuario
4. Usuario debe existir en USERPROF
5. Usuario debe tener status 'A' (Activo)
6. Password debe coincidir con registro
7. Password no debe estar expirado
8. Maximo 3 intentos fallidos

### PF-key Actions

| PF-key | Accion                          | Descripcion                    |
|--------|---------------------------------|--------------------------------|
| PF1    | CALL 'COMHELP' USING 'LOGIN'    | Ayuda de login                 |
| PF12   | STOP RUN                        | Salir del sistema              |
| ENTER  | Validar credenciales            | Procesar login                 |
| CLEAR  | Limpiar campos                  | Resetear pantalla              |

### Next Screens

| Condition                     | Next Screen                     |
|-------------------------------|---------------------------------|
| Login exitoso, password vigente | COMMENU / BNK0010             |
| Login exitoso, password expirado | Pantalla cambio password    |
| Login fallido (<3 intentos)    | BNK0001 (mismo, con error)     |
| Login fallido (3 intentos)     | BNK0001 (usuario bloqueado)    |
| PF12                           | STOP RUN                       |

---

## 2. BNK0001 — CAMBIO DE PASSWORD (sub-pantalla)

**Program ID**: BNK0001 (seccion 5000)
**Nombre**: Cambio de Contrasena

### Input Fields

| Campo                       | PIC      | Descripcion                    | Validacion                          |
|-----------------------------|----------|--------------------------------|-------------------------------------|
| WS-CONTRASENA-ANTERIOR      | X(20)    | Password anterior (SECURE)     | Debe coincidir con actual           |
| WS-CONTRASENA-NUEVA         | X(20)    | Password nuevo (SECURE)        | Min 6 chars, != anterior            |
| WS-CONTRASENA-CONFIRMA      | X(20)    | Confirmacion (SECURE)          | Debe coincidir con nuevo            |

### Validation Rules

1. Password nuevo no vacio
2. Password nuevo >= 6 caracteres
3. Confirmacion debe coincidir con nuevo
4. Nuevo debe ser diferente al anterior
5. Nuevo no puede ser igual al ID de usuario

### PF-key Actions

| PF-key | Accion                          | Descripcion                    |
|--------|---------------------------------|--------------------------------|
| ENTER  | Validar y guardar nuevo password| Actualiza USERPROF             |
| PF12   | Cancelar cambio                 | Retorna a login                |

### Next Screens

| Condition                     | Next Screen                     |
|-------------------------------|---------------------------------|
| Cambio exitoso                | COMMENU / BNK0010              |
| Cancelado (PF12)              | BNK0001 (login)                |

---

## 3. COMMENU / BNK0010 — MENU PRINCIPAL

**Program ID**: COMMENU / BNK0010
**Nombre**: Menu Principal de Operaciones

### Input Fields

COMMENU: solo PF-keys (no ACCEPT de datos)
BNK0010: WS-OPCION (PIC 99) - codigo numerico de opcion

### Output Fields

| Campo                 | PIC      | Descripcion                    |
|-----------------------|----------|--------------------------------|
| WS-FECHA              | 9(08)    | Fecha actual                   |
| WS-HORA               | 9(06)    | Hora actual                    |
| WS-USUARIO            | X(08)    | Usuario autenticado            |
| WS-SUCURSAL           | X(04)    | Sucursal del usuario           |
| WS-MENSAJE            | X(60)    | Mensaje informativo            |
| WS-MENSAJE-ERROR      | X(60)    | Mensaje de error               |

### PF-key Actions (COMMENU)

| PF-key | Accion                          | Descripcion                    |
|--------|---------------------------------|--------------------------------|
| PF1    | CALL 'CUSMNU00'                 | Modulo Clientes                |
| PF2    | CALL 'ACTMNU00'                 | Modulo Cuentas                 |
| PF3    | CALL 'TLRMNU00'                 | Modulo Ventanilla              |
| PF4    | CALL 'LONMNU00'                 | Modulo Prestamos               |
| PF5    | CALL 'DEPMNU00'                 | Modulo Depositos               |
| PF6    | CALL 'TDMNU000'                 | Modulo Plazo Fijo              |
| PF7    | CALL 'FTMNU000'                 | Modulo Transferencias          |
| PF8    | CALL 'BCHMNU00'                 | Modulo Batch                   |
| PF9    | CALL 'RPTMNU00'                 | Modulo Reportes                |
| PF10   | CALL 'SECMNU00'                 | Modulo Seguridad               |
| PF11   | CALL 'COMHELP' USING 'GENERAL'  | Ayuda General                  |
| PF12   | CALL 'SECSGN00' + STOP RUN      | Salir                          |

### PF-key Actions (BNK0010 adicionales)

| PF-key | Accion                          |
|--------|---------------------------------|
| PF7    | Pagina anterior                 |
| PF8    | Pagina siguiente                |
| ENTER  | Ejecutar opcion por codigo      |

### Screen Layout (BNK0010)

```
+----------------------------------------------------------------------+
| BANCO NACIONAL 01/01/2006 14:30:25  USR: COBOL01  SUC: S001         |
+----------------------------------------------------------------------+
|                     MENU PRINCIPAL DE OPERACIONES                     |
|                                                                       |
|  01 - Alta Cliente            02 - Consulta Cliente                 |
|  03 - Modificacion Cliente    04 - Baja Cliente                     |
|  05 - Busqueda Cliente        06 - Direcciones                      |
|  07 - Relaciones              08 - Cambio Estatus                   |
|  09 - Apertura Cuenta         10 - Consulta Cuenta                  |
|  11 - Modificacion Cuenta     12 - Cierre Cuenta                    |
|                                                                       |
|  Opcion: __                                                            |
+----------------------------------------------------------------------+
| PAGINA 1 DE 3  PF7=PAG-ANT  PF8=PAG-SIG  PF11=AYU  PF12=SALIR       |
+----------------------------------------------------------------------+
```

---

## 4. CUSMNU00 — MENU CLIENTES

**Program ID**: CUSMNU00
**Nombre**: Modulo Clientes - Menu Principal

### Output Fields

| Campo                 | PIC      | Descripcion                    |
|-----------------------|----------|--------------------------------|
| WS-FECHA-DDMM         | 9(08)    | Fecha en formato DDMMYYYY      |
| WS-HORA               | 9(06)    | Hora actual                    |
| WS-USUARIO-ID         | X(08)    | Usuario autenticado            |
| WS-SUCURSAL-ID        | X(04)    | Sucursal                       |
| WS-MENSAJE            | X(60)    | Mensaje informativo            |
| WS-MENSAJE-ERROR      | X(60)    | Mensaje de error (BLINK)       |

### PF-key Actions

| PF-key | Accion                          | Descripcion                    |
|--------|---------------------------------|--------------------------------|
| PF1    | CALL 'CUSSRH00'                 | Busqueda de Cliente            |
| PF2    | CALL 'CUSINQ00'                 | Consulta de Cliente            |
| PF3    | CALL 'CUSMNT00'                 | Alta de Cliente                |
| PF4    | CALL 'CUSUPD00'                 | Modificacion de Cliente        |
| PF5    | CALL 'CUSADR00'                 | Direcciones                    |
| PF6    | CALL 'CUSREL00'                 | Relaciones/Beneficiarios       |
| PF7    | CALL 'CUSSTS00'                 | Cambio de Estatus              |
| PF11   | CALL 'COMHELP' USING 'CLIENTES' | Ayuda                          |
| PF12   | Confirmar y retornar            | Retorno a COMMENU              |
| CLEAR  | Limpiar mensajes                | Reset                          |

### Screen Layout

```
+----------------------------------------------------------------------+
| BANCO NACIONAL 01/01/2006 14:30:25  USR: COBOL01  SUC: S001         |
+----------------------------------------------------------------------+
|                   MODULO CLIENTES - MENU PRINCIPAL                    |
|                                                                       |
|  SELECCIONE OPERACION CON TECLA PF                                   |
|                                                                       |
|   PF1 - BUSQUEDA DE CLIENTE                                          |
|   PF2 - CONSULTA DE CLIENTE                                          |
|   PF3 - ALTA DE CLIENTE                                              |
|   PF4 - MODIFICACION DE CLIENTE                                      |
|   PF5 - MANTENIMIENTO DIRECCIONES                                    |
|   PF6 - RELACIONES / BENEFICIARIOS                                   |
|   PF7 - CAMBIO DE ESTATUS                                            |
|                                                                       |
+----------------------------------------------------------------------+
| PF1=SRH  PF2=INQ  PF3=ALT  PF4=UPD  PF5=ADR  PF6=REL  PF7=STS      |
| PF11=AYU  PF12=RET                                                   |
+----------------------------------------------------------------------+
```

---

## 5. CUSMNT00 — ALTA DE CLIENTE

**Program ID**: CUSMNT00
**Nombre**: Alta de Cliente

### Input Fields (ACCEPT)

| Campo                 | PIC      | Descripcion                    | Validacion                          |
|-----------------------|----------|--------------------------------|-------------------------------------|
| CUS-ID-TYPE           | X(02)    | Tipo persona (PF/PM/GO)        | Debe ser valor valido               |
| CUS-NAME              | X(60)    | Nombre o razon social          | No vacio                            |
| CUS-RFC               | X(13)    | RFC                            | Formato 13 chars, valido SAT        |
| CUS-CURP              | X(18)    | CURP                           | 18 chars, valido algoritmo          |
| CUS-FECHA-NACIMIENTO  | 9(08)    | Fecha nacimiento               | AAAAMMDD, < fecha actual            |
| CUS-SEXO              | X(01)    | Sexo (M/F)                     | M o F                               |
| CUS-NACIONALIDAD      | X(03)    | Nacionalidad                   | Codigo ISO                          |
| CUS-INGRESO-MENSUAL   | 9(09)V99 | Ingreso mensual                | Numerico positivo                   |
| CUS-TELEFONO1         | X(15)    | Telefono                       | Min 10 digitos                      |
| CUS-EMAIL             | X(50)    | Email                          | Formato basico                      |

### Output Fields (DISPLAY)

| Campo                 | PIC      | Descripcion                    |
|-----------------------|----------|--------------------------------|
| Datos del cliente     | varios   | Datos capturados               |
| CUS-SEGMENTO          | X(02)    | Segmento asignado automatico   |
| CUS-RIESGO-CATEGORIA  | X(01)    | Riesgo inicial (A)             |
| WS-MENSAJE            | X(60)    | Mensajes                       |

### Validation Rules

1. RFC no duplicado en archivo
2. CURP valida (18 caracteres, algoritmo)
3. Fecha nacimiento: cliente debe ser mayor de edad (18+)
4. Tipo persona: PF, PM, o GO
5. Ingreso mensual: > 0 para PF
6. Telefono: al menos 10 digitos

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| ENTER  | Validar y guardar                |
| PF12   | Cancelar y retornar             |
| PF11   | Ayuda contextual                |
| CLEAR  | Limpiar formulario              |

### Next Screens

| Condition                     | Next Screen                     |
|-------------------------------|---------------------------------|
| Alta exitosa                  | CUSMNU00 (confirmacion)        |
| Error validacion              | CUSMNT00 (mensaje error)       |
| PF12                          | CUSMNU00                       |

---

## 6. CUSSRH00 — BUSQUEDA DE CLIENTE

**Program ID**: CUSSRH00
**Nombre**: Busqueda de Cliente

### Input Fields

| Campo                 | PIC      | Descripcion                    | Validacion                          |
|-----------------------|----------|--------------------------------|-------------------------------------|
| SC-SEARCH-TYPE        | X(02)    | Tipo de busqueda               | 01=ID, 02=Nombre, 03=RFC           |
| SC-SEARCH-VALUE       | X(30)    | Valor a buscar                 | No vacio                            |

### Output Fields

| Campo                 | PIC      | Descripcion                    |
|-----------------------|----------|--------------------------------|
| SC-SEARCH-RESULT-TABLE| OCCURS 20| Tabla de resultados            |
| SC-SEARCH-RESULT-COUNT| 9(04)    | Numero de resultados           |
| WS-MENSAJE            | X(60)    | Mensajes                       |

### Validation Rules

1. Tipo de busqueda debe ser valido
2. Valor de busqueda no vacio
3. Si busqueda por ID: debe ser exacta
4. Si busqueda por nombre: minimo 3 caracteres

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| ENTER  | Ejecutar busqueda               |
| PF12   | Retornar a CUSMNU00             |
| PF11   | Ayuda contextual                |

### Next Screens

| Condition                     | Next Screen                     |
|-------------------------------|---------------------------------|
| Resultados encontrados        | CUSSRH00 (lista resultados)     |
| Sin resultados                | CUSSRH00 (mensaje no encontrado)|
| PF12                          | CUSMNU00                       |

---

## 7. ACTMNU00 — MENU CUENTAS

**Program ID**: ACTMNU00
**Nombre**: Modulo Cuentas - Menu Principal

### PF-key Actions

| PF-key | Accion                          | Descripcion                    |
|--------|---------------------------------|--------------------------------|
| PF1    | CALL 'ACTINQ00'                 | Consulta de Cuenta             |
| PF2    | CALL 'ACTOPN00'                 | Apertura de Cuenta             |
| PF3    | CALL 'ACTUPD00'                 | Modificacion de Cuenta         |
| PF4    | CALL 'ACTCLS00'                 | Cierre de Cuenta               |
| PF5    | CALL 'ACTFRZ00'                 | Congelar / Descongelar         |
| PF6    | CALL 'ACTBAL00'                 | Consulta de Saldo              |
| PF7    | CALL 'ACTSTM00'                 | Estado de Cuenta               |
| PF11   | CALL 'COMHELP' USING 'CUENTAS'  | Ayuda                          |
| PF12   | Retorno                         | COMMENU                        |

### Screen Layout (similar a CUSMNU00)

```
+----------------------------------------------------------------------+
| BANCO NACIONAL 01/01/2006 14:30:25  USR: COBOL01  SUC: S001         |
+----------------------------------------------------------------------+
|                    MODULO CUENTAS - MENU PRINCIPAL                    |
|                                                                       |
|  SELECCIONE OPERACION CON TECLA PF                                   |
|                                                                       |
|   PF1 - CONSULTA DE CUENTA                                           |
|   PF2 - APERTURA DE CUENTA                                           |
|   PF3 - MODIFICACION DE CUENTA                                       |
|   PF4 - CIERRE DE CUENTA                                             |
|   PF5 - CONGELAR / DESCONGELAR                                       |
|   PF6 - CONSULTA DE SALDO                                            |
|   PF7 - ESTADO DE CUENTA                                             |
|                                                                       |
+----------------------------------------------------------------------+
| PF1=INQ  PF2=APERT  PF3=UPD  PF4=CIERRE  PF5=FRZ  PF6=BAL  PF7=STM |
| PF11=AYU  PF12=RET                                                   |
+----------------------------------------------------------------------+
```

---

## 8. ACTOPN00 — APERTURA DE CUENTA

**Program ID**: ACTOPN00
**Nombre**: Apertura de Cuenta

### Input Fields

| Campo                 | PIC      | Descripcion                    | Validacion                          |
|-----------------------|----------|--------------------------------|-------------------------------------|
| ACT-TYPE              | X(02)    | Tipo cuenta (CH/AH/NO/IN)      | Valor valido                        |
| ACT-CURRENCY          | X(03)    | Moneda (MXN/USD/EUR)           | Valor valido                        |
| AXR-CUSTOMER-ID       | X(10)    | Cliente titular                | Debe existir en CUSTOMER            |
| ACT-BALANCE           | S9(13)V99| Deposito inicial               | >= minimo segun tipo               |
| Solicitar chequera    | X(01)    | S/N                            | Solo para CH                        |

### Validation Rules

1. Cliente debe existir y estar activo
2. Deposito inicial >= minimo por tipo
3. Tipo cuenta compatible con moneda
4. Numero de cuenta unico (no duplicado)
5. Si tipo CH y solicita chequera: crear CHQBOOK

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | CALL 'CUSSRH00' (buscar cliente)|
| ENTER  | Validar y abrir cuenta          |
| PF12   | Cancelar y retornar             |

### Next Screens

| Condition                     | Next Screen                     |
|-------------------------------|---------------------------------|
| Apertura exitosa              | ACTMNU00 (confirmacion)        |
| Cliente no encontrado         | ACTOPN00 (error)               |
| PF12                          | ACTMNU00                       |

---

## 9. TLRMNU00 — MENU CAJA / VENTANILLA

**Program ID**: TLRMNU00
**Nombre**: Modulo de Caja / Ventanilla

### Output Fields

| Campo                 | PIC      | Descripcion                    |
|-----------------------|----------|--------------------------------|
| WS-TLR-SESION-ACTIVA  | X(01)    | Indica si caja esta abierta    |

### PF-key Actions

| PF-key | Accion                          | Requisito                     |
|--------|---------------------------------|-------------------------------|
| PF1    | CALL 'TLRSGN00'                 | Apertura de Caja              |
| PF2    | CALL 'TLRDEP00'                 | Deposito (requiere caja)      |
| PF3    | CALL 'TLRWTH00'                 | Retiro (requiere caja)        |
| PF4    | CALL 'TLRTRF00'                 | Transferencia (requiere caja) |
| PF5    | CALL 'TLRPYM00'                 | Pago (requiere caja)          |
| PF6    | CALL 'TLRCHE00'                 | Cobro Cheque (requiere caja)  |
| PF7    | CALL 'TLRSMG00'                 | Resumen/Cierre (req. caja)    |
| PF12   | Retorno                         | COMMENU                       |

### Validation Rules

1. PF2-PF7 requieren sesion de caja activa
2. Si no hay caja abierta, mensaje: "DEBE ABRIR CAJA PRIMERO (PF1)"

### Screen Layout

```
+----------------------------------------------------------------------+
| BANCO NACIONAL 01/01/2006 14:30:25  USR: COBOL01  SUC: S001         |
+----------------------------------------------------------------------+
|                   MODULO DE CAJA / VENTANILLA                         |
|                                                                       |
|  SELECCIONE OPCION - TRANSACCIONES DE CAJA:                          |
|                                                                       |
|   PF1 - APERTURA DE CAJA (SIGN-ON)                                   |
|   PF2 - DEPOSITO EN EFECTIVO/CHEQUE                                  |
|   PF3 - RETIRO EN EFECTIVO                                           |
|   PF4 - TRANSFERENCIA ENTRE CUENTAS                                  |
|   PF5 - PAGO DE SERVICIOS                                            |
|   PF6 - COBRO DE CHEQUE                                              |
|   PF7 - RESUMEN / CIERRE DE CAJA                                     |
|                                                                       |
+----------------------------------------------------------------------+
| PF1=APERT  PF2=DEP  PF3=RET  PF4=TRF  PF5=PAG  PF6=CHQ  PF7=CIE    |
| PF12=SALIR                                                           |
+----------------------------------------------------------------------+
```

---

## 10. TLRDEP00 — DEPOSITO EN EFECTIVO/CHEQUE

**Program ID**: TLRDEP00
**Nombre**: Deposito

### Input Fields

| Campo                 | PIC      | Descripcion                    | Validacion                          |
|-----------------------|----------|--------------------------------|-------------------------------------|
| TRN-ACCOUNT-NBR       | X(10)    | Cuenta destino                 | Debe existir, activa               |
| TRN-AMOUNT            | S9(13)V99| Monto a depositar              | > 0                                 |
| TRN-TYPE              | X(03)    | Tipo: Efectivo/Cheque          | 'DEP'                               |
| TRN-CHQ-NBR           | 9(10)    | Numero cheque (si cheque)      | Opcional                            |

### Validation Rules

1. Cuenta destino debe existir (CALL 'ACTINQ00')
2. Cuenta debe estar activa (no cerrada/congelada)
3. Monto debe ser > 0
4. Si es cheque: validar datos del cheque

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | Buscar cuenta (CALL 'ACTINQ00') |
| ENTER  | Procesar deposito               |
| PF12   | Cancelar y retornar             |

### Next Screens

| Condition                     | Next Screen                     |
|-------------------------------|---------------------------------|
| Deposito exitoso              | TLRMNU00 (confirmacion)        |
| Cuenta no existe              | TLRDEP00 (error)               |
| PF12                          | TLRMNU00                       |

---

## 11. LONMNU00 — MENU PRESTAMOS

**Program ID**: LONMNU00
**Nombre**: Modulo Prestamos - Menu Principal

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | CALL 'LONINQ00'                 | Consulta Prestamo             |
| PF2    | CALL 'LONAPL00'                 | Solicitud Prestamo            |
| PF3    | CALL 'LONAPV00'                 | Aprobacion Prestamo           |
| PF4    | CALL 'LONDIS00'                 | Desembolso                    |
| PF5    | CALL 'LONPYM00'                 | Pago Prestamo                 |
| PF6    | CALL 'LONAMR00'                 | Tabla Amortizacion            |
| PF7    | CALL 'LONDEL00'                 | Gestion Mora/Castigo          |
| PF11   | CALL 'COMHELP' USING 'PRESTAMOS'| Ayuda                         |
| PF12   | Retorno                         | COMMENU                       |

### Screen Layout

```
+----------------------------------------------------------------------+
| BANCO NACIONAL 01/01/2006 14:30:25  USR: COBOL01  SUC: S001         |
+----------------------------------------------------------------------+
|                    MODULO PRESTAMOS - MENU PRINCIPAL                  |
|                                                                       |
|   PF1 - CONSULTA DE PRESTAMO                                         |
|   PF2 - SOLICITUD DE PRESTAMO                                        |
|   PF3 - APROBACION DE PRESTAMO                                       |
|   PF4 - DESEMBOLSO                                                   |
|   PF5 - PAGO DE PRESTAMO                                             |
|   PF6 - TABLA DE AMORTIZACION                                        |
|   PF7 - GESTION DE MORA / CASTIGO                                    |
|                                                                       |
+----------------------------------------------------------------------+
| PF1=INQ  PF2=APL  PF3=APV  PF4=DIS  PF5=PYM  PF6=AMR  PF7=DEL      |
| PF11=AYU  PF12=RET                                                   |
+----------------------------------------------------------------------+
```

---

## 12. LONAPL00 — SOLICITUD DE PRESTAMO

**Program ID**: LONAPL00
**Nombre**: Solicitud de Prestamo

### Input Fields

| Campo                 | PIC      | Descripcion                    | Validacion                          |
|-----------------------|----------|--------------------------------|-------------------------------------|
| LAP-CUSTOMER-ID       | X(10)    | Cliente                        | Debe existir                       |
| LAP-TYPE              | X(02)    | Tipo prestamo                  | PL/HI/AU/CO                        |
| LAP-AMOUNT-REQUESTED  | 9(13)V99 | Monto solicitado               | > 0, <= maximo producto            |
| LAP-TERM-MONTHS       | 9(04)    | Plazo meses                    | Entre minimo y maximo producto     |
| LAP-INGRESO-MENSUAL   | 9(09)V99 | Ingreso mensual                | Debe ser positivo                  |
| LAP-EGRESOS-MENSUALES | 9(09)V99 | Egresos mensuales              | Debe ser positivo                  |

### Validation Rules

1. Cliente debe existir (CALL 'CUSSRH00')
2. Ratio ingreso/deuda: egresos/(ingreso + pago estimado) < 45%
3. Score calculado automaticamente
4. Si score < 600: rechazo automatico
5. Tasa propuesta desde RATEFILE

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | CALL 'CUSSRH00' (buscar cliente)|
| ENTER  | Procesar solicitud              |
| PF12   | Cancelar                        |

### Next Screens

| Condition                     | Next Screen                     |
|-------------------------------|---------------------------------|
| Solicitud registrada          | LONMNU00 (score mostrado)      |
| Score insuficiente            | LONAPL00 (rechazo)             |
| PF12                          | LONMNU00                       |

---

## 13. DEPMNU00 — MENU DEPOSITOS

**Program ID**: DEPMNU00
**Nombre**: Modulo Depositos - Menu Principal

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | CALL 'DEPINQ00'                 | Consulta Deposito             |
| PF2    | CALL 'DEPOPN00'                 | Apertura Deposito             |
| PF3    | CALL 'DEPINT00'                 | Tasas de Interes              |
| PF4    | CALL 'DEPWTH00'                 | Reglas de Retiro              |
| PF5    | CALL 'DEPSTM00'                 | Estado de Deposito            |
| PF6    | CALL 'DEPREN00'                 | Renovacion Automatica         |
| PF11   | CALL 'COMHELP' USING 'DEPOSITOS'| Ayuda                         |
| PF12   | Retorno                         | COMMENU                       |

---

## 14. TDMNU000 — MENU PLAZO FIJO

**Program ID**: TDMNU000
**Nombre**: Modulo Plazo Fijo - Menu Principal

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | CALL 'TDOPN000'                 | Apertura CD                   |
| PF2    | CALL 'TDINQ000'                 | Consulta CD                   |
| PF3    | CALL 'TDCLS000'                 | Liquidacion CD                |
| PF4    | CALL 'TDINT000'                 | Calculo Interes CD            |
| PF11   | CALL 'COMHELP' USING 'PLAZOFIJO'| Ayuda                         |
| PF12   | Retorno                         | COMMENU                       |

---

## 15. FTMNU000 — MENU TRANSFERENCIAS

**Program ID**: FTMNU000
**Nombre**: Modulo Transferencias - Menu Principal

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | CALL 'FTINT000'                 | Transferencia Interna         |
| PF2    | CALL 'FTWIR000'                 | Transferencia Wire (SWIFT)    |
| PF3    | CALL 'FTACH000'                 | Transferencia ACH             |
| PF4    | CALL 'FTSTS000'                 | Estado Transferencia          |
| PF11   | CALL 'COMHELP' USING 'TRANSFERENCIAS'| Ayuda                    |
| PF12   | Retorno                         | COMMENU                       |

---

## 16. BCHMNU00 — MENU BATCH

**Program ID**: BCHMNU00
**Nombre**: Modulo Batch - Menu Principal

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | CALL 'BCHDAY00'                 | Cierre Diario                 |
| PF2    | CALL 'BCHMTH00'                 | Cierre Mensual                |
| PF3    | CALL 'BCHINT00'                 | Devengo Intereses             |
| PF4    | CALL 'BCHGLI00'                 | Interface GL                  |
| PF5    | CALL 'BCHODO00'                 | Calculo Sobregiro/Mora        |
| PF6    | CALL 'BCHFEE00'                 | Comisiones Periodicas         |
| PF11   | CALL 'COMHELP' USING 'BATCH'    | Ayuda                          |
| PF12   | Retorno                         | COMMENU                       |

---

## 17. RPTMNU00 — MENU REPORTES

**Program ID**: RPTMNU00
**Nombre**: Modulo Reportes - Menu Principal

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | CALL 'RPTBAL00'                 | Balance General               |
| PF2    | CALL 'RPTTXN00'                 | Transacciones Diarias         |
| PF3    | CALL 'RPTDEL00'                 | Cartera Vencida               |
| PF4    | CALL 'RPTTLR00'                 | Cuadre de Caja                |
| PF5    | CALL 'RPTGLB00'                 | Trial Balance                 |
| PF6    | CALL 'RPTREG00'                 | Reportes Regulatorios         |
| PF11   | CALL 'COMHELP' USING 'REPORTES' | Ayuda                         |
| PF12   | Retorno                         | COMMENU                       |

---

## 18. SECMNU00 — MENU SEGURIDAD

**Program ID**: SECMNU00
**Nombre**: Modulo Seguridad - Menu Principal

### PF-key Actions

| PF-key | Accion                          |
|--------|---------------------------------|
| PF1    | CALL 'SECUSR00'                 | Mantenimiento Usuarios        |
| PF2    | CALL 'SECPWD00'                 | Cambio de Password            |
| PF3    | CALL 'SECAUD00'                 | Auditoria de Sesiones         |
| PF11   | CALL 'COMHELP' USING 'SEGURIDAD'| Ayuda                         |
| PF12   | Retorno                         | COMMENU                       |

---

## Convenciones Generales de Pantalla

### Mensajes de Error Estandar

| Codigo | Mensaje                                  |
|--------|------------------------------------------|
| 00     | Operacion exitosa                        |
| 01     | Registro no encontrado                   |
| 02     | Registro duplicado                       |
| 03     | Usuario no autorizado                    |
| 04     | Error de archivo                         |
| 05     | Datos invalidos                          |
| 06     | Cuenta cerrada                           |
| 07     | Fondos insuficientes                     |
| 08     | Registro bloqueado                       |
| 09     | Registro expirado                        |
| 10     | Sesion expirada                          |
| 11     | Transaccion rechazada                    |
| 12     | Transaccion pendiente                    |
| 99     | Error desconocido                        |

### Teclas de Funcion Globales

- **PF11**: Ayuda contextual (CALL 'COMHELP' USING codigo)
- **PF12**: Retorno al programa llamador
- **CLEAR**: Limpiar campos y mensajes de error
- **ENTER**: Confirmar / Aceptar / Procesar
