       *================================================================*
       * LONDEL00 - GESTION DE MORA / CASTIGO                          *
       * PROPOSITO: ADMINISTRAR PRESTAMOS VENCIDOS, CASTIGO, LEGAL     *
       * EQUIPO: CREDITO Y COBRANZA - 2005                             *
       * ARCHIVOS: LOANMAST                                             *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. LONDEL00.
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
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  LOANMAST-FILE
            RECORD 350 CHARACTERS.
        COPY FD-LOANMAST REPLACING LOANMAST-FILE BY LOANMAST-FILE
                LOANMAST-RECORD BY LOANMAST-RECORD.
       *================================================================*
        WORKING-STORAGE SECTION.
        COPY CPY-COMMON.
        COPY CPY-SCREEN.
       *
        01  WS-CRT-STATUS                  PIC 9(04).
            88  WS-CRT-PF1                VALUE 1001.
            88  WS-CRT-PF2                VALUE 1002.
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
            05  WS-LOAN-NBR                PIC X(10).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-ACCION                  PIC X(01).
                88  WS-ACC-RESTRUCTURAR    VALUE 'R'.
                88  WS-ACC-CASTIGAR        VALUE 'C'.
                88  WS-ACC-LEGAL           VALUE 'L'.
            05  WS-ACCION-DISP             PIC X(01).
            05  WS-RESTRUCT-TERM           PIC 9(04).
            05  WS-RESTRUCT-TERM-DISP      PIC 9(04).
            05  WS-RESTRUCT-RATE           PIC 9(03)V9(04) COMP-3.
            05  WS-RESTRUCT-RATE-DISP      PIC 9(03).9(04).
            05  WS-OBSERVACIONES           PIC X(60).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-I                       PIC 9(04).
            05  WS-K                       PIC 9(04).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'LONDEL00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-BUSQUEDA.
            05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - GESTION DE MORA'.
            05  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
            05  LINE 02  COL 01  PIC X(80)
               VALUE ' INGRESE NUMERO DE PRESTAMO:'.
            05  LINE 02  COL 32  PIC X(10)
               USING WS-LOAN-NBR AUTO PROMPT '__________'.
            05  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
            05  LINE 24  COL 05  PIC X(60)
               VALUE 'ENTER=CONSULTAR  PF12=SALIR'.
       *
        01  SCR-DELINCUENCIA.
            05  SCR-CAB.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - GESTION DE DELINCUENCIA'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
       *
            05  SCR-CUERPO.
                10  LINE 03  COL 02  PIC X(15) VALUE 'PRESTAMO:'.
                10  LINE 03  COL 15  PIC X(10) FROM LON-NBR.
                10  LINE 03  COL 30  PIC X(15) VALUE 'CLIENTE:'.
                10  LINE 03  COL 45  PIC X(10) FROM LON-CUSTOMER-ID.
       *
                10  LINE 04  COL 02  PIC X(15) VALUE 'SALDO ACTUAL:'.
                10  LINE 04  COL 18  PIC Z(12)9.99 FROM LON-BALANCE.
                10  LINE 04  COL 45  PIC X(15) VALUE 'VENCIDO:'.
                10  LINE 04  COL 60  PIC Z(12)9.99 FROM LON-BALANCE-PAST-DUE.
       *
                10  LINE 05  COL 02  PIC X(15) VALUE 'CUOTAS VENC:'.
                10  LINE 05  COL 18  PIC 9(04) FROM LON-PAYMENTS-OVERDUE.
                10  LINE 05  COL 35  PIC X(15) VALUE 'CLASIF:'.
                10  LINE 05  COL 50  PIC X(01) FROM LON-CLASSIFICATION.
                10  LINE 05  COL 55  PIC X(15) VALUE 'ESTATUS:'.
                10  LINE 05  COL 65  PIC X(01) FROM LON-STATUS.
       *
                10  LINE 07  COL 02  PIC X(30)
                   VALUE 'ACCION (R=REESTR C=CASTIGO L=LEGAL):'.
                10  LINE 07  COL 35  PIC X(01)
                   USING WS-ACCION-DISP AUTO PROMPT '_'.
       *
                10  LINE 09  COL 02  PIC X(20)
                   VALUE 'NUEVO PLAZO (MES):'.
                10  LINE 09  COL 22  PIC 9(04)
                   USING WS-RESTRUCT-TERM-DISP AUTO PROMPT '____'.
                10  LINE 10  COL 02  PIC X(20) VALUE 'NUEVA TASA:'.
                10  LINE 10  COL 22  PIC 9(03).9(04)
                   USING WS-RESTRUCT-RATE-DISP AUTO PROMPT '____.____'.
       *
                10  LINE 12  COL 02  PIC X(20) VALUE 'OBSERVACIONES:'.
                10  LINE 12  COL 20  PIC X(60)
                   USING WS-OBSERVACIONES AUTO PROMPT
                   '...........................................................
      -    '...'.
       *
            05  SCR-CUOTAS-VENCIDAS.
                10  LINE 14  COL 02  PIC X(50)
                   VALUE 'CUOTAS VENCIDAS:'.
       *
            05  SCR-MSG.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'ENTER=PROCESAR  PF12=CANCELAR'.
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
                    PERFORM 4000-PROCESAR-ACCION
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
            OPEN I-O LOANMAST-FILE.
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
            MOVE 00 TO LS-RETCODE.
            MOVE 'PRESTAMO ENCONTRADO' TO WS-MENSAJE.
            MOVE LON-TERM-MONTHS TO WS-RESTRUCT-TERM.
            MOVE LON-TERM-MONTHS TO WS-RESTRUCT-TERM-DISP.
            MOVE LON-INTEREST-RATE TO WS-RESTRUCT-RATE.
            MOVE LON-INTEREST-RATE TO WS-RESTRUCT-RATE-DISP.
       *
        3000-EXIT.
            EXIT.
       *
        4000-PROCESAR-ACCION.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            PERFORM 5000-MOSTRAR-VENCIDAS.
            DISPLAY SCR-DELINCUENCIA.
            ACCEPT SCR-DELINCUENCIA.
       *
            IF WS-CRT-PF12
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-CRT-CLEAR
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE WS-ACCION-DISP TO WS-ACCION.
       *
            IF WS-ACC-RESTRUCTURAR
                MOVE WS-RESTRUCT-TERM-DISP TO WS-RESTRUCT-TERM
                MOVE WS-RESTRUCT-RATE-DISP TO WS-RESTRUCT-RATE
                IF WS-RESTRUCT-TERM = ZERO
                    MOVE 'PLAZO INVALIDO' TO WS-MENSAJE-ERROR
                    GO TO 4000-PROCESAR-ACCION
                END-IF
                PERFORM 6000-CONFIRMAR
                IF WS-CONFIRMA = 'S'
                    PERFORM 7000-RESTRUCTURAR
                END-IF
            ELSE
                IF WS-ACC-CASTIGAR
                    PERFORM 6000-CONFIRMAR
                    IF WS-CONFIRMA = 'S'
                        PERFORM 8000-CASTIGAR
                    END-IF
                ELSE
                    IF WS-ACC-LEGAL
                        PERFORM 6000-CONFIRMAR
                        IF WS-CONFIRMA = 'S'
                            PERFORM 9000-LEGAL
                        END-IF
                    ELSE
                        MOVE 'ACCION INVALIDA (R/C/L)'
                          TO WS-MENSAJE-ERROR
                        GO TO 4000-PROCESAR-ACCION
                    END-IF
                END-IF
            END-IF.
       *
            IF WS-RETCODE = 00
                PERFORM 9500-AUDITAR
                MOVE 'OPERACION REALIZADA' TO WS-MENSAJE
            END-IF.
       *
        4000-EXIT.
            EXIT.
       *
        5000-MOSTRAR-VENCIDAS.
            MOVE 1 TO WS-I.
            MOVE 15 TO WS-K.
            DISPLAY 'CUOTAS VENCIDAS:' AT LINE 14 COLUMN 02.
            PERFORM UNTIL WS-I > LON-PAYMENTS-TOTAL
                OR WS-K > 21
                IF LON-INST-STATUS(WS-I) = 'V'
                    DISPLAY LON-INST-NBR(WS-I)
                      AT LINE WS-K COLUMN 05
                    DISPLAY LON-INST-DUE-DATE(WS-I)
                      AT LINE WS-K COLUMN 10
                    DISPLAY LON-INST-AMOUNT(WS-I)
                      AT LINE WS-K COLUMN 20
                    ADD 1 TO WS-K
                END-IF
                ADD 1 TO WS-I
            END-PERFORM.
       *
        6000-CONFIRMAR.
            CALL 'COMMSGF' USING 'Q001'
                                 'CONFIRMA OPERACION?'
                                 'Q'
                                 WS-CONFIRMA.
       *
        7000-RESTRUCTURAR.
            MOVE WS-LOAN-NBR TO LON-NBR.
            READ LOANMAST-FILE KEY IS LON-NBR
                INVALID KEY
                    MOVE 'ERROR LEYENDO' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7000-EXIT
            END-READ.
       *
            MOVE WS-RESTRUCT-TERM TO LON-TERM-MONTHS.
            MOVE WS-RESTRUCT-RATE TO LON-INTEREST-RATE.
            MOVE 'R' TO LON-STATUS.
            MOVE '2' TO LON-CLASSIFICATION.
            MOVE WS-FECHA TO LON-DATE-LAST-MOD.
            MOVE WS-USUARIO TO LON-USER-LAST-MOD.
       *
            REWRITE LOANMAST-RECORD
                INVALID KEY
                    MOVE 'ERROR AL REESTRUCTURAR'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 7000-EXIT
            END-REWRITE.
       *
            MOVE 00 TO LS-RETCODE.
            STRING 'RESTRUCTURA ' WS-LOAN-NBR
              INTO WS-AUDIT-INFO.
        7000-EXIT.
            EXIT.
       *
        8000-CASTIGAR.
            MOVE WS-LOAN-NBR TO LON-NBR.
            READ LOANMAST-FILE KEY IS LON-NBR
                INVALID KEY
                    MOVE 'ERROR LEYENDO' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 8000-EXIT
            END-READ.
       *
            MOVE 'C' TO LON-STATUS.
            MOVE '4' TO LON-CLASSIFICATION.
            MOVE ZERO TO LON-BALANCE.
            MOVE ZERO TO LON-BALANCE-PAST-DUE.
            MOVE WS-FECHA TO LON-DATE-LAST-MOD.
            MOVE WS-USUARIO TO LON-USER-LAST-MOD.
       *
            PERFORM VARYING WS-I FROM 1 BY 1
                UNTIL WS-I > LON-PAYMENTS-TOTAL
                MOVE 'C' TO LON-INST-STATUS(WS-I)
            END-PERFORM.
       *
            REWRITE LOANMAST-RECORD
                INVALID KEY
                    MOVE 'ERROR AL CASTIGAR'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 8000-EXIT
            END-REWRITE.
       *
            MOVE 00 TO LS-RETCODE.
            STRING 'CASTIGO ' WS-LOAN-NBR INTO WS-AUDIT-INFO.
        8000-EXIT.
            EXIT.
       *
        9000-LEGAL.
            MOVE WS-LOAN-NBR TO LON-NBR.
            READ LOANMAST-FILE KEY IS LON-NBR
                INVALID KEY
                    MOVE 'ERROR LEYENDO' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 9000-EXIT
            END-READ.
       *
            MOVE 'L' TO LON-STATUS.
            MOVE '3' TO LON-CLASSIFICATION.
            MOVE WS-FECHA TO LON-DATE-LAST-MOD.
            MOVE WS-USUARIO TO LON-USER-LAST-MOD.
       *
            REWRITE LOANMAST-RECORD
                INVALID KEY
                    MOVE 'ERROR AL MARCAR LEGAL'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 9000-EXIT
            END-REWRITE.
       *
            MOVE 00 TO LS-RETCODE.
            STRING 'LEGAL ' WS-LOAN-NBR INTO WS-AUDIT-INFO.
        9000-EXIT.
            EXIT.
       *
        9500-AUDITAR.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
       *
        9900-FINALIZAR.
            CLOSE LOANMAST-FILE.
            GOBACK.
       *
        END PROGRAM LONDEL00.
