      *================================================================*
      * CRDALR00 - CONSULTA DE ALERTAS DE TARJETA                     *
      * EQUIPO: SISTEMAS DE TARJETAS - 2005                            *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRDALR00.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRANLOG-FILE
               ASSIGN TO 'TRANLOG.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TRN-SEQ
               FILE STATUS IS WS-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  TRANLOG-FILE
           LABEL RECORDS ARE STANDARD RECORD 150 CHARACTERS.
       01  TRANLOG-RECORD.
           05  TRN-SEQ                     PIC 9(10).
           05  TRN-DATE                    PIC 9(08).
           05  TRN-TIME                    PIC 9(06).
           05  TRN-TYPE                    PIC X(03).
           05  TRN-ACCOUNT-NBR             PIC X(10).
           05  TRN-ACCOUNT-DEST            PIC X(10).
           05  TRN-CUSTOMER-ID             PIC X(10).
           05  TRN-AMOUNT                  PIC S9(13)V99 COMP-3.
           05  TRN-AMOUNT-TAX              PIC S9(09)V99 COMP-3.
           05  TRN-AMOUNT-TOTAL            PIC S9(13)V99 COMP-3.
           05  TRN-AMOUNT-ORIGINAL         PIC S9(13)V99 COMP-3.
           05  TRN-FEE-AMOUNT              PIC S9(07)V99 COMP-3.
           05  TRN-FEE-CODE                PIC X(04).
           05  TRN-BRANCH                  PIC X(04).
           05  TRN-TELLER-ID               PIC X(08).
           05  TRN-USER-ID                 PIC X(08).
           05  TRN-TERMINAL                PIC X(08).
           05  TRN-CHANNEL                 PIC X(02).
           05  TRN-REFERENCE               PIC X(20).
           05  TRN-CHQ-NBR                 PIC 9(10).
           05  TRN-CHQ-BANK                PIC X(10).
           05  TRN-CHQ-ACCOUNT             PIC X(10).
           05  TRN-STATUS                  PIC X(01).
           05  TRN-REVERSE-SEQ             PIC 9(10).
           05  TRN-DESCRIPTION             PIC X(30).
           05  TRN-FILLER                  PIC X(10).
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF7                VALUE 1007.
           88  WS-CRT-PF8                VALUE 1008.
           88  WS-CRT-PF12               VALUE 1012.
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'CRDALR00'.
           05  WS-UMBRAL-ALTO             PIC S9(13)V99 COMP-3.
       01  WS-ALERT-TABLE.
           05  WS-ALERT-ENTRY             OCCURS 20.
               10  WS-A-DATE              PIC 9(08).
               10  WS-A-TYPE              PIC X(03).
               10  WS-A-AMOUNT            PIC S9(13)V99 COMP-3.
               10  WS-A-ACCOUNT           PIC X(10).
               10  WS-A-REFERENCE         PIC X(20).
               10  WS-A-ALERT-TYPE        PIC X(15).
       01  WS-ALERT-COUNT                 PIC 9(02).
       01  WS-ALERT-INDEX                 PIC 9(02).
       01  WS-ALERT-PAGE                  PIC 9(02) VALUE 1.
       01  WS-ALERT-MAX-PAGE              PIC 9(02) VALUE 1.
       01  WS-TOTAL-ALERTS                PIC 9(04).
       SCREEN SECTION.
       01  SCR-LISTADO.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - ALERTAS DE TARJETAS'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 03  COL 02  PIC X(60)
               VALUE 'FECHA     TIPO  MONTO      ALERTA'.
           05  SCR-ALR-LINE OCCURS 20.
               10  SCR-A-DATE             PIC 9(08) FROM WS-A-DATE.
               10  SCR-A-TYPE             PIC X(03) FROM WS-A-TYPE.
               10  SCR-A-AMOUNT           PIC -ZZZZZZZZZZZZ9.99
                                           FROM WS-A-AMOUNT.
               10  SCR-A-ALERT-TYPE       PIC X(15) FROM WS-A-ALERT-TYPE.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'PF7=PAG-ANT  PF8=PAG-SIG  PF12=RETORNAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
           MOVE 1 TO WS-ALERT-PAGE.
           PERFORM 3000-CARGAR-ALERTAS.
           IF WS-ALERT-COUNT = 0
               MOVE 'NO SE ENCONTRARON ALERTAS' TO WS-MENSAJE
               GO TO 9000-EXIT.
       0200-LISTADO.
           PERFORM 2000-PANTALLA-LISTADO.
           ACCEPT SCR-LISTADO.
           IF WS-CRT-PF7 AND WS-ALERT-PAGE > 1
               SUBTRACT 1 FROM WS-ALERT-PAGE
               PERFORM 3000-CARGAR-ALERTAS
               GO TO 0200-LISTADO.
           IF WS-CRT-PF8 AND WS-ALERT-PAGE < WS-ALERT-MAX-PAGE
               ADD 1 TO WS-ALERT-PAGE
               PERFORM 3000-CARGAR-ALERTAS
               GO TO 0200-LISTADO.
           IF WS-CRT-PF12 GO TO 9000-EXIT.
           GO TO 0200-LISTADO.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 5000 TO WS-UMBRAL-ALTO.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       2000-PANTALLA-LISTADO.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-LISTADO.
       3000-CARGAR-ALERTAS.
           MOVE 0 TO WS-ALERT-COUNT.
           MOVE 0 TO WS-TOTAL-ALERTS.
           MOVE 1 TO WS-ALERT-INDEX.
           OPEN INPUT TRANLOG-FILE.
           IF WS-FILE-STATUS NOT = '00' GOTO 3000-EXIT.
           MOVE 0 TO TRN-SEQ.
           START TRANLOG-FILE KEY NOT < TRN-SEQ
               INVALID KEY CLOSE TRANLOG-FILE GOTO 3000-EXIT.
       3100-READ-LOOP.
           READ TRANLOG-FILE NEXT RECORD
               AT END CLOSE TRANLOG-FILE GOTO 3000-EXIT.
           IF TRN-AMOUNT > WS-UMBRAL-ALTO
               ADD 1 TO WS-TOTAL-ALERTS
               IF WS-TOTAL-ALERTS > ((WS-ALERT-PAGE - 1) * 20)
                   AND WS-TOTAL-ALERTS <= (WS-ALERT-PAGE * 20)
                   MOVE TRN-DATE TO WS-A-DATE(WS-ALERT-INDEX)
                   MOVE TRN-TYPE TO WS-A-TYPE(WS-ALERT-INDEX)
                   MOVE TRN-AMOUNT TO WS-A-AMOUNT(WS-ALERT-INDEX)
                   MOVE TRN-ACCOUNT-NBR TO WS-A-ACCOUNT(WS-ALERT-INDEX)
                   MOVE 'ALTO MONTO' TO WS-A-ALERT-TYPE(WS-ALERT-INDEX)
                   ADD 1 TO WS-ALERT-INDEX
               END-IF.
           GOTO 3100-READ-LOOP.
       3000-EXIT.
           COMPUTE WS-ALERT-MAX-PAGE = (WS-TOTAL-ALERTS / 20) + 1.
           STRING 'ALERTAS: ' WS-TOTAL-ALERTS ' PAG '
                  WS-ALERT-PAGE ' DE ' WS-ALERT-MAX-PAGE
             INTO WS-MENSAJE.
           MOVE WS-ALERT-INDEX TO WS-ALERT-COUNT.
           EXIT.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM CRDALR00.
