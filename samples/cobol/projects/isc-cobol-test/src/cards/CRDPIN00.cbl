      *================================================================*
      * CRDPIN00 - ADMINISTRACION DE PIN                              *
      * EQUIPO: SISTEMAS DE TARJETAS - 2005                            *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRDPIN00.
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
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
           88  FS-NOT-FOUND               VALUE '23'.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'CRDPIN00'.
           05  WS-CARD-NBR                PIC X(16).
           05  WS-PIN-ACTUAL              PIC X(06).
           05  WS-PIN-NUEVO               PIC X(06).
           05  WS-PIN-CONFIRMA            PIC X(06).
           05  WS-AUDIT-DATA              PIC X(60).
           05  WS-PIN-VALIDO              PIC X(01).
               88  WS-PIN-OK              VALUE 'S'.
       SCREEN SECTION.
       01  SCR-ENTRADA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - ADMINISTRACION DE PIN'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 05  PIC X(25) VALUE 'NUMERO TARJETA (16):'.
           05  LINE 05  COL 35  PIC X(16)
               USING WS-CARD-NBR AUTO PROMPT '________________'.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=CONTINUAR  PF12=RETORNAR'.
       01  SCR-PIN-ACTUAL.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - VERIFICACION DE PIN'.
           05  LINE 05  COL 05  PIC X(25) VALUE 'INGRESE PIN ACTUAL:'.
           05  LINE 05  COL 35  PIC X(06)
               USING WS-PIN-ACTUAL AUTO SECURE PROMPT '______'.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
               BLINK.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=VERIFICAR  PF12=CANCELAR'.
       01  SCR-PIN-NUEVO.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - NUEVO PIN'.
           05  LINE 05  COL 05  PIC X(25) VALUE 'INGRESE NUEVO PIN:'.
           05  LINE 05  COL 35  PIC X(06)
               USING WS-PIN-NUEVO AUTO SECURE PROMPT '______'.
           05  LINE 07  COL 05  PIC X(25) VALUE 'CONFIRME NUEVO PIN:'.
           05  LINE 07  COL 35  PIC X(06)
               USING WS-PIN-CONFIRMA AUTO SECURE PROMPT '______'.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
               BLINK.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=CONFIRMAR  PF12=CANCELAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-CARD-NBR WS-PIN-ACTUAL
                          WS-PIN-NUEVO WS-PIN-CONFIRMA
                          WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
       0100-ENTRADA.
           PERFORM 2000-PANTALLA-ENTRADA.
           ACCEPT SCR-ENTRADA.
           IF WS-CRT-PF12 GO TO 9000-EXIT.
           IF WS-CARD-NBR = SPACES
               MOVE 'INGRESE NUMERO DE TARJETA' TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
           PERFORM 3000-LEER-TARJETA.
           IF FS-NOT-FOUND
               MOVE 'TARJETA NO ENCONTRADA' TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
           IF CRD-PIN-BLOCKED = 'Y'
               MOVE 'PIN BLOQUEADO - CONTACTE SUPERVISOR'
                 TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
           PERFORM 2100-PANTALLA-PIN-ACTUAL.
           ACCEPT SCR-PIN-ACTUAL.
           IF WS-CRT-PF12 GO TO 0100-ENTRADA.
           IF WS-PIN-ACTUAL = SPACES
               MOVE 'INGRESE EL PIN ACTUAL' TO WS-MENSAJE-ERROR
               GO TO 2100-PANTALLA-PIN-ACTUAL.
           IF WS-PIN-ACTUAL NOT = CRD-PIN-OFFSET
               MOVE 'PIN ACTUAL INCORRECTO' TO WS-MENSAJE-ERROR
               ADD 1 TO CRD-PIN-TRIES
               IF CRD-PIN-TRIES > 3
                   MOVE 'Y' TO CRD-PIN-BLOCKED
                   REWRITE CARD-RECORD
                   MOVE 'PIN BLOQUEADO' TO WS-MENSAJE-ERROR
               END-IF
               GO TO 0100-ENTRADA.
           PERFORM 2200-PANTALLA-PIN-NUEVO.
           ACCEPT SCR-PIN-NUEVO.
           IF WS-CRT-PF12 GO TO 0100-ENTRADA.
           IF WS-PIN-NUEVO = SPACES OR WS-PIN-CONFIRMA = SPACES
               MOVE 'INGRESE Y CONFIRME EL NUEVO PIN'
                 TO WS-MENSAJE-ERROR
               GO TO 2200-PANTALLA-PIN-NUEVO.
           IF WS-PIN-NUEVO NOT = WS-PIN-CONFIRMA
               MOVE 'LOS PINES NO COINCIDEN' TO WS-MENSAJE-ERROR
               GO TO 2200-PANTALLA-PIN-NUEVO.
           IF WS-PIN-NUEVO = WS-PIN-ACTUAL
               MOVE 'NUEVO PIN DEBE SER DIFERENTE'
                 TO WS-MENSAJE-ERROR
               GO TO 2200-PANTALLA-PIN-NUEVO.
           MOVE WS-PIN-NUEVO TO CRD-PIN-OFFSET.
           MOVE WS-FECHA TO CRD-DATE-LAST-PIN-CHG.
           MOVE 0 TO CRD-PIN-TRIES.
           MOVE 'N' TO CRD-PIN-BLOCKED.
           REWRITE CARD-RECORD.
           IF WS-FILE-STATUS = '00'
               MOVE 'PIN CAMBIADO EXITOSAMENTE' TO WS-MENSAJE
               STRING 'CAMBIO PIN TARJETA ' CRD-NBR
                 INTO WS-AUDIT-DATA
               CALL 'AUDTRL00' USING WS-PROGRAMA WS-AUDIT-DATA
           ELSE
               MOVE 'ERROR AL ACTUALIZAR PIN' TO WS-MENSAJE-ERROR.
           CLOSE CARD-FILE.
           GO TO 0100-ENTRADA.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'INGRESE NUMERO DE TARJETA' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       2000-PANTALLA-ENTRADA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-ENTRADA.
       2100-PANTALLA-PIN-ACTUAL.
           PERFORM 1100-LIMPIAR.
           MOVE SPACES TO WS-PIN-ACTUAL WS-MENSAJE-ERROR.
           DISPLAY SCR-PIN-ACTUAL.
       2200-PANTALLA-PIN-NUEVO.
           PERFORM 1100-LIMPIAR.
           MOVE SPACES TO WS-PIN-NUEVO WS-PIN-CONFIRMA
                          WS-MENSAJE-ERROR.
           DISPLAY SCR-PIN-NUEVO.
       3000-LEER-TARJETA.
           OPEN I-O CARD-FILE.
           IF WS-FILE-STATUS NOT = '00' GOTO 3000-EXIT.
           MOVE WS-CARD-NBR TO CRD-NBR.
           READ CARD-FILE KEY IS CRD-NBR
               INVALID KEY CLOSE CARD-FILE GOTO 3000-EXIT.
       3000-EXIT. EXIT.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM CRDPIN00.
