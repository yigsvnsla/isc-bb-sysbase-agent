# Matriz de Dependencias — Sistema Bancario COBOL

## Convenciones

| Abreviatura | Significado                               |
|-------------|-------------------------------------------|
| RD          | READ                                      |
| WR          | WRITE                                     |
| RW          | REWRITE                                   |
| DL          | DELETE                                    |
| ST          | START                                     |
| RN          | READ NEXT                                 |
| F           | File (archivo indexado)                   |
| C           | CALL (programa)                           |
| CP          | COPYBOOK                                  |

---

## 1. Common Programs

### COMDATE — Rutinas de Fecha/Hora

| COPYBOOKS  | Archivos    | CALL a programas | Llamado por                     |
|------------|-------------|------------------|---------------------------------|
| cpy-common | Ninguno     | Ninguno          | COMMENU, BNK0001, CUSMNU00,     |
|            |             |                  | TLRMNU00, TODOS los programas   |

### COMVFYL — Validacion de Archivos

| COPYBOOKS  | Archivos                | CALL a programas | Llamado por                     |
|------------|-------------------------|------------------|---------------------------------|
| cpy-common | CUSTOMER (RD)           | Ninguno          | COMMENU                         |
|            | ACCOUNT (RD)            |                  |                                 |
|            | TRANLOG (RD)            |                  |                                 |
|            | USERPROF (RD)           |                  |                                 |

### COMHELP — Ayuda Contextual

| COPYBOOKS  | Archivos    | CALL a programas | Llamado por                     |
|------------|-------------|------------------|---------------------------------|
| cpy-common | Ninguno     | Ninguno          | COMMENU, BNK0001, CUSMNU00,     |
|            |             |                  | TODOS los programas             |

### COMMENU — Menu Principal

| COPYBOOKS  | Archivos    | CALL a programas                    | Llamado por           |
|------------|-------------|-------------------------------------|-----------------------|
| cpy-common | Ninguno     | CUSMNU00, ACTMNU00, TLRMNU00       | BNK0001 (login ->)    |
| cpy-screen |             | LONMNU00, DEPMNU00, TDMNU000       |                       |
|            |             | FTMNU000, BCHMNU00, RPTMNU00       |                       |
|            |             | SECMNU00, COMHELP, COMDATE         |                       |
|            |             | SECSGN00, COMSCRN                  |                       |

### COMSCRN — Rutinas de Pantalla

| COPYBOOKS  | Archivos    | CALL a programas | Llamado por                     |
|------------|-------------|------------------|---------------------------------|
| cpy-screen | Ninguno     | Ninguno          | COMMENU, TODOS los programas    |

### COMERRF — Manejo de Errores

| COPYBOOKS  | Archivos    | CALL a programas | Llamado por                     |
|------------|-------------|------------------|---------------------------------|
| cpy-error  | Ninguno     | COMHELP          | Programas con I/O indexado      |

### COMPFKF — Manejo PF-keys

| COPYBOOKS  | Archivos    | CALL a programas | Llamado por                     |
|------------|-------------|------------------|---------------------------------|
| cpy-common | Ninguno     | Ninguno          | Programas con SCREEN SECTION    |

### COMSECF — Seguridad de Funciones

| COPYBOOKS  | Archivos    | CALL a programas | Llamado por                     |
|------------|-------------|------------------|---------------------------------|
| cpy-common | USERPROF(RD)| SECAUD00         | Programas con restriccion       |
|            | SECURITY(RD)|                  |                                 |

### COMMSGF — Formateo de Mensajes

| COPYBOOKS  | Archivos    | CALL a programas | Llamado por                     |
|------------|-------------|------------------|---------------------------------|
| cpy-common | MESSAGES(RD)| Ninguno          | Programas que muestran mensajes |

### COMVALF — Validacion de Campos

