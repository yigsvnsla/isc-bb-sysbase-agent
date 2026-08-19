       *================================================================*
       * BNK0020 - HISTORIAL DE MOVIMIENTOS / TRANSACTION VIEWER        *
       * PROPOSITO: CONSULTAR BITACORA DE TRANSACCIONES CON FILTROS    *
       * EQUIPO: SISTEMAS INFORMACION - 2005                           *
       * ARCHIVOS: TRANLOG (INDEXADO POR TRN-SEQ)                      *
       * CARACTERISTICAS: FILTROS, PAGINACION, DETALLE, EXPORTACION    *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. BNK0020.
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
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS TRN-SEQ
                FILE STATUS IS FL-TRANLOG-STATUS.
       *
            SELECT SPOOL-FILE
                ASSIGN TO 'BNK0020.RPT'
                ORGANIZATION IS LINE SEQUENTIAL
                FILE STATUS IS WS-SPOOL-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  TRANLOG-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TRANLOG REPLACING TRANLOG-FILE BY TRANLOG-FILE
                TRANLOG-RECORD BY TRANLOG-RECORD.
       *
        FD  SPOOL-FILE
            RECORD 150 CHARACTERS.
        01  SPOOL-RECORD                   PIC X(150).
       *================================================================*
        WORKING-STORAGE SECTION.
        COPY CPY-COMMON.
        COPY CPY-SCREEN.
       *
        01  WS-CRT-STATUS                  PIC 9(04).
            88  WS-CRT-PF3                VALUE 1003.
            88  WS-CRT-PF4                VALUE 1004.
            88  WS-CRT-PF5                VALUE 1005.
            88  WS-CRT-PF7                VALUE 1007.
            88  WS-CRT-PF8                VALUE 1008.
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-ENTER              VALUE 0013.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-SPOOL-STATUS                PIC X(02).
            88  WS-SPOOL-OK               VALUE '00'.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
       *
       *--- FILTROS ---*
            05  WS-FILTRO-ACCOUNT          PIC X(10).
            05  WS-FILTRO-FECHA-DESDE      PIC 9(08).
            05  WS-FILTRO-FECHA-HASTA      PIC 9(08).
            05  WS-FILTRO-TIPO             PIC X(03).
            05  WS-FILTRO-TIPO-DISP        PIC X(03).
            05  WS-FILTRO-CHANNEL          PIC X(02).
            05  WS-FILTRO-CHANNEL-DISP     PIC X(02).
            05  WS-FILTRO-BRANCH           PIC X(04).
            05  WS-FILTRO-MONTO-MIN        PIC S9(13)V99 COMP-3.
            05  WS-FILTRO-MONTO-MIN-DISP   PIC Z(12)9.99.
            05  WS-FILTRO-MONTO-MAX        PIC S9(13)V99 COMP-3.
            05  WS-FILTRO-MONTO-MAX-DISP   PIC Z(12)9.99.
       *
       *--- VARIABLES DE NAVEGACION ---*
            05  WS-PAGINA-ACTUAL           PIC 9(04).
            05  WS-PAGINA-TOTAL            PIC 9(04).
            05  WS-REG-POR-PAGINA          PIC 9(02) VALUE 20.
            05  WS-REG-EN-PAGINA           PIC 9(02).
            05  WS-REG-TOTAL               PIC 9(06).
            05  WS-REG-DESDE               PIC 9(06).
            05  WS-REG-HASTA               PIC 9(06).
            05  WS-REG-LEIDOS              PIC 9(06).
            05  WS-REG-FILTRADOS           PIC 9(06).
            05  WS-REG-MOSTRADOS           PIC 9(02).
            05  WS-I                        PIC 9(02).
            05  WS-J                        PIC 9(02).
            05  WS-K                        PIC 9(02).
            05  WS-IDX                      PIC 9(02).
            05  WS-SELECCION                PIC 9(02).
            05  WS-SELECCION-DISP           PIC 9(02).
            05  WS-TIPO-DESC                PIC X(15).
            05  WS-CHANNEL-DESC             PIC X(15).
            05  WS-MONTO-DISP               PIC Z(12)9.99.
            05  WS-MONTO-TAX-DISP           PIC Z(08)9.99.
            05  WS-FEE-DISP                 PIC Z(08)9.99.
       *
       *--- TABLA DE TRANSACCIONES EN PANTALLA ---*
            05  WS-TRANS-TABLE.
                10  WS-TRANS-ENTRY         OCCURS 20.
                    15  WS-TRN-IDX         PIC 9(10).
                    15  WS-TRN-FECHA       PIC 9(08).
                    15  WS-TRN-HORA        PIC 9(06).
                    15  WS-TRN-TIPO        PIC X(03).
                    15  WS-TRN-CUENTA      PIC X(10).
                    15  WS-TRN-DESC        PIC X(30).
                    15  WS-TRN-MONTO       PIC S9(13)V99 COMP-3.
                    15  WS-TRN-FEE         PIC S9(07)V99 COMP-3.
                    15  WS-TRN-TOTAL       PIC S9(13)V99 COMP-3.
                    15  WS-TRN-STATUS      PIC X(01).
       *
       *--- VARIABLES DE DETALLE ---*
            05  WS-DETALLE-ACTIVO          PIC X(01).
                88  WS-VER-DETALLE         VALUE 'S'.
                88  WS-NO-VER-DETALLE      VALUE 'N'.
            05  WS-DETALLE-SEQ             PIC 9(10).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'BNK0020'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
        01  WS-TIPO-TABLE.
            05  FILLER PIC X(03) VALUE 'DEP'.
            05  FILLER PIC X(03) VALUE 'RET'.
            05  FILLER PIC X(03) VALUE 'TRF'.
            05  FILLER PIC X(03) VALUE 'PAG'.
            05  FILLER PIC X(03) VALUE 'CHQ'.
            05  FILLER PIC X(03) VALUE 'INT'.
            05  FILLER PIC X(03) VALUE 'COM'.
            05  FILLER PIC X(03) VALUE 'AJU'.
            05  FILLER PIC X(03) VALUE 'APE'.
            05  FILLER PIC X(03) VALUE 'CIE'.
       *
        01  WS-TIPO-TAB-REDEF
            REDEFINES WS-TIPO-TABLE.
            05  WS-TIPO-ENTRY              PIC X(03)
                OCCURS 10.
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-FILTROS.
            05  SCR-CAB.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - HISTORIAL DE MOVIMIENTOS'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' PANTALLA DE FILTROS - INGRESE CRITERIOS'.
       *
            05  SCR-FILTROS-CUERPO.
                10  LINE 04  COL 05  PIC X(20) VALUE 'CUENTA:'.
                10  LINE 04  COL 15  PIC X(10)
                   USING WS-FILTRO-ACCOUNT AUTO PROMPT '__________'.
       *
                10  LINE 05  COL 05  PIC X(20) VALUE 'FECHA DESDE:'.
                10  LINE 05  COL 20  PIC 9(08)
                   USING WS-FILTRO-FECHA-DESDE AUTO PROMPT '________'.
                10  LINE 05  COL 35  PIC X(20) VALUE 'FECHA HASTA:'.
                10  LINE 05  COL 50  PIC 9(08)
                   USING WS-FILTRO-FECHA-HASTA AUTO PROMPT '________'.
       *
                10  LINE 06  COL 05  PIC X(20) VALUE 'TIPO TRANS:'.
                10  LINE 06  COL 20  PIC X(03)
                   USING WS-FILTRO-TIPO-DISP AUTO PROMPT '___'.
                10  LINE 06  COL 28  PIC X(50)
                   VALUE '(DEP/RET/TRF/PAG/CHQ/INT/COM/AAA=TODOS)'.
       *
                10  LINE 07  COL 05  PIC X(20) VALUE 'CANAL:'.
                10  LINE 07  COL 15  PIC X(02)
                   USING WS-FILTRO-CHANNEL-DISP AUTO PROMPT '__'.
                10  LINE 07  COL 22  PIC X(50)
                   VALUE '(01=VENT 02=CAJ 03=WEB 04=BAT 00=TODOS)'.
       *
                10  LINE 08  COL 05  PIC X(20) VALUE 'SUCURSAL:'.
                10  LINE 08  COL 18  PIC X(04)
                   USING WS-FILTRO-BRANCH AUTO PROMPT '____'.
       *
                10  LINE 09  COL 05  PIC X(20) VALUE 'MONTO MIN:'.
                10  LINE 09  COL 18  PIC Z(12)9.99
                   USING WS-FILTRO-MONTO-MIN-DISP AUTO PROMPT
                   '____________.__'.
                10  LINE 09  COL 45  PIC X(20) VALUE 'MONTO MAX:'.
                10  LINE 09  COL 58  PIC Z(12)9.99
                   USING WS-FILTRO-MONTO-MAX-DISP AUTO PROMPT
                   '____________.__'.
       *
            05  SCR-FILTROS-MSG.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-FILTROS-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(70)
                   VALUE 'ENTER=CONSULTAR  PF12=SALIR'.
       *
        01  SCR-RESULTADOS.
            05  SCR-RES-CAB.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - MOVIMIENTOS'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' #   FECHA    HORA   TIPO  CUENTA     DESCRIPCIO
      -    'N       MONTO     COMIS    TOTAL  EST'.
       *
            05  SCR-RES-LINEAS OCCURS 20.
                10  LINE-PLUS-3            PIC 9(02) FROM WS-TRN-IDX(WS-I).
                10  LINE-PLUS-3            PIC 9(08) FROM WS-TRN-FECHA(WS-I).
                10  LINE-PLUS-3            PIC 9(06) FROM WS-TRN-HORA(WS-I).
                10  LINE-PLUS-3            PIC X(03) FROM WS-TRN-TIPO(WS-I).
                10  LINE-PLUS-3            PIC X(10) FROM WS-TRN-CUENTA(WS-I).
                10  LINE-PLUS-3            PIC X(30) FROM WS-TRN-DESC(WS-I).
                10  LINE-PLUS-3            PIC Z(12)9.99
                   FROM WS-TRN-MONTO(WS-I).
                10  LINE-PLUS-3            PIC Z(08)9.99
                   FROM WS-TRN-FEE(WS-I).
                10  LINE-PLUS-3            PIC Z(12)9.99
                   FROM WS-TRN-TOTAL(WS-I).
                10  LINE-PLUS-3            PIC X(01) FROM WS-TRN-STATUS(WS-I).
       *
            05  SCR-RES-STATUS.
                10  LINE 23  COL 01  PIC X(30) FROM WS-MENSAJE.
                10  LINE 23  COL 50  PIC X(30) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-RES-PIE.
                10  LINE 24  COL 05  PIC X(75)
                   VALUE 'PF3=DETALLE  PF4=IMPRIMIR  PF5=EXPORTAR  PF7=PAG
      -    ' ANT  PF8=PAG SIG  PF12=SALIR'.
       *
        01  SCR-DETALLE.
            05  SCR-DET-CAB.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - DETALLE DE TRANSACCION'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
       *
            05  SCR-DET-CUERPO.
                10  LINE 03  COL 05  PIC X(15) VALUE 'SECUENCIA:'.
                10  LINE 03  COL 20  PIC 9(10) FROM TRN-SEQ.
                10  LINE 04  COL 05  PIC X(15) VALUE 'FECHA:'.
                10  LINE 04  COL 15  PIC 9(08) FROM TRN-DATE.
                10  LINE 04  COL 30  PIC X(15) VALUE 'HORA:'.
                10  LINE 04  COL 40  PIC 9(06) FROM TRN-TIME.
       *
                10  LINE 05  COL 05  PIC X(15) VALUE 'TIPO:'.
                10  LINE 05  COL 15  PIC X(03) FROM TRN-TYPE.
                10  LINE 05  COL 30  PIC X(15) VALUE 'CUENTA:'.
                10  LINE 05  COL 45  PIC X(10) FROM TRN-ACCOUNT-NBR.
       *
                10  LINE 06  COL 05  PIC X(15) VALUE 'CTA DESTINO:'.
                10  LINE 06  COL 20  PIC X(10) FROM TRN-ACCOUNT-DEST.
                10  LINE 06  COL 40  PIC X(15) VALUE 'CLIENTE:'.
                10  LINE 06  COL 55  PIC X(10) FROM TRN-CUSTOMER-ID.
       *
                10  LINE 07  COL 05  PIC X(15) VALUE 'MONTO:'.
                10  LINE 07  COL 15  PIC Z(12)9.99 FROM TRN-AMOUNT.
                10  LINE 07  COL 35  PIC X(15) VALUE 'IMPUESTO:'.
                10  LINE 07  COL 50  PIC Z(08)9.99 FROM TRN-AMOUNT-TAX.
                10  LINE 08  COL 05  PIC X(15) VALUE 'TOTAL:'.
                10  LINE 08  COL 15  PIC Z(12)9.99 FROM TRN-AMOUNT-TOTAL.
                10  LINE 08  COL 35  PIC X(15) VALUE 'COMISION:'.
                10  LINE 08  COL 50  PIC Z(08)9.99 FROM TRN-FEE-AMOUNT.
       *
                10  LINE 09  COL 05  PIC X(15) VALUE 'ORIGEN:'.
                10  LINE 09  COL 15  PIC X(04) FROM TRN-BRANCH.
                10  LINE 09  COL 25  PIC X(15) VALUE 'CAJERO:'.
                10  LINE 09  COL 40  PIC X(08) FROM TRN-TELLER-ID.
                10  LINE 09  COL 55  PIC X(15) VALUE 'USUARIO:'.
                10  LINE 09  COL 70  PIC X(08) FROM TRN-USER-ID.
       *
                10  LINE 10  COL 05  PIC X(15) VALUE 'CANAL:'.
                10  LINE 10  COL 15  PIC X(02) FROM TRN-CHANNEL.
                10  LINE 10  COL 25  PIC X(15) VALUE 'TERMINAL:'.
                10  LINE 10  COL 40  PIC X(08) FROM TRN-TERMINAL.
       *
                10  LINE 11  COL 05  PIC X(15) VALUE 'REFERENCIA:'.
                10  LINE 11  COL 20  PIC X(20) FROM TRN-REFERENCE.
       *
                10  LINE 12  COL 05  PIC X(15) VALUE 'CHEQUE N:'.
                10  LINE 12  COL 20  PIC 9(10) FROM TRN-CHQ-NBR.
                10  LINE 12  COL 35  PIC X(15) VALUE 'BANCO:'.
                10  LINE 12  COL 50  PIC X(10) FROM TRN-CHQ-BANK.
       *
                10  LINE 13  COL 05  PIC X(15) VALUE 'STATUS:'.
                10  LINE 13  COL 15  PIC X(01) FROM TRN-STATUS.
                10  LINE 13  COL 25  PIC X(15) VALUE 'REVERSA:'.
                10  LINE 13  COL 40  PIC 9(10) FROM TRN-REVERSE-SEQ.
       *
                10  LINE 14  COL 05  PIC X(15) VALUE 'DESCRIPCION:'.
                10  LINE 14  COL 20  PIC X(30) FROM TRN-DESCRIPTION.
       *
            05  SCR-DET-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(40)
                   VALUE 'PF3=REGRESAR A LISTA  PF12=SALIR'.
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
            MOVE SPACES TO WS-USUARIO WS-MENSAJE WS-MENSAJE-ERROR.
            MOVE LS-USUARIO TO WS-USUARIO.
            MOVE 99 TO LS-RETCODE.
       *
            PERFORM 1000-INICIALIZAR.
            PERFORM 2000-MOSTRAR-FILTROS.
            IF WS-RETCODE = 99
                GOTO MAIN-EXIT
            END-IF.
       *
            PERFORM 3000-EJECUTAR-CONSULTA.
            IF WS-RETCODE = 00
                PERFORM 4000-MOSTRAR-RESULTADOS
            END-IF.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            DISPLAY SPACES UPON CRT.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE SPACES TO WS-FILTRO-ACCOUNT
                           WS-FILTRO-TIPO-DISP
                           WS-FILTRO-CHANNEL-DISP
                           WS-FILTRO-BRANCH.
            MOVE ZERO TO WS-FILTRO-FECHA-DESDE
                         WS-FILTRO-FECHA-HASTA
                         WS-FILTRO-MONTO-MIN
                         WS-FILTRO-MONTO-MIN-DISP
                         WS-FILTRO-MONTO-MAX
                         WS-FILTRO-MONTO-MAX-DISP.
            MOVE 'INGRESE FILTROS PARA LA CONSULTA' TO WS-MENSAJE.
            MOVE 'AAA' TO WS-FILTRO-TIPO-DISP.
            MOVE '00' TO WS-FILTRO-CHANNEL-DISP.
            MOVE 0 TO WS-PAGINA-ACTUAL.
            MOVE 20 TO WS-REG-POR-PAGINA.
            OPEN INPUT TRANLOG-FILE.
       *
        2000-MOSTRAR-FILTROS.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            DISPLAY SCR-FILTROS.
            ACCEPT SCR-FILTROS.
       *
            IF WS-CRT-PF12
                MOVE 99 TO WS-RETCODE
                GOTO 2000-EXIT
            END-IF.
       *
            IF WS-CRT-CLEAR
                MOVE SPACES TO WS-FILTRO-ACCOUNT
                               WS-FILTRO-TIPO-DISP
                               WS-FILTRO-CHANNEL-DISP
                               WS-FILTRO-BRANCH
                               WS-MENSAJE WS-MENSAJE-ERROR
                MOVE ZERO TO WS-FILTRO-FECHA-DESDE
                             WS-FILTRO-FECHA-HASTA
                             WS-FILTRO-MONTO-MIN
                             WS-FILTRO-MONTO-MIN-DISP
                             WS-FILTRO-MONTO-MAX
                             WS-FILTRO-MONTO-MAX-DISP
                GO TO 2000-MOSTRAR-FILTROS
            END-IF.
       *
            IF WS-CRT-ENTER
                MOVE 00 TO WS-RETCODE
                PERFORM 2200-ASIGNAR-FILTROS
                GOTO 2000-EXIT
            END-IF.
       *
            GO TO 2000-MOSTRAR-FILTROS.
       *
        2000-EXIT.
            EXIT.
       *
        2100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        2200-ASIGNAR-FILTROS.
            MOVE WS-FILTRO-TIPO-DISP TO WS-FILTRO-TIPO.
            MOVE WS-FILTRO-CHANNEL-DISP TO WS-FILTRO-CHANNEL.
            MOVE WS-FILTRO-MONTO-MIN-DISP TO WS-FILTRO-MONTO-MIN.
            MOVE WS-FILTRO-MONTO-MAX-DISP TO WS-FILTRO-MONTO-MAX.
       *
        3000-EJECUTAR-CONSULTA.
            MOVE 0 TO WS-REG-LEIDOS
                       WS-REG-FILTRADOS
                       WS-REG-TOTAL
                       WS-PAGINA-TOTAL.
       *
            MOVE ZERO TO TRN-SEQ.
            START TRANLOG-FILE KEY NOT < TRN-SEQ
                INVALID KEY
                    MOVE 'NO HAY REGISTROS EN TRANLOG'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 3000-EXIT
            END-START.
       *
            PERFORM UNTIL WS-REG-LEIDOS > 999999
                READ TRANLOG-FILE NEXT RECORD
                    AT END
                        EXIT PERFORM
                END-READ
       *
                ADD 1 TO WS-REG-LEIDOS
       *
                PERFORM 3100-APLICAR-FILTROS
                IF WS-SWITCH-FOUND = 'Y'
                    ADD 1 TO WS-REG-FILTRADOS
                    PERFORM 3200-GUARDAR-EN-TABLA
                END-IF
            END-PERFORM.
       *
            MOVE WS-REG-FILTRADOS TO WS-REG-TOTAL.
            COMPUTE WS-PAGINA-TOTAL =
                (WS-REG-TOTAL + WS-REG-POR-PAGINA - 1)
                / WS-REG-POR-PAGINA.
            IF WS-PAGINA-TOTAL = 0
                MOVE 1 TO WS-PAGINA-TOTAL
            END-IF.
            MOVE 1 TO WS-PAGINA-ACTUAL.
       *
            IF WS-REG-TOTAL = 0
                MOVE 'NO SE ENCONTRARON REGISTROS CON ESOS FILTROS'
                  TO WS-MENSAJE-ERROR
                MOVE 99 TO LS-RETCODE
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE 00 TO LS-RETCODE.
            MOVE 'CONSULTA EXITOSA' TO WS-MENSAJE.
       *
        3000-EXIT.
            EXIT.
       *
        3100-APLICAR-FILTROS.
            MOVE 'Y' TO WS-SWITCH-FOUND.
       *
            IF WS-FILTRO-ACCOUNT NOT = SPACES
                IF TRN-ACCOUNT-NBR NOT = WS-FILTRO-ACCOUNT
                    MOVE 'N' TO WS-SWITCH-FOUND
                    GOTO 3100-EXIT
                END-IF
            END-IF.
       *
            IF WS-FILTRO-FECHA-DESDE NOT = ZERO
                IF TRN-DATE < WS-FILTRO-FECHA-DESDE
                    MOVE 'N' TO WS-SWITCH-FOUND
                    GOTO 3100-EXIT
                END-IF
            END-IF.
       *
            IF WS-FILTRO-FECHA-HASTA NOT = ZERO
                IF TRN-DATE > WS-FILTRO-FECHA-HASTA
                    MOVE 'N' TO WS-SWITCH-FOUND
                    GOTO 3100-EXIT
                END-IF
            END-IF.
       *
            IF WS-FILTRO-TIPO NOT = 'AAA'
                IF TRN-TYPE NOT = WS-FILTRO-TIPO
                    MOVE 'N' TO WS-SWITCH-FOUND
                    GOTO 3100-EXIT
                END-IF
            END-IF.
       *
            IF WS-FILTRO-CHANNEL NOT = '00'
                IF TRN-CHANNEL NOT = WS-FILTRO-CHANNEL
                    MOVE 'N' TO WS-SWITCH-FOUND
                    GOTO 3100-EXIT
                END-IF
            END-IF.
       *
            IF WS-FILTRO-BRANCH NOT = SPACES
                IF TRN-BRANCH NOT = WS-FILTRO-BRANCH
                    MOVE 'N' TO WS-SWITCH-FOUND
                    GOTO 3100-EXIT
                END-IF
            END-IF.
       *
            IF WS-FILTRO-MONTO-MIN NOT = ZERO
                IF TRN-AMOUNT < WS-FILTRO-MONTO-MIN
                    MOVE 'N' TO WS-SWITCH-FOUND
                    GOTO 3100-EXIT
                END-IF
            END-IF.
       *
            IF WS-FILTRO-MONTO-MAX NOT = ZERO
                IF TRN-AMOUNT > WS-FILTRO-MONTO-MAX
                    MOVE 'N' TO WS-SWITCH-FOUND
                    GOTO 3100-EXIT
                END-IF
            END-IF.
       *
        3100-EXIT.
            EXIT.
       *
        3200-GUARDAR-EN-TABLA.
            IF WS-REG-FILTRADOS > 999999
                GOTO 3200-EXIT
            END-IF.
       *
            COMPUTE WS-IDX =
                FUNCTION MOD(WS-REG-FILTRADOS - 1, 20) + 1.
       *
            MOVE TRN-SEQ TO WS-TRN-IDX(WS-IDX).
            MOVE TRN-DATE TO WS-TRN-FECHA(WS-IDX).
            MOVE TRN-TIME TO WS-TRN-HORA(WS-IDX).
            MOVE TRN-TYPE TO WS-TRN-TIPO(WS-IDX).
            MOVE TRN-ACCOUNT-NBR TO WS-TRN-CUENTA(WS-IDX).
            MOVE TRN-DESCRIPTION TO WS-TRN-DESC(WS-IDX).
            MOVE TRN-AMOUNT TO WS-TRN-MONTO(WS-IDX).
            MOVE TRN-FEE-AMOUNT TO WS-TRN-FEE(WS-IDX).
            MOVE TRN-AMOUNT-TOTAL TO WS-TRN-TOTAL(WS-IDX).
            MOVE TRN-STATUS TO WS-TRN-STATUS(WS-IDX).
       *
        3200-EXIT.
            EXIT.
       *
        4000-MOSTRAR-RESULTADOS.
            MOVE 1 TO WS-PAGINA-ACTUAL.
       *
        4100-PAGINA-LOOP.
            PERFORM 5000-CARGAR-PAGINA.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
       *
            PERFORM 5100-DESPLIEGA-LINEAS.
       *
            STRING 'PAG ' WS-PAGINA-ACTUAL ' DE '
                   WS-PAGINA-TOTAL '  REG: ' WS-REG-TOTAL
              INTO WS-MENSAJE.
       *
            DISPLAY SCR-RESULTADOS.
            ACCEPT SCR-RESULTADOS.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF3
                    PERFORM 6000-VER-DETALLE
                    GO TO 4100-PAGINA-LOOP
       *
                WHEN WS-CRT-PF4
                    PERFORM 7000-IMPRIMIR
                    GO TO 4100-PAGINA-LOOP
       *
                WHEN WS-CRT-PF5
                    PERFORM 8000-EXPORTAR
                    GO TO 4100-PAGINA-LOOP
       *
                WHEN WS-CRT-PF7
                    IF WS-PAGINA-ACTUAL > 1
                        SUBTRACT 1 FROM WS-PAGINA-ACTUAL
                    ELSE
                        MOVE 'YA ESTA EN PRIMERA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO 4100-PAGINA-LOOP
       *
                WHEN WS-CRT-PF8
                    IF WS-PAGINA-ACTUAL < WS-PAGINA-TOTAL
                        ADD 1 TO WS-PAGINA-ACTUAL
                    ELSE
                        MOVE 'YA ESTA EN ULTIMA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO 4100-PAGINA-LOOP
       *
                WHEN WS-CRT-PF12
                    GOTO 4000-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO 4100-PAGINA-LOOP
       *
                WHEN OTHER
                    GO TO 4100-PAGINA-LOOP
            END-EVALUATE.
       *
        4000-EXIT.
            EXIT.
       *
        5000-CARGAR-PAGINA.
            MOVE 0 TO WS-REG-MOSTRADOS.
            COMPUTE WS-REG-DESDE =
                (WS-PAGINA-ACTUAL - 1) * WS-REG-POR-PAGINA + 1.
            COMPUTE WS-REG-HASTA =
                WS-REG-DESDE + WS-REG-POR-PAGINA - 1.
            IF WS-REG-HASTA > WS-REG-TOTAL
                MOVE WS-REG-TOTAL TO WS-REG-HASTA
            END-IF.
       *
            MOVE 0 TO WS-I.
            MOVE 1 TO WS-K.
       *
            COMPUTE WS-IDX = FUNCTION MOD(WS-REG-DESDE - 1, 20) + 1.
            MOVE WS-REG-DESDE TO WS-K.
            MOVE 0 TO WS-REG-MOSTRADOS.
       *
        5100-DESPLIEGA-LINEAS.
            MOVE 3 TO WS-K.
            COMPUTE WS-IDX =
                FUNCTION MOD(WS-REG-DESDE - 1, 20) + 1.
            MOVE WS-REG-DESDE TO WS-I.
       *
            PERFORM UNTIL WS-I > WS-REG-HASTA
                MOVE WS-TRN-IDX(WS-IDX) TO WS-SELECCION
                MOVE WS-TRN-FECHA(WS-IDX) TO WS-SELECCION
                MOVE WS-TRN-HORA(WS-IDX) TO WS-SELECCION
                MOVE WS-TRN-TIPO(WS-IDX) TO WS-SELECCION
                MOVE WS-TRN-CUENTA(WS-IDX) TO WS-SELECCION
                MOVE WS-TRN-DESC(WS-IDX) TO WS-SELECCION
                MOVE WS-TRN-MONTO(WS-IDX) TO WS-SELECCION
                MOVE WS-TRN-FEE(WS-IDX) TO WS-SELECCION
                MOVE WS-TRN-TOTAL(WS-IDX) TO WS-SELECCION
                MOVE WS-TRN-STATUS(WS-IDX) TO WS-SELECCION
       *
                DISPLAY WS-TRN-IDX(WS-IDX)
                  AT LINE WS-K COLUMN 02
                DISPLAY WS-TRN-FECHA(WS-IDX)
                  AT LINE WS-K COLUMN 06
                DISPLAY WS-TRN-HORA(WS-IDX)
                  AT LINE WS-K COLUMN 15
                DISPLAY WS-TRN-TIPO(WS-IDX)
                  AT LINE WS-K COLUMN 22
                DISPLAY WS-TRN-CUENTA(WS-IDX)
                  AT LINE WS-K COLUMN 27
                DISPLAY WS-TRN-DESC(WS-IDX)
                  AT LINE WS-K COLUMN 38
                MOVE WS-TRN-MONTO(WS-IDX) TO WS-MONTO-DISP
                DISPLAY WS-MONTO-DISP
                  AT LINE WS-K COLUMN 52
                MOVE WS-TRN-FEE(WS-IDX) TO WS-FEE-DISP
                DISPLAY WS-FEE-DISP
                  AT LINE WS-K COLUMN 60
                MOVE WS-TRN-TOTAL(WS-IDX) TO WS-MONTO-DISP
                DISPLAY WS-MONTO-DISP
                  AT LINE WS-K COLUMN 66
                DISPLAY WS-TRN-STATUS(WS-IDX)
                  AT LINE WS-K COLUMN 72
       *
                ADD 1 TO WS-I
                ADD 1 TO WS-K
                ADD 1 TO WS-IDX
                IF WS-IDX > 20
                    MOVE 1 TO WS-IDX
                END-IF
            END-PERFORM.
       *
        6000-VER-DETALLE.
            MOVE 'S' TO WS-DETALLE-ACTIVO.
            MOVE WS-TRN-IDX(1) TO WS-SELECCION.
            DISPLAY 'SELECCIONE # DE LINEA (1-20): '
              AT LINE 22 COLUMN 05.
            ACCEPT WS-SELECCION AT LINE 22 COLUMN 35.
       *
            IF WS-SELECCION < 1 OR WS-SELECCION > 20
                MOVE 'SELECCION INVALIDA' TO WS-MENSAJE-ERROR
                GOTO 6000-EXIT
            END-IF.
       *
            COMPUTE WS-IDX =
                FUNCTION MOD(WS-REG-DESDE - 1, 20) + WS-SELECCION.
            IF WS-IDX > 20
                SUBTRACT 20 FROM WS-IDX
            END-IF.
       *
            MOVE WS-TRN-IDX(WS-IDX) TO TRN-SEQ.
            READ TRANLOG-FILE KEY IS TRN-SEQ
                INVALID KEY
                    MOVE 'ERROR LEYENDO DETALLE'
                      TO WS-MENSAJE-ERROR
                    GOTO 6000-EXIT
            END-READ.
       *
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            DISPLAY SCR-DETALLE.
            ACCEPT SCR-DETALLE.
       *
            IF WS-CRT-PF3 OR WS-CRT-PF12
                GOTO 6000-EXIT
            END-IF.
       *
        6000-EXIT.
            EXIT.
       *
        7000-IMPRIMIR.
            DISPLAY 'IMPRIMIENDO PAGINA ' WS-PAGINA-ACTUAL
              UPON PRINTER.
            MOVE 'IMPRESION ENVIADA A SPOOL' TO WS-MENSAJE.
       *
        8000-EXPORTAR.
            OPEN OUTPUT SPOOL-FILE.
            IF NOT WS-SPOOL-OK
                MOVE 'ERROR AL ABRIR ARCHIVO EXPORTACION'
                  TO WS-MENSAJE-ERROR
                GOTO 8000-EXIT
            END-IF.
       *
            MOVE 0 TO WS-I.
            MOVE 1 TO WS-IDX.
       *
            PERFORM VARYING WS-I FROM 1 BY 1
                UNTIL WS-I > 20 OR WS-I > WS-REG-TOTAL
                STRING WS-TRN-IDX(WS-I) ','
                       WS-TRN-FECHA(WS-I) ','
                       WS-TRN-HORA(WS-I) ','
                       WS-TRN-TIPO(WS-I) ','
                       WS-TRN-CUENTA(WS-I) ','
                       WS-TRN-DESC(WS-I) ','
                       WS-TRN-MONTO(WS-I) ','
                       WS-TRN-FEE(WS-I) ','
                       WS-TRN-TOTAL(WS-I) ','
                       WS-TRN-STATUS(WS-I)
                  INTO SPOOL-RECORD
                WRITE SPOOL-RECORD
            END-PERFORM.
       *
            CLOSE SPOOL-FILE.
            MOVE 'ARCHIVO EXPORTADO BNK0020.RPT' TO WS-MENSAJE.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA
                                  'EXPORTACION TRANLOG'.
       *
        8000-EXIT.
            EXIT.
       *
        9000-FINALIZAR.
            CLOSE TRANLOG-FILE.
            MOVE 00 TO LS-RETCODE.
            GOBACK.
       *
        END PROGRAM BNK0020.
