       *================================================================*
       * FTWIR000 - TRANSFERENCIA WIRE / ELECTRONICA                  *
       * PROPOSITO: ENVIAR TRANSFERENCIA INTERNACIONAL (SWIFT/WIRE)   *
       * EQUIPO: TRANSACCIONES ELECTRONICAS - 2003                   *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. FTWIR000.
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
       *
            SELECT FEESCHED-FILE
                ASSIGN TO 'FEESCHED.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS FEE-CODIGO
                FILE STATUS IS FL-FEESCHED-STATUS.
       *
            SELECT RATEFILE-FILE
                ASSIGN TO 'RATEFILE.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS RAT-CODIGO
                FILE STATUS IS FL-RATEFILE-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  ACCOUNT-FILE
            RECORD 200 CHARACTERS.
        COPY FD-ACCOUNT.
       *
        FD  TRANLOG-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TRANLOG.
       *
        FD  FEESCHED-FILE
            RECORD 120 CHARACTERS.
        COPY FD-FEESCHED.
       *
        FD  RATEFILE-FILE
            RECORD 100 CHARACTERS.
        COPY FD-RATEFILE.
       *================================================================*
        WORKING-STORAGE SECTION.
       *
        COPY CPY-COMMON.
        COPY CPY-SCREEN.
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
            05  WS-USUARIO-ID              PIC X(08).
            05  WS-SUCURSAL-ID             PIC X(04).
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'FTWIR000'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-SRC-ACCT                PIC X(10).
            05  WS-BENEF-NAME              PIC X(40).
            05  WS-BANK-NAME               PIC X(40).
            05  WS-SWIFT-CODE              PIC X(11).
            05  WS-DEST-ACCOUNT            PIC X(20).
            05  WS-AMOUNT                  PIC 9(13)V99 COMP-3.
            05  WS-CURRENCY                PIC X(03).
            05  WS-FEE-AMOUNT              PIC 9(07)V99 COMP-3.
            05  WS-TOTAL-AMOUNT            PIC 9(13)V99 COMP-3.
            05  WS-EXCHANGE-RATE           PIC 9(03)V9(06) COMP-3.
            05  WS-CONFIRM                 PIC X(01).
            05  WS-AUDIT-DATA              PIC X(60).
            05  WS-TRN-SEQ-AUX             PIC 9(10).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-WIRE.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' TRANSFERENCIA WIRE'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-DATOS.
                10  LINE 04  COL 05  PIC X(20) VALUE 'CTA ORIGEN:'.
                10  LINE 04  COL 25  PIC X(10)
                    USING WS-SRC-ACCT AUTO PROMPT '__________'.
                10  LINE 04  COL 40  PIC X(30)
                    VALUE 'ENTER=CONS  PF1=SRH CTA'.
       *
                10  LINE 06  COL 05  PIC X(20) VALUE 'BENEFICIARIO:'.
                10  LINE 06  COL 25  PIC X(40)
                    USING WS-BENEF-NAME AUTO.
       *
                10  LINE 07  COL 05  PIC X(20) VALUE 'BANCO:'.
                10  LINE 07  COL 25  PIC X(40)
                    USING WS-BANK-NAME AUTO.
       *
                10  LINE 08  COL 05  PIC X(20) VALUE 'SWIFT:'.
                10  LINE 08  COL 25  PIC X(11)
                    USING WS-SWIFT-CODE AUTO PROMPT '___________'.
       *
                10  LINE 09  COL 05  PIC X(20) VALUE 'CTA DESTINO:'.
                10  LINE 09  COL 25  PIC X(20)
                    USING WS-DEST-ACCOUNT AUTO.
       *
                10  LINE 11  COL 05  PIC X(15) VALUE 'MONTO:'.
                10  LINE 11  COL 25  PIC -(11)9.99
                    USING WS-AMOUNT AUTO.
                10  LINE 11  COL 45  PIC X(15) VALUE 'MONEDA:'.
                10  LINE 11  COL 60  PIC X(03)
                    USING WS-CURRENCY AUTO PROMPT '___'.
       *
                10  LINE 13  COL 05  PIC X(20) VALUE 'COMISION:'.
                10  LINE 13  COL 28  PIC -(07)9.99 FROM WS-FEE-AMOUNT.
                10  LINE 13  COL 45  PIC X(20) VALUE 'TOTAL DEBITO:'.
                10  LINE 13  COL 65  PIC -(11)9.99 FROM WS-TOTAL-AMOUNT.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF1=SRH CTA  PF11=AYU  PF12=CANCEL'.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'ENTER=PROCESAR WIRE'.
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
            MOVE LS-USUARIO TO WS-USUARIO-ID.
            MOVE 00 TO LS-RETCODE.
            MOVE 00 TO WS-RETCODE.
            MOVE SPACES TO WS-SRC-ACCT
                           WS-BENEF-NAME
                           WS-BANK-NAME
                           WS-SWIFT-CODE
                           WS-DEST-ACCOUNT
                           WS-CURRENCY.
            MOVE 0 TO WS-AMOUNT
                      WS-FEE-AMOUNT
                      WS-TOTAL-AMOUNT
                      WS-EXCHANGE-RATE.
       *
            PERFORM 1000-INICIALIZAR.
       *
        WIRE-LOOP.
            PERFORM 2000-REFRESCAR.
            DISPLAY SCR-WIRE.
            ACCEPT SCR-WIRE.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    CALL 'ACTINQ00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO WIRE-LOOP
       *
                WHEN WS-CRT-ENTER
                    PERFORM 3000-PROCESAR-WIRE
                    GO TO WIRE-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'FTWIR000'
                    GO TO WIRE-LOOP
       *
                WHEN WS-CRT-PF12
                    PERFORM 5000-CONFIRMAR-CANCELACION
                    IF WS-CONFIRMED
                        MOVE 00 TO LS-RETCODE
                        GO TO WIRE-EXIT
                    ELSE
                        GO TO WIRE-LOOP
                    END-IF
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-SRC-ACCT WS-BENEF-NAME
                                   WS-BANK-NAME WS-SWIFT-CODE
                                   WS-DEST-ACCOUNT WS-CURRENCY
                    MOVE 0 TO WS-AMOUNT WS-FEE-AMOUNT WS-TOTAL-AMOUNT
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO WIRE-LOOP
       *
                WHEN OTHER
                    MOVE 'LLENE CAMPOS Y ENTER  PF12=CANCEL'
                      TO WS-MENSAJE-ERROR
                    GO TO WIRE-LOOP
            END-EVALUATE.
       *
        WIRE-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE DATOS DE TRANSFERENCIA WIRE' TO WS-MENSAJE.
            PERFORM 1100-LIMPIAR.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        2000-REFRESCAR.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
        3000-PROCESAR-WIRE.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-SRC-ACCT = SPACES
                MOVE 'INGRESE CTA ORIGEN' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-BENEF-NAME = SPACES
                MOVE 'INGRESE NOMBRE BENEFICIARIO' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-SWIFT-CODE = SPACES
                MOVE 'INGRESE CODIGO SWIFT' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-AMOUNT <= 0
                MOVE 'MONTO INVALIDO' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            OPEN I-O ACCOUNT-FILE.
            MOVE WS-SRC-ACCT TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CTA ORIGEN NO ENCONTRADA'
                      TO WS-MENSAJE-ERROR
                    CLOSE ACCOUNT-FILE
                    GOTO 3000-EXIT
            END-READ.
       *
            IF ACT-STATUS NOT = 'A'
                MOVE 'CTA ORIGEN NO ACTIVA' TO WS-MENSAJE-ERROR
                CLOSE ACCOUNT-FILE
                GOTO 3000-EXIT
            END-IF.
       *
            PERFORM 3100-CALCULAR-FEE-WIRE.
            PERFORM 3200-CALCULAR-EXCHANGE.
       *
            COMPUTE WS-TOTAL-AMOUNT = WS-AMOUNT + WS-FEE-AMOUNT.
       *
            IF ACT-BALANCE-DISPONIBLE < WS-TOTAL-AMOUNT
                MOVE 'FONDOS INSUFICIENTES (INCLUYE COMISION)'
                  TO WS-MENSAJE-ERROR
                CLOSE ACCOUNT-FILE
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-CONFIRM.
            DISPLAY 'CONFIRMAR WIRE POR ' WS-AMOUNT
                    ' ' WS-CURRENCY ' + FEE ' WS-FEE-AMOUNT '? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRM AT LINE 23 COLUMN 70.
            IF WS-CONFIRM NOT = 'S' AND NOT = 's'
                MOVE 'WIRE CANCELADO' TO WS-MENSAJE
                CLOSE ACCOUNT-FILE
                GOTO 3000-EXIT
            END-IF.
       *
            SUBTRACT WS-TOTAL-AMOUNT FROM ACT-BALANCE
                                        ACT-BALANCE-DISPONIBLE.
            MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
            REWRITE ACCOUNT-RECORD.
            CLOSE ACCOUNT-FILE.
       *
            PERFORM 4000-ESCRIBIR-TRANLOG.
            PERFORM 6000-AUDITAR.
       *
            STRING 'WIRE POR ' WS-AMOUNT ' ' WS-CURRENCY
                   ' A ' WS-BENEF-NAME ' PROCESADO'
              INTO WS-MENSAJE.
        3000-EXIT.
            EXIT.
       *
        3100-CALCULAR-FEE-WIRE.
            MOVE 0 TO WS-FEE-AMOUNT.
            OPEN I-O FEESCHED-FILE.
            IF FL-FEESCHED-STATUS NOT = '00' AND NOT = '23'
                GOTO 3100-EXIT
            END-IF.
       *
            MOVE 'WI01' TO FEE-CODIGO.
            READ FEESCHED-FILE KEY IS FEE-CODIGO
                INVALID KEY
                    CLOSE FEESCHED-FILE
                    GOTO 3100-EXIT
            END-READ.
       *
            IF FL-FEESCHED-STATUS = '00'
                IF FEE-TIPO-FIJA
                    MOVE FEE-AMOUNT-FIJO TO WS-FEE-AMOUNT
                ELSE
                    IF FEE-TIPO-PORCENTAJE
                        COMPUTE WS-FEE-AMOUNT =
                            WS-AMOUNT * FEE-PORCENTAJE / 100
                    END-IF
                END-IF
            END-IF.
       *
            CLOSE FEESCHED-FILE.
        3100-EXIT.
            EXIT.
       *
        3200-CALCULAR-EXCHANGE.
            MOVE 0 TO WS-EXCHANGE-RATE.
       *
            IF ACT-CURRENCY NOT = WS-CURRENCY
                OPEN I-O RATEFILE-FILE
                IF FL-RATEFILE-STATUS = '00'
                    STRING 'RF' ACT-CURRENCY WS-CURRENCY
                      INTO RAT-CODIGO
                    READ RATEFILE-FILE KEY IS RAT-CODIGO
                        INVALID KEY
                            MOVE 1 TO WS-EXCHANGE-RATE
                            GOTO 3200-CONTINUE
                    END-READ
                    IF FL-RATEFILE-STATUS = '00'
                        MOVE RAT-TASA-ANUAL TO WS-EXCHANGE-RATE
                        COMPUTE WS-AMOUNT =
                            WS-AMOUNT * WS-EXCHANGE-RATE
                    ELSE
                        MOVE 1 TO WS-EXCHANGE-RATE
                    END-IF
        3200-CONTINUE
                CLOSE RATEFILE-FILE
                END-IF
            END-IF.
       *
        4000-ESCRIBIR-TRANLOG.
            OPEN I-O TRANLOG-FILE.
            IF FL-TRANLOG-STATUS NOT = '00'
                OPEN OUTPUT TRANLOG-FILE
                IF FL-TRANLOG-STATUS NOT = '00'
                    GOTO 4000-EXIT
                END-IF
            END-IF.
       *
            MOVE 0 TO TRN-SEQ.
            START TRANLOG-FILE KEY IS NOT < TRN-SEQ
                INVALID KEY
                    MOVE 1 TO TRN-SEQ
                    GOTO 4000-ESCRIBE
            END-START.
       *
            READ TRANLOG-FILE NEXT RECORD
                AT END
                    MOVE 1 TO TRN-SEQ
                    GOTO 4000-ESCRIBE
            END-READ.
       *
            ADD 1 TO TRN-SEQ.
            MOVE TRN-SEQ TO WS-TRN-SEQ-AUX.
            MOVE WS-TRN-SEQ-AUX TO TRN-SEQ.
       *
        4000-ESCRIBE.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'TRF' TO TRN-TYPE.
            MOVE WS-SRC-ACCT TO TRN-ACCOUNT-NBR.
            MOVE WS-DEST-ACCOUNT TO TRN-ACCOUNT-DEST.
            MOVE SPACES TO TRN-CUSTOMER-ID.
            MOVE WS-AMOUNT TO TRN-AMOUNT.
            MOVE 0 TO TRN-AMOUNT-TAX.
            MOVE WS-TOTAL-AMOUNT TO TRN-AMOUNT-TOTAL.
            MOVE WS-AMOUNT TO TRN-AMOUNT-ORIGINAL.
            MOVE WS-FEE-AMOUNT TO TRN-FEE-AMOUNT.
            MOVE 'WI01' TO TRN-FEE-CODE.
            MOVE WS-SUCURSAL-ID TO TRN-BRANCH.
            MOVE SPACES TO TRN-TELLER-ID.
            MOVE WS-USUARIO-ID TO TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '03' TO TRN-CHANNEL.
            STRING 'FTWIR' WS-FECHA(5:4) WS-FECHA(1:4)
              INTO TRN-REFERENCE.
            MOVE 0 TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
            MOVE 'P' TO TRN-STATUS.
            MOVE 0 TO TRN-REVERSE-SEQ.
            MOVE 'WIRE: ' INTO TRN-DESCRIPTION.
            STRING TRN-DESCRIPTION WS-BENEF-NAME
              INTO TRN-DESCRIPTION.
       *
            WRITE TRANLOG-RECORD
                INVALID KEY
                    DISPLAY 'ERROR TRANLOG'
            END-WRITE.
       *
            CLOSE TRANLOG-FILE.
        4000-EXIT.
            EXIT.
       *
        5000-CONFIRMAR-CANCELACION.
            MOVE SPACES TO WS-CONFIRM.
            DISPLAY 'CANCELAR WIRE? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRM AT LINE 23 COLUMN 30.
            IF WS-CONFIRM = 'S' OR WS-CONFIRM = 's'
                MOVE 'Y' TO WS-SWITCH-CONFIRM
            ELSE
                MOVE 'N' TO WS-SWITCH-CONFIRM
                MOVE 'OPERACION CONTINUA' TO WS-MENSAJE
            END-IF.
       *
        6000-AUDITAR.
            STRING 'FTWIR000 CTA=' WS-SRC-ACCT ' SWIFT='
                   WS-SWIFT-CODE ' MONTO=' WS-AMOUNT
              INTO WS-AUDIT-DATA.
            CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                  WS-AUDIT-DATA.
       *
        END PROGRAM FTWIR000.