| COPYBOOKS  | Archivos    | CALL a programas | Llamado por                     |
|------------|-------------|------------------|---------------------------------|
| cpy-common | Ninguno     | COMDATE          | Programas con captura de datos  |
| cpy-codtab |             |                  |                                 |

### COMUTIL — Utilidades Generales

| COPYBOOKS  | Archivos    | CALL a programas | Llamado por                     |
|------------|-------------|------------------|---------------------------------|
| cpy-common | Ninguno     | COMDATE          | Programas varios                |

---

## 2. Security Programs

### BNK0001 / SECSGN00 — Login / Sign-On

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | USERPROF (RD/RW)      | COMDATE, COMHELP | COMMENU, BNK0010      |
|              | SECURITY (WR)         | AUDTRL00         |                       |

### BNK0010 — Menu Principal (60 opciones)

| COPYBOOKS    | Archivos    | CALL a programas                    | Llamado por           |
|--------------|-------------|-------------------------------------|-----------------------|
| cpy-common   | Ninguno     | BNK0001, COMHELP, COMDATE           | COMMENU               |
| cpy-screen   |             | Todos los programas del sistema     | (programa principal)  |

### SECSGO00 — Sign-Off

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | SECURITY (WR)         | AUDTRL00         | COMMENU               |

### SECMNU00 — Menu Seguridad

| COPYBOOKS    | Archivos    | CALL a programas | Llamado por           |
|--------------|-------------|------------------|-----------------------|
| cpy-common   | Ninguno     | SECUSR00         | COMMENU, BNK0010      |
| cpy-screen   |             | SECPWD00         |                       |
|              |             | SECAUD00         |                       |
|              |             | COMHELP          |                       |

### SECUSR00 — Mantenimiento Usuarios

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | USERPROF (RD/WR/RW)   | AUDTRL00         | SECMNU00              |
| fd-userprof  |                       | COMDATE          |                       |

### SECPWD00 — Cambio Password

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | USERPROF (RD/RW)      | AUDTRL00         | SECMNU00, BNK0001     |
| fd-userprof  | SECURITY (WR)         | COMDATE          |                       |

### SECAUD00 — Auditoria Sesiones

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | SECURITY (RD/ST/RN)   | COMDATE          | SECMNU00              |
| fd-security  |                       |                  |                       |

---

## 3. Customer Programs

### CUSMNU00 — Menu Clientes

| COPYBOOKS  | Archivos    | CALL a programas                    | Llamado por           |
|------------|-------------|-------------------------------------|-----------------------|
| cpy-common | Ninguno     | CUSSRH00, CUSINQ00, CUSMNT00       | COMMENU, BNK0010      |
| cpy-screen |             | CUSUPD00, CUSADR00, CUSREL00       |                       |
|            |             | CUSSTS00, COMHELP, COMDATE         |                       |

### CUSSRH00 — Busqueda Cliente

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | CUSTOMER (RD/ST/RN)   | AUDTRL00         | CUSMNU00, ACTOPN00,  |
| fd-customer  |                       |                  | LONAPL00, DEPOPN00,  |
|              |                       |                  | TDOPN000              |

### CUSINQ00 — Consulta Cliente

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | CUSTOMER (RD)         | AUDTRL00         | CUSMNU00              |
| fd-customer  | ACCTXREF (RD/ST/RN)   | ACTINQ00 (opc)   |                       |

### CUSMNT00 — Alta Cliente

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | CUSTOMER (RD/WR)      | AUDTRL00         | CUSMNU00, BNK0010     |
| fd-customer  | ACCTXREF (WR) (opc)   | COMDATE          |                       |
| cpy-codtab   |                       |                  |                       |

### CUSUPD00 — Modificacion Cliente

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | CUSTOMER (RD/RW)      | AUDTRL00         | CUSMNU00, BNK0010     |
| fd-customer  |                       | COMDATE          |                       |

### CUSADR00 — Direcciones

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | CUSTOMER (RD/RW)      | AUDTRL00         | CUSMNU00              |
| fd-customer  |                       |                  |                       |

