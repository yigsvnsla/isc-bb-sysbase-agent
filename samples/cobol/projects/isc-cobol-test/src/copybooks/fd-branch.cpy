      *================================================================*
      * FD-BRANCH - REGISTRO DE SUCURSAL                              *
      * CREADO: 1996 - DEPARTAMENTO DE OPERACIONES                    *
      * ARCHIVO: BRANCH.DAT (INDEXADO)                                 *
      * CLAVE:   BRH-CODE (X(04))                                      *
      *================================================================*
      *
     FD  BRANCH-FILE
         RECORD 200 CHARACTERS.
      *
       01  BRANCH-RECORD.
           05  BRH-CODE                    PIC X(04).
           05  BRH-NAME                    PIC X(40).
           05  BRH-SHORT-NAME              PIC X(15).
      *
      *--- UBICACION ---*
           05  BRH-ADDRESS.
               10  BRH-STREET              PIC X(40).
               10  BRH-EXT-NUM             PIC X(10).
               10  BRH-COLONY              PIC X(30).
               10  BRH-CITY                PIC X(30).
               10  BRH-STATE               PIC X(20).
               10  BRH-ZIP                 PIC X(05).
           05  BRH-PHONE                   PIC X(15).
           05  BRH-MANAGER                 PIC X(08).
      *
      *--- HORARIO ---*
           05  BRH-OPEN-TIME               PIC 9(04).
           05  BRH-CLOSE-TIME              PIC 9(04).
           05  BRH-SATURDAY-OPEN           PIC 9(04).
           05  BRH-SATURDAY-CLOSE          PIC 9(04).
           05  BRH-SUNDAY-OPEN             PIC 9(04).
           05  BRH-SUNDAY-CLOSE            PIC 9(04).
      *
      *--- CONTABLES ---*
           05  BRH-BALANCE-CASH            PIC 9(11)V99 COMP-3.
           05  BRH-BALANCE-LIMIT           PIC 9(11)V99 COMP-3.
           05  BRH-GL-CODE                 PIC X(08).
           05  BRH-REGION                  PIC X(02).
           05  BRH-STATUS                  PIC X(01).
               88  BRH-STATUS-OPEN         VALUE 'O'.
               88  BRH-STATUS-CLOSED       VALUE 'C'.
               88  BRH-STATUS-TEMPORAL     VALUE 'T'.
           05  BRH-DATE-OPENED             PIC 9(08).
      *
      *--- EQUIPO ---*
           05  BRH-TERMINAL-COUNT          PIC 9(04).
           05  BRH-ATM-COUNT               PIC 9(02).
           05  BRH-EMPLOYEE-COUNT          PIC 9(06).
      *
           05  BRH-FILLER                  PIC X(30).
