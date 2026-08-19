      *================================================================*
      * COPYBOOK: CPY-ERROR - RUTINA ESTANDAR DE ERROR                *
      * PROPOSITO: MANEJO CENTRALIZADO DE ERRORES DE ARCHIVO          *
      * EQUIPO: BASE DE DATOS - 1999                                  *
      *================================================================*
      * INCLUIR EN PROGRAMA QUE USA ARCHIVOS INDEXADOS                *
      *================================================================*
      *
      *----------------------------------------------------------------*
      * ESTRUCTURA DE ERROR                                            *
      *----------------------------------------------------------------*
       01  WS-ERROR-INFO.
           05  WS-ERROR-PROGRAMA          PIC X(08).
           05  WS-ERROR-ARCHIVO           PIC X(10).
           05  WS-ERROR-OPERACION         PIC X(06).
               88  WS-ERR-OP-READ         VALUE 'READ'.
               88  WS-ERR-OP-WRITE        VALUE 'WRITE'.
               88  WS-ERR-OP-REWRITE      VALUE 'REWRI'.
               88  WS-ERR-OP-DELETE       VALUE 'DELET'.
               88  WS-ERR-OP-START        VALUE 'START'.
               88  WS-ERR-OP-OPEN         VALUE 'OPEN'.
               88  WS-ERR-OP-CLOSE        VALUE 'CLOSE'.
           05  WS-ERROR-FILESTATUS        PIC X(02).
           05  WS-ERROR-DESC              PIC X(40).
           05  WS-ERROR-FECHA             PIC 9(08).
           05  WS-ERROR-HORA              PIC 9(06).
      *
      *----------------------------------------------------------------*
      * TABLA DE CODIGOS DE ERROR DE ARCHIVO                           *
      *----------------------------------------------------------------*
       01  WS-FILE-ERROR-TABLE.
           05  WS-FILE-ERROR-ENTRY        OCCURS 15.
               10  WS-FILERR-CODE         PIC X(02).
               10  WS-FILERR-DESC         PIC X(30).
      *
      *----------------------------------------------------------------*
      * DATOS DE MANEJO DE ERROR                                       *
      *----------------------------------------------------------------*
       01  WS-ERROR-COUNT                 PIC 9(04) VALUE 0.
       01  WS-ERROR-MAX                   PIC 9(04) VALUE 100.
       01  WS-ERROR-SEVERITY              PIC 9(01).
           88  WS-ERR-SEV-WARNING         VALUE 1.
           88  WS-ERR-SEV-ERROR           VALUE 2.
           88  WS-ERR-SEV-FATAL           VALUE 3.
      *
      *----------------------------------------------------------------*
      * 88 LEVELS PARA FILE STATUS COMUNES                             *
      *----------------------------------------------------------------*
       01  WS-FILE-STATUS-CODE            PIC X(02).
           88  FS-OK                      VALUE '00'.
           88  FS-EOF                     VALUE '10'.
           88  FS-NOT-FOUND               VALUE '23'.
           88  FS-DUPLICATE               VALUE '22'.
           88  FS-LOCKED                  VALUE '99'.
           88  FS-NOT-OPEN                VALUE '93'.
           88  FS-ALREADY-OPEN            VALUE '92'.
           88  FS-RECORD-LOCKED           VALUE '24'.
           88  FS-WRITE-PROTECT           VALUE '84'.
           88  FS-DISK-FULL               VALUE '34'.
           88  FS-RECORD-TRUNCAT          VALUE '95'.
