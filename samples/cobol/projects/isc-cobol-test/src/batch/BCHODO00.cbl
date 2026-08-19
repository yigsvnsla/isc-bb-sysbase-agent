       *================================================================*
       * BCHODO00 - CALCULO DE SOBREGIRO Y MORA                        *
       * PROPOSITO: DETECTAR CUENTAS SOBREGIRADAS, CALCULAR COMISION   *
       *            Y MORA SOBRE PRESTAMOS VENCIDOS                    *
       * EQUIPO: OPERACIONES - 2001                                   *
       * ARCHIVOS: ACCOUNT, LOANMAST, TRANLOG                         *
       * CALL: COMDATE                                                *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCHODO00.
      *================================================================*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
      *================================================================*
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO 'ACCOUNT.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS ACT-NBR
               FILE STATUS IS FL-ACCOUNT-STATUS.
      *
           SELECT LOANMAST-FILE
               ASSIGN TO 'LOANMAST.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS LON-NBR
               FILE STATUS IS FL-LOANMAST-STATUS.
      *
           SELECT TRANLOG-FILE
               ASSIGN TO 'TRANLOG.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TRN-SEQ
               FILE STATUS IS FL-TRANLOG-STATUS.
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
      *
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
      *
       FD  TRANLOG-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 150 CHARACTERS.
       01  TRANLOG-RECORD.
           05  TRN-SEQ                     PIC 9(10).
           05  TRN-DATE                    PIC 9(08).
           05  TRN-TIME                    PIC 9(06).
           05  TRN-TYPE                    PIC X(03).
           05  TRN-ACCOUNT-NBR             PIC X(10).
           05  TRN-ACCOUNT-DEST            PIC X(10).
           05  TRN-CUSTOMER-ID             PIC X(10).
           05  TRN-AMOUNT                  PIC S9(13)V99 COMP-3.
           05  TRN-AMOUNT-TAX              PIC S9(09)V99 COMP-3.
           05  TRN-AMOUNT-TOTAL            PIC S9(13)V99 COMP-3.
           05  TRN-AMOUNT-ORIGINAL         PIC S9(13)V99 COMP-3.
           05  TRN-FEE-AMOUNT              PIC S9(07)V99 COMP-3.
           05  TRN-FEE-CODE                PIC X(04).
           05  TRN-BRANCH                  PIC X(04).
           05  TRN-TELLER-ID               PIC X(08).
           05  TRN-USER-ID                 PIC X(08).
           05  TRN-TERMINAL                PIC X(08).
           05  TRN-CHANNEL                 PIC X(02).
           05  TRN-REFERENCE               PIC X(20).
           05  TRN-CHQ-NBR                 PIC 9(10).
           05  TRN-CHQ-BANK                PIC X(10).
           05  TRN-CHQ-ACCOUNT             PIC X(10).
           05  TRN-STATUS                  PIC X(01).
           05  TRN-REVERSE-SEQ             PIC 9(10).
           05  TRN-DESCRIPTION             PIC X(30).
           05  TRN-FILLER                  PIC X(10).
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF12               VALUE 1012.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'BCHODO00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V1.5'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-CONT-SOBREGIRO          PIC 9(09) VALUE 0.
           05  WS-CONT-MORA               PIC 9(09) VALUE 0.
           05  WS-CONT-ERRORES            PIC 9(06) VALUE 0.
           05  WS-TRX-SEQ                 PIC 9(10) VALUE 0.
           05  WS-MONTO-SOBREGIRO         PIC S9(13)V99 COMP-3.
           05  WS-COMISION-CALC           PIC S9(09)V99 COMP-3.
           05  WS-INTERES-MORA-CALC       PIC S9(13)V99 COMP-3.
           05  WS-MONTO-SOBRE-DISP        PIC Z(11)9.99.
           05  WS-COMISION-DISP           PIC Z(8)9.99.
           05  WS-CONT-SOBRE-DISP         PIC Z(8)9.
           05  WS-CONT-MORA-DISP          PIC Z(8)9.
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-PROGRESO.
           05  SCR-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - SOBREGIRO Y MORA'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' BATCH - CALCULO DE COMISION POR SOBREGIRO'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
      *
           05  SCR-DATOS.
               10  LINE 05  COL 05  PIC X(40)
                   VALUE 'CUENTAS CON SOBREGIRO PROCESADAS:'.
               10  LINE 05  COL 40  PIC Z(8)9 FROM WS-CONT-SOBRE-DISP.
               10  LINE 06  COL 05  PIC X(40)
                   VALUE 'PRESTAMOS CON MORA PROCESADOS:'.
               10  LINE 06  COL 40  PIC Z(8)9 FROM WS-CONT-MORA-DISP.
               10  LINE 07  COL 05  PIC X(40) VALUE 'ERRORES:'.
               10  LINE 07  COL 40  PIC Z(5)9 FROM WS-CONT-ERRORES.
               10  LINE 09  COL 05  PIC X(30) VALUE 'ULTIMA COMISION:'.
               10  LINE 09  COL 30  PIC Z(8)9.99 FROM WS-COMISION-DISP.
      *
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF3=INTERRUMPIR  PF12=SALIR'.
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
           PERFORM 2000-PROCESAR-SOBREGIROS.
           PERFORM 3000-PROCESAR-MORA.
      *
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 0 TO WS-CONT-SOBREGIRO
                      WS-CONT-MORA
                      WS-CONT-ERRORES
                      WS-TRX-SEQ.
           MOVE 0 TO WS-MONTO-SOBREGIRO
                      WS-COMISION-CALC
                      WS-INTERES-MORA-CALC.
           MOVE 'INICIALIZANDO PROCESO...' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-PROGRESO.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
      *--- PROCESAR SOBREGIROS (CUENTAS) ---*
       2000-PROCESAR-SOBREGIROS.
           MOVE 'PROCESANDO SOBREGIROS EN CUENTAS...'
             TO WS-MENSAJE.
           DISPLAY SCR-PROGRESO.
      *
           OPEN I-O ACCOUNT-FILE.
           IF FL-ACCOUNT-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR ACCOUNT' TO WS-MENSAJE-ERROR
               MOVE 4 TO WS-RETCODE
               GOTO 2000-EXIT
           END-IF.
      *
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO ACT-NBR.
           START ACCOUNT-FILE KEY IS GREATER THAN ACT-NBR
               INVALID KEY
                   MOVE 'Y' TO WS-EOF-YES
           END-START.
      *
           PERFORM UNTIL WS-EOF-YES
               READ ACCOUNT-FILE NEXT RECORD
                   AT END
                       MOVE 'Y' TO WS-EOF-YES
                       EXIT PERFORM
               END-READ
      *
               IF FL-ACCOUNT-STATUS NOT = '00'
                   ADD 1 TO WS-CONT-ERRORES
                   EXIT PERFORM CYCLE
               END-IF
      *
               IF ACT-STATUS NOT = 'A'
                   EXIT PERFORM CYCLE
               END-IF
      *
               IF ACT-BALANCE-DISPONIBLE >= 0
                   EXIT PERFORM CYCLE
               END-IF
      *
               PERFORM 2100-CALCULAR-COMISION-SOBREGIRO
               PERFORM 2200-APLICAR-COMISION
               PERFORM 2300-REGISTRAR-TRANLOG-SOBREGIRO
               ADD 1 TO WS-CONT-SOBREGIRO
           END-PERFORM.
      *
           CLOSE ACCOUNT-FILE.
           MOVE WS-CONT-SOBREGIRO TO WS-CONT-SOBRE-DISP.
      *
       2000-EXIT.
           EXIT.
      *
       2100-CALCULAR-COMISION-SOBREGIRO.
      *    COMISION = |BALANCE_DISPONIBLE| * TASA_SOBREGIRO / 30
           COMPUTE WS-MONTO-SOBREGIRO = ACT-BALANCE-DISPONIBLE * -1.
           COMPUTE WS-COMISION-CALC ROUNDED =
               WS-MONTO-SOBREGIRO * ACT-OVERDRAFT-RATE / 30.
           MOVE WS-COMISION-CALC TO WS-COMISION-DISP.
      *
       2200-APLICAR-COMISION.
           COMPUTE ACT-BALANCE = ACT-BALANCE - WS-COMISION-CALC.
           COMPUTE ACT-BALANCE-DISPONIBLE =
               ACT-BALANCE-DISPONIBLE - WS-COMISION-CALC.
           MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
           MOVE WS-USUARIO TO ACT-USER-LAST-MOD.
           ADD 1 TO ACT-TXN-COUNT-TODAY.
           ADD 1 TO ACT-TXN-COUNT-MONTH.
      *
           REWRITE ACCOUNT-RECORD.
           IF FL-ACCOUNT-STATUS NOT = '00'
               ADD 1 TO WS-CONT-ERRORES
           END-IF.
      *
       2300-REGISTRAR-TRANLOG-SOBREGIRO.
           OPEN I-O TRANLOG-FILE.
           IF FL-TRANLOG-STATUS = '93'
               OPEN OUTPUT TRANLOG-FILE
               CLOSE TRANLOG-FILE
               OPEN I-O TRANLOG-FILE
           END-IF.
      *
           ADD 1 TO WS-TRX-SEQ.
           MOVE WS-TRX-SEQ TO TRN-SEQ.
           MOVE WS-FECHA TO TRN-DATE.
           MOVE WS-HORA TO TRN-TIME.
           MOVE 'COM' TO TRN-TYPE.
           MOVE ACT-NBR TO TRN-ACCOUNT-NBR.
           MOVE SPACES TO TRN-ACCOUNT-DEST.
           MOVE SPACES TO TRN-CUSTOMER-ID.
           MOVE WS-COMISION-CALC TO TRN-AMOUNT.
           MOVE WS-COMISION-CALC TO TRN-AMOUNT-TOTAL.
           MOVE 0 TO TRN-AMOUNT-TAX.
           MOVE WS-COMISION-CALC TO TRN-FEE-AMOUNT.
           MOVE 'OD01' TO TRN-FEE-CODE.
           MOVE ACT-BRANCH-OPEN TO TRN-BRANCH.
           MOVE 'BATCH' TO TRN-TELLER-ID.
           MOVE WS-USUARIO TO TRN-USER-ID.
           MOVE 'CONSOLA' TO TRN-TERMINAL.
           MOVE '04' TO TRN-CHANNEL.
           MOVE 'COMISION SOBREGIRO' TO TRN-REFERENCE.
           MOVE 0 TO TRN-CHQ-NBR.
           MOVE SPACES TO TRN-CHQ-BANK
                          TRN-CHQ-ACCOUNT.
           MOVE 'C' TO TRN-STATUS.
           MOVE 0 TO TRN-REVERSE-SEQ.
           STRING 'COM SOBREGIRO ' ACT-NBR
             INTO TRN-DESCRIPTION.
      *
           WRITE TRANLOG-RECORD.
           IF FL-TRANLOG-STATUS NOT = '00'
               ADD 1 TO WS-CONT-ERRORES
           END-IF.
           CLOSE TRANLOG-FILE.
      *
      *--- PROCESAR MORA (PRESTAMOS) ---*
       3000-PROCESAR-MORA.
           MOVE 'PROCESANDO PRESTAMOS CON MORA...'
             TO WS-MENSAJE.
           DISPLAY SCR-PROGRESO.
      *
           OPEN I-O LOANMAST-FILE.
           IF FL-LOANMAST-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR LOANMAST' TO WS-MENSAJE-ERROR
               MOVE 5 TO WS-RETCODE
               GOTO 3000-EXIT
           END-IF.
      *
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO LON-NBR.
           START LOANMAST-FILE KEY IS GREATER THAN LON-NBR
               INVALID KEY
                   MOVE 'Y' TO WS-EOF-YES
           END-START.
      *
           PERFORM UNTIL WS-EOF-YES
               READ LOANMAST-FILE NEXT RECORD
                   AT END
                       MOVE 'Y' TO WS-EOF-YES
                       EXIT PERFORM
               END-READ
      *
               IF LON-STATUS NOT = 'A'
                   EXIT PERFORM CYCLE
               END-IF
      *
               IF LON-BALANCE-PAST-DUE = 0
                   EXIT PERFORM CYCLE
               END-IF
      *
               PERFORM 3100-CALCULAR-INTERES-MORA
               PERFORM 3200-ACTUALIZAR-PRESTAMO
               PERFORM 3300-REGISTRAR-TRANLOG-MORA
               ADD 1 TO WS-CONT-MORA
           END-PERFORM.
      *
           CLOSE LOANMAST-FILE.
           MOVE WS-CONT-MORA TO WS-CONT-MORA-DISP.
      *
       3000-EXIT.
           EXIT.
      *
       3100-CALCULAR-INTERES-MORA.
      *    INTERES MORA = PAST_DUE * TASA_MORA / 360
           COMPUTE WS-INTERES-MORA-CALC ROUNDED =
               LON-BALANCE-PAST-DUE * LON-INTEREST-MORA / 360.
      *
       3200-ACTUALIZAR-PRESTAMO.
           COMPUTE LON-AMOUNT-INTEREST = LON-AMOUNT-INTEREST
                                       + WS-INTERES-MORA-CALC.
           COMPUTE LON-BALANCE = LON-BALANCE + WS-INTERES-MORA-CALC.
           MOVE WS-FECHA TO LON-DATE-LAST-MOD.
           MOVE WS-USUARIO TO LON-USER-LAST-MOD.
      *
           REWRITE LOANMAST-RECORD.
           IF FL-LOANMAST-STATUS NOT = '00'
               ADD 1 TO WS-CONT-ERRORES
           END-IF.
      *
       3300-REGISTRAR-TRANLOG-MORA.
           OPEN I-O TRANLOG-FILE.
           IF FL-TRANLOG-STATUS = '93'
               OPEN OUTPUT TRANLOG-FILE
               CLOSE TRANLOG-FILE
               OPEN I-O TRANLOG-FILE
           END-IF.
      *
           ADD 1 TO WS-TRX-SEQ.
           MOVE WS-TRX-SEQ TO TRN-SEQ.
           MOVE WS-FECHA TO TRN-DATE.
           MOVE WS-HORA TO TRN-TIME.
           MOVE 'COM' TO TRN-TYPE.
           MOVE LON-ACCOUNT-DEBIT TO TRN-ACCOUNT-NBR.
           MOVE SPACES TO TRN-ACCOUNT-DEST.
           MOVE LON-CUSTOMER-ID TO TRN-CUSTOMER-ID.
           MOVE WS-INTERES-MORA-CALC TO TRN-AMOUNT.
           MOVE WS-INTERES-MORA-CALC TO TRN-AMOUNT-TOTAL.
           MOVE 0 TO TRN-AMOUNT-TAX.
           MOVE 0 TO TRN-FEE-AMOUNT.
           MOVE 'MORA' TO TRN-FEE-CODE.
           MOVE '0001' TO TRN-BRANCH.
           MOVE 'BATCH' TO TRN-TELLER-ID.
           MOVE WS-USUARIO TO TRN-USER-ID.
           MOVE 'CONSOLA' TO TRN-TERMINAL.
           MOVE '04' TO TRN-CHANNEL.
           MOVE LON-NBR TO TRN-REFERENCE.
           MOVE 0 TO TRN-CHQ-NBR.
           MOVE SPACES TO TRN-CHQ-BANK
                          TRN-CHQ-ACCOUNT.
           MOVE 'C' TO TRN-STATUS.
           MOVE 0 TO TRN-REVERSE-SEQ.
           STRING 'INT MORA ' LON-NBR
             INTO TRN-DESCRIPTION.
      *
           WRITE TRANLOG-RECORD.
           IF FL-TRANLOG-STATUS NOT = '00'
               ADD 1 TO WS-CONT-ERRORES
           END-IF.
           CLOSE TRANLOG-FILE.
      *
       9000-FINALIZAR.
           CLOSE ACCOUNT-FILE.
           CLOSE LOANMAST-FILE.
           CLOSE TRANLOG-FILE.
           IF WS-CONT-ERRORES > 0
               MOVE 1 TO WS-RETCODE
           ELSE
               MOVE 0 TO LS-RETCODE
           END-IF.
      *
       END PROGRAM BCHODO00.
