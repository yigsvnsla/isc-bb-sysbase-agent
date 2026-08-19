      *================================================================*
      * COPYBOOK: CPY-COMMON                                           *
      * PROPOSITO: CONSTANTES GLOBALES Y CODIGOS RETORNO               *
      * EQUIPO: SISTEMAS CENTRALES - 1998                              *
      *================================================================*
      * USO: TODOS LOS PROGRAMAS DEL SISTEMA                           *
      * COMO USAR: COPY CPY-COMMON.                                    *
      *================================================================*
      *
      *----------------------------------------------------------------*
      * CODIGOS DE RETORNO ESTANDAR                                    *
      *----------------------------------------------------------------*
       01  WS-RETURN-CODE                  PIC 99.
           88  WS-RC-OK                   VALUE 00.
           88  WS-RC-NOT-FOUND            VALUE 01.
           88  WS-RC-DUPLICATE            VALUE 02.
           88  WS-RC-NO-AUTHORITY         VALUE 03.
           88  WS-RC-FILE-ERROR           VALUE 04.
           88  WS-RC-INVALID-DATA         VALUE 05.
           88  WS-RC-ACCOUNT-CLOSED       VALUE 06.
           88  WS-RC-INSUFFICIENT-FUNDS   VALUE 07.
           88  WS-RC-LOCKED               VALUE 08.
           88  WS-RC-EXPIRED              VALUE 09.
           88  WS-RC-TIMEOUT              VALUE 10.
           88  WS-RC-REJECTED             VALUE 11.
           88  WS-RC-PENDING              VALUE 12.
           88  WS-RC-MAXIMUM-RETRY        VALUE 99.
      *
      *----------------------------------------------------------------*
      * SWITCHES GLOBALES                                              *
      *----------------------------------------------------------------*
       01  WS-SWITCHES.
           05  WS-SWITCH-EOF              PIC X.
               88  WS-EOF-YES             VALUE 'Y'.
               88  WS-EOF-NO              VALUE 'N'.
           05  WS-SWITCH-FOUND            PIC X.
               88  WS-FOUND               VALUE 'Y'.
               88  WS-NOT-FOUND           VALUE 'N'.
           05  WS-SWITCH-FIRST-TIME       PIC X.
               88  WS-FIRST-TIME          VALUE 'Y'.
               88  WS-NOT-FIRST-TIME      VALUE 'N'.
           05  WS-SWITCH-ERROR            PIC X.
               88  WS-ERROR-YES           VALUE 'Y'.
               88  WS-ERROR-NO            VALUE 'N'.
           05  WS-SWITCH-PRINT            PIC X.
               88  WS-PRINT-YES           VALUE 'Y'.
               88  WS-PRINT-NO            VALUE 'N'.
           05  WS-SWITCH-CONFIRM          PIC X.
               88  WS-CONFIRMED           VALUE 'Y'.
               88  WS-NOT-CONFIRMED       VALUE 'N'.
      *
      *----------------------------------------------------------------*
      * CONSTANTES DE FECHA                                            *
      *----------------------------------------------------------------*
       01  WS-CURRENT-DATE                PIC 9(08).
       01  WS-CURRENT-TIME                PIC 9(06).
       01  WS-CURRENT-TIMESTAMP           PIC 9(14).
       01  WS-BUSINESS-DATE               PIC 9(08).
       01  WS-PREVIOUS-BUS-DATE           PIC 9(08).
       01  WS-NEXT-BUS-DATE               PIC 9(08).
       01  WS-DATE-YYYYMMDD               PIC 9(08).
       01  WS-DATE-DDMMYYYY               PIC 9(08).
       01  WS-DATE-JULIAN                 PIC 9(07).
      *
      *----------------------------------------------------------------*
      * CONSTANTES NUMERICAS                                           *
      *----------------------------------------------------------------*
       77  WS-CERO                        PIC 9      VALUE 0.
       77  WS-UNO                         PIC 9      VALUE 1.
       77  WS-DOS                         PIC 9      VALUE 2.
       77  WS-TRES                        PIC 9      VALUE 3.
       77  WS-CIEN                        PIC 9(3)   VALUE 100.
       77  WS-MIL                         PIC 9(4)   VALUE 1000.
       77  WS-CERO-DEC                    PIC 9(13)V99 COMP-3 VALUE 0.
      *
      *----------------------------------------------------------------*
      * ESTADOS DE ARCHIVO                                             *
      *----------------------------------------------------------------*
       01  WS-FILE-STATUS.
           05  FL-CUSTOMER-STATUS         PIC XX.
           05  FL-ACCOUNT-STATUS          PIC XX.
           05  FL-TRANLOG-STATUS          PIC XX.
           05  FL-LOANMAST-STATUS         PIC XX.
           05  FL-LOANAPPL-STATUS         PIC XX.
           05  FL-USERPROF-STATUS         PIC XX.
           05  FL-DEPMAST-STATUS          PIC XX.
           05  FL-TIMEDEP-STATUS          PIC XX.
           05  FL-GLMASTER-STATUS         PIC XX.
           05  FL-AUDITLOG-STATUS         PIC XX.
           05  FL-BATCHCTL-STATUS         PIC XX.
           05  FL-RATEFILE-STATUS         PIC XX.
           05  FL-PARAMSTR-STATUS         PIC XX.
           05  FL-FEESCHED-STATUS         PIC XX.
           05  FL-CHQBOOK-STATUS          PIC XX.
           05  FL-ACCTXREF-STATUS         PIC XX.
           05  FL-TELLEREC-STATUS         PIC XX.
           05  FL-CARD-STATUS             PIC XX.
           05  FL-BRANCH-STATUS           PIC XX.
           05  FL-CURRENCY-STATUS         PIC XX.
           05  FL-MESSAGES-STATUS         PIC XX.
      *
      *----------------------------------------------------------------*
      * TIPO DE OPERACION                                              *
      *----------------------------------------------------------------*
       01  WS-OPERATION-TYPE              PIC X.
           88  WS-OP-ALTA                 VALUE 'A'.
           88  WS-OP-BAJA                 VALUE 'B'.
           88  WS-OP-CAMBIO               VALUE 'C'.
           88  WS-OP-CONSULTA             VALUE 'D'.
           88  WS-OP-IMPRIME              VALUE 'I'.
