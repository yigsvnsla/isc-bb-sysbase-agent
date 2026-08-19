       *================================================================*
       * TLRDEP00 - DEPOSITO EN EFECTIVO / CHEQUE                      *
       * PROPOSITO: REGISTRAR DEPOSITO, ACTUALIZAR SALDO Y TRANLOG     *
       * EQUIPO: VENTANILLA - 2002                                     *
       * ARCHIVOS: ACCOUNT, TRANLOG, TELLEREC                          *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. TLRDEP00.
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
            88  WS-CRT-PF3                VALUE 1003.
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
            05  WS-BALANCE-DISPLAY         PIC Z(12)9.99.
            05  WS-NEW-BALANCE             PIC S9(13)V99 COMP-3.
            05  WS-NEW-BALANCE-DISP        PIC Z(12)9.99.
            05  WS-TIPO-DEPOSITO           PIC X(01).
                88  WS-DEP-EFECTIVO        VALUE 'E'.
                88  WS-DEP-CHEQUE          VALUE 'C'.
            05  WS-TIPO-DEP-DISPLAY        PIC X(10).
            05  WS-CHQ-NBR                 PIC 9(10).
            05  WS-CHQ-NBR-DISP            PIC 9(10).
            05  WS-CHQ-BANK                PIC X(10).
            05  WS-CHQ-ACCOUNT             PIC X(10).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-TRN-SEQ                 PIC 9(10).
            05  WS-TRN-SEQ-ACT             PIC 9(10).
            05  WS-CUSTOMER-ID             PIC X(10).
            05  WS-CONTADOR                PIC 9(02).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'TLRDEP00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-DEPOSITO.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - DEPOSITO EN CAJA'.
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
                10  LINE 07  COL 05  PIC X(20) VALUE 'SALDO ACTUAL:'.
                10  LINE 07  COL 20  PIC Z(12)9.99 FROM WS-BALANCE-DISPLAY.
       *
                10  LINE 09  COL 05  PIC X(20) VALUE 'MONTO:'.
                10  LINE 09  COL 15  PIC Z(12)9.99
                   USING WS-MONTO-DISPLAY AUTO PROMPT '____________.__'.
       *
                10  LINE 11  COL 05  PIC X(20) VALUE 'TIPO DEPOSITO:'.
                10  LINE 11  COL 20  PIC X(01)
                   USING WS-TIPO-DEP-DISPLAY AUTO PROMPT '_'.
                10  LINE 11  COL 25  PIC X(30)
                   VALUE '(E=FECTIVO / C=HEQUE)'.
       *
                10  LINE 13  COL 05  PIC X(20) VALUE 'CHEQUE NUM:'.
                10  LINE 13  COL 18  PIC 9(10)
                   USING WS-CHQ-NBR-DISP AUTO PROMPT '__________'.
                10  LINE 14  COL 05  PIC X(20) VALUE 'BANCO:'.
                10  LINE 14  COL 15  PIC X(10)
                   USING WS-CHQ-BANK AUTO PROMPT '__________'.
                10  LINE 15  COL 05  PIC X(20) VALUE 'CTA CHEQUE:'.
                10  LINE 15  COL 20  PIC X(10)
                   USING WS-CHQ-ACCOUNT AUTO PROMPT '__________'.
       *
                10  LINE 17  COL 05  PIC X(20) VALUE 'NUEVO SALDO:'.
                10  LINE 17  COL 20  PIC Z(12)9.99 FROM WS-NEW-BALANCE-DISP.
       *
            05  SCR-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'PF1=VALIDAR CTA  ENTER=PROCESAR  PF12=SALIR'.
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
        DEPOSITO-LOOP.
            PERFORM 2000-MOSTRAR-PANTALLA.
            ACCEPT SCR-DEPOSITO.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    PERFORM 3000-VALIDAR-CUENTA
                    GO TO DEPOSITO-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 'DEPOSITO CANCELADO' TO WS-MENSAJE
                    GOTO MAIN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    PERFORM 1100-LIMPIAR-CAMPOS
                    GO TO DEPOSITO-LOOP
       *
                WHEN WS-CRT-ENTER
                    PERFORM 4000-VALIDAR-DATOS
                    IF WS-ERROR-NO
                        PERFORM 5000-PROCESAR-DEPOSITO
                        IF WS-RETCODE = 00
                            PERFORM 6000-MOSTRAR-RESULTADO
                            MOVE 00 TO LS-RETCODE
                            GOTO MAIN-EXIT
                        END-IF
                    END-IF
                    GO TO DEPOSITO-LOOP
       *
                WHEN OTHER
                    MOVE 'INGRESE CUENTA Y PRESIONE PF1 PARA VALIDAR'
                      TO WS-MENSAJE-ERROR
                    GO TO DEPOSITO-LOOP
            END-EVALUATE.
       *
        MAIN-EXIT.
            EXIT.
       *
       *--- INICIALIZAR ---*
        1000-INICIALIZAR.
            PERFORM 1100-LIMPIAR-CAMPOS.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE CUENTA Y MONTO DEL DEPOSITO' TO WS-MENSAJE.
            OPEN I-O ACCOUNT-FILE.
            OPEN I-O TRANLOG-FILE.
            OPEN I-O TELLEREC-FILE.
       *
        1100-LIMPIAR-CAMPOS.
            MOVE SPACES TO WS-ACCOUNT-NBR
                           WS-CUSTOMER-ID
                           WS-MENSAJE
                           WS-MENSAJE-ERROR
                           WS-TIPO-DEP-DISPLAY
                           WS-CHQ-BANK
                           WS-CHQ-ACCOUNT.
            MOVE ZERO TO WS-MONTO
                         WS-MONTO-DISPLAY
                         WS-BALANCE-DISPLAY
                         WS-NEW-BALANCE
                         WS-NEW-BALANCE-DISP
                         WS-CHQ-NBR
                         WS-CHQ-NBR-DISP.
       *
       *--- MOSTRAR PANTALLA ---*
        2000-MOSTRAR-PANTALLA.
            PERFORM 2100-LIMPIAR-PANTALLA.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE WS-MONTO TO WS-MONTO-DISPLAY.
            MOVE WS-NEW-BALANCE TO WS-NEW-BALANCE-DISP.
            DISPLAY SCR-DEPOSITO.
       *
        2100-LIMPIAR-PANTALLA.
            DISPLAY SPACES UPON CRT.
       *
       *--- VALIDAR CUENTA ---*
        3000-VALIDAR-CUENTA.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
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
                    MOVE ZERO TO WS-BALANCE-DISPLAY
                    GOTO 3000-EXIT
            END-READ.
       *
            IF NOT ACT-STATUS-ACTIVE
                MOVE 'CUENTA NO ACTIVA - VERIFIQUE ESTATUS'
                  TO WS-MENSAJE-ERROR
                MOVE ZERO TO WS-BALANCE-DISPLAY
                GOTO 3000-EXIT
            END-IF.
       *
            CALL 'ACTINQ00' USING WS-USUARIO
                                  WS-ACCOUNT-NBR
                                  WS-CUSTOMER-ID
                                  WS-RETCODE.
       *
            MOVE ACT-BALANCE TO WS-BALANCE-DISPLAY.
            MOVE ACT-BALANCE TO WS-BALANCE.
            MOVE 'CUENTA VALIDADA CORRECTAMENTE' TO WS-MENSAJE.
       *
        3000-EXIT.
            EXIT.
       *
       *--- VALIDAR DATOS DE DEPOSITO ---*
        4000-VALIDAR-DATOS.
            MOVE 'N' TO WS-SWITCH-ERROR.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            MOVE WS-MONTO-DISPLAY TO WS-MONTO.
            MOVE WS-CHQ-NBR-DISP TO WS-CHQ-NBR.
            MOVE WS-TIPO-DEP-DISPLAY TO WS-TIPO-DEPOSITO.
       *
            IF WS-ACCOUNT-NBR = SPACES
                MOVE 'INGRESE NUMERO DE CUENTA' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-MONTO = ZERO OR WS-MONTO < ZERO
                MOVE 'MONTO DEBE SER MAYOR A CERO'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-DEP-EFECTIVO AND WS-DEP-CHEQUE
                MOVE 'TIPO DE DEPOSITO INVALIDO (E/C)'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-DEP-CHEQUE
                IF WS-CHQ-NBR = ZERO
                    MOVE 'INGRESE NUMERO DE CHEQUE'
                      TO WS-MENSAJE-ERROR
                    MOVE 'Y' TO WS-SWITCH-ERROR
                    GOTO 4000-EXIT
                END-IF
            END-IF.
       *
        4000-EXIT.
            EXIT.
       *
       *--- PROCESAR DEPOSITO ---*
        5000-PROCESAR-DEPOSITO.
            MOVE WS-ACCOUNT-NBR TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CUENTA NO ENCONTRADA EN PROCESO'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 5000-EXIT
            END-READ.
       *
            ADD WS-MONTO TO ACT-BALANCE.
            ADD WS-MONTO TO ACT-BALANCE-DISPONIBLE.
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
            IF FL-ACCOUNT-STATUS NOT = '00'
                MOVE 'ERROR DE ARCHIVO AL ACTUALIZAR CUENTA'
                  TO WS-MENSAJE-ERROR
                MOVE 99 TO LS-RETCODE
                GOTO 5000-EXIT
            END-IF.
       *
            PERFORM 5100-GENERAR-TRANLOG.
            PERFORM 5200-ACTUALIZAR-TELLEREC.
       *
            MOVE 00 TO LS-RETCODE.
            MOVE ACT-BALANCE TO WS-NEW-BALANCE.
            MOVE ACT-BALANCE TO WS-NEW-BALANCE-DISP.
       *
        5000-EXIT.
            EXIT.
       *
       *--- GENERAR REGISTRO TRANLOG ---*
        5100-GENERAR-TRANLOG.
            MOVE WS-TRN-SEQ TO TRN-SEQ.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'DEP' TO TRN-TYPE.
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
       *
            IF WS-DEP-EFECTIVO
                MOVE 'DEPOSITO EFECTIVO' TO TRN-REFERENCE
            ELSE
                MOVE 'DEPOSITO CHEQUE' TO TRN-REFERENCE
                MOVE WS-CHQ-NBR TO TRN-CHQ-NBR
                MOVE WS-CHQ-BANK TO TRN-CHQ-BANK
                MOVE WS-CHQ-ACCOUNT TO TRN-CHQ-ACCOUNT
            END-IF.
       *
            MOVE ZERO TO TRN-CHQ-NBR
                         TRN-CHQ-BANK
                         TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE ZERO TO TRN-REVERSE-SEQ.
            STRING 'DEP ' WS-MONTO ' CTA ' WS-ACCOUNT-NBR
              INTO TRN-DESCRIPTION.
       *
            WRITE TRANLOG-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ESCRIBIR TRANLOG'
                      TO WS-MENSAJE-ERROR
            END-WRITE.
       *
            ADD 1 TO WS-TRN-SEQ.
       *
       *--- ACTUALIZAR TELLEREC ---*
        5200-ACTUALIZAR-TELLEREC.
            MOVE WS-USUARIO TO TLR-ID.
            MOVE WS-FECHA TO TLR-DATE.
            READ TELLEREC-FILE KEY IS TLR-ID
                INVALID KEY
                    MOVE 'TELLEREC NO ENCONTRADO'
                      TO WS-MENSAJE-ERROR
                    GOTO 5200-EXIT
            END-READ.
       *
            ADD WS-MONTO TO TLR-TOTAL-DEPOSITOS.
            ADD 1 TO TLR-COUNT-DEPOSITOS.
            ADD 1 TO TLR-COUNT-TOTAL.
            ADD WS-MONTO TO TLR-FONDO-ACTUAL.
       *
            REWRITE TELLEREC-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ACTUALIZAR CAJA'
                      TO WS-MENSAJE-ERROR
            END-REWRITE.
       *
        5200-EXIT.
            EXIT.
       *
       *--- MOSTRAR RESULTADO ---*
        6000-MOSTRAR-RESULTADO.
            MOVE 'DEPOSITO REALIZADO EXITOSAMENTE' TO WS-MENSAJE.
            STRING 'DEP ' WS-ACCOUNT-NBR ' MONTO: ' WS-MONTO
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA
                                  WS-AUDIT-INFO.
            PERFORM 2100-LIMPIAR-PANTALLA.
            DISPLAY SCR-DEPOSITO.
            MOVE 'PRESIONE ENTER PARA CONTINUAR...' TO WS-MENSAJE.
            DISPLAY SCR-DEPOSITO.
            ACCEPT SCR-DEPOSITO.
       *
       *--- FINALIZAR ---*
        9000-FINALIZAR.
            CLOSE ACCOUNT-FILE.
            CLOSE TRANLOG-FILE.
            CLOSE TELLEREC-FILE.
            GOBACK.
       *
        END PROGRAM TLRDEP00.
