       *================================================================*
       * LONMNU00 - MENU DE CREDITOS / PRESTAMOS                       *
       * PROPOSITO: NAVEGACION DE OPERACIONES DE CREDITO               *
       * EQUIPO: CREDITO Y COBRANZA - 2004                             *
       * LLAMADO DESDE: BNK0010 (MENU PRINCIPAL)                       *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. LONMNU00.
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
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-SUCURSAL                PIC X(04).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-MENU.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - MODULO DE CREDITOS'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' OPERACIONES DE PRESTAMOS'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
                10  LINE 02  COL 70  PIC X(04) FROM WS-SUCURSAL.
       *
            05  SCR-CUERPO.
                10  LINE 05  COL 05  PIC X(40)
                   VALUE 'SELECCIONE OPERACION DE CREDITO:'.
                10  LINE 07  COL 10  PIC X(40)
                   VALUE 'PF1  - CONSULTA DE PRESTAMO'.
                10  LINE 08  COL 10  PIC X(40)
                   VALUE 'PF2  - SOLICITUD DE PRESTAMO'.
                10  LINE 09  COL 10  PIC X(40)
                   VALUE 'PF3  - APROBACION DE PRESTAMO'.
                10  LINE 10  COL 10  PIC X(40)
                   VALUE 'PF4  - DESEMBOLSO DE PRESTAMO'.
                10  LINE 11  COL 10  PIC X(40)
                   VALUE 'PF5  - PAGO DE CUOTA'.
                10  LINE 12  COL 10  PIC X(40)
                   VALUE 'PF6  - TABLA DE AMORTIZACION'.
                10  LINE 13  COL 10  PIC X(40)
                   VALUE 'PF7  - GESTION DE MORA / CASTIGO'.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
                10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF1=INQ  PF2=APL  PF3=APV  PF4=DIS  PF5=PYM'.
                10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF6=AMR  PF7=DEL  PF12=SALIR'.
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
            MOVE 00 TO LS-RETCODE.
            PERFORM 1000-INICIALIZAR.
       *
        MENU-LOOP.
            PERFORM 2000-REFRESCAR.
            DISPLAY SCR-MENU.
            ACCEPT SCR-MENU.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    CALL 'LONINQ00' USING LS-USUARIO LS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF2
                    CALL 'LONAPL00' USING LS-USUARIO LS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF3
                    CALL 'LONAPV00' USING LS-USUARIO LS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF4
                    CALL 'LONDIS00' USING LS-USUARIO LS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF5
                    CALL 'LONPYM00' USING LS-USUARIO LS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF6
                    CALL 'LONAMR00' USING LS-USUARIO LS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF7
                    CALL 'LONDEL00' USING LS-USUARIO LS-RETCODE
                    GO TO MENU-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GOBACK
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO MENU-LOOP
       *
                WHEN OTHER
                    MOVE 'USE PF1-PF7 PARA SELECCIONAR'
                      TO WS-MENSAJE-ERROR
                    GO TO MENU-LOOP
            END-EVALUATE.
       *
        1000-INICIALIZAR.
            DISPLAY SPACES UPON CRT.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'MODULO DE CREDITOS - SELECCIONE OPCION'
              TO WS-MENSAJE.
       *
        2000-REFRESCAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
       *
        END PROGRAM LONMNU00.