### CUSREL00 — Relaciones

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | ACCTXREF (RD/WR/RW/DL)| AUDTRL00         | CUSMNU00              |
| fd-accountxr | CUSTOMER (RD)         |                  |                       |

### CUSSTS00 — Cambio Estatus

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | CUSTOMER (RD/RW)      | AUDTRL00         | CUSMNU00, BNK0010     |
| fd-customer  |                       |                  |                       |

---

## 4. Account Programs

### ACTMNU00 — Menu Cuentas

| COPYBOOKS  | Archivos    | CALL a programas                    | Llamado por           |
|------------|-------------|-------------------------------------|-----------------------|
| cpy-common | Ninguno     | ACTINQ00, ACTOPN00, ACTUPD00       | COMMENU, BNK0010      |
| cpy-screen |             | ACTCLS00, ACTFRZ00, ACTBAL00       |                       |
|            |             | ACTSTM00, COMHELP, COMDATE         |                       |

### ACTINQ00 — Consulta Cuenta

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD)          | COMDATE          | ACTMNU00, TLRDEP00,  |
| fd-account   | ACCTXREF (RD)         |                  | TLRTRF00, TLRCHE00   |
|              |                       |                  | CUSINQ00              |

### ACTOPN00 — Apertura Cuenta

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/WR)            | CUSSRH00         | ACTMNU00, BNK0010     |
| fd-account   | ACCTXREF (WR)              | AUDTRL00         |                       |
| fd-accountxr | CHQBOOK (WR) (si chequera) | COMDATE          |                       |
| fd-chqbook   |                            |                  |                       |

### ACTUPD00 — Modificacion Cuenta

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW)       | AUDTRL00         | ACTMNU00, FTWIR000   |
| fd-account   |                       | COMDATE          |                       |

### ACTCLS00 — Cierre Cuenta

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW)       | ACTBAL00         | ACTMNU00, BNK0010     |
| fd-account   |                       | AUDTRL00         |                       |

### ACTFRZ00 — Congelar/Descongelar

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW)       | AUDTRL00         | ACTMNU00              |
| fd-account   |                       |                  |                       |

### ACTBAL00 — Consulta Saldo

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD)          | BCHODO00 (opc)   | ACTMNU00, TLRWTH00,  |
| fd-account   |                       | AUDTRL00         | TLRPYM00, FTINT000,  |
|              |                       |                  | FTWIR000, FTACH000,  |
|              |                       |                  | ACTCLS00, TDCLS000   |

### ACTSTM00 — Estado Cuenta

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD)          | COMDATE          | ACTMNU00              |
| fd-account   | TRANLOG (RD/ST/RN)    |                  |                       |
| fd-tranlog   |                       |                  |                       |

---

## 5. Teller Programs

### TLRMNU00 — Menu Teller

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | TELLEREC (RD)         | TLRSGN00         | COMMENU, BNK0010      |
| cpy-screen   |                       | TLRDEP00         |                       |
| fd-tellerec  |                       | TLRWTH00         |                       |
|              |                       | TLRTRF00         |                       |
|              |                       | TLRPYM00         |                       |
|              |                       | TLRCHE00         |                       |
|              |                       | TLRSMG00         |                       |
|              |                       | COMHELP          |                       |

### TLRSGN00 — Apertura Caja

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | TELLEREC (RD/WR)      | AUDTRL00         | TLRMNU00              |
| fd-tellerec  |                       | COMDATE          |                       |

### TLRDEP00 — Deposito

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW)            | ACTINQ00         | TLRMNU00              |
| fd-account   | TRANLOG (WR)               | AUDTRL00         |                       |
| fd-tranlog   | TELLEREC (RW)              | COMDATE          |                       |
| fd-tellerec  |                            | COMHELP          |                       |

