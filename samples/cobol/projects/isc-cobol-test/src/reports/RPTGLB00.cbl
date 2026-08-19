       *================================================================*
       * RPTGLB00 - REPORTE DE TRIAL BALANCE (BALANCE DE PRUEBA)      *
       * PROPOSITO: MOSTRAR SALDOS DE CUENTAS CONTABLES (GLMASTER)   *
       *            CON TOTALES POR TIPO Y ECUACION CONTABLE         *
       * EQUIPO: CONTABILIDAD - 1996                                 *
       * ARCHIVOS: GLMASTER (LECTURA SECUENCIAL)                     *
       * CALL: COMDATE                                               *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTGLB00.
      *================================================================*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
      *================================================================*
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT GLMASTER-FILE
               ASSIGN TO 'GLMASTER.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS GL-ACCOUNT
               FILE STATUS IS FL-GLMASTER-STATUS.
      *================================================================*
       DATA DIVISION.
       FILE SECTION.
       FD  GLMASTER-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 160 CHARACTERS.
       01  GLMASTER-RECORD.
           05  GL-ACCOUNT                  PIC X(08).
           05  GL-DESCRIPTION              PIC X(40).
           05  GL-TYPE                     PIC X(01).
           05  GL-LEVEL                    PIC 9(01).
           05  GL-BALANCE-INICIAL          PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-CURRENT          PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-DEBIT            PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-CREDIT           PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-PERIOD-ANT       PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-YTD              PIC S9(13)V99 COMP-3.
           05  GL-CURRENCY                 PIC X(03).
           05  GL-BRANCH                   PIC X(04).
           05  GL-CENTER-COST              PIC X(06).
           05  GL-STATUS                   PIC X(01).
           05  GL-DATE-LAST-ACTIVITY       PIC 9(08).
           05  GL-DATE-LAST-CIERRE         PIC 9(08).
           05  GL-USER-LAST-MOD            PIC X(08).
           05  GL-FILLER                   PIC X(20).
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF4                VALUE 1004.
           88  WS-CRT-PF12               VALUE 1012.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'RPTGLB00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V2.0'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-CONTADOR                PIC 9(06) VALUE 0.
           05  WS-LINEA                   PIC 9(02) VALUE 5.
      *
       01  WS-TOTALES-GL.
           05  WS-TOT-ACTIVOS             PIC S9(15)V99 COMP-3.
           05  WS-TOT-PASIVOS             PIC S9(15)V99 COMP-3.
           05  WS-TOT-CAPITAL             PIC S9(15)V99 COMP-3.
           05  WS-TOT-INGRESOS            PIC S9(15)V99 COMP-3.
           05  WS-TOT-GASTOS              PIC S9(15)V99 COMP-3.
           05  WS-TOT-ORDEN               PIC S9(15)V99 COMP-3.
           05  WS-COUNT-ACT               PIC 9(06).
           05  WS-COUNT-PAS               PIC 9(06).
           05  WS-COUNT-CAP               PIC 9(06).
           05  WS-COUNT-ING               PIC 9(06).
           05  WS-COUNT-GAS               PIC 9(06).
           05  WS-COUNT-ORD               PIC 9(06).
           05  WS-DIFERENCIA              PIC S9(15)V99 COMP-3.
      *
       01  WS-DISPLAY.
           05  WS-CONT-DISP               PIC Z(5)9.
           05  WS-MONTO-DISP              PIC Z(12)9.99.
           05  WS-MONTO2-DISP             PIC Z(12)9.99.
           05  WS-MONTO3-DISP             PIC Z(12)9.99.
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-REPORTE.
           05  SCR-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - TRIAL BALANCE'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' BALANCE DE PRUEBA (TRIAL BALANCE)'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
               10  LINE 03  COL 01  PIC X(80) VALUE ALL '-'.
           05  SCR-DETALLE.
               10  LINE 05  COL 05  PIC X(20) VALUE 'ACTIVOS:'.
               10  LINE 05  COL 20  PIC Z(5)9 FROM WS-CONT-DISP.
               10  LINE 05  COL 30  PIC Z(12)9.99 FROM WS-MONTO-DISP.
               10  LINE 06  COL 05  PIC X(20) VALUE 'PASIVOS:'.
               10  LINE 06  COL 20  PIC Z(5)9 FROM WS-CONT-DISP.
               10  LINE 06  COL 30  PIC Z(12)9.99 FROM WS-MONTO-DISP.
               10  LINE 07  COL 05  PIC X(20) VALUE 'CAPITAL:'.
               10  LINE 07  COL 20  PIC Z(5)9 FROM WS-CONT-DISP.
               10  LINE 07  COL 30  PIC Z(12)9.99 FROM WS-MONTO-DISP.
               10  LINE 08  COL 05  PIC X(20) VALUE 'INGRESOS:'.
               10  LINE 08  COL 20  PIC Z(5)9 FROM WS-CONT-DISP.
               10  LINE 08  COL 30  PIC Z(12)9.99 FROM WS-MONTO-DISP.
               10  LINE 09  COL 05  PIC X(20) VALUE 'GASTOS:'.
               10  LINE 09  COL 20  PIC Z(5)9 FROM WS-CONT-DISP.
               10  LINE 09  COL 30  PIC Z(12)9.99 FROM WS-MONTO-DISP.
               10  LINE 10  COL 05  PIC X(20) VALUE 'ORDEN:'.
               10  LINE 10  COL 20  PIC Z(5)9 FROM WS-CONT-DISP.
               10  LINE 10  COL 30  PIC Z(12)9.99 FROM WS-MONTO-DISP.
               10  LINE 12  COL 05  PIC X(60) VALUE ALL '-'.
               10  LINE 13  COL 05  PIC X(30)
                   VALUE 'ECUACION CONTABLE:'.
               10  LINE 14  COL 05  PIC X(30) VALUE 'ACTIVOS ='.
               10  LINE 14  COL 20  PIC Z(12)9.99 FROM WS-MONTO2-DISP.
               10  LINE 15  COL 05  PIC X(30) VALUE 'PASIVO+CAPITAL ='.
               10  LINE 15  COL 25  PIC Z(12)9.99 FROM WS-MONTO3-DISP.
               10  LINE 16  COL 05  PIC X(30) VALUE 'DIFERENCIA:'.
               10  LINE 16  COL 20  PIC Z(12)9.99 FROM WS-MONTO-DISP.
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF4=IMPRIMIR  PF12=SALIR'.
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-USUARIO
                                 LS-RETCODE.
      *
       MAIN.
           MOVE SPACES TO WS-MENSAJE
                          WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 0 TO WS-RETCODE.
      *
           PERFORM 1000-INICIALIZAR.
           PERFORM 2000-LEER-GL.
           PERFORM 3000-MOSTRAR.
      *
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 0 TO WS-CONTADOR
                      WS-COUNT-ACT WS-COUNT-PAS
                      WS-COUNT-CAP WS-COUNT-ING
                      WS-COUNT-GAS WS-COUNT-ORD.
           MOVE 0 TO WS-TOT-ACTIVOS WS-TOT-PASIVOS
                      WS-TOT-CAPITAL WS-TOT-INGRESOS
                      WS-TOT-GASTOS WS-TOT-ORDEN.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       2000-LEER-GL.
           OPEN INPUT GLMASTER-FILE.
           IF FL-GLMASTER-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR GLMASTER' TO WS-MENSAJE-ERROR
               GOTO 2000-EXIT.
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO GL-ACCOUNT.
           START GLMASTER-FILE KEY IS GREATER THAN GL-ACCOUNT
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
           PERFORM UNTIL WS-EOF-YES
               READ GLMASTER-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               IF GL-STATUS NOT = 'A'
                   EXIT PERFORM CYCLE
               END-IF
               ADD 1 TO WS-CONTADOR
               EVALUATE GL-TYPE
                   WHEN '1'
                       ADD 1 TO WS-COUNT-ACT
                       ADD GL-BALANCE-CURRENT TO WS-TOT-ACTIVOS
                   WHEN '2'
                       ADD 1 TO WS-COUNT-PAS
                       ADD GL-BALANCE-CURRENT TO WS-TOT-PASIVOS
                   WHEN '3'
                       ADD 1 TO WS-COUNT-CAP
                       ADD GL-BALANCE-CURRENT TO WS-TOT-CAPITAL
                   WHEN '4'
                       ADD 1 TO WS-COUNT-ING
                       ADD GL-BALANCE-CURRENT TO WS-TOT-INGRESOS
                   WHEN '5'
                       ADD 1 TO WS-COUNT-GAS
                       ADD GL-BALANCE-CURRENT TO WS-TOT-GASTOS
                   WHEN '6'
                       ADD 1 TO WS-COUNT-ORD
                       ADD GL-BALANCE-CURRENT TO WS-TOT-ORDEN
               END-EVALUATE
           END-PERFORM.
           CLOSE GLMASTER-FILE.
       2000-EXIT.
           EXIT.
      *
       3000-MOSTRAR.
           MOVE WS-COUNT-ACT TO WS-CONT-DISP.
           MOVE WS-TOT-ACTIVOS TO WS-MONTO-DISP.
           MOVE WS-COUNT-PAS TO WS-CONT-DISP.
           MOVE WS-TOT-PASIVOS TO WS-MONTO-DISP.
           MOVE WS-COUNT-CAP TO WS-CONT-DISP.
           MOVE WS-TOT-CAPITAL TO WS-MONTO-DISP.
           MOVE WS-COUNT-ING TO WS-CONT-DISP.
           MOVE WS-TOT-INGRESOS TO WS-MONTO-DISP.
           MOVE WS-COUNT-GAS TO WS-CONT-DISP.
           MOVE WS-TOT-GASTOS TO WS-MONTO-DISP.
           MOVE WS-COUNT-ORD TO WS-CONT-DISP.
           MOVE WS-TOT-ORDEN TO WS-MONTO-DISP.
           MOVE WS-TOT-ACTIVOS TO WS-MONTO2-DISP.
           COMPUTE WS-MONTO3-DISP = WS-TOT-PASIVOS + WS-TOT-CAPITAL.
           COMPUTE WS-DIFERENCIA = WS-TOT-ACTIVOS
                                 - WS-TOT-PASIVOS
                                 - WS-TOT-CAPITAL.
           MOVE WS-DIFERENCIA TO WS-MONTO-DISP.
           STRING 'TOTAL CUENTAS: ' WS-CONTADOR
             INTO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-REPORTE.
      *
       9000-FINALIZAR.
           CLOSE GLMASTER-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM RPTGLB00.
