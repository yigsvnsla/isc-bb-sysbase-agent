      *================================================================*
      * FD-CURRENCY - REGISTRO DE MONEDAS / TIPOS DE CAMBIO            *
      * CREADO: 1995 - DEPARTAMENTO DE CAMBIOS                        *
      * ARCHIVO: CURRENCY.DAT (INDEXADO)                               *
      * CLAVE:   CUR-CODIGO (X(03))                                    *
      *================================================================*
      *
     FD  CURRENCY-FILE
         RECORD 80 CHARACTERS.
      *
       01  CURRENCY-RECORD.
           05  CUR-CODIGO                  PIC X(03).
           05  CUR-DESCRIPCION             PIC X(30).
           05  CUR-SIMBOLO                 PIC X(03).
           05  CUR-PAIS                    PIC X(20).
      *
      *--- TIPOS DE CAMBIO ---*
           05  CUR-EXCHANGE-RATE-BUY       PIC 9(07)V9(06) COMP-3.
           05  CUR-EXCHANGE-RATE-SELL      PIC 9(07)V9(06) COMP-3.
           05  CUR-EXCHANGE-RATE-FIX       PIC 9(07)V9(06) COMP-3.
           05  CUR-EXCHANGE-DATE           PIC 9(08).
      *
      *--- CONTROL ---*
           05  CUR-DECIMALES               PIC 9(01).
               88  CUR-DEC-2               VALUE 2.
               88  CUR-DEC-3               VALUE 3.
               88  CUR-DEC-4               VALUE 4.
           05  CUR-STATUS                  PIC X(01).
               88  CUR-ACTIVA              VALUE 'A'.
               88  CUR-INACTIVA            VALUE 'I'.
               88  CUR-SUSPENDIDA          VALUE 'S'.
           05  CUR-ES-BASE                 PIC X(01).
               88  CUR-BASE-SI             VALUE 'S'.
               88  CUR-BASE-NO             VALUE 'N'.
      *
           05  CUR-FILLER                  PIC X(04).
