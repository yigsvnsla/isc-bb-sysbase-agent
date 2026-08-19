      *================================================================*
      * FD-LOANAPPL - SOLICITUDES DE PRESTAMO                         *
      * PROPOSITO: REGISTRO DE SOLICITUDES EN PROCESO                 *
      * EQUIPO: CREDITO - 2004                                        *
      * ARCHIVO: LOANAPPL.DAT (INDEXADO)                               *
      * CLAVE:   LAP-APPL-ID (X(10))                                   *
      *================================================================*
      *
     FD  LOANAPPL-FILE
         RECORD 280 CHARACTERS.
      *
       01  LOANAPPL-RECORD.
           05  LAP-APPL-ID                 PIC X(10).
           05  LAP-CUSTOMER-ID             PIC X(10).
           05  LAP-TYPE                    PIC X(02).
               88  LAP-TYPE-PERSONAL       VALUE 'PL'.
               88  LAP-TYPE-HIPOTECARIO    VALUE 'HI'.
               88  LAP-TYPE-AUTOMOTRIZ     VALUE 'AU'.
               88  LAP-TYPE-COMERCIAL      VALUE 'CO'.
           05  LAP-PRODUCT-CODE            PIC X(04).
      *
      *--- SOLICITUD ---*
           05  LAP-AMOUNT-REQUESTED        PIC 9(13)V99 COMP-3.
           05  LAP-TERM-MONTHS             PIC 9(04).
           05  LAP-PAYMENT-FREQ            PIC X(01).
               88  LAP-FREQ-SEMANAL        VALUE 'S'.
               88  LAP-FREQ-QUINCENAL      VALUE 'Q'.
               88  LAP-FREQ-MENSUAL        VALUE 'M'.
           05  LAP-PROPOSED-RATE           PIC 9(03)V9(04) COMP-3.
      *
      *--- SCORING ---*
           05  LAP-SCORE                   PIC 9(03).
           05  LAP-SCORE-APROBACION        PIC 9(03).
           05  LAP-SCORE-RIESGO            PIC X(01).
               88  LAP-SCORE-BAJO          VALUE 'B'.
               88  LAP-SCORE-MEDIO         VALUE 'M'.
               88  LAP-SCORE-ALTO          VALUE 'A'.
      *
      *--- INGRESOS ---*
           05  LAP-INGRESO-MENSUAL         PIC 9(09)V99 COMP-3.
           05  LAP-INGRESO-CONYUGAL        PIC 9(09)V99 COMP-3.
           05  LAP-OTROS-INGRESOS          PIC 9(09)V99 COMP-3.
           05  LAP-EGRESOS-MENSUALES       PIC 9(09)V99 COMP-3.
      *
      *--- AVAL / GARANTIA ---*
           05  LAP-GARANTE-ID              PIC X(10).
           05  LAP-GARANTE-INGRESO         PIC 9(09)V99 COMP-3.
           05  LAP-GARANTIA-TIPO           PIC X(02).
           05  LAP-GARANTIA-VALOR          PIC 9(11)V99 COMP-3.
      *
      *--- APROBACION ---*
           05  LAP-STATUS                  PIC X(01).
               88  LAP-STATUS-BORRADOR     VALUE 'B'.
               88  LAP-STATUS-EN-REVISION  VALUE 'R'.
               88  LAP-STATUS-APROBADO     VALUE 'A'.
               88  LAP-STATUS-RECHAZADO    VALUE 'Z'.
               88  LAP-STATUS-CANCELADO    VALUE 'C'.
               88  LAP-STATUS-DESEMBOLSADO VALUE 'D'.
           05  LAP-FECHA-SOLICITUD         PIC 9(08).
           05  LAP-FECHA-APROBACION        PIC 9(08).
           05  LAP-FECHA-VENCIMIENTO       PIC 9(08).
           05  LAP-USUARIO-SOLICITA        PIC X(08).
           05  LAP-USUARIO-APRUEBA         PIC X(08).
           05  LAP-OBSERVACIONES           PIC X(60).
      *
           05  LAP-FILLER                  PIC X(20).
