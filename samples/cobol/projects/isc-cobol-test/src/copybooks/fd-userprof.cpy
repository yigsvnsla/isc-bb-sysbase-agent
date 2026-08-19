      *================================================================*
      * FD-USERPROF - REGISTRO DE PERFIL DE USUARIO                   *
      * EQUIPO: SEGURIDAD INFORMATICA - 1997                           *
      * ARCHIVO: USERPROF.DAT (INDEXADO)                               *
      * CLAVE:   USR-ID (X(08))                                        *
      *================================================================*
      *
     FD  USERPROF-FILE
         RECORD 180 CHARACTERS.
      *
       01  USERPROF-RECORD.
           05  USR-ID                      PIC X(08).
           05  USR-NAME                    PIC X(40).
           05  USR-LAST-NAME               PIC X(30).
           05  USR-FIRST-NAME              PIC X(30).
      *
      *--- CREDENCIALES ---*
           05  USR-PASSWORD                PIC X(20).
           05  USR-PASSWORD-EXP-DATE       PIC 9(08).
           05  USR-PASSWORD-LAST-CHG       PIC 9(08).
           05  USR-PASSWORD-TRIES          PIC 9(02).
           05  USR-PASSWORD-BLOCKED        PIC X.
               88  USR-PWD-BLOCKED-YES     VALUE 'Y'.
               88  USR-PWD-BLOCKED-NO      VALUE 'N'.
           05  USR-PASSWORD-RESET          PIC X.
               88  USR-PWD-RESET-YES       VALUE 'Y'.
               88  USR-PWD-RESET-NO        VALUE 'N'.
      *
      *--- PUESTO ---*
           05  USR-ROLE                    PIC X(03).
               88  USR-ROLE-ADMIN          VALUE 'ADM'.
               88  USR-ROLE-GERENTE        VALUE 'GER'.
               88  USR-ROLE-SUPERVISOR     VALUE 'SUP'.
               88  USR-ROLE-CAJERO         VALUE 'CAJ'.
               88  USR-ROLE-OFICIAL        VALUE 'OFI'.
               88  USR-ROLE-AUDITOR        VALUE 'AUD'.
               88  USR-ROLE-CONSULTA       VALUE 'CON'.
           05  USR-BRANCH                  PIC X(04).
           05  USR-DEPARTMENT              PIC X(04).
      *
      *--- CONTROL ACCESO ---*
           05  USR-LOGIN-TIME-FROM         PIC 9(04).
           05  USR-LOGIN-TIME-TO           PIC 9(04).
           05  USR-LOGIN-IP-RANGE          PIC X(15).
           05  USR-LOGIN-ATTEMPT-MAX       PIC 9(02) VALUE 3.
           05  USR-SESSION-TIMEOUT         PIC 9(04) VALUE 600.
      *
      *--- DATOS CONTACTO ---*
           05  USR-EMAIL                   PIC X(50).
           05  USR-PHONE                   PIC X(15).
           05  USR-EXTENSION               PIC X(05).
      *
      *--- ESTATUS ---*
           05  USR-STATUS                  PIC X(01).
               88  USR-STATUS-ACTIVE       VALUE 'A'.
               88  USR-STATUS-INACTIVE     VALUE 'I'.
               88  USR-STATUS-SUSPENDED    VALUE 'S'.
               88  USR-STATUS-TERMINATED   VALUE 'T'.
           05  USR-DATE-HIRED              PIC 9(08).
           05  USR-DATE-TERMINATED         PIC 9(08).
           05  USR-DATE-LAST-LOGIN         PIC 9(08).
           05  USR-TIME-LAST-LOGIN         PIC 9(06).
      *
           05  USR-FILLER                  PIC X(20).
