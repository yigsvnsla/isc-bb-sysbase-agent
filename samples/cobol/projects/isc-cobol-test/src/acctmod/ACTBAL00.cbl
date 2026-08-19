       *================================================================*
       * ACTBAL00 - CONSULTA DE SALDO CON MINI-ESTADO DE CUENTA       *
       * PROPOSITO: MOSTRAR SALDOS Y ULTIMAS 5 TRANSACCIONES          *
       * EQUIPO: CONTABLE - 2004 (REVISADO 2006)                      *
       * ARCHIVOS: ACCOUNT, TRANLOG (LECTURA)                         *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. ACTBAL00.
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
                ALTERNATE RECORD KEY IS TRN-ACCOUNT-NBR
                    WITH DUPLICATES
                FILE STATUS IS FL-TRANLOG-STATUS.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'ACTBAL00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-ACTNBR                  PIC X(10).
            05  WS-IND                     PIC 9(03).
            05  WS-TRN-COUNT               PIC 9(02).
            05  WS-TRN-SEQ-LOOP            PIC 9(10).
            05  WS-TRN-LIMITE              PIC 9(02) VALUE 5.
            05  WS-DUMMY                   PIC X(01).
            05  WS-LINEA                   PIC 9(02).
       *
        01  WS-TRN-TABLE.
            05  WS-TRN-ENTRY               OCCURS 5.
                10  WS-TRN-DATE            PIC 9(08).
                10  WS-TRN-TYPE            PIC X(03).
                10  WS-TRN-DESC            PIC X(30).
                10  WS-TRN-AMOUNT          PIC S9(13)V99 COMP-3.
                10  WS-TRN-BALANCE         PIC S9(13)V99 COMP-3.
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-BALANCE.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' CONSULTA DE SALDO'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID.
                10  LINE 04  COL 05  PIC X(15) VALUE 'NUMERO CUENTA:'.
                10  LINE 04  COL 22  PIC X(10)
                    USING WS-ACTNBR AUTO PROMPT '__________'.
                10  LINE 04  COL 35  PIC X(20) VALUE 'ENTER=CONSULTAR'.
       *
            05  SCR-SALDOS.
                10  LINE 06  COL 05  PIC X(10) VALUE 'CTA:'.
                10  LINE 06  COL 16  PIC X(10) FROM ACT-NBR.
                10  LINE 06  COL 30  PIC X(10) VALUE 'TIPO:'.
                10  LINE 06  COL 40  PIC X(02) FROM ACT-TYPE.
                10  LINE 06  COL 45  PIC X(10) VALUE 'MON:'.
                10  LINE 06  COL 55  PIC X(03) FROM ACT-CURRENCY.
       *
                10  LINE 08  COL 05  PIC X(20) VALUE 'SALDO ACTUAL:'.
                10  LINE 08  COL 28  PIC -(11)9.99 FROM ACT-BALANCE.
                10  LINE 09  COL 05  PIC X(20) VALUE 'DISPONIBLE:'.
                10  LINE 09  COL 28  PIC -(11)9.99
                    FROM ACT-BALANCE-DISPONIBLE.
                10  LINE 10  COL 05  PIC X(20) VALUE 'RETENIDO:'.
                10  LINE 10  COL 28  PIC -(11)9.99
                    FROM ACT-BALANCE-RETENIDO.
                10  LINE 11  COL 05  PIC X(20) VALUE 'SOBREGIRO:'.
                10  LINE 11  COL 28  PIC -(11)9.99
                    FROM ACT-BALANCE-SOBREGIRO.
       *
            05  SCR-MINI-HEADER.
                10  LINE 13  COL 05  PIC X(60) VALUE ALL '-'.
                10  LINE 14  COL 05  PIC X(50)
                    VALUE 'ULTIMOS MOVIMIENTOS'.
                10  LINE 15  COL 05  PIC X(05) VALUE 'FECHA'.
                10  LINE 15  COL 15  PIC X(05) VALUE 'TIPO'.
                10  LINE 15  COL 25  PIC X(20) VALUE 'DESCRIPCION'.
                10  LINE 15  COL 50  PIC X(10) VALUE 'MONTO'.
                10  LINE 16  COL 05  PIC X(60) VALUE ALL '-'.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF3=DETALLE  PF11=AYUDA  PF12=RETORNAR'.
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
        BAL-LOOP.
            PERFORM 3000-REFRESCAR.
            DISPLAY SCR-BALANCE.
            ACCEPT SCR-BALANCE.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 4000-CONSULTAR-SALDO
                    GO TO BAL-LOOP
       *
                WHEN WS-CRT-PF3
                    PERFORM 5000-VER-DETALLE
                    GO TO BAL-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'ACTBAL00'
                    GO TO BAL-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO BAL-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-ACTNBR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO BAL-LOOP
       *
                WHEN OTHER
                    MOVE 'USE ENTER=CONS PF3=DETL PF12=SALIR'
                      TO WS-MENSAJE-ERROR
                    GO TO BAL-LOOP
            END-EVALUATE.
       *
        BAL-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE CUENTA, ENTER=CONS, PF3=DETALLE'
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
        4000-CONSULTAR-SALDO.
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
                PERFORM 6000-CARGAR-MINI-ESTADO
                MOVE 'SALDOS CONSULTADOS' TO WS-MENSAJE
            ELSE
                MOVE 'ERROR AL LEER CUENTA' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE ACCOUNT-FILE.
        4000-EXIT.
            EXIT.
       *
        5000-VER-DETALLE.
            IF WS-ACTNBR = SPACES
                MOVE 'PRIMERO CONSULTE UNA CUENTA' TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            CALL 'ACTINQ00' USING WS-USUARIO-ID WS-RETCODE.
        5000-EXIT.
            EXIT.
       *
        6000-CARGAR-MINI-ESTADO.
            MOVE 0 TO WS-TRN-COUNT.
       *
            OPEN I-O TRANLOG-FILE.
            IF FL-TRANLOG-STATUS NOT = '00' AND NOT = '23'
                GO TO 6000-EXIT
            END-IF.
       *
            MOVE WS-ACTNBR TO TRN-ACCOUNT-NBR.
            START TRANLOG-FILE KEY IS NOT < TRN-ACCOUNT-NBR
                INVALID KEY
                    CLOSE TRANLOG-FILE
                    GO TO 6000-EXIT
            END-START.
       *
            MOVE 'N' TO WS-SWITCH-EOF.
            PERFORM VARYING WS-TRN-SEQ-LOOP FROM 1 BY 1
                UNTIL WS-EOF-YES
                READ TRANLOG-FILE NEXT RECORD
                    AT END
                        MOVE 'Y' TO WS-SWITCH-EOF
                        GO TO 6000-CONTINUE
                END-READ
       *
                IF TRN-ACCOUNT-NBR NOT = WS-ACTNBR
                    MOVE 'Y' TO WS-SWITCH-EOF
                    GO TO 6000-CONTINUE
                END-IF
       *
                IF WS-TRN-COUNT < 5
                    ADD 1 TO WS-TRN-COUNT
                    MOVE TRN-DATE TO WS-TRN-DATE(WS-TRN-COUNT)
                    MOVE TRN-TYPE TO WS-TRN-TYPE(WS-TRN-COUNT)
                    MOVE TRN-DESCRIPTION
                      TO WS-TRN-DESC(WS-TRN-COUNT)
                    MOVE TRN-AMOUNT TO WS-TRN-AMOUNT(WS-TRN-COUNT)
                    IF WS-TRN-COUNT = 1
                        MOVE TRN-AMOUNT
                          TO WS-TRN-BALANCE(WS-TRN-COUNT)
                    ELSE
                        COMPUTE WS-TRN-BALANCE(WS-TRN-COUNT) =
                            WS-TRN-BALANCE(WS-TRN-COUNT - 1)
                            + TRN-AMOUNT
                    END-IF
                END-IF
            END-PERFORM.
       *
        6000-CONTINUE.
            CLOSE TRANLOG-FILE.
       *
            PERFORM VARYING WS-IND FROM 1 BY 1
                UNTIL WS-IND > WS-TRN-COUNT
                COMPUTE WS-LINEA = 16 + WS-IND
                DISPLAY WS-TRN-DATE(WS-IND)
                    AT LINE WS-LINEA COLUMN 05
                DISPLAY WS-TRN-TYPE(WS-IND)
                    AT LINE WS-LINEA COLUMN 15
                DISPLAY WS-TRN-DESC(WS-IND)(1:20)
                    AT LINE WS-LINEA COLUMN 25
                MOVE WS-TRN-AMOUNT(WS-IND) TO WS-BALANCE-DISP
                DISPLAY WS-BALANCE-DISP
                    AT LINE WS-LINEA COLUMN 50
            END-PERFORM.
        6000-EXIT.
            EXIT.
       *
        END PROGRAM ACTBAL00.
