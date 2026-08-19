       *================================================================*
       * LONAPL00 - SOLICITUD DE PRESTAMO                              *
       * PROPOSITO: CAPTURAR SOLICITUD, CALCULAR SCORING, GUARDAR      *
       * EQUIPO: CREDITO Y COBRANZA - 2004                             *
       * ARCHIVOS: LOANAPPL, CUSTOMER                                   *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. LONAPL00.
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
       *
            SELECT CUSTOMER-FILE
                ASSIGN TO 'CUSTOMER.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS CUS-ID
                FILE STATUS IS FL-CUSTOMER-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  LOANAPPL-FILE
            RECORD 280 CHARACTERS.
        COPY FD-LOANAPPL REPLACING LOANAPPL-FILE BY LOANAPPL-FILE
                LOANAPPL-RECORD BY LOANAPPL-RECORD.
       *
        FD  CUSTOMER-FILE
            RECORD 300 CHARACTERS.
        COPY FD-CUSTOMER REPLACING CUSTOMER-FILE BY CUSTOMER-FILE
                CUSTOMER-RECORD BY CUSTOMER-RECORD.
       *================================================================*
        WORKING-STORAGE SECTION.
        COPY CPY-COMMON.
        COPY CPY-SCREEN.
       *
        01  WS-CRT-STATUS                  PIC 9(04).
            88  WS-CRT-PF1                VALUE 1001.
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
            05  WS-APPL-ID-DISP            PIC X(10).
            05  WS-CUSTOMER-ID             PIC X(10).
            05  WS-CUSTOMER-NAME           PIC X(60).
            05  WS-CUSTOMER-FOUND          PIC X(01).
                88  WS-CLIENTE-EXISTE      VALUE 'S'.
                88  WS-CLIENTE-NO-EXISTE   VALUE 'N'.
            05  WS-LOAN-TYPE               PIC X(02).
            05  WS-LOAN-TYPE-DISP          PIC X(02).
            05  WS-AMOUNT                  PIC 9(13)V99 COMP-3.
            05  WS-AMOUNT-DISP             PIC Z(12)9.99.
            05  WS-TERM-MONTHS             PIC 9(04).
            05  WS-TERM-DISP               PIC 9(04).
            05  WS-FREQ                    PIC X(01).
            05  WS-FREQ-DISP               PIC X(01).
            05  WS-INGRESO                 PIC 9(09)V99 COMP-3.
            05  WS-INGRESO-DISP            PIC Z(08)9.99.
            05  WS-EGRESOS                 PIC 9(09)V99 COMP-3.
            05  WS-EGRESOS-DISP            PIC Z(08)9.99.
            05  WS-SCORE                   PIC 9(03).
            05  WS-SCORE-DISP              PIC 9(03).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-APL-SEQ                 PIC 9(10).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'LONAPL00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-SOLICITUD.
            05  SCR-CAB.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - SOLICITUD DE PRESTAMO'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' USUARIO: '.
                10  LINE 02  COL 12  PIC X(08) FROM WS-USUARIO.
       *
            05  SCR-CUERPO.
                10  LINE 04  COL 05  PIC X(20) VALUE 'CLIENTE:'.
                10  LINE 04  COL 15  PIC X(10)
                   USING WS-CUSTOMER-ID AUTO PROMPT '__________'.
                10  LINE 04  COL 30  PIC X(10) VALUE 'PF1=VALIDAR'.
                10  LINE 05  COL 05  PIC X(20) VALUE 'NOMBRE:'.
                10  LINE 05  COL 15  PIC X(40) FROM WS-CUSTOMER-NAME.
       *
                10  LINE 07  COL 05  PIC X(20) VALUE 'TIPO PRESTAMO:'.
                10  LINE 07  COL 20  PIC X(02)
                   USING WS-LOAN-TYPE-DISP AUTO PROMPT '__'.
                10  LINE 07  COL 25  PIC X(40)
                   VALUE '(PL=PER HI=HIP AU=AUTO CO=COM)'.
       *
                10  LINE 09  COL 05  PIC X(20) VALUE 'MONTO:'.
                10  LINE 09  COL 15  PIC Z(12)9.99
                   USING WS-AMOUNT-DISP AUTO PROMPT '____________.__'.
       *
                10  LINE 10  COL 05  PIC X(20) VALUE 'PLAZO (MESES):'.
                10  LINE 10  COL 22  PIC 9(04)
                   USING WS-TERM-DISP AUTO PROMPT '____'.
       *
                10  LINE 12  COL 05  PIC X(20) VALUE 'FRECUENCIA:'.
                10  LINE 12  COL 18  PIC X(01)
                   USING WS-FREQ-DISP AUTO PROMPT '_'.
                10  LINE 12  COL 22  PIC X(40)
                   VALUE '(S= SEM Q=QUINC M= MEN B=BIM T=TRI)'.
       *
                10  LINE 14  COL 05  PIC X(20) VALUE 'INGRESO MENSUAL:'.
                10  LINE 14  COL 22  PIC Z(08)9.99
                   USING WS-INGRESO-DISP AUTO PROMPT '________.__'.
                10  LINE 15  COL 05  PIC X(20) VALUE 'EGRESOS MENSUALES:'.
                10  LINE 15  COL 22  PIC Z(08)9.99
                   USING WS-EGRESOS-DISP AUTO PROMPT '________.__'.
       *
                10  LINE 17  COL 05  PIC X(20) VALUE 'SCORE:'.
                10  LINE 17  COL 15  PIC 9(03) FROM WS-SCORE-DISP.
       *
            05  SCR-MSG.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'PF1=VAL CLIENTE  ENTER=GUARDAR  PF12=CANCELAR'.
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
        SOLICITUD-LOOP.
            PERFORM 2000-MOSTRAR.
            ACCEPT SCR-SOLICITUD.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    PERFORM 3000-VALIDAR-CLIENTE
                    GO TO SOLICITUD-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 'SOLICITUD CANCELADA' TO WS-MENSAJE
                    GOTO MAIN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    PERFORM 1100-LIMPIAR
                    GO TO SOLICITUD-LOOP
       *
                WHEN WS-CRT-ENTER
                    PERFORM 4000-VALIDAR-DATOS
                    IF WS-ERROR-NO
                        PERFORM 5000-CALCULAR-SCORE
                        PERFORM 6000-GUARDAR-SOLICITUD
                        IF WS-RETCODE = 00
                            PERFORM 7000-AUDITAR
                            MOVE 00 TO LS-RETCODE
                            GOTO MAIN-EXIT
                        END-IF
                    END-IF
                    GO TO SOLICITUD-LOOP
       *
                WHEN OTHER
                    MOVE 'INGRESE DATOS DE SOLICITUD'
                      TO WS-MENSAJE-ERROR
                    GO TO SOLICITUD-LOOP
            END-EVALUATE.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            OPEN I-O LOANAPPL-FILE CUSTOMER-FILE.
            MOVE 'INGRESE DATOS DEL CLIENTE' TO WS-MENSAJE.
       *
        1100-LIMPIAR.
            MOVE SPACES TO WS-CUSTOMER-ID WS-CUSTOMER-NAME
                           WS-LOAN-TYPE-DISP WS-FREQ-DISP
                           WS-MENSAJE WS-MENSAJE-ERROR.
            MOVE ZERO TO WS-AMOUNT WS-AMOUNT-DISP
                         WS-TERM-MONTHS WS-TERM-DISP
                         WS-INGRESO WS-INGRESO-DISP
                         WS-EGRESOS WS-EGRESOS-DISP
                         WS-SCORE WS-SCORE-DISP.
            MOVE 'N' TO WS-CLIENTE-EXISTE.
       *
        2000-MOSTRAR.
            PERFORM 2100-LIMPIAR-PANTALLA.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE WS-AMOUNT TO WS-AMOUNT-DISP.
            MOVE WS-TERM-MONTHS TO WS-TERM-DISP.
            MOVE WS-INGRESO TO WS-INGRESO-DISP.
            MOVE WS-EGRESOS TO WS-EGRESOS-DISP.
            MOVE WS-SCORE TO WS-SCORE-DISP.
            DISPLAY SCR-SOLICITUD.
       *
        2100-LIMPIAR-PANTALLA.
            DISPLAY SPACES UPON CRT.
       *
        3000-VALIDAR-CLIENTE.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            IF WS-CUSTOMER-ID = SPACES
                MOVE 'INGRESE ID CLIENTE' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            CALL 'CUSSRH00' USING WS-USUARIO
                                   WS-CUSTOMER-ID
                                   WS-CUSTOMER-NAME
                                   WS-RETCODE.
       *
            IF WS-RETCODE NOT = 00
                MOVE 'CLIENTE NO ENCONTRADO' TO WS-MENSAJE-ERROR
                MOVE 'N' TO WS-CLIENTE-EXISTE
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE 'S' TO WS-CLIENTE-EXISTE.
            MOVE 'CLIENTE VALIDADO' TO WS-MENSAJE.
       *
            MOVE WS-CUSTOMER-ID TO CUS-ID.
            READ CUSTOMER-FILE KEY IS CUS-ID
                INVALID KEY
                    MOVE SPACES TO WS-CUSTOMER-NAME
                    GOTO 3000-EXIT
            END-READ.
            MOVE CUS-NAME TO WS-CUSTOMER-NAME.
            MOVE CUS-INGRESO-MENSUAL TO WS-INGRESO.
            MOVE CUS-INGRESO-MENSUAL TO WS-INGRESO-DISP.
       *
        3000-EXIT.
            EXIT.
       *
        4000-VALIDAR-DATOS.
            MOVE 'N' TO WS-SWITCH-ERROR.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            MOVE WS-AMOUNT-DISP TO WS-AMOUNT.
            MOVE WS-TERM-DISP TO WS-TERM-MONTHS.
            MOVE WS-LOAN-TYPE-DISP TO WS-LOAN-TYPE.
            MOVE WS-FREQ-DISP TO WS-FREQ.
            MOVE WS-INGRESO-DISP TO WS-INGRESO.
            MOVE WS-EGRESOS-DISP TO WS-EGRESOS.
       *
            IF WS-CLIENTE-NO-EXISTE
                MOVE 'VALIDE CLIENTE PRIMERO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-LOAN-TYPE = SPACES
                MOVE 'SELECCIONE TIPO PRESTAMO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-AMOUNT = ZERO OR WS-AMOUNT < ZERO
                MOVE 'MONTO INVALIDO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-TERM-MONTHS = ZERO
                MOVE 'PLAZO INVALIDO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-INGRESO = ZERO
                MOVE 'INGRESE INGRESO MENSUAL' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
        4000-EXIT.
            EXIT.
       *
        5000-CALCULAR-SCORE.
            COMPUTE WS-SCORE =
                (WS-INGRESO - WS-EGRESOS) * 100 / WS-INGRESO.
            IF WS-SCORE > 100
                MOVE 100 TO WS-SCORE
            END-IF.
            IF WS-AMOUNT > WS-INGRESO * 60
                SUBTRACT 20 FROM WS-SCORE
            END-IF.
            IF WS-TERM-MONTHS > 60
                SUBTRACT 10 FROM WS-SCORE
            END-IF.
            IF WS-SCORE < 0
                MOVE 0 TO WS-SCORE
            END-IF.
            MOVE WS-SCORE TO WS-SCORE-DISP.
       *
        6000-GUARDAR-SOLICITUD.
            ADD 1 TO WS-APL-SEQ.
            MOVE WS-APL-SEQ TO LAP-APPL-ID.
            MOVE WS-CUSTOMER-ID TO LAP-CUSTOMER-ID.
            MOVE WS-LOAN-TYPE TO LAP-TYPE.
            MOVE WS-AMOUNT TO LAP-AMOUNT-REQUESTED.
            MOVE WS-TERM-MONTHS TO LAP-TERM-MONTHS.
            MOVE WS-FREQ TO LAP-PAYMENT-FREQ.
            MOVE WS-SCORE TO LAP-SCORE.
            MOVE WS-INGRESO TO LAP-INGRESO-MENSUAL.
            MOVE WS-EGRESOS TO LAP-EGRESOS-MENSUALES.
            MOVE 'B' TO LAP-STATUS.
            MOVE WS-FECHA TO LAP-FECHA-SOLICITUD.
            MOVE WS-USUARIO TO LAP-USUARIO-SOLICITA.
            MOVE SPACES TO LAP-OBSERVACIONES.
       *
            WRITE LOANAPPL-RECORD
                INVALID KEY
                    MOVE 'ERROR AL GUARDAR SOLICITUD'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 6000-EXIT
            END-WRITE.
       *
            MOVE 00 TO LS-RETCODE.
            STRING 'SOLICITUD ' LAP-APPL-ID ' CREADA'
              INTO WS-AUDIT-INFO.
       *
        6000-EXIT.
            EXIT.
       *
        7000-AUDITAR.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
            MOVE 'SOLICITUD GUARDADA EXITOSAMENTE' TO WS-MENSAJE.
            PERFORM 2100-LIMPIAR-PANTALLA.
            DISPLAY SCR-SOLICITUD.
            MOVE 'PRESIONE ENTER...' TO WS-MENSAJE.
            DISPLAY SCR-SOLICITUD.
            ACCEPT SCR-SOLICITUD.
       *
        9000-FINALIZAR.
            CLOSE LOANAPPL-FILE CUSTOMER-FILE.
            GOBACK.
       *
        END PROGRAM LONAPL00.
