      *================================================================*
      * CRDREP00 - REEMPLAZO DE TARJETA                               *
      * EQUIPO: SISTEMAS DE TARJETAS - 2006                            *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRDREP00.
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
           SELECT TRANLOG-FILE
               ASSIGN TO 'TRANLOG.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TRN-SEQ
               FILE STATUS IS WS-FILE-STATUS2.
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
       FD  TRANLOG-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 150 CHARACTERS.
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
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
           88  WS-CRT-CLEAR              VALUE 0000.
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
           88  FS-NOT-FOUND               VALUE '23'.
       01  WS-FILE-STATUS2                PIC X(02).
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-SUCURSAL                PIC X(04).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'CRDREP00'.
           05  WS-CARD-NBR                PIC X(16).
           05  WS-NEW-CARD-NBR            PIC X(16).
           05  WS-CONFIRMA                PIC X(01).
           05  WS-AUDIT-DATA              PIC X(60).
       SCREEN SECTION.
       01  SCR-ENTRADA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - REEMPLAZO DE TARJETA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 05  PIC X(25) VALUE 'NUMERO TARJETA (16):'.
           05  LINE 05  COL 35  PIC X(16)
               USING WS-CARD-NBR AUTO PROMPT '________________'.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=PROCESAR  PF12=RETORNAR'.
       01  SCR-RESULTADO.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - REEMPLAZO COMPLETADO'.
           05  LINE 05  COL 05  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=CONTINUAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-CARD-NBR WS-CONFIRMA
                          WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
       0100-ENTRADA.
           PERFORM 2000-PANTALLA-ENTRADA.
           ACCEPT SCR-ENTRADA.
           IF WS-CRT-PF12
               GO TO 9000-EXIT.
           IF WS-CARD-NBR = SPACES
               MOVE 'INGRESE NUMERO DE TARJETA' TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
           PERFORM 3000-LEER-TARJETA.
           IF FS-NOT-FOUND
               MOVE 'TARJETA NO ENCONTRADA' TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
           IF CRD-STATUS NOT = 'L' AND NOT = 'S' AND NOT = 'B'
               MOVE 'TARJETA DEBE ESTAR PERDIDA/ROBADA/BLOQUEADA'
                 TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
           PERFORM 4000-GENERAR-NUEVA.
           MOVE 'S' TO WS-CONFIRMA.
           MOVE 'CONFIRMA REEMPLAZO?' TO WS-MENSAJE.
           ACCEPT WS-CONFIRMA FROM CRT.
           IF WS-CONFIRMA = 'S' OR 's'
               PERFORM 5000-PROCESAR-REEMPLAZO.
           DISPLAY SCR-RESULTADO.
           ACCEPT SCR-RESULTADO.
           GO TO 0100-ENTRADA.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'INGRESE TARJETA PERDIDA/ROBADA' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       2000-PANTALLA-ENTRADA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-ENTRADA.
       3000-LEER-TARJETA.
           OPEN I-O CARD-FILE.
           IF WS-FILE-STATUS NOT = '00' GOTO 3000-EXIT.
           MOVE WS-CARD-NBR TO CRD-NBR.
           READ CARD-FILE KEY IS CRD-NBR
               INVALID KEY CLOSE CARD-FILE GOTO 3000-EXIT.
       3000-EXIT. EXIT.
       4000-GENERAR-NUEVA.
           ADD 1 TO CRD-ISSUE-COUNT.
           STRING '4' CRD-BRANCH '52' CRD-ISSUE-COUNT '0000001'
             INTO WS-NEW-CARD-NBR.
           MOVE WS-FECHA TO CRD-DATE-ISSUE.
           ADD 30000 TO WS-FECHA GIVING CRD-DATE-EXPIRY.
           MOVE WS-FECHA TO CRD-DATE-LAST-PIN-CHG.
           MOVE 'N' TO CRD-PIN-BLOCKED.
           MOVE 0 TO CRD-PIN-TRIES.
           MOVE '1234' TO CRD-CVV.
           MOVE 'ABCDEF' TO CRD-PIN-OFFSET.
           MOVE 'A' TO CRD-STATUS.
           MOVE WS-NEW-CARD-NBR TO CRD-NBR.
       5000-PROCESAR-REEMPLAZO.
           REWRITE CARD-RECORD.
           IF WS-FILE-STATUS NOT = '00'
               MOVE 'ERROR AL REEMPLAZAR' TO WS-MENSAJE-ERROR
               CLOSE CARD-FILE
               GOTO 5000-EXIT.
           CLOSE CARD-FILE.
           OPEN I-O TRANLOG-FILE.
           IF WS-FILE-STATUS2 = '00'
               MOVE 9999999999 TO TRN-SEQ
               MOVE WS-FECHA TO TRN-DATE
               MOVE WS-HORA TO TRN-TIME
               MOVE 'REP' TO TRN-TYPE
               MOVE CRD-ACCOUNT-NBR TO TRN-ACCOUNT-NBR
               MOVE CRD-CUSTOMER-ID TO TRN-CUSTOMER-ID
               MOVE 0 TO TRN-AMOUNT TRN-AMOUNT-TOTAL
               MOVE WS-SUCURSAL TO TRN-BRANCH
               MOVE WS-USUARIO TO TRN-USER-ID
               MOVE 'REEMPLAZO TARJETA' TO TRN-DESCRIPTION
               MOVE 'C' TO TRN-STATUS
               WRITE TRANLOG-RECORD
               CLOSE TRANLOG-FILE.
           STRING 'REEMPLAZO TARJETA ' WS-NEW-CARD-NBR
             INTO WS-AUDIT-DATA.
           CALL 'AUDTRL00' USING WS-PROGRAMA WS-AUDIT-DATA.
           MOVE 'NUEVA TARJETA GENERADA' TO WS-MENSAJE.
       5000-EXIT. EXIT.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM CRDREP00.
