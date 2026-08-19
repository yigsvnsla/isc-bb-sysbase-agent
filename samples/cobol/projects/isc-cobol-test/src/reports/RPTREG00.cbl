       *================================================================*
       * RPTREG00 - REPORTES REGULATORIOS                              *
       * PROPOSITO: SIMULAR REPORTES: CNBV, SAT, BURO DE CREDITO     *
       * EQUIPO: CUMPLIMIENTO NORMATIVO - 2005                        *
       * ARCHIVOS: LOANMAST, ACCOUNT (LECTURA)                       *
       * CALL: COMDATE                                                *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTREG00.
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
           SELECT ACCOUNT-FILE
               ASSIGN TO 'ACCOUNT.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS ACT-NBR
               FILE STATUS IS FL-ACCOUNT-STATUS.
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
           05  WS-PROGRAMA                PIC X(08) VALUE 'RPTREG00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V1.0'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-OPCION                  PIC 9(01).
           05  WS-OPCION-DISP             PIC 9.
           05  WS-CONTADOR                PIC 9(06).
           05  WS-TOTAL-MONTO             PIC S9(13)V99 COMP-3.
           05  WS-TOTAL-INTERES           PIC S9(13)V99 COMP-3.
           05  WS-CONT-DISP               PIC Z(5)9.
           05  WS-MONTO-DISP              PIC Z(11)9.99.
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-MENU-REG.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - REPORTES REGULATORIOS'.
           05  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
           05  LINE 02  COL 01  PIC X(80)
               VALUE ' SELECCIONE TIPO DE REPORTE'.
           05  LINE 04  COL 05  PIC X(40) VALUE '1 - REPORTE CNBV'.
           05  LINE 05  COL 05  PIC X(40)
               VALUE '2 - REPORTE SAT (INTERESES)'.
           05  LINE 06  COL 05  PIC X(40)
               VALUE '3 - REPORTE BURO CREDITO'.
           05  LINE 08  COL 05  PIC X(20) VALUE 'OPCION:'.
           05  LINE 08  COL 15  PIC 9 USING WS-OPCION.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=ACEPTAR  PF12=SALIR'.
      *
       01  SCR-REPORTE.
           05  SCR-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - REPORTE REGULATORIO'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' REPORTE REGULATORIO - CNBV/SAT/BURO'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
               10  LINE 03  COL 01  PIC X(80) VALUE ALL '-'.
           05  SCR-DATOS.
               10  LINE 05  COL 05  PIC X(30) VALUE 'REGISTROS: '.
               10  LINE 05  COL 18  PIC Z(5)9 FROM WS-CONT-DISP.
               10  LINE 06  COL 05  PIC X(30) VALUE 'MONTO TOTAL:'.
               10  LINE 06  COL 20  PIC Z(11)9.99 FROM WS-MONTO-DISP.
               10  LINE 07  COL 05  PIC X(30) VALUE 'INTERES TOTAL:'.
               10  LINE 07  COL 20  PIC Z(11)9.99 FROM WS-MONTO-DISP.
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
           MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 0 TO WS-RETCODE.
           PERFORM 1000-INICIALIZAR.
           PERFORM 2000-MOSTRAR-MENU.
           IF WS-OPCION < 1 OR WS-OPCION > 3
               MOVE 'OPCION INVALIDA' TO WS-MENSAJE-ERROR
               PERFORM 9000-FINALIZAR
               GOBACK.
           EVALUATE WS-OPCION
               WHEN 1 PERFORM 3000-CNBV
               WHEN 2 PERFORM 4000-SAT
               WHEN 3 PERFORM 5000-BURO.
           PERFORM 6000-MOSTRAR.
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 0 TO WS-OPCION.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
       2000-MOSTRAR-MENU.
           DISPLAY SCR-MENU-REG.
           ACCEPT SCR-MENU-REG.
       3000-CNBV.
           MOVE 'REPORTE CNBV - CARTERA CREDITICIA' TO WS-MENSAJE.
           OPEN INPUT LOANMAST-FILE.
           IF FL-LOANMAST-STATUS NOT = '00'
               MOVE 'ERROR LOANMAST' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT.
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO LON-NBR.
           START LOANMAST-FILE KEY IS GREATER THAN LON-NBR
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
           PERFORM UNTIL WS-EOF-YES
               READ LOANMAST-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               ADD 1 TO WS-CONTADOR
               ADD LON-BALANCE TO WS-TOTAL-MONTO
               ADD LON-AMOUNT-INTEREST TO WS-TOTAL-INTERES.
           CLOSE LOANMAST-FILE.
       3000-EXIT.
           EXIT.
       4000-SAT.
           MOVE 'REPORTE SAT - INTERESES PAGADOS' TO WS-MENSAJE.
           OPEN INPUT LOANMAST-FILE.
           IF FL-LOANMAST-STATUS NOT = '00'
               GOTO 4000-EXIT.
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO LON-NBR.
           START LOANMAST-FILE KEY IS GREATER THAN LON-NBR
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
           PERFORM UNTIL WS-EOF-YES
               READ LOANMAST-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               IF LON-AMOUNT-INTEREST > 1000
                   ADD 1 TO WS-CONTADOR
                   ADD LON-AMOUNT-INTEREST TO WS-TOTAL-INTERES.
           CLOSE LOANMAST-FILE.
       4000-EXIT.
           EXIT.
       5000-BURO.
           MOVE 'REPORTE BURO - HISTORIAL CREDITICIO' TO WS-MENSAJE.
           OPEN INPUT LOANMAST-FILE.
           IF FL-LOANMAST-STATUS NOT = '00'
               GOTO 5000-EXIT.
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO LON-NBR.
           START LOANMAST-FILE KEY IS GREATER THAN LON-NBR
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
           PERFORM UNTIL WS-EOF-YES
               READ LOANMAST-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               IF LON-BALANCE-PAST-DUE > 0
                   ADD 1 TO WS-CONTADOR
                   ADD LON-BALANCE TO WS-TOTAL-MONTO
                   ADD LON-BALANCE-PAST-DUE TO WS-TOTAL-INTERES.
           CLOSE LOANMAST-FILE.
       5000-EXIT.
           EXIT.
       6000-MOSTRAR.
           MOVE WS-CONTADOR TO WS-CONT-DISP.
           MOVE WS-TOTAL-MONTO TO WS-MONTO-DISP.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-REPORTE.
       9000-FINALIZAR.
           CLOSE LOANMAST-FILE.
           MOVE 0 TO LS-RETCODE.
       END PROGRAM RPTREG00.
