      *================================================================*
      * FD-DEPMAST - REGISTRO MAESTRO DE DEPOSITOS                    *
      * EQUIPO: AHORRO Y DEPOSITOS - 2001                              *
      * ARCHIVO: DEPMAST.DAT (INDEXADO)                                *
      * CLAVE:   DEP-NBR (X(10))                                       *
      *================================================================*
      *
     FD  DEPMAST-FILE
         RECORD 200 CHARACTERS.
      *
       01  DEPMAST-RECORD.
           05  DEP-NBR                     PIC X(10).
           05  DEP-CUSTOMER-ID             PIC X(10).
           05  DEP-TYPE                    PIC X(02).
               88  DEP-TYPE-AHORRO         VALUE 'AH'.
               88  DEP-TYPE-PLAZO          VALUE 'PL'.
               88  DEP-TYPE-RECURRENTE     VALUE 'RC'.
           05  DEP-PRODUCT                 PIC X(04).
      *
      *--- MONTOS ---*
           05  DEP-BALANCE                 PIC 9(13)V99 COMP-3.
           05  DEP-BALANCE-MIN             PIC 9(13)V99 COMP-3.
           05  DEP-BALANCE-PROMEDIO        PIC 9(13)V99 COMP-3.
           05  DEP-INTEREST-ACCRUED        PIC 9(09)V99 COMP-3.
           05  DEP-INTEREST-RATE           PIC 9(03)V9(04) COMP-3.
      *
      *--- FECHAS ---*
           05  DEP-DATE-OPEN               PIC 9(08).
           05  DEP-DATE-LAST-INT           PIC 9(08).
           05  DEP-DATE-MATURITY           PIC 9(08).
           05  DEP-DATE-LAST-TXN           PIC 9(08).
           05  DEP-DATE-LAST-STATEMENT     PIC 9(08).
      *
      *--- PLAZO ---*
           05  DEP-TERM-DAYS               PIC 9(04).
           05  DEP-TERM-MONTHS             PIC 9(03).
           05  DEP-RENEWAL-COUNT           PIC 9(03).
           05  DEP-RENEWAL-AUTO            PIC X(01).
               88  DEP-RENEWAL-AUTO-YES    VALUE 'Y'.
               88  DEP-RENEWAL-AUTO-NO     VALUE 'N'.
      *
      *--- CONTROL ---*
           05  DEP-STATUS                  PIC X(01).
               88  DEP-STATUS-ACTIVE       VALUE 'A'.
               88  DEP-STATUS-CLOSED       VALUE 'C'.
               88  DEP-STATUS-FROZEN       VALUE 'F'.
               88  DEP-STATUS-MATURED      VALUE 'M'.
           05  DEP-BRANCH                  PIC X(04).
           05  DEP-OFFICER                 PIC X(08).
           05  DEP-ACCOUNT-LINKED          PIC X(10).
      *
           05  DEP-FILLER                  PIC X(20).
