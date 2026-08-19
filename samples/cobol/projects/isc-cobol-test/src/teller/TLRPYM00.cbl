       *================================================================*
       * TLRPYM00 - PAGO DE SERVICIOS                                   *
       * PROPOSITO: PAGAR SERVICIOS (LUZ, AGUA, TELEFONO, IMPUESTOS)   *
       * EQUIPO: VENTANILLA - 2003                                     *
       * ARCHIVOS: ACCOUNT, TRANLOG, TELLEREC                          *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. TLRPYM00.
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
            05  WS-SERVICIO-TIPO           PIC X(02).
                88  WS-SERV-LUZ            VALUE 'LU'.
                88  WS-SERV-AGUA           VALUE 'AG'.
                88  WS-SERV-TELEFONO       VALUE 'TE'.
                88  WS-SERV-IMPUESTOS      VALUE 'IM'.
            05  WS-SERVICIO-TIPO-DISP      PIC X(02).
            05  WS-SERVICIO-DESC           PIC X(15).
            05  WS-REFERENCIA              PIC X(20).
            05  WS-MONTO                   PIC S9(13)V99 COMP-3.
            05  WS-MONTO-DISPLAY           PIC Z(12)9.99.
            05  WS-BALANCE-DISP            PIC S9(13)V99 COMP-3.
            05  WS-BALANCE-DISP-DISPLAY    PIC Z(12)9.99.
            05  WS-NEW-BALANCE             PIC S9(13)V99 COMP-3.
            05  WS-NEW-BALANCE-DISP        PIC Z(12)9.99.
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-CUSTOMER-ID             PIC X(10).
            05  WS-RETCODE                 PIC 99.
            05  WS-TRN-SEQ                 PIC 9(10).
            05  WS-CONFIRMA                PIC X(01).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'TLRPYM00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-PAGO.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - PAGO DE SERVICIOS'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' CAJERO: '.
                10  LINE 02  COL 10  PIC X(08) FROM WS-USUARIO.
       *
            05  SCR-CUERPO.
                10  LINE 04  COL 05  PIC X(20) VALUE 'CUENTA DEBITO:'.
                10  LINE 04  COL 20  PIC X(10)
                   USING WS-ACCOUNT-NBR AUTO PROMPT '__________'.
                10  LINE 04  COL 35  PIC X(10) VALUE 'PF1=VALIDAR'.
       *
                10  LINE 05  COL 05  PIC X(20) VALUE 'CLIENTE:'.
                10  LINE 05  COL 15  PIC X(10) FROM WS-CUSTOMER-ID.
                10  LINE 06  COL 05  PIC X(20) VALUE 'SALDO DISP:'.
                10  LINE 06  COL 20  PIC Z(12)9.99
                   FROM WS-BALANCE-DISP-DISPLAY.
       *
                10  LINE 08  COL 05  PIC X(20) VALUE 'SERVICIO:'.
                10  LINE 08  COL 15  PIC X(02)
                   USING WS-SERVICIO-TIPO-DISP AUTO PROMPT '__'.
                10  LINE 08  COL 20  PIC X(30)
                   VALUE '(LU=LUZ AG=AGUA TE=TEL IM=IMP)'.
       *
                10  LINE 10  COL 05  PIC X(20) VALUE 'REFERENCIA:'.
                10  LINE 10  COL 18  PIC X(20)
                   USING WS-REFERENCIA AUTO PROMPT '....................'.
       *
                10  LINE 12  COL 05  PIC X(20) VALUE 'MONTO:'.
                10  LINE 12  COL 15  PIC Z(12)9.99
                   USING WS-MONTO-DISPLAY AUTO PROMPT '____________.__'.
       *
                10  LINE 14  COL 05  PIC X(20) VALUE 'NUEVO SALDO:'.
                10  LINE 14  COL 20  PIC Z(12)9.99 FROM WS-NEW-BALANCE-DISP.
       *
            05  SCR-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'PF1=VALIDAR CTA  ENTER=PAGAR  PF12=SALIR'.
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
        PAGO-LOOP.
            PERFORM 2000-MOSTRAR.
            ACCEPT SCR-PAGO.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    PERFORM 3000-VALIDAR-CUENTA
                    GO TO PAGO-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 'PAGO CANCELADO' TO WS-MENSAJE
                    GOTO MAIN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    PERFORM 1100-LIMPIAR
                    GO TO PAGO-LOOP
       *
                WHEN WS-CRT-ENTER
                    PERFORM 4000-VALIDAR-DATOS
                    IF WS-ERROR-NO
                        PERFORM 5000-CONFIRMAR-PAGO
                        IF WS-CONFIRMA = 'S'
                            PERFORM 6000-PROCESAR-PAGO
                            IF WS-RETCODE = 00
                                PERFORM 7000-RESULTADO
                                MOVE 00 TO LS-RETCODE
                                GOTO MAIN-EXIT
                            END-IF
                        END-IF
                    END-IF
                    GO TO PAGO-LOOP
       *
                WHEN OTHER
                    MOVE 'INGRESE DATOS DEL PAGO' TO WS-MENSAJE-ERROR
                    GO TO PAGO-LOOP
            END-EVALUATE.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'PAGO DE SERVICIOS' TO WS-MENSAJE.
            OPEN I-O ACCOUNT-FILE TRANLOG-FILE TELLEREC-FILE.
       *
        1100-LIMPIAR.
            MOVE SPACES TO WS-ACCOUNT-NBR WS-CUSTOMER-ID
                           WS-MENSAJE WS-MENSAJE-ERROR
                           WS-SERVICIO-TIPO-DISP WS-REFERENCIA.
            MOVE ZERO TO WS-MONTO WS-MONTO-DISPLAY
                         WS-BALANCE-DISP WS-BALANCE-DISP-DISPLAY
                         WS-NEW-BALANCE WS-NEW-BALANCE-DISP.
       *
        2000-MOSTRAR.
            PERFORM 2100-LIMPIAR-PANTALLA.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE WS-MONTO TO WS-MONTO-DISPLAY.
            MOVE WS-NEW-BALANCE TO WS-NEW-BALANCE-DISP.
            DISPLAY SCR-PAGO.
       *
        2100-LIMPIAR-PANTALLA.
            DISPLAY SPACES UPON CRT.
       *
        3000-VALIDAR-CUENTA.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            IF WS-ACCOUNT-NBR = SPACES
                MOVE 'INGRESE CUENTA' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
            MOVE WS-ACCOUNT-NBR TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CUENTA NO EXISTE' TO WS-MENSAJE-ERROR
                    GOTO 3000-EXIT
            END-READ.
            IF NOT ACT-STATUS-ACTIVE
                MOVE 'CUENTA NO ACTIVA' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
            CALL 'ACTINQ00' USING WS-USUARIO WS-ACCOUNT-NBR
                                  WS-CUSTOMER-ID WS-RETCODE.
            MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-DISP.
            MOVE ACT-BALANCE-DISPONIBLE TO WS-BALANCE-DISP-DISPLAY.
            MOVE 'CUENTA VALIDADA' TO WS-MENSAJE.
        3000-EXIT.
            EXIT.
       *
        4000-VALIDAR-DATOS.
            MOVE 'N' TO WS-SWITCH-ERROR.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            MOVE WS-MONTO-DISPLAY TO WS-MONTO.
            MOVE WS-SERVICIO-TIPO-DISP TO WS-SERVICIO-TIPO.
       *
            IF WS-ACCOUNT-NBR = SPACES
                MOVE 'VALIDE CUENTA PRIMERO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-SERVICIO-TIPO = SPACES
                MOVE 'SELECCIONE TIPO SERVICIO' TO WS-MENSAJE-ERROR
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
            IF WS-MONTO > WS-BALANCE-DISP
                MOVE 'SALDOS INSUFICIENTES' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            EVALUATE WS-SERVICIO-TIPO
                WHEN 'LU' MOVE 'LUZ' TO WS-SERVICIO-DESC
                WHEN 'AG' MOVE 'AGUA' TO WS-SERVICIO-DESC
                WHEN 'TE' MOVE 'TELEFONO' TO WS-SERVICIO-DESC
                WHEN 'IM' MOVE 'IMPUESTOS' TO WS-SERVICIO-DESC
                WHEN OTHER
                    MOVE 'TIPO SERVICIO INVALIDO' TO WS-MENSAJE-ERROR
                    MOVE 'Y' TO WS-SWITCH-ERROR
                    GOTO 4000-EXIT
            END-EVALUATE.
       *
        4000-EXIT.
            EXIT.
       *
        5000-CONFIRMAR-PAGO.
            CALL 'COMMSGF' USING 'Q001'
                                 'CONFIRMA PAGO DE SERVICIO?'
                                 'Q'
                                 WS-CONFIRMA.
       *
        6000-PROCESAR-PAGO.
            MOVE WS-ACCOUNT-NBR TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'ERROR CTA' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 6000-EXIT
            END-READ.
       *
            SUBTRACT WS-MONTO FROM ACT-BALANCE.
            SUBTRACT WS-MONTO FROM ACT-BALANCE-DISPONIBLE.
            MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
            ADD 1 TO ACT-TXN-COUNT-TODAY.
            MOVE WS-USUARIO TO ACT-USER-LAST-MOD.
            REWRITE ACCOUNT-RECORD
                INVALID KEY
                    MOVE 'ERROR ACT CTA' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 6000-EXIT
            END-REWRITE.
       *
            PERFORM 6100-TRANLOG.
            PERFORM 6200-TELLEREC.
            MOVE ACT-BALANCE TO WS-NEW-BALANCE.
            MOVE ACT-BALANCE TO WS-NEW-BALANCE-DISP.
            MOVE 00 TO LS-RETCODE.
       *
        6000-EXIT.
            EXIT.
       *
        6100-TRANLOG.
            MOVE WS-TRN-SEQ TO TRN-SEQ.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'PAG' TO TRN-TYPE.
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
            MOVE WS-USUARIO TO TRN-TELLER-ID TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '01' TO TRN-CHANNEL.
            MOVE WS-REFERENCIA TO TRN-REFERENCE.
            MOVE ZERO TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE ZERO TO TRN-REVERSE-SEQ.
            STRING 'PAGO ' WS-SERVICIO-DESC ' REF ' WS-REFERENCIA
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
            ADD WS-MONTO TO TLR-TOTAL-PAGOS.
            ADD 1 TO TLR-COUNT-PAGOS.
            ADD 1 TO TLR-COUNT-TOTAL.
            REWRITE TELLEREC-RECORD
                INVALID KEY CONTINUE
            END-REWRITE.
        6200-EXIT.
            EXIT.
       *
        7000-RESULTADO.
            MOVE 'PAGO EXITOSO' TO WS-MENSAJE.
            STRING 'PAG ' WS-SERVICIO-DESC ' CTA ' WS-ACCOUNT-NBR
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
            PERFORM 2100-LIMPIAR-PANTALLA.
            DISPLAY SCR-PAGO.
            MOVE 'PRESIONE ENTER...' TO WS-MENSAJE.
            DISPLAY SCR-PAGO.
            ACCEPT SCR-PAGO.
       *
        9000-FINALIZAR.
            CLOSE ACCOUNT-FILE TRANLOG-FILE TELLEREC-FILE.
            GOBACK.
       *
        END PROGRAM TLRPYM00.
