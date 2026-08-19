       *================================================================*
       * BCHFEE00 - COMISIONES PERIODICAS                             *
       * PROPOSITO: APLICAR COMISIONES MENSUALES A CUENTAS            *
       *            BASADO EN CONFIGURACION POR PRODUCTO              *
       * EQUIPO: PRODUCTOS - 2001                                    *
       * ARCHIVOS: ACCOUNT (I-O), TRANLOG (SALIDA)                   *
       * CALL: COMDATE                                               *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BCHFEE00.
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
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-DIA-DE-MES              PIC 9(02).
           05  WS-MES-ACTUAL              PIC 9(02).
           05  WS-ANO-ACTUAL              PIC 9(04).
           05  WS-PROGRAMA                PIC X(08) VALUE 'BCHFEE00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V2.0'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-CONTADOR                PIC 9(09) VALUE 0.
           05  WS-CONTADOR-ERROR          PIC 9(06) VALUE 0.
           05  WS-CONTADOR-CON-FEE        PIC 9(09) VALUE 0.
           05  WS-CONTADOR-SIN-FEE        PIC 9(09) VALUE 0.
           05  WS-TOTAL-COMISIONES        PIC S9(13)V99 COMP-3.
           05  WS-COMISION-APLICAR        PIC S9(09)V99 COMP-3.
           05  WS-TRX-SEQ                 PIC 9(10) VALUE 0.
           05  WS-TOTAL-COM-DISP          PIC Z(11)9.99.
           05  WS-PROCESADOS-DISP         PIC Z(8)9.
           05  WS-COMISION-DISP           PIC Z(8)9.99.
           05  WS-DIA-CONF                PIC 9(02) VALUE 1.
           05  WS-DIA-CONF-DISP           PIC Z9.
           05  WS-OPCION-DIA              PIC X(01).
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-CONFIG.
           05  LINE 05  COL 05  PIC X(40)
               VALUE 'CONFIGURACION DE COMISIONES PERIODICAS'.
           05  LINE 07  COL 05  PIC X(40)
               VALUE 'DIA DEL MES PARA APLICAR COMISION:'.
           05  LINE 07  COL 45  PIC Z9 USING WS-DIA-CONF.
           05  LINE 09  COL 05  PIC X(40)
               VALUE 'CONFORME? (S/N):'.
           05  LINE 09  COL 25  PIC X(01) USING WS-OPCION-DIA.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
      *
       01  SCR-PROGRESO.
           05  SCR-CABECERA.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - COMISIONES PERIODICAS'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' BATCH - APLICACION DE COMISIONES'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
      *
           05  SCR-DATOS.
               10  LINE 05  COL 05  PIC X(30)
                   VALUE 'CUENTAS CON COMISION:'.
               10  LINE 05  COL 30  PIC Z(8)9 FROM WS-PROCESADOS-DISP.
               10  LINE 06  COL 05  PIC X(30)
                   VALUE 'CUENTAS SIN COMISION:'.
               10  LINE 06  COL 30  PIC Z(8)9 FROM WS-CONTADOR-SIN-FEE.
               10  LINE 07  COL 05  PIC X(30) VALUE 'ERRORES:'.
               10  LINE 07  COL 30  PIC Z(5)9 FROM WS-CONTADOR-ERROR.
               10  LINE 09  COL 05  PIC X(30)
                   VALUE 'TOTAL COMISIONES APLICADAS:'.
               10  LINE 09  COL 35  PIC Z(11)9.99
                   FROM WS-TOTAL-COM-DISP.
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
           PERFORM 1500-CONFIGURAR-DIA.
      *
           IF WS-OPCION-DIA NOT = 'S'
               MOVE 'PROCESO CANCELADO POR USUARIO'
                 TO WS-MENSAJE
               PERFORM 9000-FINALIZAR
               GOBACK
           END-IF.
      *
           PERFORM 2000-PROCESAR-COMISIONES.
      *
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM.
           MOVE WS-FECHA TO WS-DATE-YYYYMMDD.
      *    DIA DE MES = ULTIMOS 2 DIGITOS DE FECHA
           DIVIDE WS-FECHA BY 100 GIVING WS-DATE-YYYYMMDD
               REMAINDER WS-DIA-DE-MES.
           MOVE 1 TO WS-DIA-CONF.
           MOVE 0 TO WS-CONTADOR
                      WS-CONTADOR-ERROR
                      WS-CONTADOR-CON-FEE
                      WS-CONTADOR-SIN-FEE
                      WS-TOTAL-COMISIONES
                      WS-TRX-SEQ.
           MOVE 'N' TO WS-OPCION-DIA.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       1500-CONFIGURAR-DIA.
           DISPLAY SCR-CONFIG.
           ACCEPT SCR-CONFIG.
      *
       2000-PROCESAR-COMISIONES.
           MOVE 'APLICANDO COMISIONES PERIODICAS...'
             TO WS-MENSAJE.
           DISPLAY SCR-PROGRESO.
      *
           OPEN I-O ACCOUNT-FILE.
           IF FL-ACCOUNT-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR CUENTAS' TO WS-MENSAJE-ERROR
               MOVE 4 TO WS-RETCODE
               GOTO 2000-EXIT
           END-IF.
      *
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO ACT-NBR.
           START ACCOUNT-FILE KEY IS GREATER THAN ACT-NBR
               INVALID KEY
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
               IF ACT-MONTHLY-FEE = 0
                   ADD 1 TO WS-CONTADOR-SIN-FEE
                   EXIT PERFORM CYCLE
               END-IF
      *
               PERFORM 2100-APLICAR-COMISION
               PERFORM 2200-REGISTRAR-TRANLOG
               ADD 1 TO WS-CONTADOR
               ADD 1 TO WS-CONTADOR-CON-FEE
               ADD WS-COMISION-APLICAR TO WS-TOTAL-COMISIONES
           END-PERFORM.
      *
           CLOSE ACCOUNT-FILE.
      *
           MOVE WS-CONTADOR-CON-FEE TO WS-PROCESADOS-DISP.
           MOVE WS-TOTAL-COMISIONES TO WS-TOTAL-COM-DISP.
           STRING 'PROCESO COMPLETADO - ' WS-CONTADOR-CON-FEE
                  ' COMISIONES APLICADAS'
             INTO WS-MENSAJE.
           DISPLAY SCR-PROGRESO.
      *
       2000-EXIT.
           EXIT.
      *
       2100-APLICAR-COMISION.
           MOVE ACT-MONTHLY-FEE TO WS-COMISION-APLICAR.
           MOVE WS-COMISION-APLICAR TO WS-COMISION-DISP.
      *
           COMPUTE ACT-BALANCE = ACT-BALANCE - WS-COMISION-APLICAR.
           COMPUTE ACT-BALANCE-DISPONIBLE =
               ACT-BALANCE-DISPONIBLE - WS-COMISION-APLICAR.
           MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
           MOVE WS-USUARIO TO ACT-USER-LAST-MOD.
           ADD 1 TO ACT-TXN-COUNT-TODAY.
           ADD 1 TO ACT-TXN-COUNT-MONTH.
      *
           REWRITE ACCOUNT-RECORD.
           IF FL-ACCOUNT-STATUS NOT = '00'
               ADD 1 TO WS-CONTADOR-ERROR
           END-IF.
      *
       2200-REGISTRAR-TRANLOG.
           OPEN I-O TRANLOG-FILE.
           IF FL-TRANLOG-STATUS = '93'
               OPEN OUTPUT TRANLOG-FILE
               CLOSE TRANLOG-FILE
               OPEN I-O TRANLOG-FILE
           END-IF.
      *
           ADD 1 TO WS-TRX-SEQ.
           MOVE WS-TRX-SEQ TO TRN-SEQ.
           MOVE WS-FECHA TO TRN-DATE.
           MOVE WS-HORA TO TRN-TIME.
           MOVE 'COM' TO TRN-TYPE.
           MOVE ACT-NBR TO TRN-ACCOUNT-NBR.
           MOVE SPACES TO TRN-ACCOUNT-DEST.
           MOVE SPACES TO TRN-CUSTOMER-ID.
           MOVE WS-COMISION-APLICAR TO TRN-AMOUNT.
           MOVE WS-COMISION-APLICAR TO TRN-AMOUNT-TOTAL.
           MOVE 0 TO TRN-AMOUNT-TAX.
           MOVE WS-COMISION-APLICAR TO TRN-FEE-AMOUNT.
           MOVE 'MNFE' TO TRN-FEE-CODE.
           MOVE ACT-BRANCH-OPEN TO TRN-BRANCH.
           MOVE 'BATCH' TO TRN-TELLER-ID.
           MOVE WS-USUARIO TO TRN-USER-ID.
           MOVE 'CONSOLA' TO TRN-TERMINAL.
           MOVE '04' TO TRN-CHANNEL.
           MOVE 'COMISION MENSUAL' TO TRN-REFERENCE.
           MOVE 0 TO TRN-CHQ-NBR.
           MOVE SPACES TO TRN-CHQ-BANK
                          TRN-CHQ-ACCOUNT.
           MOVE 'C' TO TRN-STATUS.
           MOVE 0 TO TRN-REVERSE-SEQ.
           STRING 'COM MENSUAL ' ACT-NBR
             INTO TRN-DESCRIPTION.
      *
           WRITE TRANLOG-RECORD.
           IF FL-TRANLOG-STATUS NOT = '00'
               ADD 1 TO WS-CONTADOR-ERROR
           END-IF.
           CLOSE TRANLOG-FILE.
      *
       9000-FINALIZAR.
           CLOSE ACCOUNT-FILE.
           CLOSE TRANLOG-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM BCHFEE00.
