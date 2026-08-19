       *================================================================*
       * CUSMNU00 - MENU DE MODULO CLIENTES                           *
       * PROPOSITO: SUBMENU OPERACIONES DE CLIENTES PF1-PF7          *
       * EQUIPO: COMERCIAL - 2003                                     *
       * ARCHIVOS: NINGUNO (SOLO LLAMADOS A SUBPROGRAMAS)             *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. CUSMNU00.
       *================================================================*
        ENVIRONMENT DIVISION.
        CONFIGURATION SECTION.
        SOURCE-COMPUTER. IBM-PS2.
        OBJECT-COMPUTER. IBM-PS2.
        SPECIAL-NAMES.
            CRT STATUS IS WS-CRT-STATUS.
       *================================================================*
        DATA DIVISION.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'CUSMNU00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-DUMMY                   PIC X(01).
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
                    VALUE ' MODULO CLIENTES - MENU PRINCIPAL'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
                10  LINE 02  COL 70  PIC X(04) FROM WS-SUCURSAL-ID.
       *
            05  SCR-OPCIONES.
                10  LINE 04  COL 05  PIC X(50)
                    VALUE 'SELECCIONE OPERACION CON TECLA PF'.
                10  LINE 06  COL 10  PIC X(50)
                    VALUE 'PF1  - BUSQUEDA DE CLIENTE'.
                10  LINE 07  COL 10  PIC X(50)
                    VALUE 'PF2  - CONSULTA DE CLIENTE'.
                10  LINE 08  COL 10  PIC X(50)
                    VALUE 'PF3  - ALTA DE CLIENTE'.
                10  LINE 09  COL 10  PIC X(50)
                    VALUE 'PF4  - MODIFICACION DE CLIENTE'.
                10  LINE 10  COL 10  PIC X(50)
                    VALUE 'PF5  - MANTENIMIENTO DIRECCIONES'.
                10  LINE 11  COL 10  PIC X(50)
                    VALUE 'PF6  - RELACIONES / BENEFICIARIOS'.
                10  LINE 12  COL 10  PIC X(50)
                    VALUE 'PF7  - CAMBIO DE ESTATUS'.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF1=SRH  PF2=INQ  PF3=ALT  PF4=UPD  PF5=ADR'.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF6=REL  PF7=STS  PF11=AYU  PF12=RET'.
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
       *
            PERFORM 1000-INICIALIZAR.
       *
        MENU-LOOP.
            PERFORM 2000-REFRESCAR-PANTALLA.
            DISPLAY SCR-MENU.
            ACCEPT SCR-MENU.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    CALL 'CUSSRH00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF2
                    CALL 'CUSINQ00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF3
                    CALL 'CUSMNT00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF4
                    CALL 'CUSUPD00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF5
                    CALL 'CUSADR00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF6
                    CALL 'CUSREL00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF7
                    CALL 'CUSSTS00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'CLIENTES'
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF12
                    PERFORM 5000-CONFIRMAR-SALIDA
                    IF WS-CONFIRMED
                        MOVE 00 TO LS-RETCODE
                        GO TO MENU-EXIT
                    ELSE
                        GO TO MENU-LOOP
                    END-IF
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO MENU-LOOP
       *
                WHEN OTHER
                    MOVE 'TECLA NO VALIDA - USE PF1 A PF7 O PF12'
                      TO WS-MENSAJE-ERROR
                    GO TO MENU-LOOP
            END-EVALUATE.
       *
        MENU-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'SELECCIONE OPERACION CON TECLA PF' TO WS-MENSAJE.
            PERFORM 1100-LIMPIAR.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        2000-REFRESCAR-PANTALLA.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
        5000-CONFIRMAR-SALIDA.
            MOVE SPACES TO WS-DUMMY.
            DISPLAY 'CONFIRMAR SALIDA DEL MODULO CLIENTES? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-DUMMY AT LINE 23 COLUMN 48.
            IF WS-DUMMY = 'S' OR WS-DUMMY = 's'
                MOVE 'Y' TO WS-SWITCH-CONFIRM
            ELSE
                MOVE 'N' TO WS-SWITCH-CONFIRM
                MOVE 'SALIDA CANCELADA' TO WS-MENSAJE
            END-IF.
       *
        END PROGRAM CUSMNU00.
