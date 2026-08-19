      *================================================================*
      * ADMCFG00 - CONFIGURACION DEL SISTEMA                          *
      * EQUIPO: ADMINISTRACION DE SISTEMAS - 2002                      *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADMCFG00.
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
           88  WS-CRT-CLEAR              VALUE 0000.
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'ADMCFG00'.
           05  WS-CONFIRMA                PIC X(01).
           05  WS-AUDIT-DATA              PIC X(60).
       01  WS-CONFIG-FIELDS.
           05  WS-BUSINESS-DATE           PIC 9(08).
           05  WS-NEXT-BUS-DATE           PIC 9(08).
           05  WS-INT-METHOD              PIC X(20).
           05  WS-FEE-DAY                 PIC 9(02).
           05  WS-CUTOFF-TIME             PIC 9(04).
           05  WS-LANGUAGE                PIC X(02).
           05  WS-COUNTRY                 PIC X(03).
       SCREEN SECTION.
       01  SCR-CONFIG.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - CONFIGURACION DEL SISTEMA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 04  COL 05  PIC X(25) VALUE 'FECHA DE NEGOCIO:'.
           05  LINE 04  COL 35  PIC 9(08) USING WS-BUSINESS-DATE AUTO.
           05  LINE 05  COL 05  PIC X(25) VALUE 'SIGUIENTE DIA HABIL:'.
           05  LINE 05  COL 35  PIC 9(08) USING WS-NEXT-BUS-DATE AUTO.
           05  LINE 07  COL 05  PIC X(30) VALUE 'METODO CALCULO INTERES:'.
           05  LINE 07  COL 40  PIC X(20) USING WS-INT-METHOD AUTO.
           05  LINE 08  COL 05  PIC X(25) VALUE 'DIA COBRO COMISION:'.
           05  LINE 08  COL 35  PIC 9(02) USING WS-FEE-DAY AUTO.
           05  LINE 09  COL 05  PIC X(25) VALUE 'HORA CORTE:'.
           05  LINE 09  COL 35  PIC 9(04) USING WS-CUTOFF-TIME AUTO.
           05  LINE 11  COL 05  PIC X(15) VALUE 'IDIOMA:'.
           05  LINE 11  COL 25  PIC X(02) USING WS-LANGUAGE AUTO.
           05  LINE 11  COL 35  PIC X(15) VALUE 'PAIS:'.
           05  LINE 11  COL 55  PIC X(03) USING WS-COUNTRY AUTO.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=GUARDAR  PF12=CANCELAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
           PERFORM 1100-CARGAR-CONFIG.
       0100-PANTALLA.
           PERFORM 2000-PANTALLA-CONFIG.
           ACCEPT SCR-CONFIG.
           IF WS-CRT-PF12 GO TO 9000-EXIT.
           IF WS-CRT-CLEAR PERFORM 1100-CARGAR-CONFIG
               GO TO 0100-PANTALLA.
           MOVE 'CONFIRMA CAMBIOS (S/N)?' TO WS-MENSAJE.
           ACCEPT WS-CONFIRMA FROM CRT.
           IF WS-CONFIRMA = 'S' OR 's'
               PERFORM 3000-GUARDAR-CONFIG.
           GO TO 0100-PANTALLA.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'CONFIGURACION DEL SISTEMA' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       1100-CARGAR-CONFIG.
           MOVE WS-FECHA TO WS-BUSINESS-DATE WS-NEXT-BUS-DATE.
           ADD 10000 TO WS-NEXT-BUS-DATE.
           MOVE 'FRANCESA' TO WS-INT-METHOD.
           MOVE 15 TO WS-FEE-DAY.
           MOVE 1800 TO WS-CUTOFF-TIME.
           MOVE 'ES' TO WS-LANGUAGE.
           MOVE 'MEX' TO WS-COUNTRY.
       2000-PANTALLA-CONFIG.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-CONFIG.
       3000-GUARDAR-CONFIG.
           OPEN I-O PARAMSTR-FILE.
           IF WS-FILE-STATUS NOT = '00'
               MOVE 'ERROR DE ARCHIVO' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT.
           MOVE 'FECHA_NEG' TO PAR-CODIGO.
           READ PARAMSTR-FILE KEY IS PAR-CODIGO
               INVALID KEY
                   MOVE 'GENERAL' TO PAR-GRUPO
                   MOVE 'FECHA NEGOCIO' TO PAR-DESCRIPCION
                   MOVE 'T' TO PAR-TIPO-DATO MOVE 'S' TO PAR-MODIFICABLE
                   WRITE PARAMSTR-RECORD
                   GOTO 3100-SIG
           END-READ.
           MOVE WS-BUSINESS-DATE TO PAR-VALOR-FECHA.
           MOVE WS-FECHA TO PAR-FECHA-MOD.
           MOVE WS-USUARIO TO PAR-USUARIO-MOD.
           REWRITE PARAMSTR-RECORD.
       3100-SIG.
           MOVE 'INT_METODO' TO PAR-CODIGO.
           READ PARAMSTR-FILE KEY IS PAR-CODIGO
               INVALID KEY
                   MOVE 'GENERAL' TO PAR-GRUPO
                   MOVE 'METODO INTERES' TO PAR-DESCRIPCION
                   MOVE WS-INT-METHOD TO PAR-VALOR-TEXTO
                   MOVE 'T' TO PAR-TIPO-DATO MOVE 'S' TO PAR-MODIFICABLE
                   WRITE PARAMSTR-RECORD
                   GOTO 3200-FIN
           END-READ.
           MOVE WS-INT-METHOD TO PAR-VALOR-TEXTO.
           REWRITE PARAMSTR-RECORD.
       3200-FIN.
           CLOSE PARAMSTR-FILE.
           STRING 'CONFIGURACION ACTUALIZADA POR ' WS-USUARIO
             INTO WS-AUDIT-DATA
           CALL 'AUDTRL00' USING WS-PROGRAMA WS-AUDIT-DATA.
           MOVE 'CONFIGURACION GUARDADA' TO WS-MENSAJE.
       3000-EXIT. EXIT.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM ADMCFG00.
