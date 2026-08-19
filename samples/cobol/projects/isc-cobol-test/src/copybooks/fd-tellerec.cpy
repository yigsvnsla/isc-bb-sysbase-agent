      *================================================================*
      * FD-TELLEREC - REGISTRO DE CAJA / FONDO DE CAJERO              *
      * PROPOSITO: CONTROL DE APERTURA Y CIERRE DE CAJA               *
      * EQUIPO: VENTANILLA - 1999                                     *
      * ARCHIVO: TELLEREC.DAT (INDEXADO)                               *
      * CLAVE:   TLR-ID + TLR-DATE (X(08) + 9(08))                    *
      *================================================================*
      *
     FD  TELLEREC-FILE
         RECORD 150 CHARACTERS.
      *
       01  TELLEREC-RECORD.
           05  TLR-ID                      PIC X(08).
           05  TLR-DATE                    PIC 9(08).
           05  TLR-BRANCH                  PIC X(04).
      *
      *--- FONDO ASIGNADO ---*
           05  TLR-FONDO-INICIAL           PIC 9(09)V99 COMP-3.
           05  TLR-FONDO-ACTUAL            PIC 9(09)V99 COMP-3.
           05  TLR-FONDO-CIERRE            PIC 9(09)V99 COMP-3.
           05  TLR-LIMITE-EFECTIVO         PIC 9(09)V99 COMP-3.
      *
      *--- MOVIMIENTOS ---*
           05  TLR-TOTAL-DEPOSITOS         PIC 9(09)V99 COMP-3.
           05  TLR-TOTAL-RETIROS           PIC 9(09)V99 COMP-3.
           05  TLR-TOTAL-TRANSFERENCIAS    PIC 9(09)V99 COMP-3.
           05  TLR-TOTAL-PAGOS             PIC 9(09)V99 COMP-3.
           05  TLR-TOTAL-CHEQUES           PIC 9(09)V99 COMP-3.
      *
      *--- CONTEO ---*
           05  TLR-COUNT-DEPOSITOS         PIC 9(05).
           05  TLR-COUNT-RETIROS           PIC 9(05).
           05  TLR-COUNT-TRANSFERENCIAS    PIC 9(05).
           05  TLR-COUNT-PAGOS             PIC 9(05).
           05  TLR-COUNT-CHEQUES           PIC 9(05).
           05  TLR-COUNT-TOTAL             PIC 9(05).
      *
      *--- CONTROL ---*
           05  TLR-HORA-APERTURA           PIC 9(06).
           05  TLR-HORA-CIERRE             PIC 9(06).
           05  TLR-STATUS                  PIC X(01).
               88  TLR-STATUS-ABIERTO      VALUE 'O'.
               88  TLR-STATUS-CERRADO      VALUE 'C'.
               88  TLR-STATUS-SUSPENDIDO   VALUE 'S'.
           05  TLR-DIFERENCIA              PIC S9(09)V99 COMP-3.
           05  TLR-CUADRADO                PIC X(01).
               88  TLR-CUADRADO-SI         VALUE 'S'.
               88  TLR-CUADRADO-NO         VALUE 'N'.
      *
           05  TLR-FILLER                  PIC X(15).
