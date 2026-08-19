      *================================================================*
      * FD-ACCOUNTXR - CRUCE CLIENTE-CUENTA                            *
      * PROPOSITO: RELACIONAR CLIENTES CON CUENTAS (N:N)               *
      * EQUIPO: SISTEMAS COMERCIALES - 1998                            *
      * ARCHIVO: ACCTXREF.DAT (INDEXADO)                               *
      * CLAVE:   AXR-ID (X(20)) = CUS-ID + ACT-NBR                    *
      *================================================================*
      *
     FD  ACCTXREF-FILE
         RECORD 80 CHARACTERS.
      *
       01  ACCTXREF-RECORD.
           05  AXR-ID                      PIC X(20).
           05  AXR-CUSTOMER-ID             PIC X(10).
           05  AXR-ACCOUNT-NBR             PIC X(10).
      *
      *--- TITULARIDAD ---*
           05  AXR-ROL                     PIC X(02).
               88  AXR-ROL-TITULAR         VALUE 'TI'.
               88  AXR-ROL-COTITULAR       VALUE 'CO'.
               88  AXR-ROL-BENEFICIARIO    VALUE 'BE'.
               88  AXR-ROL-AUTORIZADO      VALUE 'AU'.
               88  AXR-ROL-FIRMA           VALUE 'FI'.
               88  AXR-ROL-GARANTE         VALUE 'GA'.
           05  AXR-PORCENTAJE              PIC 9(03)V99 COMP-3.
           05  AXR-FECHA-ALTA              PIC 9(08).
           05  AXR-FECHA-BAJA              PIC 9(08).
           05  AXR-STATUS                  PIC X(01).
               88  AXR-STATUS-ACTIVO       VALUE 'A'.
               88  AXR-STATUS-INACTIVO     VALUE 'I'.
               88  AXR-STATUS-SUSPENDIDO   VALUE 'S'.
           05  AXR-USUARIO-ALTA            PIC X(08).
      *
           05  AXR-FILLER                  PIC X(17).
