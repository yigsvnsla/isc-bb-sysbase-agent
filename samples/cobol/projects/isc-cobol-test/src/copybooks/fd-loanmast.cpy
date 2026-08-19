      *================================================================*
      * FD-LOANMAST - REGISTRO MAESTRO DE PRESTAMOS                   *
      * EQUIPO: CREDITO Y COBRANZA - 2004                              *
      * ARCHIVO: LOANMAST.DAT (INDEXADO)                               *
      * CLAVE:   LON-NBR (X(10))                                       *
      *================================================================*
      *
     FD  LOANMAST-FILE
         RECORD 350 CHARACTERS.
      *
       01  LOANMAST-RECORD.
           05  LON-NBR                     PIC X(10).
           05  LON-APPL-ID                 PIC X(10).
           05  LON-CUSTOMER-ID             PIC X(10).
           05  LON-TYPE                    PIC X(02).
               88  LON-TYPE-PERSONAL       VALUE 'PL'.
               88  LON-TYPE-HIPOTECARIO    VALUE 'HI'.
               88  LON-TYPE-AUTOMOTRIZ     VALUE 'AU'.
               88  LON-TYPE-COMERCIAL      VALUE 'CO'.
               88  LON-TYPE-PRENDARIO      VALUE 'PR'.
               88  LON-TYPE-REVOLVENTE     VALUE 'RE'.
           05  LON-PRODUCT-CODE            PIC X(04).
      *
      *--- MONTOS ---*
           05  LON-AMOUNT-APPROVED         PIC 9(13)V99 COMP-3.
           05  LON-AMOUNT-DISBURSED        PIC 9(13)V99 COMP-3.
           05  LON-BALANCE                 PIC 9(13)V99 COMP-3.
           05  LON-BALANCE-PAST-DUE        PIC 9(13)V99 COMP-3.
           05  LON-AMOUNT-INTEREST         PIC 9(13)V99 COMP-3.
           05  LON-AMOUNT-PENALTY          PIC 9(09)V99 COMP-3.
           05  LON-MINIMUM-PAYMENT         PIC 9(09)V99 COMP-3.
      *
      *--- TASAS ---*
           05  LON-INTEREST-RATE           PIC 9(03)V9(04) COMP-3.
           05  LON-INTEREST-LATE           PIC 9(03)V9(04) COMP-3.
           05  LON-INTEREST-MORA           PIC 9(03)V9(04) COMP-3.
           05  LON-COMISION-APERTURA       PIC 9(07)V99 COMP-3.
      *
      *--- PLAZO ---*
           05  LON-TERM-MONTHS             PIC 9(04).
           05  LON-TERM-DAYS               PIC 9(04).
           05  LON-FREQUENCY               PIC X(01).
               88  LON-FREQ-SEMANAL        VALUE 'S'.
               88  LON-FREQ-QUINCENAL      VALUE 'Q'.
               88  LON-FREQ-MENSUAL        VALUE 'M'.
               88  LON-FREQ-BIMESTRAL      VALUE 'B'.
               88  LON-FREQ-TRIMESTRAL     VALUE 'T'.
           05  LON-PAYMENTS-TOTAL          PIC 9(04).
           05  LON-PAYMENTS-MADE           PIC 9(04).
           05  LON-PAYMENTS-OVERDUE        PIC 9(04).
      *
      *--- AMORTIZACION ---*
           05  LON-AMORT-TYPE              PIC X(01).
               88  LON-AMORT-FRANCESA      VALUE 'F'.
               88  LON-AMORT-ALEMANA       VALUE 'A'.
               88  LON-AMORT-AMERICANA     VALUE 'M'.
               88  LON-AMORT-CUOTA-FIJA    VALUE 'C'.
           05  LON-INSTALLMENT-AMOUNT      PIC 9(09)V99 COMP-3.
           05  LON-INSTALLMENT-DUE-DAY     PIC 9(02).
      *
      *--- FECHAS ---*
           05  LON-DATE-APPROVAL           PIC 9(08).
           05  LON-DATE-DISBURSEMENT       PIC 9(08).
           05  LON-DATE-FIRST-PAYMENT      PIC 9(08).
           05  LON-DATE-LAST-PAYMENT       PIC 9(08).
           05  LON-DATE-MATURITY           PIC 9(08).
           05  LON-DATE-LAST-CALC          PIC 9(08).
      *
      *--- COLATERAL ---*
           05  LON-COLLATERAL-TYPE         PIC X(02).
           05  LON-COLLATERAL-DESC         PIC X(40).
           05  LON-COLLATERAL-VALUE        PIC 9(13)V99 COMP-3.
      *
      *--- CUENTA PARA PAGO ---*
           05  LON-ACCOUNT-DEBIT           PIC X(10).
           05  LON-ACCOUNT-DISBURSEMENT    PIC X(10).
      *
      *--- TABLA DE CUOTAS (OCCURS) ---*
           05  LON-INSTALLMENT-TABLE.
               10  LON-INSTALLMENT-ENTRY   OCCURS 360.
                   15  LON-INST-NBR        PIC 9(04).
                   15  LON-INST-DUE-DATE   PIC 9(08).
                   15  LON-INST-AMOUNT     PIC 9(09)V99 COMP-3.
                   15  LON-INST-PRINCIPAL  PIC 9(09)V99 COMP-3.
                   15  LON-INST-INTEREST   PIC 9(09)V99 COMP-3.
                   15  LON-INST-BALANCE    PIC 9(09)V99 COMP-3.
                   15  LON-INST-STATUS     PIC X(01).
                       88  LON-INST-PENDING    VALUE 'P'.
                       88  LON-INST-PAID      VALUE 'C'.
                       88  LON-INST-OVERDUE   VALUE 'V'.
                       88  LON-INST-REFINANCED VALUE 'R'.
      *
      *--- CONTROL ---*
           05  LON-STATUS                  PIC X(01).
               88  LON-STATUS-ACTIVE       VALUE 'A'.
               88  LON-STATUS-PAID         VALUE 'P'.
               88  LON-STATUS-CHARGED-OFF  VALUE 'C'.
               88  LON-STATUS-RESTRUCTURED VALUE 'R'.
               88  LON-STATUS-LEGAL        VALUE 'L'.
           05  LON-CLASSIFICATION          PIC X(01).
               88  LON-CLASS-NORMAL        VALUE '1'.
               88  LON-CLASS-SUBSTANDARD   VALUE '2'.
               88  LON-CLASS-DOUBTFUL      VALUE '3'.
               88  LON-CLASS-LOSS          VALUE '4'.
           05  LON-OFFICER                  PIC X(08).
           05  LON-USER-LAST-MOD           PIC X(08).
           05  LON-DATE-LAST-MOD           PIC 9(08).
      *
           05  LON-FILLER                  PIC X(30).
