      *================================================================*
      * FD-CARD - REGISTRO DE TARJETAS DEBITO/CREDITO                 *
      * EQUIPO: SISTEMAS DE TARJETAS - 2005                            *
      * ARCHIVO: CARD.DAT (INDEXADO)                                   *
      * CLAVE:   CRD-NBR (X(16))                                       *
      *================================================================*
      *
     FD  CARD-FILE
         RECORD 250 CHARACTERS.
      *
       01  CARD-RECORD.
           05  CRD-NBR                     PIC X(16).
           05  CRD-EMBOSSED-NAME           PIC X(30).
           05  CRD-TYPE                    PIC X(02).
               88  CRD-TYPE-DEBITO         VALUE 'DB'.
               88  CRD-TYPE-CREDITO        VALUE 'CR'.
               88  CRD-TYPE-PREPAGO        VALUE 'PP'.
               88  CRD-TYPE-CORPORATIVA    VALUE 'CO'.
           05  CRD-PRODUCT                 PIC X(04).
               88  CRD-PROD-CLASSIC        VALUE 'CLAS'.
               88  CRD-PROD-GOLD           VALUE 'GOLD'.
               88  CRD-PROD-PLATINUM       VALUE 'PLAT'.
               88  CRD-PROD-BLACK          VALUE 'BLCK'.
      *
      *--- VINCULACION ---*
           05  CRD-CUSTOMER-ID             PIC X(10).
           05  CRD-ACCOUNT-NBR             PIC X(10).
           05  CRD-BRANCH                  PIC X(04).
      *
      *--- FECHAS ---*
           05  CRD-DATE-ISSUE              PIC 9(08).
           05  CRD-DATE-EXPIRY             PIC 9(08).
           05  CRD-DATE-LAST-USED          PIC 9(08).
           05  CRD-DATE-LAST-PIN-CHG       PIC 9(08).
      *
      *--- LIMITES ---*
           05  CRD-LIMIT-CASH              PIC 9(09)V99 COMP-3.
           05  CRD-LIMIT-PURCHASE          PIC 9(09)V99 COMP-3.
           05  CRD-LIMIT-DAILY-CASH        PIC 9(09)V99 COMP-3.
           05  CRD-LIMIT-DAILY-PURCHASE    PIC 9(09)V99 COMP-3.
           05  CRD-LIMIT-MONTHLY           PIC 9(09)V99 COMP-3.
      *
      *--- SALDOS (CREDITO) ---*
           05  CRD-BALANCE-CURRENT         PIC S9(09)V99 COMP-3.
           05  CRD-BALANCE-AVAILABLE       PIC S9(09)V99 COMP-3.
           05  CRD-BALANCE-PAST-DUE        PIC S9(09)V99 COMP-3.
           05  CRD-MINIMUM-PAYMENT         PIC S9(09)V99 COMP-3.
           05  CRD-INTEREST-RATE           PIC 9(03)V9(04) COMP-3.
           05  CRD-CUT-DAY                 PIC 9(02).
           05  CRD-PAYMENT-DAY             PIC 9(02).
      *
      *--- PIN Y SEGURIDAD ---*
           05  CRD-PIN-OFFSET              PIC X(06).
           05  CRD-CVV                     PIC X(04).
           05  CRD-PIN-TRIES               PIC 9(02).
           05  CRD-PIN-BLOCKED             PIC X(01).
               88  CRD-PIN-BLOQ-YES        VALUE 'Y'.
               88  CRD-PIN-BLOQ-NO         VALUE 'N'.
      *
      *--- ESTATUS ---*
           05  CRD-STATUS                  PIC X(01).
               88  CRD-STATUS-ACTIVE       VALUE 'A'.
               88  CRD-STATUS-INACTIVE     VALUE 'I'.
               88  CRD-STATUS-BLOCKED      VALUE 'B'.
               88  CRD-STATUS-EXPIRED      VALUE 'E'.
               88  CRD-STATUS-STOLEN       VALUE 'S'.
               88  CRD-STATUS-LOST         VALUE 'L'.
               88  CRD-STATUS-CANCELLED    VALUE 'C'.
           05  CRD-REASON-LAST-CHANGE      PIC X(40).
      *
      *--- EXTRAS ---*
           05  CRD-ISSUE-COUNT             PIC 9(02).
           05  CRD-ATM-DAILY-COUNT         PIC 9(03).
           05  CRD-ATM-DAILY-AMOUNT        PIC 9(09)V99 COMP-3.
           05  CRD-CONTACTLESS             PIC X(01).
               88  CRD-CONTACTLESS-ON      VALUE 'Y'.
               88  CRD-CONTACTLESS-OFF     VALUE 'N'.
      *
           05  CRD-FILLER                  PIC X(15).
