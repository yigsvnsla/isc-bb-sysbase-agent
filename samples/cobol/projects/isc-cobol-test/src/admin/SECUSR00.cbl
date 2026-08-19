      *================================================================*
      * SECUSR00 - ADMINISTRACION DE USUARIOS                         *
      * EQUIPO: SEGURIDAD - 2000                                       *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SECUSR00.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT USERPROF-FILE
               ASSIGN TO 'USERPROF.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS USR-ID
               FILE STATUS IS WS-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  USERPROF-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 180 CHARACTERS.
       01  USERPROF-RECORD.
           05  USR-ID                      PIC X(08).
           05  USR-NAME                    PIC X(40).
           05  USR-LAST-NAME               PIC X(30).
           05  USR-FIRST-NAME              PIC X(30).
           05  USR-PASSWORD                PIC X(20).
           05  USR-PASSWORD-EXP-DATE       PIC 9(08).
           05  USR-PASSWORD-LAST-CHG       PIC 9(08).
           05  USR-PASSWORD-TRIES          PIC 9(02).
           05  USR-PASSWORD-BLOCKED        PIC X.
           05  USR-PASSWORD-RESET          PIC X.
           05  USR-ROLE                    PIC X(03).
           05  USR-BRANCH                  PIC X(04).
           05  USR-DEPARTMENT              PIC X(04).
           05  USR-LOGIN-TIME-FROM         PIC 9(04).
           05  USR-LOGIN-TIME-TO           PIC 9(04).
           05  USR-LOGIN-IP-RANGE          PIC X(15).
           05  USR-LOGIN-ATTEMPT-MAX       PIC 9(02).
           05  USR-SESSION-TIMEOUT         PIC 9(04).
           05  USR-EMAIL                   PIC X(50).
           05  USR-PHONE                   PIC X(15).
           05  USR-EXTENSION               PIC X(05).
           05  USR-STATUS                  PIC X(01).
           05  USR-DATE-HIRED              PIC 9(08).
           05  USR-DATE-TERMINATED         PIC 9(08).
           05  USR-DATE-LAST-LOGIN         PIC 9(08).
           05  USR-TIME-LAST-LOGIN         PIC 9(06).
           05  USR-FILLER                  PIC X(20).
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
           88  WS-CRT-CLEAR              VALUE 0000.
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
           05  WS-PROGRAMA                PIC X(08) VALUE 'SECUSR00'.
           05  WS-USER-ID                 PIC X(08).
           05  WS-AUDIT-DATA              PIC X(60).
           05  WS-FLAG-ERROR              PIC X(01).
               88  WS-HAY-ERROR           VALUE 'S'.
       SCREEN SECTION.
       01  SCR-ENTRADA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - ADMINISTRACION DE USUARIOS'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 05  PIC X(15) VALUE 'ID DE USUARIO:'.
           05  LINE 05  COL 25  PIC X(08)
               USING WS-USER-ID AUTO PROMPT '________'.
           05  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=CONSULTAR  PF12=RETORNAR'.
       01  SCR-DISPLAY.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - DATOS DE USUARIO'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 03  COL 02  PIC X(10) VALUE 'USUARIO:'.
           05  LINE 03  COL 15  PIC X(08) FROM USR-ID.
           05  LINE 03  COL 35  PIC X(15) VALUE 'NOMBRE:'.
           05  LINE 03  COL 55  PIC X(40) USING USR-NAME AUTO.
           05  LINE 04  COL 02  PIC X(10) VALUE 'APELLIDO:'.
           05  LINE 04  COL 15  PIC X(30) USING USR-LAST-NAME AUTO.
           05  LINE 04  COL 50  PIC X(10) VALUE 'NOMBRE:'.
           05  LINE 04  COL 60  PIC X(30) USING USR-FIRST-NAME AUTO.
           05  LINE 06  COL 02  PIC X(10) VALUE 'ROL:'.
           05  LINE 06  COL 15  PIC X(03) USING USR-ROLE AUTO.
           05  LINE 06  COL 30  PIC X(15) VALUE 'SUCURSAL:'.
           05  LINE 06  COL 45  PIC X(04) USING USR-BRANCH AUTO.
           05  LINE 06  COL 55  PIC X(10) VALUE 'DPTO:'.
           05  LINE 06  COL 65  PIC X(04) USING USR-DEPARTMENT AUTO.
           05  LINE 07  COL 02  PIC X(10) VALUE 'EMAIL:'.
           05  LINE 07  COL 15  PIC X(50) USING USR-EMAIL AUTO.
           05  LINE 08  COL 02  PIC X(10) VALUE 'TELEFONO:'.
           05  LINE 08  COL 15  PIC X(15) USING USR-PHONE AUTO.
           05  LINE 10  COL 02  PIC X(15) VALUE 'HORA ACCESO:'.
           05  LINE 10  COL 20  PIC 9(04) USING USR-LOGIN-TIME-FROM AUTO.
           05  LINE 10  COL 30  PIC X(03) VALUE ' A '.
           05  LINE 10  COL 35  PIC 9(04) USING USR-LOGIN-TIME-TO AUTO.
           05  LINE 11  COL 02  PIC X(15) VALUE 'INTENTOS MAX:'.
           05  LINE 11  COL 20  PIC 9(02) USING USR-LOGIN-ATTEMPT-MAX AUTO.
           05  LINE 11  COL 35  PIC X(15) VALUE 'TIMEOUT:'.
           05  LINE 11  COL 55  PIC 9(04) USING USR-SESSION-TIMEOUT AUTO.
           05  LINE 12  COL 02  PIC X(10) VALUE 'ESTATUS:'.
           05  LINE 12  COL 15  PIC X(01) USING USR-STATUS AUTO.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=GUARDAR  PF12=CANCELAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-USER-ID WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
       0100-ENTRADA.
           PERFORM 2000-PANTALLA-ENTRADA.
           ACCEPT SCR-ENTRADA.
           IF WS-CRT-PF12 GO TO 9000-EXIT.
           IF WS-USER-ID = SPACES
               MOVE 'INGRESE ID DE USUARIO' TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
           OPEN I-O USERPROF-FILE.
           IF WS-FILE-STATUS NOT = '00' GOTO 0100-ENTRADA.
           MOVE WS-USER-ID TO USR-ID.
           READ USERPROF-FILE KEY IS USR-ID
               INVALID KEY CLOSE USERPROF-FILE
               MOVE 'USUARIO NO ENCONTRADO' TO WS-MENSAJE-ERROR
               GO TO 0100-ENTRADA.
           PERFORM 2100-PANTALLA-DISPLAY.
           ACCEPT SCR-DISPLAY.
           IF WS-CRT-PF12
               CLOSE USERPROF-FILE GO TO 0100-ENTRADA.
           MOVE 'N' TO WS-FLAG-ERROR.
           IF USR-NAME = SPACES
               MOVE 'NOMBRE REQUERIDO' TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR.
           IF WS-NO-HAY-ERROR
               REWRITE USERPROF-RECORD
               IF WS-FILE-STATUS = '00'
                   STRING 'USUARIO ' USR-ID ' ACTUALIZADO'
                     INTO WS-AUDIT-DATA
                   CALL 'AUDTRL00' USING WS-PROGRAMA WS-AUDIT-DATA
                   MOVE 'USUARIO ACTUALIZADO' TO WS-MENSAJE
               ELSE
                   MOVE 'ERROR AL GUARDAR' TO WS-MENSAJE-ERROR.
           CLOSE USERPROF-FILE.
           GO TO 0100-ENTRADA.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'INGRESE ID DE USUARIO' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       2000-PANTALLA-ENTRADA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-ENTRADA.
       2100-PANTALLA-DISPLAY.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-DISPLAY.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM SECUSR00.
