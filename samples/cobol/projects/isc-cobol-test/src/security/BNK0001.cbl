      *================================================================*
      * BNK0001 - LOGIN / AUTENTICACION DE USUARIO                    *
      * PROPOSITO: PANTALLA DE INGRESO, VALIDACION, CAMBIO PASSWORD   *
      * EQUIPO: SEGURIDAD - 1997 (REVISADO 2004)                     *
      * ARCHIVOS: USERPROF (INDEXADO)                                 *
      * LLAMADOR: COMMENU                                            *
      * RETORNA:  WS-USUARIO, WS-SUCURSAL, WS-RETCODE                *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BNK0001.
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
               FILE STATUS IS WS-FILE-STATUS.
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
               88  USR-PWD-BLOCKED-YES     VALUE 'Y'.
               88  USR-PWD-BLOCKED-NO      VALUE 'N'.
           05  USR-PASSWORD-RESET          PIC X.
               88  USR-PWD-RESET-YES       VALUE 'Y'.
               88  USR-PWD-RESET-NO        VALUE 'N'.
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
               88  USR-STATUS-ACTIVE       VALUE 'A'.
               88  USR-STATUS-INACTIVE     VALUE 'I'.
               88  USR-STATUS-SUSPENDED    VALUE 'S'.
               88  USR-STATUS-TERMINATED   VALUE 'T'.
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
           88  WS-CRT-PF2                VALUE 1002.
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
           88  WS-CRT-CLEAR              VALUE 0000.
      *
       01  WS-FILE-STATUS                 PIC X(02).
           88  FS-OK                      VALUE '00'.
           88  FS-NOT-FOUND               VALUE '23'.
           88  FS-DUPLICATE               VALUE '22'.
      *
       01  WS-FLAG-ERROR                  PIC X(01).
           88  WS-HAY-ERROR               VALUE 'S'.
           88  WS-NO-HAY-ERROR            VALUE 'N'.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-CONTRASENA              PIC X(20).
           05  WS-CONTRASENA-ANTERIOR     PIC X(20).
           05  WS-CONTRASENA-NUEVA        PIC X(20).
           05  WS-CONTRASENA-CONFIRMA     PIC X(20).
           05  WS-FECHA-HOY               PIC 9(08).
           05  WS-FECHA-HOY-DDMM          PIC 9(08).
           05  WS-HORA-ACTUAL             PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-INTENTOS                PIC 9(02).
           05  WS-INTENTOS-MAX            PIC 9(02) VALUE 3.
           05  WS-SUCURSAL                PIC X(04).
           05  WS-NOMBRE-USUARIO          PIC X(40).
           05  WS-PROGRAMA                PIC X(08) VALUE 'BNK0001'.
           05  WS-VERSION                 PIC X(06) VALUE 'V5.2'.
           05  WS-CAMBIO-PASSWORD         PIC X(01).
               88  WS-CAMBIO-SI           VALUE 'S'.
               88  WS-CAMBIO-NO           VALUE 'N'.
           05  WS-PASSWORD-EXPIRADA       PIC X(01).
               88  WS-PWD-EXPIRED         VALUE 'S'.
               88  WS-PWD-VIGENTE         VALUE 'N'.
           05  WS-VALIDACION-OK           PIC X(01).
               88  WS-LOGIN-OK            VALUE 'S'.
               88  WS-LOGIN-FALLIDO       VALUE 'N'.
           05  WS-PWD-VALIDA              PIC X(01).
               88  WS-PWD-OK              VALUE 'S'.
               88  WS-PWD-MAL             VALUE 'N'.
           05  WS-DIAS-PWD                PIC 9(04).
           05  WS-DIAS-RESTANTES          PIC 9(04).
           05  WS-CONTADOR                PIC 9(02).
      *
      *================================================================*
       SCREEN SECTION.
      *
      *--- PANTALLA DE LOGIN ---*
       01  SCR-LOGIN.
           05  SCR-LOGIN-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
               10  LINE 01  COL 65  PIC X(06) FROM WS-VERSION.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' MODULO DE ACCESO AL SISTEMA'.
      *
           05  SCR-LOGIN-CUERPO.
               10  LINE 05  COL 20  PIC X(40)
                   VALUE 'BIENVENIDO AL SISTEMA BANCARIO'.
               10  LINE 07  COL 20  PIC X(20) VALUE 'USUARIO:'.
               10  LINE 07  COL 32  PIC X(08)
                   USING WS-USUARIO AUTO PROMPT '________'.
               10  LINE 09  COL 20  PIC X(20) VALUE 'CONTRASENA:'.
               10  LINE 09  COL 32  PIC X(20)
                   USING WS-CONTRASENA AUTO PROMPT '___________________'
                   SECURE.
      *
           05  SCR-LOGIN-MENSAJE.
               10  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
      *
           05  SCR-LOGIN-PIE.
               10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 24  COL 02  PIC X(35)
                   VALUE 'PF1=AYUDA  PF12=SALIR  ENTER=ACEPTAR'.
      *
      *--- PANTALLA DE CAMBIO DE CONTRASENA ---*
       01  SCR-CAMBIO-PWD.
           05  SCR-CAMBIO-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - CAMBIO DE CONTRASENA'.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' SU CONTRASENA HA EXPIRADO - DEBE CAMBIARLA'.
      *
           05  SCR-CAMBIO-CUERPO.
               10  LINE 05  COL 15  PIC X(30) VALUE 'USUARIO:'.
               10  LINE 05  COL 30  PIC X(08) FROM WS-USUARIO.
               10  LINE 07  COL 15  PIC X(25) VALUE 'CONTRASENA ANTERIOR:'.
               10  LINE 07  COL 42  PIC X(20)
                   USING WS-CONTRASENA-ANTERIOR AUTO SECURE.
               10  LINE 09  COL 15  PIC X(25) VALUE 'CONTRASENA NUEVA:'.
               10  LINE 09  COL 42  PIC X(20)
                   USING WS-CONTRASENA-NUEVA AUTO SECURE.
               10  LINE 11  COL 15  PIC X(25) VALUE 'CONFIRMAR NUEVA:'.
               10  LINE 11  COL 42  PIC X(20)
                   USING WS-CONTRASENA-CONFIRMA AUTO SECURE.
      *
           05  SCR-CAMBIO-MENSAJE.
               10  LINE 14  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
      *
           05  SCR-CAMBIO-PIE.
               10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 24  COL 05  PIC X(40)
                   VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
      *
      *--- PANTALLA DE INFORMACION DE SESION ---*
       01  SCR-SESION-INFO.
           05  LINE 05  COL 15  PIC X(40) FROM WS-MENSAJE.
           05  LINE 07  COL 15  PIC X(20) VALUE 'USUARIO:'.
           05  LINE 07  COL 30  PIC X(08) FROM WS-USUARIO.
           05  LINE 08  COL 15  PIC X(20) VALUE 'NOMBRE:'.
           05  LINE 08  COL 30  PIC X(40) FROM WS-NOMBRE-USUARIO.
           05  LINE 09  COL 15  PIC X(20) VALUE 'SUCURSAL:'.
           05  LINE 09  COL 30  PIC X(04) FROM WS-SUCURSAL.
           05  LINE 10  COL 15  PIC X(20) VALUE 'FECHA:'.
           05  LINE 10  COL 30  PIC 9(08) FROM WS-FECHA-HOY-DDMM.
           05  LINE 12  COL 15  PIC X(40)
               VALUE 'PRESIONE ENTER PARA CONTINUAR...'.
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-USUARIO                     PIC X(08).
       01  LS-SUCURSAL                    PIC X(04).
       01  LS-RETCODE                     PIC 99.
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-USUARIO
                                 LS-SUCURSAL
                                 LS-RETCODE.
      *
       MAIN.
           MOVE SPACES TO WS-USUARIO
                          WS-CONTRASENA
                          WS-MENSAJE
                          WS-MENSAJE-ERROR.
           MOVE 0 TO WS-INTENTOS.
           MOVE 'N' TO WS-LOGIN-FALLIDO.
           MOVE SPACES TO LS-USUARIO.
           MOVE SPACES TO LS-SUCURSAL.
           MOVE 99 TO LS-RETCODE.
      *
           PERFORM 1000-INICIALIZAR.
      *
       LOGIN-LOOP.
           PERFORM 2000-MOSTRAR-PANTALLA-LOGIN.
           ACCEPT SCR-LOGIN.
      *
           EVALUATE TRUE
               WHEN WS-CRT-PF1
                   CALL 'COMHELP' USING 'LOGIN'
                   GO TO LOGIN-LOOP
      *
               WHEN WS-CRT-PF12
                   MOVE 'SESION CANCELADA POR EL USUARIO'
                     TO WS-MENSAJE
                   MOVE 99 TO LS-RETCODE
                   PERFORM 9000-FINALIZAR
      *
               WHEN WS-CRT-CLEAR
                   MOVE SPACES TO WS-USUARIO
                                  WS-CONTRASENA
                                  WS-MENSAJE
                                  WS-MENSAJE-ERROR
                   GO TO LOGIN-LOOP
      *
               WHEN WS-CRT-ENTER
                   PERFORM 3000-VALIDAR-ENTRADA
                   IF WS-NO-HAY-ERROR
                       PERFORM 4000-PROCESAR-LOGIN
                       IF WS-LOGIN-OK
                           IF WS-PWD-EXPIRED
                               PERFORM 5000-CAMBIO-PASSWORD
                               IF WS-CAMBIO-NO
                                   MOVE 'CAMBIO OBLIGATORIO FALLIDO'
                                     TO WS-MENSAJE-ERROR
                                   ADD 1 TO WS-INTENTOS
                                   GO TO LOGIN-LOOP
                               END-IF
                           END-IF
                           PERFORM 6000-SESION-OK
                           PERFORM 7000-LLAMAR-MENU
                           GO TO LOGIN-EXIT
                       ELSE
                           ADD 1 TO WS-INTENTOS
                           IF WS-INTENTOS >= WS-INTENTOS-MAX
                               MOVE 'USUARIO BLOQUEADO - CONTACTE'
                                 TO WS-MENSAJE-ERROR
                               PERFORM 8000-BLOQUEAR-USUARIO
                               GO TO LOGIN-LOOP
                           END-IF
                           GO TO LOGIN-LOOP
                       END-IF
                   ELSE
                       GO TO LOGIN-LOOP
                   END-IF
      *
               WHEN OTHER
                   MOVE 'USE ENTER PARA ACEPTAR O PF12 PARA SALIR'
                     TO WS-MENSAJE-ERROR
                   GO TO LOGIN-LOOP
           END-EVALUATE.
      *
       LOGIN-EXIT.
           EXIT.
      *
      *--- INICIALIZAR ---*
       1000-INICIALIZAR.
           MOVE SPACES TO WS-MENSAJE.
           MOVE SPACES TO WS-MENSAJE-ERROR.
           MOVE 0 TO WS-INTENTOS.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA-HOY
                                WS-HORA-ACTUAL.
           MOVE WS-FECHA-HOY TO WS-FECHA-HOY-DDMM.
           MOVE 'BIENVENIDO - INGRESE SU USUARIO Y CONTRASENA'
             TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR-PANTALLA.
      *
       1100-LIMPIAR-PANTALLA.
           DISPLAY SPACES UPON CRT.
      *
      *--- MOSTRAR PANTALLA LOGIN ---*
       2000-MOSTRAR-PANTALLA-LOGIN.
           PERFORM 1100-LIMPIAR-PANTALLA.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA-HOY
                                WS-HORA-ACTUAL.
           MOVE WS-FECHA-HOY TO WS-FECHA-HOY-DDMM.
           DISPLAY SCR-LOGIN.
      *
      *--- VALIDAR ENTRADA DE CAMPOS ---*
       3000-VALIDAR-ENTRADA.
           MOVE 'N' TO WS-FLAG-ERROR.
           MOVE SPACES TO WS-MENSAJE-ERROR.
      *
           IF WS-USUARIO = SPACES OR WS-USUARIO = LOW-VALUES
               MOVE 'INGRESE SU USUARIO' TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR
               GOTO 3000-EXIT
           END-IF.
      *
           IF WS-CONTRASENA = SPACES OR WS-CONTRASENA = LOW-VALUES
               MOVE 'INGRESE SU CONTRASENA' TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR
               GOTO 3000-EXIT
           END-IF.
      *
           IF WS-CONTRASENA = WS-USUARIO
               MOVE 'CONTRASENA NO PUEDE SER IGUAL AL USUARIO'
                 TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR
               GOTO 3000-EXIT
           END-IF.
      *
           IF WS-CONTRASENA = '        '
               OR WS-CONTRASENA = '                '
               MOVE 'CONTRASENA INVALIDA' TO WS-MENSAJE-ERROR
               MOVE 'S' TO WS-FLAG-ERROR
               GOTO 3000-EXIT
           END-IF.
      *
       3000-EXIT.
           EXIT.
      *
      *--- PROCESAR LOGIN CONTRA ARCHIVO ---*
       4000-PROCESAR-LOGIN.
           MOVE 'N' TO WS-LOGIN-FALLIDO.
           MOVE SPACES TO WS-MENSAJE-ERROR.
      *
           OPEN I-O USERPROF-FILE.
           IF WS-FILE-STATUS NOT = '00'
               MOVE 'ERROR DE ARCHIVO - CONTACTE AL ADMINISTRADOR'
                 TO WS-MENSAJE-ERROR
               MOVE 'N' TO WS-LOGIN-FALLIDO
               GOTO 4000-EXIT
           END-IF.
      *
           MOVE WS-USUARIO TO USR-ID.
           READ USERPROF-FILE KEY IS USR-ID
               INVALID KEY
                   MOVE 'USUARIO NO REGISTRADO EN EL SISTEMA'
                     TO WS-MENSAJE-ERROR
                   MOVE 'N' TO WS-LOGIN-FALLIDO
                   CLOSE USERPROF-FILE
                   GOTO 4000-EXIT
           END-READ.
      *
           IF USR-STATUS NOT = 'A'
               IF USR-STATUS = 'I'
                   MOVE 'USUARIO INACTIVO - CONTACTE ADMIN'
                     TO WS-MENSAJE-ERROR
               ELSE
                   IF USR-STATUS = 'S'
                       MOVE 'USUARIO SUSPENDIDO - CONTACTE ADMIN'
                         TO WS-MENSAJE-ERROR
                   ELSE
                       MOVE 'USUARIO DADO DE BAJA'
                         TO WS-MENSAJE-ERROR
                   END-IF
               END-IF
               MOVE 'N' TO WS-LOGIN-FALLIDO
               CLOSE USERPROF-FILE
               GOTO 4000-EXIT
           END-IF.
      *
           IF USR-PWD-BLOCKED-YES
               MOVE 'USUARIO BLOQUEADO POR INTENTOS FALLIDOS'
                 TO WS-MENSAJE-ERROR
               MOVE 'N' TO WS-LOGIN-FALLIDO
               CLOSE USERPROF-FILE
               GOTO 4000-EXIT
           END-IF.
      *
           IF USR-PASSWORD NOT = WS-CONTRASENA
               ADD 1 TO USR-PASSWORD-TRIES
               REWRITE USERPROF-RECORD
               COMPUTE WS-INTENTOS-MAX = USR-LOGIN-ATTEMPT-MAX
               IF WS-INTENTOS-MAX = 0
                   MOVE 3 TO WS-INTENTOS-MAX
               END-IF
               COMPUTE WS-INTENTOS = USR-PASSWORD-TRIES
               STRING 'CONTRASENA INCORRECTA - INTENTO '
                      WS-INTENTOS ' DE ' WS-INTENTOS-MAX
                 INTO WS-MENSAJE-ERROR
               MOVE 'N' TO WS-LOGIN-FALLIDO
               CLOSE USERPROF-FILE
               GOTO 4000-EXIT
           END-IF.
      *
           MOVE 0 TO USR-PASSWORD-TRIES.
           MOVE WS-FECHA-HOY TO USR-DATE-LAST-LOGIN.
           MOVE WS-HORA-ACTUAL TO USR-TIME-LAST-LOGIN.
           MOVE USR-BRANCH TO WS-SUCURSAL.
           REWRITE USERPROF-RECORD.
      *
           IF WS-FILE-STATUS NOT = '00'
               MOVE 'ERROR AL ACTUALIZAR PERFIL' TO WS-MENSAJE-ERROR
               MOVE 'N' TO WS-LOGIN-FALLIDO
               CLOSE USERPROF-FILE
               GOTO 4000-EXIT
           END-IF.
      *
           CLOSE USERPROF-FILE.
           MOVE 'S' TO WS-LOGIN-OK.
           MOVE USR-NAME TO WS-NOMBRE-USUARIO.
      *
           IF USR-PASSWORD-EXP-DATE < WS-FECHA-HOY
               MOVE 'S' TO WS-PWD-EXPIRED
           ELSE
               MOVE 'N' TO WS-PWD-EXPIRED
               COMPUTE WS-DIAS-RESTANTES =
                   USR-PASSWORD-EXP-DATE - WS-FECHA-HOY
               IF WS-DIAS-RESTANTES < 15
                   STRING 'SU CONTRASENA EXPIRA EN '
                          WS-DIAS-RESTANTES ' DIAS'
                     INTO WS-MENSAJE
               ELSE
                   MOVE 'ACCESO AUTORIZADO - BIENVENIDO'
                     TO WS-MENSAJE
               END-IF
           END-IF.
      *
       4000-EXIT.
           EXIT.
      *
      *--- CAMBIO DE CONTRASENA OBLIGATORIO ---*
       5000-CAMBIO-PASSWORD.
           MOVE 'N' TO WS-CAMBIO-NO.
           MOVE SPACES TO WS-CONTRASENA-ANTERIOR
                          WS-CONTRASENA-NUEVA
                          WS-CONTRASENA-CONFIRMA
                          WS-MENSAJE-ERROR.
           MOVE WS-USUARIO TO LS-USUARIO.
      *
       5100-CAMBIO-LOOP.
           PERFORM 1100-LIMPIAR-PANTALLA.
           DISPLAY SCR-CAMBIO-PWD.
           ACCEPT SCR-CAMBIO-PWD.
      *
           IF WS-CRT-PF12
               MOVE 'N' TO WS-CAMBIO-NO
               MOVE 'N' TO WS-LOGIN-OK
               GOTO 5900-CAMBIO-EXIT
           END-IF.
      *
           IF WS-CONTRASENA-NUEVA = SPACES
               OR WS-CONTRASENA-NUEVA = LOW-VALUES
               MOVE 'LA NUEVA CONTRASENA NO PUEDE ESTAR VACIA'
                 TO WS-MENSAJE-ERROR
               GOTO 5100-CAMBIO-LOOP
           END-IF.
      *
           IF WS-CONTRASENA-NUEVA NOT = WS-CONTRASENA-CONFIRMA
               MOVE 'LAS CONTRASENAS NO COINCIDEN'
                 TO WS-MENSAJE-ERROR
               GOTO 5100-CAMBIO-LOOP
           END-IF.
      *
           IF WS-CONTRASENA-NUEVA = WS-CONTRASENA-ANTERIOR
               MOVE 'LA NUEVA CONTRASENA DEBE SER DIFERENTE'
                 TO WS-MENSAJE-ERROR
               GOTO 5100-CAMBIO-LOOP
           END-IF.
      *
           IF WS-CONTRASENA-NUEVA < 6
               MOVE 'CONTRASENA DEBE TENER AL MENOS 6 CARACTERES'
                 TO WS-MENSAJE-ERROR
               GOTO 5100-CAMBIO-LOOP
           END-IF.
      *
           PERFORM 5300-ACTUALIZAR-PASSWORD.
           IF WS-CAMBIO-SI
               MOVE 'S' TO WS-CAMBIO-NO
               MOVE 'CONTRASENA CAMBIADA EXITOSAMENTE'
                 TO WS-MENSAJE
           END-IF.
      *
       5900-CAMBIO-EXIT.
           EXIT.
      *
       5300-ACTUALIZAR-PASSWORD.
           OPEN I-O USERPROF-FILE.
           IF WS-FILE-STATUS NOT = '00'
               MOVE 'ERROR AL ACCEDER ARCHIVO' TO WS-MENSAJE-ERROR
               MOVE 'N' TO WS-CAMBIO-NO
               GOTO 5300-EXIT
           END-IF.
      *
           MOVE WS-USUARIO TO USR-ID.
           READ USERPROF-FILE KEY IS USR-ID
               INVALID KEY
                   MOVE 'ERROR LEYENDO PERFIL' TO WS-MENSAJE-ERROR
                   MOVE 'N' TO WS-CAMBIO-NO
                   CLOSE USERPROF-FILE
                   GOTO 5300-EXIT
           END-READ.
      *
           MOVE WS-CONTRASENA-NUEVA TO USR-PASSWORD.
           CALL 'COMDATE' USING 'ADD'
                                WS-FECHA-HOY
                                00090
           MOVE WS-FECHA-HOY TO USR-PASSWORD-EXP-DATE.
           MOVE WS-FECHA-HOY TO USR-PASSWORD-LAST-CHG.
           MOVE 'N' TO USR-PASSWORD-BLOCKED.
           MOVE 0 TO USR-PASSWORD-TRIES.
           REWRITE USERPROF-RECORD.
      *
           IF WS-FILE-STATUS = '00'
               MOVE 'S' TO WS-CAMBIO-SI
           ELSE
               MOVE 'N' TO WS-CAMBIO-SI
               MOVE 'ERROR AL GUARDAR NUEVA CONTRASENA'
                 TO WS-MENSAJE-ERROR
           END-IF.
      *
           CLOSE USERPROF-FILE.
       5300-EXIT.
           EXIT.
      *
      *--- SESION OK ---*
       6000-SESION-OK.
           PERFORM 1100-LIMPIAR-PANTALLA.
           STRING 'SESION INICIADA: ' WS-NOMBRE-USUARIO
             INTO WS-MENSAJE.
           DISPLAY SCR-SESION-INFO.
           ACCEPT SCR-SESION-INFO.
      *
      *--- LLAMAR AL MENU PRINCIPAL ---*
       7000-LLAMAR-MENU.
           MOVE WS-USUARIO TO LS-USUARIO.
           MOVE WS-SUCURSAL TO LS-SUCURSAL.
           MOVE 00 TO LS-RETCODE.
      *
      *--- BLOQUEAR USUARIO ---*
       8000-BLOQUEAR-USUARIO.
           OPEN I-O USERPROF-FILE.
           IF WS-FILE-STATUS = '00'
               MOVE WS-USUARIO TO USR-ID
               READ USERPROF-FILE KEY IS USR-ID
                   INVALID KEY
                       CLOSE USERPROF-FILE
                       GOTO 8000-EXIT
               END-READ
               MOVE 'Y' TO USR-PASSWORD-BLOCKED
               REWRITE USERPROF-RECORD
               CLOSE USERPROF-FILE
           END-IF.
       8000-EXIT.
           EXIT.
      *
      *--- FINALIZAR ---*
       9000-FINALIZAR.
           IF WS-USUARIO NOT = SPACES
               PERFORM 8000-BLOQUEAR-USUARIO
           END-IF.
           CLOSE USERPROF-FILE.
           STOP RUN.
      *
       END PROGRAM BNK0001.
