      *================================================================*
      * COMSCRN - UTILERIAS DE PANTALLA                               *
      * PROPOSITO: LIMPIEZA, DIBUJO CAJAS, POSICIONAMIENTO            *
      * EQUIPO: INTERFAZ DE USUARIO - 1998                             *
      * USO:   CALL 'COMSCRN' USING OPERACION  PARAM1 PARAM2         *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMSCRN.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-OPERACION                  PIC X(05).
       01  WS-COL1                       PIC 9(02).
       01  WS-LIN1                       PIC 9(02).
       01  WS-COL2                       PIC 9(02).
       01  WS-LIN2                       PIC 9(02).
       01  WS-IND                        PIC 9(02).
       01  WS-IND2                       PIC 9(02).
       01  WS-TEXTO                      PIC X(78).
       01  WS-CHAR                       PIC X(01).
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-OPERACION                   PIC X(05).
       01  LS-PARAM1                      PIC X(10).
       01  LS-PARAM2                      PIC X(10).
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-OPERACION
                                 LS-PARAM1
                                 LS-PARAM2.
      *
       MAIN.
           MOVE LS-OPERACION TO WS-OPERACION.
      *
           EVALUATE WS-OPERACION
               WHEN 'CLEAR'
                   PERFORM 1000-LIMPIAR-PANTALLA
      *
               WHEN 'BOX'
                   PERFORM 2000-DIBUJAR-CAJA
      *
               WHEN 'CENTER'
                   PERFORM 3000-CENTRAR-TEXTO
      *
               WHEN 'BLANK'
                   PERFORM 4000-LIMPIAR-LINEA
      *
               WHEN 'CURSOR'
                   PERFORM 5000-POSICIONAR-CURSOR
      *
               WHEN 'COLOR'
                   PERFORM 6000-CAMBIAR-COLOR
      *
               WHEN OTHER
                   CONTINUE
           END-EVALUATE.
      *
           GOBACK.
      *
      *--- LIMPIAR PANTALLA ---*
       1000-LIMPIAR-PANTALLA.
           DISPLAY SPACES UPON CRT.
      *
      *--- DIBUJAR CAJA ---*
       2000-DIBUJAR-CAJA.
           MOVE LS-PARAM1(1:2) TO WS-LIN1.
           MOVE LS-PARAM1(3:2) TO WS-COL1.
           MOVE LS-PARAM2(1:2) TO WS-LIN2.
           MOVE LS-PARAM2(3:2) TO WS-COL2.
      *
           MOVE '+' TO WS-CHAR.
           DISPLAY WS-CHAR AT LINE WS-LIN1 COLUMN WS-COL1.
           MOVE '-' TO WS-CHAR.
           PERFORM VARYING WS-IND FROM WS-COL1 BY 1
               UNTIL WS-IND > WS-COL2
               DISPLAY WS-CHAR AT LINE WS-LIN1 COLUMN WS-IND
           END-PERFORM.
           MOVE '+' TO WS-CHAR.
           DISPLAY WS-CHAR AT LINE WS-LIN1 COLUMN WS-COL2.
      *
           PERFORM VARYING WS-IND FROM WS-LIN1 BY 1
               UNTIL WS-IND > WS-LIN2
               MOVE '|' TO WS-CHAR
               DISPLAY WS-CHAR AT LINE WS-IND COLUMN WS-COL1
               DISPLAY WS-CHAR AT LINE WS-IND COLUMN WS-COL2
           END-PERFORM.
      *
           MOVE '+' TO WS-CHAR.
           DISPLAY WS-CHAR AT LINE WS-LIN2 COLUMN WS-COL1.
           MOVE '-' TO WS-CHAR.
           PERFORM VARYING WS-IND FROM WS-COL1 BY 1
               UNTIL WS-IND > WS-COL2
               DISPLAY WS-CHAR AT LINE WS-LIN2 COLUMN WS-IND
           END-PERFORM.
           MOVE '+' TO WS-CHAR.
           DISPLAY WS-CHAR AT LINE WS-LIN2 COLUMN WS-COL2.
      *
      *--- CENTRAR TEXTO ---*
       3000-CENTRAR-TEXTO.
           MOVE LS-PARAM1(1:2) TO WS-LIN1.
           MOVE LS-PARAM1(5:5) TO WS-TEXTO.
           COMPUTE WS-COL1 = (80 - 5) / 2.
           DISPLAY WS-TEXTO AT LINE WS-LIN1 COLUMN WS-COL1.
      *
      *--- LIMPIAR LINEA ---*
       4000-LIMPIAR-LINEA.
           MOVE LS-PARAM1(1:2) TO WS-LIN1.
           MOVE LS-PARAM1(3:2) TO WS-COL1.
           MOVE LS-PARAM2(1:2) TO WS-COL2.
           MOVE SPACES TO WS-CHAR.
           PERFORM VARYING WS-IND FROM WS-COL1 BY 1
               UNTIL WS-IND > WS-COL2
               DISPLAY WS-CHAR AT LINE WS-LIN1 COLUMN WS-IND
           END-PERFORM.
      *
      *--- POSICIONAR CURSOR ---*
       5000-POSICIONAR-CURSOR.
           MOVE LS-PARAM1(1:2) TO WS-LIN1.
           MOVE LS-PARAM1(3:2) TO WS-COL1.
           DISPLAY SPACE AT LINE WS-LIN1 COLUMN WS-COL1.
      *
      *--- CAMBIAR COLOR ---*
       6000-CAMBIAR-COLOR.
      *    MICRO FOCUS COLOR MANAGEMENT - MONO LEGACY
           CONTINUE.
      *
       END PROGRAM COMSCRN.
