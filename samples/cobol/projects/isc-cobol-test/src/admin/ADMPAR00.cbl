      *================================================================*
      * ADMPAR00 - PARAMETROS DEL SISTEMA                             *
      * EQUIPO: ADMINISTRACION DE SISTEMAS - 2001                      *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADMPAR00.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PARAMSTR-FILE
               ASSIGN TO 'PARAMSTR.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS PAR-CODIGO
               FILE STATUS IS WS-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  PARAMSTR-FILE
           LABEL RECORDS ARE STANDARD RECORD 150 CHARACTERS.
       01  PARAMSTR-RECORD.
           05  PAR-CODIGO                  PIC X(08).
           05  PAR-GRUPO                   PIC X(10).
           05  PAR-DESCRIPCION             PIC X(40).
           05  PAR-VALOR-TEXTO             PIC X(40).
           05  PAR-VALOR-NUMERICO          PIC S9(13)V99 COMP-3.
           05  PAR-VALOR-FECHA             PIC 9(08).
           05  PAR-TIPO-DATO               PIC X(01).
           05  PAR-MODIFICABLE             PIC X(01).
           05  PAR-FECHA-MOD               PIC 9(08).
           05  PAR-USUARIO-MOD             PIC X(08).
           05  PAR-FILLER                  PIC X(05).
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'ADMPAR00'.
           05  WS-GRUPO-SEL               PIC X(10).
           05  WS-PAR-COUNT               PIC 9(02).
           05  WS-PAR-INDEX               PIC 9(02).
       01  WS-PAR-TABLE.
           05  WS-PAR-ENTRY               OCCURS 30.
               10  WS-P-CODIGO            PIC X(08).
               10  WS-P-DESCR             PIC X(40).
               10  WS-P-TEXTO             PIC X(40).
       SCREEN SECTION.
       01  SCR-GRUPO.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - PARAMETROS DEL SISTEMA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 04  COL 05  PIC X(30) VALUE 'GRUPOS DISPONIBLES:'.
           05  LINE 06  COL 10  PIC X(30) VALUE 'GENERAL   - GENERALES'.
           05  LINE 07  COL 10  PIC X(30) VALUE 'TASAS     - TASAS'.
           05  LINE 08  COL 10  PIC X(30) VALUE 'LIMITES   - LIMITES'.
           05  LINE 09  COL 10  PIC X(30) VALUE 'HORARIO   - HORARIOS'.
           05  LINE 10  COL 10  PIC X(30) VALUE 'COMISION  - COMISIONES'.
           05  LINE 11  COL 10  PIC X(30) VALUE 'SEGURIDAD - SEGURIDAD'.
           05  LINE 12  COL 10  PIC X(30) VALUE 'CONTABLE  - CONTABLES'.
           05  LINE 14  COL 05  PIC X(20) VALUE 'SELECCIONE GRUPO:'.
           05  LINE 14  COL 25  PIC X(10) USING WS-GRUPO-SEL AUTO.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=VER  PF12=RETORNAR'.
       01  SCR-PARAMS.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - PARAMETROS'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 04  COL 02  PIC X(60)
               VALUE 'CODIGO    DESCRIPCION               VALOR'.
           05  SCR-PAR-LINE OCCURS 7.
               10  SCR-P-COD    PIC X(08) FROM WS-P-CODIGO.
               10  SCR-P-DESC   PIC X(30) FROM WS-P-DESCR.
               10  SCR-P-VAL    PIC X(20) FROM WS-P-TEXTO.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=REFRESCAR  PF12=RETORNAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-GRUPO-SEL WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
       0100-GRUPO.
           PERFORM 2000-PANTALLA-GRUPO.
           ACCEPT SCR-GRUPO.
           IF WS-CRT-PF12 GO TO 9000-EXIT.
           IF WS-GRUPO-SEL = SPACES
               MOVE 'SELECCIONE UN GRUPO' TO WS-MENSAJE-ERROR
               GO TO 0100-GRUPO.
           OPEN INPUT PARAMSTR-FILE.
           IF WS-FILE-STATUS NOT = '00' GOTO 0100-GRUPO.
           MOVE 0 TO WS-PAR-COUNT.
           MOVE SPACES TO PAR-CODIGO.
           START PARAMSTR-FILE KEY NOT < PAR-CODIGO
               INVALID KEY CLOSE PARAMSTR-FILE GO TO 0200-LISTA.
       0110-READ.
           READ PARAMSTR-FILE NEXT RECORD
               AT END CLOSE PARAMSTR-FILE GO TO 0200-LISTA.
           IF PAR-GRUPO NOT = WS-GRUPO-SEL GOTO 0110-READ.
           ADD 1 TO WS-PAR-COUNT.
           MOVE PAR-CODIGO TO WS-P-CODIGO(WS-PAR-COUNT).
           MOVE PAR-DESCRIPCION TO WS-P-DESCR(WS-PAR-COUNT).
           IF PAR-TIPO-DATO = 'T' OR 'B'
               MOVE PAR-VALOR-TEXTO TO WS-P-TEXTO(WS-PAR-COUNT)
           ELSE
               MOVE PAR-VALOR-TEXTO TO WS-P-TEXTO(WS-PAR-COUNT).
           GOTO 0110-READ.
       0200-LISTA.
           PERFORM 2100-PANTALLA-PARAMS.
           ACCEPT SCR-PARAMS.
           IF WS-CRT-PF12 GO TO 0100-GRUPO.
           GO TO 0200-LISTA.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'SELECCIONE GRUPO DE PARAMETROS' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       2000-PANTALLA-GRUPO.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-GRUPO.
       2100-PANTALLA-PARAMS.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-PARAMS.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM ADMPAR00.
