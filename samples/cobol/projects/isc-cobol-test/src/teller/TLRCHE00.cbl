       *================================================================*
       * TLRCHE00 - COBRO DE CHEQUE                                    *
       * PROPOSITO: COBRAR CHEQUE PROPIO O DE TERCEROS                 *
       * EQUIPO: VENTANILLA - 2003                                     *
       * ARCHIVOS: ACCOUNT, CHQBOOK, TRANLOG, TELLEREC                 *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. TLRCHE00.
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
            SELECT CHQBOOK-FILE
                ASSIGN TO 'CHQBOOK.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS CHQ-NBR
                FILE STATUS IS FL-CHQBOOK-STATUS.
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
        FD  CHQBOOK-FILE
            RECORD 100 CHARACTERS.
        COPY FD-CHQBOOK REPLACING CHQBOOK-FILE BY CHQBOOK-FILE
                CHQBOOK-RECORD BY CHQBOOK-RECORD.
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
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-ENTER              VALUE 0013.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-CHQ-NBR                 PIC 9(10).
            05  WS-CHQ-NBR-DISP            PIC 9(10).
            05  WS-CHQ-BANK                PIC X(10).
            05  WS-CHQ-ACCOUNT             PIC X(10).
            05  WS-CHQ-BENEFICIARIO        PIC X(40).
            05  WS-CHQ-MONTO               PIC S9(13)V99 COMP-3.
            05  WS-CHQ-MONTO-DISP          PIC Z(12)9.99.
            05  WS-ES-PROPIO               PIC X(01).
                88  WS-CHEQUE-PROPIO       VALUE 'S'.
                88  WS-CHEQUE-TERCERO      VALUE 'N'.
            05  WS-ACCOUNT-NBR             PIC X(10).
            05  WS-CUSTOMER-ID             PIC X(10).
            05  WS-BALANCE-DISP            PIC S9(13)V99 COMP-3.
            05  WS-BALANCE-DISP-DISPLAY    PIC Z(12)9.99.
            05  WS-STOP-PAGO               PIC X(01).
                88  WS-CHEQUE-STOP         VALUE 'S'.
                88  WS-CHEQUE-NO-STOP      VALUE 'N'.
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-TRN-SEQ                 PIC 9(10).
            05  WS-CONFIRMA                PIC X(01).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'TLRCHE00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-CHEQUE.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - COBRO DE CHEQUE'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' CAJERO: '.
                10  LINE 02  COL 10  PIC X(08) FROM WS-USUARIO.
       *
            05  SCR-CUERPO.
                10  LINE 04  COL 05  PIC X(20) VALUE 'NUMERO CHEQUE:'.
                10  LINE 04  COL 22  PIC 9(10)
                   USING WS-CHQ-NBR-DISP AUTO PROMPT '__________'.
       *
                10  LINE 06  COL 05  PIC X(20) VALUE 'BANCO EMISOR:'.
                10  LINE 06  COL 20  PIC X(10)
                   USING WS-CHQ-BANK AUTO PROMPT '__________'.
       *
                10  LINE 07  COL 05  PIC X(20) VALUE 'CTA CHEQUE:'.
                10  LINE 07  COL 20  PIC X(10)
                   USING WS-CHQ-ACCOUNT AUTO PROMPT '__________'.
       *
                10  LINE 08  COL 05  PIC X(20) VALUE 'BENEFICIARIO:'.
                10  LINE 08  COL 20  PIC X(40)
                   USING WS-CHQ-BENEFICIARIO AUTO PROMPT
                   '.......................................'.
       *
                10  LINE 10  COL 05  PIC X(20) VALUE 'MONTO:'.
                10  LINE 10  COL 15  PIC Z(12)9.99
                   USING WS-CHQ-MONTO-DISP AUTO PROMPT '____________.__'.
       *
                10  LINE 12  COL 05  PIC X(20) VALUE 'ES PROPIO? (S/N):'.
                10  LINE 12  COL 25  PIC X(01)
                   USING WS-ES-PROPIO AUTO PROMPT '_'.
       *
                10  LINE 14  COL 05  PIC X(20) VALUE 'CTA DEBITO:'.
                10  LINE 14  COL 20  PIC X(10)
                   USING WS-ACCOUNT-NBR AUTO PROMPT '__________'.
                10  LINE 15  COL 05  PIC X(20) VALUE 'SALDO DISP:'.
                10  LINE 15  COL 20  PIC Z(12)9.99
                   FROM WS-BALANCE-DISP-DISPLAY.
       *
            05  SCR-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'ENTER=PROCESAR  PF12=SALIR'.
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
        CHEQUE-LOOP.
            PERFORM 2000-MOSTRAR.
            ACCEPT SCR-CHEQUE.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF12
                    MOVE 'COBRO CANCELADO' TO WS-MENSAJE
                    GOTO MAIN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    PERFORM 1100-LIMPIAR
                    GO TO CHEQUE-LOOP
       *
                WHEN WS-CRT-ENTER
                    PERFORM 3000-VALIDAR-DATOS
                    IF WS-ERROR-NO
                        PERFORM 4000-VERIFICAR-STOP
                        IF WS-CHEQUE-NO-STOP
                            PERFORM 5000-CONFIRMAR
                            IF WS-CONFIRMA = 'S'
                                PERFORM 6000-PROCESAR-CHEQUE
                                IF WS-RETCODE = 00
                                    PERFORM 7000-RESULTADO
                                    MOVE 00 TO LS-RETCODE
                                    GOTO MAIN-EXIT
                                END-IF
                            END-IF
                        ELSE
                            MOVE 'CHEQUE CON STOP PAYMENT'
                              TO WS-MENSAJE-ERROR
                        END-IF
                    END-IF
                    GO TO CHEQUE-LOOP
       *
                WHEN OTHER
                    MOVE 'INGRESE DATOS DEL CHEQUE' TO WS-MENSAJE-ERROR
                    GO TO CHEQUE-LOOP
            END-EVALUATE.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'COBRO DE CHEQUE - INGRESE DATOS' TO WS-MENSAJE.
            OPEN I-O ACCOUNT-FILE CHQBOOK-FILE TRANLOG-FILE
                 TELLEREC-FILE.
       *
        1100-LIMPIAR.
            MOVE SPACES TO WS-CHQ-BANK WS-CHQ-ACCOUNT
                           WS-CHQ-BENEFICIARIO WS-ACCOUNT-NBR
                           WS-CUSTOMER-ID WS-MENSAJE WS-MENSAJE-ERROR
                           WS-ES-PROPIO.
            MOVE ZERO TO WS-CHQ-NBR WS-CHQ-NBR-DISP
                         WS-CHQ-MONTO WS-CHQ-MONTO-DISP
                         WS-BALANCE-DISP WS-BALANCE-DISP-DISPLAY.
       *
        2000-MOSTRAR.
            PERFORM 2100-LIMPIAR-PANTALLA.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE WS-CHQ-MONTO TO WS-CHQ-MONTO-DISP.
            DISPLAY SCR-CHEQUE.
       *
        2100-LIMPIAR-PANTALLA.
            DISPLAY SPACES UPON CRT.
       *
        3000-VALIDAR-DATOS.
            MOVE 'N' TO WS-SWITCH-ERROR.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            MOVE WS-CHQ-NBR-DISP TO WS-CHQ-NBR.
            MOVE WS-CHQ-MONTO-DISP TO WS-CHQ-MONTO.
       *
            IF WS-CHQ-NBR = ZERO
                MOVE 'INGRESE NUM CHEQUE' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-CHQ-MONTO = ZERO OR WS-CHQ-MONTO < ZERO
                MOVE 'MONTO INVALIDO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-CHEQUE-PROPIO
                IF WS-ACCOUNT-NBR = SPACES
                    MOVE 'INGRESE CTA DEBITO' TO WS-MENSAJE-ERROR
                    MOVE 'Y' TO WS-SWITCH-ERROR
                    GOTO 3000-EXIT
                END-IF
                MOVE WS-ACCOUNT-NBR TO ACT-NBR
                READ ACCOUNT-FILE KEY IS ACT-NBR
                    INVALID KEY
                        MOVE 'CTA NO EXISTE' TO WS-MENSAJE-ERROR
                        MOVE 'Y' TO WS-SWITCH-ERROR
                        GOTO 3000-EXIT
                END-READ
                IF NOT ACT-STATUS-ACTIVE
                    MOVE 'CTA NO ACTIVA' TO WS-MENSAJE-ERROR
                    MOVE 'Y' TO WS-SWITCH-ERROR
                    GOTO 3000-EXIT
                END-IF
                MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-DISP
                MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-DISP-DISPLAY
                IF WS-CHQ-MONTO > ACT-BALANCE-DISPONIBLE
                    MOVE 'SALDOS INSUFICIENTES' TO WS-MENSAJE-ERROR
                    MOVE 'Y' TO WS-SWITCH-ERROR
                    GOTO 3000-EXIT
                END-IF
            END-IF.
       *
        3000-EXIT.
            EXIT.
       *
        4000-VERIFICAR-STOP.
            MOVE 'N' TO WS-CHEQUE-STOP.
            IF WS-CHEQUE-PROPIO
                MOVE WS-CHQ-NBR TO CHQ-NBR
                READ CHQBOOK-FILE KEY IS CHQ-NBR
                    INVALID KEY
                        MOVE 'N' TO WS-CHEQUE-STOP
                        GOTO 4000-EXIT
                END-READ
                MOVE 'N' TO WS-CHEQUE-STOP
            END-IF.
        4000-EXIT.
            EXIT.
       *
        5000-CONFIRMAR.
            CALL 'COMMSGF' USING 'Q001'
                                 'CONFIRMA COBRO CHEQUE?'
                                 'Q'
                                 WS-CONFIRMA.
       *
        6000-PROCESAR-CHEQUE.
            IF WS-CHEQUE-PROPIO
                MOVE WS-ACCOUNT-NBR TO ACT-NBR
                READ ACCOUNT-FILE KEY IS ACT-NBR
                    INVALID KEY
                        MOVE 'ERROR CTA' TO WS-MENSAJE-ERROR
                        MOVE 99 TO LS-RETCODE
                        GOTO 6000-EXIT
                END-READ
                SUBTRACT WS-CHQ-MONTO FROM ACT-BALANCE
                SUBTRACT WS-CHQ-MONTO FROM ACT-BALANCE-DISPONIBLE
                MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY
                ADD 1 TO ACT-TXN-COUNT-TODAY
                ADD 1 TO ACT-CHECKS-ISSUED
                MOVE WS-USUARIO TO ACT-USER-LAST-MOD
                REWRITE ACCOUNT-RECORD
                    INVALID KEY
                        MOVE 'ERROR ACT CTA' TO WS-MENSAJE-ERROR
                        MOVE 99 TO LS-RETCODE
                        GOTO 6000-EXIT
                END-REWRITE
            END-IF.
       *
            PERFORM 6100-TRANLOG.
            PERFORM 6200-TELLEREC.
            MOVE 00 TO LS-RETCODE.
       *
        6000-EXIT.
            EXIT.
       *
        6100-TRANLOG.
            MOVE WS-TRN-SEQ TO TRN-SEQ.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'CHQ' TO TRN-TYPE.
            MOVE WS-ACCOUNT-NBR TO TRN-ACCOUNT-NBR.
            MOVE SPACES TO TRN-ACCOUNT-DEST.
            MOVE WS-CUSTOMER-ID TO TRN-CUSTOMER-ID.
            MOVE WS-CHQ-MONTO TO TRN-AMOUNT.
            MOVE ZERO TO TRN-AMOUNT-TAX.
            MOVE WS-CHQ-MONTO TO TRN-AMOUNT-TOTAL.
            MOVE WS-CHQ-MONTO TO TRN-AMOUNT-ORIGINAL.
            MOVE ZERO TO TRN-FEE-AMOUNT.
            MOVE SPACES TO TRN-FEE-CODE.
            MOVE WS-SUCURSAL-ID TO TRN-BRANCH.
            MOVE WS-USUARIO TO TRN-TELLER-ID TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '01' TO TRN-CHANNEL.
            STRING 'CHQ ' WS-CHQ-NBR ' BCO ' WS-CHQ-BANK
              INTO TRN-REFERENCE.
            MOVE WS-CHQ-NBR TO TRN-CHQ-NBR.
            MOVE WS-CHQ-BANK TO TRN-CHQ-BANK.
            MOVE WS-CHQ-ACCOUNT TO TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE ZERO TO TRN-REVERSE-SEQ.
            STRING 'COBRO CHEQUE ' WS-CHQ-NBR ' $' WS-CHQ-MONTO
              INTO TRN-DESCRIPTION.
            WRITE TRANLOG-RECORD
                INVALID KEY
                    MOVE 'ERROR TRANLOG' TO WS-MENSAJE-ERROR
            END-WRITE.
            ADD 1 TO WS-TRN-SEQ.
       *
        6200-TELLEREC.
            MOVE WS-USUARIO TO TLR-ID.
            MOVE WS-FECHA TO TLR-DATE.
            READ TELLEREC-FILE KEY IS TLR-ID
                INVALID KEY GOTO 6200-EXIT
            END-READ.
            ADD WS-CHQ-MONTO TO TLR-TOTAL-CHEQUES.
            ADD 1 TO TLR-COUNT-CHEQUES.
            ADD 1 TO TLR-COUNT-TOTAL.
            SUBTRACT WS-CHQ-MONTO FROM TLR-FONDO-ACTUAL.
            REWRITE TELLEREC-RECORD
                INVALID KEY CONTINUE
            END-REWRITE.
        6200-EXIT.
            EXIT.
       *
        7000-RESULTADO.
            MOVE 'COBRO CHEQUE EXITOSO' TO WS-MENSAJE.
            STRING 'CHQ ' WS-CHQ-NBR ' CTA ' WS-ACCOUNT-NBR
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
            PERFORM 2100-LIMPIAR-PANTALLA.
            DISPLAY SCR-CHEQUE.
            MOVE 'PRESIONE ENTER...' TO WS-MENSAJE.
            DISPLAY SCR-CHEQUE.
            ACCEPT SCR-CHEQUE.
       *
        9000-FINALIZAR.
            CLOSE ACCOUNT-FILE CHQBOOK-FILE TRANLOG-FILE
                  TELLEREC-FILE.
            GOBACK.
       *
        END PROGRAM TLRCHE00.
