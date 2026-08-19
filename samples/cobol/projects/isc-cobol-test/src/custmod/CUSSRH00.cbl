       *================================================================*
       * CUSSRH00 - BUSQUEDA DE CLIENTES                               *
       * PROPOSITO: BUSCAR CLIENTES POR ID, NOMBRE O RFC              *
       * EQUIPO: COMERCIAL - 2004 (REVISADO 2007)                     *
       * ARCHIVOS: CUSTOMER (LECTURA)                                  *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. CUSSRH00.
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
            SELECT CUSTOMER-FILE
                ASSIGN TO 'CUSTOMER.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS CUS-ID
                FILE STATUS IS FL-CUSTOMER-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  CUSTOMER-FILE
            LABEL RECORDS ARE STANDARD
            RECORD 300 CHARACTERS.
        COPY FD-CUSTOMER.
       *================================================================*
        WORKING-STORAGE SECTION.
       *
        COPY CPY-COMMON.
        COPY CPY-SCREEN.
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
        01  WS-VARIABLES.
            05  WS-USUARIO-ID              PIC X(08).
            05  WS-SUCURSAL-ID             PIC X(04).
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'CUSSRH00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-SEARCH-TYPE             PIC X(02).
            05  WS-SEARCH-VALUE            PIC X(60).
            05  WS-SEARCH-COUNT            PIC 9(04).
            05  WS-PAGINA                  PIC 9(02) VALUE 1.
            05  WS-PAGINA-MAX              PIC 9(02).
            05  WS-IND                     PIC 9(03).
            05  WS-IND2                    PIC 9(03).
            05  WS-LINEA                   PIC 9(02).
            05  WS-COLUMNA                 PIC 9(02).
            05  WS-SELECCION               PIC 9(02).
            05  WS-SEL-IND                 PIC 9(03).
            05  WS-CUSTID-SELECCIONADO     PIC X(10).
            05  WS-AUX-COUNT               PIC 9(03).
            05  WS-FUNCTION-LENGTH         PIC 9(02).
       *
        01  WS-RESULTADOS.
            05  WS-RES-COUNT               PIC 9(04).
            05  WS-RES-TABLE               OCCURS 50.
                10  WS-RES-ID              PIC X(10).
                10  WS-RES-NAME            PIC X(60).
                10  WS-RES-TYPE            PIC X(02).
                10  WS-RES-RFC             PIC X(13).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-BUSQUEDA.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' BUSQUEDA DE CLIENTES'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-CRITERIOS.
                10  LINE 04  COL 05  PIC X(20) VALUE 'TIPO BUSQUEDA:'.
                10  LINE 04  COL 28  PIC X(02)
                    USING WS-SEARCH-TYPE AUTO PROMPT '__'.
                10  LINE 04  COL 35  PIC X(40)
                    VALUE '01=ID  02=NOMBRE  03=RFC'.
                10  LINE 05  COL 05  PIC X(15) VALUE 'VALOR:'.
                10  LINE 05  COL 22  PIC X(60)
                    USING WS-SEARCH-VALUE AUTO.
       *
            05  SCR-ENCABEZADO-LISTA.
                10  LINE 07  COL 05  PIC X(05) VALUE 'NUM'.
                10  LINE 07  COL 10  PIC X(10) VALUE 'ID'.
                10  LINE 07  COL 22  PIC X(40) VALUE 'NOMBRE'.
                10  LINE 07  COL 63  PIC X(10) VALUE 'TIPO'.
                10  LINE 08  COL 05  PIC X(60) VALUE ALL '-'.
       *
            05  SCR-LISTA                  OCCURS 12.
                10  SCR-LINEA              PIC Z9 FROM WS-SELECCION
                    LINE 09 COL 05.
                10  SCR-ID                 PIC X(10) FROM WS-RES-ID
                    LINE 09 COL 10.
                10  SCR-NAME               PIC X(40) FROM WS-RES-NAME
                    LINE 09 COL 22.
                10  SCR-TYPE               PIC X(02) FROM WS-RES-TYPE
                    LINE 09 COL 63.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF3=SELEC  PF7=PANT  PF8=SIG  PF11=AYU'.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF12=RET  ENTER=BSQ'.
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
            MOVE LS-USUARIO TO WS-USUARIO-ID.
            MOVE 00 TO LS-RETCODE.
            MOVE 00 TO WS-RETCODE.
            MOVE 1 TO WS-PAGINA.
            MOVE SPACES TO WS-SEARCH-TYPE
                           WS-SEARCH-VALUE.
            MOVE SPACES TO WS-CUSTID-SELECCIONADO.
       *
            PERFORM 1000-INICIALIZAR.
       *
        SEARCH-LOOP.
            PERFORM 2000-REFRESCAR.
            DISPLAY SCR-BUSQUEDA.
            ACCEPT SCR-BUSQUEDA.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 3000-EJECUTAR-BUSQUEDA
                    MOVE 1 TO WS-PAGINA
                    GO TO SEARCH-LOOP
       *
                WHEN WS-CRT-PF3
                    PERFORM 4000-SELECCIONAR-RESULTADO
                    GO TO SEARCH-LOOP
       *
                WHEN WS-CRT-PF7
                    IF WS-PAGINA > 1
                        SUBTRACT 1 FROM WS-PAGINA
                    ELSE
                        MOVE 'YA ESTA EN PRIMERA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO SEARCH-LOOP
       *
                WHEN WS-CRT-PF8
                    IF WS-PAGINA < WS-PAGINA-MAX
                        ADD 1 TO WS-PAGINA
                    ELSE
                        MOVE 'YA ESTA EN ULTIMA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO SEARCH-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'CUSSRH00'
                    GO TO SEARCH-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO SEARCH-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    MOVE SPACES TO WS-SEARCH-TYPE WS-SEARCH-VALUE
                    MOVE 0 TO WS-SEARCH-COUNT
                    MOVE 1 TO WS-PAGINA
                    GO TO SEARCH-LOOP
       *
                WHEN OTHER
                    MOVE 'TECLA NO VALIDA' TO WS-MENSAJE-ERROR
                    GO TO SEARCH-LOOP
            END-EVALUATE.
       *
        SEARCH-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE TIPO Y VALOR, ENTER=BSQ, PF3=SELEC'
              TO WS-MENSAJE.
            PERFORM 1100-LIMPIAR.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        2000-REFRESCAR.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
        3000-EJECUTAR-BUSQUEDA.
            MOVE 0 TO WS-SEARCH-COUNT.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-SEARCH-TYPE = SPACES OR = LOW-VALUES
                MOVE 'SELECCIONE TIPO DE BUSQUEDA 01/02/03'
                  TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-SEARCH-VALUE = SPACES OR = LOW-VALUES
                MOVE 'INGRESE VALOR A BUSCAR' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            OPEN I-O CUSTOMER-FILE.
            IF FL-CUSTOMER-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR ARCHIVO CLIENTES'
                  TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            EVALUATE WS-SEARCH-TYPE
                WHEN '01'
                    PERFORM 3100-BUSCAR-POR-ID
                WHEN '02'
                    PERFORM 3200-BUSCAR-POR-NOMBRE
                WHEN '03'
                    PERFORM 3300-BUSCAR-POR-RFC
                WHEN OTHER
                    MOVE 'TIPO BUSQUEDA INVALIDO 01/02/03'
                      TO WS-MENSAJE-ERROR
            END-EVALUATE.
       *
            CLOSE CUSTOMER-FILE.
       *
            IF WS-SEARCH-COUNT = 0
                MOVE 'NO SE ENCONTRARON CLIENTES' TO WS-MENSAJE-ERROR
            ELSE
                COMPUTE WS-PAGINA-MAX =
                    (WS-SEARCH-COUNT - 1) / 12 + 1
                IF WS-PAGINA-MAX < 1
                    MOVE 1 TO WS-PAGINA-MAX
                END-IF
                STRING WS-SEARCH-COUNT ' CLIENTE(S) ENCONTRADOS'
                  INTO WS-MENSAJE
                PERFORM 3500-MOSTRAR-RESULTADOS
            END-IF.
       *
        3000-EXIT.
            EXIT.
       *
        3100-BUSCAR-POR-ID.
            MOVE WS-SEARCH-VALUE TO CUS-ID.
            READ CUSTOMER-FILE KEY IS CUS-ID
                INVALID KEY
                    GOTO 3100-EXIT
            END-READ.
       *
            IF FL-CUSTOMER-STATUS = '00'
                ADD 1 TO WS-SEARCH-COUNT
                MOVE CUS-ID TO WS-RES-ID(WS-SEARCH-COUNT)
                MOVE CUS-NAME TO WS-RES-NAME(WS-SEARCH-COUNT)
                MOVE CUS-ID-TYPE TO WS-RES-TYPE(WS-SEARCH-COUNT)
                MOVE CUS-RFC TO WS-RES-RFC(WS-SEARCH-COUNT)
            END-IF.
        3100-EXIT.
            EXIT.
       *
        3200-BUSCAR-POR-NOMBRE.
            MOVE SPACES TO CUS-ID.
            START CUSTOMER-FILE KEY IS NOT < CUS-ID
                INVALID KEY
                    GOTO 3200-EXIT
            END-START.
       *
            MOVE 'N' TO WS-SWITCH-EOF.
            PERFORM UNTIL WS-EOF-YES
                READ CUSTOMER-FILE NEXT RECORD
                    AT END
                        MOVE 'Y' TO WS-SWITCH-EOF
                        GOTO 3200-EXIT
                END-READ
       *
                MOVE FUNCTION LENGTH(WS-SEARCH-VALUE)
                  TO WS-FUNCTION-LENGTH
                IF WS-FUNCTION-LENGTH > 60
                    MOVE 60 TO WS-FUNCTION-LENGTH
                END-IF
       *
                IF CUS-NAME(1:WS-FUNCTION-LENGTH) =
                    WS-SEARCH-VALUE(1:WS-FUNCTION-LENGTH)
                    ADD 1 TO WS-SEARCH-COUNT
                    MOVE CUS-ID TO WS-RES-ID(WS-SEARCH-COUNT)
                    MOVE CUS-NAME TO WS-RES-NAME(WS-SEARCH-COUNT)
                    MOVE CUS-ID-TYPE TO WS-RES-TYPE(WS-SEARCH-COUNT)
                    MOVE CUS-RFC TO WS-RES-RFC(WS-SEARCH-COUNT)
                END-IF
       *
                IF WS-SEARCH-COUNT >= 50
                    MOVE 'Y' TO WS-SWITCH-EOF
                END-IF
            END-PERFORM.
        3200-EXIT.
            MOVE 'N' TO WS-SWITCH-EOF.
            EXIT.
       *
        3300-BUSCAR-POR-RFC.
            MOVE SPACES TO CUS-ID.
            START CUSTOMER-FILE KEY IS NOT < CUS-ID
                INVALID KEY
                    GOTO 3300-EXIT
            END-START.
       *
            MOVE 'N' TO WS-SWITCH-EOF.
            PERFORM UNTIL WS-EOF-YES
                READ CUSTOMER-FILE NEXT RECORD
                    AT END
                        MOVE 'Y' TO WS-SWITCH-EOF
                        GOTO 3300-EXIT
                END-READ
       *
                IF CUS-RFC = WS-SEARCH-VALUE
                    ADD 1 TO WS-SEARCH-COUNT
                    MOVE CUS-ID TO WS-RES-ID(WS-SEARCH-COUNT)
                    MOVE CUS-NAME TO WS-RES-NAME(WS-SEARCH-COUNT)
                    MOVE CUS-ID-TYPE TO WS-RES-TYPE(WS-SEARCH-COUNT)
                    MOVE CUS-RFC TO WS-RES-RFC(WS-SEARCH-COUNT)
                END-IF
       *
                IF WS-SEARCH-COUNT >= 50
                    MOVE 'Y' TO WS-SWITCH-EOF
                END-IF
            END-PERFORM.
        3300-EXIT.
            MOVE 'N' TO WS-SWITCH-EOF.
            EXIT.
       *
        3500-MOSTRAR-RESULTADOS.
            PERFORM VARYING WS-IND FROM 1 BY 1
                UNTIL WS-IND > WS-SEARCH-COUNT
                DISPLAY WS-IND AT LINE 09 COLUMN 05
                DISPLAY WS-RES-ID(WS-IND) AT LINE 09 COLUMN 10
                DISPLAY WS-RES-NAME(WS-IND)(1:40)
                    AT LINE 09 COLUMN 22
                DISPLAY WS-RES-TYPE(WS-IND) AT LINE 09 COLUMN 63
                ADD 1 TO WS-LINEA
            END-PERFORM.
       *
        4000-SELECCIONAR-RESULTADO.
            IF WS-SEARCH-COUNT = 0
                MOVE 'NO HAY RESULTADOS PARA SELECCIONAR'
                  TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-DUMMY.
            DISPLAY 'SELECCIONE NUMERO (00=CANCELAR): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-SELECCION AT LINE 23 COLUMN 42.
       *
            IF WS-SELECCION = 0
                GOTO 4000-EXIT
            END-IF.
       *
            COMPUTE WS-SEL-IND =
                (WS-PAGINA - 1) * 12 + WS-SELECCION.
       *
            IF WS-SEL-IND < 1 OR WS-SEL-IND > WS-SEARCH-COUNT
                MOVE 'SELECCION INVALIDA' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE WS-RES-ID(WS-SEL-IND) TO WS-CUSTID-SELECCIONADO.
            STRING 'SELECCIONADO: ' WS-CUSTID-SELECCIONADO
              INTO WS-MENSAJE.
       *
        4000-EXIT.
            EXIT.
       *
        END PROGRAM CUSSRH00.
