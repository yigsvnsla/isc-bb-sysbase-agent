       *================================================================*
       * BCHMNU00 - MENU DE PROCESOS BATCH                            *
       * PROPOSITO: ACCESO A CIERRE DIARIO, MENSUAL, INTERESES,       *
       *            COMISIONES, GL Y SOBREGIROS                       *
       * EQUIPO: OPERACIONES - 1998                                   *
       * ARCHIVOS: BATCHCTL (SOLO LECTURA)                            *
       * CALL: BCHDAY00, BCHMTH00, BCHINT00, BCHGLI00, BCHODO00,     *
       *       BCHFEE00                                               *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCHMNU00.
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
           SELECT BATCHCTL-FILE
               ASSIGN TO 'BATCHCTL.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS BCH-FECHA-PROCESO
               FILE STATUS IS FL-BATCHCTL-STATUS.
      *================================================================*
       DATA DIVISION.
       FILE SECTION.
       FD  BATCHCTL-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 150 CHARACTERS.
       01  BATCHCTL-RECORD.
           05  BCH-FECHA-PROCESO           PIC 9(08).
           05  BCH-FECHA-CONTABLE          PIC 9(08).
           05  BCH-FECHA-PROXIMA           PIC 9(08).
           05  BCH-DIA-HABIL               PIC X(01).
           05  BCH-ESTADO-GENERAL          PIC X(01).
           05  BCH-STATUS-DETALLE.
               10  BCH-ST-INTERES          PIC X(01).
               10  BCH-ST-SOBREGIRO        PIC X(01).
               10  BCH-ST-COMISIONES       PIC X(01).
               10  BCH-ST-GL               PIC X(01).
               10  BCH-ST-REPORTES         PIC X(01).
               10  BCH-ST-CIERRE           PIC X(01).
           05  BCH-HORA-INICIO             PIC 9(06).
           05  BCH-HORA-FIN                PIC 9(06).
           05  BCH-TRX-PROCESADAS          PIC 9(10).
           05  BCH-TRX-ERROR               PIC 9(06).
           05  BCH-USUARIO-EJECUTA         PIC X(08).
           05  BCH-OBSERVACIONES           PIC X(40).
           05  BCH-FILLER                  PIC X(10).
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF1                VALUE 1001.
           88  WS-CRT-PF2                VALUE 1002.
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF4                VALUE 1004.
           88  WS-CRT-PF5                VALUE 1005.
           88  WS-CRT-PF6                VALUE 1006.
           88  WS-CRT-PF7                VALUE 1007.
           88  WS-CRT-PF8                VALUE 1008.
           88  WS-CRT-PF9                VALUE 1009.
           88  WS-CRT-PF10               VALUE 1010.
           88  WS-CRT-PF11               VALUE 1011.
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
           05  WS-SUCURSAL                PIC X(04).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-PROGRAMA                PIC X(08) VALUE 'BCHMNU00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V3.1'.
           05  WS-DUMMY                   PIC X(01).
           05  WS-BATCH-FECHA             PIC 9(08).
           05  WS-BATCH-ESTADO            PIC X(01).
           05  WS-BATCH-TRX               PIC 9(10).
           05  WS-BATCH-TRX-D             PIC Z(9)9.
           05  WS-BATCH-HORA-I            PIC 9(06).
           05  WS-BATCH-HORA-F            PIC 9(06).
           05  WS-BATCH-USUARIO           PIC X(08).
           05  WS-BATCH-OBS               PIC X(40).
           05  WS-BATCH-CONTABLE          PIC 9(08).
           05  WS-BATCH-PROXIMA           PIC 9(08).
           05  WS-CONTADOR                PIC 9(02).
           05  WS-I                       PIC 9(02).
           05  WS-PROGRAMA-LLAMAR         PIC X(08).
      *
       01  WS-LAST-BATCH-INFO.
           05  WS-LAST-FECHA              PIC 9(08).
           05  WS-LAST-FECHA-D            PIC 99/99/9999.
           05  WS-LAST-ESTADO             PIC X(01).
           05  WS-LAST-TRX                PIC 9(10).
           05  WS-LAST-TRX-D              PIC Z(9)9.
           05  WS-LAST-USUARIO            PIC X(08).
           05  WS-LAST-HORA-I             PIC 9(06).
           05  WS-LAST-HORA-F             PIC 9(06).
           05  WS-LAST-OBS                PIC X(40).
      *
       01  WS-ESTADO-DESC                 PIC X(20).
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-MENU.
           05  SCR-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' MENU DE PROCESOS BATCH'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
      *
           05  SCR-CUERPO.
               10  LINE 04  COL 05  PIC X(30)
                   VALUE 'PROCESOS DEL SISTEMA BATCH'.
               10  LINE 05  COL 05  PIC X(70) VALUE ALL '-'.
               10  LINE 06  COL 05  PIC X(40)
                   VALUE 'PF1  - CIERRE DIARIO'.
               10  LINE 07  COL 05  PIC X(40)
                   VALUE 'PF2  - CIERRE MENSUAL'.
               10  LINE 08  COL 05  PIC X(40)
                   VALUE 'PF3  - CALCULO DE INTERESES'.
               10  LINE 09  COL 05  PIC X(40)
                   VALUE 'PF4  - PASE CONTABLE (GL)'.
               10  LINE 10  COL 05  PIC X(40)
                   VALUE 'PF5  - SOBREGIRO / MORA'.
               10  LINE 11  COL 05  PIC X(40)
                   VALUE 'PF6  - COMISIONES PERIODICAS'.
      *
           05  SCR-LAST-BATCH.
               10  LINE 13  COL 05  PIC X(70) VALUE ALL '-'.
               10  LINE 14  COL 05  PIC X(30) VALUE 'ULTIMO PROCESO BATCH:'.
               10  LINE 15  COL 05  PIC X(20) VALUE 'FECHA:'.
               10  LINE 15  COL 15  PIC 99/99/9999 FROM WS-LAST-FECHA-D.
               10  LINE 16  COL 05  PIC X(20) VALUE 'ESTADO:'.
               10  LINE 16  COL 15  PIC X(20) FROM WS-ESTADO-DESC.
               10  LINE 17  COL 05  PIC X(20) VALUE 'TRX OK:'.
               10  LINE 17  COL 15  PIC Z(9)9 FROM WS-LAST-TRX.
               10  LINE 18  COL 05  PIC X(20) VALUE 'USUARIO:'.
               10  LINE 18  COL 15  PIC X(08) FROM WS-LAST-USUARIO.
               10  LINE 19  COL 05  PIC X(20) VALUE 'HORA INICIO:'.
               10  LINE 19  COL 20  PIC 9(06) FROM WS-LAST-HORA-I.
               10  LINE 20  COL 05  PIC X(20) VALUE 'HORA FIN:'.
               10  LINE 20  COL 20  PIC 9(06) FROM WS-LAST-HORA-F.
      *
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF1=DIARIO PF2=MENSUAL PF3=INT PF4=GL '.
               10  LINE 24  COL 40  PIC X(40)
                   VALUE 'PF5=SOBREGIRO PF6=COMISION PF12=RET'.
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
                          WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE SPACES TO WS-SUCURSAL.
           MOVE 0 TO WS-RETCODE.
      *
           PERFORM 1000-INICIALIZAR.
           PERFORM 1200-LEER-ULTIMO-BATCH.
      *
       MENU-LOOP.
           PERFORM 2000-MOSTRAR-MENU.
           ACCEPT SCR-MENU.
      *
           EVALUATE TRUE
               WHEN WS-CRT-PF1
                   MOVE 'BCHDAY00' TO WS-PROGRAMA-LLAMAR
                   PERFORM 3000-EJECUTAR-PROGRAMA
      *
               WHEN WS-CRT-PF2
                   MOVE 'BCHMTH00' TO WS-PROGRAMA-LLAMAR
                   PERFORM 3000-EJECUTAR-PROGRAMA
      *
               WHEN WS-CRT-PF3
                   MOVE 'BCHINT00' TO WS-PROGRAMA-LLAMAR
                   PERFORM 3000-EJECUTAR-PROGRAMA
      *
               WHEN WS-CRT-PF4
                   MOVE 'BCHGLI00' TO WS-PROGRAMA-LLAMAR
                   PERFORM 3000-EJECUTAR-PROGRAMA
      *
               WHEN WS-CRT-PF5
                   MOVE 'BCHODO00' TO WS-PROGRAMA-LLAMAR
                   PERFORM 3000-EJECUTAR-PROGRAMA
      *
               WHEN WS-CRT-PF6
                   MOVE 'BCHFEE00' TO WS-PROGRAMA-LLAMAR
                   PERFORM 3000-EJECUTAR-PROGRAMA
      *
               WHEN WS-CRT-PF12
                   PERFORM 9000-FINALIZAR
      *
               WHEN WS-CRT-CLEAR
                   MOVE SPACES TO WS-MENSAJE
                                  WS-MENSAJE-ERROR
                   GO TO MENU-LOOP
      *
               WHEN OTHER
                   MOVE 'USE PF1-PF6 PARA PROCESOS, PF12=SALIR'
                     TO WS-MENSAJE-ERROR
                   GO TO MENU-LOOP
           END-EVALUATE.
      *
           GO TO MENU-LOOP.
      *
      *--- INICIALIZAR FECHA ---*
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 'SELECCIONE PROCESO BATCH CON PF-KEY'
             TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
      *--- LEER ULTIMO REGISTRO DE BATCHCTL ---*
       1200-LEER-ULTIMO-BATCH.
           MOVE SPACES TO WS-LAST-FECHA
                          WS-LAST-ESTADO
                          WS-LAST-USUARIO
                          WS-LAST-OBS.
           MOVE 0 TO WS-LAST-TRX.
           MOVE 0 TO WS-LAST-HORA-I
           MOVE 0 TO WS-LAST-HORA-F.
           MOVE 'SIN PROCESO BATCH PREVIO' TO WS-ESTADO-DESC.
      *
           OPEN INPUT BATCHCTL-FILE.
           IF FL-BATCHCTL-STATUS = '00'
               MOVE 99999999 TO BCH-FECHA-PROCESO
               START BATCHCTL-FILE KEY IS LESS THAN
                     BCH-FECHA-PROCESO
                   INVALID KEY
                       CLOSE BATCHCTL-FILE
                       GOTO 1200-EXIT
               END-START
               READ BATCHCTL-FILE NEXT RECORD
                   AT END
                       CLOSE BATCHCTL-FILE
                       GOTO 1200-EXIT
               END-READ
               IF FL-BATCHCTL-STATUS = '00'
                   MOVE BCH-FECHA-PROCESO TO WS-LAST-FECHA
                   MOVE BCH-FECHA-PROCESO TO WS-LAST-FECHA-D
                   MOVE BCH-ESTADO-GENERAL TO WS-LAST-ESTADO
                   MOVE BCH-TRX-PROCESADAS TO WS-LAST-TRX
                   MOVE BCH-USUARIO-EJECUTA TO WS-LAST-USUARIO
                   MOVE BCH-HORA-INICIO TO WS-LAST-HORA-I
                   MOVE BCH-HORA-FIN TO WS-LAST-HORA-F
                   MOVE BCH-OBSERVACIONES TO WS-LAST-OBS
                   EVALUATE BCH-ESTADO-GENERAL
                       WHEN 'P'
                           MOVE 'PENDIENTE' TO WS-ESTADO-DESC
                       WHEN 'E'
                           MOVE 'EN EJECUCION' TO WS-ESTADO-DESC
                       WHEN 'C'
                           MOVE 'COMPLETADO' TO WS-ESTADO-DESC
                       WHEN 'R'
                           MOVE 'ERROR' TO WS-ESTADO-DESC
                       WHEN 'X'
                           MOVE 'CANCELADO' TO WS-ESTADO-DESC
                       WHEN OTHER
                           MOVE 'DESCONOCIDO' TO WS-ESTADO-DESC
                   END-EVALUATE
               END-IF
               CLOSE BATCHCTL-FILE
           END-IF.
      *
       1200-EXIT.
           EXIT.
      *
      *--- MOSTRAR MENU ---*
       2000-MOSTRAR-MENU.
           PERFORM 1100-LIMPIAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           DISPLAY SCR-MENU.
      *
      *--- EJECUTAR PROGRAMA SELECCIONADO ---*
       3000-EJECUTAR-PROGRAMA.
           MOVE SPACES TO WS-MENSAJE-ERROR.
           STRING 'EJECUTANDO ' WS-PROGRAMA-LLAMAR '...'
             INTO WS-MENSAJE.
           DISPLAY SCR-MENU.
      *
           CALL WS-PROGRAMA-LLAMAR USING WS-USUARIO
                                          WS-RETCODE.
      *
           IF WS-RETCODE NOT = 00
               STRING 'ERROR EN ' WS-PROGRAMA-LLAMAR
                      ' - CODIGO ' WS-RETCODE
                 INTO WS-MENSAJE-ERROR
           ELSE
               STRING WS-PROGRAMA-LLAMAR
                      ' FINALIZADO CORRECTAMENTE'
                 INTO WS-MENSAJE
           END-IF.
      *
           PERFORM 1200-LEER-ULTIMO-BATCH.
      *
      *--- FINALIZAR ---*
       9000-FINALIZAR.
           PERFORM 1100-LIMPIAR.
           MOVE 0 TO LS-RETCODE.
           GOBACK.
      *
       END PROGRAM BCHMNU00.
