      *================================================================*
      * ADMBRH00 - ADMINISTRACION DE SUCURSALES                       *
      * EQUIPO: OPERACIONES - 2001                                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADMBRH00.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT BRANCH-FILE
               ASSIGN TO 'BRANCH.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS BRH-CODE
               FILE STATUS IS WS-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  BRANCH-FILE
           LABEL RECORDS ARE STANDARD RECORD 200 CHARACTERS.
       01  BRANCH-RECORD.
           05  BRH-CODE                    PIC X(04).
           05  BRH-NAME                    PIC X(40).
           05  BRH-SHORT-NAME              PIC X(15).
           05  BRH-ADDRESS.
               10  BRH-STREET              PIC X(40).
               10  BRH-EXT-NUM             PIC X(10).
               10  BRH-COLONY              PIC X(30).
               10  BRH-CITY                PIC X(30).
               10  BRH-STATE               PIC X(20).
               10  BRH-ZIP                 PIC X(05).
           05  BRH-PHONE                   PIC X(15).
           05  BRH-MANAGER                 PIC X(08).
           05  BRH-OPEN-TIME               PIC 9(04).
           05  BRH-CLOSE-TIME              PIC 9(04).
           05  BRH-SATURDAY-OPEN           PIC 9(04).
           05  BRH-SATURDAY-CLOSE          PIC 9(04).
           05  BRH-SUNDAY-OPEN             PIC 9(04).
           05  BRH-SUNDAY-CLOSE            PIC 9(04).
           05  BRH-BALANCE-CASH            PIC 9(11)V99 COMP-3.
           05  BRH-BALANCE-LIMIT           PIC 9(11)V99 COMP-3.
           05  BRH-GL-CODE                 PIC X(08).
           05  BRH-REGION                  PIC X(02).
           05  BRH-STATUS                  PIC X(01).
           05  BRH-DATE-OPENED             PIC 9(08).
           05  BRH-TERMINAL-COUNT          PIC 9(04).
           05  BRH-ATM-COUNT               PIC 9(02).
           05  BRH-EMPLOYEE-COUNT          PIC 9(06).
           05  BRH-FILLER                  PIC X(30).
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
           88  FS-NOT-FOUND               VALUE '23'.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'ADMBRH00'.
           05  WS-BRH-CODE                PIC X(04).
           05  WS-CONFIRMA                PIC X(01).
           05  WS-AUDIT-DATA              PIC X(60).
           05  WS-FLAG-ERROR              PIC X(01).
               88  WS-HAY-ERROR           VALUE 'S'.
       SCREEN SECTION.
       01  SCR-ENTRADA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - SUCURSALES'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 05  PIC X(20) VALUE 'CODIGO SUCURSAL:'.
           05  LINE 05  COL 25  PIC X(04)
               USING WS-BRH-CODE AUTO PROMPT '____'.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=CONSULTAR  PF12=RETORNAR'.
       01  SCR-BRANCH.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - DATOS DE SUCURSAL'.
           05  LINE 03  COL 02  PIC X(10) VALUE 'CODIGO:'.
           05  LINE 03  COL 15  PIC X(04) USING BRH-CODE AUTO.
           05  LINE 03  COL 30  PIC X(10) VALUE 'NOMBRE:'.
           05  LINE 03  COL 45  PIC X(40) USING BRH-NAME AUTO.
           05  LINE 05  COL 02  PIC X(10) VALUE 'CALLE:'.
           05  LINE 05  COL 15  PIC X(40) USING BRH-STREET AUTO.
           05  LINE 06  COL 02  PIC X(10) VALUE 'COLONIA:'.
           05  LINE 06  COL 15  PIC X(30) USING BRH-COLONY AUTO.
           05  LINE 06  COL 50  PIC X(10) VALUE 'CIUDAD:'.
           05  LINE 06  COL 60  PIC X(30) USING BRH-CITY AUTO.
           05  LINE 07  COL 02  PIC X(10) VALUE 'GERENTE:'.
           05  LINE 07  COL 15  PIC X(08) USING BRH-MANAGER AUTO.
           05  LINE 07  COL 35  PIC X(10) VALUE 'REGION:'.
           05  LINE 07  COL 50  PIC X(02) USING BRH-REGION AUTO.
           05  LINE 08  COL 02  PIC X(15) VALUE 'HORA APERTURA:'.
           05  LINE 08  COL 20  PIC 9(04) USING BRH-OPEN-TIME AUTO.
           05  LINE 08  COL 35  PIC X(15) VALUE 'HORA CIERRE:'.
           05  LINE 08  COL 55  PIC 9(04) USING BRH-CLOSE-TIME AUTO.
           05  LINE 09  COL 02  PIC X(15) VALUE 'ESTATUS (O/C/T):'.
           05  LINE 09  COL 22  PIC X(01) USING BRH-STATUS AUTO.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=GUARDAR  PF12=CANCELAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-BRH-CODE WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
       0100-ENTRADA.
           PERFORM 2000-PANTALLA-ENTRADA.
           ACCEPT SCR-ENTRADA.
           IF WS-CRT-PF12 GO TO 9000-EXIT.
           IF WS-BRH-CODE = SPACES
               MOVE 'INGRESE CODIGO' TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
           OPEN I-O BRANCH-FILE.
           IF WS-FILE-STATUS NOT = '00' GOTO 0100-ENTRADA.
           MOVE WS-BRH-CODE TO BRH-CODE.
           READ BRANCH-FILE KEY IS BRH-CODE
               INVALID KEY CLOSE BRANCH-FILE
               MOVE 'NO ENCONTRADA - CREAR (S/N)?' TO WS-MENSAJE
               ACCEPT WS-CONFIRMA FROM CRT
               IF WS-CONFIRMA = 'S'
                   OPEN I-O BRANCH-FILE
                   MOVE WS-BRH-CODE TO BRH-CODE
                   MOVE WS-FECHA TO BRH-DATE-OPENED
                   MOVE 'O' TO BRH-STATUS
               ELSE GO TO 0100-ENTRADA.
           PERFORM 2100-PANTALLA-BRANCH.
           ACCEPT SCR-BRANCH.
           IF WS-CRT-PF12
               CLOSE BRANCH-FILE GO TO 0100-ENTRADA.
           MOVE 'N' TO WS-FLAG-ERROR.
           IF BRH-CODE = SPACES OR BRH-NAME = SPACES
               MOVE 'CODIGO Y NOMBRE REQUERIDOS' TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR.
           IF BRH-STATUS NOT = 'O' AND 'C' AND 'T'
               MOVE 'ESTATUS INVALIDO' TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR.
           IF WS-NO-HAY-ERROR
               REWRITE BRANCH-RECORD
               IF WS-FILE-STATUS = '00'
                   STRING 'SUCURSAL ' BRH-CODE ' ACTUALIZADA'
                     INTO WS-AUDIT-DATA
                   CALL 'AUDTRL00' USING WS-PROGRAMA WS-AUDIT-DATA
                   MOVE 'GUARDADA' TO WS-MENSAJE
               ELSE
                   MOVE 'ERROR' TO WS-MENSAJE-ERROR.
           CLOSE BRANCH-FILE.
           GO TO 0100-ENTRADA.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'INGRESE CODIGO DE SUCURSAL' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       2000-PANTALLA-ENTRADA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-ENTRADA.
       2100-PANTALLA-BRANCH.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-BRANCH.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM ADMBRH00.
