      *================================================================*
      * CRDBLK00 - BLOQUEO/DESBLOQUEO DE TARJETA                      *
      * EQUIPO: SISTEMAS DE TARJETAS - 2006                            *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRDBLK00.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CARD-FILE
               ASSIGN TO 'CARD.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CRD-NBR
               FILE STATUS IS WS-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  CARD-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 250 CHARACTERS.
       01  CARD-RECORD.
           05  CRD-NBR                     PIC X(16).
           05  CRD-EMBOSSED-NAME           PIC X(30).
           05  CRD-TYPE                    PIC X(02).
           05  CRD-PRODUCT                 PIC X(04).
           05  CRD-CUSTOMER-ID             PIC X(10).
           05  CRD-ACCOUNT-NBR             PIC X(10).
           05  CRD-BRANCH                  PIC X(04).
           05  CRD-DATE-ISSUE              PIC 9(08).
           05  CRD-DATE-EXPIRY             PIC 9(08).
           05  CRD-DATE-LAST-USED          PIC 9(08).
           05  CRD-DATE-LAST-PIN-CHG       PIC 9(08).
           05  CRD-LIMIT-CASH              PIC 9(09)V99 COMP-3.
           05  CRD-LIMIT-PURCHASE          PIC 9(09)V99 COMP-3.
           05  CRD-LIMIT-DAILY-CASH        PIC 9(09)V99 COMP-3.
           05  CRD-LIMIT-DAILY-PURCHASE    PIC 9(09)V99 COMP-3.
           05  CRD-LIMIT-MONTHLY           PIC 9(09)V99 COMP-3.
           05  CRD-BALANCE-CURRENT         PIC S9(09)V99 COMP-3.
           05  CRD-BALANCE-AVAILABLE       PIC S9(09)V99 COMP-3.
           05  CRD-BALANCE-PAST-DUE        PIC S9(09)V99 COMP-3.
           05  CRD-MINIMUM-PAYMENT         PIC S9(09)V99 COMP-3.
           05  CRD-INTEREST-RATE           PIC 9(03)V9(04) COMP-3.
           05  CRD-CUT-DAY                 PIC 9(02).
           05  CRD-PAYMENT-DAY             PIC 9(02).
           05  CRD-PIN-OFFSET              PIC X(06).
           05  CRD-CVV                     PIC X(04).
           05  CRD-PIN-TRIES               PIC 9(02).
           05  CRD-PIN-BLOCKED             PIC X(01).
           05  CRD-STATUS                  PIC X(01).
           05  CRD-REASON-LAST-CHANGE      PIC X(40).
           05  CRD-ISSUE-COUNT             PIC 9(02).
           05  CRD-ATM-DAILY-COUNT         PIC 9(03).
           05  CRD-ATM-DAILY-AMOUNT        PIC 9(09)V99 COMP-3.
           05  CRD-CONTACTLESS             PIC X(01).
           05  CRD-FILLER                  PIC X(15).
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
           88  WS-CRT-CLEAR              VALUE 0000.
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
           88  FS-NOT-FOUND               VALUE '23'.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-SUCURSAL                PIC X(04).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'CRDBLK00'.
           05  WS-CARD-NBR                PIC X(16).
           05  WS-BLOCK-REASON            PIC X(02).
           05  WS-BLOCK-REASON-DISP       PIC X(30).
           05  WS-CONFIRMA                PIC X(01).
           05  WS-AUDIT-DATA              PIC X(60).
           05  WS-FLAG-ERROR              PIC X(01).
               88  WS-HAY-ERROR           VALUE 'S'.
       SCREEN SECTION.
       01  SCR-ENTRADA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - BLOQUEO DE TARJETA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 05  PIC X(25) VALUE 'NUMERO TARJETA (16):'.
           05  LINE 05  COL 35  PIC X(16)
               USING WS-CARD-NBR AUTO PROMPT '________________'.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
               BLINK.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=ACEPTAR  PF12=RETORNAR'.
       01  SCR-REASON.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - MOTIVO DE BLOQUEO'.
           05  LINE 04  COL 10  PIC X(30) VALUE 'SELECCIONE MOTIVO:'.
           05  LINE 06  COL 15  PIC X(30) VALUE '1 - PERDIDA'.
           05  LINE 07  COL 15  PIC X(30) VALUE '2 - ROBO'.
           05  LINE 08  COL 15  PIC X(30) VALUE '3 - FRAUDE'.
           05  LINE 09  COL 15  PIC X(30) VALUE '4 - TARJETA DANADA'.
           05  LINE 11  COL 15  PIC X(20) VALUE 'MOTIVO (1-4):'.
           05  LINE 11  COL 35  PIC X(02)
               USING WS-BLOCK-REASON AUTO.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
               BLINK.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=CONFIRMAR  PF12=CANCELAR'.
       01  SCR-CONFIRMA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - CONFIRMAR BLOQUEO'.
           05  LINE 05  COL 10  PIC X(25) VALUE 'TARJETA:'.
           05  LINE 05  COL 30  PIC X(16) FROM WS-CARD-NBR.
           05  LINE 06  COL 10  PIC X(25) VALUE 'MOTIVO:'.
           05  LINE 06  COL 30  PIC X(30) FROM WS-BLOCK-REASON-DISP.
           05  LINE 08  COL 10  PIC X(40)
               VALUE 'CONFIRMA EL BLOQUEO (S/N)?'.
           05  LINE 08  COL 55  PIC X(01)
               USING WS-CONFIRMA AUTO.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'S=BLOQUEAR  N=CANCELAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-CARD-NBR WS-MENSAJE WS-MENSAJE-ERROR
                          WS-BLOCK-REASON WS-CONFIRMA.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
       ENTRY-LOOP.
           PERFORM 2000-PANTALLA-ENTRADA.
           ACCEPT SCR-ENTRADA.
           IF WS-CRT-PF12
               GO TO 9000-EXIT.
           IF WS-CRT-CLEAR
               MOVE SPACES TO WS-CARD-NBR WS-MENSAJE WS-MENSAJE-ERROR
               GO TO ENTRY-LOOP.
           IF NOT WS-CRT-ENTER
               MOVE 'USE ENTER' TO WS-MENSAJE-ERROR
               GO TO ENTRY-LOOP.
           IF WS-CARD-NBR = SPACES
               MOVE 'INGRESE NUMERO DE TARJETA' TO WS-MENSAJE-ERROR
               GO TO ENTRY-LOOP.
           PERFORM 3000-LEER-TARJETA.
           IF FS-NOT-FOUND
               MOVE 'TARJETA NO ENCONTRADA' TO WS-MENSAJE-ERROR
               GO TO ENTRY-LOOP.
           IF CRD-STATUS = 'C' OR 'E'
               MOVE 'TARJETA CANCELADA O VENCIDA'
                 TO WS-MENSAJE-ERROR
               GO TO ENTRY-LOOP.
           PERFORM 2100-PANTALLA-REASON.
           ACCEPT SCR-REASON.
           IF WS-CRT-PF12
               GO TO ENTRY-LOOP.
           PERFORM 4000-VALIDAR-MOTIVO.
           IF WS-HAY-ERROR
               GO TO 2100-PANTALLA-REASON.
           MOVE 'S' TO WS-CONFIRMA.
           PERFORM 2200-PANTALLA-CONFIRMA.
           ACCEPT SCR-CONFIRMA.
           IF WS-CONFIRMA = 'S' OR 's'
               PERFORM 5000-PROCESAR-BLOQUEO
               MOVE 'TARJETA BLOQUEADA' TO WS-MENSAJE
           ELSE
               MOVE 'OPERACION CANCELADA' TO WS-MENSAJE.
           GO TO ENTRY-LOOP.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'INGRESE NUMERO DE TARJETA A BLOQUEAR'
             TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       2000-PANTALLA-ENTRADA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-ENTRADA.
       2100-PANTALLA-REASON.
           PERFORM 1100-LIMPIAR.
           MOVE SPACES TO WS-BLOCK-REASON WS-MENSAJE-ERROR.
           DISPLAY SCR-REASON.
       2200-PANTALLA-CONFIRMA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-CONFIRMA.
       3000-LEER-TARJETA.
           OPEN I-O CARD-FILE.
           IF WS-FILE-STATUS NOT = '00'
               GOTO 3000-EXIT.
           MOVE WS-CARD-NBR TO CRD-NBR.
           READ CARD-FILE KEY IS CRD-NBR
               INVALID KEY
                   CLOSE CARD-FILE
                   GOTO 3000-EXIT.
       3000-EXIT. EXIT.
       4000-VALIDAR-MOTIVO.
           MOVE 'N' TO WS-FLAG-ERROR.
           MOVE SPACES TO WS-MENSAJE-ERROR.
           IF WS-BLOCK-REASON = SPACES
               MOVE 'SELECCIONE UN MOTIVO (1-4)' TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR
               GOTO 4000-EXIT.
           EVALUATE WS-BLOCK-REASON
               WHEN '1'
                   MOVE 'PERDIDA' TO WS-BLOCK-REASON-DISP
                   MOVE 'L' TO CRD-STATUS
                   MOVE 'REPORTADA COMO PERDIDA'
                     TO CRD-REASON-LAST-CHANGE
               WHEN '2'
                   MOVE 'ROBO' TO WS-BLOCK-REASON-DISP
                   MOVE 'S' TO CRD-STATUS
                   MOVE 'REPORTADA COMO ROBADA'
                     TO CRD-REASON-LAST-CHANGE
               WHEN '3'
                   MOVE 'FRAUDE' TO WS-BLOCK-REASON-DISP
                   MOVE 'B' TO CRD-STATUS
                   MOVE 'BLOQUEADA POR FRAUDE'
                     TO CRD-REASON-LAST-CHANGE
               WHEN '4'
                   MOVE 'TARJETA DANADA' TO WS-BLOCK-REASON-DISP
                   MOVE 'B' TO CRD-STATUS
                   MOVE 'BLOQUEADA POR DANO FISICO'
                     TO CRD-REASON-LAST-CHANGE
               WHEN OTHER
                   MOVE 'MOTIVO INVALIDO (USE 1-4)'
                     TO WS-MENSAJE-ERROR
                   MOVE 'S' TO WS-FLAG-ERROR.
       4000-EXIT. EXIT.
       5000-PROCESAR-BLOQUEO.
           REWRITE CARD-RECORD.
           IF WS-FILE-STATUS NOT = '00'
               MOVE 'ERROR AL ACTUALIZAR' TO WS-MENSAJE-ERROR
               CLOSE CARD-FILE
               GOTO 5000-EXIT.
           CLOSE CARD-FILE.
           STRING 'BLOQUEO TARJETA ' CRD-NBR ' MOTIVO: '
                  WS-BLOCK-REASON-DISP
             INTO WS-AUDIT-DATA.
           CALL 'AUDTRL00' USING WS-PROGRAMA WS-AUDIT-DATA.
       5000-EXIT. EXIT.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM CRDBLK00.