### TLRWTH00 — Retiro

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW)            | ACTBAL00         | TLRMNU00              |
| fd-account   | TRANLOG (WR)               | AUDTRL00         |                       |
| fd-tranlog   | TELLEREC (RW)              | BCHODO00 (opc)   |                       |
| fd-tellerec  |                            |                  |                       |

### TLRTRF00 — Transferencia

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW x2)         | ACTINQ00         | TLRMNU00, LONDIS00   |
| fd-account   | TRANLOG (WR)               | AUDTRL00         |                       |
| fd-tranlog   | TELLEREC (RW)              |                  |                       |
| fd-tellerec  |                            |                  |                       |

### TLRPYM00 — Pago Servicios

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW)            | ACTBAL00         | TLRMNU00              |
| fd-account   | TRANLOG (WR)               | AUDTRL00         |                       |
| fd-tranlog   | TELLEREC (RW)              |                  |                       |
| fd-tellerec  |                            |                  |                       |

### TLRCHE00 — Cobro Cheque

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW)            | ACTINQ00         | TLRMNU00              |
| fd-account   | TRANLOG (WR)               | AUDTRL00         |                       |
| fd-tranlog   | TELLEREC (RW)              |                  |                       |
| fd-tellerec  |                            |                  |                       |

### TLRSMG00 — Resumen/Cierre Caja

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | TELLEREC (RD/RW)      | COMDATE          | TLRMNU00              |
| fd-tellerec  |                       | RPTTLR00         |                       |

---

## 6. Loan Programs

### LONMNU00 — Menu Prestamos

| COPYBOOKS  | Archivos    | CALL a programas                    | Llamado por           |
|------------|-------------|-------------------------------------|-----------------------|
| cpy-common | Ninguno     | LONINQ00, LONAPL00, LONAPV00       | COMMENU, BNK0010      |
| cpy-screen |             | LONDIS00, LONPYM00, LONAMR00       |                       |
|            |             | LONDEL00, COMHELP, COMDATE         |                       |

### LONINQ00 — Consulta Prestamo

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | LOANMAST (RD)         | AUDTRL00         | LONMNU00              |
| fd-loanmast  |                       |                  |                       |

### LONAPL00 — Solicitud Prestamo

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | LOANAPPL (RD/WR)           | CUSSRH00         | LONMNU00, BNK0010     |
| fd-loanappl  | RATEFILE (RD)              | AUDTRL00         |                       |
| fd-ratefile  | CUSTOMER (RD)              | COMDATE          |                       |
| fd-customer  |                            |                  |                       |

### LONAPV00 — Aprobacion Prestamo

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | LOANAPPL (RD/RW)      | AUDTRL00         | LONMNU00              |
| fd-loanappl  |                       | COMHELP          |                       |

### LONDIS00 — Desembolso

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | LOANAPPL (RD/DL)           | TLRTRF00         | LONMNU00              |
| fd-loanappl  | LOANMAST (WR)              | AUDTRL00         |                       |
| fd-loanmast  |                            | COMDATE          |                       |

### LONPYM00 — Pago Prestamo

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | LOANMAST (RD/RW)           | LONAMR00         | LONMNU00, BNK0010     |
| fd-loanmast  | TRANLOG (WR)               | AUDTRL00         |                       |
| fd-tranlog   |                            | COMDATE          |                       |

### LONAMR00 — Tabla Amortizacion

| COPYBOOKS    | Archivos    | CALL a programas | Llamado por           |
|--------------|-------------|------------------|-----------------------|
| cpy-common   | Ninguno     | COMDATE          | LONMNU00, LONPYM00   |

### LONDEL00 — Gestion Mora/Castigo

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | LOANMAST (RD/RW)      | AUDTRL00         | LONMNU00              |
| fd-loanmast  | RATEFILE (RD)         | COMDATE          |                       |
| fd-ratefile  |                       |                  |                       |

---

## 7. Deposit Programs

### DEPMNU00 — Menu Depositos

