       *================================================================*
       * TLRTRF00 - TRANSFERENCIA ENTRE CUENTAS                         *
       * PROPOSITO: DEBITAR CUENTA ORIGEN, ACREDITAR DESTINO           *
       * EQUIPO: VENTANILLA - 2003                                     *
       * ARCHIVOS: ACCOUNT (ORIGEN/DESTINO), TRANLOG, TELLEREC         *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. TLRTRF00.
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
            SELECT TELLEREC-FILE
                ASSIGN TO 'TELLEREC.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS TLR-ID
                FILE STATUS IS FL-TELLEREC-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  ACCOUNT-FILE
            RECORD 200 CHARACTERS.
        COPY FD-ACCOUNT REPLACING ACCOUNT-FILE BY ACCOUNT-FILE
                ACCOUNT-RECORD BY ACCOUNT-RECORD.
       *
        FD  TRANLOG-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TRANLOG REPLACING TRANLOG-FILE BY TRANLOG-FILE
                TRANLOG-RECORD BY TRANLOG-RECORD.
       *
        FD  TELLEREC-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TELLEREC REPLACING TELLEREC-FILE BY TELLEREC-FILE
                TELLEREC-RECORD BY TELLEREC-RECORD.
       *================================================================*
        WORKING-STORAGE SECTION.
        COPY CPY-COMMON.
        COPY CPY-SCREEN.
       *
        01  WS-CRT-STATUS                  PIC 9(04).
            88  WS-CRT-PF1                VALUE 1001.
            88  WS-CRT-PF2                VALUE 1002.
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-ENTER              VALUE 0013.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-CTA-ORIGEN              PIC X(10).
            05  WS-CTA-DESTINO             PIC X(10).
            05  WS-CLIENTE-ORIGEN          PIC X(10).
            05  WS-CLIENTE-DESTINO         PIC X(10).
            05  WS-MONTO                   PIC S9(13)V99 COMP-3.
            05  WS-MONTO-DISPLAY           PIC Z(12)9.99.
            05  WS-BALANCE-ORIGEN          PIC S9(13)V99 COMP-3.
            05  WS-BALANCE-ORIGEN-DISP     PIC Z(12)9.99.
            05  WS-BALANCE-DESTINO         PIC S9(13)V99 COMP-3.
            05  WS-BALANCE-DESTINO-DISP    PIC Z(12)9.99.
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-TRN-SEQ                 PIC 9(10).
            05  WS-CONFIRMA                PIC X(01).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'TLRTRF00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-TRF.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - TRANSFERENCIA ENTRE CUENTAS'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' CAJERO: '.
                10  LINE 02  COL 10  PIC X(08) FROM WS-USUARIO.
       *
            05  SCR-CUERPO.
                10  LINE 04  COL 05  PIC X(20) VALUE 'CTA ORIGEN:'.
                10  LINE 04  COL 20  PIC X(10)
                   USING WS-CTA-ORIGEN AUTO PROMPT '__________'.
                10  LINE 04  COL 35  PIC X(10) VALUE 'PF1=VALIDAR'.
       *
                10  LINE 05  COL 05  PIC X(20) VALUE 'CLIENTE:'.
                10  LINE 05  COL 15  PIC X(10) FROM WS-CLIENTE-ORIGEN.
                10  LINE 06  COL 05  PIC X(20) VALUE 'SALDO DISP:'.
                10  LINE 06  COL 20  PIC Z(12)9.99 FROM WS-BALANCE-ORIGEN-DISP.
       *
                10  LINE 08  COL 05  PIC X(20) VALUE 'CTA DESTINO:'.
                10  LINE 08  COL 20  PIC X(10)
                   USING WS-CTA-DESTINO AUTO PROMPT '__________'.
                10  LINE 08  COL 35  PIC X(10) VALUE 'PF2=VALIDAR'.
       *
                10  LINE 09  COL 05  PIC X(20) VALUE 'CLIENTE:'.
                10  LINE 09  COL 15  PIC X(10) FROM WS-CLIENTE-DESTINO.
                10  LINE 10  COL 05  PIC X(20) VALUE 'SALDO ACT:'.
                10  LINE 10  COL 20  PIC Z(12)9.99 FROM WS-BALANCE-DESTINO-DISP.
       *
                10  LINE 12  COL 05  PIC X(20) VALUE 'MONTO A TRANSFERIR:'.
                10  LINE 12  COL 25  PIC Z(12)9.99
                   USING WS-MONTO-DISPLAY AUTO PROMPT '____________.__'.
       *
            05  SCR-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'PF1=VAL ORI  PF2=VAL DES  ENTER=TRF  PF12=SAL'.
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
        TRF-LOOP.
            PERFORM 2000-MOSTRAR.
            ACCEPT SCR-TRF.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    PERFORM 3000-VALIDAR-ORIGEN
                    GO TO TRF-LOOP
       *
                WHEN WS-CRT-PF2
                    PERFORM 4000-VALIDAR-DESTINO
                    GO TO TRF-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 'TRANSFERENCIA CANCELADA' TO WS-MENSAJE
                    GOTO MAIN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    PERFORM 1100-LIMPIAR
                    GO TO TRF-LOOP
       *
                WHEN WS-CRT-ENTER
                    PERFORM 5000-VALIDAR-TRF
                    IF WS-ERROR-NO
                        PERFORM 6000-CONFIRMAR
                        IF WS-CONFIRMA = 'S'
                            PERFORM 7000-PROCESAR-TRF
                            IF WS-RETCODE = 00
                                PERFORM 8000-RESULTADO
                                MOVE 00 TO LS-RETCODE
                                GOTO MAIN-EXIT
                            END-IF
                        END-IF
                    END-IF
                    GO TO TRF-LOOP
       *
                WHEN OTHER
                    MOVE 'INGRESE CUENTAS Y MONTO' TO WS-MENSAJE-ERROR
                    GO TO TRF-LOOP
            END-EVALUATE.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'TRANSFERENCIA - INGRESE CUENTAS' TO WS-MENSAJE.
            OPEN I-O ACCOUNT-FILE.
            OPEN I-O TRANLOG-FILE.
            OPEN I-O TELLEREC-FILE.
       *
        1100-LIMPIAR.
            MOVE SPACES TO WS-CTA-ORIGEN WS-CTA-DESTINO
                           WS-CLIENTE-ORIGEN WS-CLIENTE-DESTINO
                           WS-MENSAJE WS-MENSAJE-ERROR.
            MOVE ZERO TO WS-MONTO WS-MONTO-DISPLAY
                         WS-BALANCE-ORIGEN WS-BALANCE-ORIGEN-DISP
                         WS-BALANCE-DESTINO WS-BALANCE-DESTINO-DISP.
       *
        2000-MOSTRAR.
            PERFORM 2100-LIMPIAR-PANTALLA.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE WS-MONTO TO WS-MONTO-DISPLAY.
            DISPLAY SCR-TRF.
       *
        2100-LIMPIAR-PANTALLA.
            DISPLAY SPACES UPON CRT.
       *
        3000-VALIDAR-ORIGEN.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            IF WS-CTA-ORIGEN = SPACES
                MOVE 'INGRESE CTA ORIGEN' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
            MOVE WS-CTA-ORIGEN TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CTA ORIGEN NO EXISTE' TO WS-MENSAJE-ERROR
                    GOTO 3000-EXIT
            END-READ.
            IF NOT ACT-STATUS-ACTIVE
                MOVE 'CTA ORIGEN NO ACTIVA' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
            CALL 'ACTINQ00' USING WS-USUARIO WS-CTA-ORIGEN
                                  WS-CLIENTE-ORIGEN WS-RETCODE.
            MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-ORIGEN.
            MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-ORIGEN-DISP.
            MOVE 'CTA ORIGEN VALIDADA' TO WS-MENSAJE.
        3000-EXIT.
            EXIT.
       *
        4000-VALIDAR-DESTINO.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            IF WS-CTA-DESTINO = SPACES
                MOVE 'INGRESE CTA DESTINO' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-CTA-DESTINO = WS-CTA-ORIGEN
                MOVE 'CTA DESTINO DEBE SER DIFERENTE A ORIGEN'
                  TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE WS-CTA-DESTINO TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CTA DESTINO NO EXISTE' TO WS-MENSAJE-ERROR
                    GOTO 4000-EXIT
            END-READ.
       *
            IF NOT ACT-STATUS-ACTIVE
                MOVE 'CTA DESTINO NO ACTIVA' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            CALL 'ACTINQ00' USING WS-USUARIO WS-CTA-DESTINO
                                  WS-CLIENTE-DESTINO WS-RETCODE.
            MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-DESTINO.
            MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-DESTINO-DISP.
            MOVE 'CTA DESTINO VALIDADA' TO WS-MENSAJE.
        4000-EXIT.
            EXIT.
       *
        5000-VALIDAR-TRF.
            MOVE 'N' TO WS-SWITCH-ERROR.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            MOVE WS-MONTO-DISPLAY TO WS-MONTO.
       *
            IF WS-CTA-ORIGEN = SPACES
                MOVE 'VALIDE CTA ORIGEN' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            IF WS-CTA-DESTINO = SPACES
                MOVE 'VALIDE CTA DESTINO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            IF WS-MONTO = ZERO OR WS-MONTO < ZERO
                MOVE 'MONTO INVALIDO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            IF WS-MONTO > WS-BALANCE-ORIGEN
                MOVE 'SALDOS INSUFICIENTES EN ORIGEN'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 5000-EXIT
            END-IF.
        5000-EXIT.
            EXIT.
       *
        6000-CONFIRMAR.
            CALL 'COMMSGF' USING 'Q001'
                                 'CONFIRMAR TRANSFERENCIA?'
                                 'Q'
                                 WS-CONFIRMA.
       *
        7000-PROCESAR-TRF.
            MOVE WS-CTA-ORIGEN TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'ERROR LEYENDO ORIGEN' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7000-EXIT
            END-READ.
            SUBTRACT WS-MONTO FROM ACT-BALANCE.
            SUBTRACT WS-MONTO FROM ACT-BALANCE-DISPONIBLE.
            MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
            ADD 1 TO ACT-TXN-COUNT-TODAY.
            MOVE WS-USUARIO TO ACT-USER-LAST-MOD.
            REWRITE ACCOUNT-RECORD
                INVALID KEY
                    MOVE 'ERROR ACT ORIGEN' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7000-EXIT
            END-REWRITE.
       *
            MOVE WS-CTA-DESTINO TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'ERROR LEYENDO DESTINO' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7000-EXIT
            END-READ.
            ADD WS-MONTO TO ACT-BALANCE.
            ADD WS-MONTO TO ACT-BALANCE-DISPONIBLE.
            MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
            ADD 1 TO ACT-TXN-COUNT-TODAY.
            MOVE WS-USUARIO TO ACT-USER-LAST-MOD.
            REWRITE ACCOUNT-RECORD
                INVALID KEY
                    MOVE 'ERROR ACT DESTINO' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7000-EXIT
            END-REWRITE.
       *
            PERFORM 7100-TRANLOG.
            PERFORM 7200-TELLEREC.
            MOVE 00 TO LS-RETCODE.
       *
        7000-EXIT.
            EXIT.
       *
        7100-TRANLOG.
            MOVE WS-TRN-SEQ TO TRN-SEQ.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'TRF' TO TRN-TYPE.
            MOVE WS-CTA-ORIGEN TO TRN-ACCOUNT-NBR.
            MOVE WS-CTA-DESTINO TO TRN-ACCOUNT-DEST.
            MOVE WS-CLIENTE-ORIGEN TO TRN-CUSTOMER-ID.
            MOVE WS-MONTO TO TRN-AMOUNT.
            MOVE ZERO TO TRN-AMOUNT-TAX.
            MOVE WS-MONTO TO TRN-AMOUNT-TOTAL.
            MOVE WS-MONTO TO TRN-AMOUNT-ORIGINAL.
            MOVE ZERO TO TRN-FEE-AMOUNT.
            MOVE SPACES TO TRN-FEE-CODE.
            MOVE WS-SUCURSAL-ID TO TRN-BRANCH.
            MOVE WS-USUARIO TO TRN-TELLER-ID TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '01' TO TRN-CHANNEL.
            MOVE 'TRANSFERENCIA' TO TRN-REFERENCE.
            MOVE ZERO TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE ZERO TO TRN-REVERSE-SEQ.
            STRING 'TRF ' WS-MONTO ' DE ' WS-CTA-ORIGEN
                   ' A ' WS-CTA-DESTINO INTO TRN-DESCRIPTION.
            WRITE TRANLOG-RECORD
                INVALID KEY
                    MOVE 'ERROR TRANLOG' TO WS-MENSAJE-ERROR
            END-WRITE.
            ADD 1 TO WS-TRN-SEQ.
       *
        7200-TELLEREC.
            MOVE WS-USUARIO TO TLR-ID.
            MOVE WS-FECHA TO TLR-DATE.
            READ TELLEREC-FILE KEY IS TLR-ID
                INVALID KEY GOTO 7200-EXIT
            END-READ.
            ADD WS-MONTO TO TLR-TOTAL-TRANSFERENCIAS.
            ADD 1 TO TLR-COUNT-TRANSFERENCIAS.
            ADD 1 TO TLR-COUNT-TOTAL.
            REWRITE TELLEREC-RECORD
                INVALID KEY
                    MOVE 'ERROR ACT CAJA' TO WS-MENSAJE-ERROR
            END-REWRITE.
        7200-EXIT.
            EXIT.
       *
        8000-RESULTADO.
            MOVE 'TRANSFERENCIA EXITOSA' TO WS-MENSAJE.
            STRING 'TRF ' WS-CTA-ORIGEN ' -> ' WS-CTA-DESTINO
                   ' MONTO: ' WS-MONTO INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
            PERFORM 2100-LIMPIAR-PANTALLA.
            DISPLAY SCR-TRF.
            MOVE 'PRESIONE ENTER...' TO WS-MENSAJE.
            DISPLAY SCR-TRF.
            ACCEPT SCR-TRF.
       *
        9000-FINALIZAR.
            CLOSE ACCOUNT-FILE TRANLOG-FILE TELLEREC-FILE.
            GOBACK.
       *
        END PROGRAM TLRTRF00.
