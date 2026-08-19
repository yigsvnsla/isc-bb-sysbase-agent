      *================================================================*
      * FD-TRANLOG - REGISTRO DE BITACORA DE TRANSACCIONES             *
      * EQUIPO: SISTEMAS TRANSACCIONALES - 2003                        *
      * ARCHIVO: TRANLOG.DAT (INDEXADO)                                *
      * CLAVE:   TRN-SEQ (9(10))                                       *
      * ALTERNATE: TRN-ACCOUNT-NBR                                     *
      *================================================================*
      *
     FD  TRANLOG-FILE
         RECORD 150 CHARACTERS.
      *
       01  TRANLOG-RECORD.
           05  TRN-SEQ                     PIC 9(10).
           05  TRN-DATE                    PIC 9(08).
           05  TRN-TIME                    PIC 9(06).
           05  TRN-TYPE                    PIC X(03).
               88  TRN-TYPE-DEPOSITO       VALUE 'DEP'.
               88  TRN-TYPE-RETIRO         VALUE 'RET'.
               88  TRN-TYPE-TRANSFERENCIA  VALUE 'TRF'.
               88  TRN-TYPE-PAGO           VALUE 'PAG'.
               88  TRN-TYPE-CHEQUE         VALUE 'CHQ'.
               88  TRN-TYPE-INTERES        VALUE 'INT'.
               88  TRN-TYPE-COMISION       VALUE 'COM'.
               88  TRN-TYPE-AJUSTE         VALUE 'AJU'.
               88  TRN-TYPE-APERTURA       VALUE 'APE'.
               88  TRN-TYPE-CIERRE         VALUE 'CIE'.
      *
      *--- CUENTAS ---*
           05  TRN-ACCOUNT-NBR             PIC X(10).
           05  TRN-ACCOUNT-DEST            PIC X(10).
           05  TRN-CUSTOMER-ID             PIC X(10).
      *
      *--- MONTOS ---*
           05  TRN-AMOUNT                  PIC S9(13)V99 COMP-3.
           05  TRN-AMOUNT-TAX              PIC S9(09)V99 COMP-3.
           05  TRN-AMOUNT-TOTAL            PIC S9(13)V99 COMP-3.
           05  TRN-AMOUNT-ORIGINAL         PIC S9(13)V99 COMP-3.
      *
      *--- COMISION ---*
           05  TRN-FEE-AMOUNT              PIC S9(07)V99 COMP-3.
           05  TRN-FEE-CODE                PIC X(04).
      *
      *--- ORIGEN ---*
           05  TRN-BRANCH                  PIC X(04).
           05  TRN-TELLER-ID               PIC X(08).
           05  TRN-USER-ID                 PIC X(08).
           05  TRN-TERMINAL                PIC X(08).
           05  TRN-CHANNEL                 PIC X(02).
               88  TRN-CH-VENTANILLA       VALUE '01'.
               88  TRN-CH-CAJERO           VALUE '02'.
               88  TRN-CH-BANCA-ELECT      VALUE '03'.
               88  TRN-CH-BATCH            VALUE '04'.
      *
      *--- REFERENCIA ---*
           05  TRN-REFERENCE               PIC X(20).
           05  TRN-CHQ-NBR                 PIC 9(10).
           05  TRN-CHQ-BANK                PIC X(10).
           05  TRN-CHQ-ACCOUNT             PIC X(10).
      *
      *--- CONTROL ---*
           05  TRN-STATUS                  PIC X(01).
               88  TRN-STATUS-PENDIENTE    VALUE 'P'.
               88  TRN-STATUS-CONFIRMADO   VALUE 'C'.
               88  TRN-STATUS-RECHAZADO    VALUE 'R'.
               88  TRN-STATUS-REVERSADO    VALUE 'V'.
           05  TRN-REVERSE-SEQ             PIC 9(10).
           05  TRN-DESCRIPTION             PIC X(30).
      *
           05  TRN-FILLER                  PIC X(10).
