      *================================================================*
      * FD-RATEFILE - TABLA DE TASAS DE INTERES                       *
      * PROPOSITO: ALMACENA TASAS POR PRODUCTO Y PLAZO                *
      * EQUIPO: TESORERIA - 1999                                      *
      * ARCHIVO: RATEFILE.DAT (INDEXADO)                               *
      * CLAVE:   RAT-CODIGO (X(06))                                    *
      *================================================================*
      *
     FD  RATEFILE-FILE
         RECORD 100 CHARACTERS.
      *
       01  RATEFILE-RECORD.
           05  RAT-CODIGO                  PIC X(06).
           05  RAT-DESCRIPCION             PIC X(35).
           05  RAT-TIPO                    PIC X(02).
               88  RAT-TIPO-ACTIVO         VALUE 'AC'.
               88  RAT-TIPO-PASIVO         VALUE 'PA'.
               88  RAT-TIPO-PENALIZACION   VALUE 'PE'.
               88  RAT-TIPO-MORA           VALUE 'MO'.
               88  RAT-TIPO-REFERENCIA     VALUE 'RF'.
           05  RAT-PRODUCT                 PIC X(04).
           05  RAT-PLAZO-MIN               PIC 9(04).
           05  RAT-PLAZO-MAX               PIC 9(04).
           05  RAT-MONTO-MIN               PIC 9(11)V99 COMP-3.
           05  RAT-MONTO-MAX               PIC 9(11)V99 COMP-3.
      *
      *--- TASA ---*
           05  RAT-TASA-ANUAL              PIC 9(03)V9(06) COMP-3.
           05  RAT-TASA-MENSUAL            PIC 9(03)V9(06) COMP-3.
           05  RAT-TASA-DIARIA             PIC 9(03)V9(06) COMP-3.
           05  RAT-TASA-CAT                PIC 9(03)V9(06) COMP-3.
      *
      *--- CONTROL ---*
           05  RAT-FECHA-INICIO            PIC 9(08).
           05  RAT-FECHA-FIN               PIC 9(08).
           05  RAT-STATUS                  PIC X(01).
               88  RAT-STATUS-VIGENTE      VALUE 'V'.
               88  RAT-STATUS-HISTORICO    VALUE 'H'.
               88  RAT-STATUS-PENDIENTE    VALUE 'P'.
           05  RAT-USUARIO-ALTA            PIC X(08).
           05  RAT-FECHA-ALTA              PIC 9(08).
      *
           05  RAT-FILLER                  PIC X(10).
