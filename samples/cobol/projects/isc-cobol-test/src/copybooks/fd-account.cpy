      *================================================================*
      * FD-ACCOUNT - REGISTRO MAESTRO DE CUENTAS                      *
      * EQUIPO: SISTEMAS CONTABLES - 2001                              *
      * ARCHIVO: ACCOUNT.DAT (INDEXADO)                                *
      * CLAVE:   ACT-NBR (X(10))                                       *
      *================================================================*
      *
     FD  ACCOUNT-FILE
         RECORD 200 CHARACTERS.
      *
       01  ACCOUNT-RECORD.
           05  ACT-NBR                     PIC X(10).
           05  ACT-TYPE                    PIC X(02).
               88  ACT-TYPE-CHEQUES        VALUE 'CH'.
               88  ACT-TYPE-AHORRO         VALUE 'AH'.
               88  ACT-TYPE-NOMINA         VALUE 'NO'.
               88  ACT-TYPE-INVERSION      VALUE 'IN'.
           05  ACT-CURRENCY                PIC X(03).
               88  ACT-CURRENCY-MXN        VALUE 'MXN'.
               88  ACT-CURRENCY-USD        VALUE 'USD'.
               88  ACT-CURRENCY-EUR        VALUE 'EUR'.
      *
      *--- SALDOS ---*
           05  ACT-BALANCE                 PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-DISPONIBLE      PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-RETENIDO        PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-SOBREGIRO       PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-PROMEDIO        PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-ANTERIOR        PIC S9(13)V99 COMP-3.
      *
      *--- PARAMETROS DE OPERACION ---*
           05  ACT-OVERDRAFT-LIMIT         PIC S9(09)V99 COMP-3.
           05  ACT-OVERDRAFT-RATE          PIC 9(03)V9(04) COMP-3.
           05  ACT-INTEREST-RATE           PIC 9(03)V9(04) COMP-3.
           05  ACT-INTEREST-ACCRUED        PIC S9(09)V99 COMP-3.
           05  ACT-MONTHLY-FEE             PIC 9(07)V99 COMP-3.
      *
      *--- FECHAS ---*
           05  ACT-DATE-OPEN               PIC 9(08).
           05  ACT-DATE-CLOSE              PIC 9(08).
           05  ACT-DATE-LAST-ACTIVITY      PIC 9(08).
           05  ACT-DATE-LAST-INT-CALC      PIC 9(08).
           05  ACT-DATE-LAST-STATEMENT     PIC 9(08).
      *
      *--- CONTROL ---*
           05  ACT-STATUS                  PIC X(01).
               88  ACT-STATUS-ACTIVE       VALUE 'A'.
               88  ACT-STATUS-INACTIVE     VALUE 'I'.
               88  ACT-STATUS-CLOSED       VALUE 'C'.
               88  ACT-STATUS-FROZEN       VALUE 'F'.
               88  ACT-STATUS-DORMANT      VALUE 'D'.
           05  ACT-BRANCH-OPEN             PIC X(04).
           05  ACT-OFFICER                 PIC X(08).
           05  ACT-USER-LAST-MOD           PIC X(08).
      *
      *--- CONTADORES ---*
           05  ACT-TXN-COUNT-TODAY         PIC 9(06).
           05  ACT-TXN-COUNT-MONTH         PIC 9(06).
           05  ACT-CHECKS-ISSUED           PIC 9(06).
           05  ACT-CHECKS-BOUNCED          PIC 9(06).
      *
      *--- CHEQUERA ---*
           05  ACT-CHQBOOK-NBR             PIC X(10).
           05  ACT-CHQ-NEXT               PIC 9(07).
           05  ACT-CHQ-LAST-USED          PIC 9(07).
           05  ACT-CHQ-STOP-COUNT          PIC 9(03).
      *
           05  ACT-FILLER                  PIC X(15).
