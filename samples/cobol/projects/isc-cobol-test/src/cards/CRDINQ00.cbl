      *================================================================*
      * CRDINQ00 - CONSULTA DE TARJETA                                *
      * EQUIPO: SISTEMAS DE TARJETAS - 2005                            *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRDINQ00.
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
               88  CRD-TYPE-DEBITO         VALUE 'DB'.
               88  CRD-TYPE-CREDITO        VALUE 'CR'.
               88  CRD-TYPE-PREPAGO        VALUE 'PP'.
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
               88  CRD-PIN-BLOQ-YES        VALUE 'Y'.
           05  CRD-STATUS                  PIC X(01).
               88  CRD-STATUS-ACTIVE       VALUE 'A'.
               88  CRD-STATUS-BLOCKED      VALUE 'B'.
               88  CRD-STATUS-EXPIRED      VALUE 'E'.
               88  CRD-STATUS-STOLEN       VALUE 'S'.
               88  CRD-STATUS-LOST         VALUE 'L'.
           05  CRD-REASON-LAST-CHANGE      PIC X(40).
           05  CRD-ISSUE-COUNT             PIC 9(02).
           05  CRD-ATM-DAILY-COUNT         PIC 9(03).
           05  CRD-ATM-DAILY-AMOUNT        PIC 9(09)V99 COMP-3.
           05  CRD-CONTACTLESS             PIC X(01).
           05  CRD-FILLER                  PIC X(15).
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF2                VALUE 1002.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
           88  WS-CRT-CLEAR              VALUE 0000.
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
           05  WS-PROGRAMA                PIC X(08) VALUE 'CRDINQ00'.
           05  WS-CARD-NBR                PIC X(16).
           05  WS-CUSTOMER-ID-SRCH        PIC X(10).
           05  WS-DISPLAY-TYPE            PIC X(15).
           05  WS-DISPLAY-PRODUCT         PIC X(15).
           05  WS-DISPLAY-STATUS          PIC X(15).
           05  WS-DISPLAY-CONTACTLESS     PIC X(05).
           05  WS-ISSUE-DATE-DDMM         PIC 9(08).
           05  WS-EXPIRE-DATE-DDMM        PIC 9(08).
       SCREEN SECTION.
       01  SCR-ENTRADA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - CONSULTA DE TARJETA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 02  COL 01  PIC X(80)
               VALUE ' INGRESE NUMERO DE TARJETA O CLIENTE'.
           05  LINE 05  COL 05  PIC X(25) VALUE 'NUMERO TARJETA (16 DIG):'.
           05  LINE 05  COL 35  PIC X(16)
               USING WS-CARD-NBR AUTO PROMPT '________________'.
           05  LINE 07  COL 05  PIC X(20) VALUE 'O BUSCAR POR CLIENTE:'.
           05  LINE 07  COL 30  PIC X(10)
               USING WS-CUSTOMER-ID-SRCH AUTO.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
               BLINK.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=CONSULTAR  PF2=BLOQUEAR  PF12=RETORNAR'.
       01  SCR-DISPLAY.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - DATOS DE TARJETA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 03  COL 02  PIC X(15) VALUE 'TARJETA:'.
           05  LINE 03  COL 15  PIC X(16) FROM CRD-NBR.
           05  LINE 03  COL 45  PIC X(10) VALUE 'TIPO:'.
           05  LINE 03  COL 55  PIC X(15) FROM WS-DISPLAY-TYPE.
           05  LINE 04  COL 02  PIC X(15) VALUE 'TITULAR:'.
           05  LINE 04  COL 15  PIC X(30) FROM CRD-EMBOSSED-NAME.
           05  LINE 04  COL 45  PIC X(10) VALUE 'PRODUCTO:'.
           05  LINE 04  COL 55  PIC X(15) FROM WS-DISPLAY-PRODUCT.
           05  LINE 06  COL 02  PIC X(10) VALUE 'CLIENTE:'.
           05  LINE 06  COL 15  PIC X(10) FROM CRD-CUSTOMER-ID.
           05  LINE 06  COL 45  PIC X(10) VALUE 'CUENTA:'.
           05  LINE 06  COL 55  PIC X(10) FROM CRD-ACCOUNT-NBR.
           05  LINE 07  COL 02  PIC X(10) VALUE 'SUCURSAL:'.
           05  LINE 07  COL 15  PIC X(04) FROM CRD-BRANCH.
           05  LINE 07  COL 45  PIC X(10) VALUE 'SIN CONTACTO:'.
           05  LINE 07  COL 60  PIC X(05) FROM WS-DISPLAY-CONTACTLESS.
           05  LINE 09  COL 02  PIC X(12) VALUE 'EMISION:'.
           05  LINE 09  COL 15  PIC 9(08) FROM WS-ISSUE-DATE-DDMM.
           05  LINE 09  COL 45  PIC X(10) VALUE 'VENCIMIENTO:'.
           05  LINE 09  COL 60  PIC 9(08) FROM WS-EXPIRE-DATE-DDMM.
           05  LINE 10  COL 02  PIC X(15) VALUE 'ESTATUS:'.
           05  LINE 10  COL 20  PIC X(15) FROM WS-DISPLAY-STATUS.
           05  LINE 11  COL 02  PIC X(10) VALUE 'EMISIONES:'.
           05  LINE 11  COL 15  PIC 9(02) FROM CRD-ISSUE-COUNT.
           05  LINE 13  COL 02  PIC X(15) VALUE 'LIMITE EFECTIVO:'.
           05  LINE 13  COL 22  PIC ZZZZZZZZZ9.99 FROM CRD-LIMIT-CASH.
           05  LINE 13  COL 45  PIC X(18) VALUE 'LIMITE COMPRAS:'.
           05  LINE 13  COL 65  PIC ZZZZZZZZZ9.99 FROM CRD-LIMIT-PURCHASE.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'PF2=BLOQUEAR  PF12=RETORNAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-CARD-NBR WS-CUSTOMER-ID-SRCH
                          WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
       ENTRY-LOOP.
           PERFORM 2000-MOSTRAR-ENTRADA.
           ACCEPT SCR-ENTRADA.
           IF WS-CRT-PF2
               MOVE WS-CARD-NBR TO LS-USUARIO
               CALL 'CRDBLK00' USING LS-USUARIO LS-RETCODE
               GO TO ENTRY-LOOP.
           IF WS-CRT-PF12
               GO TO 9000-EXIT.
           IF WS-CRT-CLEAR
               MOVE SPACES TO WS-CARD-NBR WS-CUSTOMER-ID-SRCH
                              WS-MENSAJE WS-MENSAJE-ERROR
               GO TO ENTRY-LOOP.
           IF NOT WS-CRT-ENTER
               MOVE 'USE ENTER, PF2 O PF12' TO WS-MENSAJE-ERROR
               GO TO ENTRY-LOOP.
           IF WS-CARD-NBR NOT = SPACES
               PERFORM 3000-BUSCAR-POR-NUMERO
               IF FS-OK
                   PERFORM 2500-MOSTRAR-DATOS
                   ACCEPT SCR-DISPLAY
                   IF WS-CRT-PF2
                       MOVE CRD-NBR TO LS-USUARIO
                       CALL 'CRDBLK00' USING LS-USUARIO LS-RETCODE
                   END-IF
                   GO TO ENTRY-LOOP
               ELSE
                   MOVE 'TARJETA NO ENCONTRADA' TO WS-MENSAJE-ERROR
                   GO TO ENTRY-LOOP.
           IF WS-CUSTOMER-ID-SRCH NOT = SPACES
               MOVE 'BUSQUEDA POR CLIENTE NO IMPLEMENTADA'
                 TO WS-MENSAJE-ERROR
               GO TO ENTRY-LOOP.
           MOVE 'INGRESE NUMERO DE TARJETA O ID DE CLIENTE'
             TO WS-MENSAJE-ERROR.
           GO TO ENTRY-LOOP.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'INGRESE NUMERO DE TARJETA (16 DIGITOS)'
             TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
       2000-MOSTRAR-ENTRADA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-ENTRADA.
       2500-MOSTRAR-DATOS.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-DISPLAY.
       3000-BUSCAR-POR-NUMERO.
           OPEN I-O CARD-FILE.
           IF WS-FILE-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR ARCHIVO' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT.
           MOVE WS-CARD-NBR TO CRD-NBR.
           READ CARD-FILE KEY IS CRD-NBR
               INVALID KEY
                   MOVE 'TARJETA NO REGISTRADA' TO WS-MENSAJE-ERROR
                   CLOSE CARD-FILE
                   GOTO 3000-EXIT.
           MOVE CRD-DATE-ISSUE TO WS-ISSUE-DATE-DDMM.
           MOVE CRD-DATE-EXPIRY TO WS-EXPIRE-DATE-DDMM.
           EVALUATE CRD-TYPE
               WHEN 'DB' MOVE 'DEBITO' TO WS-DISPLAY-TYPE
               WHEN 'CR' MOVE 'CREDITO' TO WS-DISPLAY-TYPE
               WHEN 'PP' MOVE 'PREPAGO' TO WS-DISPLAY-TYPE
               WHEN OTHER MOVE 'DESCONOCIDO' TO WS-DISPLAY-TYPE.
           EVALUATE CRD-PRODUCT
               WHEN 'CLAS' MOVE 'CLASICA' TO WS-DISPLAY-PRODUCT
               WHEN 'GOLD' MOVE 'DORADA' TO WS-DISPLAY-PRODUCT
               WHEN 'PLAT' MOVE 'PLATINO' TO WS-DISPLAY-PRODUCT
               WHEN 'BLCK' MOVE 'BLACK' TO WS-DISPLAY-PRODUCT
               WHEN OTHER MOVE 'ESTANDAR' TO WS-DISPLAY-PRODUCT.
           EVALUATE CRD-STATUS
               WHEN 'A' MOVE 'ACTIVA' TO WS-DISPLAY-STATUS
               WHEN 'I' MOVE 'INACTIVA' TO WS-DISPLAY-STATUS
               WHEN 'B' MOVE 'BLOQUEADA' TO WS-DISPLAY-STATUS
               WHEN 'E' MOVE 'VENCIDA' TO WS-DISPLAY-STATUS
               WHEN 'S' MOVE 'ROBADA' TO WS-DISPLAY-STATUS
               WHEN 'L' MOVE 'EXTRAVIADA' TO WS-DISPLAY-STATUS
               WHEN 'C' MOVE 'CANCELADA' TO WS-DISPLAY-STATUS
               WHEN OTHER MOVE 'DESCONOCIDO' TO WS-DISPLAY-STATUS.
           IF CRD-CONTACTLESS = 'Y'
               MOVE 'SI' TO WS-DISPLAY-CONTACTLESS
           ELSE
               MOVE 'NO' TO WS-DISPLAY-CONTACTLESS.
           CLOSE CARD-FILE.
           MOVE 'CONSULTA EXITOSA' TO WS-MENSAJE.
       3000-EXIT.
           EXIT.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM CRDINQ00.
