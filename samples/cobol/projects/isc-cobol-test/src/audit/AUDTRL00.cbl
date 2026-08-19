      *================================================================*
      * AUDTRL00 - REGISTRO DE AUDITORIA CENTRALIZADO                 *
      * PROPOSITO: ESCRIBIR PISTA DE AUDITORIA PARA TODO CAMBIO       *
      * EQUIPO: AUDITORIA INTERNA - 2000                              *
      * ARCHIVO: AUDITLOG (INDEXADO)                                   *
      * USO: CALL 'AUDTRL00' USING WS-PROGRAMA WS-DATOS              *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. AUDTRL00.
      *================================================================*
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AUDITLOG-FILE
               ASSIGN TO 'AUDITLOG.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS AUD-SEQ
               FILE STATUS IS WS-FS.
      *================================================================*
       DATA DIVISION.
       FILE SECTION.
       FD  AUDITLOG-FILE
           RECORD 200 CHARACTERS.
       01  AUDITLOG-RECORD.
           05  AUD-SEQ                     PIC 9(10).
           05  AUD-DATE                    PIC 9(08).
           05  AUD-TIME                    PIC 9(06).
           05  AUD-USUARIO                 PIC X(08).
           05  AUD-TERMINAL                PIC X(08).
           05  AUD-PROGRAMA                PIC X(08).
           05  AUD-EVENTO                  PIC X(02).
           05  AUD-ENTITY-TYPE             PIC X(02).
           05  AUD-ENTITY-KEY              PIC X(20).
           05  AUD-CAMPO-ANTERIOR          PIC X(60).
           05  AUD-CAMPO-NUEVO             PIC X(60).
           05  AUD-RESULTADO               PIC X(01).
           05  AUD-OBSERVACIONES           PIC X(30).
           05  AUD-FILLER                  PIC X(15).
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-FS                           PIC X(02).
           88  WS-FS-OK                   VALUE '00'.
           88  WS-FS-DUP                  VALUE '22'.
       01  WS-SEQ-COUNT                   PIC 9(10) VALUE 0.
       01  WS-PROGRAMA                    PIC X(08).
       01  WS-DATOS                       PIC X(60).
       01  WS-FECHA                       PIC 9(08).
       01  WS-HORA                        PIC 9(06).
       01  WS-USUARIO-ACTUAL              PIC X(08) VALUE 'SYSTEM'.
       01  WS-SUCURSAL                    PIC X(04) VALUE '0001'.
       01  WS-TERMINAL                    PIC X(08) VALUE 'TERM001'.
       01  WS-TEXTO-AUX                   PIC X(60).
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-PROGRAMA                    PIC X(08).
       01  LS-DATOS                       PIC X(60).
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-PROGRAMA
                                 LS-DATOS.
      *
       MAIN.
           MOVE LS-PROGRAMA TO WS-PROGRAMA.
           MOVE LS-DATOS TO WS-DATOS.
      *
           PERFORM 1000-OBTENER-FECHA-HORA.
           PERFORM 2000-GENERAR-SECUENCIA.
           PERFORM 3000-ARMAR-REGISTRO.
           PERFORM 4000-ESCRIBIR.
           GOBACK.
      *
       1000-OBTENER-FECHA-HORA.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
      *
       2000-GENERAR-SECUENCIA.
           ADD 1 TO WS-SEQ-COUNT.
           MOVE WS-SEQ-COUNT TO AUD-SEQ.
      *
       3000-ARMAR-REGISTRO.
           MOVE WS-FECHA TO AUD-DATE.
           MOVE WS-HORA TO AUD-TIME.
           MOVE WS-USUARIO-ACTUAL TO AUD-USUARIO.
           MOVE WS-TERMINAL TO AUD-TERMINAL.
           MOVE WS-PROGRAMA TO AUD-PROGRAMA.
           MOVE 'CA' TO AUD-EVENTO.
           MOVE 'TR' TO AUD-ENTITY-TYPE.
           MOVE WS-DATOS TO AUD-OBSERVACIONES.
           MOVE WS-DATOS TO AUD-ENTITY-KEY.
           MOVE SPACES TO AUD-CAMPO-ANTERIOR
                          AUD-CAMPO-NUEVO.
           MOVE 'O' TO AUD-RESULTADO.
      *
       4000-ESCRIBIR.
           OPEN I-O AUDITLOG-FILE.
           IF WS-FS-OK
               WRITE AUDITLOG-RECORD
               CLOSE AUDITLOG-FILE
           ELSE
               OPEN OUTPUT AUDITLOG-FILE
               IF WS-FS-OK
                   WRITE AUDITLOG-RECORD
               END-IF
               CLOSE AUDITLOG-FILE
           END-IF.
      *
       END PROGRAM AUDTRL00.