| COPYBOOKS  | Archivos    | CALL a programas                    | Llamado por           |
|------------|-------------|-------------------------------------|-----------------------|
| cpy-common | Ninguno     | DEPINQ00, DEPOPN00, DEPINT00       | COMMENU, BNK0010      |
| cpy-screen |             | DEPWTH00, DEPSTM00, DEPREN00       |                       |
|            |             | COMHELP, COMDATE                   |                       |

### DEPINQ00 — Consulta Deposito

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | DEPMAST (RD)          | AUDTRL00         | DEPMNU00              |
| fd-depmast   |                       |                  |                       |

### DEPOPN00 — Apertura Deposito

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | DEPMAST (WR)          | CUSSRH00         | DEPMNU00, BNK0010     |
| fd-depmast   | RATEFILE (RD)         | AUDTRL00         |                       |
| fd-ratefile  |                       | COMDATE          |                       |

### DEPINT00 — Tasas de Interes

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | RATEFILE (RD/WR)      | AUDTRL00         | DEPMNU00              |
| fd-ratefile  |                       |                  |                       |

### DEPWTH00 — Reglas Retiro

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | DEPMAST (RD)          | AUDTRL00         | DEPMNU00              |
| fd-depmast   |                       |                  |                       |

### DEPSTM00 — Estado Deposito

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | DEPMAST (RD)          | COMDATE          | DEPMNU00              |
| fd-depmast   |                       |                  |                       |

### DEPREN00 — Renovacion Automatica

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | DEPMAST (RD/RW)       | AUDTRL00         | DEPMNU00              |
| fd-depmast   | RATEFILE (RD)         | COMDATE          |                       |
| fd-ratefile  |                       |                  |                       |

---

## 8. Time Deposit Programs

### TDMNU000 — Menu Plazo Fijo

| COPYBOOKS  | Archivos    | CALL a programas                    | Llamado por           |
|------------|-------------|-------------------------------------|-----------------------|
| cpy-common | Ninguno     | TDOPN000, TDINQ000, TDCLS000       | COMMENU, BNK0010      |
| cpy-screen |             | TDINT000, COMHELP, COMDATE         |                       |

### TDOPN000 — Apertura CD

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | TIMEDEP (WR)          | CUSSRH00         | TDMNU000, BNK0010     |
| fd-timedep   | RATEFILE (RD)         | AUDTRL00         |                       |
| fd-ratefile  | TRANLOG (WR)          | COMDATE          |                       |
| fd-tranlog   |                       |                  |                       |

### TDINQ000 — Consulta CD

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | TIMEDEP (RD)          | AUDTRL00         | TDMNU000              |
| fd-timedep   |                       |                  |                       |

### TDCLS000 — Liquidacion CD

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | TIMEDEP (RD/RW)       | ACTBAL00         | TDMNU000              |
| fd-timedep   |                       | AUDTRL00         |                       |
|              |                       | COMDATE          |                       |

### TDINT000 — Calculo Interes CD

| COPYBOOKS    | Archivos    | CALL a programas | Llamado por           |
|--------------|-------------|------------------|-----------------------|
| cpy-common   | Ninguno     | COMDATE          | TDMNU000              |
| fd-timedep   |             |                  |                       |

---

## 9. Transfer Programs

### FTMNU000 — Menu Transferencias

| COPYBOOKS  | Archivos    | CALL a programas                    | Llamado por           |
|------------|-------------|-------------------------------------|-----------------------|
| cpy-common | Ninguno     | FTINT000, FTWIR000, FTACH000       | COMMENU, BNK0010      |
| cpy-screen |             | FTSTS000, COMHELP, COMDATE         |                       |

### FTINT000 — Transferencia Interna

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW x2)         | ACTBAL00         | FTMNU000              |
| fd-account   | TRANLOG (WR)               | AUDTRL00         |                       |
| fd-tranlog   |                            |                  |                       |

