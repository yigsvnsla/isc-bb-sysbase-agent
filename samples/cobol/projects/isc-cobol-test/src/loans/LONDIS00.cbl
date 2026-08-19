       *================================================================*
       * LONDIS00 - DESEMBOLSO DE PRESTAMO                             *
       * PROPOSITO: CREAR LOANMAST, GENERAR AMORTIZACION, ACREDITAR    *
       * EQUIPO: CREDITO Y COBRANZA - 2004                             *
       * ARCHIVOS: LOANAPPL, LOANMAST, ACCOUNT, TRANLOG                *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. LONDIS00.
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
            SELECT LOANAPPL-FILE
                ASSIGN TO 'LOANAPPL.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS LAP-APPL-ID
                FILE STATUS IS FL-LOANAPPL-STATUS.
       *
            SELECT LOANMAST-FILE
                ASSIGN TO 'LOANMAST.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS LON-NBR
                FILE STATUS IS FL-LOANMAST-STATUS.
       *
            SELECT ACCOUNT-FILE
                ASSIGN TO 'ACCOUNT.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS ACT-NBR
                FILE STATUS IS FL-ACCOUNT-STATUS.
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
        FD  LOANAPPL-FILE
            RECORD 280 CHARACTERS.
        COPY FD-LOANAPPL REPLACING LOANAPPL-FILE BY LOANAPPL-FILE
                LOANAPPL-RECORD BY LOANAPPL-RECORD.
       *
        FD  LOANMAST-FILE
            RECORD 350 CHARACTERS.
        COPY FD-LOANMAST REPLACING LOANMAST-FILE BY LOANMAST-FILE
                LOANMAST-RECORD BY LOANMAST-RECORD.
       *
        FD  ACCOUNT-FILE
            RECORD 200 CHARACTERS.
        COPY FD-ACCOUNT REPLACING ACCOUNT-FILE BY ACCOUNT-FILE
                ACCOUNT-RECORD BY ACCOUNT-RECORD.
       *
        FD  TRANLOG-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TRANLOG REPLACING TRANLOG-FILE BY TRANLOG-FILE
                TRANLOG-RECORD BY TRANLOG-RECORD.
       *================================================================*
        WORKING-STORAGE SECTION.
        COPY CPY-COMMON.
        COPY CPY-SCREEN.
       *
        01  WS-CRT-STATUS                  PIC 9(04).
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-ENTER              VALUE 0013.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-APPL-ID                 PIC X(10).
            05  WS-LON-NBR                 PIC X(10).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-TRN-SEQ                 PIC 9(10).
            05  WS-LON-SEQ                 PIC 9(10).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-I                       PIC 9(04).
            05  WS-BALANCE-AMORT           PIC 9(13)V99 COMP-3.
            05  WS-CUOTA-PRINCIPAL         PIC 9(09)V99 COMP-3.
            05  WS-CUOTA-INTERES           PIC 9(09)V99 COMP-3.
            05  WS-CUOTA-TOTAL             PIC 9(09)V99 COMP-3.
            05  WS-TASA-MENSUAL            PIC 9(03)V9(06) COMP-3.
            05  WS-FACTOR                  PIC 9(03)V9(06) COMP-3.
            05  WS-FECHA-PAGO              PIC 9(08).
            05  WS-ANO                      PIC 9(04).
            05  WS-MES                      PIC 9(02).
            05  WS-DIA                      PIC 9(02).
            05  WS-INTERES-CALC             PIC 9(09)V99 COMP-3.
            05  WS-PRINCIPAL-CALC           PIC 9(09)V99 COMP-3.
            05  WS-MONTHLY-RATE             PIC 9(03)V9(06) COMP-3.
            05  WS-TEMP-RATE                PIC 9(03)V9(06) COMP-3.
            05  WS-TEMP-BALANCE             PIC 9(13)V99 COMP-3.
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'LONDIS00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-BUSQUEDA.
            05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - DESEMBOLSO DE PRESTAMO'.
            05  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
            05  LINE 02  COL 01  PIC X(80)
               VALUE ' DESEMBOLSO DE PRESTAMO APROBADO'.
            05  LINE 04  COL 05  PIC X(25) VALUE 'ID SOLICITUD APROBADA:'.
            05  LINE 04  COL 30  PIC X(10)
               USING WS-APPL-ID AUTO PROMPT '__________'.
            05  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
            05  LINE 24  COL 05  PIC X(60)
               VALUE 'ENTER=DESEMBOLSAR  PF12=SALIR'.
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
            MOVE SPACES TO WS-USUARIO WS-MENSAJE WS-MENSAJE-ERROR.
            MOVE LS-USUARIO TO WS-USUARIO.
            MOVE 99 TO LS-RETCODE.
            PERFORM 1000-INICIALIZAR.
       *
        BUSQUEDA-LOOP.
            PERFORM 2000-MOSTRAR.
            ACCEPT SCR-BUSQUEDA.
       *
            IF WS-CRT-PF12
                GOTO MAIN-EXIT
            END-IF.
       *
            IF WS-CRT-CLEAR
                MOVE SPACES TO WS-APPL-ID WS-MENSAJE WS-MENSAJE-ERROR
                GO TO BUSQUEDA-LOOP
            END-IF.
       *
            IF WS-CRT-ENTER
                PERFORM 3000-VALIDAR-Y-DESEMBOLSAR
                IF WS-RETCODE = 00
                    PERFORM 4000-RESULTADO
                    GOTO MAIN-EXIT
                END-IF
            END-IF.
            GO TO BUSQUEDA-LOOP.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            DISPLAY SPACES UPON CRT.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            OPEN I-O LOANAPPL-FILE LOANMAST-FILE ACCOUNT-FILE
                 TRANLOG-FILE.
            MOVE 'INGRESE ID SOLICITUD APROBADA' TO WS-MENSAJE.
       *
        2000-MOSTRAR.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            DISPLAY SCR-BUSQUEDA.
       *
        2100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        3000-VALIDAR-Y-DESEMBOLSAR.
            IF WS-APPL-ID = SPACES
                MOVE 'INGRESE ID SOLICITUD' TO WS-MENSAJE-ERROR
                MOVE 99 TO LS-RETCODE
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE WS-APPL-ID TO LAP-APPL-ID.
            READ LOANAPPL-FILE KEY IS LAP-APPL-ID
                INVALID KEY
                    MOVE 'SOLICITUD NO EXISTE' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 3000-EXIT
            END-READ.
       *
            IF NOT LAP-STATUS-APROBADO
                MOVE 'SOLICITUD NO APROBADA' TO WS-MENSAJE-ERROR
                MOVE 99 TO LS-RETCODE
                GOTO 3000-EXIT
            END-IF.
       *
            CALL 'COMMSGF' USING 'Q001'
                                 'CONFIRMA DESEMBOLSO?'
                                 'Q'
                                 WS-CONFIRMA.
            IF WS-CONFIRMA NOT = 'S'
                MOVE 'DESEMBOLSO CANCELADO' TO WS-MENSAJE
                MOVE 99 TO LS-RETCODE
                GOTO 3000-EXIT
            END-IF.
       *
            PERFORM 5000-CREAR-LOANMAST.
            IF LS-RETCODE NOT = 00
                GOTO 3000-EXIT
            END-IF.
       *
            PERFORM 6000-ACREDITAR-CUENTA.
            IF LS-RETCODE NOT = 00
                GOTO 3000-EXIT
            END-IF.
       *
            PERFORM 7000-ELIMINAR-SOLICITUD.
       *
            MOVE 00 TO LS-RETCODE.
            STRING 'DESEMBOLSO ' WS-LON-NBR ' CTA '
                   LAP-ACCOUNT-DISBURSEMENT
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
       *
        3000-EXIT.
            EXIT.
       *
        5000-CREAR-LOANMAST.
            ADD 1 TO WS-LON-SEQ.
            MOVE WS-LON-SEQ TO WS-LON-NBR.
            MOVE WS-LON-NBR TO LON-NBR.
            MOVE LAP-APPL-ID TO LON-APPL-ID.
            MOVE LAP-CUSTOMER-ID TO LON-CUSTOMER-ID.
            MOVE LAP-TYPE TO LON-TYPE.
            MOVE LAP-AMOUNT-REQUESTED TO LON-AMOUNT-APPROVED.
            MOVE LAP-AMOUNT-REQUESTED TO LON-AMOUNT-DISBURSED.
            MOVE LAP-AMOUNT-REQUESTED TO LON-BALANCE.
            MOVE ZERO TO LON-BALANCE-PAST-DUE.
            MOVE LAP-PROPOSED-RATE TO LON-INTEREST-RATE.
            MOVE LAP-TERM-MONTHS TO LON-TERM-MONTHS.
            MOVE LAP-PAYMENT-FREQ TO LON-FREQUENCY.
            MOVE LAP-TERM-MONTHS TO LON-PAYMENTS-TOTAL.
            MOVE ZERO TO LON-PAYMENTS-MADE.
            MOVE ZERO TO LON-PAYMENTS-OVERDUE.
            MOVE 'F' TO LON-AMORT-TYPE.
            MOVE WS-FECHA TO LON-DATE-APPROVAL.
            MOVE WS-FECHA TO LON-DATE-DISBURSEMENT.
            MOVE LAP-FECHA-VENCIMIENTO TO LON-DATE-MATURITY.
            MOVE SPACES TO LON-COLLATERAL-TYPE
                           LON-COLLATERAL-DESC.
            MOVE ZERO TO LON-COLLATERAL-VALUE.
            MOVE LAP-ACCOUNT-DISBURSEMENT TO LON-ACCOUNT-DISBURSEMENT.
            MOVE 'A' TO LON-STATUS.
            MOVE '1' TO LON-CLASSIFICATION.
            MOVE WS-USUARIO TO LON-OFFICER.
            MOVE WS-USUARIO TO LON-USER-LAST-MOD.
            MOVE WS-FECHA TO LON-DATE-LAST-MOD.
       *
            PERFORM 5100-GENERAR-AMORTIZACION.
       *
            WRITE LOANMAST-RECORD
                INVALID KEY
                    MOVE 'ERROR CREAR PRESTAMO' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 5000-EXIT
            END-WRITE.
       *
            MOVE 00 TO LS-RETCODE.
        5000-EXIT.
            EXIT.
       *
        5100-GENERAR-AMORTIZACION.
            MOVE LAP-AMOUNT-REQUESTED TO WS-BALANCE-AMORT.
            MOVE LAP-PROPOSED-RATE TO WS-MONTHLY-RATE.
            DIVIDE 12 INTO WS-MONTHLY-RATE.
            DIVIDE 100 INTO WS-MONTHLY-RATE.
       *
            COMPUTE WS-TEMP-RATE = 1 + WS-MONTHLY-RATE.
            MOVE WS-TEMP-RATE TO WS-FACTOR.
            PERFORM VARYING WS-I FROM 1 BY 1
                UNTIL WS-I > LAP-TERM-MONTHS
                COMPUTE WS-FACTOR = WS-FACTOR * WS-TEMP-RATE
            END-PERFORM.
       *
            COMPUTE WS-CUOTA-TOTAL =
                WS-BALANCE-AMORT * WS-MONTHLY-RATE * WS-FACTOR
                / (WS-FACTOR - 1).
            MOVE WS-CUOTA-TOTAL TO LON-INSTALLMENT-AMOUNT.
       *
            MOVE WS-FECHA TO WS-ANO WS-MES WS-DIA.
            MOVE WS-ANO TO WS-ANO.
       *
            MOVE WS-BALANCE-AMORT TO WS-TEMP-BALANCE.
            PERFORM VARYING WS-I FROM 1 BY 1
                UNTIL WS-I > LAP-TERM-MONTHS
                MOVE WS-I TO LON-INST-NBR(WS-I)
                ADD 1 TO WS-MES
                IF WS-MES > 12
                    MOVE 1 TO WS-MES
                    ADD 1 TO WS-ANO
                END-IF
                MOVE WS-ANO TO WS-FECHA-PAGO
                MULTIPLY WS-ANO BY 10000 GIVING WS-FECHA-PAGO
                MULTIPLY WS-MES BY 100 GIVING WS-MES
                ADD WS-MES TO WS-FECHA-PAGO
                ADD 1 TO WS-FECHA-PAGO
                MOVE WS-FECHA-PAGO TO LON-INST-DUE-DATE(WS-I)
                COMPUTE WS-CUOTA-INTERES =
                    WS-TEMP-BALANCE * WS-MONTHLY-RATE
                COMPUTE WS-CUOTA-PRINCIPAL =
                    WS-CUOTA-TOTAL - WS-CUOTA-INTERES
                MOVE WS-CUOTA-TOTAL TO LON-INST-AMOUNT(WS-I)
                MOVE WS-CUOTA-PRINCIPAL TO LON-INST-PRINCIPAL(WS-I)
                MOVE WS-CUOTA-INTERES TO LON-INST-INTEREST(WS-I)
                SUBTRACT WS-CUOTA-PRINCIPAL FROM WS-TEMP-BALANCE
                MOVE WS-TEMP-BALANCE TO LON-INST-BALANCE(WS-I)
                MOVE 'P' TO LON-INST-STATUS(WS-I)
            END-PERFORM.
       *
        6000-ACREDITAR-CUENTA.
            MOVE LAP-ACCOUNT-DISBURSEMENT TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CTA DESEMBOLSO NO EXISTE'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 6000-EXIT
            END-READ.
       *
            ADD LAP-AMOUNT-REQUESTED TO ACT-BALANCE.
            ADD LAP-AMOUNT-REQUESTED TO ACT-BALANCE-DISPONIBLE.
            MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
            MOVE WS-USUARIO TO ACT-USER-LAST-MOD.
            REWRITE ACCOUNT-RECORD
                INVALID KEY
                    MOVE 'ERROR ACT CTA' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 6000-EXIT
            END-REWRITE.
       *
            PERFORM 6100-TRANLOG.
            MOVE 00 TO LS-RETCODE.
        6000-EXIT.
            EXIT.
       *
        6100-TRANLOG.
            MOVE WS-TRN-SEQ TO TRN-SEQ.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'APR' TO TRN-TYPE.
            MOVE LAP-ACCOUNT-DISBURSEMENT TO TRN-ACCOUNT-NBR.
            MOVE SPACES TO TRN-ACCOUNT-DEST.
            MOVE LAP-CUSTOMER-ID TO TRN-CUSTOMER-ID.
            MOVE LAP-AMOUNT-REQUESTED TO TRN-AMOUNT.
            MOVE ZERO TO TRN-AMOUNT-TAX.
            MOVE LAP-AMOUNT-REQUESTED TO TRN-AMOUNT-TOTAL.
            MOVE LAP-AMOUNT-REQUESTED TO TRN-AMOUNT-ORIGINAL.
            MOVE ZERO TO TRN-FEE-AMOUNT.
            MOVE SPACES TO TRN-FEE-CODE.
            MOVE WS-SUCURSAL-ID TO TRN-BRANCH.
            MOVE WS-USUARIO TO TRN-TELLER-ID TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '04' TO TRN-CHANNEL.
            MOVE 'DESEMBOLSO PRESTAMO' TO TRN-REFERENCE.
            MOVE ZERO TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE ZERO TO TRN-REVERSE-SEQ.
            STRING 'DES ' WS-LON-NBR ' CTA '
                   LAP-ACCOUNT-DISBURSEMENT
              INTO TRN-DESCRIPTION.
            WRITE TRANLOG-RECORD
                INVALID KEY
                    MOVE 'ERROR TRANLOG' TO WS-MENSAJE-ERROR
            END-WRITE.
            ADD 1 TO WS-TRN-SEQ.
       *
        7000-ELIMINAR-SOLICITUD.
            MOVE WS-APPL-ID TO LAP-APPL-ID.
            READ LOANAPPL-FILE KEY IS LAP-APPL-ID
                INVALID KEY
                    GOTO 7000-EXIT
            END-READ.
            MOVE 'D' TO LAP-STATUS.
            REWRITE LOANAPPL-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ACTUALIZAR SOLICITUD'
                      TO WS-MENSAJE-ERROR
            END-REWRITE.
        7000-EXIT.
            EXIT.
       *
        4000-RESULTADO.
            MOVE 'DESEMBOLSO EXITOSO' TO WS-MENSAJE.
            PERFORM 2100-LIMPIAR.
            DISPLAY SCR-BUSQUEDA.
            MOVE 'PRESIONE ENTER...' TO WS-MENSAJE.
            DISPLAY SCR-BUSQUEDA.
            ACCEPT SCR-BUSQUEDA.
       *
        9000-FINALIZAR.
            CLOSE LOANAPPL-FILE LOANMAST-FILE ACCOUNT-FILE
                  TRANLOG-FILE.
            GOBACK.
       *
        END PROGRAM LONDIS00.
