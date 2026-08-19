       *================================================================*
       * TLRSGN00 - APERTURA DE CAJA (SIGN-ON)                          *
       * PROPOSITO: INICIAR SESION DE CAJA, FONDO INICIAL              *
       * EQUIPO: VENTANILLA - 2002                                     *
       * ARCHIVOS: TELLEREC (ESCRITURA)                                 *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. TLRSGN00.
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
            SELECT TELLEREC-FILE
                ASSIGN TO 'TELLEREC.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS TLR-ID
                FILE STATUS IS FL-TELLEREC-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  TELLEREC-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TELLEREC REPLACING TELLEREC-FILE BY TELLEREC-FILE
                TELLEREC-RECORD BY TELLEREC-RECORD.
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
            05  WS-FONDO-INICIAL           PIC 9(09)V99 COMP-3.
            05  WS-FONDO-DISPLAY           PIC Z(09)9.99.
            05  WS-LIMITE-EFECTIVO         PIC 9(09)V99 COMP-3.
            05  WS-LIMITE-DISPLAY          PIC Z(09)9.99.
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-YA-ABIERTA              PIC X(01).
                88  WS-CAJA-YA-ABIERTA     VALUE 'S'.
                88  WS-CAJA-NO-ABIERTA     VALUE 'N'.
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'TLRSGN00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-APERTURA.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - APERTURA DE CAJA'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' CAJERO: '.
                10  LINE 02  COL 10  PIC X(08) FROM WS-USUARIO.
       *
            05  SCR-CUERPO.
                10  LINE 05  COL 05  PIC X(40)
                   VALUE 'DATOS DE APERTURA DE CAJA:'.
                10  LINE 07  COL 05  PIC X(20) VALUE 'FONDO INICIAL:'.
                10  LINE 07  COL 28  PIC Z(09)9.99
                   USING WS-FONDO-DISPLAY AUTO PROMPT '___________.__'.
                10  LINE 09  COL 05  PIC X(20) VALUE 'LIMITE EFECTIVO:'.
                10  LINE 09  COL 28  PIC Z(09)9.99
                   USING WS-LIMITE-DISPLAY AUTO PROMPT '___________.__'.
       *
            05  SCR-MENSAJE.
                10  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(40)
                   VALUE 'ENTER=ABRIR CAJA  PF12=CANCELAR'.
       *
        01  SCR-CAJA-EXISTE.
            05  LINE 05  COL 05  PIC X(60)
               VALUE 'LA CAJA YA SE ENCUENTRA ABIERTA PARA EL DIA DE HOY'
               .
            05  LINE 07  COL 05  PIC X(40)
               VALUE 'FECHA:'.
            05  LINE 07  COL 15  PIC 9(08) FROM TLR-DATE.
            05  LINE 08  COL 05  PIC X(40)
               VALUE 'HORA APERTURA:'.
            05  LINE 08  COL 22  PIC 9(06) FROM TLR-HORA-APERTURA.
            05  LINE 09  COL 05  PIC X(40)
               VALUE 'FONDO INICIAL:'.
            05  LINE 09  COL 22  PIC Z(09)9.99 FROM TLR-FONDO-INICIAL.
            05  LINE 11  COL 05  PIC X(50)
               VALUE 'PRESIONE ENTER PARA CONTINUAR...'.
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
            MOVE SPACES TO WS-USUARIO
                           WS-MENSAJE
                           WS-MENSAJE-ERROR.
            MOVE LS-USUARIO TO WS-USUARIO.
            MOVE 99 TO LS-RETCODE.
       *
            PERFORM 1000-INICIALIZAR.
            PERFORM 2000-VERIFICAR-SESION.
       *
            IF WS-CAJA-YA-ABIERTA
                PERFORM 3000-MOSTRAR-YA-ABIERTA
                GOTO MAIN-EXIT
            END-IF.
       *
        APERTURA-LOOP.
            PERFORM 4000-MOSTRAR-PANTALLA.
            ACCEPT SCR-APERTURA.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF12
                    MOVE 'APERTURA CANCELADA' TO WS-MENSAJE
                    GOTO MAIN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE ZERO TO WS-FONDO-INICIAL WS-LIMITE-EFECTIVO
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO APERTURA-LOOP
       *
                WHEN WS-CRT-ENTER
                    PERFORM 5000-VALIDAR-DATOS
                    IF WS-ERROR-NO
                        PERFORM 6000-GUARDAR-APERTURA
                        IF WS-RETCODE = 00
                            PERFORM 7000-AUDITAR
                            MOVE 00 TO LS-RETCODE
                            GOTO MAIN-EXIT
                        END-IF
                    END-IF
                    GO TO APERTURA-LOOP
       *
                WHEN OTHER
                    MOVE 'INGRESE FONDO INICIAL Y PRESIONE ENTER'
                      TO WS-MENSAJE-ERROR
                    GO TO APERTURA-LOOP
            END-EVALUATE.
       *
        MAIN-EXIT.
            EXIT.
       *
       *--- INICIALIZAR ---*
        1000-INICIALIZAR.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE ZERO TO WS-FONDO-INICIAL.
            MOVE ZERO TO WS-LIMITE-EFECTIVO.
            MOVE 'INGRESE FONDO INICIAL DE CAJA' TO WS-MENSAJE.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
       *--- VERIFICAR SI YA HAY SESION ABIERTA ---*
        2000-VERIFICAR-SESION.
            OPEN I-O TELLEREC-FILE.
            IF FL-TELLEREC-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR ARCHIVO DE CAJA'
                  TO WS-MENSAJE-ERROR
                MOVE 'N' TO WS-CAJA-YA-ABIERTA
                GOTO 2000-EXIT
            END-IF.
       *
            MOVE WS-USUARIO TO TLR-ID.
            MOVE WS-FECHA TO TLR-DATE.
            READ TELLEREC-FILE KEY IS TLR-ID
                INVALID KEY
                    MOVE 'N' TO WS-CAJA-YA-ABIERTA
                    GOTO 2000-EXIT
            END-READ.
       *
            IF TLR-STATUS-ABIERTO
                MOVE 'S' TO WS-CAJA-YA-ABIERTA
                MOVE 'CAJA YA ABIERTA' TO WS-MENSAJE
            ELSE
                MOVE 'N' TO WS-CAJA-YA-ABIERTA
            END-IF.
       *
        2000-EXIT.
            EXIT.
       *
       *--- MOSTRAR QUE YA ESTA ABIERTA ---*
        3000-MOSTRAR-YA-ABIERTA.
            PERFORM 1100-LIMPIAR.
            DISPLAY SCR-CAJA-EXISTE.
            ACCEPT SCR-CAJA-EXISTE.
       *
       *--- MOSTRAR PANTALLA DE APERTURA ---*
        4000-MOSTRAR-PANTALLA.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE WS-FONDO-INICIAL TO WS-FONDO-DISPLAY.
            MOVE WS-LIMITE-EFECTIVO TO WS-LIMITE-DISPLAY.
            DISPLAY SCR-APERTURA.
       *
       *--- VALIDAR DATOS DE APERTURA ---*
        5000-VALIDAR-DATOS.
            MOVE 'N' TO WS-SWITCH-ERROR.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            MOVE WS-FONDO-DISPLAY TO WS-FONDO-INICIAL.
            MOVE WS-LIMITE-DISPLAY TO WS-LIMITE-EFECTIVO.
       *
            IF WS-FONDO-INICIAL = ZERO
                MOVE 'EL FONDO INICIAL DEBE SER MAYOR A CERO'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            IF WS-LIMITE-EFECTIVO = ZERO
                MOVE 'INGRESE UN LIMITE DE EFECTIVO VALIDO'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            IF WS-FONDO-INICIAL > WS-LIMITE-EFECTIVO
                MOVE 'FONDO INICIAL NO PUEDE EXCEDER LIMITE'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
        5000-EXIT.
            EXIT.
       *
       *--- GUARDAR APERTURA DE CAJA ---*
        6000-GUARDAR-APERTURA.
            MOVE WS-FECHA TO TLR-DATE.
            MOVE WS-USUARIO TO TLR-ID.
            MOVE WS-USUARIO TO WS-SUCURSAL-ID.
            MOVE WS-SUCURSAL-ID TO TLR-BRANCH.
            MOVE WS-FONDO-INICIAL TO TLR-FONDO-INICIAL.
            MOVE WS-FONDO-INICIAL TO TLR-FONDO-ACTUAL.
            MOVE ZERO TO TLR-FONDO-CIERRE.
            MOVE WS-LIMITE-EFECTIVO TO TLR-LIMITE-EFECTIVO.
            MOVE ZERO TO TLR-TOTAL-DEPOSITOS
                         TLR-TOTAL-RETIROS
                         TLR-TOTAL-TRANSFERENCIAS
                         TLR-TOTAL-PAGOS
                         TLR-TOTAL-CHEQUES.
            MOVE ZERO TO TLR-COUNT-DEPOSITOS
                         TLR-COUNT-RETIROS
                         TLR-COUNT-TRANSFERENCIAS
                         TLR-COUNT-PAGOS
                         TLR-COUNT-CHEQUES
                         TLR-COUNT-TOTAL.
            MOVE WS-HORA TO TLR-HORA-APERTURA.
            MOVE ZERO TO TLR-HORA-CIERRE.
            MOVE 'O' TO TLR-STATUS.
            MOVE ZERO TO TLR-DIFERENCIA.
            MOVE 'S' TO TLR-CUADRADO.
       *
            WRITE TELLEREC-RECORD
                INVALID KEY
                    MOVE 'ERROR AL CREAR REGISTRO DE CAJA'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 6000-EXIT
            END-WRITE.
       *
            IF FL-TELLEREC-STATUS NOT = '00'
                MOVE 'ERROR DE ARCHIVO AL GUARDAR APERTURA'
                  TO WS-MENSAJE-ERROR
                MOVE 99 TO LS-RETCODE
                GOTO 6000-EXIT
            END-IF.
       *
            MOVE 00 TO LS-RETCODE.
            MOVE 'CAJA ABIERTA CORRECTAMENTE' TO WS-AUDIT-INFO.
       *
        6000-EXIT.
            EXIT.
       *
       *--- AUDITAR ---*
        7000-AUDITAR.
            STRING 'APERT: ' TLR-ID ' FDO:' TLR-FONDO-INICIAL
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA
                                  WS-AUDIT-INFO.
       *
       *--- FINALIZAR ---*
        9000-FINALIZAR.
            CLOSE TELLEREC-FILE.
            GOBACK.
       *
        END PROGRAM TLRSGN00.
