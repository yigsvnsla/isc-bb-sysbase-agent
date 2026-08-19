      *================================================================*
      * FD-BATCHCTL - REGISTRO DE CONTROL DE PROCESOS BATCH           *
      * PROPOSITO: CONTROL DE CIERRES DIARIOS Y MENSUALES             *
      * EQUIPO: OPERACIONES - 1997                                    *
      * ARCHIVO: BATCHCTL.DAT (INDEXADO)                               *
      * CLAVE:   BCH-FECHA-PROCESO (9(08))                             *
      *================================================================*
      *
     FD  BATCHCTL-FILE
         RECORD 150 CHARACTERS.
      *
       01  BATCHCTL-RECORD.
           05  BCH-FECHA-PROCESO           PIC 9(08).
           05  BCH-FECHA-CONTABLE          PIC 9(08).
           05  BCH-FECHA-PROXIMA           PIC 9(08).
           05  BCH-DIA-HABIL               PIC X(01).
               88  BCH-DIA-HABIL-SI        VALUE 'S'.
               88  BCH-DIA-HABIL-NO        VALUE 'N'.
      *
      *--- ESTADO POR PROCESO ---*
           05  BCH-ESTADO-GENERAL          PIC X(01).
               88  BCH-ESTADO-PENDIENTE    VALUE 'P'.
               88  BCH-ESTADO-EN-EJEC      VALUE 'E'.
               88  BCH-ESTADO-COMPLETADO   VALUE 'C'.
               88  BCH-ESTADO-ERROR        VALUE 'R'.
               88  BCH-ESTADO-CANCELADO    VALUE 'X'.
      *
           05  BCH-STATUS-DETALLE.
               10  BCH-ST-INTERES          PIC X(01).
               10  BCH-ST-SOBREGIRO        PIC X(01).
               10  BCH-ST-COMISIONES       PIC X(01).
               10  BCH-ST-GL               PIC X(01).
               10  BCH-ST-REPORTES         PIC X(01).
               10  BCH-ST-CIERRE           PIC X(01).
      *
      *--- CONTROL ---*
           05  BCH-HORA-INICIO             PIC 9(06).
           05  BCH-HORA-FIN                PIC 9(06).
           05  BCH-TRX-PROCESADAS          PIC 9(10).
           05  BCH-TRX-ERROR               PIC 9(06).
           05  BCH-USUARIO-EJECUTA         PIC X(08).
           05  BCH-OBSERVACIONES           PIC X(40).
      *
           05  BCH-FILLER                  PIC X(10).
