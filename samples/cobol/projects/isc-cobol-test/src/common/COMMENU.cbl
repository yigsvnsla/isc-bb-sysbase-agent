      *================================================================*
      * COMMENU - MENU PRINCIPAL DEL SISTEMA                          *
      * PROPÓSITO: PROGRAMA PRINCIPAL, PUERTA DE ENTRADA              *
      * EQUIPO: ARQUITECTURA - 2001 (REFAC. 2005)                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMMENU.
      *================================================================*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PC.
       OBJECT-COMPUTER. IBM-PC.
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
           88  WS-CRT-CLEAR              VALUE 0000.
      *
       01  WS-SESSION-ACTIVE             PIC X(01).
           88  WS-LOGGED-ON              VALUE 'S'.
           88  WS-LOGGED-OFF             VALUE 'N'.
       01  WS-FECHA                      PIC 9(08).
       01  WS-HORA                       PIC 9(06).
       01  WS-USUARIO                    PIC X(08).
       01  WS-SUCURSAL                   PIC X(04).
       01  WS-PROGRAMA                   PIC X(08).
       01  WS-MENSAJE                    PIC X(60).
       01  WS-RETCODE                    PIC 99.
       01  WS-DUMMY                      PIC X.
      *
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-PANTALLA-PRINCIPAL.
           05  SCR-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
               10  LINE 01  COL 60  PIC 9(08) FROM WS-FECHA.
               10  LINE 01  COL 70  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' MENU PRINCIPAL'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
               10  LINE 02  COL 70  PIC X(04) FROM WS-SUCURSAL.
      *
           05  SCR-MENU-OPCIONES.
               10  LINE 05  COL 10  PIC X(50)
                   VALUE 'PF1  - CLIENTES (ALTAS/CONSULTAS/BAJAS)'.
               10  LINE 06  COL 10  PIC X(50)
                   VALUE 'PF2  - CUENTAS (APERTURA/CIERRE/MODIFICACION)'.
               10  LINE 07  COL 10  PIC X(50)
                   VALUE 'PF3  - VENTANILLA (DEPOSITOS/RETIROS/PAGOS)'.
               10  LINE 08  COL 10  PIC X(50)
                   VALUE 'PF4  - PRESTAMOS (SOLICITUD/APROBACION/PAGO)'.
               10  LINE 09  COL 10  PIC X(50)
                   VALUE 'PF5  - DEPOSITOS (AHORRO/PLAZO/RENOVACION)'.
               10  LINE 10  COL 10  PIC X(50)
                   VALUE 'PF6  - PLAZO FIJO (CERTIFICADOS/CDS)'.
               10  LINE 11  COL 10  PIC X(50)
                   VALUE 'PF7  - TRANSFERENCIAS (WIRE/ACH/INTERNA)'.
               10  LINE 12  COL 10  PIC X(50)
                   VALUE 'PF8  - PROCESOS BATCH (CIERRE/INTERESES)'.
               10  LINE 13  COL 10  PIC X(50)
                   VALUE 'PF9  - REPORTES (BALANCE/TXN/DELINCUENCIA)'.
               10  LINE 14  COL 10  PIC X(50)
                   VALUE 'PF10 - SEGURIDAD (USUARIOS/AUDITORIA)'.
               10  LINE 15  COL 10  PIC X(50)
                   VALUE 'PF11 - AYUDA GENERAL DEL SISTEMA'.
               10  LINE 16  COL 10  PIC X(50)
                   VALUE 'PF12 - SALIR DEL SISTEMA'.
      *
           05  SCR-LINEA-ESTATUS.
               10  LINE 23  COL 01  PIC X(80)
                   VALUE ALL '-'.
               10  LINE 24  COL 01  PIC X(60)
                   FROM WS-MENSAJE.
               10  LINE 24  COL 62  PIC X(15)
                   VALUE 'PF11-AYUDA'.
               10  LINE 24  COL 74  PIC X(06)
                   VALUE 'PF12=SALIR'.
      *
      *================================================================*
       PROCEDURE DIVISION.
      *
       MAIN-MENU.
           MOVE 'S' TO WS-SESSION-ACTIVE.
           MOVE SPACES TO WS-USUARIO.
           MOVE SPACES TO WS-SUCURSAL.
      *
           PERFORM 1000-INICIALIZAR.
      *
            IF NOT WS-LOGGED-ON
                CALL 'BNK0001' USING WS-USUARIO
                                     WS-SUCURSAL
                                     WS-RETCODE
               END-CALL
               IF WS-RETCODE NOT = 00
                   MOVE 'ACCESO DENEGADO - CONTACTE AL ADMINISTRADOR'
                     TO WS-MENSAJE
                   DISPLAY SCR-PANTALLA-PRINCIPAL
                   STOP RUN
               END-IF
           END-IF.
      *
       MENU-LOOP.
           PERFORM 1500-REFRESCAR-PANTALLA.
           PERFORM 2000-ACTUALIZAR-CABECERA.
           DISPLAY SCR-PANTALLA-PRINCIPAL.
           ACCEPT SCR-PANTALLA-PRINCIPAL.
      *
           EVALUATE TRUE
               WHEN WS-CRT-PF1
                   CALL 'CUSMNU00'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO CLIENTES NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF2
                   CALL 'ACTMNU00'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO CUENTAS NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF3
                   CALL 'TLRMNU00'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO VENTANILLA NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF4
                   CALL 'LONMNU00'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO PRESTAMOS NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF5
                   CALL 'DEPMNU00'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO DEPOSITOS NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF6
                   CALL 'TDMNU000'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO PLAZO FIJO NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF7
                   CALL 'FTMNU000'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO TRANSFERENCIAS NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF8
                   CALL 'BCHMNU00'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO BATCH NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF9
                   CALL 'RPTMNU00'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO REPORTES NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF10
                   CALL 'SECMNU00'
                   ON EXCEPTION
                       MOVE 'ERROR: MODULO SEGURIDAD NO DISPONIBLE'
                         TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF11
                   CALL 'COMHELP' USING 'GENERAL'
                   ON EXCEPTION
                       MOVE 'AYUDA NO DISPONIBLE' TO WS-MENSAJE
                   END-CALL
      *
               WHEN WS-CRT-PF12
                   PERFORM 9000-SALIR
      *
               WHEN OTHER
                   MOVE 'OPCION NO VALIDA - USE PF1 A PF12'
                     TO WS-MENSAJE
           END-EVALUATE.
      *
           GO TO MENU-LOOP.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE 'SISTEMA INICIADO - FAVOR AUTENTICARSE'
             TO WS-MENSAJE.
      *
       1500-REFRESCAR-PANTALLA.
           CALL 'COMSCRN' USING 'CLEAR'.
      *
       2000-ACTUALIZAR-CABECERA.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
      *
       9000-SALIR.
           MOVE 'SESION FINALIZADA' TO WS-MENSAJE.
           STOP RUN.
      *
       END PROGRAM COMMENU.
