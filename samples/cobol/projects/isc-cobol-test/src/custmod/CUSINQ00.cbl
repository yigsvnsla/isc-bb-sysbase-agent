       *================================================================*
       * CUSINQ00 - CONSULTA DE CLIENTE                               *
       * PROPOSITO: VISUALIZAR DATOS COMPLETOS DEL CLIENTE            *
       * EQUIPO: COMERCIAL - 2003                                     *
       * ARCHIVOS: CUSTOMER (LECTURA)                                  *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. CUSINQ00.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'CUSINQ00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-CUSTID                  PIC X(10).
            05  WS-INGRESO-MENSUAL-DISP    PIC Z(09)9.99.
            05  WS-DUMMY                   PIC X(01).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-CONSULTA.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' CONSULTA DE CLIENTE'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-CAMPOS.
                10  LINE 04  COL 05  PIC X(10) VALUE 'CLIENTE:'.
                10  LINE 04  COL 16  PIC X(10)
                    USING WS-CUSTID AUTO PROMPT '__________'.
                10  LINE 04  COL 30  PIC X(02)
                    FROM CUS-ID-TYPE.
                10  LINE 04  COL 35  PIC X(30) VALUE 'PF3=EDITAR'.
       *
                10  LINE 06  COL 05  PIC X(10) VALUE 'NOMBRE:'.
                10  LINE 06  COL 16  PIC X(60) FROM CUS-NAME.
                10  LINE 07  COL 05  PIC X(10) VALUE 'AP PATER:'.
                10  LINE 07  COL 16  PIC X(30) FROM CUS-FIRST-LASTNAME.
                10  LINE 07  COL 50  PIC X(10) VALUE 'AP MATER:'.
                10  LINE 07  COL 62  PIC X(30) FROM CUS-SECOND-LASTNAME.
                10  LINE 08  COL 05  PIC X(10) VALUE 'RFC:'.
                10  LINE 08  COL 16  PIC X(13) FROM CUS-RFC.
                10  LINE 08  COL 35  PIC X(10) VALUE 'CURP:'.
                10  LINE 08  COL 45  PIC X(18) FROM CUS-CURP.
       *
                10  LINE 10  COL 05  PIC X(10) VALUE 'DIRECCION'.
                10  LINE 11  COL 05  PIC X(10) VALUE 'CALLE:'.
                10  LINE 11  COL 16  PIC X(40) FROM CUS-STRET.
                10  LINE 12  COL 05  PIC X(10) VALUE 'NUM EXT:'.
                10  LINE 12  COL 16  PIC X(10) FROM CUS-NUM-EXT.
                10  LINE 12  COL 30  PIC X(10) VALUE 'NUM INT:'.
                10  LINE 12  COL 42  PIC X(10) FROM CUS-NUM-INT.
                10  LINE 13  COL 05  PIC X(10) VALUE 'COLONIA:'.
                10  LINE 13  COL 16  PIC X(30) FROM CUS-COLONIA.
                10  LINE 13  COL 50  PIC X(10) VALUE 'CP:'.
                10  LINE 13  COL 55  PIC X(05) FROM CUS-CP.
                10  LINE 14  COL 05  PIC X(10) VALUE 'CIUDAD:'.
                10  LINE 14  COL 16  PIC X(30) FROM CUS-CIUDAD.
                10  LINE 14  COL 50  PIC X(10) VALUE 'ESTADO:'.
                10  LINE 14  COL 62  PIC X(20) FROM CUS-ESTADO.
                10  LINE 15  COL 05  PIC X(10) VALUE 'PAIS:'.
                10  LINE 15  COL 16  PIC X(20) FROM CUS-PAIS.
       *
                10  LINE 17  COL 05  PIC X(10) VALUE 'CONTACTO'.
                10  LINE 18  COL 05  PIC X(10) VALUE 'TEL1:'.
                10  LINE 18  COL 16  PIC X(15) FROM CUS-TELEFONO1.
                10  LINE 18  COL 35  PIC X(10) VALUE 'TEL2:'.
                10  LINE 18  COL 46  PIC X(15) FROM CUS-TELEFONO2.
                10  LINE 19  COL 05  PIC X(10) VALUE 'CEL:'.
                10  LINE 19  COL 16  PIC X(15) FROM CUS-CELULAR.
                10  LINE 19  COL 35  PIC X(10) VALUE 'EMAIL:'.
                10  LINE 19  COL 46  PIC X(50) FROM CUS-EMAIL.
       *
                10  LINE 21  COL 05  PIC X(10) VALUE 'EMPRESA:'.
                10  LINE 21  COL 16  PIC X(40) FROM CUS-EMPRESA.
                10  LINE 21  COL 60  PIC X(10) VALUE 'PUESTO:'.
                10  LINE 21  COL 70  PIC X(30) FROM CUS-PUESTO.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF3=EDITAR  PF11=AYUDA  PF12=RETORNAR'.
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
            MOVE SPACES TO WS-CUSTID.
       *
            PERFORM 1000-INICIALIZAR.
       *
        INQUIRY-LOOP.
            PERFORM 2000-REFRESCAR.
            DISPLAY SCR-CONSULTA.
            ACCEPT SCR-CONSULTA.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 3000-CONSULTAR-CLIENTE
                    GO TO INQUIRY-LOOP
       *
                WHEN WS-CRT-PF3
                    PERFORM 4000-EDITAR-CLIENTE
                    GO TO INQUIRY-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'CUSINQ00'
                    GO TO INQUIRY-LOOP
       *
                WHEN WS-CRT-PF12
                    PERFORM 9000-FINALIZAR
                    GO TO INQUIRY-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-CUSTID
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO INQUIRY-LOOP
       *
                WHEN OTHER
                    MOVE 'TECLA NO VALIDA' TO WS-MENSAJE-ERROR
                    GO TO INQUIRY-LOOP
            END-EVALUATE.
       *
        INQUIRY-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE ID CLIENTE Y PRESIONE ENTER' TO WS-MENSAJE.
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
        3000-CONSULTAR-CLIENTE.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-CUSTID = SPACES OR = LOW-VALUES
                MOVE 'INGRESE ID DE CLIENTE' TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            OPEN I-O CUSTOMER-FILE.
            IF FL-CUSTOMER-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO CLIENTES'
                  TO WS-MENSAJE-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            MOVE WS-CUSTID TO CUS-ID.
            READ CUSTOMER-FILE KEY IS CUS-ID
                INVALID KEY
                    MOVE 'CLIENTE NO ENCONTRADO' TO WS-MENSAJE-ERROR
                    CLOSE CUSTOMER-FILE
                    GOTO 3000-EXIT
            END-READ.
       *
            IF FL-CUSTOMER-STATUS = '00'
                MOVE 'CLIENTE ENCONTRADO' TO WS-MENSAJE
                MOVE CUS-INGRESO-MENSUAL TO WS-INGRESO-MENSUAL-DISP
            ELSE
                MOVE 'ERROR AL LEER CLIENTE' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE CUSTOMER-FILE.
        3000-EXIT.
            EXIT.
       *
        4000-EDITAR-CLIENTE.
            IF WS-CUSTID = SPACES
                MOVE 'PRIMERO CONSULTE UN CLIENTE' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            CALL 'CUSUPD00' USING WS-USUARIO-ID
                                  WS-RETCODE.
        4000-EXIT.
            EXIT.
       *
        9000-FINALIZAR.
            PERFORM 1100-LIMPIAR.
            MOVE 00 TO LS-RETCODE.
       *
        END PROGRAM CUSINQ00.
