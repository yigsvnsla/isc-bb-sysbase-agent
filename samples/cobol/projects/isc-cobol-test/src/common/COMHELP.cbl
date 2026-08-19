      *================================================================*
      * COMHELP - PANTALLA DE AYUDA CONTEXTUAL                        *
      * PROPOSITO: DESPLEGAR AYUDA POR TEMA / PROGRAMA                *
      * EQUIPO: DOCUMENTACION - 2000                                  *
      * USO:   CALL 'COMHELP' USING WS-HELP-TOPIC                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMHELP.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-HELP-TOPIC                 PIC X(08).
       01  WS-HELP-TEXT                  PIC X(70).
       01  WS-HELP-TITLE                 PIC X(30).
       01  WS-CRT-STATUS                 PIC 9(04).
           88  WS-CRT-PF12              VALUE 1012.
           88  WS-CRT-PF11              VALUE 1011.
       01  WS-HELP-INDEX                 PIC 9(02).
       01  WS-HELP-LINE-COUNT           PIC 9(02).
       01  WS-HELP-LINE-ACTUAL          PIC 9(02).
      *
      *--- TABLA DE AYUDA ---*
       01  WS-HELP-TABLE.
           05  WS-HELP-ENTRY             OCCURS 50.
               10  WS-HELP-CODE          PIC X(08).
               10  WS-HELP-TIT           PIC X(30).
               10  WS-HELP-TXT           OCCURS 12.
                   15  WS-HELP-LINE      PIC X(70).
      *
       01  WS-FILLER.
           05  WS-HELP-DATA.
               10  FILLER PIC X(08) VALUE 'GENERAL'.
               10  FILLER PIC X(30) VALUE 'AYUDA GENERAL DEL SISTEMA'.
               10  FILLER PIC X(70)
                   VALUE 'SISTEMA INTEGRAL BANCARIO - COBOL'.
               10  FILLER PIC X(70)
                   VALUE 'USE PF1-PF10 PARA NAVEGAR A LOS MODULOS.'.
               10  FILLER PIC X(70)
                   VALUE 'PF11 AYUDA CONTEXTUAL. PF12 RETORNAR.'.
               10  FILLER PIC X(70)
                   VALUE ' '.
               10  FILLER PIC X(70)
                   VALUE 'PARA INGRESAR, USE SU USUARIO Y CONTRASENA.'.
               10  FILLER PIC X(70)
                   VALUE 'SI OLVIDO SU CONTRASENA, CONTACTE A SU'.
               10  FILLER PIC X(70)
                   VALUE 'ADMINISTRADOR DE SEGURIDAD.'.
               10  FILLER PIC X(70)
                   VALUE ' '.
               10  FILLER PIC X(70)
                   VALUE 'VERSION 5.2 - MICRO FOCUS COBOL'.
               10  FILLER PIC X(70)
                   VALUE '(C) 1995-2008 BANCO NACIONAL'.
               10  FILLER PIC X(70)
                   VALUE ' '.
      *
               10  FILLER PIC X(08) VALUE 'CLIENTES'.
               10  FILLER PIC X(30)
                   VALUE 'MODULO DE CLIENTES'.
               10  FILLER PIC X(70)
                   VALUE 'ALTAS, BAJAS, MODIFICACIONES Y CONSULTAS'.
               10  FILLER PIC X(70)
                   VALUE 'DE CLIENTES PERSONA FISICA Y MORAL.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE 'LOS CAMPOS CON * SON OBLIGATORIOS.'.
               10  FILLER PIC X(70)
                   VALUE 'EL RFC DEBE SER VALIDO PARA PERSONAS'.
               10  FILLER PIC X(70)
                   VALUE 'FISICAS (13 POSICIONES) Y MORALES'.
               10  FILLER PIC X(70)
                   VALUE '(12 POSICIONES).'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE 'USE PF1 PARA BUSCAR, PF3 PARA ALTA.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
      *
               10  FILLER PIC X(08) VALUE 'CUENTAS'.
               10  FILLER PIC X(30)
                   VALUE 'MODULO DE CUENTAS'.
               10  FILLER PIC X(70)
                   VALUE 'APERTURA, CIERRE Y MODIFICACION DE CUENTAS'.
               10  FILLER PIC X(70)
                   VALUE 'DE CHEQUES, AHORRO, NOMINA E INVERSION.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE 'EL SALDO MINIMO DE APERTURA ES DEFINIDO'.
               10  FILLER PIC X(70)
                   VALUE 'POR TIPO DE PRODUCTO.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE 'PARA APERTURAR UNA CUENTA, EL CLIENTE'.
               10  FILLER PIC X(70)
                   VALUE 'DEBE EXISTIR EN EL MODULO DE CLIENTES.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
      *
               10  FILLER PIC X(08) VALUE 'VENTANIL'.
               10  FILLER PIC X(30)
                   VALUE 'MODULO DE VENTANILLA'.
               10  FILLER PIC X(70)
                   VALUE 'TRANSACCIONES DE CAJA: DEPOSITOS, RETIROS,'.
               10  FILLER PIC X(70)
                   VALUE 'TRANSFERENCIAS, PAGOS Y COBRO DE CHEQUES.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE 'EL CAJERO DEBE INICIAR CAJA CON PF1 ANTES'.
               10  FILLER PIC X(70)
                   VALUE 'DE REALIZAR OPERACIONES.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE 'AL FINAL DEL DIA, CIERRE CAJA CON PF7.'.
               10  FILLER PIC X(70)
                   VALUE 'LA DIFERENCIA MAXIMA PERMITIDA ES DE'.
               10  FILLER PIC X(70)
                   VALUE '$50.00 M.N.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
      *
               10  FILLER PIC X(08) VALUE 'PRESTAM'.
               10  FILLER PIC X(30)
                   VALUE 'MODULO DE PRESTAMOS'.
               10  FILLER PIC X(70)
                   VALUE 'SOLICITUD, APROBACION, DESEMBOLSO Y PAGO'.
               10  FILLER PIC X(70)
                   VALUE 'DE PRESTAMOS PERSONALES, HIPOTECARIOS,'.
               10  FILLER PIC X(70)
                   VALUE 'AUTOMOTRICES Y COMERCIALES.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE 'TODA SOLICITUD REQUIERE APROBACION DE AL'.
               10  FILLER PIC X(70)
                   VALUE 'MENOS UN OFICIAL DE CREDITO.'.
               10  FILLER PIC X(70)
                   VALUE 'MONTOS > 250,000 REQUIEREN DOBLE FIRMA.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
      *
               10  FILLER PIC X(08) VALUE 'SEGURID'.
               10  FILLER PIC X(30)
                   VALUE 'MODULO DE SEGURIDAD'.
               10  FILLER PIC X(70)
                   VALUE 'ADMINISTRACION DE USUARIOS, ROLES Y PERFILES'.
               10  FILLER PIC X(70)
                   VALUE 'DE ACCESO AL SISTEMA.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE 'SOLO USUARIOS CON PERFIL ADMINISTRADOR'.
               10  FILLER PIC X(70)
                   VALUE 'PUEDEN ACCEDER A ESTE MODULO.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE 'LAS CONTRASENAS EXPIRAN CADA 90 DIAS.'.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
               10  FILLER PIC X(70)
                   VALUE '  '.
      *
       01  WS-HELP-TABLA-REDEF
           REDEFINES WS-HELP-DATA.
           05  WS-HELP-REG                OCCURS 5.
               10  WS-HELP-TCOD            PIC X(08).
               10  WS-HELP-TTIT            PIC X(30).
               10  WS-HELP-TLINE           OCCURS 12.
                   15  WS-HELP-TTEXT       PIC X(70).
      *
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-HELP.
           05  SCR-HELP-CAB.
               10  LINE 01 COL 01 PIC X(80)
                   VALUE ' BANCO NACIONAL - AYUDA DEL SISTEMA'.
               10  LINE 01 COL 65 PIC X(15) VALUE 'PF12=RETORNAR'.
           05  SCR-HELP-TIT.
               10  LINE 03 COL 05 PIC X(30) FROM WS-HELP-TITLE.
           05  SCR-HELP-LINEAS.
               10  LINE 05 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 06 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 07 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 08 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 09 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 10 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 11 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 12 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 13 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 14 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 15 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
               10  LINE 16 COL 03 PIC X(70) FROM WS-HELP-LINE-ACTUAL.
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-HELP-CODE                   PIC X(08).
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-HELP-CODE.
      *
       MAIN.
           MOVE LS-HELP-CODE TO WS-HELP-TOPIC.
           PERFORM 1000-BUSCAR-TEMA.
      *
           IF WS-HELP-TOPIC = SPACES
               MOVE 'AYUDA NO DISPONIBLE PARA ESTE TEMA'
                 TO WS-HELP-TITLE
               MOVE SPACES TO WS-HELP-LINE
               MOVE 1 TO WS-HELP-LINE-COUNT
               PERFORM VARYING WS-HELP-INDEX FROM 1 BY 1
                   UNTIL WS-HELP-INDEX > 12
                   MOVE WS-HELP-LINE TO WS-HELP-LINE-ACTUAL
               END-PERFORM
           END-IF.
      *
           DISPLAY SCR-HELP.
           ACCEPT SCR-HELP.
      *
           IF WS-CRT-PF11
               PERFORM 2000-INDICE-AYUDA
           END-IF.
      *
           GOBACK.
      *
      *--- BUSCAR TEMA ---*
       1000-BUSCAR-TEMA.
           MOVE 1 TO WS-HELP-INDEX.
           PERFORM VARYING WS-HELP-INDEX FROM 1 BY 1
               UNTIL WS-HELP-INDEX > 5
               IF WS-HELP-TCOD(WS-HELP-INDEX) = WS-HELP-TOPIC
                   MOVE WS-HELP-TTIT(WS-HELP-INDEX)
                     TO WS-HELP-TITLE
                   PERFORM VARYING WS-HELP-LINE-COUNT FROM 1 BY 1
                       UNTIL WS-HELP-LINE-COUNT > 12
                       MOVE WS-HELP-TTEXT(WS-HELP-INDEX,
                           WS-HELP-LINE-COUNT)
                         TO WS-HELP-LINE-ACTUAL
                   END-PERFORM
                   MOVE SPACES TO WS-HELP-TOPIC
               END-IF
           END-PERFORM.
      *
       2000-INDICE-AYUDA.
           MOVE 'INDICE DE AYUDA' TO WS-HELP-TITLE.
           MOVE 'TEMA: CLIENTES - CODIGO: CLIENTES' TO
               WS-HELP-LINE-ACTUAL.
      *
       END PROGRAM COMHELP.
