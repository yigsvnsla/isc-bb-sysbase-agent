      *================================================================*
      * COMMSGF - MANEJO DE MENSAJES DEL SISTEMA                      *
      * PROPOSITO: DESPLEGAR MENSAJES ESTANDAR EN PANTALLA           *
      * CREADO: 1998 - DEPARTAMENTO DE SOPORTE TECNICO               *
      * USO:   CALL 'COMMSGF' USING CODIGO TEXTO TIPO               *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMMSGF.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-CODIGO                     PIC X(04).
       01  WS-TEXTO                      PIC X(60).
       01  WS-TIPO                       PIC X(01).
           88  WS-TIPO-INFO              VALUE 'I'.
           88  WS-TIPO-WARNING           VALUE 'W'.
           88  WS-TIPO-ERROR             VALUE 'E'.
           88  WS-TIPO-CRITICAL          VALUE 'C'.
           88  WS-TIPO-CONFIRM           VALUE 'Q'.
       01  WS-CRT-STATUS                 PIC 9(04).
           88  WS-CRT-PF12              VALUE 1012.
       01  WS-CONFIRMA                   PIC X(01).
           88  WS-CONF-SI               VALUE 'S'.
           88  WS-CONF-NO               VALUE 'N'.
      *
      *--- TABLA DE MENSAJES DEL SISTEMA ---*
       01  WS-TABLA-MENSAJES.
           05  WS-MSG-ENTRY              OCCURS 50.
               10  WS-MSG-CODE           PIC X(04).
               10  WS-MSG-TEXT           PIC X(60).
               10  WS-MSG-TYPE           PIC X(01).
      *
       01  WS-MSG-DATOS.
           05  FILLER PIC X(04) VALUE 'E001'.
           05  FILLER PIC X(60)
               VALUE 'ERROR DE ARCHIVO - CONTACTE AL ADMINISTRADOR'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'E002'.
           05  FILLER PIC X(60)
               VALUE 'REGISTRO NO ENCONTRADO'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'E003'.
           05  FILLER PIC X(60)
               VALUE 'REGISTRO DUPLICADO - YA EXISTE'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'E004'.
           05  FILLER PIC X(60)
               VALUE 'SALDOS INSUFICIENTES PARA REALIZAR OPERACION'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'E005'.
           05  FILLER PIC X(60)
               VALUE 'CUENTA BLOQUEADA O CONGELADA'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'E006'.
           05  FILLER PIC X(60)
               VALUE 'USUARIO NO AUTORIZADO PARA ESTA FUNCION'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'E007'.
           05  FILLER PIC X(60)
               VALUE 'FECHA INVALIDA - VERIFIQUE EL FORMATO'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'E008'.
           05  FILLER PIC X(60)
               VALUE 'MONTO EXCEDE EL LIMITE PERMITIDO'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'E009'.
           05  FILLER PIC X(60)
               VALUE 'CLIENTE NO EXISTE EN EL PADRON'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'E010'.
           05  FILLER PIC X(60)
               VALUE 'CUENTA NO PERTENECE AL CLIENTE INDICADO'.
           05  FILLER PIC X(01) VALUE 'E'.
           05  FILLER PIC X(04) VALUE 'W001'.
           05  FILLER PIC X(60)
               VALUE 'ADVERTENCIA: OPERACION IRREVERSIBLE'.
           05  FILLER PIC X(01) VALUE 'W'.
           05  FILLER PIC X(04) VALUE 'W002'.
           05  FILLER PIC X(60)
               VALUE 'SESION A PUNTO DE EXPIRAR - CONFIRME OPERACION'.
           05  FILLER PIC X(01) VALUE 'W'.
           05  FILLER PIC X(04) VALUE 'W003'.
           05  FILLER PIC X(60)
               VALUE 'EL MONTO SUPERA EL PROMEDIO MENSUAL'.
           05  FILLER PIC X(01) VALUE 'W'.
           05  FILLER PIC X(04) VALUE 'I001'.
           05  FILLER PIC X(60)
               VALUE 'OPERACION REALIZADA EXITOSAMENTE'.
           05  FILLER PIC X(01) VALUE 'I'.
           05  FILLER PIC X(04) VALUE 'I002'.
           05  FILLER PIC X(60)
               VALUE 'DATOS GUARDADOS CORRECTAMENTE'.
           05  FILLER PIC X(01) VALUE 'I'.
           05  FILLER PIC X(04) VALUE 'I003'.
           05  FILLER PIC X(60)
               VALUE 'IMPRESION ENVIADA A LA COLA DE SPOOL'.
           05  FILLER PIC X(01) VALUE 'I'.
           05  FILLER PIC X(04) VALUE 'I004'.
           05  FILLER PIC X(60)
               VALUE 'PROCESO BATCH INICIADO - MONITOREE EN LOG'.
           05  FILLER PIC X(01) VALUE 'I'.
           05  FILLER PIC X(04) VALUE 'I005'.
           05  FILLER PIC X(60)
               VALUE 'CONTRASENA CAMBIADA EXITOSAMENTE'.
           05  FILLER PIC X(01) VALUE 'I'.
           05  FILLER PIC X(04) VALUE 'Q001'.
           05  FILLER PIC X(60)
               VALUE 'CONFIRMA LA OPERACION? (S=SI / N=NO)'.
           05  FILLER PIC X(01) VALUE 'Q'.
           05  FILLER PIC X(04) VALUE 'Q002'.
           05  FILLER PIC X(60)
               VALUE 'DESEA SALIR DEL MODULO? (S=SI / N=NO)'.
           05  FILLER PIC X(01) VALUE 'Q'.
           05  FILLER PIC X(04) VALUE 'Q003'.
           05  FILLER PIC X(60)
               VALUE 'DESEA IMPRIMIR EL COMPROBANTE? (S=SI/N=NO)'.
           05  FILLER PIC X(01) VALUE 'Q'.
      *
       01  WS-MSG-TABLA-REDEF
           REDEFINES WS-MSG-DATOS.
           05  WS-MSG-REG                 OCCURS 22.
               10  WS-MSG-REG-CODE        PIC X(04).
               10  WS-MSG-REG-TEXT        PIC X(60).
               10  WS-MSG-REG-TYPE        PIC X(01).
      *
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-PANTALLA-ERROR.
           05  SCR-ERR-CAJA.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 03  PIC X(04) FROM WS-CODIGO.
               10  LINE 23  COL 08  PIC X(60) FROM WS-TEXTO.
      *
       01  SCR-PANTALLA-CONFIRMA.
           05  SCR-CONF-CAJA.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 03  PIC X(04) FROM WS-CODIGO.
               10  LINE 23  COL 08  PIC X(60) FROM WS-TEXTO.
               10  LINE 24  COL 03  PIC X(01)
                   TO WS-CONFIRMA AUTO.
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-CODIGO                      PIC X(04).
       01  LS-TEXTO                       PIC X(60).
       01  LS-TIPO                        PIC X(01).
       01  LS-RESPUESTA                   PIC X(01).
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-CODIGO
                                 LS-TEXTO
                                 LS-TIPO
                                 LS-RESPUESTA.
      *
       MAIN.
           MOVE LS-CODIGO TO WS-CODIGO.
           PERFORM 1000-BUSCAR-MENSAJE.
      *
           IF LS-TIPO = 'I' OR 'W' OR 'E' OR 'C'
               DISPLAY SCR-PANTALLA-ERROR
           ELSE
               IF LS-TIPO = 'Q'
                   DISPLAY SCR-PANTALLA-CONFIRMA
                   ACCEPT SCR-PANTALLA-CONFIRMA
                   MOVE WS-CONFIRMA TO LS-RESPUESTA
               END-IF
           END-IF.
      *
           GOBACK.
      *
       1000-BUSCAR-MENSAJE.
           MOVE 1 TO WS-CODIGO.
           PERFORM VARYING WS-CODIGO FROM 1 BY 1
               UNTIL WS-CODIGO > 22
               IF WS-MSG-REG-CODE(WS-CODIGO) = LS-CODIGO
                   MOVE WS-MSG-REG-TEXT(WS-CODIGO)
                     TO WS-TEXTO
                   MOVE WS-MSG-REG-TYPE(WS-CODIGO)
                     TO WS-TIPO
               END-IF
           END-PERFORM.
      *
           IF LS-TEXTO NOT = SPACES
               MOVE LS-TEXTO TO WS-TEXTO
           END-IF.
      *
       END PROGRAM COMMSGF.
