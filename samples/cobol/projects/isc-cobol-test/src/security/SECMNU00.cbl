       *================================================================*
       * SECMNU00 - MENU DE SEGURIDAD / ADMINISTRACION                 *
       * PROPOSITO: ACCESO A ADMINISTRACION DE USUARIOS, PASSWORD,    *
       *            Y AUDITORIA DE SESIONES                           *
       * EQUIPO: SEGURIDAD INFORMATICA - 1997                         *
       * CALL: SECUSR00, SECPWD00, SECAUD00                          *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SECMNU00.
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
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF1                VALUE 1001.
           88  WS-CRT-PF2                VALUE 1002.
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-CLEAR              VALUE 0000.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-PROGRAMA                PIC X(08) VALUE 'SECMNU00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V1.0'.
           05  WS-PROGRAMA-LLAMAR         PIC X(08).
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-MENU.
           05  SCR-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - ADMINISTRACION SEGURIDAD'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' MODULO DE SEGURIDAD'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
      *
           05  SCR-CUERPO.
               10  LINE 04  COL 05  PIC X(30)
                   VALUE 'ADMINISTRACION DE SEGURIDAD'.
               10  LINE 05  COL 05  PIC X(70) VALUE ALL '-'.
               10  LINE 06  COL 05  PIC X(50)
                   VALUE 'PF1  - ADMINISTRACION DE USUARIOS'.
               10  LINE 07  COL 05  PIC X(50)
                   VALUE 'PF2  - CAMBIO DE PASSWORD'.
               10  LINE 08  COL 05  PIC X(50)
                   VALUE 'PF3  - AUDITORIA DE SESIONES'.
      *
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF1=USUARIOS  PF2=PASSWORD  PF3=AUDITORIA '.
               10  LINE 24  COL 45  PIC X(35)
                   VALUE ' PF12=RETORNAR'.
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
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 0 TO WS-RETCODE.
      *
           PERFORM 1000-INICIALIZAR.
      *
       MENU-LOOP.
           PERFORM 2000-MOSTRAR-MENU.
           ACCEPT SCR-MENU.
      *
           EVALUATE TRUE
               WHEN WS-CRT-PF1
                   MOVE 'SECUSR00' TO WS-PROGRAMA-LLAMAR
                   PERFORM 3000-EJECUTAR
               WHEN WS-CRT-PF2
                   MOVE 'SECPWD00' TO WS-PROGRAMA-LLAMAR
                   PERFORM 3000-EJECUTAR
               WHEN WS-CRT-PF3
                   MOVE 'SECAUD00' TO WS-PROGRAMA-LLAMAR
                   PERFORM 3000-EJECUTAR
               WHEN WS-CRT-PF12
                   PERFORM 9000-FINALIZAR
               WHEN WS-CRT-CLEAR
                   MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                   GO TO MENU-LOOP
               WHEN OTHER
                   MOVE 'USE PF1-PF3, PF12=RETORNAR'
                     TO WS-MENSAJE-ERROR
                   GO TO MENU-LOOP
           END-EVALUATE.
      *
           GO TO MENU-LOOP.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 'SELECCIONE OPCION CON PF-KEY'
             TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       2000-MOSTRAR-MENU.
           PERFORM 1100-LIMPIAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           DISPLAY SCR-MENU.
      *
       3000-EJECUTAR.
           MOVE SPACES TO WS-MENSAJE-ERROR.
           STRING 'EJECUTANDO ' WS-PROGRAMA-LLAMAR '...'
             INTO WS-MENSAJE.
           DISPLAY SCR-MENU.
           CALL WS-PROGRAMA-LLAMAR USING WS-USUARIO
                                          WS-RETCODE.
           IF WS-RETCODE NOT = 00
               STRING 'ERROR EN ' WS-PROGRAMA-LLAMAR
                 INTO WS-MENSAJE-ERROR
           ELSE
               STRING WS-PROGRAMA-LLAMAR ' OK'
                 INTO WS-MENSAJE.
      *
       9000-FINALIZAR.
           PERFORM 1100-LIMPIAR.
           MOVE 0 TO LS-RETCODE.
           GOBACK.
      *
       END PROGRAM SECMNU00.
