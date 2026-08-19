      *================================================================*
      * ADMLOG00 - VISOR DE LOGS DEL SISTEMA                          *
      * EQUIPO: SOPORTE TECNICO - 2003                                 *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADMLOG00.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF7                VALUE 1007.
           88  WS-CRT-PF8                VALUE 1008.
           88  WS-CRT-PF12               VALUE 1012.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'ADMLOG00'.
       01  WS-LOG-TABLE.
           05  WS-LOG-ENTRY               OCCURS 18.
               10  WS-L-TIMESTAMP         PIC X(20).
               10  WS-L-SEVERITY          PIC X(01).
               10  WS-L-MODULE            PIC X(08).
               10  WS-L-MESSAGE           PIC X(40).
       01  WS-LOG-ENTRIES.
           05  WS-LOG-DATA                OCCURS 200.
               10  WS-LD-TS               PIC X(20).
               10  WS-LD-SEV              PIC X(01).
               10  WS-LD-MOD              PIC X(08).
               10  WS-LD-MSG              PIC X(40).
       01  WS-LOG-COUNT                   PIC 9(03) VALUE 0.
       01  WS-LOG-INDEX                   PIC 9(03).
       01  WS-LOG-PAGE                    PIC 9(02) VALUE 1.
       01  WS-LOG-MAX-PAGE                PIC 9(02).
       01  WS-LOG-TOTAL                   PIC 9(03).
       01  WS-J                           PIC 9(03).
       01  WS-I                           PIC 9(03).
       SCREEN SECTION.
       01  SCR-LOG.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - LOGS DEL SISTEMA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 03  COL 02  PIC X(60)
               VALUE 'TIMESTAMP           S  MODULO    MENSAJE'.
           05  SCR-LOG-LINES OCCURS 18.
               10  SCR-L-TS   PIC X(20) FROM WS-L-TIMESTAMP.
               10  SCR-L-SEV  PIC X(01) FROM WS-L-SEVERITY.
               10  SCR-L-MOD  PIC X(08) FROM WS-L-MODULE.
               10  SCR-L-MSG  PIC X(40) FROM WS-L-MESSAGE.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'PF7=PAG-ANT  PF8=PAG-SIG  PF12=RETORNAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
           PERFORM 1100-GENERAR-LOGS.
           MOVE 1 TO WS-LOG-PAGE.
           PERFORM 3000-CARGAR.
           PERFORM 2000-PANTALLA.
           ACCEPT SCR-LOG.
       0100-LISTADO.
           IF WS-CRT-PF7 AND WS-LOG-PAGE > 1
               SUBTRACT 1 FROM WS-LOG-PAGE
               PERFORM 3000-CARGAR
               GO TO 0100-LISTADO.
           IF WS-CRT-PF8 AND WS-LOG-PAGE < WS-LOG-MAX-PAGE
               ADD 1 TO WS-LOG-PAGE
               PERFORM 3000-CARGAR
               GO TO 0100-LISTADO.
           IF WS-CRT-PF12 GO TO 9000-EXIT.
           GO TO 0100-LISTADO.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       1100-GENERAR-LOGS.
           MOVE 0 TO WS-I.
           MOVE '20260701 08:15:30' TO WS-LD-TS(1).
           MOVE 'I' TO WS-LD-SEV(1). MOVE 'BNK0001' TO WS-LD-MOD(1).
           MOVE 'LOGIN EXITOSO ADMIN' TO WS-LD-MSG(1).
           MOVE '20260701 08:20:15' TO WS-LD-TS(2).
           MOVE 'W' TO WS-LD-SEV(2). MOVE 'SECUSR00' TO WS-LD-MOD(2).
           MOVE 'INTENTO FALLIDO USR' TO WS-LD-MSG(2).
           MOVE '20260701 09:00:00' TO WS-LD-TS(3).
           MOVE 'I' TO WS-LD-SEV(3). MOVE 'CRDINQ00' TO WS-LD-MOD(3).
           MOVE 'CONSULTA TARJETA OK' TO WS-LD-MSG(3).
           MOVE '20260701 09:15:45' TO WS-LD-TS(4).
           MOVE 'E' TO WS-LD-SEV(4). MOVE 'CRDBLK00' TO WS-LD-MOD(4).
           MOVE 'TARJETA NO ENCONTRADA' TO WS-LD-MSG(4).
           MOVE '20260701 10:30:00' TO WS-LD-TS(5).
           MOVE 'I' TO WS-LD-SEV(5). MOVE 'ADMPAR00' TO WS-LD-MOD(5).
           MOVE 'PARAMETRO TASA ACTUALIZADO' TO WS-LD-MSG(5).
           MOVE '20260701 11:00:22' TO WS-LD-TS(6).
           MOVE 'C' TO WS-LD-SEV(6). MOVE 'CRDLMT00' TO WS-LD-MOD(6).
           MOVE 'LIMITE ACTUALIZADO SUPV' TO WS-LD-MSG(6).
           MOVE '20260701 12:45:10' TO WS-LD-TS(7).
           MOVE 'I' TO WS-LD-SEV(7). MOVE 'CRDPIN00' TO WS-LD-MOD(7).
           MOVE 'CAMBIO PIN REALIZADO' TO WS-LD-MSG(7).
           MOVE '20260701 14:00:00' TO WS-LD-TS(8).
           MOVE 'W' TO WS-LD-SEV(8). MOVE 'CRDMOV00' TO WS-LD-MOD(8).
           MOVE 'TRANSACCION ALTA' TO WS-LD-MSG(8).
           MOVE '20260701 15:30:30' TO WS-LD-TS(9).
           MOVE 'I' TO WS-LD-SEV(9). MOVE 'ADMBRH00' TO WS-LD-MOD(9).
           MOVE 'SUCURSAL 0001 ACTUALIZADA' TO WS-LD-MSG(9).
           MOVE '20260701 16:00:00' TO WS-LD-TS(10).
           MOVE 'E' TO WS-LD-SEV(10). MOVE 'ADMAUD00' TO WS-LD-MOD(10).
           MOVE 'ERROR DE ARCHIVO' TO WS-LD-MSG(10).
           MOVE '20260701 16:45:12' TO WS-LD-TS(11).
           MOVE 'I' TO WS-LD-SEV(11). MOVE 'CRDREP00' TO WS-LD-MOD(11).
           MOVE 'REEMPLAZO EXITOSO' TO WS-LD-MSG(11).
           MOVE '20260701 17:30:00' TO WS-LD-TS(12).
           MOVE 'I' TO WS-LD-SEV(12). MOVE 'CRDALR00' TO WS-LD-MOD(12).
           MOVE 'ALERTA TRANSACCION > $5000' TO WS-LD-MSG(12).
           MOVE '20260701 18:00:00' TO WS-LD-TS(13).
           MOVE 'W' TO WS-LD-SEV(13). MOVE 'ADMROL00' TO WS-LD-MOD(13).
           MOVE 'PERMISO AGREGADO A ROL' TO WS-LD-MSG(13).
           MOVE '20260701 19:00:00' TO WS-LD-TS(14).
           MOVE 'I' TO WS-LD-SEV(14). MOVE 'ADMLOG00' TO WS-LD-MOD(14).
           MOVE 'CONSULTA DE LOGS' TO WS-LD-MSG(14).
           MOVE 14 TO WS-LOG-COUNT.
       2000-PANTALLA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-LOG.
       3000-CARGAR.
           MOVE 1 TO WS-J.
           COMPUTE WS-LOG-MAX-PAGE = (WS-LOG-COUNT / 18) + 1.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LOG-COUNT
               IF WS-I > ((WS-LOG-PAGE - 1) * 18)
                   AND WS-I <= (WS-LOG-PAGE * 18)
                   MOVE WS-LD-TS(WS-I) TO WS-L-TIMESTAMP(WS-J)
                   MOVE WS-LD-SEV(WS-I) TO WS-L-SEVERITY(WS-J)
                   MOVE WS-LD-MOD(WS-I) TO WS-L-MODULE(WS-J)
                   MOVE WS-LD-MSG(WS-I) TO WS-L-MESSAGE(WS-J)
                   ADD 1 TO WS-J
               END-IF.
           STRING 'LOGS: ' WS-LOG-COUNT ' PAG ' WS-LOG-PAGE
                  ' DE ' WS-LOG-MAX-PAGE INTO WS-MENSAJE.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM ADMLOG00.