### FTWIR000 — Transferencia Wire (SWIFT)

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW)            | ACTBAL00         | FTMNU000              |
| fd-account   | TRANLOG (WR)               | ACTUPD00         |                       |
| fd-tranlog   |                            | AUDTRL00         |                       |
|              |                            | COMHELP          |                       |

### FTACH000 — Transferencia ACH

| COPYBOOKS    | Archivos                   | CALL a programas | Llamado por           |
|--------------|----------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW)            | ACTBAL00         | FTMNU000              |
| fd-account   | TRANLOG (WR)               | AUDTRL00         |                       |
| fd-tranlog   |                            |                  |                       |

### FTSTS000 — Estado Transferencia

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | TRANLOG (RD)          | AUDTRL00         | FTMNU000              |
| fd-tranlog   |                       |                  |                       |

---

## 10. Batch Programs

### BCHMNU00 — Menu Batch

| COPYBOOKS  | Archivos    | CALL a programas                    | Llamado por           |
|------------|-------------|-------------------------------------|-----------------------|
| cpy-common | Ninguno     | BCHDAY00, BCHMTH00, BCHINT00       | COMMENU, BNK0010      |
| cpy-screen |             | BCHGLI00, BCHODO00, BCHFEE00       |                       |
|            |             | COMHELP, COMDATE                   |                       |

### BCHDAY00 — Cierre Diario

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | BATCHCTL (RD/RW)          | BCHINT00         | BCHMNU00              |
| fd-batchctl  | TRANLOG (RD/ST/RN)        | BCHODO00         |                       |
| fd-tranlog   |                           | BCHFEE00         |                       |
|              |                           | BCHGLI00         |                       |
|              |                           | RPTTXN00         |                       |
|              |                           | RPTBAL00         |                       |
|              |                           | AUDTRL00         |                       |
|              |                           | COMDATE          |                       |

### BCHMTH00 — Cierre Mensual

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | BATCHCTL (RD/RW)          | BCHINT00         | BCHMNU00              |
| fd-batchctl  | TRANLOG (RD/ST/RN)        | BCHGLI00         |                       |
| fd-tranlog   |                           | RPTGLB00         |                       |
|              |                           | RPTREG00         |                       |
|              |                           | AUDTRL00         |                       |
|              |                           | COMDATE          |                       |

### BCHINT00 — Devengo Intereses

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW/ST/RN)     | Ninguno          | BCHDAY00, BCHMTH00,  |
| fd-account   | GLMASTER (RD/RW)          |                  | BCHMNU00              |
| fd-glmaster  | RATEFILE (RD)             |                  |                       |
| fd-ratefile  | TRANLOG (WR)              |                  |                       |
| fd-tranlog   |                           |                  |                       |

### BCHGLI00 — Interface GL

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/ST/RN)        | Ninguno          | BCHDAY00, BCHMTH00,  |
| fd-account   | GLMASTER (RD/RW)          |                  | BCHMNU00              |
| fd-glmaster  | TRANLOG (RD/ST/RN)        |                  |                       |
| fd-tranlog   |                           |                  |                       |

### BCHODO00 — Calculo Sobregiro/Mora

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW/ST/RN)     | Ninguno          | BCHDAY00, BCHMNU00,  |
| fd-account   | RATEFILE (RD)             |                  | ACTBAL00, TLRWTH00   |
| fd-ratefile  | TRANLOG (WR)              |                  |                       |
| fd-tranlog   |                           |                  |                       |

### BCHFEE00 — Comisiones Periodicas

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (RD/RW/ST/RN)     | Ninguno          | BCHDAY00, BCHMNU00   |
| fd-account   | FEESCHED (RD)             |                  |                       |
| fd-feeschd   | TRANLOG (WR)              |                  |                       |
| fd-tranlog   |                           |                  |                       |

---

## 11. Report Programs

### RPTMNU00 — Menu Reportes

