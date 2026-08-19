      *================================================================*
      * FD-AUDITLOG - PISTA DE AUDITORIA                              *
      * PROPOSITO: REGISTRO DE TODO CAMBIO EN EL SISTEMA              *
      * EQUIPO: AUDITORIA INTERNA - 2000                               *
      * ARCHIVO: AUDITLOG.DAT (INDEXADO)                               *
      * CLAVE:   AUD-SEQ (9(10))                                       *
      *================================================================*
      *
     FD  AUDITLOG-FILE
         RECORD 200 CHARACTERS.
      *
       01  AUDITLOG-RECORD.
           05  AUD-SEQ                     PIC 9(10).
           05  AUD-DATE                    PIC 9(08).
           05  AUD-TIME                    PIC 9(06).
           05  AUD-USUARIO                 PIC X(08).
           05  AUD-TERMINAL                PIC X(08).
           05  AUD-PROGRAMA                PIC X(08).
      *
      *--- TIPO DE EVENTO ---*
           05  AUD-EVENTO                  PIC X(02).
               88  AUD-EVENTO-ALTA         VALUE 'AL'.
               88  AUD-EVENTO-BAJA         VALUE 'BA'.
               88  AUD-EVENTO-CAMBIO       VALUE 'CA'.
               88  AUD-EVENTO-CONSULTA     VALUE 'CO'.
               88  AUD-EVENTO-IMPRESION    VALUE 'IM'.
               88  AUD-EVENTO-REVERSO      VALUE 'RE'.
               88  AUD-EVENTO-AUTORIZA     VALUE 'AU'.
               88  AUD-EVENTO-CIERRE       VALUE 'CI'.
               88  AUD-EVENTO-BLOQUEO      VALUE 'BL'.
      *
      *--- ENTIDAD AFECTADA ---*
           05  AUD-ENTITY-TYPE             PIC X(02).
               88  AUD-ENT-CLIENTE         VALUE 'CL'.
               88  AUD-ENT-CUENTA          VALUE 'CT'.
               88  AUD-ENT-PRESTAMO        VALUE 'PR'.
               88  AUD-ENT-TARJETA         VALUE 'TJ'.
               88  AUD-ENT-USUARIO         VALUE 'US'.
               88  AUD-ENT-PARAMETRO       VALUE 'PA'.
               88  AUD-ENT-TASA            VALUE 'TA'.
               88  AUD-ENT-SUCURSAL        VALUE 'SU'.
               88  AUD-ENT-TRANSACCION     VALUE 'TR'.
           05  AUD-ENTITY-KEY              PIC X(20).
      *
      *--- DETALLE ---*
           05  AUD-CAMPO-ANTERIOR          PIC X(60).
           05  AUD-CAMPO-NUEVO             PIC X(60).
           05  AUD-RESULTADO               PIC X(01).
               88  AUD-RES-OK              VALUE 'O'.
               88  AUD-RES-RECHAZADO       VALUE 'R'.
               88  AUD-RES-ERROR           VALUE 'E'.
           05  AUD-OBSERVACIONES           PIC X(30).
      *
           05  AUD-FILLER                  PIC X(15).
