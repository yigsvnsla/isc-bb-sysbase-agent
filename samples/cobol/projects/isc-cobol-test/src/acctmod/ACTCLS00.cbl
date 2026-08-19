       *================================================================*
       * ACTCLS00 - CIERRE DE CUENTA                                 *
       * PROPOSITO: CERRAR CUENTA CON SALDO CERO O PROCESAR SALDO    *
       * EQUIPO: CONTABLE - 2003                                     *
       * ARCHIVOS: ACCOUNT, TRANLOG (LECTURA/ESCRITURA)              *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. ACTCLS00.
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
            SELECT AUDITLOG-FILE
                ASSIGN TO 'AUDITLOG.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS AUD-SEQ
                FILE STATUS IS FL-AUDITLOG-STATUS.
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
        FD  AUDITLOG-FILE
            RECORD 200 CHARACTERS.
        COPY FD-AUDITLOG.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'ACTCLS00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-ACTNBR                  PIC X(10).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-BALANCE-DISP            PIC -(11)9.99.
            05  WS-DUMMY                   PIC X(01).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-CIERRE.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' CIERRE DE CUENTA'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID.
                10  LINE 04  COL 05  PIC X(15) VALUE 'NUMERO CUENTA:'.
                10  LINE 04  COL 22  PIC X(10)
                    USING WS-ACTNBR AUTO PROMPT '__________'.
                10  LINE 04  COL 35  PIC X(20) VALUE 'ENTER=CONSULTAR'.
       *
            05  SCR-DATOS.
                10  LINE 06  COL 05  PIC X(15) VALUE 'TIPO:'.
                10  LINE 06  COL 16  PIC X(02) FROM ACT-TYPE.
                10  LINE 06  COL 25  PIC X(15) VALUE 'MONEDA:'.
                10  LINE 06  COL 35  PIC X(03) FROM ACT-CURRENCY.
                10  LINE 06  COL 45  PIC X(15) VALUE 'ESTATUS:'.
                10  LINE 06  COL 55  PIC X(01) FROM ACT-STATUS.
       *
                10  LINE 08  COL 05  PIC X(15) VALUE 'SALDO ACTUAL:'.
                10  LINE 08  COL 22  PIC -(11)9.99 FROM ACT-BALANCE.
                10  LINE 08  COL 45  PIC X(20) VALUE 'DISPONIBLE:'.
                10  LINE 08  COL 62  PIC -(11)9.99
                    FROM ACT-BALANCE-DISPONIBLE.
       *
                10  LINE 10  COL 05  PIC X(15) VALUE 'FECHA APERTURA:'.
                10  LINE 10  COL 22  PIC 9(08) FROM ACT-DATE-OPEN.
                10  LINE 11  COL 05  PIC X(15) VALUE 'SUCURSAL:'.
                10  LINE 11  COL 22  PIC X(04) FROM ACT-BRANCH-OPEN.
                10  LINE 11  COL 30  PIC X(15) VALUE 'OFICIAL:'.
                10  LINE 11  COL 45  PIC X(08) FROM ACT-OFFICER.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF3=CERRAR  PF11=AYUDA  PF12=RETORNAR'.
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
            MOVE SPACES TO WS-ACTNBR.
       *
            PERFORM 1000-INICIALIZAR.
       *
        CLOSE-LOOP.
            PERFORM 3000-REFRESCAR.
            DISPLAY SCR-CIERRE.
            ACCEPT SCR-CIERRE.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 4000-CONSULTAR-CUENTA
                    GO TO CLOSE-LOOP
       *
                WHEN WS-CRT-PF3
                    PERFORM 5000-CERRAR-CUENTA
                    GO TO CLOSE-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'ACTCLS00'
                    GO TO CLOSE-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO CLOSE-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-ACTNBR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO CLOSE-LOOP
       *
                WHEN OTHER
                    MOVE 'USE ENTER=CONS PF3=CERRAR PF12=SALIR'
                      TO WS-MENSAJE-ERROR
                    GO TO CLOSE-LOOP
            END-EVALUATE.
       *
        CLOSE-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE CUENTA, ENTER=CONS, PF3=CERRAR'
              TO WS-MENSAJE.
            PERFORM 1100-LIMPIAR.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        3000-REFRESCAR.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
        4000-CONSULTAR-CUENTA.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-ACTNBR = SPACES
                MOVE 'INGRESE NUMERO DE CUENTA' TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            OPEN I-O ACCOUNT-FILE.
            IF FL-ACCOUNT-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO' TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            MOVE WS-ACTNBR TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CUENTA NO ENCONTRADA' TO WS-MENSAJE-ERROR
                    CLOSE ACCOUNT-FILE
                    GO TO 4000-EXIT
            END-READ.
       *
            IF FL-ACCOUNT-STATUS = '00'
                MOVE 'CUENTA ENCONTRADA - VERIFIQUE DATOS'
                  TO WS-MENSAJE
            ELSE
                MOVE 'ERROR AL LEER CUENTA' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE ACCOUNT-FILE.
        4000-EXIT.
            EXIT.
       *
        5000-CERRAR-CUENTA.
            IF WS-ACTNBR = SPACES
                MOVE 'PRIMERO CONSULTE UNA CUENTA' TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            OPEN I-O ACCOUNT-FILE.
            IF FL-ACCOUNT-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR ARCHIVO' TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            MOVE WS-ACTNBR TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CUENTA NO ENCONTRADA' TO WS-MENSAJE-ERROR
                    CLOSE ACCOUNT-FILE
                    GO TO 5000-EXIT
            END-READ.
       *
            IF ACT-STATUS = 'C'
                MOVE 'CUENTA YA ESTA CERRADA' TO WS-MENSAJE-ERROR
                CLOSE ACCOUNT-FILE
                GO TO 5000-EXIT
            END-IF.
       *
            IF ACT-BALANCE NOT = 0
                MOVE 'CUENTA TIENE SALDO PENDIENTE - NO SE PUEDE CERRAR'
                  TO WS-MENSAJE-ERROR
                CLOSE ACCOUNT-FILE
                GO TO 5000-EXIT
            END-IF.
       *
            IF ACT-BALANCE-DISPONIBLE NOT = 0
                MOVE 'FONDOS DISPONIBLES - RETIRE ANTES DE CERRAR'
                  TO WS-MENSAJE-ERROR
                CLOSE ACCOUNT-FILE
                GO TO 5000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-CONFIRMA.
            DISPLAY 'CONFIRMA CIERRE DE CUENTA? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRMA AT LINE 23 COLUMN 40.
            IF WS-CONFIRMA NOT = 'S' AND NOT = 's'
                MOVE 'CIERRE CANCELADO' TO WS-MENSAJE
                CLOSE ACCOUNT-FILE
                GO TO 5000-EXIT
            END-IF.
       *
            MOVE 'C' TO ACT-STATUS.
            MOVE WS-FECHA TO ACT-DATE-CLOSE
                             ACT-DATE-LAST-ACTIVITY.
            MOVE WS-USUARIO-ID TO ACT-USER-LAST-MOD.
       *
            REWRITE ACCOUNT-RECORD
                INVALID KEY
                    MOVE 'ERROR AL CERRAR CUENTA' TO WS-MENSAJE-ERROR
                    CLOSE ACCOUNT-FILE
                    GO TO 5000-EXIT
            END-REWRITE.
       *
            IF FL-ACCOUNT-STATUS = '00'
                PERFORM 6000-REGISTRAR-TRANSACCION
                PERFORM 7000-REGISTRAR-AUDITORIA
                MOVE 'CUENTA CERRADA EXITOSAMENTE' TO WS-MENSAJE
            ELSE
                MOVE 'ERROR AL CERRAR CUENTA' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE ACCOUNT-FILE.
        5000-EXIT.
            EXIT.
       *
        6000-REGISTRAR-TRANSACCION.
            OPEN I-O TRANLOG-FILE.
            MOVE 0 TO TRN-SEQ.
            START TRANLOG-FILE KEY IS NOT < TRN-SEQ
                INVALID KEY
                    MOVE 0 TO TRN-SEQ
                    GO TO 6000-ESCRIBIR
            END-START.
            READ TRANLOG-FILE NEXT RECORD
                AT END
                    MOVE 0 TO TRN-SEQ
                    GO TO 6000-ESCRIBIR
            END-READ.
            IF TRN-SEQ IS NUMERIC
                ADD 1 TO TRN-SEQ
            END-IF.
        6000-ESCRIBIR.
            MOVE WS-FECHA TO TRN-DATE
            MOVE WS-HORA TO TRN-TIME
            MOVE 'CIE' TO TRN-TYPE
            MOVE WS-ACTNBR TO TRN-ACCOUNT-NBR
            MOVE SPACES TO TRN-ACCOUNT-DEST
            MOVE SPACES TO TRN-CUSTOMER-ID
            MOVE 0 TO TRN-AMOUNT TRN-AMOUNT-TAX
                       TRN-AMOUNT-TOTAL TRN-AMOUNT-ORIGINAL
                       TRN-FEE-AMOUNT
            MOVE SPACES TO TRN-FEE-CODE
            MOVE ACT-BRANCH-OPEN TO TRN-BRANCH
            MOVE SPACES TO TRN-TELLER-ID
            MOVE WS-USUARIO-ID TO TRN-USER-ID
            MOVE SPACES TO TRN-TERMINAL
            MOVE '03' TO TRN-CHANNEL
            MOVE 'CIERRE DE CUENTA' TO TRN-REFERENCE
            MOVE 0 TO TRN-CHQ-NBR
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT
            MOVE 'C' TO TRN-STATUS
            MOVE 0 TO TRN-REVERSE-SEQ
            MOVE 'CIERRE DE CUENTA' TO TRN-DESCRIPTION
            WRITE TRANLOG-RECORD
            CLOSE TRANLOG-FILE.
       *
        7000-REGISTRAR-AUDITORIA.
            OPEN I-O AUDITLOG-FILE.
            IF FL-AUDITLOG-STATUS = '00'
                MOVE 0 TO AUD-SEQ
                START AUDITLOG-FILE KEY IS NOT < AUD-SEQ
                    INVALID KEY
                        MOVE 0 TO AUD-SEQ
                        GO TO 7000-ESCRIBIR
                END-START
                READ AUDITLOG-FILE NEXT RECORD
                    AT END
                        MOVE 0 TO AUD-SEQ
                        GO TO 7000-ESCRIBIR
                END-READ
                IF AUD-SEQ IS NUMERIC
                    ADD 1 TO AUD-SEQ
                END-IF
        7000-ESCRIBIR.
                MOVE WS-FECHA TO AUD-DATE
                MOVE WS-HORA TO AUD-TIME
                MOVE WS-USUARIO-ID TO AUD-USUARIO
                MOVE 'ACTCLS00' TO AUD-PROGRAMA
                MOVE 'CI' TO AUD-EVENTO
                MOVE 'CT' TO AUD-ENTITY-TYPE
                MOVE ACT-NBR TO AUD-ENTITY-KEY
                MOVE 'CIERRE DE CUENTA' TO AUD-OBSERVACIONES
                MOVE 'O' TO AUD-RESULTADO
                WRITE AUDITLOG-RECORD
                CLOSE AUDITLOG-FILE
            END-IF.
       *
        END PROGRAM ACTCLS00.