| COPYBOOKS  | Archivos    | CALL a programas                    | Llamado por           |
|------------|-------------|-------------------------------------|-----------------------|
| cpy-common | Ninguno     | RPTBAL00, RPTTXN00, RPTDEL00       | COMMENU, BNK0010      |
| cpy-screen |             | RPTTLR00, RPTGLB00, RPTREG00       |                       |
|            |             | COMHELP, COMDATE                   |                       |

### RPTBAL00 — Balance General

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | ACCOUNT (ST/RN)           | COMDATE          | RPTMNU00, BCHDAY00   |
| fd-account   | GLMASTER (RD/ST/RN)       |                  |                       |
| fd-glmaster  |                           |                  |                       |

### RPTTXN00 — Transacciones Diarias

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | TRANLOG (ST/RN)           | COMDATE          | RPTMNU00, BCHDAY00   |
| fd-tranlog   |                           |                  |                       |

### RPTDEL00 — Cartera Vencida

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | LOANMAST (ST/RN)          | COMDATE          | RPTMNU00              |
| fd-loanmast  |                           |                  |                       |

### RPTTLR00 — Cuadre Caja

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | TELLEREC (ST/RN)          | COMDATE          | RPTMNU00, TLRSMG00   |
| fd-tellerec  |                           |                  |                       |

### RPTGLB00 — Trial Balance

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | GLMASTER (ST/RN)          | COMDATE          | RPTMNU00              |
| fd-glmaster  |                           |                  |                       |

### RPTREG00 — Reportes Regulatorios

| COPYBOOKS    | Archivos                  | CALL a programas | Llamado por           |
|--------------|---------------------------|------------------|-----------------------|
| cpy-common   | LOANMAST (ST/RN)          | COMDATE          | RPTMNU00              |
| fd-loanmast  | ACCOUNT (ST/RN)           |                  |                       |
| fd-account   | DEPMAST (ST/RN)           |                  |                       |
| fd-depmast   |                           |                  |                       |

---

## 12. Audit Programs

### AUDTRL00 — Escribir Auditoria

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por                     |
|--------------|-----------------------|------------------|---------------------------------|
| cpy-common   | AUDITLOG (WR)         | Ninguno          | TODOS los programas             |
| fd-auditlog  |                       |                  | transaccionales                 |

### AUDINQ00 — Consulta Auditoria

| COPYBOOKS    | Archivos              | CALL a programas | Llamado por           |
|--------------|-----------------------|------------------|-----------------------|
| cpy-common   | AUDITLOG (ST/RN)      | COMDATE          | SECMNU00, BNK0010     |
| fd-auditlog  |                       |                  |                       |

---

## Resumen de Dependencias

| Componente     | COPYBOOKS | Archivos | CALL to | CALL from |
|----------------|-----------|----------|---------|-----------|
| Common (10)    | 2-4 c/u   | 0-3      | 0-12    | 1-75      |
| Security (8)   | 2-3 c/u   | 1-2      | 1-3     | 1-2       |
| Customer (7)   | 2-3 c/u   | 0-2      | 1-3     | 1-3       |
| Account (8)    | 2-4 c/u   | 0-3      | 1-3     | 2-5       |
| Teller (8)     | 3-4 c/u   | 2-4      | 2-4     | 1         |
| Loans (7)      | 2-4 c/u   | 0-3      | 1-3     | 1-3       |
| Deposits (6)   | 2-3 c/u   | 1-2      | 1-3     | 1         |
| TimeDep (4)    | 2-3 c/u   | 1-3      | 2-3     | 1         |
| Transfer (4)   | 2-3 c/u   | 2-3      | 2-3     | 1         |
| Batch (6)      | 2-4 c/u   | 2-4      | 0-7     | 1-3       |
| Reports (6)    | 2-3 c/u   | 1-2      | 1       | 1-2       |
| Audit (2)      | 2 c/u     | 1        | 0       | 60+       |

**Total relaciones CALL**: ~180
**Total COPYBOOK incluidos**: ~150
**Total operaciones archivo**: ~250
