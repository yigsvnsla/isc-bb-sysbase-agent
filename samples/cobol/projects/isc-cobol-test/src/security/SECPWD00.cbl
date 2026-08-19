       *================================================================*
       * SECPWD00 - CAMBIO DE PASSWORD DE USUARIO                     *
       * PROPOSITO: CAMBIAR PASSWORD, VALIDAR HISTORIAL,              *
       *            ACTUALIZAR FECHA DE EXPIRACION                   *
       * EQUIPO: SEGURIDAD INFORMATICA - 1998                        *
       * ARCHIVOS: USERPROF (I-O)                                    *
       * CALL: COMDATE, COMMSGF, AUDTRL00                            *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SECPWD00.
      *================================================================*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
      *================================================================*
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT USERPROF-FILE
               ASSIGN TO 'USERPROF.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS USR-ID
               FILE STATUS IS FL-USERPROF-STATUS.
      *================================================================*
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
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF1                VALUE 1001.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
           88  WS-CRT-CLEAR              VALUE 0000.
      *
       01  WS-FLAG-ERROR                  PIC X(01).
           88  WS-HAY-ERROR               VALUE 'S'.
           88  WS-NO-HAY-ERROR            VALUE 'N'.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'SECPWD00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V1.3'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-ID-USUARIO              PIC X(08).
           05  WS-PWD-ACTUAL              PIC X(20).
           05  WS-PWD-NUEVA               PIC X(20).
           05  WS-PWD-CONFIRMA            PIC X(20).
           05  WS-NOMBRE-USUARIO          PIC X(40).
           05  WS-USUARIO-ENCONTRADO      PIC X(01).
           05  WS-EXP-DATE                PIC 9(08).
           05  WS-LONGITUD                PIC 9(02).
           05  WS-I                       PIC 9(02).
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-BUSQUEDA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - CAMBIO DE PASSWORD'.
           05  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
           05  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
           05  LINE 02  COL 01  PIC X(80)
               VALUE ' MODULO DE SEGURIDAD - PASSWORD'.
           05  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 10  PIC X(20) VALUE 'USUARIO:'.
           05  LINE 05  COL 22  PIC X(08) USING WS-ID-USUARIO.
           05  LINE 07  COL 10  PIC X(40)
               VALUE 'DEJE EN BLANCO PARA SU PROPIO USUARIO'.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=CONTINUAR  PF12=CANCELAR'.
      *
       01  SCR-CAMBIO.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - CAMBIO DE PASSWORD'.
           05  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
           05  LINE 02  COL 01  PIC X(80)
               VALUE ' INGRESE NUEVA CONTRASENA'.
           05  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
           05  LINE 05  COL 10  PIC X(20) VALUE 'USUARIO:'.
           05  LINE 05  COL 30  PIC X(08) FROM WS-ID-USUARIO.
           05  LINE 06  COL 10  PIC X(20) VALUE 'NOMBRE:'.
           05  LINE 06  COL 30  PIC X(40) FROM WS-NOMBRE-USUARIO.
           05  LINE 08  COL 10  PIC X(25) VALUE 'PASSWORD ACTUAL:'.
           05  LINE 08  COL 38  PIC X(20) USING WS-PWD-ACTUAL SECURE.
           05  LINE 10  COL 10  PIC X(25) VALUE 'PASSWORD NUEVO:'.
           05  LINE 10  COL 38  PIC X(20) USING WS-PWD-NUEVA SECURE.
           05  LINE 12  COL 10  PIC X(25) VALUE 'CONFIRMAR NUEVO:'.
           05  LINE 12  COL 38  PIC X(20) USING WS-PWD-CONFIRMA SECURE.
           05  LINE 14  COL 10  PIC X(60) FROM WS-MENSAJE-ERROR BLINK.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
      *
       01  SCR-CONFIRMACION.
           05  LINE 10  COL 10  PIC X(40)
               VALUE 'PASSWORD CAMBIADO EXITOSAMENTE'.
           05  LINE 12  COL 10  PIC X(40)
               VALUE 'PRESIONE ENTER PARA CONTINUAR'.
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-USUARIO
                                 LS-RETCODE.
      *
       MAIN.
           MOVE SPACES TO WS-MENSAJE
                          WS-MENSAJE-ERROR
                          WS-ID-USUARIO.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 0 TO WS-RETCODE.
      *
           PERFORM 1000-INICIALIZAR.
           PERFORM 2000-BUSCAR-USUARIO.
      *
           IF WS-ID-USUARIO = SPACES
               MOVE 'USUARIO NO ESPECIFICADO' TO WS-MENSAJE-ERROR
               PERFORM 9000-FINALIZAR
               GOBACK.
      *
           PERFORM 3000-VALIDAR-USUARIO.
           IF WS-HAY-ERROR
               PERFORM 9000-FINALIZAR
               GOBACK.
      *
           PERFORM 4000-INGRESAR-PASSWORD.
           IF WS-HAY-ERROR
               PERFORM 9000-FINALIZAR
               GOBACK.
      *
           PERFORM 5000-ACTUALIZAR.
      *
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 'N' TO WS-HAY-ERROR.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       2000-BUSCAR-USUARIO.
           DISPLAY SCR-BUSQUEDA.
           ACCEPT SCR-BUSQUEDA.
           IF WS-ID-USUARIO = SPACES OR LOW-VALUES
               MOVE WS-USUARIO TO WS-ID-USUARIO.
      *
       3000-VALIDAR-USUARIO.
           MOVE 'N' TO WS-FLAG-ERROR.
           OPEN INPUT USERPROF-FILE.
           IF FL-USERPROF-STATUS NOT = '00'
               MOVE 'ERROR DE ARCHIVO' TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR
               GOTO 3000-EXIT.
      *
           MOVE WS-ID-USUARIO TO USR-ID.
           READ USERPROF-FILE KEY IS USR-ID
               INVALID KEY
                   MOVE 'USUARIO NO REGISTRADO' TO WS-MENSAJE-ERROR
                   MOVE 'S' TO WS-FLAG-ERROR
                   CLOSE USERPROF-FILE
                   GOTO 3000-EXIT.
           IF USR-STATUS NOT = 'A'
               MOVE 'USUARIO INACTIVO' TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR
               CLOSE USERPROF-FILE
               GOTO 3000-EXIT.
           MOVE USR-NAME TO WS-NOMBRE-USUARIO.
           CLOSE USERPROF-FILE.
       3000-EXIT.
           EXIT.
      *
       4000-INGRESAR-PASSWORD.
           MOVE 'N' TO WS-FLAG-ERROR.
           MOVE SPACES TO WS-PWD-ACTUAL
                          WS-PWD-NUEVA
                          WS-PWD-CONFIRMA
                          WS-MENSAJE-ERROR.
      *
       4100-PWD-LOOP.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-CAMBIO.
           ACCEPT SCR-CAMBIO.
      *
           IF WS-CRT-PF12
               MOVE 'PROCESO CANCELADO' TO WS-MENSAJE
               MOVE 'S' TO WS-FLAG-ERROR
               GOTO 4000-EXIT.
      *
           IF WS-PWD-NUEVA = SPACES OR LOW-VALUES
               MOVE 'INGRESE NUEVO PASSWORD' TO WS-MENSAJE-ERROR
               GOTO 4100-PWD-LOOP.
      *
           IF WS-PWD-NUEVA NOT = WS-PWD-CONFIRMA
               MOVE 'PASSWORDS NO COINCIDEN' TO WS-MENSAJE-ERROR
               GOTO 4100-PWD-LOOP.
      *
           IF WS-PWD-NUEVA = WS-PWD-ACTUAL
               MOVE 'NUEVO PASSWORD DEBE SER DIFERENTE'
                 TO WS-MENSAJE-ERROR
               GOTO 4100-PWD-LOOP.
      *
           IF WS-PWD-NUEVA = WS-ID-USUARIO
               MOVE 'PASSWORD NO PUEDE SER IGUAL AL USUARIO'
                 TO WS-MENSAJE-ERROR
               GOTO 4100-PWD-LOOP.
      *
           MOVE 0 TO WS-LONGITUD.
           INSPECT WS-PWD-NUEVA TALLYING WS-LONGITUD
               FOR CHARACTERS BEFORE INITIAL SPACE.
           IF WS-LONGITUD < 6
               MOVE 'PASSWORD DEBE TENER 6+ CARACTERES'
                 TO WS-MENSAJE-ERROR
               GOTO 4100-PWD-LOOP.
      *
       4000-EXIT.
           EXIT.
      *
       5000-ACTUALIZAR.
           MOVE 'N' TO WS-FLAG-ERROR.
           OPEN I-O USERPROF-FILE.
           IF FL-USERPROF-STATUS NOT = '00'
               MOVE 'ERROR DE ARCHIVO' TO WS-MENSAJE-ERROR
               GOTO 5000-EXIT.
      *
           MOVE WS-ID-USUARIO TO USR-ID.
           READ USERPROF-FILE KEY IS USR-ID
               INVALID KEY
                   MOVE 'USUARIO NO EXISTE' TO WS-MENSAJE-ERROR
                   CLOSE USERPROF-FILE
                   GOTO 5000-EXIT.
      *
           MOVE WS-PWD-NUEVA TO USR-PASSWORD.
           CALL 'COMDATE' USING 'ADD'
                                WS-FECHA
                                00090.
           MOVE WS-FECHA TO USR-PASSWORD-EXP-DATE.
           MOVE WS-FECHA TO USR-PASSWORD-LAST-CHG.
           MOVE 0 TO USR-PASSWORD-TRIES.
           MOVE 'N' TO USR-PASSWORD-BLOCKED.
      *
           REWRITE USERPROF-RECORD.
           IF FL-USERPROF-STATUS NOT = '00'
               MOVE 'ERROR AL ACTUALIZAR' TO WS-MENSAJE-ERROR
               CLOSE USERPROF-FILE
               GOTO 5000-EXIT.
      *
           CLOSE USERPROF-FILE.
      *
           CALL 'AUDTRL00' USING WS-PROGRAMA
                                 'PASSWORD CHANGED ' WS-ID-USUARIO.
      *
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-CONFIRMACION.
           ACCEPT SCR-CONFIRMACION.
           MOVE 'PASSWORD ACTUALIZADO CORRECTAMENTE'
             TO WS-MENSAJE.
      *
       5000-EXIT.
           EXIT.
      *
       9000-FINALIZAR.
           CLOSE USERPROF-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM SECPWD00.
