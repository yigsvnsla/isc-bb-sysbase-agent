       *================================================================*
       * RPTTLR00 - REPORTE DE CUADRE DE CAJEROS                      *
       * PROPOSITO: LISTAR POR CAJERO: FONDO INICIAL, ACTUAL, CIERRE, *
       *            DEPOSITOS, RETIROS, DIFERENCIA, CUADRADO S/N     *
       * EQUIPO: VENTANILLA - 1999                                   *
       * ARCHIVOS: TELLEREC (LECTURA SECUENCIAL POR FECHA)           *
       * CALL: COMDATE                                               *
       *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RPTTLR00.
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
           SELECT TELLEREC-FILE
               ASSIGN TO 'TELLEREC.DAT'
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS TLR-ID
               FILE STATUS IS FL-TELLEREC-STATUS.
      *================================================================*
       DATA DIVISION.
       FILE SECTION.
       FD  TELLEREC-FILE
           LABEL RECORDS ARE STANDARD
           RECORD 150 CHARACTERS.
       01  TELLEREC-RECORD.
           05  TLR-ID                      PIC X(08).
           05  TLR-DATE                    PIC 9(08).
           05  TLR-BRANCH                  PIC X(04).
           05  TLR-FONDO-INICIAL           PIC 9(09)V99 COMP-3.
           05  TLR-FONDO-ACTUAL            PIC 9(09)V99 COMP-3.
           05  TLR-FONDO-CIERRE            PIC 9(09)V99 COMP-3.
           05  TLR-LIMITE-EFECTIVO         PIC 9(09)V99 COMP-3.
           05  TLR-TOTAL-DEPOSITOS         PIC 9(09)V99 COMP-3.
           05  TLR-TOTAL-RETIROS           PIC 9(09)V99 COMP-3.
           05  TLR-TOTAL-TRANSFERENCIAS    PIC 9(09)V99 COMP-3.
           05  TLR-TOTAL-PAGOS             PIC 9(09)V99 COMP-3.
           05  TLR-TOTAL-CHEQUES           PIC 9(09)V99 COMP-3.
           05  TLR-COUNT-DEPOSITOS         PIC 9(05).
           05  TLR-COUNT-RETIROS           PIC 9(05).
           05  TLR-COUNT-TRANSFERENCIAS    PIC 9(05).
           05  TLR-COUNT-PAGOS             PIC 9(05).
           05  TLR-COUNT-CHEQUES           PIC 9(05).
           05  TLR-COUNT-TOTAL             PIC 9(05).
           05  TLR-HORA-APERTURA           PIC 9(06).
           05  TLR-HORA-CIERRE             PIC 9(06).
           05  TLR-STATUS                  PIC X(01).
           05  TLR-DIFERENCIA              PIC S9(09)V99 COMP-3.
           05  TLR-CUADRADO                PIC X(01).
           05  TLR-FILLER                  PIC X(15).
      *================================================================*
       WORKING-STORAGE SECTION.
      *
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF4                VALUE 1004.
           88  WS-CRT-PF12               VALUE 1012.
      *
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-RETCODE                 PIC 99.
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-FECHA-DDMM              PIC 9(08).
           05  WS-PROGRAMA                PIC X(08) VALUE 'RPTTLR00'.
           05  WS-VERSION                 PIC X(06) VALUE 'V1.2'.
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-FECHA-REPORTE           PIC 9(08).
           05  WS-FECHA-REP-DISP          PIC 99/99/9999.
           05  WS-LINEA                   PIC 9(02) VALUE 5.
           05  WS-CONTADOR                PIC 9(02).
           05  WS-CONT-TOTAL              PIC 9(06) VALUE 0.
           05  WS-TOT-FONDO-INICIAL       PIC 9(11)V99 COMP-3.
           05  WS-TOT-FONDO-ACTUAL        PIC 9(11)V99 COMP-3.
           05  WS-TOT-FONDO-CIERRE        PIC 9(11)V99 COMP-3.
           05  WS-TOT-DEPOSITOS           PIC 9(11)V99 COMP-3.
           05  WS-TOT-RETIROS             PIC 9(11)V99 COMP-3.
           05  WS-TOT-COUNT               PIC 9(06).
           05  WS-TOT-CUADRADOS           PIC 9(06) VALUE 0.
           05  WS-TOT-DIFERENCIA          PIC S9(11)V99 COMP-3.
           05  WS-MONTO-DISP              PIC Z(8)9.99.
           05  WS-COUNT-DISP              PIC Z(5)9.
           05  WS-TOTAL-DISP              PIC Z(10)9.99.
      *
       COPY CPY-COMMON.
      *================================================================*
       SCREEN SECTION.
      *
       01  SCR-PROMPT.
           05  LINE 05  COL 10  PIC X(30)
               VALUE 'FECHA DEL REPORTE (DDMMYYYY):'.
           05  LINE 05  COL 42  PIC 99/99/9999
               USING WS-FECHA-REPORTE.
           05  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
           05  LINE 24  COL 02  PIC X(40)
               VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
      *
       01  SCR-REPORTE.
           05  SCR-CAB.
               10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - CUADRE DE CAJEROS'.
               10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
               10  LINE 02  COL 01  PIC X(80)
                   VALUE ' REPORTE DE CUADRE DE CAJEROS'.
               10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO.
               10  LINE 03  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 04  COL 01  PIC X(78)
                   VALUE 'CAJERO    F.INICIAL  F.ACTUAL   F.CIERRE   '.
               10  LINE 04  COL 42  PIC X(38)
                   VALUE 'DEPOSITOS   RETIROS    DIF    S/N'.
           05  SCR-LINEAS OCCURS 12.
               10  SCR-LIN-ID              PIC X(08).
               10  SCR-LIN-FINI            PIC Z(8)9.99.
               10  SCR-LIN-FACT            PIC Z(8)9.99.
               10  SCR-LIN-FCIE            PIC Z(8)9.99.
               10  SCR-LIN-DEP             PIC Z(8)9.99.
               10  SCR-LIN-RET             PIC Z(8)9.99.
               10  SCR-LIN-DIF             PIC Z(8)9.99.
               10  SCR-LIN-CUAD            PIC X(01).
           05  SCR-PIE.
               10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
               10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
               10  LINE 24  COL 02  PIC X(78)
                   VALUE 'PF4=IMPRIMIR  PF12=SALIR'.
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
           PERFORM 2000-PROMPT-FECHA.
           PERFORM 3000-LEER-CAJEROS.
           PERFORM 4000-MOSTRAR.
      *
           PERFORM 9000-FINALIZAR.
           GOBACK.
      *
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW'
                                WS-FECHA
                                WS-HORA.
           MOVE WS-FECHA TO WS-FECHA-DDMM
                           WS-FECHA-REPORTE.
           MOVE 0 TO WS-CONTADOR WS-CONT-TOTAL
                      WS-TOT-FONDO-INICIAL
                      WS-TOT-FONDO-ACTUAL
                      WS-TOT-FONDO-CIERRE
                      WS-TOT-DEPOSITOS
                      WS-TOT-RETIROS
                      WS-TOT-COUNT
                      WS-TOT-CUADRADOS
                      WS-TOT-DIFERENCIA.
           PERFORM 1100-LIMPIAR.
      *
       1100-LIMPIAR.
           DISPLAY SPACES UPON CRT.
      *
       2000-PROMPT-FECHA.
           DISPLAY SCR-PROMPT.
           ACCEPT SCR-PROMPT.
           MOVE WS-FECHA-REPORTE TO WS-FECHA-REP-DISP.
      *
       3000-LEER-CAJEROS.
           OPEN INPUT TELLEREC-FILE.
           IF FL-TELLEREC-STATUS NOT = '00'
               MOVE 'ERROR AL ABRIR TELLEREC' TO WS-MENSAJE-ERROR
               GOTO 3000-EXIT.
           MOVE 'N' TO WS-EOF-YES.
           MOVE LOW-VALUES TO TLR-ID.
           START TELLEREC-FILE KEY IS GREATER THAN TLR-ID
               INVALID KEY MOVE 'Y' TO WS-EOF-YES.
           PERFORM UNTIL WS-EOF-YES
               READ TELLEREC-FILE NEXT RECORD
                   AT END MOVE 'Y' TO WS-EOF-YES
                   EXIT PERFORM
               END-READ
               IF TLR-DATE NOT = WS-FECHA-REPORTE
                   EXIT PERFORM CYCLE
               END-IF
               ADD 1 TO WS-CONT-TOTAL
               ADD TLR-FONDO-INICIAL TO WS-TOT-FONDO-INICIAL
               ADD TLR-FONDO-ACTUAL TO WS-TOT-FONDO-ACTUAL
               ADD TLR-FONDO-CIERRE TO WS-TOT-FONDO-CIERRE
               ADD TLR-TOTAL-DEPOSITOS TO WS-TOT-DEPOSITOS
               ADD TLR-TOTAL-RETIROS TO WS-TOT-RETIROS
               ADD TLR-DIFERENCIA TO WS-TOT-DIFERENCIA
               ADD TLR-COUNT-TOTAL TO WS-TOT-COUNT
               IF TLR-CUADRADO = 'S'
                   ADD 1 TO WS-TOT-CUADRADOS
               END-IF
           END-PERFORM.
           CLOSE TELLEREC-FILE.
       3000-EXIT.
           EXIT.
      *
       4000-MOSTRAR.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-REPORTE.
           MOVE WS-CONT-TOTAL TO WS-COUNT-DISP.
           STRING 'TOTAL CAJEROS: ' WS-CONT-TOTAL
                  '  CUADRADOS: ' WS-TOT-CUADRADOS
             INTO WS-MENSAJE.
      *
       9000-FINALIZAR.
           CLOSE TELLEREC-FILE.
           MOVE 0 TO LS-RETCODE.
      *
       END PROGRAM RPTTLR00.
