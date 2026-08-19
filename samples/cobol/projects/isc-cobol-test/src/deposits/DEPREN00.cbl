       *================================================================*
       * DEPREN00 - RENOVACION AUTOMATICA DE DEPOSITOS                 *
       * PROPOSITO: PROCESAR RENOVACION DE DEPOSITOS VENCIDOS          *
       * EQUIPO: AHORRO Y DEPOSITOS - 2004                            *
       * ARCHIVOS: DEPMAST, TRANLOG                                   *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. DEPREN00.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'DEPREN00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-DEP-COUNT               PIC 9(04).
            05  WS-REN-COUNT               PIC 9(04).
            05  WS-PROCESADOS              PIC 9(04).
            05  WS-CONFIRM                 PIC X(01).
            05  WS-AUDIT-DATA              PIC X(60).
            05  WS-TRN-SEQ-AUX             PIC 9(10).
            05  WS-INTEREST-CALC           PIC 9(13)V99 COMP-3.
       *
        01  WS-DEP-LIST.
            05  WS-DEP-ENTRY               OCCURS 50.
                10  WS-DEP-NBR-ENT         PIC X(10).
                10  WS-DEP-CUS-ENT         PIC X(10).
                10  WS-DEP-BAL-ENT         PIC 9(13)V99 COMP-3.
                10  WS-DEP-MAT-ENT         PIC 9(08).
                10  WS-DEP-TERM-ENT        PIC 9(04).
                10  WS-DEP-SEL             PIC X(01).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-RENOVACION.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' RENOVACION AUTOMATICA DE DEPOSITOS'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ACCION.
                10  LINE 04  COL 05  PIC X(60)
                    VALUE 'PF1=SCAN (BUSCAR VENCIDOS)  PF2=PROCESAR'.
       *
            05  SCR-LISTA-HEADER.
                10  LINE 06  COL 05  PIC X(04) VALUE 'SEL'.
                10  LINE 06  COL 10  PIC X(10) VALUE 'DEPOSITO'.
                10  LINE 06  COL 22  PIC X(10) VALUE 'CLIENTE'.
                10  LINE 06  COL 35  PIC X(12) VALUE 'SALDO'.
                10  LINE 06  COL 50  PIC X(10) VALUE 'VCTO'.
                10  LINE 07  COL 05  PIC X(70) VALUE ALL '-'.
       *
            05  SCR-LISTA                  OCCURS 12.
                10  SCR-L-SEL              PIC X(01)
                    LINE 08 COL 05 FROM WS-DEP-SEL.
                10  SCR-L-NBR              PIC X(10)
                    LINE 08 COL 10 FROM WS-DEP-NBR-ENT.
                10  SCR-L-CUS              PIC X(10)
                    LINE 08 COL 22 FROM WS-DEP-CUS-ENT.
                10  SCR-L-BAL              PIC -(11)9.99
                    LINE 08 COL 35 FROM WS-DEP-BAL-ENT.
                10  SCR-L-MAT              PIC 9(08)
                    LINE 08 COL 50 FROM WS-DEP-MAT-ENT.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF1=SCAN  PF2=PROC  PF11=AYU  PF12=RET'.
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
            MOVE 0 TO WS-DEP-COUNT WS-REN-COUNT WS-PROCESADOS.
       *
            PERFORM 1000-INICIALIZAR.
       *
        REN-LOOP.
            PERFORM 2000-REFRESCAR.
            DISPLAY SCR-RENOVACION.
            ACCEPT SCR-RENOVACION.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    PERFORM 3000-SCAN-DEPOSITOS
                    GO TO REN-LOOP
       *
                WHEN WS-CRT-PF2
                    IF WS-DEP-COUNT = 0
                        MOVE 'PRIMERO EJECUTE SCAN (PF1)'
                          TO WS-MENSAJE-ERROR
                    ELSE
                        PERFORM 4000-PROCESAR-RENOVACION
                    END-IF
                    GO TO REN-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'DEPREN00'
                    GO TO REN-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO REN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE 0 TO WS-DEP-COUNT
                              WS-REN-COUNT
                              WS-PROCESADOS
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO REN-LOOP
       *
                WHEN OTHER
                    MOVE 'PF1=SCAN  PF2=PROCESAR  PF12=RET'
                      TO WS-MENSAJE-ERROR
                    GO TO REN-LOOP
            END-EVALUATE.
       *
        REN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'PF1=SCAN PARA BUSCAR DEPOSITOS VENCIDOS'
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
        3000-SCAN-DEPOSITOS.
            MOVE 0 TO WS-DEP-COUNT.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            OPEN I-O DEPMAST-FILE.
            IF FL-DEPMAST-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR DEPMAST' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE SPACES TO DEP-NBR.
            START DEPMAST-FILE KEY IS NOT < DEP-NBR
                INVALID KEY
                    MOVE 'NO HAY DEPOSITOS REGISTRADOS'
                      TO WS-MENSAJE-ERROR
                    CLOSE DEPMAST-FILE
                    GOTO 3000-EXIT
            END-START.
       *
            MOVE 'N' TO WS-SWITCH-EOF.
            PERFORM UNTIL WS-EOF-YES
                READ DEPMAST-FILE NEXT RECORD
                    AT END
                        MOVE 'Y' TO WS-SWITCH-EOF
                        GOTO 3000-CONTINUE
                END-READ
       *
                IF DEP-RENEWAL-AUTO-YES
                    AND DEP-STATUS-ACTIVE
                    AND DEP-DATE-MATURITY <= WS-FECHA
                    ADD 1 TO WS-DEP-COUNT
                    IF WS-DEP-COUNT <= 50
                        MOVE DEP-NBR
                          TO WS-DEP-NBR-ENT(WS-DEP-COUNT)
                        MOVE DEP-CUSTOMER-ID
                          TO WS-DEP-CUS-ENT(WS-DEP-COUNT)
                        MOVE DEP-BALANCE
                          TO WS-DEP-BAL-ENT(WS-DEP-COUNT)
                        MOVE DEP-DATE-MATURITY
                          TO WS-DEP-MAT-ENT(WS-DEP-COUNT)
                        MOVE DEP-TERM-DAYS
                          TO WS-DEP-TERM-ENT(WS-DEP-COUNT)
                        MOVE 'N' TO WS-DEP-SEL(WS-DEP-COUNT)
                    END-IF
                END-IF
            END-PERFORM.
       *
        3000-CONTINUE.
            CLOSE DEPMAST-FILE.
       *
            IF WS-DEP-COUNT = 0
                MOVE 'NO HAY DEPOSITOS VENCIDOS CON AUTO-RENOVACION'
                  TO WS-MENSAJE-ERROR
            ELSE
                STRING WS-DEP-COUNT ' DEPOSITO(S) VENCIDO(S)'
                  INTO WS-MENSAJE
            END-IF.
        3000-EXIT.
            EXIT.
       *
        4000-PROCESAR-RENOVACION.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            MOVE 0 TO WS-PROCESADOS.
       *
            MOVE SPACES TO WS-CONFIRM.
            DISPLAY 'PROCESAR RENOVACION DE ' WS-DEP-COUNT
                    ' DEPOSITO(S)? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRM AT LINE 23 COLUMN 50.
            IF WS-CONFIRM NOT = 'S' AND NOT = 's'
                MOVE 'RENOVACION CANCELADA' TO WS-MENSAJE
                GOTO 4000-EXIT
            END-IF.
       *
            OPEN I-O DEPMAST-FILE.
            IF FL-DEPMAST-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR DEPMAST' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            PERFORM VARYING WS-REN-COUNT FROM 1 BY 1
                UNTIL WS-REN-COUNT > WS-DEP-COUNT
       *
                MOVE WS-DEP-NBR-ENT(WS-REN-COUNT) TO DEP-NBR
                READ DEPMAST-FILE KEY IS DEP-NBR
                    INVALID KEY
                        GOTO 4100-CONTINUAR
                END-READ
       *
                IF FL-DEPMAST-STATUS NOT = '00'
                    GOTO 4100-CONTINUAR
                END-IF
       *
                COMPUTE WS-INTEREST-CALC =
                    DEP-BALANCE * DEP-INTEREST-RATE / 100
                    * DEP-TERM-DAYS / 360.
       *
                ADD WS-INTEREST-CALC TO DEP-BALANCE.
                ADD 1 TO DEP-RENEWAL-COUNT.
       *
                CALL 'COMDATE' USING 'ADD'
                                     WS-FECHA
                                     WS-DEP-TERM-ENT(WS-REN-COUNT).
                MOVE WS-FECHA TO DEP-DATE-MATURITY.
                MOVE WS-FECHA TO DEP-DATE-LAST-INT.
                MOVE WS-FECHA TO DEP-DATE-LAST-TXN.
                MOVE 'M' TO DEP-STATUS.
       *
                REWRITE DEPMAST-RECORD
                    INVALID KEY
                        GOTO 4100-CONTINUAR
                END-REWRITE.
       *
                PERFORM 5000-ESCRIBIR-TRANLOG.
                ADD 1 TO WS-PROCESADOS.
       *
        4100-CONTINUAR.
                CONTINUE.
            END-PERFORM.
       *
            CLOSE DEPMAST-FILE.
       *
            STRING WS-PROCESADOS ' DE ' WS-DEP-COUNT
                   ' RENOVADOS EXITOSAMENTE'
              INTO WS-MENSAJE.
       *
            STRING 'DEPREN00 PROC=' WS-PROCESADOS ' TOTAL='
                   WS-DEP-COUNT
              INTO WS-AUDIT-DATA.
            CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                  WS-AUDIT-DATA.
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
            MOVE 'INT' TO TRN-TYPE.
            MOVE DEP-NBR TO TRN-ACCOUNT-NBR.
            MOVE SPACES TO TRN-ACCOUNT-DEST.
            MOVE DEP-CUSTOMER-ID TO TRN-CUSTOMER-ID.
            MOVE WS-INTEREST-CALC TO TRN-AMOUNT.
            MOVE 0 TO TRN-AMOUNT-TAX.
            MOVE WS-INTEREST-CALC TO TRN-AMOUNT-TOTAL.
            MOVE WS-INTEREST-CALC TO TRN-AMOUNT-ORIGINAL.
            MOVE 0 TO TRN-FEE-AMOUNT.
            MOVE SPACES TO TRN-FEE-CODE.
            MOVE DEP-BRANCH TO TRN-BRANCH.
            MOVE SPACES TO TRN-TELLER-ID.
            MOVE WS-USUARIO-ID TO TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '04' TO TRN-CHANNEL.
            MOVE SPACES TO TRN-REFERENCE.
            MOVE 0 TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE 0 TO TRN-REVERSE-SEQ.
            MOVE 'RENOVACION + INTERESES' TO TRN-DESCRIPTION.
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
        END PROGRAM DEPREN00.
