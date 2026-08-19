       *================================================================*
       * DEPSTM00 - ESTADO DE CUENTA DEPOSITO                         *
       * PROPOSITO: VISUALIZAR MOVIMIENTOS DE UN DEPOSITO POR RANGO   *
       * EQUIPO: AHORRO Y DEPOSITOS - 2003                            *
       * ARCHIVOS: DEPMAST, TRANLOG (LECTURA)                         *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. DEPSTM00.
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
                ALTERNATE RECORD KEY IS TRN-ACCOUNT-NBR
                    WITH DUPLICATES
                FILE STATUS IS FL-TRANLOG-STATUS.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'DEPSTM00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-DEPNBR                  PIC X(10).
            05  WS-DATE-FROM               PIC 9(08).
            05  WS-DATE-TO                 PIC 9(08).
            05  WS-TRN-COUNT               PIC 9(04).
            05  WS-TRN-PAGE                PIC 9(02) VALUE 1.
            05  WS-TRN-PAGE-MAX            PIC 9(02).
            05  WS-TRN-IND                 PIC 9(04).
            05  WS-TRN-DISP-IND            PIC 9(04).
            05  WS-TRN-LINE                PIC 9(02).
            05  WS-DUMMY                   PIC X(01).
            05  WS-AUDIT-DATA              PIC X(60).
       *
        01  WS-STATEMENT-TABLE.
            05  WS-STM-ENTRY               OCCURS 200.
                10  WS-STM-DATE            PIC 9(08).
                10  WS-STM-TYPE            PIC X(03).
                10  WS-STM-AMOUNT          PIC S9(13)V99 COMP-3.
                10  WS-STM-DESC            PIC X(30).
                10  WS-STM-STATUS          PIC X(01).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-STATEMENT.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' ESTADO DE CUENTA - DEPOSITOS'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-PARAMS.
                10  LINE 04  COL 05  PIC X(15) VALUE 'DEPOSITO:'.
                10  LINE 04  COL 22  PIC X(10)
                    USING WS-DEPNBR AUTO PROMPT '__________'.
                10  LINE 04  COL 40  PIC X(15) VALUE 'FECHA INI:'.
                10  LINE 04  COL 55  PIC 9(08)
                    USING WS-DATE-FROM AUTO.
                10  LINE 05  COL 05  PIC X(15) VALUE 'FECHA FIN:'.
                10  LINE 05  COL 22  PIC 9(08)
                    USING WS-DATE-TO AUTO.
                10  LINE 05  COL 45  PIC X(20) VALUE 'ENTER=GENERAR'.
       *
            05  SCR-HEADER.
                10  LINE 07  COL 05  PIC X(10) VALUE 'FECHA'.
                10  LINE 07  COL 20  PIC X(06) VALUE 'TIPO'.
                10  LINE 07  COL 30  PIC X(15) VALUE 'MONTO'.
                10  LINE 07  COL 50  PIC X(30) VALUE 'DESCRIPCION'.
                10  LINE 07  COL 75  PIC X(06) VALUE 'STATUS'.
                10  LINE 08  COL 05  PIC X(75) VALUE ALL '-'.
       *
            05  SCR-DETALLE              OCCURS 12.
                10  SCR-D-FECHA           PIC 9(08)
                    LINE 09 COL 05 FROM WS-STM-DATE.
                10  SCR-D-TIPO            PIC X(03)
                    LINE 09 COL 20 FROM WS-STM-TYPE.
                10  SCR-D-MONTO           PIC -(11)9.99
                    LINE 09 COL 30 FROM WS-STM-AMOUNT.
                10  SCR-D-DESC            PIC X(30)
                    LINE 09 COL 50 FROM WS-STM-DESC.
                10  SCR-D-STATUS          PIC X(01)
                    LINE 09 COL 75 FROM WS-STM-STATUS.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF4=IMPRIMIR  PF7=PANT  PF8=SIG  PF11=AYU'.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF12=RETORNAR'.
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
            MOVE 0 TO WS-DATE-FROM WS-DATE-TO
                      WS-TRN-COUNT WS-TRN-PAGE.
       *
            PERFORM 1000-INICIALIZAR.
       *
        STM-LOOP.
            PERFORM 2000-REFRESCAR.
            DISPLAY SCR-STATEMENT.
            ACCEPT SCR-STATEMENT.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 3000-GENERAR-ESTADO
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF4
                    PERFORM 4000-IMPRIMIR
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF7
                    IF WS-TRN-PAGE > 1
                        SUBTRACT 1 FROM WS-TRN-PAGE
                    ELSE
                        MOVE 'YA ESTA EN PRIMERA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF8
                    IF WS-TRN-PAGE < WS-TRN-PAGE-MAX
                        ADD 1 TO WS-TRN-PAGE
                    ELSE
                        MOVE 'YA ESTA EN ULTIMA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'DEPSTM00'
                    GO TO STM-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO STM-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-DEPNBR
                    MOVE 0 TO WS-DATE-FROM WS-DATE-TO
                              WS-TRN-COUNT WS-TRN-PAGE
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO STM-LOOP
       *
                WHEN OTHER
                    MOVE 'USE ENTER=GEN  PF4=IMP  PF7=ANT  PF8=SIG'
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
            MOVE 'INGRESE DEPOSITO Y RANGO DE FECHAS' TO WS-MENSAJE.
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
        3000-GENERAR-ESTADO.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            MOVE 0 TO WS-TRN-COUNT.
            MOVE 1 TO WS-TRN-PAGE.
       *
            IF WS-DEPNBR = SPACES
                MOVE 'INGRESE NUMERO DE DEPOSITO' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-DATE-FROM = 0 OR WS-DATE-TO = 0
                MOVE 'INGRESE RANGO DE FECHAS' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-DATE-FROM > WS-DATE-TO
                MOVE 'FECHA INICIO NO PUEDE SER MAYOR A FIN'
                  TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            OPEN I-O TRANLOG-FILE.
            IF FL-TRANLOG-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR TRANLOG' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE WS-DEPNBR TO TRN-ACCOUNT-NBR.
            START TRANLOG-FILE KEY IS NOT < TRN-ACCOUNT-NBR
                INVALID KEY
                    MOVE 'NO HAY MOVIMIENTOS PARA ESTE DEPOSITO'
                      TO WS-MENSAJE-ERROR
                    CLOSE TRANLOG-FILE
                    GOTO 3000-EXIT
            END-START.
       *
            MOVE 'N' TO WS-SWITCH-EOF.
            PERFORM UNTIL WS-EOF-YES
                READ TRANLOG-FILE NEXT RECORD
                    AT END
                        MOVE 'Y' TO WS-SWITCH-EOF
                        GOTO 3000-CONTINUE
                END-READ
       *
                IF TRN-ACCOUNT-NBR NOT = WS-DEPNBR
                    MOVE 'Y' TO WS-SWITCH-EOF
                    GOTO 3000-CONTINUE
                END-IF
       *
                IF TRN-DATE >= WS-DATE-FROM
                    AND TRN-DATE <= WS-DATE-TO
                    ADD 1 TO WS-TRN-COUNT
                    IF WS-TRN-COUNT <= 200
                        MOVE TRN-DATE
                          TO WS-STM-DATE(WS-TRN-COUNT)
                        MOVE TRN-TYPE
                          TO WS-STM-TYPE(WS-TRN-COUNT)
                        MOVE TRN-AMOUNT
                          TO WS-STM-AMOUNT(WS-TRN-COUNT)
                        MOVE TRN-DESCRIPTION
                          TO WS-STM-DESC(WS-TRN-COUNT)
                        MOVE TRN-STATUS
                          TO WS-STM-STATUS(WS-TRN-COUNT)
                    END-IF
                END-IF
            END-PERFORM.
       *
        3000-CONTINUE.
            CLOSE TRANLOG-FILE.
       *
            IF WS-TRN-COUNT = 0
                MOVE 'NO HAY MOVIMIENTOS EN EL RANGO SELECCIONADO'
                  TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            COMPUTE WS-TRN-PAGE-MAX =
                (WS-TRN-COUNT - 1) / 12 + 1.
            IF WS-TRN-PAGE-MAX < 1
                MOVE 1 TO WS-TRN-PAGE-MAX
            END-IF.
       *
            STRING WS-TRN-COUNT ' MOVIMIENTO(S) ENCONTRADOS'
              INTO WS-MENSAJE.
       *
            CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                  'DEPSTM00 GENERADO'.
        3000-EXIT.
            EXIT.
       *
        4000-IMPRIMIR.
            IF WS-TRN-COUNT = 0
                MOVE 'NO HAY DATOS PARA IMPRIMIR' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-DUMMY.
            DISPLAY 'ENVIANDO A IMPRESION... PRESIONE ENTER'
                AT LINE 23 COLUMN 05.
            ACCEPT WS-DUMMY AT LINE 23 COLUMN 45.
            MOVE 'IMPRESION ENVIADA A SPOOL' TO WS-MENSAJE.
        4000-EXIT.
            EXIT.
       *
        END PROGRAM DEPSTM00.
