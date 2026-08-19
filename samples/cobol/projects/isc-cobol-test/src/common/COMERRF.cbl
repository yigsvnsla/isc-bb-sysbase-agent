      *================================================================*
      * COMERRF - MANEJO DE ERRORES DEL SISTEMA                       *
      * PROPOSITO: CAPTURA, REGISTRO Y VISUALIZACION DE ERRORES       *
      * EQUIPO: CALIDAD - 2003                                        *
      * USO:   CALL 'COMERRF' USING DATOS-ERROR                       *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMERRF.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-ERR-CODIGO                 PIC X(04).
       01  WS-ERR-PROGRAMA               PIC X(08).
       01  WS-ERR-ARCHIVO                PIC X(10).
       01  WS-ERR-OPERACION              PIC X(06).
       01  WS-ERR-FILESTATUS             PIC X(02).
       01  WS-ERR-DESCRIPCION            PIC X(40).
       01  WS-ERR-SEVERIDAD              PIC 9(01).
           88  WS-ERR-LEVE               VALUE 1.
           88  WS-ERR-MODERADO           VALUE 2.
           88  WS-ERR-GRAVE              VALUE 3.
       01  WS-ERR-FECHA                  PIC 9(08).
       01  WS-ERR-HORA                   PIC 9(06).
       01  WS-ERR-USUARIO                PIC X(08).
       01  WS-ERR-CONTADOR               PIC 9(04) VALUE 0.
      *
       01  WS-TEXTO-AUX                  PIC X(60).
       01  WS-DUMMY-RESP                 PIC X(01).
      *
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-ERROR.
           05  SCR-ERR-CAB.
               10  LINE 01 COL 01 PIC X(80)
                   VALUE ' BANCO NACIONAL - ERROR DEL SISTEMA'.
               10  LINE 01 COL 60 PIC 9(08) FROM WS-ERR-FECHA.
               10  LINE 01 COL 70 PIC 9(06) FROM WS-ERR-HORA.
           05  SCR-ERR-CUERPO.
               10  LINE 04 COL 05 PIC X(30)
                   VALUE 'SE HA PRODUCIDO UN ERROR:'.
               10  LINE 06 COL 05 PIC X(15) VALUE 'PROGRAMA:'.
               10  LINE 06 COL 15 PIC X(08) FROM WS-ERR-PROGRAMA.
               10  LINE 07 COL 05 PIC X(15) VALUE 'ARCHIVO:'.
               10  LINE 07 COL 15 PIC X(10) FROM WS-ERR-ARCHIVO.
               10  LINE 08 COL 05 PIC X(15) VALUE 'OPERACION:'.
               10  LINE 08 COL 15 PIC X(06) FROM WS-ERR-OPERACION.
               10  LINE 09 COL 05 PIC X(15) VALUE 'CODIGO:'.
               10  LINE 09 COL 15 PIC X(02) FROM WS-ERR-FILESTATUS.
               10  LINE 11 COL 05 PIC X(40) FROM WS-ERR-DESCRIPCION.
           05  SCR-ERR-PIE.
               10  LINE 23 COL 01 PIC X(80) VALUE ALL '-'.
               10  LINE 24 COL 05 PIC X(40)
                   VALUE 'PF12 - CONTINUAR / PF1 - DETALLE'.
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-ERROR-DATOS.
           05  LS-ERR-PROGRAMA            PIC X(08).
           05  LS-ERR-ARCHIVO             PIC X(10).
           05  LS-ERR-OPERACION           PIC X(06).
           05  LS-ERR-FILESTATUS          PIC X(02).
           05  LS-ERR-DESCRIPCION         PIC X(40).
           05  LS-ERR-SEVERIDAD           PIC 9(01).
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-ERROR-DATOS.
      *
       MAIN.
           MOVE LS-ERR-PROGRAMA   TO WS-ERR-PROGRAMA.
           MOVE LS-ERR-ARCHIVO    TO WS-ERR-ARCHIVO.
           MOVE LS-ERR-OPERACION  TO WS-ERR-OPERACION.
           MOVE LS-ERR-FILESTATUS TO WS-ERR-FILESTATUS.
           MOVE LS-ERR-DESCRIPCION TO WS-ERR-DESCRIPCION.
           MOVE LS-ERR-SEVERIDAD  TO WS-ERR-SEVERIDAD.
      *
           PERFORM 1000-OBTENER-FECHA-HORA.
           PERFORM 2000-REGISTRAR-EN-AUDITORIA.
           PERFORM 3000-MOSTRAR-ERROR.
      *
           GOBACK.
      *
       1000-OBTENER-FECHA-HORA.
           CALL 'COMDATE' USING 'NOW'
                                WS-ERR-FECHA
                                WS-ERR-HORA.
      *
       2000-REGISTRAR-EN-AUDITORIA.
           ADD 1 TO WS-ERR-CONTADOR.
      *
           IF WS-ERR-SEVERIDAD > 1
               STRING 'ERR:'  LS-ERR-PROGRAMA
                      ' ' LS-ERR-OPERACION
                      ' ' LS-ERR-FILESTATUS
                 INTO WS-TEXTO-AUX
               CALL 'AUDTRL00' USING WS-ERR-PROGRAMA
                                     WS-TEXTO-AUX
           END-IF.
      *
       3000-MOSTRAR-ERROR.
           DISPLAY SCR-ERROR.
           ACCEPT SCR-ERROR.
      *
       END PROGRAM COMERRF.
