       *================================================================*
       * BCHGLI00 - PASE CONTABLE (INTERFAZ GL)                        *
       * PROPOSITO: LEER TRANLOG, AGRUPAR POR TIPO Y CREAR ASIENTOS   *
       *            CONTABLES EN GLMASTER                             *
       * EQUIPO: CONTABILIDAD - 1997                                 *
       * ARCHIVOS: TRANLOG (LECTURA), GLMASTER (ACTUALIZACION),      *
       *           BATCHCTL (ACTUALIZACION)                          *
       * CALL: COMDATE                                                *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCHGLI00.
      *================================================================*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
      *================================================================*
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRANLOG-FILE
               ASSIGN TO 'TRANLOG.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS TRN-SEQ
               FILE STATUS IS FL-TRANLOG-STATUS.
      *
           SELECT GLMASTER-FILE
               ASSIGN TO 'GLMASTER.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS GL-ACCOUNT
               FILE STATUS IS FL-GLMASTER-STATUS.
      *
           SELECT BATCHCTL-FILE
               ASSIGN TO 'BATCHCTL.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS BCH-FECHA-PROCESO
               FILE STATUS IS FL-BATCHCTL-STATUS.
      *================================================================*
       DATA DIVISION.
       FILE SECTION.
       FD  TRANLOG-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 150 CHARACTERS.
       01  TRANLOG-RECORD.
           05  TRN-SEQ                     PIC 9(10).
           05  TRN-DATE                    PIC 9(08).
           05  TRN-TIME                    PIC 9(06).
           05  TRN-TYPE                    PIC X(03).
           05  TRN-ACCOUNT-NBR             PIC X(10).
           05  TRN-ACCOUNT-DEST            PIC X(10).
           05  TRN-CUSTOMER-ID             PIC X(10).
           05  TRN-AMOUNT                  PIC S9(13)V99 COMP-3.
           05  TRN-AMOUNT-TAX              PIC S9(09)V99 COMP-3.
           05  TRN-AMOUNT-TOTAL            PIC S9(13)V99 COMP-3.
           05  TRN-AMOUNT-ORIGINAL         PIC S9(13)V99 COMP-3.
           05  TRN-FEE-AMOUNT              PIC S9(07)V99 COMP-3.
           05  TRN-FEE-CODE                PIC X(04).
           05  TRN-BRANCH                  PIC X(04).
           05  TRN-TELLER-ID               PIC X(08).
           05  TRN-USER-ID                 PIC X(08).
           05  TRN-TERMINAL                PIC X(08).
           05  TRN-CHANNEL                 PIC X(02).
           05  TRN-REFERENCE               PIC X(20).
           05  TRN-CHQ-NBR                 PIC 9(10).
           05  TRN-CHQ-BANK                PIC X(10).
           05  TRN-CHQ-ACCOUNT             PIC X(10).
           05  TRN-STATUS                  PIC X(01).
           05  TRN-REVERSE-SEQ             PIC 9(10).
           05  TRN-DESCRIPTION             PIC X(30).
           05  TRN-FILLER                  PIC X(10).
      *
       FD  GLMASTER-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 160 CHARACTERS.
       01  GLMASTER-RECORD.
           05  GL-ACCOUNT                  PIC X(08).
           05  GL-DESCRIPTION              PIC X(40).
           05  GL-TYPE                     PIC X(01).
           05  GL-LEVEL                    PIC 9(01).
           05  GL-BALANCE-INICIAL          PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-CURRENT          PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-DEBIT            PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-CREDIT           PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-PERIOD-ANT       PIC S9(13)V99 COMP-3.
           05  GL-BALANCE-YTD              PIC S9(13)V99 COMP-3.
           05  GL-CURRENCY                 PIC X(03).
           05  GL-BRANCH                   PIC X(04).
           05  GL-CENTER-COST              PIC X(06).
           05  GL-STATUS                   PIC X(01).
           05  GL-DATE-LAST-ACTIVITY       PIC 9(08).
           05  GL-DATE-LAST-CIERRE         PIC 9(08).
           05  GL-USER-LAST-MOD            PIC X(08).
           05  GL-FILLER                   PIC X(20).
      *
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
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'BCHGLI00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V2.7'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-TRX-PROCESADAS          PIC 9(10) VALUE 0.
           05  WS-TRX-ERRORES             PIC 9(06) VALUE 0.
           05  WS-TOTAL-DEBITOS           PIC S9(13)V99 COMP-3.
           05  WS-TOTAL-CREDITOS          PIC S9(13)V99 COMP-3.
           05  WS-TRX-DISP                PIC Z(9)9.
           05  WS-TOTAL-DISP              PIC Z(11)9.99.
           05  WS-GL-DEBIT-ACCT           PIC X(08).
           05  WS-GL-CREDIT-ACCT          PIC X(08).
           05  WS-GL-INTERES-ACCT         PIC X(08) VALUE '41010001'.
           05  WS-GL-COMISION-ACCT        PIC X(08) VALUE '41020001'.
           05  WS-GL-EFECTIVO-ACCT        PIC X(08) VALUE '11010001'.
           05  WS-GL-MORA-ACCT            PIC X(08) VALUE '41030001'.
      *
       01  WS-BCTL-CONTROL.
           05  WS-BCTL-FECHA               PIC 9(08).
           05  WS-BCTL-CONTABLE            PIC 9(08).
           05  WS-BCTL-PROXIMA             PIC 9(08).
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-PROGRESO.
           05  SCR-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - PASE CONTABLE (GL)'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' BATCH - INTERFAZ CONTABLE'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
      *
           05  SCR-DATOS.
               10  LINE 05  COL 05  PIC X(30)
                   VALUE 'TRANSACCIONES PROCESADAS:'.
               10  LINE 05  COL 35  PIC Z(9)9 FROM WS-TRX-DISP.
               10  LINE 06  COL 05  PIC X(30) VALUE 'ERRORES:'.
               10  LINE 06  COL 35  PIC Z(5)9 FROM WS-TRX-ERRORES.
               10  LINE 08  COL 05  PIC X(30) VALUE 'TOTAL DEBITOS:'.
               10  LINE 08  COL 30  PIC Z(11)9.99 FROM WS-TOTAL-DISP.
               10  LINE 10  COL 05  PIC X(30) VALUE 'TOTAL CREDITOS:'.
               10  LINE 10  COL 30  PIC Z(11)9.99 FROM WS-TOTAL-DISP.
      *
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF3=INTERRUMPIR  PF12=SALIR'.
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
           PERFORM 2000-PROCESAR-TRANLOG.
           PERFORM 3000-ACTUALIZAR-BATCHCTL.
      *
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 0 TO WS-TRX-PROCESADAS
                      WS-TRX-ERRORES
                      WS-TOTAL-DEBITOS
                      WS-TOTAL-CREDITOS.
           MOVE 'INICIALIZANDO PASE CONTABLE...'
             TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-PROGRESO.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
      *--- PROCESAR TRANLOG Y CREAR ASIENTOS ---*
       2000-PROCESAR-TRANLOG.
           MOVE 'PROCESANDO TRANSACCIONES PARA GL...'
             TO WS-MENSAJE.
           DISPLAY SCR-PROGRESO.
      *
      *--- LEER BATCHCTL PARA OBTENER FECHA CONTABLE ---*
           PERFORM 2100-LEER-BATCHCTL.
      *
           OPEN INPUT TRANLOG-FILE.
           IF FL-TRANLOG-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR TRANLOG' TO WS-MENSAJE-ERROR
               MOVE 4 TO WS-RETCODE
               GOTO 2000-EXIT
           END-IF.
      *
           OPEN I-O GLMASTER-FILE.
           IF FL-GLMASTER-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR GLMASTER' TO WS-MENSAJE-ERROR
               MOVE 5 TO WS-RETCODE
               CLOSE TRANLOG-FILE
               GOTO 2000-EXIT
           END-IF.
      *
           MOVE 'N' TO WS-EOF-YES.
           MOVE 0 TO TRN-SEQ.
           START TRANLOG-FILE KEY IS GREATER THAN TRN-SEQ
               INVALID KEY
                   MOVE 'Y' TO WS-EOF-YES
           END-START.
      *
           PERFORM UNTIL WS-EOF-YES
               READ TRANLOG-FILE NEXT RECORD
                   AT END
                       MOVE 'Y' TO WS-EOF-YES
                       EXIT PERFORM
               END-READ
      *
               IF FL-TRANLOG-STATUS NOT = '00'
                   ADD 1 TO WS-TRX-ERRORES
                   EXIT PERFORM CYCLE
               END-IF
      *
               EVALUATE TRN-TYPE
                   WHEN 'DEP'
                       MOVE WS-GL-EFECTIVO-ACCT TO WS-GL-DEBIT-ACCT
                       MOVE '41010001' TO WS-GL-CREDIT-ACCT
                       PERFORM 2200-CREAR-ASIENTO
      *
                   WHEN 'RET'
                       MOVE '11010001' TO WS-GL-DEBIT-ACCT
                       MOVE WS-GL-EFECTIVO-ACCT TO WS-GL-CREDIT-ACCT
                       PERFORM 2200-CREAR-ASIENTO
      *
                   WHEN 'INT'
                       MOVE '11010001' TO WS-GL-DEBIT-ACCT
                       MOVE WS-GL-INTERES-ACCT TO WS-GL-CREDIT-ACCT
                       PERFORM 2200-CREAR-ASIENTO
      *
                   WHEN 'COM'
                       MOVE '11010001' TO WS-GL-DEBIT-ACCT
                       MOVE WS-GL-COMISION-ACCT TO WS-GL-CREDIT-ACCT
                       PERFORM 2200-CREAR-ASIENTO
      *
                   WHEN 'PAG'
                       MOVE WS-GL-EFECTIVO-ACCT TO WS-GL-DEBIT-ACCT
                       MOVE '21010001' TO WS-GL-CREDIT-ACCT
                       PERFORM 2200-CREAR-ASIENTO
      *
                   WHEN 'CHQ'
                       MOVE WS-GL-EFECTIVO-ACCT TO WS-GL-DEBIT-ACCT
                       MOVE '21020001' TO WS-GL-CREDIT-ACCT
                       PERFORM 2200-CREAR-ASIENTO
      *
                   WHEN 'TRF'
                       MOVE '11010001' TO WS-GL-DEBIT-ACCT
                       MOVE '11010001' TO WS-GL-CREDIT-ACCT
                       PERFORM 2200-CREAR-ASIENTO
      *
                   WHEN OTHER
                       MOVE '11010001' TO WS-GL-DEBIT-ACCT
                       MOVE '31010001' TO WS-GL-CREDIT-ACCT
                       PERFORM 2200-CREAR-ASIENTO
               END-EVALUATE
      *
               ADD 1 TO WS-TRX-PROCESADAS
           END-PERFORM.
      *
           CLOSE TRANLOG-FILE.
           CLOSE GLMASTER-FILE.
      *
           MOVE WS-TRX-PROCESADAS TO WS-TRX-DISP.
           STRING 'PASE CONTABLE COMPLETADO - ' WS-TRX-PROCESADAS
                  ' ASIENTOS CREADOS'
             INTO WS-MENSAJE.
           DISPLAY SCR-PROGRESO.
      *
       2000-EXIT.
           EXIT.
      *
       2100-LEER-BATCHCTL.
           OPEN INPUT BATCHCTL-FILE.
           IF FL-BATCHCTL-STATUS = '00'
               MOVE 99999999 TO BCH-FECHA-PROCESO
               START BATCHCTL-FILE KEY IS LESS THAN BCH-FECHA-PROCESO
                   INVALID KEY
                       CLOSE BATCHCTL-FILE
                       GOTO 2100-EXIT
               END-START
               READ BATCHCTL-FILE NEXT RECORD
                   AT END
                       CLOSE BATCHCTL-FILE
                       GOTO 2100-EXIT
               END-READ
               IF FL-BATCHCTL-STATUS = '00'
                   MOVE BCH-FECHA-PROCESO TO WS-BCTL-FECHA
                   MOVE BCH-FECHA-CONTABLE TO WS-BCTL-CONTABLE
                   MOVE BCH-FECHA-PROXIMA TO WS-BCTL-PROXIMA
               END-IF
               CLOSE BATCHCTL-FILE
           END-IF.
      *
       2100-EXIT.
           EXIT.
      *
       2200-CREAR-ASIENTO.
      *    ACTUALIZAR CUENTA DEBITO
           MOVE WS-GL-DEBIT-ACCT TO GL-ACCOUNT.
           READ GLMASTER-FILE KEY IS GL-ACCOUNT
               INVALID KEY
                   ADD 1 TO WS-TRX-ERRORES
                   GOTO 2200-EXIT
           END-READ.
      *
           COMPUTE GL-BALANCE-CURRENT = GL-BALANCE-CURRENT
                                      + TRN-AMOUNT-TOTAL.
           COMPUTE GL-BALANCE-DEBIT = GL-BALANCE-DEBIT
                                    + TRN-AMOUNT-TOTAL.
           MOVE WS-FECHA TO GL-DATE-LAST-ACTIVITY.
           MOVE WS-USUARIO TO GL-USER-LAST-MOD.
           REWRITE GLMASTER-RECORD.
           IF FL-GLMASTER-STATUS NOT = '00'
               ADD 1 TO WS-TRX-ERRORES
           END-IF.
      *
      *    ACTUALIZAR CUENTA CREDITO
           MOVE WS-GL-CREDIT-ACCT TO GL-ACCOUNT.
           READ GLMASTER-FILE KEY IS GL-ACCOUNT
               INVALID KEY
                   ADD 1 TO WS-TRX-ERRORES
                   GOTO 2200-EXIT
           END-READ.
      *
           COMPUTE GL-BALANCE-CURRENT = GL-BALANCE-CURRENT
                                      + TRN-AMOUNT-TOTAL.
           COMPUTE GL-BALANCE-CREDIT = GL-BALANCE-CREDIT
                                     + TRN-AMOUNT-TOTAL.
           MOVE WS-FECHA TO GL-DATE-LAST-ACTIVITY.
           MOVE WS-USUARIO TO GL-USER-LAST-MOD.
           REWRITE GLMASTER-RECORD.
           IF FL-GLMASTER-STATUS NOT = '00'
               ADD 1 TO WS-TRX-ERRORES
           END-IF.
      *
           ADD TRN-AMOUNT-TOTAL TO WS-TOTAL-DEBITOS.
           ADD TRN-AMOUNT-TOTAL TO WS-TOTAL-CREDITOS.
      *
       2200-EXIT.
           EXIT.
      *
      *--- ACTUALIZAR REGISTRO DE CONTROL BATCH ---*
       3000-ACTUALIZAR-BATCHCTL.
           OPEN I-O BATCHCTL-FILE.
           IF FL-BATCHCTL-STATUS NOT = '00'
               GOTO 3000-EXIT
           END-IF.
      *
           MOVE WS-FECHA TO BCH-FECHA-PROCESO.
           MOVE WS-FECHA TO BCH-FECHA-CONTABLE.
           MOVE WS-FECHA TO BCH-FECHA-PROXIMA.
           MOVE 'C' TO BCH-ESTADO-GENERAL.
           MOVE 'S' TO BCH-ST-GL.
           MOVE WS-FECHA TO GL-DATE-LAST-ACTIVITY.
           MOVE WS-USUARIO TO BCH-USUARIO-EJECUTA.
           MOVE WS-TRX-PROCESADAS TO BCH-TRX-PROCESADAS.
           MOVE WS-TRX-ERRORES TO BCH-TRX-ERROR.
      *
           WRITE BATCHCTL-RECORD.
           IF FL-BATCHCTL-STATUS = '22'
               REWRITE BATCHCTL-RECORD
           END-IF.
      *
           CLOSE BATCHCTL-FILE.
       3000-EXIT.
           EXIT.
      *
       9000-FINALIZAR.
           CLOSE TRANLOG-FILE.
           CLOSE GLMASTER-FILE.
           CLOSE BATCHCTL-FILE.
           IF WS-TRX-ERRORES > 0
               MOVE 1 TO LS-RETCODE
           ELSE
               MOVE 0 TO LS-RETCODE
           END-IF.
      *
       END PROGRAM BCHGLI00.
