       *================================================================*
       * RPTTXN00 - REPORTE DE TRANSACCIONES DIARIAS                   *
       * PROPOSITO: CONSULTAR TRANLOG CON FILTROS DE FECHA Y CUENTA,  *
       *            VISUALIZAR CON PAGINACION (PF7/PF8)               *
       * EQUIPO: SISTEMAS TRANSACCIONALES - 2003                      *
       * ARCHIVOS: TRANLOG (LECTURA SECUENCIAL)                       *
       * CALL: COMDATE, COMMSGF                                      *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTTXN00.
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
           SELECT TRANLOG-FILE
               ASSIGN TO 'TRANLOG.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS TRN-SEQ
               FILE STATUS IS FL-TRANLOG-STATUS.
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
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF1                VALUE 1001.
           88  WS-CRT-PF4                VALUE 1004.
           88  WS-CRT-PF5                VALUE 1005.
           88  WS-CRT-PF7                VALUE 1007.
           88  WS-CRT-PF8                VALUE 1008.
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'RPTTXN00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V2.5'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-FECHA-DESDE             PIC 9(08).
           05  WS-FECHA-HASTA             PIC 9(08).
           05  WS-FECHA-DESDE-DISP        PIC 99/99/9999.
           05  WS-FECHA-HASTA-DISP        PIC 99/99/9999.
           05  WS-FILTRO-CUENTA           PIC X(10).
           05  WS-USAR-FILTRO             PIC X(01).
           05  WS-PAGINA                  PIC 9(04) VALUE 1.
           05  WS-TOTAL-REG               PIC 9(06) VALUE 0.
           05  WS-REG-EN-PAGINA           PIC 9(02) VALUE 15.
           05  WS-TOTAL-PAGINAS           PIC 9(04).
           05  WS-REG-DESDE               PIC 9(06).
           05  WS-REG-HASTA               PIC 9(06).
           05  WS-CONTADOR-REG            PIC 9(06).
           05  WS-CONTADOR-TOTAL          PIC 9(06).
           05  WS-SUM-DEP                 PIC S9(13)V99 COMP-3.
           05  WS-SUM-RET                 PIC S9(13)V99 COMP-3.
           05  WS-SUM-TRF                 PIC S9(13)V99 COMP-3.
           05  WS-SUM-PAG                 PIC S9(13)V99 COMP-3.
           05  WS-SUM-INT                 PIC S9(13)V99 COMP-3.
           05  WS-SUM-COM                 PIC S9(13)V99 COMP-3.
           05  WS-SUM-TOTAL               PIC S9(13)V99 COMP-3.
           05  WS-SUM-DISP                PIC Z(11)9.99.
      *
       01  WS-TXN-TABLE.
           05  WS-TXN-ENTRY               OCCURS 15.
               10  WS-TXN-SEQ              PIC 9(10).
               10  WS-TXN-DATE             PIC 9(08).
               10  WS-TXN-TIME             PIC 9(06).
               10  WS-TXN-TYPE             PIC X(03).
               10  WS-TXN-ACCOUNT          PIC X(10).
               10  WS-TXN-AMOUNT           PIC S9(13)V99 COMP-3.
               10  WS-TXN-STATUS           PIC X(01).
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-PROMPT.
           05  LINE 05  COL 10  PIC X(30) VALUE 'FECHA DESDE (DDMMYYYY):'.
           05  LINE 05  COL 42  PIC 99/99/9999 USING WS-FECHA-DESDE.
           05  LINE 07  COL 10  PIC X(30) VALUE 'FECHA HASTA (DDMMYYYY):'.
           05  LINE 07  COL 42  PIC 99/99/9999 USING WS-FECHA-HASTA.
           05  LINE 09  COL 10  PIC X(30) VALUE 'CUENTA (OPCIONAL):'.
           05  LINE 09  COL 42  PIC X(10) USING WS-FILTRO-CUENTA.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
      *
       01  SCR-REPORTE.
           05  SCR-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - TRANSACCIONES DIARIAS'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' REPORTE DE TRANSACCIONES'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
               10  LINE 03  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 04  COL 01  PIC X(78)
                   VALUE 'SEQ     FECHA    HORA  TIPO  CUENTA     '.
               10  LINE 04  COL 41  PIC X(39)
                   VALUE 'MONTO        EST'.
      *
           05  SCR-DETALLE OCCURS 15.
               10  SCR-DET-LINE            PIC 9(02).
               10  SCR-DET-SEQ             PIC Z(9)9.
               10  SCR-DET-DATE            PIC 99/99/9999.
               10  SCR-DET-TIME            PIC 9(06).
               10  SCR-DET-TYPE            PIC X(03).
               10  SCR-DET-ACCT            PIC X(10).
               10  SCR-DET-AMT             PIC Z(11)9.99.
               10  SCR-DET-STAT            PIC X(01).
      *
           05  SCR-PIE.
               10  LINE 21  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 21  COL 05  PIC X(20) VALUE 'PAGINA:'.
               10  LINE 21  COL 15  PIC Z(9) FROM WS-PAGINA.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF4=IMPR  PF5=EXPORT  PF7=P-ANT  PF8=P-SIG'.
               10  LINE 24  COL 55  PIC X(25)
                   VALUE '  PF12=SALIR'.
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
           PERFORM 2000-PROMPT-FILTROS.
           PERFORM 3000-CARGAR-TABLA.
           PERFORM 4000-MOSTRAR-PAGINA.
      *
       REPORT-LOOP.
           ACCEPT SCR-REPORTE.
           EVALUATE TRUE
               WHEN WS-CRT-PF7
                   IF WS-PAGINA > 1
                       SUBTRACT 1 FROM WS-PAGINA
                       PERFORM 4000-MOSTRAR-PAGINA
                   ELSE
                       MOVE 'YA ESTA EN PRIMERA PAGINA'
                         TO WS-MENSAJE-ERROR
                   END-IF
               WHEN WS-CRT-PF8
                   IF WS-PAGINA < WS-TOTAL-PAGINAS
                       ADD 1 TO WS-PAGINA
                       PERFORM 4000-MOSTRAR-PAGINA
                   ELSE
                       MOVE 'YA ESTA EN ULTIMA PAGINA'
                         TO WS-MENSAJE-ERROR
                   END-IF
               WHEN WS-CRT-PF12
                   PERFORM 9000-FINALIZAR
                   GOBACK
               WHEN WS-CRT-CLEAR
                   MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                   PERFORM 4000-MOSTRAR-PAGINA
               WHEN OTHER
                   MOVE 'USE PF7/PF8=NAVEGAR  PF12=SALIR'
                     TO WS-MENSAJE-ERROR
           END-EVALUATE.
           GO TO REPORT-LOOP.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM WS-FECHA-HASTA.
           MOVE WS-FECHA TO WS-FECHA-DESDE.
           MOVE SPACES TO WS-FILTRO-CUENTA.
           MOVE 1 TO WS-PAGINA.
           MOVE 0 TO WS-TOTAL-REG WS-CONTADOR-TOTAL.
           MOVE 0 TO WS-SUM-DEP WS-SUM-RET WS-SUM-TRF
                      WS-SUM-PAG WS-SUM-INT WS-SUM-COM
                      WS-SUM-TOTAL.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       2000-PROMPT-FILTROS.
           DISPLAY SCR-PROMPT.
           ACCEPT SCR-PROMPT.
      *
       3000-CARGAR-TABLA.
           OPEN INPUT TRANLOG-FILE.
           IF FL-TRANLOG-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR TRANLOG' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT.
      *
           MOVE 'N' TO WS-EOF-YES.
           MOVE 0 TO TRN-SEQ.
           START TRANLOG-FILE KEY IS GREATER THAN TRN-SEQ
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
      *
           PERFORM UNTIL WS-EOF-YES
               READ TRANLOG-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               IF TRN-DATE < WS-FECHA-DESDE
                   EXIT PERFORM CYCLE
               END-IF
               IF TRN-DATE > WS-FECHA-HASTA
                   EXIT PERFORM CYCLE
               END-IF
               IF WS-FILTRO-CUENTA NOT = SPACES
                   IF TRN-ACCOUNT-NBR NOT = WS-FILTRO-CUENTA
                       EXIT PERFORM CYCLE
                   END-IF
               END-IF
               ADD 1 TO WS-TOTAL-REG
               ADD TRN-AMOUNT-TOTAL TO WS-SUM-TOTAL
               EVALUATE TRN-TYPE
                   WHEN 'DEP' ADD TRN-AMOUNT-TOTAL TO WS-SUM-DEP
                   WHEN 'RET' ADD TRN-AMOUNT-TOTAL TO WS-SUM-RET
                   WHEN 'TRF' ADD TRN-AMOUNT-TOTAL TO WS-SUM-TRF
                   WHEN 'PAG' ADD TRN-AMOUNT-TOTAL TO WS-SUM-PAG
                   WHEN 'INT' ADD TRN-AMOUNT-TOTAL TO WS-SUM-INT
                   WHEN 'COM' ADD TRN-AMOUNT-TOTAL TO WS-SUM-COM
               END-EVALUATE
           END-PERFORM.
      *
           CLOSE TRANLOG-FILE.
           COMPUTE WS-TOTAL-PAGINAS = WS-TOTAL-REG / 15 + 1.
           IF WS-TOTAL-PAGINAS < 1
               MOVE 1 TO WS-TOTAL-PAGINAS.
       3000-EXIT.
           EXIT.
      *
       4000-MOSTRAR-PAGINA.
           COMPUTE WS-REG-DESDE =
               (WS-PAGINA - 1) * 15 + 1.
           COMPUTE WS-REG-HASTA = WS-PAGINA * 15.
           IF WS-REG-HASTA > WS-TOTAL-REG
               MOVE WS-TOTAL-REG TO WS-REG-HASTA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-REPORTE.
      *
       9000-FINALIZAR.
           CLOSE TRANLOG-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM RPTTXN00.
