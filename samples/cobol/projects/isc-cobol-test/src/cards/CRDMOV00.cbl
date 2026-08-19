      *================================================================*
      * CRDMOV00 - CONSULTA DE MOVIMIENTOS POR TARJETA                *
      * EQUIPO: SISTEMAS DE TARJETAS - 2005                            *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRDMOV00.
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
       FD  CARD-FILE LABEL RECORDS ARE STANDARD RECORD 250 CHARACTERS.
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
           88  WS-CRT-ENTER              VALUE 0013.
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
       01  WS-FILE-STATUS2                PIC X(02).
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'CRDMOV00'.
           05  WS-CARD-NBR                PIC X(16).
           05  WS-DATE-FROM               PIC 9(08).
           05  WS-DATE-TO                 PIC 9(08).
           05  WS-TRN-ACCT                PIC X(10).
           05  WS-TRN-CUST                PIC X(10).
       01  WS-TRN-TABLE.
           05  WS-TRN-ENTRY               OCCURS 20.
               10  WS-T-DATE              PIC 9(08).
               10  WS-T-TYPE              PIC X(03).
               10  WS-T-AMOUNT            PIC S9(13)V99 COMP-3.
               10  WS-T-REFERENCE         PIC X(20).
               10  WS-T-STATUS            PIC X(01).
               10  WS-T-DESC              PIC X(15).
       01  WS-TRN-COUNT                   PIC 9(02).
       01  WS-TRN-INDEX                   PIC 9(02).
       01  WS-TRN-PAGE                    PIC 9(02) VALUE 1.
       01  WS-TRN-MAX-PAGE                PIC 9(02) VALUE 1.
       01  WS-TRN-POS                     PIC 9(02).
       SCREEN SECTION.
       01  SCR-ENTRADA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - MOVIMIENTOS POR TARJETA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 05  PIC X(25) VALUE 'NUMERO TARJETA (16):'.
           05  LINE 05  COL 35  PIC X(16)
               USING WS-CARD-NBR AUTO PROMPT '________________'.
           05  LINE 07  COL 05  PIC X(15) VALUE 'FECHA INICIO:'.
           05  LINE 07  COL 25  PIC 9(08) USING WS-DATE-FROM AUTO.
           05  LINE 08  COL 05  PIC X(15) VALUE 'FECHA FIN:'.
           05  LINE 08  COL 25  PIC 9(08) USING WS-DATE-TO AUTO.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=CONSULTAR  PF12=RETORNAR'.
       01  SCR-LISTADO.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - MOVIMIENTOS DE TARJETA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 03  COL 02  PIC X(60)
               VALUE 'FECHA     TIPO  MONTO      REFERENCIA'.
           05  SCR-TRN-LINE OCCURS 20.
               10  SCR-T-DATE             PIC 9(08) FROM WS-T-DATE.
               10  SCR-T-TYPE             PIC X(03) FROM WS-T-TYPE.
               10  SCR-T-AMOUNT           PIC -ZZZZZZZZZZZZ9.99
                                           FROM WS-T-AMOUNT.
               10  SCR-T-REF              PIC X(20) FROM WS-T-REFERENCE.
               10  SCR-T-STATUS           PIC X(01) FROM WS-T-STATUS.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'PF7=PAG-ANT  PF8=PAG-SIG  PF12=RETORNAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-CARD-NBR WS-DATE-FROM WS-DATE-TO
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
           MOVE 1 TO WS-TRN-PAGE.
           PERFORM 4000-CARGAR-MOVIMIENTOS.
           IF WS-TRN-COUNT = 0
               MOVE 'NO SE ENCONTRARON MOVIMIENTOS' TO WS-MENSAJE
               GO TO 0100-ENTRADA.
       0200-LISTADO.
           PERFORM 2100-PANTALLA-LISTADO.
           ACCEPT SCR-LISTADO.
           IF WS-CRT-PF7 AND WS-TRN-PAGE > 1
               SUBTRACT 1 FROM WS-TRN-PAGE
               PERFORM 4000-CARGAR-MOVIMIENTOS
               GO TO 0200-LISTADO.
           IF WS-CRT-PF8 AND WS-TRN-PAGE < WS-TRN-MAX-PAGE
               ADD 1 TO WS-TRN-PAGE
               PERFORM 4000-CARGAR-MOVIMIENTOS
               GO TO 0200-LISTADO.
           IF WS-CRT-PF12 GO TO 0100-ENTRADA.
           GO TO 0200-LISTADO.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE WS-FECHA TO WS-DATE-TO.
           MOVE 20000000 TO WS-DATE-FROM.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       2000-PANTALLA-ENTRADA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-ENTRADA.
       2100-PANTALLA-LISTADO.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-LISTADO.
       3000-LEER-TARJETA.
           OPEN I-O CARD-FILE.
           IF WS-FILE-STATUS NOT = '00' GOTO 3000-EXIT.
           MOVE WS-CARD-NBR TO CRD-NBR.
           READ CARD-FILE KEY IS CRD-NBR
               INVALID KEY CLOSE CARD-FILE GOTO 3000-EXIT.
           MOVE CRD-ACCOUNT-NBR TO WS-TRN-ACCT.
           MOVE CRD-CUSTOMER-ID TO WS-TRN-CUST.
           CLOSE CARD-FILE.
       3000-EXIT. EXIT.
       4000-CARGAR-MOVIMIENTOS.
           MOVE 0 TO WS-TRN-COUNT.
           MOVE 1 TO WS-TRN-INDEX.
           OPEN INPUT TRANLOG-FILE.
           IF WS-FILE-STATUS2 NOT = '00' GOTO 4000-EXIT.
           MOVE 0 TO TRN-SEQ.
           START TRANLOG-FILE KEY NOT < TRN-SEQ
               INVALID KEY CLOSE TRANLOG-FILE GOTO 4000-EXIT.
       4100-READ-NEXT.
           READ TRANLOG-FILE NEXT RECORD
               AT END CLOSE TRANLOG-FILE GOTO 4000-EXIT.
           IF TRN-ACCOUNT-NBR NOT = WS-TRN-ACCT
               AND TRN-CUSTOMER-ID NOT = WS-TRN-CUST
               GOTO 4100-READ-NEXT.
           IF TRN-DATE < WS-DATE-FROM OR TRN-DATE > WS-DATE-TO
               GOTO 4100-READ-NEXT.
           ADD 1 TO WS-TRN-COUNT.
           IF WS-TRN-COUNT > ((WS-TRN-PAGE - 1) * 20)
               AND WS-TRN-COUNT <= (WS-TRN-PAGE * 20)
               MOVE TRN-DATE TO WS-T-DATE(WS-TRN-INDEX)
               MOVE TRN-TYPE TO WS-T-TYPE(WS-TRN-INDEX)
               MOVE TRN-AMOUNT TO WS-T-AMOUNT(WS-TRN-INDEX)
               MOVE TRN-REFERENCE TO WS-T-REFERENCE(WS-TRN-INDEX)
               MOVE TRN-STATUS TO WS-T-STATUS(WS-TRN-INDEX)
               MOVE TRN-DESCRIPTION TO WS-T-DESC(WS-TRN-INDEX)
               ADD 1 TO WS-TRN-INDEX.
           GOTO 4100-READ-NEXT.
       4000-EXIT.
           COMPUTE WS-TRN-MAX-PAGE = (WS-TRN-COUNT / 20) + 1.
           STRING 'PAG ' WS-TRN-PAGE ' DE ' WS-TRN-MAX-PAGE
             INTO WS-MENSAJE.
           EXIT.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM CRDMOV00.
