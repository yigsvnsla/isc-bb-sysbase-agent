       *================================================================*
       * RPTBAL00 - REPORTE DE BALANCE GENERAL                        *
       * PROPOSITO: GENERAR BALANCE GENERAL POR TIPO DE CUENTA        *
       *            CON TOTALES Y RESUMEN                             *
       * EQUIPO: CONTABILIDAD - 1997                                 *
       * ARCHIVOS: ACCOUNT (LECTURA SECUENCIAL)                      *
       * CALL: COMDATE, COMMSGF                                     *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTBAL00.
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
           SELECT ACCOUNT-FILE
               ASSIGN TO 'ACCOUNT.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS ACT-NBR
               FILE STATUS IS FL-ACCOUNT-STATUS.
      *================================================================*
       DATA DIVISION.
       FILE SECTION.
       FD  ACCOUNT-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 200 CHARACTERS.
       01  ACCOUNT-RECORD.
           05  ACT-NBR                     PIC X(10).
           05  ACT-TYPE                    PIC X(02).
           05  ACT-CURRENCY                PIC X(03).
           05  ACT-BALANCE                 PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-DISPONIBLE      PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-RETENIDO        PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-SOBREGIRO       PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-PROMEDIO        PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-ANTERIOR        PIC S9(13)V99 COMP-3.
           05  ACT-OVERDRAFT-LIMIT         PIC S9(09)V99 COMP-3.
           05  ACT-OVERDRAFT-RATE          PIC 9(03)V9(04) COMP-3.
           05  ACT-INTEREST-RATE           PIC 9(03)V9(04) COMP-3.
           05  ACT-INTEREST-ACCRUED        PIC S9(09)V99 COMP-3.
           05  ACT-MONTHLY-FEE             PIC 9(07)V99 COMP-3.
           05  ACT-DATE-OPEN               PIC 9(08).
           05  ACT-DATE-CLOSE              PIC 9(08).
           05  ACT-DATE-LAST-ACTIVITY      PIC 9(08).
           05  ACT-DATE-LAST-INT-CALC      PIC 9(08).
           05  ACT-DATE-LAST-STATEMENT     PIC 9(08).
           05  ACT-STATUS                  PIC X(01).
           05  ACT-BRANCH-OPEN             PIC X(04).
           05  ACT-OFFICER                 PIC X(08).
           05  ACT-USER-LAST-MOD           PIC X(08).
           05  ACT-TXN-COUNT-TODAY         PIC 9(06).
           05  ACT-TXN-COUNT-MONTH         PIC 9(06).
           05  ACT-CHECKS-ISSUED           PIC 9(06).
           05  ACT-CHECKS-BOUNCED          PIC 9(06).
           05  ACT-CHQBOOK-NBR             PIC X(10).
           05  ACT-CHQ-NEXT               PIC 9(07).
           05  ACT-CHQ-LAST-USED          PIC 9(07).
           05  ACT-CHQ-STOP-COUNT          PIC 9(03).
           05  ACT-FILLER                  PIC X(15).
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF1                VALUE 1001.
           88  WS-CRT-PF4                VALUE 1004.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'RPTBAL00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V1.8'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-FECHA-REPORTE           PIC 9(08).
           05  WS-FECHA-REP-DISP          PIC 99/99/9999.
      *
       01  WS-TOTALES-POR-TIPO.
           05  WS-TIPO-CH                 PIC 9(09).
           05  WS-TIPO-AH                 PIC 9(09).
           05  WS-TIPO-NO                 PIC 9(09).
           05  WS-TIPO-IN                 PIC 9(09).
           05  WS-TIPO-OTROS              PIC 9(09).
           05  WS-MONTO-CH                PIC S9(13)V99 COMP-3.
           05  WS-MONTO-AH                PIC S9(13)V99 COMP-3.
           05  WS-MONTO-NO                PIC S9(13)V99 COMP-3.
           05  WS-MONTO-IN                PIC S9(13)V99 COMP-3.
           05  WS-MONTO-OTROS             PIC S9(13)V99 COMP-3.
           05  WS-TOTAL-CUENTAS           PIC 9(09).
           05  WS-TOTAL-BALANCE           PIC S9(13)V99 COMP-3.
      *
       01  WS-DISPLAY-LINEAS.
           05  WS-LINEA                   PIC 9(02) VALUE 5.
           05  WS-LINE                   PIC 9(02).
           05  WS-COUNT-DISP              PIC Z(8)9.
           05  WS-MONTO-DISP              PIC Z(11)9.99.
           05  WS-TOTAL-DISP              PIC Z(11)9.99.
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-PROMPT-FECHA.
           05  LINE 05  COL 10  PIC X(40)
               VALUE 'FECHA DEL REPORTE (DDMMYYYY):'.
           05  LINE 05  COL 40  PIC 99/99/9999
               USING WS-FECHA-REPORTE.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
      *
       01  SCR-REPORTE.
           05  SCR-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - BALANCE GENERAL'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' REPORTE DE BALANCE GENERAL'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
               10  LINE 03  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 04  COL 05  PIC X(30)
                   VALUE 'TIPO CTAS  CANTIDAD   SALDO'.
               10  LINE 04  COL 40  PIC X(30) VALUE 'TOTAL'.
      *
           05  SCR-LINEAS OCCURS 6.
               10  SCR-LIN-TYPE             PIC X(08).
               10  SCR-LIN-COUNT            PIC Z(8)9.
               10  SCR-LIN-BAL              PIC Z(11)9.99.
      *
           05  SCR-TOTAL.
               10  LINE 13  COL 05  PIC X(60) VALUE ALL '-'.
               10  LINE 14  COL 05  PIC X(20) VALUE 'TOTAL GENERAL:'.
               10  LINE 14  COL 30  PIC Z(8)9 FROM WS-TOTAL-DISP.
               10  LINE 14  COL 42  PIC Z(11)9.99 FROM WS-TOTAL-DISP.
      *
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
           PERFORM 2000-PROMPT-FECHA.
           PERFORM 3000-LEER-CUENTAS.
           PERFORM 4000-MOSTRAR-REPORTE.
      *
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE WS-FECHA TO WS-FECHA-REPORTE.
           MOVE 0 TO WS-TOTAL-CUENTAS
                      WS-TOTAL-BALANCE.
           MOVE 0 TO WS-TIPO-CH WS-TIPO-AH WS-TIPO-NO
                      WS-TIPO-IN WS-TIPO-OTROS.
           MOVE 0 TO WS-MONTO-CH WS-MONTO-AH WS-MONTO-NO
                      WS-MONTO-IN WS-MONTO-OTROS.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       2000-PROMPT-FECHA.
           DISPLAY SCR-PROMPT-FECHA.
           ACCEPT SCR-PROMPT-FECHA.
           MOVE WS-FECHA-REPORTE TO WS-FECHA-REP-DISP.
      *
       3000-LEER-CUENTAS.
           OPEN INPUT ACCOUNT-FILE.
           IF FL-ACCOUNT-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR ACCOUNT' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT.
      *
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO ACT-NBR.
           START ACCOUNT-FILE KEY IS GREATER THAN ACT-NBR
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
      *
           PERFORM UNTIL WS-EOF-YES
               READ ACCOUNT-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
      *
               IF ACT-STATUS NOT = 'A' AND NOT = 'D'
                   EXIT PERFORM CYCLE
               END-IF
      *
               ADD 1 TO WS-TOTAL-CUENTAS
               ADD ACT-BALANCE TO WS-TOTAL-BALANCE
      *
               EVALUATE ACT-TYPE
                   WHEN 'CH'
                       ADD 1 TO WS-TIPO-CH
                       ADD ACT-BALANCE TO WS-MONTO-CH
                   WHEN 'AH'
                       ADD 1 TO WS-TIPO-AH
                       ADD ACT-BALANCE TO WS-MONTO-AH
                   WHEN 'NO'
                       ADD 1 TO WS-TIPO-NO
                       ADD ACT-BALANCE TO WS-MONTO-NO
                   WHEN 'IN'
                       ADD 1 TO WS-TIPO-IN
                       ADD ACT-BALANCE TO WS-MONTO-IN
                   WHEN OTHER
                       ADD 1 TO WS-TIPO-OTROS
                       ADD ACT-BALANCE TO WS-MONTO-OTROS
               END-EVALUATE
           END-PERFORM.
      *
           CLOSE ACCOUNT-FILE.
       3000-EXIT.
           EXIT.
      *
       4000-MOSTRAR-REPORTE.
           MOVE WS-TOTAL-CUENTAS TO WS-COUNT-DISP.
           MOVE WS-TOTAL-CUENTAS TO WS-TOTAL-DISP.
           MOVE WS-TOTAL-BALANCE TO WS-TOTAL-DISP.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-REPORTE.
      *
       9000-FINALIZAR.
           CLOSE ACCOUNT-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM RPTBAL00.
