       *================================================================*
       * BCHDAY00 - CIERRE DIARIO (ORQUESTADOR BATCH)                  *
       * PROPOSITO: COORDINAR LOS PROCESOS DE CIERRE DIARIO:          *
       *            INTERESES, SOBREGIRO, COMISIONES, GL              *
       * EQUIPO: OPERACIONES - 1997                                  *
       * ARCHIVOS: BATCHCTL (CONTROL DE CIERRE), AUDITLOG            *
       * CALL: BCHINT00, BCHODO00, BCHFEE00, BCHGLI00,              *
       *       COMDATE, AUDTRL00                                    *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCHDAY00.
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
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
           88  WS-CRT-CLEAR              VALUE 0000.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-SUCURSAL                PIC X(04).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'BCHDAY00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V3.2'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-CONFIRMA                PIC X(01).
           05  WS-TRX-TOTAL               PIC 9(10) VALUE 0.
           05  WS-TRX-ERROR               PIC 9(06) VALUE 0.
           05  WS-HORA-INICIO             PIC 9(06).
           05  WS-HORA-FIN                PIC 9(06).
           05  WS-RETCODE-INT             PIC 99.
           05  WS-RETCODE-ODO             PIC 99.
           05  WS-RETCODE-FEE             PIC 99.
           05  WS-RETCODE-GLI             PIC 99.
           05  WS-PROCESO-ACTUAL          PIC X(20).
           05  WS-PROCESO-COMPLETADO      PIC X(01).
           05  WS-FECHA-PROXIMA           PIC 9(08).
           05  WS-FECHA-CONTABLE          PIC 9(08).
           05  WS-TRX-DISP                PIC Z(9)9.
           05  WS-ERR-DISP                PIC Z(5)9.
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-CONFIRMA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - CIERRE DIARIO'.
           05  LINE 02  COL 01  PIC X(80)
               VALUE ' VERIFICACION PREVIA AL CIERRE'.
           05  LINE 04  COL 05  PIC X(40)
               VALUE 'FECHA DE PROCESO:'.
           05  LINE 04  COL 30  PIC 99/99/9999 FROM WS-FECHA-DDMM.
           05  LINE 06  COL 05  PIC X(60)
               VALUE 'PROCESOS A EJECUTAR:'.
           05  LINE 07  COL 10  PIC X(40) VALUE '1. CALCULO DE INTERESES'.
           05  LINE 08  COL 10  PIC X(40)
               VALUE '2. COMISION POR SOBREGIRO'.
           05  LINE 09  COL 10  PIC X(40) VALUE '3. COMISIONES PERIODICAS'.
           05  LINE 10  COL 10  PIC X(40) VALUE '4. PASE CONTABLE GL'.
           05  LINE 12  COL 05  PIC X(60)
               VALUE 'NOTA: ESTE PROCESO NO PUEDE INTERRUMPIRSE'.
           05  LINE 14  COL 05  PIC X(40)
               VALUE 'CONFIRMAR CIERRE DIARIO? (S/N):'.
           05  LINE 14  COL 40  PIC X(01) USING WS-CONFIRMA.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
      *
       01  SCR-PROGRESO.
           05  SCR-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - CIERRE DIARIO'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' EJECUTANDO PROCESOS DE CIERRE DIARIO'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
      *
           05  SCR-PROCESO.
               10  LINE 05  COL 05  PIC X(30) VALUE 'PROCESO ACTUAL:'.
               10  LINE 05  COL 25  PIC X(20) FROM WS-PROCESO-ACTUAL.
      *
           05  SCR-RESUMEN.
               10  LINE 08  COL 05  PIC X(30)
                   VALUE 'TRANSACCIONES PROCESADAS:'.
               10  LINE 08  COL 35  PIC Z(9)9 FROM WS-TRX-DISP.
               10  LINE 09  COL 05  PIC X(30) VALUE 'ERRORES:'.
               10  LINE 09  COL 35  PIC Z(5)9 FROM WS-ERR-DISP.
      *
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
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
           MOVE 0 TO WS-RETCODE.
      *
           PERFORM 1000-INICIALIZAR.
           PERFORM 1500-MOSTRAR-CONFIRMA.
      *
           IF WS-CONFIRMA NOT = 'S'
               MOVE 'CIERRE DIARIO CANCELADO' TO WS-MENSAJE
               PERFORM 9000-FINALIZAR
               GOBACK
           END-IF.
      *
           PERFORM 2000-REGISTRAR-INICIO.
           PERFORM 3000-EJECUTAR-INTERESES.
           PERFORM 4000-EJECUTAR-SOBREGIROS.
           PERFORM 5000-EJECUTAR-COMISIONES.
           PERFORM 6000-EJECUTAR-GL.
           PERFORM 7000-CALCULAR-FECHA-PROXIMA.
           PERFORM 8000-REGISTRAR-FIN.
      *
           PERFORM 8500-MOSTRAR-RESUMEN.
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 'N' TO WS-CONFIRMA.
           MOVE 0 TO WS-TRX-TOTAL
                      WS-TRX-ERROR.
           MOVE 'PREPARANDO CIERRE DIARIO...' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       1500-MOSTRAR-CONFIRMA.
           DISPLAY SCR-CONFIRMA.
           ACCEPT SCR-CONFIRMA.
      *
       2000-REGISTRAR-INICIO.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE WS-HORA TO WS-HORA-INICIO.
           MOVE 'INICIANDO CIERRE DIARIO...' TO WS-MENSAJE.
           MOVE SPACES TO WS-MENSAJE-ERROR.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-PROGRESO.
      *
      *--- EJECUTAR CALCULO DE INTERESES ---*
       3000-EJECUTAR-INTERESES.
           MOVE 'CALCULO DE INTERESES' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           CALL 'BCHINT00' USING WS-USUARIO
                                  WS-RETCODE-INT.
           IF WS-RETCODE-INT NOT = 00
               ADD 1 TO WS-TRX-ERROR
           END-IF.
      *
      *--- EJECUTAR SOBREGIRO/MORA ---*
       4000-EJECUTAR-SOBREGIROS.
           MOVE 'COMISION SOBREGIRO' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           CALL 'BCHODO00' USING WS-USUARIO
                                  WS-RETCODE-ODO.
           IF WS-RETCODE-ODO NOT = 00
               ADD 1 TO WS-TRX-ERROR
           END-IF.
      *
      *--- EJECUTAR COMISIONES PERIODICAS ---*
       5000-EJECUTAR-COMISIONES.
           MOVE 'COMISIONES PERIODICAS' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           CALL 'BCHFEE00' USING WS-USUARIO
                                  WS-RETCODE-FEE.
           IF WS-RETCODE-FEE NOT = 00
               ADD 1 TO WS-TRX-ERROR
           END-IF.
      *
      *--- EJECUTAR PASE CONTABLE ---*
       6000-EJECUTAR-GL.
           MOVE 'PASE CONTABLE GL' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           CALL 'BCHGLI00' USING WS-USUARIO
                                  WS-RETCODE-GLI.
           IF WS-RETCODE-GLI NOT = 00
               ADD 1 TO WS-TRX-ERROR
           END-IF.
      *
       7000-CALCULAR-FECHA-PROXIMA.
           CALL 'COMDATE' USING 'ADD'
                                WS-FECHA
                                00001.
           MOVE WS-FECHA TO WS-FECHA-PROXIMA.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
      *
      *--- REGISTRAR CIERRE EN BATCHCTL ---*
       8000-REGISTRAR-FIN.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-HORA TO WS-HORA-FIN.
           MOVE 'COMPLETANDO CIERRE DIARIO...' TO WS-MENSAJE.
           DISPLAY SCR-PROGRESO.
      *
           OPEN I-O BATCHCTL-FILE.
           IF FL-BATCHCTL-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR BATCHCTL' TO WS-MENSAJE-ERROR
               GOTO 8000-EXIT
           END-IF.
      *
           MOVE WS-FECHA TO BCH-FECHA-PROCESO.
           MOVE WS-FECHA TO BCH-FECHA-CONTABLE.
           MOVE WS-FECHA-PROXIMA TO BCH-FECHA-PROXIMA.
           MOVE 'S' TO BCH-DIA-HABIL.
           MOVE 'C' TO BCH-ESTADO-GENERAL.
           MOVE 'C' TO BCH-ST-INTERES.
           MOVE 'C' TO BCH-ST-SOBREGIRO.
           MOVE 'C' TO BCH-ST-COMISIONES.
           MOVE 'C' TO BCH-ST-GL.
           MOVE 'C' TO BCH-ST-REPORTES.
           MOVE 'C' TO BCH-ST-CIERRE.
           MOVE WS-HORA-INICIO TO BCH-HORA-INICIO.
           MOVE WS-HORA-FIN TO BCH-HORA-FIN.
           MOVE WS-TRX-TOTAL TO BCH-TRX-PROCESADAS.
           MOVE WS-TRX-ERROR TO BCH-TRX-ERROR.
           MOVE WS-USUARIO TO BCH-USUARIO-EJECUTA.
           MOVE 'CIERRE DIARIO OK' TO BCH-OBSERVACIONES.
      *
           WRITE BATCHCTL-RECORD.
           IF FL-BATCHCTL-STATUS = '22'
               REWRITE BATCHCTL-RECORD
           END-IF.
      *
           CLOSE BATCHCTL-FILE.
       8000-EXIT.
           EXIT.
      *
      *--- MOSTRAR RESUMEN FINAL ---*
       8500-MOSTRAR-RESUMEN.
           MOVE WS-TRX-TOTAL TO WS-TRX-DISP.
           MOVE WS-TRX-ERROR TO WS-ERR-DISP.
           MOVE 'PROCESO COMPLETADO' TO WS-MENSAJE.
           DISPLAY SCR-PROGRESO.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
      *
      *--- REGISTRAR AUDITORIA ---*
           CALL 'AUDTRL00' USING WS-PROGRAMA
                                 'CIERRE DIARIO COMPLETADO'.
      *
       9000-FINALIZAR.
           CLOSE BATCHCTL-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM BCHDAY00.
