      *================================================================*
      * FD-FEESCHD - TABLA DE COMISIONES Y TARIFAS                    *
      * CREADO: 2001 - DEPARTAMENTO DE PRODUCTOS                      *
      * ARCHIVO: FEESCHED.DAT (INDEXADO)                               *
      * CLAVE:   FEE-CODIGO (X(04))                                    *
      *================================================================*
      *
     FD  FEESCHED-FILE
         RECORD 120 CHARACTERS.
      *
       01  FEESCHED-RECORD.
           05  FEE-CODIGO                  PIC X(04).
           05  FEE-DESCRIPCION             PIC X(35).
           05  FEE-TIPO                    PIC X(02).
               88  FEE-TIPO-FIJA           VALUE 'FI'.
               88  FEE-TIPO-PORCENTAJE     VALUE 'PO'.
               88  FEE-TIPO-ESCALONADA     VALUE 'ES'.
      *
      *--- MONTO / TASA ---*
           05  FEE-AMOUNT-FIJO             PIC 9(07)V99 COMP-3.
           05  FEE-PORCENTAJE              PIC 9(03)V9(04) COMP-3.
           05  FEE-MONTO-MIN               PIC 9(07)V99 COMP-3.
           05  FEE-MONTO-MAX               PIC 9(07)V99 COMP-3.
      *
      *--- FRECUENCIA ---*
           05  FEE-FRECUENCIA              PIC X(01).
               88  FEE-FREC-DIARIA         VALUE 'D'.
               88  FEE-FREC-MENSUAL        VALUE 'M'.
               88  FEE-FREC-TRIMESTRAL     VALUE 'T'.
               88  FEE-FREC-SEMESTRAL      VALUE 'S'.
               88  FEE-FREC-ANUAL          VALUE 'A'.
               88  FEE-FREC-UNICA          VALUE 'U'.
      *
      *--- APLICACION ---*
           05  FEE-PRODUCTO                PIC X(04).
           05  FEE-TIPO-CUENTA             PIC X(02).
           05  FEE-EXENTO-PRIMER-MES       PIC X(01).
               88  FEE-EXENTO-SI           VALUE 'S'.
               88  FEE-EXENTO-NO           VALUE 'N'.
      *
      *--- CONTROL ---*
           05  FEE-STATUS                  PIC X(01).
               88  FEE-STATUS-ACTIVO       VALUE 'A'.
               88  FEE-STATUS-INACTIVO     VALUE 'I'.
           05  FEE-FECHA-INICIO            PIC 9(08).
           05  FEE-FECHA-FIN               PIC 9(08).
           05  FEE-USUARIO-MOD             PIC X(08).
      *
           05  FEE-FILLER                  PIC X(10).
