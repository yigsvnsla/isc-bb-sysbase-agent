      *================================================================*
      * CRDMNU00 - MENU PRINCIPAL MODULO TARJETAS                     *
      * EQUIPO: SISTEMAS DE TARJETAS - 2005                            *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRDMNU00.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF1                VALUE 1001.
           88  WS-CRT-PF2                VALUE 1002.
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF4                VALUE 1004.
           88  WS-CRT-PF5                VALUE 1005.
           88  WS-CRT-PF6                VALUE 1006.
           88  WS-CRT-PF7                VALUE 1007.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
           88  WS-CRT-CLEAR              VALUE 0000.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-SUCURSAL                PIC X(04).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'CRDMNU00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V1.3'.
       SCREEN SECTION.
       01  SCR-MENU.
           05  SCR-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                  VALUE ' BANCO NACIONAL - SISTEMA DE TARJETAS'.
               10  LINE 01  COL 65  PIC X(06) FROM WS-VERSION.
               10  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
               10  LINE 02  COL 01  PIC X(80)
                  VALUE ' MODULO DE ADMINISTRACION DE TARJETAS'.
               10  LINE 02  COL 70  PIC X(04) FROM WS-SUCURSAL.
           05  LINE 04  COL 05  PIC X(40)
               VALUE 'SELECCIONE LA OPCION DESEADA:'.
           05  LINE 06  COL 10  PIC X(30) VALUE 'PF1  - CONSULTA TARJETA'.
           05  LINE 07  COL 10  PIC X(30) VALUE 'PF2  - BLOQUEO TARJETA'.
           05  LINE 08  COL 10  PIC X(30) VALUE 'PF3  - REEMPLAZO TARJETA'.
           05  LINE 09  COL 10  PIC X(30) VALUE 'PF4  - ADMINISTRACION PIN'.
           05  LINE 10  COL 10  PIC X(30) VALUE 'PF5  - MOVIMIENTOS'.
           05  LINE 11  COL 10  PIC X(30) VALUE 'PF6  - LIMITES'.
           05  LINE 12  COL 10  PIC X(30) VALUE 'PF7  - ALERTAS'.
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
               10  LINE 24  COL 02  PIC X(78)
                  VALUE 'PF1=CONS  PF2=BLOQ  PF3=REEM  PF4=PIN  PF5=MOV'.
               10  LINE 24  COL 02  PIC X(78)
                  VALUE 'PF6=LIM  PF7=ALERT  PF12=RETORNAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-SUCURSAL                    PIC X(04).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO
                                 LS-SUCURSAL
                                 LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE LS-SUCURSAL TO WS-SUCURSAL.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
       MENU-LOOP.
           PERFORM 2000-MOSTRAR-MENU.
           ACCEPT SCR-MENU.
           EVALUATE TRUE
               WHEN WS-CRT-PF1
                   CALL 'CRDINQ00' USING WS-USUARIO LS-RETCODE
                   IF LS-RETCODE NOT = 00
                       MOVE 'ERROR EN CONSULTA' TO WS-MENSAJE-ERROR
                   END-IF
                   GO TO MENU-LOOP
               WHEN WS-CRT-PF2
                   CALL 'CRDBLK00' USING WS-USUARIO LS-RETCODE
                   IF LS-RETCODE NOT = 00
                       MOVE 'ERROR EN BLOQUEO' TO WS-MENSAJE-ERROR
                   END-IF
                   GO TO MENU-LOOP
               WHEN WS-CRT-PF3
                   CALL 'CRDREP00' USING WS-USUARIO LS-RETCODE
                   IF LS-RETCODE NOT = 00
                       MOVE 'ERROR EN REEMPLAZO' TO WS-MENSAJE-ERROR
                   END-IF
                   GO TO MENU-LOOP
               WHEN WS-CRT-PF4
                   CALL 'CRDPIN00' USING WS-USUARIO LS-RETCODE
                   IF LS-RETCODE NOT = 00
                       MOVE 'ERROR EN ADMIN PIN' TO WS-MENSAJE-ERROR
                   END-IF
                   GO TO MENU-LOOP
               WHEN WS-CRT-PF5
                   CALL 'CRDMOV00' USING WS-USUARIO LS-RETCODE
                   IF LS-RETCODE NOT = 00
                       MOVE 'ERROR EN MOVIMIENTOS' TO WS-MENSAJE-ERROR
                   END-IF
                   GO TO MENU-LOOP
               WHEN WS-CRT-PF6
                   CALL 'CRDLMT00' USING WS-USUARIO LS-RETCODE
                   IF LS-RETCODE NOT = 00
                       MOVE 'ERROR EN LIMITES' TO WS-MENSAJE-ERROR
                   END-IF
                   GO TO MENU-LOOP
               WHEN WS-CRT-PF7
                   CALL 'CRDALR00' USING WS-USUARIO LS-RETCODE
                   IF LS-RETCODE NOT = 00
                       MOVE 'ERROR EN ALERTAS' TO WS-MENSAJE-ERROR
                   END-IF
                   GO TO MENU-LOOP
               WHEN WS-CRT-PF11
                   CALL 'COMHELP' USING 'CRDMNU00'
                   GO TO MENU-LOOP
               WHEN WS-CRT-PF12
                   PERFORM 9000-RETORNAR
               WHEN WS-CRT-CLEAR
                   MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                   GO TO MENU-LOOP
               WHEN OTHER
                   MOVE 'USE PF1-PF7, PF12 PARA SALIR'
                     TO WS-MENSAJE-ERROR
                   GO TO MENU-LOOP
           END-EVALUATE.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'SELECCIONE OPCION DEL MENU DE TARJETAS' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
       2000-MOSTRAR-MENU.
           PERFORM 1100-LIMPIAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           DISPLAY SCR-MENU.
       9000-RETORNAR.
           MOVE 00 TO LS-RETCODE.
       END PROGRAM CRDMNU00.
