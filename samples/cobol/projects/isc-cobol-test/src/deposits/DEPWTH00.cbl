       *================================================================*
       * DEPWTH00 - RETIRO / WITHDRAWAL DE DEPOSITO                   *
       * PROPOSITO: PROCESAR RETIRO CON CALCULO DE PENALIZACION        *
       * EQUIPO: AHORRO Y DEPOSITOS - 2002                            *
       * ARCHIVOS: DEPMAST, TRANLOG                                   *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. DEPWTH00.
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
            SELECT DEPMAST-FILE
                ASSIGN TO 'DEPMAST.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS DEP-NBR
                FILE STATUS IS FL-DEPMAST-STATUS.
       *
            SELECT TRANLOG-FILE
                ASSIGN TO 'TRANLOG.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS TRN-SEQ
                FILE STATUS IS FL-TRANLOG-STATUS.
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
        FD  DEPMAST-FILE
            RECORD 200 CHARACTERS.
        COPY FD-DEPMAST.
       *
        FD  TRANLOG-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TRANLOG.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'DEPWTH00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-DEPNBR                  PIC X(10).
            05  WS-WITHDRAW-AMOUNT         PIC 9(13)V99 COMP-3.
            05  WS-PENALTY-AMOUNT          PIC 9(09)V99 COMP-3.
            05  WS-NET-AMOUNT              PIC 9(13)V99 COMP-3.
            05  WS-PENALTY-RATE            PIC 9(03)V9(04) COMP-3.
            05  WS-EARLY-WITHDRAWAL        PIC X(01).
                88  WS-ES-EARLY            VALUE 'S'.
                88  WS-NO-EARLY            VALUE 'N'.
            05  WS-CONFIRM                 PIC X(01).
            05  WS-AUDIT-DATA              PIC X(60).
            05  WS-TRN-SEQ-AUX             PIC 9(10).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-WITHDRAWAL.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' RETIRO DE DEPOSITO'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID.
                10  LINE 04  COL 05  PIC X(18) VALUE 'NUMERO DEPOSITO:'.
                10  LINE 04  COL 25  PIC X(10)
                    USING WS-DEPNBR AUTO PROMPT '__________'.
                10  LINE 04  COL 40  PIC X(20) VALUE 'ENTER=CONSULTA'.
       *
            05  SCR-DATOS.
                10  LINE 06  COL 05  PIC X(15) VALUE 'CLIENTE:'.
                10  LINE 06  COL 20  PIC X(10) FROM DEP-CUSTOMER-ID.
                10  LINE 06  COL 40  PIC X(15) VALUE 'TIPO:'.
                10  LINE 06  COL 55  PIC X(02) FROM DEP-TYPE.
                10  LINE 07  COL 05  PIC X(15) VALUE 'PRODUCTO:'.
                10  LINE 07  COL 20  PIC X(04) FROM DEP-PRODUCT.
                10  LINE 07  COL 40  PIC X(15) VALUE 'SALDO ACTUAL:'.
                10  LINE 07  COL 55  PIC -(11)9.99 FROM DEP-BALANCE.
                10  LINE 08  COL 05  PIC X(15) VALUE 'VENCIMIENTO:'.
                10  LINE 08  COL 20  PIC 9(08) FROM DEP-DATE-MATURITY.
                10  LINE 08  COL 45  PIC X(15) VALUE 'ESTATUS:'.
                10  LINE 08  COL 55  PIC X(01) FROM DEP-STATUS.
       *
            05  SCR-PENALTY.
                10  LINE 10  COL 05  PIC X(20) VALUE 'PENALIZACION:'.
                10  LINE 10  COL 28  PIC -(09)9.99 FROM WS-PENALTY-AMOUNT
                    BLINK.
                10  LINE 11  COL 05  PIC X(20) VALUE 'MONTO A RETIRAR:'.
                10  LINE 11  COL 28  PIC -(11)9.99
                    USING WS-WITHDRAW-AMOUNT AUTO.
                10  LINE 12  COL 05  PIC X(20) VALUE 'NETO A PAGAR:'.
                10  LINE 12  COL 28  PIC -(11)9.99 FROM WS-NET-AMOUNT.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'ENTER=CONFIRMAR  PF11=AYU  PF12=RETORNAR'.
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
            MOVE SPACES TO WS-DEPNBR.
            MOVE 0 TO WS-WITHDRAW-AMOUNT
                      WS-PENALTY-AMOUNT
                      WS-NET-AMOUNT.
       *
            PERFORM 1000-INICIALIZAR.
       *
        WTH-LOOP.
            PERFORM 2000-REFRESCAR.
            DISPLAY SCR-WITHDRAWAL.
            ACCEPT SCR-WITHDRAWAL.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    IF WS-DEPNBR NOT = SPACES
                        AND DEP-BALANCE = 0
                        PERFORM 3000-CARGAR-DEPOSITO
                    ELSE
                        IF WS-WITHDRAW-AMOUNT > 0
                            PERFORM 4000-PROCESAR-RETIRO
                        ELSE
                            PERFORM 3000-CARGAR-DEPOSITO
                        END-IF
                    END-IF
                    GO TO WTH-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'DEPWTH00'
                    GO TO WTH-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO WTH-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-DEPNBR
                    MOVE 0 TO WS-WITHDRAW-AMOUNT
                              WS-PENALTY-AMOUNT
                              WS-NET-AMOUNT
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO WTH-LOOP
       *
                WHEN OTHER
                    MOVE 'INGRESE DEPOSITO Y ENTER=CONS  PF12=RET'
                      TO WS-MENSAJE-ERROR
                    GO TO WTH-LOOP
            END-EVALUATE.
       *
        WTH-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE NUMERO DE DEPOSITO Y PRESIONE ENTER'
              TO WS-MENSAJE.
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
        3000-CARGAR-DEPOSITO.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-DEPNBR = SPACES OR = LOW-VALUES
                MOVE 'INGRESE NUMERO DE DEPOSITO' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            OPEN I-O DEPMAST-FILE.
            IF FL-DEPMAST-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE WS-DEPNBR TO DEP-NBR.
            READ DEPMAST-FILE KEY IS DEP-NBR
                INVALID KEY
                    MOVE 'DEPOSITO NO ENCONTRADO' TO WS-MENSAJE-ERROR
                    CLOSE DEPMAST-FILE
                    GOTO 3000-EXIT
            END-READ.
       *
            IF FL-DEPMAST-STATUS = '00'
                IF DEP-STATUS NOT = 'A'
                    MOVE 'DEPOSITO NO ESTA ACTIVO' TO WS-MENSAJE-ERROR
                    CLOSE DEPMAST-FILE
                    GOTO 3000-EXIT
                END-IF
                MOVE 'DEPOSITO ENCONTRADO - INGRESE MONTO A RETIRAR'
                  TO WS-MENSAJE
            ELSE
                MOVE 'ERROR AL LEER DEPOSITO' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE DEPMAST-FILE.
       *
            PERFORM 3100-CALCULAR-PENALIZACION.
        3000-EXIT.
            EXIT.
       *
        3100-CALCULAR-PENALIZACION.
            MOVE 0 TO WS-PENALTY-AMOUNT.
            MOVE 'N' TO WS-EARLY-WITHDRAWAL.
       *
            IF DEP-DATE-MATURITY > WS-FECHA
                MOVE 'S' TO WS-EARLY-WITHDRAWAL
                PERFORM 3200-LEER-TASA-PENALIZACION
                IF WS-PENALTY-RATE > 0
                    COMPUTE WS-PENALTY-AMOUNT =
                        DEP-BALANCE * WS-PENALTY-RATE / 100
                ELSE
                    COMPUTE WS-PENALTY-AMOUNT =
                        DEP-BALANCE * 0.05
                END-IF
            END-IF.
       *
        3200-LEER-TASA-PENALIZACION.
            MOVE 0 TO WS-PENALTY-RATE.
       *
            OPEN I-O RATEFILE-FILE.
            IF FL-RATEFILE-STATUS NOT = '00'
                GOTO 3200-EXIT
            END-IF.
       *
            MOVE DEP-PRODUCT TO RAT-CODIGO(1:4).
            MOVE 'PE' TO RAT-CODIGO(5:2).
            READ RATEFILE-FILE KEY IS RAT-CODIGO
                INVALID KEY
                    CLOSE RATEFILE-FILE
                    GOTO 3200-EXIT
            END-READ.
       *
            IF FL-RATEFILE-STATUS = '00'
                MOVE RAT-TASA-ANUAL TO WS-PENALTY-RATE
            END-IF.
       *
            CLOSE RATEFILE-FILE.
        3200-EXIT.
            EXIT.
       *
        4000-PROCESAR-RETIRO.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-WITHDRAW-AMOUNT <= 0
                MOVE 'INGRESE MONTO VALIDO A RETIRAR'
                  TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-WITHDRAW-AMOUNT > DEP-BALANCE
                MOVE 'MONTO EXCEDE EL SALDO DISPONIBLE'
                  TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            COMPUTE WS-NET-AMOUNT =
                WS-WITHDRAW-AMOUNT - WS-PENALTY-AMOUNT.
            IF WS-NET-AMOUNT < 0
                MOVE 0 TO WS-NET-AMOUNT
            END-IF.
       *
            MOVE SPACES TO WS-CONFIRM.
            DISPLAY 'CONFIRMAR RETIRO DE ' WS-WITHDRAW-AMOUNT
                    ' CON PENALIZACION DE ' WS-PENALTY-AMOUNT '? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRM AT LINE 23 COLUMN 72.
            IF WS-CONFIRM NOT = 'S' AND NOT = 's'
                MOVE 'RETIRO CANCELADO' TO WS-MENSAJE
                GOTO 4000-EXIT
            END-IF.
       *
            OPEN I-O DEPMAST-FILE.
            IF FL-DEPMAST-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR DEPMAST' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE WS-DEPNBR TO DEP-NBR.
            READ DEPMAST-FILE KEY IS DEP-NBR
                INVALID KEY
                    MOVE 'ERROR AL LEER DEPOSITO' TO WS-MENSAJE-ERROR
                    CLOSE DEPMAST-FILE
                    GOTO 4000-EXIT
            END-READ.
       *
            SUBTRACT WS-WITHDRAW-AMOUNT FROM DEP-BALANCE.
            MOVE WS-FECHA TO DEP-DATE-LAST-TXN.
            IF DEP-BALANCE = 0
                MOVE 'C' TO DEP-STATUS
            END-IF.
       *
            REWRITE DEPMAST-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ACTUALIZAR DEPOSITO'
                      TO WS-MENSAJE-ERROR
                    CLOSE DEPMAST-FILE
                    GOTO 4000-EXIT
            END-REWRITE.
       *
            CLOSE DEPMAST-FILE.
       *
            PERFORM 5000-ESCRIBIR-TRANLOG.
            PERFORM 6000-AUDITAR.
       *
            STRING 'RETIRO PROCESADO: ' WS-WITHDRAW-AMOUNT
              INTO WS-MENSAJE.
        4000-EXIT.
            EXIT.
       *
        5000-ESCRIBIR-TRANLOG.
            OPEN I-O TRANLOG-FILE.
            IF FL-TRANLOG-STATUS NOT = '00'
                OPEN OUTPUT TRANLOG-FILE
                IF FL-TRANLOG-STATUS NOT = '00'
                    GOTO 5000-EXIT
                END-IF
            END-IF.
       *
            MOVE 0 TO TRN-SEQ.
            START TRANLOG-FILE KEY IS NOT < TRN-SEQ
                INVALID KEY
                    MOVE 1 TO TRN-SEQ
                    GOTO 5000-ESCRIBE
            END-START.
       *
            READ TRANLOG-FILE NEXT RECORD
                AT END
                    MOVE 1 TO TRN-SEQ
                    GOTO 5000-ESCRIBE
            END-READ.
       *
            ADD 1 TO TRN-SEQ.
            MOVE TRN-SEQ TO WS-TRN-SEQ-AUX.
            MOVE WS-TRN-SEQ-AUX TO TRN-SEQ.
       *
        5000-ESCRIBE.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'RET' TO TRN-TYPE.
            MOVE WS-DEPNBR TO TRN-ACCOUNT-NBR.
            MOVE DEP-ACCOUNT-LINKED TO TRN-ACCOUNT-DEST.
            MOVE DEP-CUSTOMER-ID TO TRN-CUSTOMER-ID.
            MOVE WS-WITHDRAW-AMOUNT TO TRN-AMOUNT.
            MOVE 0 TO TRN-AMOUNT-TAX.
            MOVE WS-NET-AMOUNT TO TRN-AMOUNT-TOTAL.
            MOVE WS-WITHDRAW-AMOUNT TO TRN-AMOUNT-ORIGINAL.
            MOVE WS-PENALTY-AMOUNT TO TRN-FEE-AMOUNT.
            MOVE 'PE01' TO TRN-FEE-CODE.
            MOVE WS-SUCURSAL-ID TO TRN-BRANCH.
            MOVE SPACES TO TRN-TELLER-ID.
            MOVE WS-USUARIO-ID TO TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '01' TO TRN-CHANNEL.
            MOVE SPACES TO TRN-REFERENCE.
            MOVE 0 TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE 0 TO TRN-REVERSE-SEQ.
            MOVE 'RETIRO DEPOSITO' TO TRN-DESCRIPTION.
       *
            WRITE TRANLOG-RECORD
                INVALID KEY
                    DISPLAY 'ERROR AL ESCRIBIR TRANLOG'
            END-WRITE.
       *
            CLOSE TRANLOG-FILE.
        5000-EXIT.
            EXIT.
       *
        6000-AUDITAR.
            STRING 'DEPWTH00 DEP=' WS-DEPNBR ' MONTO='
                   WS-WITHDRAW-AMOUNT
              INTO WS-AUDIT-DATA.
            CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                  WS-AUDIT-DATA.
       *
        END PROGRAM DEPWTH00.
