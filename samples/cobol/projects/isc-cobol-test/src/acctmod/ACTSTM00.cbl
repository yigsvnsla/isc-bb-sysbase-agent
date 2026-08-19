       *================================================================*
       * ACTSTM00 - ESTADO DE CUENTA (PERIODO)                        *
       * PROPOSITO: LISTAR TRANSACCIONES POR RANGO DE FECHAS          *
       * EQUIPO: CONTABLE - 2003 (ACTUALIZADO 2005)                   *
       * ARCHIVOS: ACCOUNT, TRANLOG (LECTURA)                         *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. ACTSTM00.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'ACTSTM00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-ACTNBR                  PIC X(10).
            05  WS-FECHA-DESDE             PIC 9(08).
            05  WS-FECHA-HASTA             PIC 9(08).
            05  WS-FECHA-DESDE-DISP        PIC 9(08).
            05  WS-FECHA-HASTA-DISP        PIC 9(08).
            05  WS-IND                     PIC 9(03).
            05  WS-TRN-COUNT               PIC 9(04).
            05  WS-PAGINA                  PIC 9(02) VALUE 1.
            05  WS-PAGINA-MAX              PIC 9(02).
            05  WS-REG-POR-PAGINA          PIC 9(02) VALUE 12.
            05  WS-BALANCE-ACUM            PIC S9(13)V99 COMP-3.
            05  WS-BALANCE-DISP            PIC -(11)9.99.
            05  WS-DUMMY                   PIC X(01).
            05  WS-LINEA                   PIC 9(02).
       *
        01  WS-TRN-TABLE.
            05  WS-TRN-ENTRY               OCCURS 100.
                10  WS-TRN-FECHA           PIC 9(08).
                10  WS-TRN-TIPO            PIC X(03).
                10  WS-TRN-DESC            PIC X(30).
                10  WS-TRN-MONTO           PIC S9(13)V99 COMP-3.
                10  WS-TRN-BAL             PIC S9(13)V99 COMP-3.
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-ESTADO.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' ESTADO DE CUENTA'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-DATOS.
                10  LINE 04  COL 05  PIC X(15) VALUE 'NUMERO CUENTA:'.
                10  LINE 04  COL 22  PIC X(10)
                    USING WS-ACTNBR AUTO PROMPT '__________'.
       *
                10  LINE 05  COL 05  PIC X(15) VALUE 'FECHA DESDE:'.
                10  LINE 05  COL 22  PIC 9(08)
                    USING WS-FECHA-DESDE AUTO PROMPT '________'.
                10  LINE 05  COL 35  PIC X(10) VALUE 'YYYYMMDD'.
       *
                10  LINE 06  COL 05  PIC X(15) VALUE 'FECHA HASTA:'.
                10  LINE 06  COL 22  PIC 9(08)
                    USING WS-FECHA-HASTA AUTO PROMPT '________'.
                10  LINE 06  COL 35  PIC X(10) VALUE 'YYYYMMDD'.
                10  LINE 06  COL 50  PIC X(20) VALUE 'ENTER=GENERAR'.
       *
            05  SCR-LISTA-HEADER.
                10  LINE 08  COL 05  PIC X(60) VALUE ALL '-'.
                10  LINE 09  COL 05  PIC X(05) VALUE 'FECHA'.
                10  LINE 09  COL 15  PIC X(05) VALUE 'TIPO'.
                10  LINE 09  COL 22  PIC X(25) VALUE 'DESCRIPCION'.
                10  LINE 09  COL 50  PIC X(12) VALUE 'MONTO'.
                10  LINE 09  COL 63  PIC X(12) VALUE 'SALDO'.
                10  LINE 10  COL 05  PIC X(60) VALUE ALL '-'.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF4=IMPRIMIR  PF7=PAG-ANT  PF8=PAG-SIG'.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF11=AYU  PF12=RET'.
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
            MOVE 0 TO WS-FECHA-DESDE WS-FECHA-HASTA.
            MOVE 1 TO WS-PAGINA.
            MOVE 0 TO WS-TRN-COUNT.
       *
            PERFORM 1000-INICIALIZAR.
       *
        STM-LOOP.
            PERFORM 3000-REFRESCAR.
            DISPLAY SCR-ESTADO.
            ACCEPT SCR-ESTADO.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 4000-GENERAR-ESTADO
                    MOVE 1 TO WS-PAGINA
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF4
                    PERFORM 5000-IMPRIMIR
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF7
                    IF WS-PAGINA > 1
                        SUBTRACT 1 FROM WS-PAGINA
                    ELSE
                        MOVE 'YA ESTA EN PRIMERA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF8
                    IF WS-PAGINA < WS-PAGINA-MAX
                        ADD 1 TO WS-PAGINA
                    ELSE
                        MOVE 'YA ESTA EN ULTIMA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'ACTSTM00'
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO STM-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-ACTNBR
                    MOVE 0 TO WS-FECHA-DESDE
                               WS-FECHA-HASTA
                               WS-TRN-COUNT
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    MOVE 1 TO WS-PAGINA
                    GO TO STM-LOOP
       *
                WHEN OTHER
                    MOVE 'USE ENTER=GEN PF4=IMP PF7/PF8=PAG PF12=RET'
                      TO WS-MENSAJE-ERROR
                    GO TO STM-LOOP
            END-EVALUATE.
       *
        STM-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE CUENTA Y RANGO DE FECHAS, ENTER=GEN'
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
        4000-GENERAR-ESTADO.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            MOVE 0 TO WS-TRN-COUNT.
       *
            IF WS-ACTNBR = SPACES
                MOVE 'INGRESE NUMERO DE CUENTA' TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            IF WS-FECHA-DESDE = 0 OR WS-FECHA-HASTA = 0
                MOVE 'INGRESE FECHA DESDE Y HASTA' TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            IF WS-FECHA-DESDE > WS-FECHA-HASTA
                MOVE 'FECHA DESDE NO PUEDE SER MAYOR QUE HASTA'
                  TO WS-MENSAJE-ERROR
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
            CLOSE ACCOUNT-FILE.
       *
            OPEN I-O TRANLOG-FILE.
            IF FL-TRANLOG-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR TRANLOG' TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            MOVE WS-ACTNBR TO TRN-ACCOUNT-NBR.
            START TRANLOG-FILE KEY IS NOT < TRN-ACCOUNT-NBR
                INVALID KEY
                    MOVE 'NO HAY TRANSACCIONES' TO WS-MENSAJE-ERROR
                    CLOSE TRANLOG-FILE
                    GO TO 4000-EXIT
            END-START.
       *
            MOVE ZEROS TO WS-BALANCE-ACUM.
            MOVE 'N' TO WS-SWITCH-EOF.
            PERFORM UNTIL WS-EOF-YES
                READ TRANLOG-FILE NEXT RECORD
                    AT END
                        MOVE 'Y' TO WS-SWITCH-EOF
                        GO TO 4000-CONTINUE
                END-READ
       *
                IF TRN-ACCOUNT-NBR NOT = WS-ACTNBR
                    MOVE 'Y' TO WS-SWITCH-EOF
                    GO TO 4000-CONTINUE
                END-IF
       *
                IF TRN-DATE >= WS-FECHA-DESDE
                    AND TRN-DATE <= WS-FECHA-HASTA
                    ADD 1 TO WS-TRN-COUNT
                    MOVE TRN-DATE TO WS-TRN-FECHA(WS-TRN-COUNT)
                    MOVE TRN-TYPE TO WS-TRN-TIPO(WS-TRN-COUNT)
                    MOVE TRN-DESCRIPTION
                      TO WS-TRN-DESC(WS-TRN-COUNT)
                    MOVE TRN-AMOUNT
                      TO WS-TRN-MONTO(WS-TRN-COUNT)
                    COMPUTE WS-BALANCE-ACUM =
                        WS-BALANCE-ACUM + TRN-AMOUNT
                    MOVE WS-BALANCE-ACUM
                      TO WS-TRN-BAL(WS-TRN-COUNT)
                END-IF
       *
                IF WS-TRN-COUNT >= 100
                    MOVE 'Y' TO WS-SWITCH-EOF
                END-IF
            END-PERFORM.
       *
        4000-CONTINUE.
            CLOSE TRANLOG-FILE.
       *
            IF WS-TRN-COUNT = 0
                MOVE 'NO HAY TRANSACCIONES EN EL RANGO'
                  TO WS-MENSAJE-ERROR
            ELSE
                COMPUTE WS-PAGINA-MAX =
                    (WS-TRN-COUNT - 1) / WS-REG-POR-PAGINA + 1
                IF WS-PAGINA-MAX < 1
                    MOVE 1 TO WS-PAGINA-MAX
                END-IF
                STRING WS-TRN-COUNT ' TRANSACCION(ES) ENCONTRADAS'
                  INTO WS-MENSAJE
                PERFORM 4500-MOSTRAR-PAGINA
            END-IF.
        4000-EXIT.
            EXIT.
       *
        4500-MOSTRAR-PAGINA.
            COMPUTE WS-IND = (WS-PAGINA - 1) * WS-REG-POR-PAGINA + 1.
            MOVE 11 TO WS-LINEA.
       *
            PERFORM UNTIL WS-IND > WS-TRN-COUNT
                OR WS-LINEA > 21
                DISPLAY WS-TRN-FECHA(WS-IND)
                    AT LINE WS-LINEA COLUMN 05
                DISPLAY WS-TRN-TIPO(WS-IND)
                    AT LINE WS-LINEA COLUMN 15
                DISPLAY WS-TRN-DESC(WS-IND)(1:25)
                    AT LINE WS-LINEA COLUMN 22
                MOVE WS-TRN-MONTO(WS-IND) TO WS-BALANCE-DISP
                DISPLAY WS-BALANCE-DISP
                    AT LINE WS-LINEA COLUMN 50
                MOVE WS-TRN-BAL(WS-IND) TO WS-BALANCE-DISP
                DISPLAY WS-BALANCE-DISP
                    AT LINE WS-LINEA COLUMN 63
                ADD 1 TO WS-IND
                ADD 1 TO WS-LINEA
            END-PERFORM.
       *
            STRING 'PAGINA ' WS-PAGINA ' DE ' WS-PAGINA-MAX
              INTO WS-MENSAJE.
       *
        5000-IMPRIMIR.
            IF WS-TRN-COUNT = 0
                MOVE 'GENERE PRIMERO EL ESTADO DE CUENTA'
                  TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            PERFORM VARYING WS-IND FROM 1 BY 1
                UNTIL WS-IND > WS-TRN-COUNT
                DISPLAY 'FECHA:' WS-TRN-FECHA(WS-IND)
                        ' TIPO:' WS-TRN-TIPO(WS-IND)
                        ' MONTO:' WS-TRN-MONTO(WS-IND)
                        ' SALDO:' WS-TRN-BAL(WS-IND)
                    UPON PRINTER
            END-PERFORM.
       *
            MOVE 'IMPRESION ENVIADA A LA COLA DE SPOOL' TO WS-MENSAJE.
        5000-EXIT.
            EXIT.
       *
        END PROGRAM ACTSTM00.
