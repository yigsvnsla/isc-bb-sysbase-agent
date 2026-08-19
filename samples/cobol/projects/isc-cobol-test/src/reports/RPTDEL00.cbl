       *================================================================*
       * RPTDEL00 - REPORTE DE CARTERA VENCIDA (PAST DUE)             *
       * PROPOSITO: LISTAR PRESTAMOS CON BALANCE VENCIDO > 0,        *
       *            AGRUPAR POR RANGO DE DIAS DE MORA                *
       * EQUIPO: CREDITO Y COBRANZA - 2004                           *
       * ARCHIVOS: LOANMAST (LECTURA SECUENCIAL)                     *
       * CALL: COMDATE                                               *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTDEL00.
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
           SELECT LOANMAST-FILE
               ASSIGN TO 'LOANMAST.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS LON-NBR
               FILE STATUS IS FL-LOANMAST-STATUS.
      *================================================================*
       DATA DIVISION.
       FILE SECTION.
       FD  LOANMAST-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 350 CHARACTERS.
       01  LOANMAST-RECORD.
           05  LON-NBR                     PIC X(10).
           05  LON-APPL-ID                 PIC X(10).
           05  LON-CUSTOMER-ID             PIC X(10).
           05  LON-TYPE                    PIC X(02).
           05  LON-PRODUCT-CODE            PIC X(04).
           05  LON-AMOUNT-APPROVED         PIC 9(13)V99 COMP-3.
           05  LON-AMOUNT-DISBURSED        PIC 9(13)V99 COMP-3.
           05  LON-BALANCE                 PIC 9(13)V99 COMP-3.
           05  LON-BALANCE-PAST-DUE        PIC 9(13)V99 COMP-3.
           05  LON-AMOUNT-INTEREST         PIC 9(13)V99 COMP-3.
           05  LON-AMOUNT-PENALTY          PIC 9(09)V99 COMP-3.
           05  LON-MINIMUM-PAYMENT         PIC 9(09)V99 COMP-3.
           05  LON-INTEREST-RATE           PIC 9(03)V9(04) COMP-3.
           05  LON-INTEREST-LATE           PIC 9(03)V9(04) COMP-3.
           05  LON-INTEREST-MORA           PIC 9(03)V9(04) COMP-3.
           05  LON-COMISION-APERTURA       PIC 9(07)V99 COMP-3.
           05  LON-TERM-MONTHS             PIC 9(04).
           05  LON-TERM-DAYS               PIC 9(04).
           05  LON-FREQUENCY               PIC X(01).
           05  LON-PAYMENTS-TOTAL          PIC 9(04).
           05  LON-PAYMENTS-MADE           PIC 9(04).
           05  LON-PAYMENTS-OVERDUE        PIC 9(04).
           05  LON-AMORT-TYPE              PIC X(01).
           05  LON-INSTALLMENT-AMOUNT      PIC 9(09)V99 COMP-3.
           05  LON-INSTALLMENT-DUE-DAY     PIC 9(02).
           05  LON-DATE-APPROVAL           PIC 9(08).
           05  LON-DATE-DISBURSEMENT       PIC 9(08).
           05  LON-DATE-FIRST-PAYMENT      PIC 9(08).
           05  LON-DATE-LAST-PAYMENT       PIC 9(08).
           05  LON-DATE-MATURITY           PIC 9(08).
           05  LON-DATE-LAST-CALC          PIC 9(08).
           05  LON-COLLATERAL-TYPE         PIC X(02).
           05  LON-COLLATERAL-DESC         PIC X(40).
           05  LON-COLLATERAL-VALUE        PIC 9(13)V99 COMP-3.
           05  LON-ACCOUNT-DEBIT           PIC X(10).
           05  LON-ACCOUNT-DISBURSEMENT    PIC X(10).
           05  LON-INSTALLMENT-TABLE.
               10  LON-INSTALLMENT-ENTRY   OCCURS 360.
                   15  LON-INST-NBR        PIC 9(04).
                   15  LON-INST-DUE-DATE   PIC 9(08).
                   15  LON-INST-AMOUNT     PIC 9(09)V99 COMP-3.
                   15  LON-INST-PRINCIPAL  PIC 9(09)V99 COMP-3.
                   15  LON-INST-INTEREST   PIC 9(09)V99 COMP-3.
                   15  LON-INST-BALANCE    PIC 9(09)V99 COMP-3.
                   15  LON-INST-STATUS     PIC X(01).
           05  LON-STATUS                  PIC X(01).
           05  LON-CLASSIFICATION          PIC X(01).
           05  LON-OFFICER                 PIC X(08).
           05  LON-USER-LAST-MOD           PIC X(08).
           05  LON-DATE-LAST-MOD           PIC 9(08).
           05  LON-FILLER                  PIC X(30).
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
           05  WS-PROGRAMA                PIC X(08) VALUE 'RPTDEL00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V1.5'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-CONTADOR                PIC 9(06) VALUE 0.
           05  WS-DIAS-MORA               PIC 9(04).
           05  WS-CLASIF                  PIC X(01).
           05  WS-LINEA                   PIC 9(02).
      *
       01  WS-BUCKETS.
           05  WS-BKT-1-30                PIC 9(06) VALUE 0.
           05  WS-BKT-31-60               PIC 9(06) VALUE 0.
           05  WS-BKT-61-90               PIC 9(06) VALUE 0.
           05  WS-BKT-90-PLUS             PIC 9(06) VALUE 0.
           05  WS-MONTO-BKT-1-30          PIC 9(13)V99 COMP-3.
           05  WS-MONTO-BKT-31-60         PIC 9(13)V99 COMP-3.
           05  WS-MONTO-BKT-61-90         PIC 9(13)V99 COMP-3.
           05  WS-MONTO-BKT-90-PLUS       PIC 9(13)V99 COMP-3.
           05  WS-TOTAL-PRESTAMOS         PIC 9(06) VALUE 0.
           05  WS-TOTAL-VENCIDO           PIC 9(13)V99 COMP-3.
      *
       01  WS-DISPLAY.
           05  WS-CONT-DISP               PIC Z(5)9.
           05  WS-MONTO-DISP              PIC Z(11)9.99.
           05  WS-TOTAL-BAL-DISP          PIC Z(11)9.99.
           05  WS-PAST-DUE-DISP           PIC Z(11)9.99.
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-REPORTE.
           05  SCR-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - CARTERA VENCIDA'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' REPORTE DE CARTERA VENCIDA'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
               10  LINE 03  COL 01  PIC X(80) VALUE ALL '-'.
           05  SCR-RESUMEN.
               10  LINE 05  COL 05  PIC X(30)
                   VALUE 'TOTAL PRESTAMOS VENCIDOS:'.
               10  LINE 05  COL 35  PIC Z(5)9 FROM WS-CONT-DISP.
               10  LINE 06  COL 05  PIC X(30)
                   VALUE 'MONTO TOTAL VENCIDO:'.
               10  LINE 06  COL 35  PIC Z(11)9.99 FROM WS-TOTAL-BAL-DISP.
               10  LINE 08  COL 05  PIC X(60) VALUE ALL '-'.
               10  LINE 09  COL 05  PIC X(30) VALUE 'BUCKET      CTDAD'.
               10  LINE 09  COL 40  PIC X(30) VALUE 'MONTO'.
               10  LINE 10  COL 05  PIC X(30) VALUE '1-30 DIAS:'.
               10  LINE 10  COL 20  PIC Z(5)9 FROM WS-MONTO-DISP.
               10  LINE 10  COL 35  PIC Z(11)9.99 FROM WS-MONTO-DISP.
               10  LINE 11  COL 05  PIC X(30) VALUE '31-60 DIAS:'.
               10  LINE 11  COL 20  PIC Z(5)9 FROM WS-MONTO-DISP.
               10  LINE 11  COL 35  PIC Z(11)9.99 FROM WS-MONTO-DISP.
               10  LINE 12  COL 05  PIC X(30) VALUE '61-90 DIAS:'.
               10  LINE 12  COL 20  PIC Z(5)9 FROM WS-MONTO-DISP.
               10  LINE 12  COL 35  PIC Z(11)9.99 FROM WS-MONTO-DISP.
               10  LINE 13  COL 05  PIC X(30) VALUE '90+ DIAS:'.
               10  LINE 13  COL 20  PIC Z(5)9 FROM WS-MONTO-DISP.
               10  LINE 13  COL 35  PIC Z(11)9.99 FROM WS-MONTO-DISP.
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
           PERFORM 2000-LEER-PRESTAMOS.
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
           MOVE 0 TO WS-CONTADOR WS-TOTAL-PRESTAMOS
                      WS-TOTAL-VENCIDO.
           MOVE 0 TO WS-BKT-1-30 WS-BKT-31-60
                      WS-BKT-61-90 WS-BKT-90-PLUS.
           MOVE 0 TO WS-MONTO-BKT-1-30 WS-MONTO-BKT-31-60
                      WS-MONTO-BKT-61-90 WS-MONTO-BKT-90-PLUS.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       2000-LEER-PRESTAMOS.
           OPEN INPUT LOANMAST-FILE.
           IF FL-LOANMAST-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR LOANMAST' TO WS-MENSAJE-ERROR
               GOTO 2000-EXIT.
      *
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO LON-NBR.
           START LOANMAST-FILE KEY IS GREATER THAN LON-NBR
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
      *
           PERFORM UNTIL WS-EOF-YES
               READ LOANMAST-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               IF LON-BALANCE-PAST-DUE = 0
                   EXIT PERFORM CYCLE
               END-IF
               ADD 1 TO WS-TOTAL-PRESTAMOS
               ADD LON-BALANCE-PAST-DUE TO WS-TOTAL-VENCIDO
      *        CALCULAR DIAS DE MORA (SIMULATED)
               COMPUTE WS-DIAS-MORA =
                   LON-PAYMENTS-OVERDUE * 30
               IF WS-DIAS-MORA > 90
                   ADD 1 TO WS-BKT-90-PLUS
                   ADD LON-BALANCE-PAST-DUE
                     TO WS-MONTO-BKT-90-PLUS
               ELSE
                   IF WS-DIAS-MORA > 60
                       ADD 1 TO WS-BKT-61-90
                       ADD LON-BALANCE-PAST-DUE
                         TO WS-MONTO-BKT-61-90
                   ELSE
                       IF WS-DIAS-MORA > 30
                           ADD 1 TO WS-BKT-31-60
                           ADD LON-BALANCE-PAST-DUE
                             TO WS-MONTO-BKT-31-60
                       ELSE
                           ADD 1 TO WS-BKT-1-30
                           ADD LON-BALANCE-PAST-DUE
                             TO WS-MONTO-BKT-1-30
                       END-IF
                   END-IF
               END-IF
               ADD 1 TO WS-CONTADOR
           END-PERFORM.
      *
           CLOSE LOANMAST-FILE.
       2000-EXIT.
           EXIT.
      *
       3000-MOSTRAR.
           MOVE WS-TOTAL-PRESTAMOS TO WS-CONT-DISP.
           MOVE WS-TOTAL-VENCIDO TO WS-TOTAL-BAL-DISP.
           MOVE WS-BKT-1-30 TO WS-MONTO-DISP.
           MOVE WS-MONTO-BKT-1-30 TO WS-MONTO-DISP.
           MOVE WS-BKT-31-60 TO WS-MONTO-DISP.
           MOVE WS-MONTO-BKT-31-60 TO WS-MONTO-DISP.
           MOVE WS-BKT-61-90 TO WS-MONTO-DISP.
           MOVE WS-MONTO-BKT-61-90 TO WS-MONTO-DISP.
           MOVE WS-BKT-90-PLUS TO WS-MONTO-DISP.
           MOVE WS-MONTO-BKT-90-PLUS TO WS-MONTO-DISP.
           STRING 'TOTAL: ' WS-CONTADOR ' PRESTAMOS VENCIDOS'
             INTO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-REPORTE.
      *
       9000-FINALIZAR.
           CLOSE LOANMAST-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM RPTDEL00.
