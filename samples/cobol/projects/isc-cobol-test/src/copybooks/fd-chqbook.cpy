      *================================================================*
      * FD-CHQBOOK - REGISTRO DE CHEQUERAS EMITIDAS                   *
      * PROPOSITO: CONTROL DE CHEQUES POR CUENTA                      *
      * EQUIPO: OPERACIONES - 2002                                    *
      * ARCHIVO: CHQBOOK.DAT (INDEXADO)                                *
      * CLAVE:   CHQ-NBR (X(10))                                       *
      *================================================================*
      *
     FD  CHQBOOK-FILE
         RECORD 100 CHARACTERS.
      *
       01  CHQBOOK-RECORD.
           05  CHQ-NBR                     PIC X(10).
           05  CHQ-ACCOUNT-NBR             PIC X(10).
           05  CHQ-TYPE                    PIC X(01).
               88  CHQ-TYPE-NOMBRE         VALUE 'N'.
               88  CHQ-TYPE-AL-PORTADOR    VALUE 'P'.
           05  CHQ-SERIE                   PIC X(10).
      *
      *--- RANGO ---*
           05  CHQ-FROM                    PIC 9(07).
           05  CHQ-TO                      PIC 9(07).
           05  CHQ-NEXT-TO-USE             PIC 9(07).
           05  CHQ-TOTAL-HOJAS             PIC 9(05).
      *
      *--- CONTROL ---*
           05  CHQ-DATE-ISSUED             PIC 9(08).
           05  CHQ-STATUS                  PIC X(01).
               88  CHQ-STATUS-ACTIVA       VALUE 'A'.
               88  CHQ-STATUS-CANCELADA    VALUE 'C'.
               88  CHQ-STATUS-REPORTADA    VALUE 'R'.
               88  CHQ-STATUS-TERMINADA    VALUE 'T'.
           05  CHQ-BRANCH                  PIC X(04).
           05  CHQ-USER-ISSUED             PIC X(08).
           05  CHQ-STOP-COUNT              PIC 9(03).
      *
           05  CHQ-FILLER                  PIC X(10).
