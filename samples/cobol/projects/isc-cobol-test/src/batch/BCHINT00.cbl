       *================================================================*
       * BCHINT00 - CALCULO DE INTERESES DIARIOS                       *
       * PROPOSITO: CALCULAR INTERESES DEVENGADOS POR CUENTA          *
       *            Y REGISTRAR EN TRANLOG.                           *
       * EQUIPO: OPERACIONES - 1999                                   *
       * ARCHIVOS: ACCOUNT (ENTRADA/SALIDA), TRANLOG (SALIDA)         *
       * CALL: COMDATE                                                *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCHINT00.
      *================================================================*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
      *================================================================*
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO 'ACCOUNT.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS ACT-NBR
               FILE STATUS IS FL-ACCOUNT-STATUS.
      *
           SELECT TRANLOG-FILE
               ASSIGN TO 'TRANLOG.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TRN-SEQ
               FILE STATUS IS FL-TRANLOG-STATUS.
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
      *
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
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF1                VALUE 1001.
           88  WS-CRT-PF3                VALUE 1003.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
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
           05  WS-PROGRAMA                PIC X(08) VALUE 'BCHINT00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V2.3'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-CONTADOR-PROCESADOS     PIC 9(09) VALUE 0.
           05  WS-CONTADOR-ERROR          PIC 9(06) VALUE 0.
           05  WS-CONTADOR-SIN-SALDO      PIC 9(09) VALUE 0.
           05  WS-TRX-SEQ                 PIC 9(10) VALUE 0.
           05  WS-INTERES-CALC            PIC S9(09)V99 COMP-3.
           05  WS-TASA-DIARIA             PIC 9(03)V9(08) COMP-3.
           05  WS-INTERES-DISP             PIC Z(8)9.99.
           05  WS-PROCESADOS-DISP          PIC Z(8)9.
           05  WS-ERRORES-DISP             PIC Z(5)9.
      *
       01  WS-ACCT-STATUS                 PIC X(01).
           88  WS-ACT-ACTIVE              VALUE 'A'.
           88  WS-ACT-INACTIVE            VALUE 'I'.
           88  WS-ACT-CLOSED              VALUE 'C'.
           88  WS-ACT-FROZEN              VALUE 'F'.
           88  WS-ACT-DORMANT             VALUE 'D'.
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-PROGRESO.
           05  SCR-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - CALCULO DE INTERESES DIARIOS'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' BATCH - CALCULO DE INTERES POR CUENTA'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
      *
           05  SCR-SQL.
               10  LINE 04  COL 05  PIC X(60)
                   VALUE 'SQL: SELECT * FROM ACCOUNT WHERE STATUS=''A'''.
      *
           05  SCR-DATOS.
               10  LINE 06  COL 05  PIC X(30) VALUE 'CUENTAS PROCESADAS:'.
               10  LINE 06  COL 30  PIC Z(8)9 FROM WS-PROCESADOS-DISP.
               10  LINE 07  COL 05  PIC X(30) VALUE 'CUENTAS SIN SALDO:'.
               10  LINE 07  COL 30  PIC Z(8)9 FROM WS-CONTADOR-SIN-SALDO.
               10  LINE 08  COL 05  PIC X(30) VALUE 'ERRORES:'.
               10  LINE 08  COL 30  PIC Z(5)9 FROM WS-ERRORES-DISP.
               10  LINE 10  COL 05  PIC X(30) VALUE 'ULTIMO INTERES:'.
               10  LINE 10  COL 30  PIC Z(8)9.99 FROM WS-INTERES-DISP.
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
           PERFORM 2000-PROCESAR-CALCULO.
      *
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
      *--- INICIALIZAR ---*
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE 0 TO WS-CONTADOR-PROCESADOS
                      WS-CONTADOR-ERROR
                      WS-CONTADOR-SIN-SALDO.
           MOVE 0 TO WS-INTERES-CALC.
           MOVE 0 TO WS-TRX-SEQ.
           MOVE SPACES TO WS-MENSAJE-ERROR.
           MOVE 'INICIALIZANDO CALCULO DE INTERESES...'
             TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-PROGRESO.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
      *--- PROCESAR CALCULO DE INTERESES ---*
       2000-PROCESAR-CALCULO.
           MOVE 'PROCESANDO CALCULO DE INTERESES...'
             TO WS-MENSAJE.
           MOVE SPACES TO WS-MENSAJE-ERROR.
           DISPLAY SCR-PROGRESO.
      *
           OPEN I-O ACCOUNT-FILE.
           IF FL-ACCOUNT-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR ARCHIVO DE CUENTAS'
                 TO WS-MENSAJE-ERROR
               MOVE 4 TO WS-RETCODE
               GOTO 2000-EXIT
           END-IF.
      *
      *--- LECTURA SECUENCIAL DE CUENTAS ---*
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO ACT-NBR.
           START ACCOUNT-FILE KEY IS GREATER THAN ACT-NBR
               INVALID KEY
                   MOVE 'ERROR AL POSICIONAR ARCHIVO'
                     TO WS-MENSAJE-ERROR
                   MOVE 'Y' TO WS-EOF-YES
           END-START.
      *
           PERFORM UNTIL WS-EOF-YES
               READ ACCOUNT-FILE NEXT RECORD
                   AT END
                       MOVE 'Y' TO WS-EOF-YES
                       EXIT PERFORM
               END-READ
      *
               IF FL-ACCOUNT-STATUS NOT = '00'
                   ADD 1 TO WS-CONTADOR-ERROR
                   EXIT PERFORM CYCLE
               END-IF
      *
               IF ACT-STATUS NOT = 'A'
                   EXIT PERFORM CYCLE
               END-IF
      *
               IF ACT-BALANCE = 0
                   ADD 1 TO WS-CONTADOR-SIN-SALDO
                   EXIT PERFORM CYCLE
               END-IF
      *
               PERFORM 3000-CALCULAR-INTERES
               PERFORM 4000-ACTUALIZAR-CUENTA
               PERFORM 5000-REGISTRAR-TRANLOG
               ADD 1 TO WS-CONTADOR-PROCESADOS
               IF WS-CONTADOR-PROCESADOS / 100 = 0
                   DISPLAY SCR-PROGRESO
               END-IF
           END-PERFORM.
      *
           CLOSE ACCOUNT-FILE.
           CLOSE TRANLOG-FILE.
      *
           MOVE WS-CONTADOR-PROCESADOS TO WS-PROCESADOS-DISP.
           MOVE WS-CONTADOR-ERROR TO WS-ERRORES-DISP.
           STRING 'PROCESO COMPLETADO - ' WS-CONTADOR-PROCESADOS
                  ' CUENTAS PROCESADAS'
             INTO WS-MENSAJE.
      *
       2000-EXIT.
           EXIT.
      *
      *--- CALCULAR INTERES DIARIO ---*
       3000-CALCULAR-INTERES.
      *    INTERES = BALANCE * TASA / 360
           COMPUTE WS-INTERES-CALC ROUNDED =
               ACT-BALANCE * ACT-INTEREST-RATE / 360.
           MOVE WS-INTERES-CALC TO WS-INTERES-DISP.
      *
      *--- ACTUALIZAR CUENTA ---*
       4000-ACTUALIZAR-CUENTA.
           COMPUTE ACT-INTEREST-ACCRUED = ACT-INTEREST-ACCRUED
                                        + WS-INTERES-CALC.
           MOVE WS-FECHA TO ACT-DATE-LAST-INT-CALC.
           MOVE WS-USUARIO TO ACT-USER-LAST-MOD.
      *
           REWRITE ACCOUNT-RECORD.
           IF FL-ACCOUNT-STATUS NOT = '00'
               ADD 1 TO WS-CONTADOR-ERROR
               STRING 'ERROR AL ACTUALIZAR ' ACT-NBR
                 INTO WS-MENSAJE-ERROR
           END-IF.
      *
      *--- REGISTRAR TRANLOG ---*
       5000-REGISTRAR-TRANLOG.
           OPEN I-O TRANLOG-FILE.
           IF FL-TRANLOG-STATUS NOT = '00'
               IF FL-TRANLOG-STATUS = '93'
                   OPEN OUTPUT TRANLOG-FILE
                   CLOSE TRANLOG-FILE
                   OPEN I-O TRANLOG-FILE
               END-IF
           END-IF.
      *
           ADD 1 TO WS-TRX-SEQ.
           MOVE WS-TRX-SEQ TO TRN-SEQ.
           MOVE WS-FECHA TO TRN-DATE.
           MOVE WS-HORA TO TRN-TIME.
           MOVE 'INT' TO TRN-TYPE.
           MOVE ACT-NBR TO TRN-ACCOUNT-NBR.
           MOVE SPACES TO TRN-ACCOUNT-DEST.
           MOVE SPACES TO TRN-CUSTOMER-ID.
           MOVE WS-INTERES-CALC TO TRN-AMOUNT.
           MOVE WS-INTERES-CALC TO TRN-AMOUNT-TOTAL.
           MOVE 0 TO TRN-AMOUNT-TAX.
           MOVE 0 TO TRN-FEE-AMOUNT.
           MOVE SPACES TO TRN-FEE-CODE.
           MOVE ACT-BRANCH-OPEN TO TRN-BRANCH.
           MOVE 'BATCH' TO TRN-TELLER-ID.
           MOVE WS-USUARIO TO TRN-USER-ID.
           MOVE 'CONSOLA' TO TRN-TERMINAL.
           MOVE '04' TO TRN-CHANNEL.
           MOVE SPACES TO TRN-REFERENCE.
           MOVE 0 TO TRN-CHQ-NBR.
           MOVE SPACES TO TRN-CHQ-BANK
                          TRN-CHQ-ACCOUNT.
           MOVE 'C' TO TRN-STATUS.
           MOVE 0 TO TRN-REVERSE-SEQ.
           STRING 'INT DIARIO ' ACT-NBR
             INTO TRN-DESCRIPTION.
      *
           WRITE TRANLOG-RECORD.
           IF FL-TRANLOG-STATUS NOT = '00'
               ADD 1 TO WS-CONTADOR-ERROR
           END-IF.
      *
           CLOSE TRANLOG-FILE.
      *
      *--- FINALIZAR ---*
       9000-FINALIZAR.
           CLOSE ACCOUNT-FILE.
           CLOSE TRANLOG-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM BCHINT00.
