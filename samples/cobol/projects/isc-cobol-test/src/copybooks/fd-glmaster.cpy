      *================================================================*
      * FD-GLMASTER - REGISTRO DE CUENTAS CONTABLES (MAYOR)           *
      * PROPOSITO: CONTABILIDAD GENERAL                               *
      * EQUIPO: CONTABILIDAD - 1996                                   *
      * ARCHIVO: GLMASTER.DAT (INDEXADO)                               *
      * CLAVE:   GL-ACCOUNT (X(08))                                    *
      *================================================================*
      *
     FD  GLMASTER-FILE
         RECORD 160 CHARACTERS.
      *
       01  GLMASTER-RECORD.
           05  GL-ACCOUNT                  PIC X(08).
           05  GL-DESCRIPTION              PIC X(40).
           05  GL-TYPE                     PIC X(01).
               88  GL-TYPE-ACTIVO          VALUE '1'.
               88  GL-TYPE-PASIVO          VALUE '2'.
               88  GL-TYPE-CAPITAL         VALUE '3'.
               88  GL-TYPE-INGRESO         VALUE '4'.
               88  GL-TYPE-GASTO           VALUE '5'.
               88  GL-TYPE-ORDEN           VALUE '6'.
           05  GL-LEVEL                    PIC 9(01).
               88  GL-LEVEL-MAYOR          VALUE 1.
               88  GL-LEVEL-SUBCTACTA      VALUE 2.
               88  GL-LEVEL-AUXILIAR       VALUE 3.
      *
      *--- SALDOS ---*
           05  GL-BALANCE-INICIAL          PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-CURRENT          PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-DEBIT            PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-CREDIT           PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-PERIOD-ANT       PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-YTD              PIC S9(13)V99 COMP-3.
      *
      *--- CONTROL ---*
           05  GL-CURRENCY                 PIC X(03).
           05  GL-BRANCH                   PIC X(04).
           05  GL-CENTER-COST              PIC X(06).
           05  GL-STATUS                   PIC X(01).
               88  GL-STATUS-ACTIVE        VALUE 'A'.
               88  GL-STATUS-INACTIVE      VALUE 'I'.
               88  GL-STATUS-BLOQUEADA     VALUE 'B'.
           05  GL-DATE-LAST-ACTIVITY       PIC 9(08).
           05  GL-DATE-LAST-CIERRE         PIC 9(08).
           05  GL-USER-LAST-MOD            PIC X(08).
      *
           05  GL-FILLER                   PIC X(20).
