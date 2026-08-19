       *================================================================*
       * SECAUD00 - REPORTE DE AUDITORIA DE SESIONES                  *
       * PROPOSITO: CONSULTAR REGISTROS DE SEGURIDAD (LOGIN/LOGOUT,  *
       *            FALLOS, BLOQUEOS, CAMBIO PASSWORD) POR FECHA     *
       * EQUIPO: AUDITORIA INTERNA - 2000                            *
       * ARCHIVOS: SECURITY (LECTURA SECUENCIAL) O AUDITLOG          *
       * CALL: COMDATE, COMMSGF                                     *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SECAUD00.
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
           SELECT SECURITY-FILE
               ASSIGN TO 'SECURITY.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS SEC-SEQ
               FILE STATUS IS FL-FILE-STATUS.
      *================================================================*
       DATA DIVISION.
       FILE SECTION.
       FD  SECURITY-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 120 CHARACTERS.
       01  SECURITY-RECORD.
           05  SEC-SEQ                     PIC 9(10).
           05  SEC-DATE                    PIC 9(08).
           05  SEC-TIME                    PIC 9(06).
           05  SEC-USER-ID                 PIC X(08).
           05  SEC-EVENT-TYPE              PIC X(02).
           05  SEC-IP-ADDRESS              PIC X(15).
           05  SEC-TERMINAL                PIC X(08).
           05  SEC-BROWSER                 PIC X(20).
           05  SEC-RESULT                  PIC X(01).
           05  SEC-DETAILS                 PIC X(40).
           05  SEC-FILLER                  PIC X(10).
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF4                VALUE 1004.
           88  WS-CRT-PF5                VALUE 1005.
           88  WS-CRT-PF7                VALUE 1007.
           88  WS-CRT-PF8                VALUE 1008.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
      *
       01  WS-FLAG-ERROR                  PIC X(01).
           88  WS-HAY-ERROR               VALUE 'S'.
           88  WS-NO-HAY-ERROR            VALUE 'N'.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'SECAUD00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V1.0'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-FECHA-DESDE             PIC 9(08).
           05  WS-FECHA-HASTA             PIC 9(08).
           05  WS-FECHA-DESDE-DISP        PIC 99/99/9999.
           05  WS-FECHA-HASTA-DISP        PIC 99/99/9999.
           05  WS-FILTRO-USUARIO          PIC X(08).
           05  WS-PAGINA                  PIC 9(04) VALUE 1.
           05  WS-TOTAL-REG               PIC 9(06) VALUE 0.
           05  WS-REG-X-PAGINA            PIC 9(02) VALUE 12.
           05  WS-TOTAL-PAGINAS           PIC 9(04).
           05  WS-REG-DESDE               PIC 9(06).
           05  WS-REG-HASTA               PIC 9(06).
           05  WS-CONTADOR                PIC 9(06) VALUE 0.
           05  WS-FILE-STATUS-CODE        PIC X(02).
      *
       01  WS-AUD-TABLE.
           05  WS-AUD-ENTRY               OCCURS 12.
               10  WS-AUD-SEQ             PIC 9(10).
               10  WS-AUD-DATE            PIC 9(08).
               10  WS-AUD-TIME            PIC 9(06).
               10  WS-AUD-USER            PIC X(08).
               10  WS-AUD-EVENT           PIC X(02).
               10  WS-AUD-TERMINAL        PIC X(08).
               10  WS-AUD-RESULT          PIC X(01).
      *
       01  WS-EVENT-DESC                  PIC X(15).
       01  WS-RESULT-DESC                 PIC X(10).
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-PROMPT.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - AUDITORIA DE SESIONES'.
           05  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
           05  LINE 02  COL 01  PIC X(80)
               VALUE ' FILTROS DE CONSULTA'.
           05  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 10  PIC X(30) VALUE 'FECHA DESDE:'.
           05  LINE 05  COL 30  PIC 99/99/9999
               USING WS-FECHA-DESDE.
           05  LINE 07  COL 10  PIC X(30) VALUE 'FECHA HASTA:'.
           05  LINE 07  COL 30  PIC 99/99/9999
               USING WS-FECHA-HASTA.
           05  LINE 09  COL 10  PIC X(30) VALUE 'USUARIO (OPC):'.
           05  LINE 09  COL 30  PIC X(08) USING WS-FILTRO-USUARIO.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
      *
       01  SCR-REPORTE.
           05  SCR-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - AUDITORIA DE SESIONES'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' REGISTROS DE AUDITORIA'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
               10  LINE 03  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 04  COL 01  PIC X(78)
                   VALUE 'FECHA     HORA   USUARIO EVENTO TERMINAL  '.
               10  LINE 04  COL 55  PIC X(25) VALUE 'RES'.
      *
           05  SCR-DETALLE OCCURS 12.
               10  SCR-DET-DATE            PIC 99/99/9999.
               10  SCR-DET-TIME            PIC 9(06).
               10  SCR-DET-USER            PIC X(08).
               10  SCR-DET-EVENT           PIC X(15).
               10  SCR-DET-TERM            PIC X(08).
               10  SCR-DET-RES             PIC X(10).
      *
           05  SCR-PIE.
               10  LINE 21  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 21  COL 05  PIC X(20) VALUE 'PAG:'.
               10  LINE 21  COL 12  PIC Z(9) FROM WS-PAGINA.
               10  LINE 21  COL 20  PIC X(10) VALUE 'DE '.
               10  LINE 21  COL 25  PIC Z(9) FROM WS-TOTAL-PAGINAS.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF7=P-ANT  PF8=P-SIG  PF12=SALIR'.
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
           PERFORM 2000-PROMPT-FILTROS.
           PERFORM 3000-CARGAR-DATOS.
           PERFORM 4000-MOSTRAR-PAGINA.
      *
       AUD-LOOP.
           ACCEPT SCR-REPORTE.
           EVALUATE TRUE
               WHEN WS-CRT-PF7
                   IF WS-PAGINA > 1
                       SUBTRACT 1 FROM WS-PAGINA
                       PERFORM 4000-MOSTRAR-PAGINA
                   ELSE
                       MOVE 'PRIMERA PAGINA' TO WS-MENSAJE-ERROR
                   END-IF
               WHEN WS-CRT-PF8
                   IF WS-PAGINA < WS-TOTAL-PAGINAS
                       ADD 1 TO WS-PAGINA
                       PERFORM 4000-MOSTRAR-PAGINA
                   ELSE
                       MOVE 'ULTIMA PAGINA' TO WS-MENSAJE-ERROR
                   END-IF
               WHEN WS-CRT-PF12
                   PERFORM 9000-FINALIZAR
                   GOBACK
               WHEN WS-CRT-CLEAR
                   MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                   PERFORM 4000-MOSTRAR-PAGINA
               WHEN OTHER
                   MOVE 'PF7=ANT  PF8=SIG  PF12=SALIR'
                     TO WS-MENSAJE-ERROR
           END-EVALUATE.
           GO TO AUD-LOOP.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM
                           WS-FECHA-HASTA.
           MOVE WS-FECHA TO WS-FECHA-DESDE.
           MOVE SPACES TO WS-FILTRO-USUARIO.
           MOVE 1 TO WS-PAGINA.
           MOVE 0 TO WS-TOTAL-REG.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       2000-PROMPT-FILTROS.
           DISPLAY SCR-PROMPT.
           ACCEPT SCR-PROMPT.
           MOVE WS-FECHA-DESDE TO WS-FECHA-DESDE-DISP.
           MOVE WS-FECHA-HASTA TO WS-FECHA-HASTA-DISP.
      *
       3000-CARGAR-DATOS.
           MOVE 0 TO WS-CONTADOR.
           OPEN INPUT SECURITY-FILE.
           IF FL-FILE-STATUS NOT = '00' AND NOT = '93'
               MOVE 'ERROR AL ABRIR SECURITY' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT.
           IF FL-FILE-STATUS = '93'
               MOVE 'ARCHIVO SECURITY NO EXISTE' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT.
      *
           MOVE 'N' TO WS-EOF-YES.
           MOVE 0 TO SEC-SEQ.
           START SECURITY-FILE KEY IS GREATER THAN SEC-SEQ
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
      *
           PERFORM UNTIL WS-EOF-YES
               READ SECURITY-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               IF SEC-DATE < WS-FECHA-DESDE
                   EXIT PERFORM CYCLE
               END-IF
               IF SEC-DATE > WS-FECHA-HASTA
                   EXIT PERFORM CYCLE
               END-IF
               IF WS-FILTRO-USUARIO NOT = SPACES
                   IF SEC-USER-ID NOT = WS-FILTRO-USUARIO
                       EXIT PERFORM CYCLE
                   END-IF
               END-IF
               ADD 1 TO WS-TOTAL-REG
           END-PERFORM.
      *
           CLOSE SECURITY-FILE.
           COMPUTE WS-TOTAL-PAGINAS = WS-TOTAL-REG / 12 + 1.
           IF WS-TOTAL-PAGINAS < 1
               MOVE 1 TO WS-TOTAL-PAGINAS.
      *
       3000-EXIT.
           EXIT.
      *
       4000-MOSTRAR-PAGINA.
           COMPUTE WS-REG-DESDE =
               (WS-PAGINA - 1) * 12 + 1.
           COMPUTE WS-REG-HASTA = WS-PAGINA * 12.
           IF WS-REG-HASTA > WS-TOTAL-REG
               MOVE WS-TOTAL-REG TO WS-REG-HASTA.
      *
           STRING 'REGISTROS ' WS-REG-DESDE '-' WS-REG-HASTA
                  ' DE ' WS-TOTAL-REG
             INTO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-REPORTE.
      *
       9000-FINALIZAR.
           CLOSE SECURITY-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM SECAUD00.
