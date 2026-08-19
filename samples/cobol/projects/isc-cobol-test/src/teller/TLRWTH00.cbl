       *================================================================*
       * TLRWTH00 - RETIRO EN EFECTIVO                                 *
       * PROPOSITO: RETIRAR EFECTIVO DE CUENTA, ACTUALIZAR SALDOS      *
       * EQUIPO: VENTANILLA - 2002                                     *
       * ARCHIVOS: ACCOUNT, TRANLOG, TELLEREC                          *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. TLRWTH00.
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
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-ENTER              VALUE 0013.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-ACCOUNT-NBR             PIC X(10).
            05  WS-MONTO                   PIC S9(13)V99 COMP-3.
            05  WS-MONTO-DISPLAY           PIC Z(12)9.99.
            05  WS-BALANCE-DISPONIBLE      PIC S9(13)V99 COMP-3.
            05  WS-BALANCE-DISP            PIC Z(12)9.99.
            05  WS-NEW-BALANCE             PIC S9(13)V99 COMP-3.
            05  WS-NEW-BALANCE-DISP        PIC Z(12)9.99.
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-TRN-SEQ                 PIC 9(10).
            05  WS-CUSTOMER-ID             PIC X(10).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'TLRWTH00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-RETIRO.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - RETIRO EN EFECTIVO'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' CAJERO: '.
                10  LINE 02  COL 10  PIC X(08) FROM WS-USUARIO.
       *
            05  SCR-CUERPO.
                10  LINE 04  COL 05  PIC X(20) VALUE 'CUENTA:'.
                10  LINE 04  COL 15  PIC X(10)
                   USING WS-ACCOUNT-NBR AUTO PROMPT '__________'.
                10  LINE 04  COL 30  PIC X(10) VALUE 'PF1=VALIDAR'.
       *
                10  LINE 06  COL 05  PIC X(20) VALUE 'CLIENTE:'.
                10  LINE 06  COL 15  PIC X(10) FROM WS-CUSTOMER-ID.
                10  LINE 07  COL 05  PIC X(20) VALUE 'SALDO DISP:'.
                10  LINE 07  COL 18  PIC Z(12)9.99 FROM WS-BALANCE-DISP.
       *
                10  LINE 09  COL 05  PIC X(20) VALUE 'MONTO RETIRO:'.
                10  LINE 09  COL 20  PIC Z(12)9.99
                   USING WS-MONTO-DISPLAY AUTO PROMPT '____________.__'.
       *
                10  LINE 11  COL 05  PIC X(20) VALUE 'NUEVO SALDO:'.
                10  LINE 11  COL 20  PIC Z(12)9.99 FROM WS-NEW-BALANCE-DISP.
       *
            05  SCR-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'ENTER=PROCESAR RETIRO  PF1=VALIDAR  PF12=SALIR'.
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
            MOVE SPACES TO WS-USUARIO
                           WS-MENSAJE
                           WS-MENSAJE-ERROR.
            MOVE LS-USUARIO TO WS-USUARIO.
            MOVE 99 TO LS-RETCODE.
       *
            PERFORM 1000-INICIALIZAR.
       *
        RETIRO-LOOP.
            PERFORM 2000-MOSTRAR-PANTALLA.
            ACCEPT SCR-RETIRO.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    PERFORM 3000-VALIDAR-CUENTA
                    GO TO RETIRO-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 'RETIRO CANCELADO' TO WS-MENSAJE
                    GOTO MAIN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    PERFORM 1100-LIMPIAR-CAMPOS
                    GO TO RETIRO-LOOP
       *
                WHEN WS-CRT-ENTER
                    PERFORM 4000-VALIDAR-DATOS
                    IF WS-ERROR-NO
                        PERFORM 5000-PROCESAR-RETIRO
                        IF WS-RETCODE = 00
                            PERFORM 6000-MOSTRAR-RESULTADO
                            MOVE 00 TO LS-RETCODE
                            GOTO MAIN-EXIT
                        END-IF
                    END-IF
                    GO TO RETIRO-LOOP
       *
                WHEN OTHER
                    MOVE 'INGRESE CUENTA Y MONTO DEL RETIRO'
                      TO WS-MENSAJE-ERROR
                    GO TO RETIRO-LOOP
            END-EVALUATE.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            PERFORM 1100-LIMPIAR-CAMPOS.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE CUENTA Y MONTO A RETIRAR' TO WS-MENSAJE.
            OPEN I-O ACCOUNT-FILE.
            OPEN I-O TRANLOG-FILE.
            OPEN I-O TELLEREC-FILE.
       *
        1100-LIMPIAR-CAMPOS.
            MOVE SPACES TO WS-ACCOUNT-NBR
                           WS-CUSTOMER-ID
                           WS-MENSAJE
                           WS-MENSAJE-ERROR.
            MOVE ZERO TO WS-MONTO
                         WS-MONTO-DISPLAY
                         WS-BALANCE-DISP
                         WS-NEW-BALANCE
                         WS-NEW-BALANCE-DISP.
       *
        2000-MOSTRAR-PANTALLA.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE WS-MONTO TO WS-MONTO-DISPLAY.
            MOVE WS-NEW-BALANCE TO WS-NEW-BALANCE-DISP.
            DISPLAY SCR-RETIRO.
       *
        2100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        3000-VALIDAR-CUENTA.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            IF WS-ACCOUNT-NBR = SPACES OR LOW-VALUES
                MOVE 'INGRESE NUMERO DE CUENTA' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE WS-ACCOUNT-NBR TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CUENTA NO ENCONTRADA' TO WS-MENSAJE-ERROR
                    MOVE SPACES TO WS-CUSTOMER-ID
                    MOVE ZERO TO WS-BALANCE-DISP
                    GOTO 3000-EXIT
            END-READ.
       *
            IF NOT ACT-STATUS-ACTIVE
                MOVE 'CUENTA NO ACTIVA' TO WS-MENSAJE-ERROR
                MOVE ZERO TO WS-BALANCE-DISP
                GOTO 3000-EXIT
            END-IF.
       *
            CALL 'ACTINQ00' USING WS-USUARIO
                                  WS-ACCOUNT-NBR
                                  WS-CUSTOMER-ID
                                  WS-RETCODE.
       *
            MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-DISPONIBLE.
            MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-DISP.
            MOVE 'CUENTA VALIDADA' TO WS-MENSAJE.
       *
        3000-EXIT.
            EXIT.
       *
        4000-VALIDAR-DATOS.
            MOVE 'N' TO WS-SWITCH-ERROR.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            MOVE WS-MONTO-DISPLAY TO WS-MONTO.
       *
            IF WS-ACCOUNT-NBR = SPACES
                MOVE 'INGRESE NUMERO DE CUENTA' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-MONTO = ZERO OR WS-MONTO < ZERO
                MOVE 'MONTO INVALIDO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-MONTO > WS-BALANCE-DISPONIBLE
                MOVE 'SALDOS INSUFICIENTES - FONDOS DISPONIBLES: '
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
        4000-EXIT.
            EXIT.
       *
        5000-PROCESAR-RETIRO.
            MOVE WS-ACCOUNT-NBR TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CUENTA NO ENCONTRADA' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 5000-EXIT
            END-READ.
       *
            SUBTRACT WS-MONTO FROM ACT-BALANCE.
            SUBTRACT WS-MONTO FROM ACT-BALANCE-DISPONIBLE.
            MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
            ADD 1 TO ACT-TXN-COUNT-TODAY.
            ADD 1 TO ACT-TXN-COUNT-MONTH.
            MOVE WS-USUARIO TO ACT-USER-LAST-MOD.
       *
            REWRITE ACCOUNT-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ACTUALIZAR CUENTA'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 5000-EXIT
            END-REWRITE.
       *
            PERFORM 5100-GENERAR-TRANLOG.
            PERFORM 5200-ACTUALIZAR-TELLEREC.
            MOVE 00 TO LS-RETCODE.
            MOVE ACT-BALANCE TO WS-NEW-BALANCE.
            MOVE ACT-BALANCE TO WS-NEW-BALANCE-DISP.
       *
        5000-EXIT.
            EXIT.
       *
        5100-GENERAR-TRANLOG.
            MOVE WS-TRN-SEQ TO TRN-SEQ.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'RET' TO TRN-TYPE.
            MOVE WS-ACCOUNT-NBR TO TRN-ACCOUNT-NBR.
            MOVE SPACES TO TRN-ACCOUNT-DEST.
            MOVE WS-CUSTOMER-ID TO TRN-CUSTOMER-ID.
            MOVE WS-MONTO TO TRN-AMOUNT.
            MOVE ZERO TO TRN-AMOUNT-TAX.
            MOVE WS-MONTO TO TRN-AMOUNT-TOTAL.
            MOVE WS-MONTO TO TRN-AMOUNT-ORIGINAL.
            MOVE ZERO TO TRN-FEE-AMOUNT.
            MOVE SPACES TO TRN-FEE-CODE.
            MOVE WS-SUCURSAL-ID TO TRN-BRANCH.
            MOVE WS-USUARIO TO TRN-TELLER-ID.
            MOVE WS-USUARIO TO TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '01' TO TRN-CHANNEL.
            MOVE SPACES TO TRN-REFERENCE.
            MOVE ZERO TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE ZERO TO TRN-REVERSE-SEQ.
            STRING 'RETIRO ' WS-MONTO ' CTA ' WS-ACCOUNT-NBR
              INTO TRN-DESCRIPTION.
       *
            WRITE TRANLOG-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ESCRIBIR TRANLOG'
                      TO WS-MENSAJE-ERROR
            END-WRITE.
            ADD 1 TO WS-TRN-SEQ.
       *
        5200-ACTUALIZAR-TELLEREC.
            MOVE WS-USUARIO TO TLR-ID.
            MOVE WS-FECHA TO TLR-DATE.
            READ TELLEREC-FILE KEY IS TLR-ID
                INVALID KEY
                    MOVE 'TELLEREC NO ENCONTRADO' TO WS-MENSAJE-ERROR
                    GOTO 5200-EXIT
            END-READ.
       *
            ADD WS-MONTO TO TLR-TOTAL-RETIROS.
            ADD 1 TO TLR-COUNT-RETIROS.
            ADD 1 TO TLR-COUNT-TOTAL.
            SUBTRACT WS-MONTO FROM TLR-FONDO-ACTUAL.
       *
            REWRITE TELLEREC-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ACTUALIZAR CAJA' TO WS-MENSAJE-ERROR
            END-REWRITE.
       *
        5200-EXIT.
            EXIT.
       *
        6000-MOSTRAR-RESULTADO.
            MOVE 'RETIRO EXITOSO' TO WS-MENSAJE.
            STRING 'RET ' WS-ACCOUNT-NBR ' MONTO: ' WS-MONTO
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
            PERFORM 2100-LIMPIAR.
            DISPLAY SCR-RETIRO.
            MOVE 'PRESIONE ENTER...' TO WS-MENSAJE.
            DISPLAY SCR-RETIRO.
            ACCEPT SCR-RETIRO.
       *
        9000-FINALIZAR.
            CLOSE ACCOUNT-FILE.
            CLOSE TRANLOG-FILE.
            CLOSE TELLEREC-FILE.
            GOBACK.
       *
        END PROGRAM TLRWTH00.
