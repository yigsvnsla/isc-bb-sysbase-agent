      *================================================================*
      * FD-CUSTOMER - REGISTRO MAESTRO DE CLIENTES                    *
      * EQUIPO: SISTEMAS COMERCIALES - 1995                           *
      * ARCHIVO: CUSTOMER.DAT (INDEXADO)                               *
      * CLAVE:   CUS-ID (X(10))                                        *
      *================================================================*
      *
     FD  CUSTOMER-FILE
         LABEL RECORDS ARE STANDARD
         RECORD 300 CHARACTERS.
      *
       01  CUSTOMER-RECORD.
           05  CUS-ID                      PIC X(10).
           05  CUS-ID-TYPE                 PIC X(02).
               88  CUS-TYPE-PHYSICAL       VALUE 'PF'.
               88  CUS-TYPE-MORAL          VALUE 'PM'.
               88  CUS-TYPE-GUBERNAMENTAL  VALUE 'GO'.
           05  CUS-NAME                    PIC X(60).
           05  CUS-FIRST-LASTNAME          PIC X(30).
           05  CUS-SECOND-LASTNAME         PIC X(30).
           05  CUS-SHORT-NAME              PIC X(40).
      *
      *--- DATOS FISCALES ---*
           05  CUS-RFC                     PIC X(13).
           05  CUS-CURP                    PIC X(18).
           05  CUS-REGISTRO-FISCAL         PIC X(20).
      *
      *--- DOMICILIO PARTICULAR ---*
           05  CUS-ADDRESS.
               10  CUS-STRET               PIC X(40).
               10  CUS-NUM-EXT             PIC X(10).
               10  CUS-NUM-INT             PIC X(10).
               10  CUS-COLONIA             PIC X(30).
               10  CUS-CIUDAD              PIC X(30).
               10  CUS-ESTADO              PIC X(20).
               10  CUS-PAIS                PIC X(20).
               10  CUS-CP                  PIC X(05).
      *
      *--- DATOS DE CONTACTO ---*
           05  CUS-TELEFONO1               PIC X(15).
           05  CUS-TELEFONO2               PIC X(15).
           05  CUS-CELULAR                 PIC X(15).
           05  CUS-EMAIL                   PIC X(50).
      *
      *--- DATOS LABORALES (PERSONA FISICA) ---*
           05  CUS-EMPRESA                 PIC X(40).
           05  CUS-PUESTO                  PIC X(30).
           05  CUS-INGRESO-MENSUAL         PIC 9(09)V99 COMP-3.
      *
      *--- CLASIFICACION ---*
           05  CUS-SEGMENTO                PIC X(02).
               88  CUS-SEG-BASICO          VALUE '01'.
               88  CUS-SEG-MEDIO           VALUE '02'.
               88  CUS-SEG-ALTO            VALUE '03'.
               88  CUS-SEG-PREMIER         VALUE '04'.
               88  CUS-SEG-EMPRESARIAL     VALUE '05'.
           05  CUS-RIESGO-CATEGORIA        PIC X(01).
               88  CUS-RIESGO-A            VALUE 'A'.
               88  CUS-RIESGO-B            VALUE 'B'.
               88  CUS-RIESGO-C            VALUE 'C'.
               88  CUS-RIESGO-D            VALUE 'D'.
      *
      *--- CONTROL ---*
           05  CUS-STATUS                  PIC X(01).
               88  CUS-STATUS-ACTIVO       VALUE 'A'.
               88  CUS-STATUS-INACTIVO     VALUE 'I'.
               88  CUS-STATUS-BLOQUEADO    VALUE 'B'.
               88  CUS-STATUS-FALLECIDO    VALUE 'F'.
           05  CUS-FECHA-ALTA              PIC 9(08).
           05  CUS-FECHA-ULT-MOD           PIC 9(08).
           05  CUS-FECHA-ULT-OP            PIC 9(08).
           05  CUS-USUARIO-ALTA            PIC X(08).
           05  CUS-USUARIO-ULT-MOD         PIC X(08).
           05  CUS-FECHA-NACIMIENTO        PIC 9(08).
           05  CUS-SEXO                    PIC X(01).
               88  CUS-SEXO-MASCULINO      VALUE 'M'.
               88  CUS-SEXO-FEMENINO       VALUE 'F'.
           05  CUS-NACIONALIDAD            PIC X(03).
           05  CUS-ACTIVIDAD-ECONOMICA     PIC X(06).
           05  CUS-FILLER                  PIC X(20).
