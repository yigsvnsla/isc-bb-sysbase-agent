      *================================================================*
      * FD-SECURITY - REGISTRO DE AUDITORIA SEGURIDAD                 *
      * PROPOSITO: CONTROL DE ACCESO Y SESIONES                       *
      * ARCHIVO: SECURITY.DAT (INDEXADO)                              *
      * CLAVE:   SEC-SEQ (9(10))                                      *
      *================================================================*
      *
     FD  SECURITY-FILE
         RECORD 120 CHARACTERS.
      *
       01  SECURITY-RECORD.
           05  SEC-SEQ                     PIC 9(10).
           05  SEC-DATE                    PIC 9(08).
           05  SEC-TIME                    PIC 9(06).
           05  SEC-USER-ID                 PIC X(08).
           05  SEC-EVENT-TYPE              PIC X(02).
               88  SEC-EVENT-LOGIN         VALUE 'LI'.
               88  SEC-EVENT-LOGOUT        VALUE 'LO'.
               88  SEC-EVENT-FAILED        VALUE 'FA'.
               88  SEC-EVENT-LOCKED        VALUE 'LC'.
               88  SEC-EVENT-PWDCHG        VALUE 'PC'.
               88  SEC-EVENT-PWDRESET      VALUE 'PR'.
               88  SEC-EVENT-TIMEOUT       VALUE 'TO'.
               88  SEC-EVENT-UNAUTHORIZED  VALUE 'UA'.
               88  SEC-EVENT-ADMIN         VALUE 'AD'.
           05  SEC-IP-ADDRESS              PIC X(15).
           05  SEC-TERMINAL                PIC X(08).
           05  SEC-BROWSER                 PIC X(20).
           05  SEC-RESULT                  PIC X(01).
               88  SEC-RESULT-SUCCESS      VALUE 'S'.
               88  SEC-RESULT-FAILURE      VALUE 'F'.
               88  SEC-RESULT-BLOCKED      VALUE 'B'.
           05  SEC-DETAILS                 PIC X(40).
      *
           05  SEC-FILLER                  PIC X(10).
