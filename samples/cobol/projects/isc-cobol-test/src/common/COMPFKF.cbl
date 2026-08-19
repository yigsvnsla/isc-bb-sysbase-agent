      *================================================================*
      * COMPFKF - MANEJO DE TECLAS PF                                 *
      * PROPOSITO: CENTRALIZAR LA INTERPRETACION DE PF KEYS           *
      * CREADO: 1997 - EQUIPO DE INTERFAZ                             *
      * USO:   CALL 'COMPFKF' USING TECLA  ACCION  MENSAJE            *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMPFKF.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                 PIC 9(04).
           88  WS-CRT-PF1               VALUE 1001.
           88  WS-CRT-PF2               VALUE 1002.
           88  WS-CRT-PF3               VALUE 1003.
           88  WS-CRT-PF4               VALUE 1004.
           88  WS-CRT-PF5               VALUE 1005.
           88  WS-CRT-PF6               VALUE 1006.
           88  WS-CRT-PF7               VALUE 1007.
           88  WS-CRT-PF8               VALUE 1008.
           88  WS-CRT-PF9               VALUE 1009.
           88  WS-CRT-PF10              VALUE 1010.
           88  WS-CRT-PF11              VALUE 1011.
           88  WS-CRT-PF12              VALUE 1012.
           88  WS-CRT-ENTER             VALUE 0013.
           88  WS-CRT-CLEAR             VALUE 0000.
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-TECLA                       PIC 9(04).
       01  LS-ACCION                      PIC X(02).
       01  LS-MENSAJE                     PIC X(60).
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-TECLA
                                 LS-ACCION
                                 LS-MENSAJE.
      *
       MAIN.
           MOVE LS-TECLA TO WS-CRT-STATUS.
           MOVE SPACES TO LS-MENSAJE.
      *
           EVALUATE TRUE
               WHEN WS-CRT-PF1
                   MOVE '01' TO LS-ACCION
                   MOVE 'PF1 - SELECCIONADO' TO LS-MENSAJE
               WHEN WS-CRT-PF2
                   MOVE '02' TO LS-ACCION
               WHEN WS-CRT-PF3
                   MOVE '03' TO LS-ACCION
               WHEN WS-CRT-PF4
                   MOVE '04' TO LS-ACCION
               WHEN WS-CRT-PF5
                   MOVE '05' TO LS-ACCION
               WHEN WS-CRT-PF6
                   MOVE '06' TO LS-ACCION
               WHEN WS-CRT-PF7
                   MOVE '07' TO LS-ACCION
               WHEN WS-CRT-PF8
                   MOVE '08' TO LS-ACCION
               WHEN WS-CRT-PF9
                   MOVE '09' TO LS-ACCION
               WHEN WS-CRT-PF10
                   MOVE '10' TO LS-ACCION
               WHEN WS-CRT-PF11
                   MOVE '11' TO LS-ACCION
               WHEN WS-CRT-PF12
                   MOVE '12' TO LS-ACCION
                   MOVE 'RETORNANDO...' TO LS-MENSAJE
               WHEN WS-CRT-ENTER
                   MOVE 'EN' TO LS-ACCION
               WHEN WS-CRT-CLEAR
                   MOVE 'CL' TO LS-ACCION
                   MOVE 'PANTALLA LIMPIA' TO LS-MENSAJE
               WHEN OTHER
                   MOVE '??' TO LS-ACCION
                   MOVE 'TECLA NO RECONOCIDA' TO LS-MENSAJE
           END-EVALUATE.
      *
           GOBACK.
      *
       END PROGRAM COMPFKF.
