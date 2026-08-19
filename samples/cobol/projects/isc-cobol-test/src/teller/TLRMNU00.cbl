       *================================================================*
       * TLRMNU00 - MENU DE CAJA / VENTANILLA                          *
       * PROPOSITO: NAVEGACION DE TRANSACCIONES DE CAJA                *
       * EQUIPO: VENTANILLA - 2002                                     *
       * ARCHIVOS: TELLEREC (VALIDAR SESION ACTIVA)                    *
       * LLAMADO DESDE: BNK0010 (MENU PRINCIPAL)                       *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. TLRMNU00.
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
            88  WS-CRT-PF2                VALUE 1002.
            88  WS-CRT-PF3                VALUE 1003.
            88  WS-CRT-PF4                VALUE 1004.
            88  WS-CRT-PF5                VALUE 1005.
            88  WS-CRT-PF6                VALUE 1006.
            88  WS-CRT-PF7                VALUE 1007.
            88  WS-CRT-PF8                VALUE 1008.
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-ENTER              VALUE 0013.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-SUCURSAL                PIC X(04).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-OPCION                  PIC 9(02).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-TLR-ENCONTRADO          PIC X(01).
                88  WS-TLR-SESION-ACTIVA   VALUE 'S'.
                88  WS-TLR-SIN-SESION      VALUE 'N'.
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'TLRMNU00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-MENU.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' MODULO DE CAJA / VENTANILLA'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
                10  LINE 02  COL 70  PIC X(04) FROM WS-SUCURSAL.
       *
            05  SCR-CUERPO.
                10  LINE 05  COL 05  PIC X(40)
                   VALUE 'SELECCIONE OPCION - TRANSACCIONES DE CAJA:'.
                10  LINE 07  COL 10  PIC X(40)
                   VALUE 'PF1  - APERTURA DE CAJA (SIGN-ON)'.
                10  LINE 08  COL 10  PIC X(40)
                   VALUE 'PF2  - DEPOSITO EN EFECTIVO/CHEQUE'.
                10  LINE 09  COL 10  PIC X(40)
                   VALUE 'PF3  - RETIRO EN EFECTIVO'.
                10  LINE 10  COL 10  PIC X(40)
                   VALUE 'PF4  - TRANSFERENCIA ENTRE CUENTAS'.
                10  LINE 11  COL 10  PIC X(40)
                   VALUE 'PF5  - PAGO DE SERVICIOS'.
                10  LINE 12  COL 10  PIC X(40)
                   VALUE 'PF6  - COBRO DE CHEQUE'.
                10  LINE 13  COL 10  PIC X(40)
                   VALUE 'PF7  - RESUMEN / CIERRE DE CAJA'.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
                10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF1=APERT  PF2=DEP  PF3=RET  PF4=TRF  PF5=PAG'.
                10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF6=CHQ  PF7=CIE.  PF12=SALIR'.
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
            MOVE 00 TO LS-RETCODE.
       *
            PERFORM 1000-INICIALIZAR.
            PERFORM 2000-VALIDAR-SESION-CAJA.
       *
        MENU-LOOP.
            PERFORM 3000-REFRESCAR-PANTALLA.
            DISPLAY SCR-MENU.
            ACCEPT SCR-MENU.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    PERFORM 4000-EJECUTAR-PF1
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF2
                    IF WS-TLR-SESION-ACTIVA
                        CALL 'TLRDEP00' USING LS-USUARIO LS-RETCODE
                    ELSE
                        MOVE 'DEBE ABRIR CAJA PRIMERO (PF1)'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF3
                    IF WS-TLR-SESION-ACTIVA
                        CALL 'TLRWTH00' USING LS-USUARIO LS-RETCODE
                    ELSE
                        MOVE 'DEBE ABRIR CAJA PRIMERO (PF1)'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF4
                    IF WS-TLR-SESION-ACTIVA
                        CALL 'TLRTRF00' USING LS-USUARIO LS-RETCODE
                    ELSE
                        MOVE 'DEBE ABRIR CAJA PRIMERO (PF1)'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF5
                    IF WS-TLR-SESION-ACTIVA
                        CALL 'TLRPYM00' USING LS-USUARIO LS-RETCODE
                    ELSE
                        MOVE 'DEBE ABRIR CAJA PRIMERO (PF1)'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF6
                    IF WS-TLR-SESION-ACTIVA
                        CALL 'TLRCHE00' USING LS-USUARIO LS-RETCODE
                    ELSE
                        MOVE 'DEBE ABRIR CAJA PRIMERO (PF1)'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF7
                    IF WS-TLR-SESION-ACTIVA
                        CALL 'TLRSMG00' USING LS-USUARIO LS-RETCODE
                    ELSE
                        MOVE 'DEBE ABRIR CAJA PRIMERO (PF1)'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    PERFORM 9000-FINALIZAR
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO MENU-LOOP
       *
                WHEN OTHER
                    MOVE 'USE PF1-PF7 PARA SELECCIONAR O PF12 SALIR'
                      TO WS-MENSAJE-ERROR
                    GO TO MENU-LOOP
            END-EVALUATE.
       *
       *--- INICIALIZAR ---*
        1000-INICIALIZAR.
            PERFORM 1100-LIMPIAR-PANTALLA.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'BIENVENIDO - MODULO DE CAJA' TO WS-MENSAJE.
            MOVE 'N' TO WS-TLR-SESION-ACTIVA.
       *
        1100-LIMPIAR-PANTALLA.
            DISPLAY SPACES UPON CRT.
       *
       *--- VALIDAR SI CAJA YA ESTA ABIERTA ---*
        2000-VALIDAR-SESION-CAJA.
            OPEN I-O TELLEREC-FILE.
            IF FL-TELLEREC-STATUS NOT = '00'
                MOVE 'SIN SESION DE CAJA - USE PF1 PARA ABRIR'
                  TO WS-MENSAJE
                MOVE 'N' TO WS-TLR-SESION-ACTIVA
                GOTO 2000-EXIT
            END-IF.
       *
            MOVE WS-USUARIO TO TLR-ID.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO TLR-DATE.
            READ TELLEREC-FILE KEY IS TLR-ID
                INVALID KEY
                    MOVE 'SIN SESION DE CAJA - USE PF1 PARA ABRIR'
                      TO WS-MENSAJE
                    MOVE 'N' TO WS-TLR-SESION-ACTIVA
                    GOTO 2000-EXIT
            END-READ.
       *
            IF TLR-STATUS-ABIERTO
                MOVE 'S' TO WS-TLR-SESION-ACTIVA
                MOVE 'CAJA ABIERTA - SELECCIONE OPERACION'
                  TO WS-MENSAJE
            ELSE
                MOVE 'N' TO WS-TLR-SESION-ACTIVA
                MOVE 'DEBE ABRIR CAJA (PF1)' TO WS-MENSAJE
            END-IF.
       *
        2000-EXIT.
            EXIT.
       *
       *--- REFRESCAR PANTALLA ---*
        3000-REFRESCAR-PANTALLA.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
       *
       *--- EJECUTAR APERTURA DE CAJA ---*
        4000-EJECUTAR-PF1.
            CALL 'TLRSGN00' USING LS-USUARIO LS-RETCODE.
            IF LS-RETCODE = 00
                MOVE 'S' TO WS-TLR-SESION-ACTIVA
                PERFORM 2000-VALIDAR-SESION-CAJA
            ELSE
                MOVE 'APERTURA DE CAJA CANCELADA O CON ERROR'
                  TO WS-MENSAJE-ERROR
            END-IF.
       *
       *--- FINALIZAR ---*
        9000-FINALIZAR.
            CLOSE TELLEREC-FILE.
            MOVE 00 TO LS-RETCODE.
            GOBACK.
       *
        END PROGRAM TLRMNU00.
