      *================================================================*
      * COMSECF - FRAMEWORK DE SEGURIDAD                              *
      * PROPOSITO: VALIDACION DE USUARIO, SESION Y AUTORIZACION       *
      * EQUIPO: SEGURIDAD INFORMATICA - 1999                          *
      * USO:   CALL 'COMSECF' USING OPERACION  PARAM1  PARAM2  RET   *
      * OPERACIONES:                                                   *
      *   'LOG' - VALIDAR LOGIN (USUARIO, PASSWORD)                   *
      *   'CHK' - VALIDAR SESION ACTIVA                               *
      *   'PMT' - VERIFICAR PERMISO POR PROGRAMA                      *
      *   'PWD' - VALIDAR FORMATO PASSWORD                            *
      *   'OUT' - CERRAR SESION                                       *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMSECF.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-OPERACION                  PIC X(03).
       01  WS-USUARIO                    PIC X(08).
       01  WS-PASSWORD                   PIC X(20).
       01  WS-PROGRAMA                   PIC X(08).
       01  WS-RETCODE                    PIC 99.
       01  WS-USER-STATUS                PIC X(01).
       01  WS-USER-BLOCKED               PIC X(01).
       01  WS-USER-PWD-TRIES             PIC 9(02).
       01  WS-USER-PWD-EXP               PIC 9(08).
       01  WS-FECHA-HOY                  PIC 9(08).
       01  WS-HORA-ACTUAL                PIC 9(06).
       01  WS-SESSION-TABLE.
           05  WS-SESSION-ENTRY          OCCURS 50.
               10  WS-SES-USR            PIC X(08).
               10  WS-SES-TERMINAL       PIC X(08).
               10  WS-SES-FECHA          PIC 9(08).
               10  WS-SES-HORA           PIC 9(06).
               10  WS-SES-ACTIVA         PIC X(01).
                   88  WS-SES-ACTIVA-SI  VALUE 'S'.
                   88  WS-SES-ACTIVA-NO  VALUE 'N'.
       01  WS-SESSION-COUNT              PIC 9(03) VALUE 0.
       01  WS-USER-PROFILE-EXISTS        PIC X(01).
       01  WS-PERMISO                    PIC X(01).
       01  WS-TEXTO-AUX                  PIC X(60).
       01  WS-FILE-STATUS-CODE           PIC X(02).
       01  WS-IND                        PIC 9(03).
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-OPERACION                   PIC X(03).
       01  LS-PARAM1                      PIC X(20).
       01  LS-PARAM2                      PIC X(20).
       01  LS-RETORNO                     PIC 99.
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-OPERACION
                                 LS-PARAM1
                                 LS-PARAM2
                                 LS-RETORNO.
      *
       MAIN.
           MOVE LS-OPERACION TO WS-OPERACION.
           MOVE 0 TO WS-RETCODE.
      *
           EVALUATE WS-OPERACION
               WHEN 'LOG'
                   PERFORM 1000-VALIDAR-LOGIN
      *
               WHEN 'CHK'
                   PERFORM 2000-VALIDAR-SESION
      *
               WHEN 'PMT'
                   PERFORM 3000-VERIFICAR-PERMISO
      *
               WHEN 'PWD'
                   PERFORM 4000-VALIDAR-PASSWORD
      *
               WHEN 'OUT'
                   PERFORM 5000-CERRAR-SESION
      *
               WHEN OTHER
                   MOVE 99 TO WS-RETCODE
           END-EVALUATE.
      *
           MOVE WS-RETCODE TO LS-RETORNO.
           GOBACK.
      *
      *--- VALIDAR LOGIN ---*
       1000-VALIDAR-LOGIN.
           MOVE LS-PARAM1(1:8) TO WS-USUARIO.
           MOVE LS-PARAM2(1:20) TO WS-PASSWORD.
      *
           IF WS-USUARIO = SPACES OR WS-USUARIO = LOW-VALUES
               MOVE 1 TO WS-RETCODE
               GOTO 1000-EXIT
           END-IF.
      *
           IF WS-PASSWORD = SPACES OR WS-PASSWORD = LOW-VALUES
               MOVE 2 TO WS-RETCODE
               GOTO 1000-EXIT
           END-IF.
      *
           OPEN I-O USERPROF-FILE.
           IF WS-FILE-STATUS-CODE NOT = '00'
               MOVE 4 TO WS-RETCODE
               GOTO 1000-EXIT
           END-IF.
      *
           MOVE WS-USUARIO TO USR-ID.
           READ USERPROF-FILE KEY IS USR-ID
               INVALID KEY
                   MOVE 1 TO WS-RETCODE
                   GOTO 1000-CLOSE
           END-READ.
      *
           IF USR-STATUS NOT = 'A'
               MOVE 5 TO WS-RETCODE
               GOTO 1000-CLOSE
           END-IF.
      *
           IF USR-PASSWORD-BLOCKED = 'Y'
               MOVE 6 TO WS-RETCODE
               GOTO 1000-CLOSE
           END-IF.
      *
           IF USR-PASSWORD NOT = WS-PASSWORD
               ADD 1 TO USR-PASSWORD-TRIES
               IF USR-PASSWORD-TRIES > USR-LOGIN-ATTEMPT-MAX
                   MOVE 'Y' TO USR-PASSWORD-BLOCKED
                   REWRITE USERPROF-RECORD
                   MOVE 6 TO WS-RETCODE
               ELSE
                   REWRITE USERPROF-RECORD
                   MOVE 3 TO WS-RETCODE
               END-IF
               GOTO 1000-CLOSE
           END-IF.
      *
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA-HOY
                                WS-HORA-ACTUAL.
      *
           IF USR-PASSWORD-EXP-DATE < WS-FECHA-HOY
               MOVE 7 TO WS-RETCODE
               GOTO 1000-CLOSE
           END-IF.
      *
           MOVE 0 TO USR-PASSWORD-TRIES.
           MOVE WS-FECHA-HOY TO USR-DATE-LAST-LOGIN.
           MOVE WS-HORA-ACTUAL TO USR-TIME-LAST-LOGIN.
           REWRITE USERPROF-RECORD.
      *
           ADD 1 TO WS-SESSION-COUNT.
           MOVE WS-USUARIO TO WS-SES-USR(WS-SESSION-COUNT).
           MOVE 'TERM01' TO WS-SES-TERMINAL(WS-SESSION-COUNT).
           MOVE WS-FECHA-HOY TO WS-SES-FECHA(WS-SESSION-COUNT).
           MOVE WS-HORA-ACTUAL TO WS-SES-HORA(WS-SESSION-COUNT).
           MOVE 'S' TO WS-SES-ACTIVA(WS-SESSION-COUNT).
      *
           MOVE 0 TO WS-RETCODE.
      *
       1000-CLOSE.
           CLOSE USERPROF-FILE.
       1000-EXIT.
           EXIT.
      *
      *--- VALIDAR SESION ---*
       2000-VALIDAR-SESION.
           MOVE LS-PARAM1(1:8) TO WS-USUARIO.
           MOVE 1 TO WS-IND.
      *
           PERFORM VARYING WS-IND FROM 1 BY 1
               UNTIL WS-IND > WS-SESSION-COUNT
               IF WS-SES-USR(WS-IND) = WS-USUARIO
                   AND WS-SES-ACTIVA(WS-IND) = 'S'
                   MOVE 0 TO WS-RETCODE
                   GOTO 2000-EXIT
               END-IF
           END-PERFORM.
      *
           MOVE 1 TO WS-RETCODE.
       2000-EXIT.
           EXIT.
      *
      *--- VERIFICAR PERMISO ---*
       3000-VERIFICAR-PERMISO.
           MOVE LS-PARAM1(1:8) TO WS-USUARIO.
           MOVE LS-PARAM2(1:8) TO WS-PROGRAMA.
           MOVE 0 TO WS-RETCODE.
      *
      *--- EN SISTEMA REAL AQUI SE VALIDA CONTRA TABLA PERMISOS ---*
      *
       4000-VALIDAR-PASSWORD.
           MOVE LS-PARAM1(1:20) TO WS-PASSWORD.
      *
           IF WS-PASSWORD < SPACES
               MOVE 1 TO WS-RETCODE
               GOTO 4000-EXIT
           END-IF.
      *
           IF WS-PASSWORD = SPACES
               MOVE 2 TO WS-RETCODE
               GOTO 4000-EXIT
           END-IF.
      *
           MOVE 0 TO WS-RETCODE.
       4000-EXIT.
           EXIT.
      *
      *--- CERRAR SESION ---*
       5000-CERRAR-SESION.
           MOVE LS-PARAM1(1:8) TO WS-USUARIO.
      *
           PERFORM VARYING WS-IND FROM 1 BY 1
               UNTIL WS-IND > WS-SESSION-COUNT
               IF WS-SES-USR(WS-IND) = WS-USUARIO
                   MOVE 'N' TO WS-SES-ACTIVA(WS-IND)
               END-IF
           END-PERFORM.
      *
           MOVE 0 TO WS-RETCODE.
      *
       END PROGRAM COMSECF.
