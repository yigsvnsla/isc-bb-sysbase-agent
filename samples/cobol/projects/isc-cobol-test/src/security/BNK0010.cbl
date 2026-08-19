      *================================================================*
      * BNK0010 - MENU PRINCIPAL DEL SISTEMA                          *
      * PROPOSITO: NAVEGACION CENTRAL, 60 OPCIONES, SUBMENUS          *
      * EQUIPO: ARQUITECTURA - 2001 (REFACTOR 2006)                  *
      * ARCHIVOS: NINGUNO (SOLO CALL A PROGRAMAS)                     *
      * LLAMADO DESDE: COMMENU / BNK0001                              *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BNK0010.
      *================================================================*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF1                VALUE 1001.
           88  WS-CRT-PF2                VALUE 1002.
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF4                VALUE 1004.
           88  WS-CRT-PF5                VALUE 1005.
           88  WS-CRT-PF6                VALUE 1006.
           88  WS-CRT-PF7                VALUE 1007.
           88  WS-CRT-PF8                VALUE 1008.
           88  WS-CRT-PF9                VALUE 1009.
           88  WS-CRT-PF10               VALUE 1010.
           88  WS-CRT-PF11               VALUE 1011.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
           88  WS-CRT-CLEAR              VALUE 0000.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-SUCURSAL                PIC X(04).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-OPCION                  PIC 9(02).
           05  WS-OPCION-DISPLAY          PIC Z9.
           05  WS-PAGINA                  PIC 9(01) VALUE 1.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-NOMBRE-PROG             PIC X(08).
           05  WS-DUMMY                   PIC X(01).
           05  WS-SESSION-CHECK           PIC X(01).
      *
      *--- TABLA DE OPCIONES DEL MENU ---*
       01  WS-OPCIONES-TABLA.
           05  WS-OPC-ENTRY              OCCURS 60.
               10  WS-OPC-COD            PIC 9(02).
               10  WS-OPC-DESC           PIC X(30).
               10  WS-OPC-PROG           PIC X(08).
               10  WS-OPC-TIPO           PIC X(01).
                   88  WS-OPC-MENU       VALUE 'M'.
                   88  WS-OPC-PROGRAMA   VALUE 'P'.
                   88  WS-OPC-SALIDA     VALUE 'S'.
                   88  WS-OPC-NO-IMP     VALUE 'N'.
               10  WS-OPC-GRUPO          PIC X(02).
      *
       01  WS-OPC-DATOS.
           05  FILLER PIC 99 VALUE 01.
           05  FILLER PIC X(30) VALUE 'ALTA DE CLIENTE'.
           05  FILLER PIC X(08) VALUE 'CUSMNT00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CL'.
      *
           05  FILLER PIC 99 VALUE 02.
           05  FILLER PIC X(30) VALUE 'CONSULTA DE CLIENTE'.
           05  FILLER PIC X(08) VALUE 'CUSINQ00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CL'.
      *
           05  FILLER PIC 99 VALUE 03.
           05  FILLER PIC X(30) VALUE 'MODIFICACION DE CLIENTE'.
           05  FILLER PIC X(08) VALUE 'CUSUPD00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CL'.
      *
           05  FILLER PIC 99 VALUE 04.
           05  FILLER PIC X(30) VALUE 'BAJA DE CLIENTE'.
           05  FILLER PIC X(08) VALUE 'CUSSTS00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CL'.
      *
           05  FILLER PIC 99 VALUE 05.
           05  FILLER PIC X(30) VALUE 'BUSQUEDA DE CLIENTE'.
           05  FILLER PIC X(08) VALUE 'CUSSRH00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CL'.
      *
           05  FILLER PIC 99 VALUE 06.
           05  FILLER PIC X(30) VALUE 'MANTENIMIENTO DIRECCIONES'.
           05  FILLER PIC X(08) VALUE 'CUSADR00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CL'.
      *
           05  FILLER PIC 99 VALUE 07.
           05  FILLER PIC X(30) VALUE 'RELACIONES / BENEFICIARIOS'.
           05  FILLER PIC X(08) VALUE 'CUSREL00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CL'.
      *
           05  FILLER PIC 99 VALUE 08.
           05  FILLER PIC X(30) VALUE 'CAMBIO DE ESTATUS CLIENTE'.
           05  FILLER PIC X(08) VALUE 'CUSSTS00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CL'.
      *
           05  FILLER PIC 99 VALUE 09.
           05  FILLER PIC X(30) VALUE 'APERTURA DE CUENTA'.
           05  FILLER PIC X(08) VALUE 'ACTOPN00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CT'.
      *
           05  FILLER PIC 99 VALUE 10.
           05  FILLER PIC X(30) VALUE 'CONSULTA DE CUENTA'.
           05  FILLER PIC X(08) VALUE 'ACTINQ00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CT'.
      *
           05  FILLER PIC 99 VALUE 11.
           05  FILLER PIC X(30) VALUE 'MODIFICACION DE CUENTA'.
           05  FILLER PIC X(08) VALUE 'ACTUPD00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CT'.
      *
           05  FILLER PIC 99 VALUE 12.
           05  FILLER PIC X(30) VALUE 'CIERRE DE CUENTA'.
           05  FILLER PIC X(08) VALUE 'ACTCLS00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CT'.
      *
           05  FILLER PIC 99 VALUE 13.
           05  FILLER PIC X(30) VALUE 'CONGELAR / DESCONGELAR'.
           05  FILLER PIC X(08) VALUE 'ACTFRZ00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CT'.
      *
           05  FILLER PIC 99 VALUE 14.
           05  FILLER PIC X(30) VALUE 'CONSULTA DE SALDO'.
           05  FILLER PIC X(08) VALUE 'ACTBAL00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CT'.
      *
           05  FILLER PIC 99 VALUE 15.
           05  FILLER PIC X(30) VALUE 'ESTADO DE CUENTA'.
           05  FILLER PIC X(08) VALUE 'ACTSTM00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CT'.
      *
           05  FILLER PIC 99 VALUE 16.
           05  FILLER PIC X(30) VALUE 'ADMINISTRACION CHEQUERAS'.
           05  FILLER PIC X(08) VALUE 'ACTUPD00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'CT'.
      *
           05  FILLER PIC 99 VALUE 17.
           05  FILLER PIC X(30) VALUE 'APERTURA DE CAJA'.
           05  FILLER PIC X(08) VALUE 'TLRSGN00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TL'.
      *
           05  FILLER PIC 99 VALUE 18.
           05  FILLER PIC X(30) VALUE 'DEPOSITO EN EFECTIVO'.
           05  FILLER PIC X(08) VALUE 'TLRDEP00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TL'.
      *
           05  FILLER PIC 99 VALUE 19.
           05  FILLER PIC X(30) VALUE 'RETIRO EN EFECTIVO'.
           05  FILLER PIC X(08) VALUE 'TLRWTH00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TL'.
      *
           05  FILLER PIC 99 VALUE 20.
           05  FILLER PIC X(30) VALUE 'TRANSFERENCIA ENTRE CUENTAS'.
           05  FILLER PIC X(08) VALUE 'TLRTRF00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TL'.
      *
           05  FILLER PIC 99 VALUE 21.
           05  FILLER PIC X(30) VALUE 'PAGO DE SERVICIOS'.
           05  FILLER PIC X(08) VALUE 'TLRPYM00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TL'.
      *
           05  FILLER PIC 99 VALUE 22.
           05  FILLER PIC X(30) VALUE 'COBRO DE CHEQUE'.
           05  FILLER PIC X(08) VALUE 'TLRCHE00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TL'.
      *
           05  FILLER PIC 99 VALUE 23.
           05  FILLER PIC X(30) VALUE 'PAGO DE PRESTAMO'.
           05  FILLER PIC X(08) VALUE 'LONPYM00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TL'.
      *
           05  FILLER PIC 99 VALUE 24.
           05  FILLER PIC X(30) VALUE 'RESUMEN / CIERRE CAJA'.
           05  FILLER PIC X(08) VALUE 'TLRSMG00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TL'.
      *
           05  FILLER PIC 99 VALUE 25.
           05  FILLER PIC X(30) VALUE 'SOLICITUD DE PRESTAMO'.
           05  FILLER PIC X(08) VALUE 'LONAPL00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'PR'.
      *
           05  FILLER PIC 99 VALUE 26.
           05  FILLER PIC X(30) VALUE 'APROBACION DE PRESTAMO'.
           05  FILLER PIC X(08) VALUE 'LONAPV00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'PR'.
      *
           05  FILLER PIC 99 VALUE 27.
           05  FILLER PIC X(30) VALUE 'DESEMBOLSO DE PRESTAMO'.
           05  FILLER PIC X(08) VALUE 'LONDIS00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'PR'.
      *
           05  FILLER PIC 99 VALUE 28.
           05  FILLER PIC X(30) VALUE 'CONSULTA DE PRESTAMO'.
           05  FILLER PIC X(08) VALUE 'LONINQ00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'PR'.
      *
           05  FILLER PIC 99 VALUE 29.
           05  FILLER PIC X(30) VALUE 'PAGO DE CUOTA'.
           05  FILLER PIC X(08) VALUE 'LONPYM00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'PR'.
      *
           05  FILLER PIC 99 VALUE 30.
           05  FILLER PIC X(30) VALUE 'TABLA DE AMORTIZACION'.
           05  FILLER PIC X(08) VALUE 'LONAMR00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'PR'.
      *
           05  FILLER PIC 99 VALUE 31.
           05  FILLER PIC X(30) VALUE 'GESTION DE MORA / CASTIGO'.
           05  FILLER PIC X(08) VALUE 'LONDEL00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'PR'.
      *
           05  FILLER PIC 99 VALUE 32.
           05  FILLER PIC X(30) VALUE 'APERTURA DE DEPOSITO'.
           05  FILLER PIC X(08) VALUE 'DEPOPN00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'DP'.
      *
           05  FILLER PIC 99 VALUE 33.
           05  FILLER PIC X(30) VALUE 'CONSULTA DE DEPOSITO'.
           05  FILLER PIC X(08) VALUE 'DEPINQ00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'DP'.
      *
           05  FILLER PIC 99 VALUE 34.
           05  FILLER PIC X(30) VALUE 'TASAS DE INTERES'.
           05  FILLER PIC X(08) VALUE 'DEPINT00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'DP'.
      *
           05  FILLER PIC 99 VALUE 35.
           05  FILLER PIC X(30) VALUE 'RENOVACION DE DEPOSITO'.
           05  FILLER PIC X(08) VALUE 'DEPREN00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'DP'.
      *
           05  FILLER PIC 99 VALUE 36.
           05  FILLER PIC X(30) VALUE 'CANCELACION DE DEPOSITO'.
           05  FILLER PIC X(08) VALUE 'ACTCLS00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'DP'.
      *
           05  FILLER PIC 99 VALUE 37.
           05  FILLER PIC X(30) VALUE 'APERTURA CERTIF. DEPOSITO'.
           05  FILLER PIC X(08) VALUE 'TDOPN000'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TD'.
      *
           05  FILLER PIC 99 VALUE 38.
           05  FILLER PIC X(30) VALUE 'CONSULTA DE CD'.
           05  FILLER PIC X(08) VALUE 'TDINQ000'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TD'.
      *
           05  FILLER PIC 99 VALUE 39.
           05  FILLER PIC X(30) VALUE 'LIQUIDACION DE CD'.
           05  FILLER PIC X(08) VALUE 'TDCLS000'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TD'.
      *
           05  FILLER PIC 99 VALUE 40.
           05  FILLER PIC X(30) VALUE 'CALCULO DE INTERES CD'.
           05  FILLER PIC X(08) VALUE 'TDINT000'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TD'.
      *
           05  FILLER PIC 99 VALUE 41.
           05  FILLER PIC X(30) VALUE 'TRANSFERENCIA INTERNA'.
           05  FILLER PIC X(08) VALUE 'FTINT000'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TF'.
      *
           05  FILLER PIC 99 VALUE 42.
           05  FILLER PIC X(30) VALUE 'TRANSFERENCIA WIRE'.
           05  FILLER PIC X(08) VALUE 'FTWIR000'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TF'.
      *
           05  FILLER PIC 99 VALUE 43.
           05  FILLER PIC X(30) VALUE 'TRANSFERENCIA ACH'.
           05  FILLER PIC X(08) VALUE 'FTACH000'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TF'.
      *
           05  FILLER PIC 99 VALUE 44.
           05  FILLER PIC X(30) VALUE 'CONSULTA TRANSFERENCIA'.
           05  FILLER PIC X(08) VALUE 'FTSTS000'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'TF'.
      *
           05  FILLER PIC 99 VALUE 45.
           05  FILLER PIC X(30) VALUE 'CIERRE DIARIO'.
           05  FILLER PIC X(08) VALUE 'BCHDAY00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'BC'.
      *
           05  FILLER PIC 99 VALUE 46.
           05  FILLER PIC X(30) VALUE 'CIERRE MENSUAL'.
           05  FILLER PIC X(08) VALUE 'BCHMTH00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'BC'.
      *
           05  FILLER PIC 99 VALUE 47.
           05  FILLER PIC X(30) VALUE 'INTERESES Y MORA'.
           05  FILLER PIC X(08) VALUE 'BCHINT00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'BC'.
      *
           05  FILLER PIC 99 VALUE 48.
           05  FILLER PIC X(30) VALUE 'PASE CONTABLE GL'.
           05  FILLER PIC X(08) VALUE 'BCHGLI00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'BC'.
      *
           05  FILLER PIC 99 VALUE 49.
           05  FILLER PIC X(30) VALUE 'COMISIONES PERIODICAS'.
           05  FILLER PIC X(08) VALUE 'BCHFEE00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'BC'.
      *
           05  FILLER PIC 99 VALUE 50.
           05  FILLER PIC X(30) VALUE 'BALANCE GENERAL'.
           05  FILLER PIC X(08) VALUE 'RPTBAL00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'RP'.
      *
           05  FILLER PIC 99 VALUE 51.
           05  FILLER PIC X(30) VALUE 'TRANSACCIONES DIARIAS'.
           05  FILLER PIC X(08) VALUE 'RPTTXN00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'RP'.
      *
           05  FILLER PIC 99 VALUE 52.
           05  FILLER PIC X(30) VALUE 'CARTERA VENCIDA'.
           05  FILLER PIC X(08) VALUE 'RPTDEL00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'RP'.
      *
           05  FILLER PIC 99 VALUE 53.
           05  FILLER PIC X(30) VALUE 'CUADRE DE CAJA'.
           05  FILLER PIC X(08) VALUE 'RPTTLR00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'RP'.
      *
           05  FILLER PIC 99 VALUE 54.
           05  FILLER PIC X(30) VALUE 'TRIAL BALANCE'.
           05  FILLER PIC X(08) VALUE 'RPTGLB00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'RP'.
      *
           05  FILLER PIC 99 VALUE 55.
           05  FILLER PIC X(30) VALUE 'REPORTES REGULATORIOS'.
           05  FILLER PIC X(08) VALUE 'RPTREG00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'RP'.
      *
           05  FILLER PIC 99 VALUE 56.
           05  FILLER PIC X(30) VALUE 'ALTA DE USUARIO'.
           05  FILLER PIC X(08) VALUE 'SECUSR00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'SG'.
      *
           05  FILLER PIC 99 VALUE 57.
           05  FILLER PIC X(30) VALUE 'CONSULTA DE USUARIO'.
           05  FILLER PIC X(08) VALUE 'SECUSR00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'SG'.
      *
           05  FILLER PIC 99 VALUE 58.
           05  FILLER PIC X(30) VALUE 'CAMBIO DE PASSWORD'.
           05  FILLER PIC X(08) VALUE 'SECPWD00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'SG'.
      *
           05  FILLER PIC 99 VALUE 59.
           05  FILLER PIC X(30) VALUE 'AUDITORIA DE SESIONES'.
           05  FILLER PIC X(08) VALUE 'SECAUD00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'SG'.
      *
           05  FILLER PIC 99 VALUE 60.
           05  FILLER PIC X(30) VALUE 'PARAMETROS DEL SISTEMA'.
           05  FILLER PIC X(08) VALUE 'SECMNU00'.
           05  FILLER PIC X VALUE 'P'.
           05  FILLER PIC XX VALUE 'SG'.
      *
           05  FILLER PIC 99 VALUE 99.
           05  FILLER PIC X(30) VALUE 'SALIR DEL SISTEMA'.
           05  FILLER PIC X(08) VALUE 'BNK0001'.
           05  FILLER PIC X VALUE 'S'.
           05  FILLER PIC XX VALUE 'XX'.
      *
       01  WS-OPC-TABLA REDEFINES WS-OPC-DATOS.
           05  WS-OPC-REG                 OCCURS 61.
               10  WS-OPC-COD-REG         PIC 9(02).
               10  WS-OPC-DESC-REG        PIC X(30).
               10  WS-OPC-PROG-REG        PIC X(08).
               10  WS-OPC-TIPO-REG        PIC X(01).
               10  WS-OPC-GRUPO-REG       PIC X(02).
      *
       01  WS-PAGINA-TABLA.
           05  WS-PAG-ENTRY              OCCURS 3.
               10  WS-PAG-FROM            PIC 99.
               10  WS-PAG-TO              PIC 99.
      *
       01  WS-PAG-DATOS.
           05  FILLER PIC 99 VALUE 01.
           05  FILLER PIC 99 VALUE 22.
           05  FILLER PIC 99 VALUE 23.
           05  FILLER PIC 99 VALUE 44.
           05  FILLER PIC 99 VALUE 45.
           05  FILLER PIC 99 VALUE 61.
      *
       01  WS-PAG-REG REDEFINES WS-PAG-DATOS.
           05  WS-PAG-REG-ENTRY           OCCURS 3.
               10  WS-PAG-FROM-REG        PIC 99.
               10  WS-PAG-TO-REG          PIC 99.
      *
       01  WS-LINEA                       PIC 9(02).
       01  WS-COLUMNA                     PIC 9(02).
       01  WS-I                           PIC 9(02).
       01  WS-J                           PIC 9(02).
       01  WS-K                           PIC 9(02).
       01  WS-CONTADOR                    PIC 9(02).
       01  WS-OPC-ENCONTRADO              PIC X(01).
           88  WS-OPC-EXISTE              VALUE 'S'.
           88  WS-OPC-NO-EXISTE           VALUE 'N'.
       01  WS-PROGRAMA-ENCONTRADO         PIC X(01).
       01  WS-FIRMA                       PIC X(08) VALUE 'BNK0010'.
      *
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-MENU.
           05  SCR-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' MENU PRINCIPAL DE OPERACIONES'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
               10  LINE 02  COL 70  PIC X(04) FROM WS-SUCURSAL.
      *
           05  SCR-OPTIONS                OCCURS 20.
               10  SCR-OPT-LINE           PIC 99 FROM WS-OPC-COD-REG
                                          OCCURS 1 TO 20
                                          DEPENDING ON WS-CONTADOR.
               10  SCR-OPT-DESC           PIC X(30) FROM WS-OPC-DESC-REG.
      *
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF1=CLI  PF2=CTA  PF3=CAJA  PF4=PREST  PF5=DEP'.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF1=CLI  PF2=CTA  PF3=CAJA  PF4=PREST  PF5=DE'.
      *
      *--- PANTALLA DE SUBMUESTRA POR GRUPO ---*
       01  SCR-SUBMENU.
           05  SCR-SUB-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - SUBMENU'.
               10  LINE 01  COL 65  PIC X(08) FROM WS-USUARIO.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' '.
           05  SCR-SUB-LINEAS.
               10  LINE 04  COL 05  PIC X(30) VALUE 'CODIGO  OPCION'.
               10  LINE 05  COL 05  PIC X(30)
                   VALUE '------  ------------------------------'.
               10  LINE 06  COL 05  PIC X(30)
                   FROM WS-OPC-DESC-REG.
      *
       01  SCR-SESION-TERMINO.
           05  LINE 10  COL 10  PIC X(50)
               VALUE 'SESION FINALIZADA. GRACIAS POR SU VISITA.'.
           05  LINE 12  COL 10  PIC X(40)
               VALUE 'PRESIONE ENTER PARA CONTINUAR...'.
      *
      *================================================================*
       PROCEDURE DIVISION.
      *
       MAIN.
           MOVE SPACES TO WS-USUARIO WS-SUCURSAL WS-MENSAJE.
           MOVE 99 TO WS-RETCODE.
           MOVE 1 TO WS-PAGINA.
      *
           CALL 'BNK0001' USING WS-USUARIO
                                 WS-SUCURSAL
                                 WS-RETCODE.
           IF WS-RETCODE NOT = 00
               MOVE 'ACCESO DENEGADO AL SISTEMA' TO WS-MENSAJE
               DISPLAY SCR-SESION-TERMINO
               ACCEPT SCR-SESION-TERMINO
               STOP RUN
           END-IF.
      *
           PERFORM 1000-INICIALIZAR-VENTANA.
           PERFORM 2000-REFRESCAR-PANTALLA.
      *
       MENU-PRINCIPAL.
           PERFORM 1500-ACTUALIZAR-CABECERA.
           PERFORM 2500-MOSTRAR-PAGINA.
           DISPLAY SCR-MENU.
           ACCEPT SCR-MENU.
      *
           IF WS-CRT-ENTER
               PERFORM 3000-EJECUTAR-OPCION
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF1
               MOVE 1 TO WS-PAGINA
               PERFORM 2500-MOSTRAR-PAGINA
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF2
               MOVE 2 TO WS-PAGINA
               PERFORM 2500-MOSTRAR-PAGINA
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF3
               MOVE 3 TO WS-PAGINA
               PERFORM 2500-MOSTRAR-PAGINA
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF4
               PERFORM 4000-SUBMENU-PRESTAMOS
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF5
               PERFORM 4500-SUBMENU-DEPOSITOS
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF6
               PERFORM 4600-SUBMENU-BATCH
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF7
               IF WS-PAGINA > 1
                   SUBTRACT 1 FROM WS-PAGINA
                   PERFORM 2500-MOSTRAR-PAGINA
               ELSE
                   MOVE 'YA ESTA EN LA PRIMERA PAGINA'
                     TO WS-MENSAJE-ERROR
               END-IF
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF8
               IF WS-PAGINA < 3
                   ADD 1 TO WS-PAGINA
                   PERFORM 2500-MOSTRAR-PAGINA
               ELSE
                   MOVE 'YA ESTA EN LA ULTIMA PAGINA'
                     TO WS-MENSAJE-ERROR
               END-IF
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF11
               CALL 'COMHELP' USING 'GENERAL'
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-PF12
               PERFORM 5000-CONFIRMAR-SALIDA
               IF WS-RETCODE = 00
                   PERFORM 9000-FINALIZAR
               END-IF
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           IF WS-CRT-CLEAR
               MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
               GO TO MENU-PRINCIPAL
           END-IF.
      *
           MOVE 'OPCION NO VALIDA - INGRESE CODIGO O USE PF'
             TO WS-MENSAJE-ERROR.
           GO TO MENU-PRINCIPAL.
      *
      *--- INICIALIZAR PANTALLA Y FECHA ---*
       1000-INICIALIZAR-VENTANA.
           PERFORM 1100-LIMPIAR.
           PERFORM 1500-ACTUALIZAR-CABECERA.
           MOVE 'BIENVENIDO - INGRESE CODIGO DE OPCION O PF'
             TO WS-MENSAJE.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       1500-ACTUALIZAR-CABECERA.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
      *
       2000-REFRESCAR-PANTALLA.
           PERFORM 1100-LIMPIAR.
           PERFORM 1500-ACTUALIZAR-CABECERA.
           PERFORM 2500-MOSTRAR-PAGINA.
      *
      *--- MOSTRAR OPCIONES DE LA PAGINA ACTUAL ---*
       2500-MOSTRAR-PAGINA.
           MOVE SPACES TO WS-MENSAJE-ERROR.
           MOVE WS-PAG-FROM-REG(WS-PAGINA) TO WS-I.
           MOVE WS-PAG-TO-REG(WS-PAGINA) TO WS-J.
           MOVE 0 TO WS-CONTADOR.
      *
           PERFORM VARYING WS-K FROM WS-I BY 1
               UNTIL WS-K > WS-J
               ADD 1 TO WS-CONTADOR
           END-PERFORM.
      *
           MOVE 1 TO WS-K.
           MOVE 5 TO WS-LINEA.
           MOVE 3 TO WS-COLUMNA.
      *
           PERFORM VARYING WS-K FROM WS-I BY 1
               UNTIL WS-K > WS-J
               ADD 1 TO WS-CONTADOR
               DISPLAY WS-OPC-COD-REG(WS-K) AT LINE WS-LINEA
                       COLUMN WS-COLUMNA
               ADD 2 TO WS-COLUMNA
               DISPLAY '-' AT LINE WS-LINEA COLUMN WS-COLUMNA
               ADD 1 TO WS-COLUMNA
               DISPLAY WS-OPC-DESC-REG(WS-K) AT LINE WS-LINEA
                       COLUMN WS-COLUMNA
               ADD 1 TO WS-LINEA
               MOVE 3 TO WS-COLUMNA
           END-PERFORM.
      *
           STRING 'PAGINA ' WS-PAGINA ' DE 3  '
                  'PF7=PAG-ANT  PF8=PAG-SIG  PF11=AYU  PF12=SALIR'
             INTO WS-MENSAJE.
      *
      *--- EJECUTAR OPCION SELECCIONADA ---*
       3000-EJECUTAR-OPCION.
           MOVE 'N' TO WS-OPC-ENCONTRADO.
           MOVE SPACES TO WS-MENSAJE-ERROR.
           MOVE WS-OPCION TO WS-OPCION-DISPLAY.
      *
           IF WS-OPCION = 00 OR WS-OPCION > 99
               MOVE 'CODIGO INVALIDO - USE 01-99' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT
           END-IF.
      *
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 61
               IF WS-OPC-COD-REG(WS-I) = WS-OPCION
                   MOVE 'S' TO WS-OPC-ENCONTRADO
                   MOVE WS-OPC-PROG-REG(WS-I) TO WS-NOMBRE-PROG
                   MOVE WS-OPC-TIPO-REG(WS-I) TO WS-PROGRAMA-ENCONTRADO
                   EXIT PERFORM
               END-IF
           END-PERFORM.
      *
           IF WS-OPC-NO-EXISTE
               MOVE 'CODIGO NO REGISTRADO' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT
           END-IF.
      *
           IF WS-PROGRAMA-ENCONTRADO = 'S'
               MOVE 'CERRANDO SESION...' TO WS-MENSAJE
               PERFORM 5000-CONFIRMAR-SALIDA
               IF WS-RETCODE = 00
                   PERFORM 9000-FINALIZAR
               END-IF
               GOTO 3000-EXIT
           END-IF.
      *
           PERFORM 3500-VALIDAR-Y-EJECUTAR.
      *
       3000-EXIT.
           EXIT.
      *
      *--- VALIDAR Y LLAMAR PROGRAMA ---*
       3500-VALIDAR-Y-EJECUTAR.
           MOVE SPACES TO WS-MENSAJE.
      *
           EVALUATE WS-NOMBRE-PROG
               WHEN 'CUSMNT00'
                   CALL 'CUSMNT00' USING WS-USUARIO WS-RETCODE
               WHEN 'CUSINQ00'
                   CALL 'CUSINQ00' USING WS-USUARIO WS-RETCODE
               WHEN 'CUSUPD00'
                   CALL 'CUSUPD00' USING WS-USUARIO WS-RETCODE
               WHEN 'CUSSTS00'
                   CALL 'CUSSTS00' USING WS-USUARIO WS-RETCODE
               WHEN 'CUSSRH00'
                   CALL 'CUSSRH00' USING WS-USUARIO WS-RETCODE
               WHEN 'CUSADR00'
                   CALL 'CUSADR00' USING WS-USUARIO WS-RETCODE
               WHEN 'CUSREL00'
                   CALL 'CUSREL00' USING WS-USUARIO WS-RETCODE
               WHEN 'ACTOPN00'
                   CALL 'ACTOPN00' USING WS-USUARIO WS-RETCODE
               WHEN 'ACTINQ00'
                   CALL 'ACTINQ00' USING WS-USUARIO WS-RETCODE
               WHEN 'ACTUPD00'
                   CALL 'ACTUPD00' USING WS-USUARIO WS-RETCODE
               WHEN 'ACTCLS00'
                   CALL 'ACTCLS00' USING WS-USUARIO WS-RETCODE
               WHEN 'ACTFRZ00'
                   CALL 'ACTFRZ00' USING WS-USUARIO WS-RETCODE
               WHEN 'ACTBAL00'
                   CALL 'ACTBAL00' USING WS-USUARIO WS-RETCODE
               WHEN 'ACTSTM00'
                   CALL 'ACTSTM00' USING WS-USUARIO WS-RETCODE
               WHEN 'TLRSGN00'
                   CALL 'TLRSGN00' USING WS-USUARIO WS-RETCODE
               WHEN 'TLRDEP00'
                   CALL 'TLRDEP00' USING WS-USUARIO WS-RETCODE
               WHEN 'TLRWTH00'
                   CALL 'TLRWTH00' USING WS-USUARIO WS-RETCODE
               WHEN 'TLRTRF00'
                   CALL 'TLRTRF00' USING WS-USUARIO WS-RETCODE
               WHEN 'TLRPYM00'
                   CALL 'TLRPYM00' USING WS-USUARIO WS-RETCODE
               WHEN 'TLRCHE00'
                   CALL 'TLRCHE00' USING WS-USUARIO WS-RETCODE
               WHEN 'TLRSMG00'
                   CALL 'TLRSMG00' USING WS-USUARIO WS-RETCODE
               WHEN 'LONAPL00'
                   CALL 'LONAPL00' USING WS-USUARIO WS-RETCODE
               WHEN 'LONAPV00'
                   CALL 'LONAPV00' USING WS-USUARIO WS-RETCODE
               WHEN 'LONDIS00'
                   CALL 'LONDIS00' USING WS-USUARIO WS-RETCODE
               WHEN 'LONINQ00'
                   CALL 'LONINQ00' USING WS-USUARIO WS-RETCODE
               WHEN 'LONPYM00'
                   CALL 'LONPYM00' USING WS-USUARIO WS-RETCODE
               WHEN 'LONAMR00'
                   CALL 'LONAMR00' USING WS-USUARIO WS-RETCODE
               WHEN 'LONDEL00'
                   CALL 'LONDEL00' USING WS-USUARIO WS-RETCODE
               WHEN 'DEPOPN00'
                   CALL 'DEPOPN00' USING WS-USUARIO WS-RETCODE
               WHEN 'DEPINQ00'
                   CALL 'DEPINQ00' USING WS-USUARIO WS-RETCODE
               WHEN 'DEPINT00'
                   CALL 'DEPINT00' USING WS-USUARIO WS-RETCODE
               WHEN 'DEPREN00'
                   CALL 'DEPREN00' USING WS-USUARIO WS-RETCODE
               WHEN 'TDOPN000'
                   CALL 'TDOPN000' USING WS-USUARIO WS-RETCODE
               WHEN 'TDINQ000'
                   CALL 'TDINQ000' USING WS-USUARIO WS-RETCODE
               WHEN 'TDCLS000'
                   CALL 'TDCLS000' USING WS-USUARIO WS-RETCODE
               WHEN 'TDINT000'
                   CALL 'TDINT000' USING WS-USUARIO WS-RETCODE
               WHEN 'FTINT000'
                   CALL 'FTINT000' USING WS-USUARIO WS-RETCODE
               WHEN 'FTWIR000'
                   CALL 'FTWIR000' USING WS-USUARIO WS-RETCODE
               WHEN 'FTACH000'
                   CALL 'FTACH000' USING WS-USUARIO WS-RETCODE
               WHEN 'FTSTS000'
                   CALL 'FTSTS000' USING WS-USUARIO WS-RETCODE
               WHEN 'BCHDAY00'
                   CALL 'BCHDAY00' USING WS-USUARIO WS-RETCODE
               WHEN 'BCHMTH00'
                   CALL 'BCHMTH00' USING WS-USUARIO WS-RETCODE
               WHEN 'BCHINT00'
                   CALL 'BCHINT00' USING WS-USUARIO WS-RETCODE
               WHEN 'BCHGLI00'
                   CALL 'BCHGLI00' USING WS-USUARIO WS-RETCODE
               WHEN 'BCHFEE00'
                   CALL 'BCHFEE00' USING WS-USUARIO WS-RETCODE
               WHEN 'RPTBAL00'
                   CALL 'RPTBAL00' USING WS-USUARIO WS-RETCODE
               WHEN 'RPTTXN00'
                   CALL 'RPTTXN00' USING WS-USUARIO WS-RETCODE
               WHEN 'RPTDEL00'
                   CALL 'RPTDEL00' USING WS-USUARIO WS-RETCODE
               WHEN 'RPTTLR00'
                   CALL 'RPTTLR00' USING WS-USUARIO WS-RETCODE
               WHEN 'RPTGLB00'
                   CALL 'RPTGLB00' USING WS-USUARIO WS-RETCODE
               WHEN 'RPTREG00'
                   CALL 'RPTREG00' USING WS-USUARIO WS-RETCODE
               WHEN 'SECUSR00'
                   CALL 'SECUSR00' USING WS-USUARIO WS-RETCODE
               WHEN 'SECPWD00'
                   CALL 'SECPWD00' USING WS-USUARIO WS-RETCODE
               WHEN 'SECAUD00'
                   CALL 'SECAUD00' USING WS-USUARIO WS-RETCODE
               WHEN 'SECMNU00'
                   CALL 'SECMNU00' USING WS-USUARIO WS-RETCODE
               WHEN 'BNK0001'
                   PERFORM 9000-FINALIZAR
               WHEN OTHER
                   MOVE 'PROGRAMA NO DISPONIBLE'
                     TO WS-MENSAJE-ERROR
           END-EVALUATE.
      *
           IF WS-RETCODE NOT = 00
               STRING 'ERROR EN ' WS-NOMBRE-PROG
                      ' - CODIGO ' WS-RETCODE
                 INTO WS-MENSAJE-ERROR
           ELSE
               STRING 'OPERACION ' WS-NOMBRE-PROG
                      ' FINALIZADA CORRECTAMENTE'
                 INTO WS-MENSAJE
           END-IF.
      *
      *--- SUBMENU PRESTAMOS ---*
       4000-SUBMENU-PRESTAMOS.
           PERFORM 1100-LIMPIAR.
           DISPLAY ' SUBMENU PRESTAMOS - SELECCIONE OPCION:'.
           DISPLAY ' '.
           DISPLAY ' 25 - SOLICITUD DE PRESTAMO'.
           DISPLAY ' 26 - APROBACION DE PRESTAMO'.
           DISPLAY ' 27 - DESEMBOLSO DE PRESTAMO'.
           DISPLAY ' 28 - CONSULTA DE PRESTAMO'.
           DISPLAY ' 29 - PAGO DE CUOTA'.
           DISPLAY ' 30 - TABLA DE AMORTIZACION'.
           DISPLAY ' 31 - GESTION DE MORA / CASTIGO'.
           DISPLAY ' '.
           DISPLAY ' 00 - RETORNAR AL MENU PRINCIPAL'.
           DISPLAY ' '.
           DISPLAY ' OPCION: '.
           ACCEPT WS-OPCION.
           IF WS-OPCION = 0
               GOTO 4000-EXIT
           END-IF.
           PERFORM 3000-EJECUTAR-OPCION.
       4000-EXIT.
           EXIT.
      *
      *--- SUBMENU DEPOSITOS ---*
       4500-SUBMENU-DEPOSITOS.
           PERFORM 1100-LIMPIAR.
           DISPLAY ' SUBMENU DEPOSITOS - SELECCIONE OPCION:'.
           DISPLAY ' '.
           DISPLAY ' 32 - APERTURA DE DEPOSITO'.
           DISPLAY ' 33 - CONSULTA DE DEPOSITO'.
           DISPLAY ' 34 - TASAS DE INTERES'.
           DISPLAY ' 35 - RENOVACION DE DEPOSITO'.
           DISPLAY ' 36 - CANCELACION DE DEPOSITO'.
           DISPLAY ' 37 - APERTURA CERTIFICADO DEPOSITO'.
           DISPLAY ' 38 - CONSULTA DE CD'.
           DISPLAY ' 39 - LIQUIDACION DE CD'.
           DISPLAY ' 40 - CALCULO DE INTERES CD'.
           DISPLAY ' '.
           DISPLAY ' 00 - RETORNAR AL MENU PRINCIPAL'.
           DISPLAY ' '.
           DISPLAY ' OPCION: '.
           ACCEPT WS-OPCION.
           IF WS-OPCION = 0
               GOTO 4500-EXIT
           END-IF.
           PERFORM 3000-EJECUTAR-OPCION.
       4500-EXIT.
           EXIT.
      *
      *--- SUBMENU BATCH ---*
       4600-SUBMENU-BATCH.
           PERFORM 1100-LIMPIAR.
           DISPLAY ' SUBMENU BATCH - SELECCIONE OPCION:'.
           DISPLAY ' '.
           DISPLAY ' 45 - CIERRE DIARIO'.
           DISPLAY ' 46 - CIERRE MENSUAL'.
           DISPLAY ' 47 - INTERESES Y MORA'.
           DISPLAY ' 48 - PASE CONTABLE GL'.
           DISPLAY ' 49 - COMISIONES PERIODICAS'.
           DISPLAY ' '.
           DISPLAY ' 00 - RETORNAR AL MENU PRINCIPAL'.
           DISPLAY ' '.
           DISPLAY ' OPCION: '.
           ACCEPT WS-OPCION.
           IF WS-OPCION = 0
               GOTO 4600-EXIT
           END-IF.
           PERFORM 3000-EJECUTAR-OPCION.
       4600-EXIT.
           EXIT.
      *
      *--- CONFIRMAR SALIDA ---*
       5000-CONFIRMAR-SALIDA.
           MOVE SPACES TO WS-DUMMY.
           DISPLAY ' CONFIRMAR SALIDA DEL SISTEMA? (S/N): '.
           ACCEPT WS-DUMMY.
           IF WS-DUMMY = 'S' OR WS-DUMMY = 's'
               MOVE 00 TO WS-RETCODE
           ELSE
               MOVE 99 TO WS-RETCODE
               MOVE 'SALIDA CANCELADA' TO WS-MENSAJE
           END-IF.
      *
      *--- FINALIZAR ---*
       9000-FINALIZAR.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-SESION-TERMINO.
           ACCEPT SCR-SESION-TERMINO.
           STOP RUN.
      *
       END PROGRAM BNK0010.
