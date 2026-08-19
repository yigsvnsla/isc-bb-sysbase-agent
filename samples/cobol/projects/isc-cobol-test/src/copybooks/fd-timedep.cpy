      *================================================================*
      * FD-TIMEDEP - CERTIFICADOS DE DEPOSITO A PLAZO (CD)            *
      * EQUIPO: MESAS DE DINERO - 2005                                 *
      * ARCHIVO: TIMEDEP.DAT (INDEXADO)                                *
      * CLAVE:   TD-NBR (X(12))                                        *
      *================================================================*
      *
     FD  TIMEDEP-FILE
         RECORD 180 CHARACTERS.
      *
       01  TIMEDEP-RECORD.
           05  TD-NBR                      PIC X(12).
           05  TD-CUSTOMER-ID              PIC X(10).
           05  TD-CERTIFICATE-NBR          PIC X(15).
           05  TD-TYPE                     PIC X(02).
               88  TD-TYPE-FIJO            VALUE 'FI'.
               88  TD-TYPE-REINFORZABLE    VALUE 'RE'.
               88  TD-TYPE-CAPITALIZABLE   VALUE 'CA'.
      *
      *--- MONTO ---*
           05  TD-AMOUNT                   PIC 9(13)V99 COMP-3.
           05  TD-AMOUNT-INTEREST          PIC 9(13)V99 COMP-3.
           05  TD-AMOUNT-TOTAL             PIC 9(13)V99 COMP-3.
           05  TD-AMOUNT-MIN               PIC 9(13)V99 COMP-3.
      *
      *--- TASA ---*
           05  TD-INTEREST-RATE            PIC 9(03)V9(06) COMP-3.
           05  TD-INTEREST-TYPE            PIC X(01).
               88  TD-INT-SIMPLE           VALUE 'S'.
               88  TD-INT-COMPUESTO        VALUE 'C'.
           05  TD-PAYMENT-FREQ             PIC X(01).
               88  TD-PAY-MENSUAL          VALUE 'M'.
               88  TD-PAY-TRIMESTRAL       VALUE 'T'.
               88  TD-PAY-SEMESTRAL        VALUE 'S'.
               88  TD-PAY-AL-VENCIMIENTO   VALUE 'V'.
      *
      *--- PLAZO ---*
           05  TD-TERM-DAYS                PIC 9(04).
           05  TD-TERM-MONTHS              PIC 9(03).
           05  TD-DATE-ISSUE               PIC 9(08).
           05  TD-DATE-MATURITY            PIC 9(08).
           05  TD-DATE-LAST-INT-PAYMENT    PIC 9(08).
      *
      *--- CONTROL ---*
           05  TD-STATUS                   PIC X(01).
               88  TD-STATUS-ACTIVE        VALUE 'A'.
               88  TD-STATUS-MATURED       VALUE 'M'.
               88  TD-STATUS-CANCELLED     VALUE 'C'.
               88  TD-STATUS-RENEWED       VALUE 'R'.
               88  TD-STATUS-EARLY-CLOSE   VALUE 'E'.
           05  TD-RENEWAL-COUNT            PIC 9(02).
           05  TD-EARLY-PENALTY-RATE       PIC 9(03)V9(04) COMP-3.
           05  TD-ACCOUNT-DEST             PIC X(10).
           05  TD-BRANCH                   PIC X(04).
      *
           05  TD-FILLER                   PIC X(15).
