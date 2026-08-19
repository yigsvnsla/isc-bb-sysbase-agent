       *================================================================*
       * LONPYM00 - PAGO DE CUOTA DE PRESTAMO                          *
       * PROPOSITO: APLICAR PAGO A CUOTAS, ACTUALIZAR SALDOS           *
       * EQUIPO: CREDITO Y COBRANZA - 2004                             *
       * ARCHIVOS: LOANMAST, ACCOUNT, TRANLOG                          *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. LONPYM00.
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
            88  WS-CRT-PF7                VALUE 1007.
            88  WS-CRT-PF8                VALUE 1008.
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-ENTER              VALUE 0013.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-LOAN-NBR                PIC X(10).
            05  WS-CUSTOMER-ID             PIC X(10).
            05  WS-MONTO-PAGO              PIC 9(09)V99 COMP-3.
            05  WS-MONTO-PAGO-DISP         PIC Z(08)9.99.
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-TRN-SEQ                 PIC 9(10).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-I                       PIC 9(04).
            05  WS-J                       PIC 9(04).
            05  WS-K                       PIC 9(04).
            05  WS-PAGO-APLICADO           PIC 9(09)V99 COMP-3.
            05  WS-INST-A-PAGAR            PIC 9(04).
            05  WS-BALANCE-ACT             PIC 9(13)V99 COMP-3.
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'LONPYM00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-BUSQUEDA.
            05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - PAGO DE PRESTAMO'.
            05  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
            05  LINE 02  COL 01  PIC X(80)
               VALUE ' INGRESE NUMERO DE PRESTAMO:'.
            05  LINE 02  COL 32  PIC X(10)
               USING WS-LOAN-NBR AUTO PROMPT '__________'.
            05  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
            05  LINE 24  COL 05  PIC X(60)
               VALUE 'ENTER=CONSULTAR  PF12=SALIR'.
       *
        01  SCR-PAGO.
            05  SCR-CAB.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - APLICAR PAGO'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
       *
            05  SCR-CUERPO.
                10  LINE 03  COL 02  PIC X(15) VALUE 'PRESTAMO:'.
                10  LINE 03  COL 15  PIC X(10) FROM LON-NBR.
                10  LINE 03  COL 30  PIC X(15) VALUE 'CLIENTE:'.
                10  LINE 03  COL 45  PIC X(10) FROM LON-CUSTOMER-ID.
       *
                10  LINE 04  COL 02  PIC X(15) VALUE 'SALDO ACTUAL:'.
                10  LINE 04  COL 20  PIC Z(12)9.99 FROM LON-BALANCE.
                10  LINE 04  COL 45  PIC X(15) VALUE 'CUOTA:'.
                10  LINE 04  COL 55  PIC Z(08)9.99
                   FROM LON-INSTALLMENT-AMOUNT.
       *
                10  LINE 05  COL 02  PIC X(15) VALUE 'VENCIDO:'.
                10  LINE 05  COL 20  PIC Z(12)9.99 FROM LON-BALANCE-PAST-DUE.
                10  LINE 05  COL 45  PIC X(15) VALUE 'PAGADAS:'.
                10  LINE 05  COL 55  PIC 9(04) FROM LON-PAYMENTS-MADE.
       *
                10  LINE 07  COL 02  PIC X(20) VALUE 'MONTO A PAGAR:'.
                10  LINE 07  COL 20  PIC Z(08)9.99
                   USING WS-MONTO-PAGO-DISP AUTO PROMPT '________.__'.
       *
                10  LINE 09  COL 02  PIC X(60)
                   VALUE 'CUOTAS PENDIENTES:'.
                10  LINE 10  COL 02  PIC X(80)
                   VALUE 'NUM  FECHA      MONTO     EST'.
       *
            05  SCR-MSG.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'ENTER=PAGAR  PF12=SALIR'.
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
            PERFORM 2000-MOSTRAR-BUSQUEDA.
            ACCEPT SCR-BUSQUEDA.
       *
            IF WS-CRT-PF12
                GOTO MAIN-EXIT
            END-IF.
       *
            IF WS-CRT-ENTER
                PERFORM 3000-CONSULTAR
                IF WS-RETCODE = 00
                    PERFORM 4000-PROCESAR-PAGO
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
            OPEN I-O LOANMAST-FILE ACCOUNT-FILE TRANLOG-FILE.
            MOVE 'INGRESE NUMERO DE PRESTAMO' TO WS-MENSAJE.
       *
        2000-MOSTRAR-BUSQUEDA.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            DISPLAY SCR-BUSQUEDA.
       *
        2100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        3000-CONSULTAR.
            MOVE WS-LOAN-NBR TO LON-NBR.
            READ LOANMAST-FILE KEY IS LON-NBR
                INVALID KEY
                    MOVE 'PRESTAMO NO ENCONTRADO'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 3000-EXIT
            END-READ.
       *
            IF NOT LON-STATUS-ACTIVE
                MOVE 'PRESTAMO NO ACTIVO' TO WS-MENSAJE-ERROR
                MOVE 99 TO LS-RETCODE
                GOTO 3000-EXIT
            END-IF.
       *
            IF LON-BALANCE = ZERO
                MOVE 'PRESTAMO YA ESTA LIQUIDADO'
                  TO WS-MENSAJE-ERROR
                MOVE 99 TO LS-RETCODE
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE LON-INSTALLMENT-AMOUNT TO WS-MONTO-PAGO.
            MOVE LON-INSTALLMENT-AMOUNT TO WS-MONTO-PAGO-DISP.
            MOVE 'PRESTAMO ENCONTRADO' TO WS-MENSAJE.
            MOVE 00 TO LS-RETCODE.
       *
        3000-EXIT.
            EXIT.
       *
        4000-PROCESAR-PAGO.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
       *
        4100-PAGO-LOOP.
            PERFORM 5000-DESPLIEGA-INSTALLMENTS.
            DISPLAY SCR-PAGO.
            ACCEPT SCR-PAGO.
       *
            IF WS-CRT-PF12
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-CRT-ENTER
                MOVE WS-MONTO-PAGO-DISP TO WS-MONTO-PAGO
                IF WS-MONTO-PAGO = ZERO OR WS-MONTO-PAGO < ZERO
                    MOVE 'MONTO INVALIDO' TO WS-MENSAJE-ERROR
                    GO TO 4100-PAGO-LOOP
                END-IF
                IF WS-MONTO-PAGO > LON-BALANCE
                    MOVE 'MONTO EXCEDE SALDO' TO WS-MENSAJE-ERROR
                    GO TO 4100-PAGO-LOOP
                END-IF
                PERFORM 6000-CONFIRMAR
                IF WS-CONFIRMA = 'S'
                    PERFORM 7000-APLICAR-PAGO
                    IF WS-RETCODE = 00
                        PERFORM 8000-RESULTADO
                        GOTO 4000-EXIT
                    END-IF
                END-IF
            END-IF.
            GO TO 4100-PAGO-LOOP.
       *
        4000-EXIT.
            EXIT.
       *
        5000-DESPLIEGA-INSTALLMENTS.
            DISPLAY 'CUOTAS PENDIENTES:' AT LINE 09 COLUMN 02.
            DISPLAY 'NUM  FECHA      MONTO     EST'
              AT LINE 10 COLUMN 02.
       *
            MOVE 1 TO WS-I.
            MOVE 11 TO WS-K.
       *
            PERFORM UNTIL WS-I > LON-PAYMENTS-TOTAL
                OR WS-K > 21
                IF LON-INST-STATUS(WS-I) = 'P'
                    DISPLAY LON-INST-NBR(WS-I) AT LINE WS-K COLUMN 02
                    DISPLAY LON-INST-DUE-DATE(WS-I)
                      AT LINE WS-K COLUMN 07
                    DISPLAY LON-INST-AMOUNT(WS-I)
                      AT LINE WS-K COLUMN 18
                    DISPLAY LON-INST-STATUS(WS-I)
                      AT LINE WS-K COLUMN 34
                    ADD 1 TO WS-K
                END-IF
                ADD 1 TO WS-I
            END-PERFORM.
       *
        6000-CONFIRMAR.
            CALL 'COMMSGF' USING 'Q001'
                                 'CONFIRMA APLICAR PAGO?'
                                 'Q'
                                 WS-CONFIRMA.
       *
        7000-APLICAR-PAGO.
            MOVE WS-LOAN-NBR TO LON-NBR.
            READ LOANMAST-FILE KEY IS LON-NBR
                INVALID KEY
                    MOVE 'ERROR LEYENDO PRESTAMO'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7000-EXIT
            END-READ.
       *
            MOVE WS-MONTO-PAGO TO WS-PAGO-APLICADO.
       *
            PERFORM VARYING WS-I FROM 1 BY 1
                UNTIL WS-I > LON-PAYMENTS-TOTAL
                OR WS-PAGO-APLICADO = ZERO
                IF LON-INST-STATUS(WS-I) = 'P'
                    IF WS-PAGO-APLICADO >= LON-INST-AMOUNT(WS-I)
                        MOVE 'C' TO LON-INST-STATUS(WS-I)
                        SUBTRACT LON-INST-AMOUNT(WS-I)
                          FROM WS-PAGO-APLICADO
                        ADD 1 TO LON-PAYMENTS-MADE
                    ELSE
                        MOVE 'P' TO LON-INST-STATUS(WS-I)
                    END-IF
                END-IF
            END-PERFORM.
       *
            SUBTRACT WS-MONTO-PAGO FROM LON-BALANCE.
            IF LON-BALANCE < ZERO
                MOVE ZERO TO LON-BALANCE
            END-IF.
            MOVE WS-FECHA TO LON-DATE-LAST-PAYMENT.
            MOVE WS-FECHA TO LON-DATE-LAST-MOD.
            MOVE WS-USUARIO TO LON-USER-LAST-MOD.
       *
            REWRITE LOANMAST-RECORD
                INVALID KEY
                    MOVE 'ERROR ACT PRESTAMO' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7000-EXIT
            END-REWRITE.
       *
            PERFORM 7100-DEBITAR-CUENTA.
            PERFORM 7200-TRANLOG.
       *
            MOVE 00 TO LS-RETCODE.
        7000-EXIT.
            EXIT.
       *
        7100-DEBITAR-CUENTA.
            MOVE LON-ACCOUNT-DEBIT TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CTA DEBITO NO EXISTE'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7100-EXIT
            END-READ.
       *
            SUBTRACT WS-MONTO-PAGO FROM ACT-BALANCE.
            SUBTRACT WS-MONTO-PAGO FROM ACT-BALANCE-DISPONIBLE.
            MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
            MOVE WS-USUARIO TO ACT-USER-LAST-MOD.
            REWRITE ACCOUNT-RECORD
                INVALID KEY
                    MOVE 'ERROR ACT CTA' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7100-EXIT
            END-REWRITE.
        7100-EXIT.
            EXIT.
       *
        7200-TRANLOG.
            MOVE WS-TRN-SEQ TO TRN-SEQ.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'PAG' TO TRN-TYPE.
            MOVE LON-ACCOUNT-DEBIT TO TRN-ACCOUNT-NBR.
            MOVE SPACES TO TRN-ACCOUNT-DEST.
            MOVE LON-CUSTOMER-ID TO TRN-CUSTOMER-ID.
            MOVE WS-MONTO-PAGO TO TRN-AMOUNT.
            MOVE ZERO TO TRN-AMOUNT-TAX.
            MOVE WS-MONTO-PAGO TO TRN-AMOUNT-TOTAL.
            MOVE WS-MONTO-PAGO TO TRN-AMOUNT-ORIGINAL.
            MOVE ZERO TO TRN-FEE-AMOUNT.
            MOVE SPACES TO TRN-FEE-CODE.
            MOVE WS-SUCURSAL-ID TO TRN-BRANCH.
            MOVE WS-USUARIO TO TRN-TELLER-ID TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '01' TO TRN-CHANNEL.
            MOVE 'PAGO PRESTAMO' TO TRN-REFERENCE.
            MOVE ZERO TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE ZERO TO TRN-REVERSE-SEQ.
            STRING 'PAGO PRE ' WS-LOAN-NBR ' $' WS-MONTO-PAGO
              INTO TRN-DESCRIPTION.
            WRITE TRANLOG-RECORD
                INVALID KEY
                    MOVE 'ERROR TRANLOG' TO WS-MENSAJE-ERROR
            END-WRITE.
            ADD 1 TO WS-TRN-SEQ.
       *
        8000-RESULTADO.
            MOVE 'PAGO APLICADO EXITOSAMENTE' TO WS-MENSAJE.
            STRING 'PAGO PRE ' WS-LOAN-NBR ' $' WS-MONTO-PAGO
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
            PERFORM 2100-LIMPIAR.
            DISPLAY SCR-PAGO.
            MOVE 'PRESIONE ENTER...' TO WS-MENSAJE.
            DISPLAY SCR-PAGO.
            ACCEPT SCR-PAGO.
       *
        9000-FINALIZAR.
            CLOSE LOANMAST-FILE ACCOUNT-FILE TRANLOG-FILE.
            GOBACK.
       *
        END PROGRAM LONPYM00.
