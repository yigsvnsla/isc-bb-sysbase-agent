       *================================================================*
       * BCHMTH00 - CIERRE MENSUAL                                    *
       * PROPOSITO: ORQUESTAR CIERRE MENSUAL, PROMEDIOS, INTERES      *
       *            AHORROS, BALANCE DE PRUEBA                        *
       * EQUIPO: OPERACIONES - 1998                                   *
       * CALL: BCHINT00, BCHODO00, BCHFEE00, BCHGLI00, COMDATE       *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCHMTH00.
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
           SELECT ACCOUNT-FILE
               ASSIGN TO 'ACCOUNT.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS ACT-NBR
               FILE STATUS IS FL-ACCOUNT-STATUS.
           SELECT TRANLOG-FILE
               ASSIGN TO 'TRANLOG.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TRN-SEQ
               FILE STATUS IS FL-TRANLOG-STATUS.
           SELECT BATCHCTL-FILE
               ASSIGN TO 'BATCHCTL.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS BCH-FECHA-PROCESO
               FILE STATUS IS FL-BATCHCTL-STATUS.
      *================================================================*
       DATA DIVISION.
       FILE SECTION.
       FD  ACCOUNT-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 200 CHARACTERS.
       01  ACCOUNT-RECORD.
           05  ACT-NBR                     PIC X(10).
           05  ACT-TYPE                    PIC X(02).
           05  ACT-CURRENCY                PIC X(03).
           05  ACT-BALANCE                 PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-DISPONIBLE      PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-RETENIDO        PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-SOBREGIRO       PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-PROMEDIO        PIC S9(13)V99 COMP-3.
           05  ACT-BALANCE-ANTERIOR        PIC S9(13)V99 COMP-3.
           05  ACT-OVERDRAFT-LIMIT         PIC S9(09)V99 COMP-3.
           05  ACT-OVERDRAFT-RATE          PIC 9(03)V9(04) COMP-3.
           05  ACT-INTEREST-RATE           PIC 9(03)V9(04) COMP-3.
           05  ACT-INTEREST-ACCRUED        PIC S9(09)V99 COMP-3.
           05  ACT-MONTHLY-FEE             PIC 9(07)V99 COMP-3.
           05  ACT-DATE-OPEN               PIC 9(08).
           05  ACT-DATE-CLOSE              PIC 9(08).
           05  ACT-DATE-LAST-ACTIVITY      PIC 9(08).
           05  ACT-DATE-LAST-INT-CALC      PIC 9(08).
           05  ACT-DATE-LAST-STATEMENT     PIC 9(08).
           05  ACT-STATUS                  PIC X(01).
           05  ACT-BRANCH-OPEN             PIC X(04).
           05  ACT-OFFICER                 PIC X(08).
           05  ACT-USER-LAST-MOD           PIC X(08).
           05  ACT-TXN-COUNT-TODAY         PIC 9(06).
           05  ACT-TXN-COUNT-MONTH         PIC 9(06).
           05  ACT-CHECKS-ISSUED           PIC 9(06).
           05  ACT-CHECKS-BOUNCED          PIC 9(06).
           05  ACT-CHQBOOK-NBR             PIC X(10).
           05  ACT-CHQ-NEXT               PIC 9(07).
           05  ACT-CHQ-LAST-USED          PIC 9(07).
           05  ACT-CHQ-STOP-COUNT          PIC 9(03).
           05  ACT-FILLER                  PIC X(15).
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
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'BCHMTH00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V2.1'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-CONFIRMA                PIC X(01).
           05  WS-HORA-INICIO             PIC 9(06).
           05  WS-HORA-FIN                PIC 9(06).
           05  WS-TRX-TOTAL               PIC 9(10) VALUE 0.
           05  WS-TRX-ERROR               PIC 9(06) VALUE 0.
           05  WS-PROCESO-ACTUAL          PIC X(25).
           05  WS-CONT-CUENTAS            PIC 9(09) VALUE 0.
           05  WS-CONT-AHORRO             PIC 9(09) VALUE 0.
           05  WS-TOTAL-INTERES-AHORRO    PIC S9(13)V99 COMP-3.
           05  WS-INTERES-CUENTA          PIC S9(09)V99 COMP-3.
           05  WS-TRX-SEQ                 PIC 9(10) VALUE 0.
           05  WS-FECHA-PROXIMA           PIC 9(08).
           05  WS-DIAS-MES                PIC 9(02) VALUE 30.
           05  WS-TRX-DISP                PIC Z(9)9.
           05  WS-ERR-DISP                PIC Z(5)9.
           05  WS-INT-AHO-DISP            PIC Z(11)9.99.
           05  WS-RETCODE-INT             PIC 99.
           05  WS-RETCODE-ODO             PIC 99.
           05  WS-RETCODE-FEE             PIC 99.
           05  WS-RETCODE-GLI             PIC 99.
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
       01  SCR-CONFIRMA.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - CIERRE MENSUAL'.
           05  LINE 02  COL 01  PIC X(80)
               VALUE ' VERIFICACION PREVIA AL CIERRE MENSUAL'.
           05  LINE 04  COL 05  PIC X(30) VALUE 'FECHA DE PROCESO:'.
           05  LINE 04  COL 30  PIC 99/99/9999 FROM WS-FECHA-DDMM.
           05  LINE 06  COL 05  PIC X(60)
               VALUE 'PROCESOS A EJECUTAR:'.
           05  LINE 07  COL 10  PIC X(50)
               VALUE '1. CALCULO DE INTERESES DIARIOS'.
           05  LINE 08  COL 10  PIC X(50)
               VALUE '2. SOBREGIRO / MORA'.
           05  LINE 09  COL 10  PIC X(50)
               VALUE '3. COMISIONES PERIODICAS'.
           05  LINE 10  COL 10  PIC X(50)
               VALUE '4. PASE CONTABLE GL'.
           05  LINE 11  COL 10  PIC X(50)
               VALUE '5. CALCULO DE PROMEDIO MENSUAL'.
           05  LINE 12  COL 10  PIC X(50)
               VALUE '6. INTERES AHORRO'.
           05  LINE 13  COL 10  PIC X(50)
               VALUE '7. BALANCE PRUEBA MENSUAL'.
           05  LINE 15  COL 05  PIC X(40)
               VALUE 'CONFIRMAR? (S/N):'.
           05  LINE 15  COL 25  PIC X(01) USING WS-CONFIRMA.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
       01  SCR-PROGRESO.
           05  SCR-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - CIERRE MENSUAL'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' EJECUTANDO CIERRE MENSUAL'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
           05  SCR-PROCESO.
               10  LINE 05  COL 05  PIC X(20) VALUE 'PROCESO:'.
               10  LINE 05  COL 15  PIC X(25) FROM WS-PROCESO-ACTUAL.
           05  SCR-DATOS.
               10  LINE 08  COL 05  PIC X(30)
                   VALUE 'CUENTAS PROCESADAS:'.
               10  LINE 08  COL 25  PIC Z(9)9 FROM WS-TRX-DISP.
               10  LINE 09  COL 05  PIC X(30) VALUE 'INTERES AHORRO:'.
               10  LINE 09  COL 25  PIC Z(11)9.99 FROM WS-INT-AHO-DISP.
               10  LINE 10  COL 05  PIC X(30) VALUE 'ERRORES:'.
               10  LINE 10  COL 25  PIC Z(5)9 FROM WS-ERR-DISP.
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
      *================================================================*
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
      *================================================================*
       PROCEDURE DIVISION USING LS-USUARIO
                                 LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 0 TO WS-RETCODE.
           PERFORM 1000-INICIALIZAR.
           PERFORM 1500-MOSTRAR-CONFIRMA.
           IF WS-CONFIRMA NOT = 'S'
               MOVE 'CIERRE MENSUAL CANCELADO' TO WS-MENSAJE
               PERFORM 9000-FINALIZAR
               GOBACK.
           PERFORM 2000-REGISTRAR-INICIO.
           PERFORM 3000-EJECUTAR-BATCH-DIARIO.
           PERFORM 4000-CALCULAR-PROMEDIOS.
           PERFORM 5000-CALCULAR-INTERES-AHORRO.
           PERFORM 6000-GENERAR-BALANCE-PRUEBA.
           PERFORM 7000-REGISTRAR-FIN.
           PERFORM 8000-MOSTRAR-RESUMEN.
           PERFORM 9000-FINALIZAR.
           GOBACK.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 'N' TO WS-CONFIRMA.
           MOVE 0 TO WS-TRX-TOTAL WS-TRX-ERROR
                      WS-CONT-CUENTAS WS-CONT-AHORRO
                      WS-TOTAL-INTERES-AHORRO WS-TRX-SEQ.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
       1500-MOSTRAR-CONFIRMA.
           DISPLAY SCR-CONFIRMA.
           ACCEPT SCR-CONFIRMA.
       2000-REGISTRAR-INICIO.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE WS-HORA TO WS-HORA-INICIO.
           PERFORM 1100-LIMPIAR.
       3000-EJECUTAR-BATCH-DIARIO.
           MOVE 'INTERESES DIARIOS' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           CALL 'BCHINT00' USING WS-USUARIO WS-RETCODE-INT.
           IF WS-RETCODE-INT NOT = 00
               ADD 1 TO WS-TRX-ERROR.
           MOVE 'SOBREGIRO/MORA' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           CALL 'BCHODO00' USING WS-USUARIO WS-RETCODE-ODO.
           IF WS-RETCODE-ODO NOT = 00
               ADD 1 TO WS-TRX-ERROR.
           MOVE 'COMISIONES PERIODICAS' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           CALL 'BCHFEE00' USING WS-USUARIO WS-RETCODE-FEE.
           IF WS-RETCODE-FEE NOT = 00
               ADD 1 TO WS-TRX-ERROR.
           MOVE 'PASE CONTABLE GL' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           CALL 'BCHGLI00' USING WS-USUARIO WS-RETCODE-GLI.
           IF WS-RETCODE-GLI NOT = 00
               ADD 1 TO WS-TRX-ERROR.
       4000-CALCULAR-PROMEDIOS.
           MOVE 'CALCULO PROMEDIO MENSUAL' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           OPEN I-O ACCOUNT-FILE.
           IF FL-ACCOUNT-STATUS NOT = '00'
               MOVE 'ERROR ABRIENDO ACCOUNT' TO WS-MENSAJE-ERROR
               GOTO 4000-EXIT.
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO ACT-NBR.
           START ACCOUNT-FILE KEY IS GREATER THAN ACT-NBR
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
           PERFORM UNTIL WS-EOF-YES
               READ ACCOUNT-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               IF ACT-STATUS NOT = 'A'
                   EXIT PERFORM CYCLE
               END-IF
               MOVE ACT-BALANCE TO ACT-BALANCE-PROMEDIO
               MOVE ACT-BALANCE TO ACT-BALANCE-ANTERIOR
               MOVE WS-USUARIO TO ACT-USER-LAST-MOD
               REWRITE ACCOUNT-RECORD
               ADD 1 TO WS-CONT-CUENTAS
           END-PERFORM.
           CLOSE ACCOUNT-FILE.
       4000-EXIT.
           EXIT.
       5000-CALCULAR-INTERES-AHORRO.
           MOVE 'INTERES AHORRO MENSUAL' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
           OPEN I-O ACCOUNT-FILE.
           IF FL-ACCOUNT-STATUS NOT = '00'
               GOTO 5000-EXIT.
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO ACT-NBR.
           START ACCOUNT-FILE KEY IS GREATER THAN ACT-NBR
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
           PERFORM UNTIL WS-EOF-YES
               READ ACCOUNT-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               IF ACT-STATUS NOT = 'A'
                   EXIT PERFORM CYCLE
               END-IF
               IF ACT-TYPE NOT = 'AH'
                   EXIT PERFORM CYCLE
               END-IF
               COMPUTE WS-INTERES-CUENTA ROUNDED =
                   ACT-BALANCE-PROMEDIO * ACT-INTEREST-RATE / 12
               COMPUTE ACT-BALANCE = ACT-BALANCE + WS-INTERES-CUENTA
               COMPUTE ACT-BALANCE-DISPONIBLE =
                   ACT-BALANCE-DISPONIBLE + WS-INTERES-CUENTA
               COMPUTE ACT-INTEREST-ACCRUED =
                   ACT-INTEREST-ACCRUED + WS-INTERES-CUENTA
               MOVE WS-FECHA TO ACT-DATE-LAST-INT-CALC
               REWRITE ACCOUNT-RECORD
               ADD WS-INTERES-CUENTA TO WS-TOTAL-INTERES-AHORRO
               ADD 1 TO WS-CONT-AHORRO
               PERFORM 5100-REGISTRAR-TRANLOG-AHORRO
           END-PERFORM.
           CLOSE ACCOUNT-FILE.
           MOVE WS-TOTAL-INTERES-AHORRO TO WS-INT-AHO-DISP.
       5000-EXIT.
           EXIT.
       5100-REGISTRAR-TRANLOG-AHORRO.
           OPEN I-O TRANLOG-FILE.
           IF FL-TRANLOG-STATUS = '93'
               OPEN OUTPUT TRANLOG-FILE
               CLOSE TRANLOG-FILE
               OPEN I-O TRANLOG-FILE.
           ADD 1 TO WS-TRX-SEQ.
           MOVE WS-TRX-SEQ TO TRN-SEQ.
           MOVE WS-FECHA TO TRN-DATE.
           MOVE WS-HORA TO TRN-TIME.
           MOVE 'INT' TO TRN-TYPE.
           MOVE ACT-NBR TO TRN-ACCOUNT-NBR.
           MOVE SPACES TO TRN-ACCOUNT-DEST.
           MOVE WS-INTERES-CUENTA TO TRN-AMOUNT.
           MOVE WS-INTERES-CUENTA TO TRN-AMOUNT-TOTAL.
           MOVE 0 TO TRN-AMOUNT-TAX TRN-FEE-AMOUNT.
           MOVE SPACES TO TRN-FEE-CODE.
           MOVE ACT-BRANCH-OPEN TO TRN-BRANCH.
           MOVE 'BATCH' TO TRN-TELLER-ID.
           MOVE WS-USUARIO TO TRN-USER-ID.
           MOVE '04' TO TRN-CHANNEL.
           MOVE 'C' TO TRN-STATUS.
           STRING 'INT AHORRO MENSUAL ' ACT-NBR
             INTO TRN-DESCRIPTION.
           WRITE TRANLOG-RECORD.
           IF FL-TRANLOG-STATUS NOT = '00'
               ADD 1 TO WS-TRX-ERROR.
           CLOSE TRANLOG-FILE.
       6000-GENERAR-BALANCE-PRUEBA.
           MOVE 'BALANCE PRUEBA MENSUAL' TO WS-PROCESO-ACTUAL.
           DISPLAY SCR-PROGRESO.
      *    SIMULATED - DISPLAY GL TRIAL BALANCE
           DISPLAY ' '.
           DISPLAY ' BALANCE DE PRUEBA MENSUAL'.
           DISPLAY ' ============================'.
           DISPLAY ' GENERANDO REPORTE...'.
       7000-REGISTRAR-FIN.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE WS-HORA TO WS-HORA-FIN.
           MOVE WS-FECHA TO WS-FECHA-PROXIMA.
           OPEN I-O BATCHCTL-FILE.
           IF FL-BATCHCTL-STATUS = '00'
               MOVE WS-FECHA TO BCH-FECHA-PROCESO
               MOVE WS-FECHA TO BCH-FECHA-CONTABLE
               MOVE WS-FECHA-PROXIMA TO BCH-FECHA-PROXIMA
               MOVE 'S' TO BCH-DIA-HABIL
               MOVE 'C' TO BCH-ESTADO-GENERAL
               MOVE 'C' TO BCH-ST-INTERES
               MOVE 'C' TO BCH-ST-SOBREGIRO
               MOVE 'C' TO BCH-ST-COMISIONES
               MOVE 'C' TO BCH-ST-GL
               MOVE 'C' TO BCH-ST-REPORTES
               MOVE 'C' TO BCH-ST-CIERRE
               MOVE WS-HORA-INICIO TO BCH-HORA-INICIO
               MOVE WS-HORA-FIN TO BCH-HORA-FIN
               MOVE WS-TRX-TOTAL TO BCH-TRX-PROCESADAS
               MOVE WS-TRX-ERROR TO BCH-TRX-ERROR
               MOVE WS-USUARIO TO BCH-USUARIO-EJECUTA
               MOVE 'CIERRE MENSUAL OK' TO BCH-OBSERVACIONES
               WRITE BATCHCTL-RECORD
               IF FL-BATCHCTL-STATUS = '22'
                   REWRITE BATCHCTL-RECORD
               END-IF
               CLOSE BATCHCTL-FILE.
       8000-MOSTRAR-RESUMEN.
           CALL 'AUDTRL00' USING WS-PROGRAMA
                                 'CIERRE MENSUAL COMPLETADO'.
           MOVE WS-TRX-TOTAL TO WS-TRX-DISP.
           MOVE WS-TRX-ERROR TO WS-ERR-DISP.
           MOVE 'CIERRE MENSUAL COMPLETADO' TO WS-MENSAJE.
           DISPLAY SCR-PROGRESO.
       9000-FINALIZAR.
           CLOSE ACCOUNT-FILE.
           CLOSE TRANLOG-FILE.
           CLOSE BATCHCTL-FILE.
           MOVE 0 TO LS-RETCODE.
       END PROGRAM BCHMTH00.
