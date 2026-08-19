      *================================================================*
      * FD-MESSAGES - REGISTRO DE MENSAJES / NOTIFICACIONES           *
      * EQUIPO: CANALES DIGITALES - 2006                              *
      * ARCHIVO: MESSAGES.DAT (INDEXADO)                               *
      * CLAVE:   MSG-ID (9(08))                                        *
      *================================================================*
      *
     FD  MESSAGES-FILE
         RECORD 300 CHARACTERS.
      *
       01  MESSAGES-RECORD.
           05  MSG-ID                      PIC 9(08).
           05  MSG-TYPE                    PIC X(02).
               88  MSG-TYPE-ALERTA         VALUE 'AL'.
               88  MSG-TYPE-NOTIFICACION   VALUE 'NO'.
               88  MSG-TYPE-PROMOCION      VALUE 'PR'.
               88  MSG-TYPE-CARGO          VALUE 'CA'.
               88  MSG-TYPE-ABONO          VALUE 'AB'.
               88  MSG-TYPE-SEGURIDAD      VALUE 'SE'.
           05  MSG-PRIORITY                PIC X(01).
               88  MSG-PRIO-ALTA           VALUE 'H'.
               88  MSG-PRIO-MEDIA          VALUE 'M'.
               88  MSG-PRIO-BAJA           VALUE 'L'.
      *
      *--- DESTINO ---*
           05  MSG-CUSTOMER-ID             PIC X(10).
           05  MSG-ACCOUNT-NBR             PIC X(10).
           05  MSG-USER-ID                 PIC X(08).
           05  MSG-BRANCH                  PIC X(04).
           05  MSG-CHANNEL                 PIC X(02).
               88  MSG-CH-SMS              VALUE 'SM'.
               88  MSG-CH-EMAIL            VALUE 'EM'.
               88  MSG-CH-PUSH             VALUE 'PU'.
               88  MSG-CH-PANTALLA         VALUE 'PA'.
      *
      *--- CONTENIDO ---*
           05  MSG-SUBJECT                 PIC X(40).
           05  MSG-BODY                    PIC X(150).
           05  MSG-REFERENCE               PIC X(20).
      *
      *--- FECHAS ---*
           05  MSG-DATE-CREATED            PIC 9(08).
           05  MSG-DATE-SENT               PIC 9(08).
           05  MSG-DATE-READ               PIC 9(08).
           05  MSG-DATE-EXPIRES            PIC 9(08).
      *
      *--- ESTATUS ---*
           05  MSG-STATUS                  PIC X(01).
               88  MSG-STATUS-PENDING      VALUE 'P'.
               88  MSG-STATUS-SENT         VALUE 'S'.
               88  MSG-STATUS-READ         VALUE 'R'.
               88  MSG-STATUS-FAILED       VALUE 'F'.
               88  MSG-STATUS-CANCELLED    VALUE 'C'.
      *
           05  MSG-FILLER                  PIC X(15).
