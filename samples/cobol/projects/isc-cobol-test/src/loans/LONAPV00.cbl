       *================================================================*
       * LONAPV00 - APROBACION DE PRESTAMO                             *
       * PROPOSITO: REVISAR, APROBAR O RECHAZAR SOLICITUD              *
       * EQUIPO: CREDITO Y COBRANZA - 2004                             *
       * ARCHIVOS: LOANAPPL                                             *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. LONAPV00.
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
            SELECT LOANAPPL-FILE
                ASSIGN TO 'LOANAPPL.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS LAP-APPL-ID
                FILE STATUS IS FL-LOANAPPL-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  LOANAPPL-FILE
            RECORD 280 CHARACTERS.
        COPY FD-LOANAPPL REPLACING LOANAPPL-FILE BY LOANAPPL-FILE
                LOANAPPL-RECORD BY LOANAPPL-RECORD.
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
            05  WS-APPL-ID                 PIC X(10).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-ACCION                  PIC X(01).
                88  WS-APROBAR             VALUE 'A'.
                88  WS-RECHAZAR            VALUE 'R'.
            05  WS-ACCION-DISP             PIC X(01).
            05  WS-APROB-AMOUNT            PIC 9(13)V99 COMP-3.
            05  WS-APROB-AMOUNT-DISP       PIC Z(12)9.99.
            05  WS-APROB-RATE              PIC 9(03)V9(04) COMP-3.
            05  WS-APROB-RATE-DISP         PIC 9(03).9(04).
            05  WS-APROB-TERM              PIC 9(04).
            05  WS-APROB-TERM-DISP         PIC 9(04).
            05  WS-OBSERVACIONES           PIC X(60).
            05  WS-CONFIRMA                PIC X(01).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'LONAPV00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-BUSQUEDA.
            05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - APROBACION DE PRESTAMO'.
            05  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
            05  LINE 02  COL 01  PIC X(80)
               VALUE ' APROBACION / RECHAZO DE SOLICITUD'.
            05  LINE 04  COL 05  PIC X(25) VALUE 'ID SOLICITUD:'.
            05  LINE 04  COL 22  PIC X(10)
               USING WS-APPL-ID AUTO PROMPT '__________'.
            05  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
            05  LINE 24  COL 05  PIC X(60)
               VALUE 'ENTER=CONSULTAR  PF12=SALIR'.
       *
        01  SCR-APROBACION.
            05  SCR-CAB.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - DETALLE SOLICITUD'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' '.
       *
            05  SCR-CUERPO.
                10  LINE 03  COL 05  PIC X(15) VALUE 'SOLICITUD:'.
                10  LINE 03  COL 20  PIC X(10) FROM LAP-APPL-ID.
                10  LINE 03  COL 35  PIC X(15) VALUE 'CLIENTE:'.
                10  LINE 03  COL 50  PIC X(10) FROM LAP-CUSTOMER-ID.
       *
                10  LINE 04  COL 05  PIC X(15) VALUE 'TIPO:'.
                10  LINE 04  COL 15  PIC X(02) FROM LAP-TYPE.
                10  LINE 04  COL 25  PIC X(15) VALUE 'MONTO SOL:'.
                10  LINE 04  COL 40  PIC Z(12)9.99 FROM LAP-AMOUNT-REQUESTED.
                10  LINE 04  COL 60  PIC X(15) VALUE 'PLAZO:'.
                10  LINE 04  COL 70  PIC 9(04) FROM LAP-TERM-MONTHS.
       *
                10  LINE 05  COL 05  PIC X(15) VALUE 'SCORE:'.
                10  LINE 05  COL 15  PIC 9(03) FROM LAP-SCORE.
                10  LINE 05  COL 25  PIC X(15) VALUE 'INGRESO:'.
                10  LINE 05  COL 40  PIC Z(08)9.99 FROM LAP-INGRESO-MENSUAL.
                10  LINE 05  COL 60  PIC X(15) VALUE 'EGRESOS:'.
                10  LINE 05  COL 72  PIC Z(08)9.99 FROM LAP-EGRESOS-MENSUALES.
       *
                10  LINE 06  COL 05  PIC X(15) VALUE 'ESTATUS:'.
                10  LINE 06  COL 15  PIC X(01) FROM LAP-STATUS.
                10  LINE 06  COL 25  PIC X(15) VALUE 'FECHA SOL:'.
                10  LINE 06  COL 40  PIC 9(08) FROM LAP-FECHA-SOLICITUD.
       *
                10  LINE 08  COL 05  PIC X(25) VALUE 'ACCION (A=APROB R=RECH):'.
                10  LINE 08  COL 35  PIC X(01)
                   USING WS-ACCION-DISP AUTO PROMPT '_'.
       *
                10  LINE 10  COL 05  PIC X(20) VALUE 'MONTO APROBADO:'.
                10  LINE 10  COL 22  PIC Z(12)9.99
                   USING WS-APROB-AMOUNT-DISP AUTO PROMPT '____________.__'.
                10  LINE 11  COL 05  PIC X(20) VALUE 'TASA INTERES:'.
                10  LINE 11  COL 22  PIC 9(03).9(04)
                   USING WS-APROB-RATE-DISP AUTO PROMPT '____.____'.
                10  LINE 12  COL 05  PIC X(20) VALUE 'PLAZO (MESES):'.
                10  LINE 12  COL 22  PIC 9(04)
                   USING WS-APROB-TERM-DISP AUTO PROMPT '____'.
       *
                10  LINE 14  COL 05  PIC X(20) VALUE 'OBSERVACIONES:'.
                10  LINE 14  COL 20  PIC X(60)
                   USING WS-OBSERVACIONES AUTO PROMPT
                   '...........................................................
      -    '...'.
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
                    PERFORM 4000-PROCESAR-APROBACION
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
            OPEN I-O LOANAPPL-FILE.
            MOVE 'INGRESE ID DE SOLICITUD' TO WS-MENSAJE.
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
            MOVE WS-APPL-ID TO LAP-APPL-ID.
            READ LOANAPPL-FILE KEY IS LAP-APPL-ID
                INVALID KEY
                    MOVE 'SOLICITUD NO ENCONTRADA'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 3000-EXIT
            END-READ.
       *
            IF LAP-STATUS-BORRADOR OR LAP-STATUS-EN-REVISION
                MOVE 'SOLICITUD ENCONTRADA' TO WS-MENSAJE
                MOVE 00 TO LS-RETCODE
            ELSE
                MOVE 'SOLICITUD YA PROCESADA (EST:'
                  TO WS-MENSAJE-ERROR
                MOVE 99 TO LS-RETCODE
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE LAP-AMOUNT-REQUESTED TO WS-APROB-AMOUNT.
            MOVE LAP-AMOUNT-REQUESTED TO WS-APROB-AMOUNT-DISP.
            MOVE LAP-TERM-MONTHS TO WS-APROB-TERM.
            MOVE LAP-TERM-MONTHS TO WS-APROB-TERM-DISP.
            MOVE LAP-PROPOSED-RATE TO WS-APROB-RATE.
            MOVE LAP-PROPOSED-RATE TO WS-APROB-RATE-DISP.
            MOVE LAP-OBSERVACIONES TO WS-OBSERVACIONES.
       *
        3000-EXIT.
            EXIT.
       *
        4000-PROCESAR-APROBACION.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            DISPLAY SCR-APROBACION.
            ACCEPT SCR-APROBACION.
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
            IF WS-APROBAR
                MOVE WS-APROB-AMOUNT-DISP TO WS-APROB-AMOUNT
                MOVE WS-APROB-RATE-DISP TO WS-APROB-RATE
                MOVE WS-APROB-TERM-DISP TO WS-APROB-TERM
                IF WS-APROB-AMOUNT = ZERO
                    MOVE 'MONTO APROBADO INVALIDO'
                      TO WS-MENSAJE-ERROR
                    GO TO 4000-PROCESAR-APROBACION
                END-IF
                IF WS-APROB-RATE = ZERO
                    MOVE 'TASA DE INTERES REQUERIDA'
                      TO WS-MENSAJE-ERROR
                    GO TO 4000-PROCESAR-APROBACION
                END-IF
                PERFORM 5000-CONFIRMAR-APROBAR
                IF WS-CONFIRMA = 'S'
                    PERFORM 6000-APROBAR
                END-IF
            ELSE
                IF WS-RECHAZAR
                    PERFORM 5000-CONFIRMAR-APROBAR
                    IF WS-CONFIRMA = 'S'
                        PERFORM 7000-RECHAZAR
                    END-IF
                ELSE
                    MOVE 'ACCION INVALIDA (A/R)'
                      TO WS-MENSAJE-ERROR
                    GO TO 4000-PROCESAR-APROBACION
                END-IF
            END-IF.
       *
        4000-EXIT.
            EXIT.
       *
        5000-CONFIRMAR-APROBAR.
            CALL 'COMMSGF' USING 'Q001'
                                 'CONFIRMA LA OPERACION?'
                                 'Q'
                                 WS-CONFIRMA.
       *
        6000-APROBAR.
            MOVE WS-APPL-ID TO LAP-APPL-ID.
            READ LOANAPPL-FILE KEY IS LAP-APPL-ID
                INVALID KEY
                    MOVE 'ERROR LEYENDO SOLICITUD'
                      TO WS-MENSAJE-ERROR
                    GOTO 6000-EXIT
            END-READ.
       *
            MOVE 'A' TO LAP-STATUS.
            MOVE WS-FECHA TO LAP-FECHA-APROBACION.
            MOVE WS-USUARIO TO LAP-USUARIO-APRUEBA.
            MOVE WS-APROB-AMOUNT TO LAP-AMOUNT-REQUESTED.
            MOVE WS-APROB-RATE TO LAP-PROPOSED-RATE.
            MOVE WS-APROB-TERM TO LAP-TERM-MONTHS.
            MOVE WS-OBSERVACIONES TO LAP-OBSERVACIONES.
            ADD 10 TO LAP-SCORE.
       *
            REWRITE LOANAPPL-RECORD
                INVALID KEY
                    MOVE 'ERROR AL APROBAR SOLICITUD'
                      TO WS-MENSAJE-ERROR
                    GOTO 6000-EXIT
            END-REWRITE.
       *
            MOVE 00 TO LS-RETCODE.
            STRING 'APROBADA SOLICITUD ' LAP-APPL-ID
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
            MOVE 'SOLICITUD APROBADA EXITOSAMENTE' TO WS-MENSAJE.
       *
        6000-EXIT.
            EXIT.
       *
        7000-RECHAZAR.
            MOVE WS-APPL-ID TO LAP-APPL-ID.
            READ LOANAPPL-FILE KEY IS LAP-APPL-ID
                INVALID KEY
                    MOVE 'ERROR LEYENDO' TO WS-MENSAJE-ERROR
                    GOTO 7000-EXIT
            END-READ.
       *
            MOVE 'Z' TO LAP-STATUS.
            MOVE WS-FECHA TO LAP-FECHA-APROBACION.
            MOVE WS-USUARIO TO LAP-USUARIO-APRUEBA.
            MOVE WS-OBSERVACIONES TO LAP-OBSERVACIONES.
       *
            REWRITE LOANAPPL-RECORD
                INVALID KEY
                    MOVE 'ERROR AL RECHAZAR' TO WS-MENSAJE-ERROR
                    GOTO 7000-EXIT
            END-REWRITE.
       *
            MOVE 00 TO LS-RETCODE.
            STRING 'RECHAZADA SOLICITUD ' LAP-APPL-ID
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
            MOVE 'SOLICITUD RECHAZADA' TO WS-MENSAJE.
       *
        7000-EXIT.
            EXIT.
       *
        9000-FINALIZAR.
            CLOSE LOANAPPL-FILE.
            GOBACK.
       *
        END PROGRAM LONAPV00.
