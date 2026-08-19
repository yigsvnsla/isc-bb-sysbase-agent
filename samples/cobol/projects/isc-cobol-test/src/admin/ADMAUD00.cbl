      *================================================================*
      * ADMAUD00 - CONSULTA DE PISTA DE AUDITORIA                     *
      * EQUIPO: AUDITORIA INTERNA - 2001                               *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADMAUD00.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AUDITLOG-FILE
               ASSIGN TO 'AUDITLOG.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS AUD-SEQ
               FILE STATUS IS WS-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  AUDITLOG-FILE
           LABEL RECORDS ARE STANDARD RECORD 200 CHARACTERS.
       01  AUDITLOG-RECORD.
           05  AUD-SEQ                     PIC 9(10).
           05  AUD-DATE                    PIC 9(08).
           05  AUD-TIME                    PIC 9(06).
           05  AUD-USUARIO                 PIC X(08).
           05  AUD-TERMINAL                PIC X(08).
           05  AUD-PROGRAMA                PIC X(08).
           05  AUD-EVENTO                  PIC X(02).
           05  AUD-ENTITY-TYPE             PIC X(02).
           05  AUD-ENTITY-KEY              PIC X(20).
           05  AUD-CAMPO-ANTERIOR          PIC X(60).
           05  AUD-CAMPO-NUEVO             PIC X(60).
           05  AUD-RESULTADO               PIC X(01).
           05  AUD-OBSERVACIONES           PIC X(30).
           05  AUD-FILLER                  PIC X(15).
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF6                VALUE 1006.
           88  WS-CRT-PF7                VALUE 1007.
           88  WS-CRT-PF8                VALUE 1008.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'ADMAUD00'.
           05  WS-DATE-FROM               PIC 9(08).
           05  WS-DATE-TO                 PIC 9(08).
       01  WS-AUDIT-TABLE.
           05  WS-AUD-ENTRY               OCCURS 15.
               10  WS-A-SEQ               PIC 9(10).
               10  WS-A-DATE              PIC 9(08).
               10  WS-A-TIME              PIC 9(06).
               10  WS-A-USER              PIC X(08).
               10  WS-A-PROG              PIC X(08).
               10  WS-A-EVENT             PIC X(02).
               10  WS-A-ENT-TYPE          PIC X(02).
               10  WS-A-ENT-KEY           PIC X(20).
       01  WS-AUD-COUNT                   PIC 9(02).
       01  WS-AUD-INDEX                   PIC 9(02).
       01  WS-AUD-PAGE                    PIC 9(02) VALUE 1.
       01  WS-AUD-MAX-PAGE                PIC 9(02) VALUE 1.
       01  WS-AUD-TOTAL                   PIC 9(04).
       01  WS-I                           PIC 9(02).
       SCREEN SECTION.
       01  SCR-ENTRADA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - CONSULTA DE AUDITORIA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 05  PIC X(15) VALUE 'FECHA INICIO:'.
           05  LINE 05  COL 25  PIC 9(08) USING WS-DATE-FROM AUTO.
           05  LINE 06  COL 05  PIC X(15) VALUE 'FECHA FIN:'.
           05  LINE 06  COL 25  PIC 9(08) USING WS-DATE-TO AUTO.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=CONSULTAR  PF12=RETORNAR'.
       01  SCR-LISTADO.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - REGISTROS DE AUDITORIA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 03  COL 02  PIC X(60)
               VALUE 'SECUENCIA  FECHA     HORA   USUARIO  PROGRAMA'.
           05  SCR-AUD-LINE OCCURS 15.
               10  SCR-A-SEQ    PIC 9(10) FROM WS-A-SEQ.
               10  SCR-A-DATE   PIC 9(08) FROM WS-A-DATE.
               10  SCR-A-TIME   PIC 9(06) FROM WS-A-TIME.
               10  SCR-A-USER   PIC X(08) FROM WS-A-USER.
               10  SCR-A-PROG   PIC X(08) FROM WS-A-PROG.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'PF3=DETALLE  PF7=PAG-ANT  PF8=PAG-SIG  PF12=SALIR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
       0100-ENTRADA.
           PERFORM 2000-PANTALLA-ENTRADA.
           ACCEPT SCR-ENTRADA.
           IF WS-CRT-PF12 GO TO 9000-EXIT.
           MOVE 1 TO WS-AUD-PAGE.
           PERFORM 3000-CARGAR.
           IF WS-AUD-COUNT = 0
               MOVE 'NO HAY REGISTROS' TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
       0200-LISTADO.
           PERFORM 2100-PANTALLA-LISTADO.
           ACCEPT SCR-LISTADO.
           IF WS-CRT-PF3
               PERFORM 4000-DETALLE
               GO TO 0200-LISTADO.
           IF WS-CRT-PF7 AND WS-AUD-PAGE > 1
               SUBTRACT 1 FROM WS-AUD-PAGE
               PERFORM 3000-CARGAR
               GO TO 0200-LISTADO.
           IF WS-CRT-PF8 AND WS-AUD-PAGE < WS-AUD-MAX-PAGE
               ADD 1 TO WS-AUD-PAGE
               PERFORM 3000-CARGAR
               GO TO 0200-LISTADO.
           IF WS-CRT-PF12 GO TO 0100-ENTRADA.
           GO TO 0200-LISTADO.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 20000101 TO WS-DATE-FROM.
           MOVE WS-FECHA TO WS-DATE-TO.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       2000-PANTALLA-ENTRADA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-ENTRADA.
       2100-PANTALLA-LISTADO.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-LISTADO.
       3000-CARGAR.
           MOVE 0 TO WS-AUD-COUNT.
           MOVE 0 TO WS-AUD-TOTAL.
           MOVE 1 TO WS-AUD-INDEX.
           OPEN INPUT AUDITLOG-FILE.
           IF WS-FILE-STATUS NOT = '00' GOTO 3000-EXIT.
           MOVE 0 TO AUD-SEQ.
           START AUDITLOG-FILE KEY NOT < AUD-SEQ
               INVALID KEY CLOSE AUDITLOG-FILE GOTO 3000-EXIT.
       3100-READ.
           READ AUDITLOG-FILE NEXT RECORD
               AT END CLOSE AUDITLOG-FILE GOTO 3000-EXIT.
           IF AUD-DATE < WS-DATE-FROM OR AUD-DATE > WS-DATE-TO
               GOTO 3100-READ.
           ADD 1 TO WS-AUD-TOTAL.
           IF WS-AUD-TOTAL > ((WS-AUD-PAGE - 1) * 15)
               AND WS-AUD-TOTAL <= (WS-AUD-PAGE * 15)
               MOVE AUD-SEQ TO WS-A-SEQ(WS-AUD-INDEX)
               MOVE AUD-DATE TO WS-A-DATE(WS-AUD-INDEX)
               MOVE AUD-TIME TO WS-A-TIME(WS-AUD-INDEX)
               MOVE AUD-USUARIO TO WS-A-USER(WS-AUD-INDEX)
               MOVE AUD-PROGRAMA TO WS-A-PROG(WS-AUD-INDEX)
               MOVE AUD-EVENTO TO WS-A-EVENT(WS-AUD-INDEX)
               MOVE AUD-ENTITY-TYPE TO WS-A-ENT-TYPE(WS-AUD-INDEX)
               MOVE AUD-ENTITY-KEY TO WS-A-ENT-KEY(WS-AUD-INDEX)
               ADD 1 TO WS-AUD-INDEX.
           GOTO 3100-READ.
       3000-EXIT.
           COMPUTE WS-AUD-MAX-PAGE = (WS-AUD-TOTAL / 15) + 1.
           STRING 'REG: ' WS-AUD-TOTAL ' PAG ' WS-AUD-PAGE
                  ' DE ' WS-AUD-MAX-PAGE INTO WS-MENSAJE.
           SUBTRACT 1 FROM WS-AUD-INDEX GIVING WS-AUD-COUNT.
           EXIT.
       4000-DETALLE.
           DISPLAY ' CAMPO ANTERIOR: ' AUD-CAMPO-ANTERIOR.
           DISPLAY ' '.
           DISPLAY ' CAMPO NUEVO: ' AUD-CAMPO-NUEVO.
           DISPLAY ' '.
           DISPLAY ' PRESIONE ENTER'.
           ACCEPT WS-RETCODE FROM CRT.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM ADMAUD00.
