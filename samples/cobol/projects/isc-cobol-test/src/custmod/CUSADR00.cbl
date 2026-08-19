       *================================================================*
       * CUSADR00 - MANTENIMIENTO DE DIRECCIONES                      *
       * PROPOSITO: ADMINISTRAR HASTA 3 DIRECCIONES POR CLIENTE       *
       * EQUIPO: COMERCIAL - 2005                                     *
       * ARCHIVOS: CUSTOMER (LECTURA/ESCRITURA)                       *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. CUSADR00.
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
       *
            SELECT AUDITLOG-FILE
                ASSIGN TO 'AUDITLOG.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS AUD-SEQ
                FILE STATUS IS FL-AUDITLOG-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  CUSTOMER-FILE
            LABEL RECORDS ARE STANDARD
            RECORD 300 CHARACTERS.
        COPY FD-CUSTOMER.
       *
        FD  AUDITLOG-FILE
            RECORD 200 CHARACTERS.
        COPY FD-AUDITLOG.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'CUSADR00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-CUSTID                  PIC X(10).
            05  WS-DUMMY                   PIC X(01).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-SEL-DIR                 PIC 9(01).
            05  WS-DIRECCION-ACTIVA        PIC 9(01).
       *
        01  WS-DIRECCIONES.
            05  WS-DIR-ENTRY               OCCURS 3.
                10  WS-DIR-TIPO            PIC X(15).
                10  WS-DIR-STRET           PIC X(40).
                10  WS-DIR-NUM-EXT         PIC X(10).
                10  WS-DIR-NUM-INT         PIC X(10).
                10  WS-DIR-COLONIA         PIC X(30).
                10  WS-DIR-CIUDAD          PIC X(30).
                10  WS-DIR-ESTADO          PIC X(20).
                10  WS-DIR-PAIS            PIC X(20).
                10  WS-DIR-CP              PIC X(05).
       *
        01  WS-DIR-EDIT                   REDEFINES WS-DIRECCIONES.
            05  WS-DIR-EDIT-ENTRY          OCCURS 3.
                10  WS-DIR-EDIT-TIPO       PIC X(15).
                10  WS-DIR-EDIT-STRET      PIC X(40).
                10  WS-DIR-EDIT-NUM-EXT    PIC X(10).
                10  WS-DIR-EDIT-NUM-INT    PIC X(10).
                10  WS-DIR-EDIT-COLONIA    PIC X(30).
                10  WS-DIR-EDIT-CIUDAD     PIC X(30).
                10  WS-DIR-EDIT-ESTADO     PIC X(20).
                10  WS-DIR-EDIT-PAIS       PIC X(20).
                10  WS-DIR-EDIT-CP         PIC X(05).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-ADDRESS.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' MANTENIMIENTO DE DIRECCIONES'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID.
                10  LINE 04  COL 05  PIC X(10) VALUE 'CLIENTE:'.
                10  LINE 04  COL 16  PIC X(10)
                    USING WS-CUSTID AUTO PROMPT '__________'.
                10  LINE 04  COL 30  PIC X(20) VALUE 'ENTER=CONSULTAR'.
       *
            05  SCR-DIR1.
                10  LINE 06  COL 05  PIC X(15) VALUE 'DIR 1 (CASA):'.
                10  LINE 07  COL 05  PIC X(10) VALUE 'CALLE:'.
                10  LINE 07  COL 22  PIC X(40)
                    USING WS-DIR-EDIT-STRET(1) AUTO.
                10  LINE 08  COL 05  PIC X(10) VALUE 'NUM EXT:'.
                10  LINE 08  COL 22  PIC X(10)
                    USING WS-DIR-EDIT-NUM-EXT(1) AUTO.
                10  LINE 08  COL 35  PIC X(10) VALUE 'NUM INT:'.
                10  LINE 08  COL 50  PIC X(10)
                    USING WS-DIR-EDIT-NUM-INT(1) AUTO.
                10  LINE 09  COL 05  PIC X(10) VALUE 'COLONIA:'.
                10  LINE 09  COL 22  PIC X(30)
                    USING WS-DIR-EDIT-COLONIA(1) AUTO.
                10  LINE 09  COL 55  PIC X(05) VALUE 'CP:'.
                10  LINE 09  COL 62  PIC X(05)
                    USING WS-DIR-EDIT-CP(1) AUTO.
       *
            05  SCR-DIR2.
                10  LINE 11  COL 05  PIC X(20) VALUE 'DIR 2 (TRABAJO):'.
                10  LINE 12  COL 05  PIC X(10) VALUE 'CALLE:'.
                10  LINE 12  COL 22  PIC X(40)
                    USING WS-DIR-EDIT-STRET(2) AUTO.
                10  LINE 13  COL 05  PIC X(10) VALUE 'NUM EXT:'.
                10  LINE 13  COL 22  PIC X(10)
                    USING WS-DIR-EDIT-NUM-EXT(2) AUTO.
                10  LINE 13  COL 35  PIC X(10) VALUE 'NUM INT:'.
                10  LINE 13  COL 50  PIC X(10)
                    USING WS-DIR-EDIT-NUM-INT(2) AUTO.
                10  LINE 14  COL 05  PIC X(10) VALUE 'COLONIA:'.
                10  LINE 14  COL 22  PIC X(30)
                    USING WS-DIR-EDIT-COLONIA(2) AUTO.
                10  LINE 14  COL 55  PIC X(05) VALUE 'CP:'.
                10  LINE 14  COL 62  PIC X(05)
                    USING WS-DIR-EDIT-CP(2) AUTO.
       *
            05  SCR-DIR3.
                10  LINE 16  COL 05  PIC X(20) VALUE 'DIR 3 (FISCAL):'.
                10  LINE 17  COL 05  PIC X(10) VALUE 'CALLE:'.
                10  LINE 17  COL 22  PIC X(40)
                    USING WS-DIR-EDIT-STRET(3) AUTO.
                10  LINE 18  COL 05  PIC X(10) VALUE 'NUM EXT:'.
                10  LINE 18  COL 22  PIC X(10)
                    USING WS-DIR-EDIT-NUM-EXT(3) AUTO.
                10  LINE 18  COL 35  PIC X(10) VALUE 'NUM INT:'.
                10  LINE 18  COL 50  PIC X(10)
                    USING WS-DIR-EDIT-NUM-INT(3) AUTO.
                10  LINE 19  COL 05  PIC X(10) VALUE 'COLONIA:'.
                10  LINE 19  COL 22  PIC X(30)
                    USING WS-DIR-EDIT-COLONIA(3) AUTO.
                10  LINE 19  COL 55  PIC X(05) VALUE 'CP:'.
                10  LINE 19  COL 62  PIC X(05)
                    USING WS-DIR-EDIT-CP(3) AUTO.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF3=GUARDAR  PF11=AYUDA  PF12=RETORNAR'.
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
            MOVE 1 TO WS-DIRECCION-ACTIVA.
       *
            PERFORM 1000-INICIALIZAR.
            PERFORM 2000-LIMPIAR-DIRECCIONES.
       *
        ADDR-LOOP.
            PERFORM 3000-REFRESCAR.
            DISPLAY SCR-ADDRESS.
            ACCEPT SCR-ADDRESS.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 4000-CONSULTAR-CLIENTE
                    GO TO ADDR-LOOP
       *
                WHEN WS-CRT-PF3
                    PERFORM 5000-GUARDAR-DIRECCIONES
                    GO TO ADDR-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'CUSADR00'
                    GO TO ADDR-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO ADDR-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-CUSTID
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    PERFORM 2000-LIMPIAR-DIRECCIONES
                    GO TO ADDR-LOOP
       *
                WHEN OTHER
                    MOVE 'USE ENTER=CONS PF3=GUARDAR PF12=SALIR'
                      TO WS-MENSAJE-ERROR
                    GO TO ADDR-LOOP
            END-EVALUATE.
       *
        ADDR-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE ID CLIENTE, ENTER=CONS, PF3=GUARDAR'
              TO WS-MENSAJE.
            PERFORM 1100-LIMPIAR.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        2000-LIMPIAR-DIRECCIONES.
            PERFORM VARYING WS-SEL-DIR FROM 1 BY 1
                UNTIL WS-SEL-DIR > 3
                MOVE SPACES TO WS-DIR-EDIT-STRET(WS-SEL-DIR)
                               WS-DIR-EDIT-NUM-EXT(WS-SEL-DIR)
                               WS-DIR-EDIT-NUM-INT(WS-SEL-DIR)
                               WS-DIR-EDIT-COLONIA(WS-SEL-DIR)
                               WS-DIR-EDIT-CIUDAD(WS-SEL-DIR)
                               WS-DIR-EDIT-ESTADO(WS-SEL-DIR)
                               WS-DIR-EDIT-PAIS(WS-SEL-DIR)
                               WS-DIR-EDIT-CP(WS-SEL-DIR)
            END-PERFORM.
       *
        3000-REFRESCAR.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
        4000-CONSULTAR-CLIENTE.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-CUSTID = SPACES OR = LOW-VALUES
                MOVE 'INGRESE ID DE CLIENTE' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            OPEN I-O CUSTOMER-FILE.
            IF FL-CUSTOMER-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE WS-CUSTID TO CUS-ID.
            READ CUSTOMER-FILE KEY IS CUS-ID
                INVALID KEY
                    MOVE 'CLIENTE NO ENCONTRADO' TO WS-MENSAJE-ERROR
                    CLOSE CUSTOMER-FILE
                    GOTO 4000-EXIT
            END-READ.
       *
            IF FL-CUSTOMER-STATUS = '00'
                MOVE CUS-STRET TO WS-DIR-EDIT-STRET(1)
                MOVE CUS-NUM-EXT TO WS-DIR-EDIT-NUM-EXT(1)
                MOVE CUS-NUM-INT TO WS-DIR-EDIT-NUM-INT(1)
                MOVE CUS-COLONIA TO WS-DIR-EDIT-COLONIA(1)
                MOVE CUS-CIUDAD TO WS-DIR-EDIT-CIUDAD(1)
                MOVE CUS-ESTADO TO WS-DIR-EDIT-ESTADO(1)
                MOVE CUS-PAIS TO WS-DIR-EDIT-PAIS(1)
                MOVE CUS-CP TO WS-DIR-EDIT-CP(1)
                MOVE 'DIRECCION PRINCIPAL CARGADA' TO WS-MENSAJE
            ELSE
                MOVE 'ERROR AL LEER CLIENTE' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE CUSTOMER-FILE.
        4000-EXIT.
            EXIT.
       *
        5000-GUARDAR-DIRECCIONES.
            IF WS-CUSTID = SPACES
                MOVE 'PRIMERO CONSULTE UN CLIENTE' TO WS-MENSAJE-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-CONFIRMA.
            DISPLAY 'GUARDAR DIRECCIONES? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRMA AT LINE 23 COLUMN 35.
            IF WS-CONFIRMA NOT = 'S' AND NOT = 's'
                MOVE 'OPERACION CANCELADA' TO WS-MENSAJE
                GOTO 5000-EXIT
            END-IF.
       *
            OPEN I-O CUSTOMER-FILE.
            IF FL-CUSTOMER-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR ARCHIVO' TO WS-MENSAJE-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            MOVE WS-CUSTID TO CUS-ID.
            READ CUSTOMER-FILE KEY IS CUS-ID
                INVALID KEY
                    MOVE 'CLIENTE NO ENCONTRADO' TO WS-MENSAJE-ERROR
                    CLOSE CUSTOMER-FILE
                    GOTO 5000-EXIT
            END-READ.
       *
            IF FL-CUSTOMER-STATUS = '00'
                MOVE WS-DIR-EDIT-STRET(1) TO CUS-STRET
                MOVE WS-DIR-EDIT-NUM-EXT(1) TO CUS-NUM-EXT
                MOVE WS-DIR-EDIT-NUM-INT(1) TO CUS-NUM-INT
                MOVE WS-DIR-EDIT-COLONIA(1) TO CUS-COLONIA
                MOVE WS-DIR-EDIT-CIUDAD(1) TO CUS-CIUDAD
                MOVE WS-DIR-EDIT-ESTADO(1) TO CUS-ESTADO
                MOVE WS-DIR-EDIT-PAIS(1) TO CUS-PAIS
                MOVE WS-DIR-EDIT-CP(1) TO CUS-CP
                MOVE WS-FECHA TO CUS-FECHA-ULT-MOD
                MOVE WS-USUARIO-ID TO CUS-USUARIO-ULT-MOD
                REWRITE CUSTOMER-RECORD
                    INVALID KEY
                        MOVE 'ERROR AL GUARDAR DIRECCIONES'
                          TO WS-MENSAJE-ERROR
                        CLOSE CUSTOMER-FILE
                        GOTO 5000-EXIT
                END-REWRITE
                IF FL-CUSTOMER-STATUS = '00'
                    PERFORM 6000-REGISTRAR-AUDITORIA
                    MOVE 'DIRECCIONES GUARDADAS OK' TO WS-MENSAJE
                ELSE
                    MOVE 'ERROR AL ACTUALIZAR' TO WS-MENSAJE-ERROR
                END-IF
            END-IF.
       *
            CLOSE CUSTOMER-FILE.
        5000-EXIT.
            EXIT.
       *
        6000-REGISTRAR-AUDITORIA.
            OPEN I-O AUDITLOG-FILE.
            IF FL-AUDITLOG-STATUS = '00'
                MOVE 0 TO AUD-SEQ
                START AUDITLOG-FILE KEY IS NOT < AUD-SEQ
                    INVALID KEY
                        MOVE 0 TO AUD-SEQ
                        GOTO 6000-ESCRIBIR
                END-START
                READ AUDITLOG-FILE NEXT RECORD
                    AT END
                        MOVE 0 TO AUD-SEQ
                        GOTO 6000-ESCRIBIR
                END-READ
                IF AUD-SEQ IS NUMERIC
                    ADD 1 TO AUD-SEQ
                END-IF
        6000-ESCRIBIR.
                MOVE WS-FECHA TO AUD-DATE
                MOVE WS-HORA TO AUD-TIME
                MOVE WS-USUARIO-ID TO AUD-USUARIO
                MOVE 'CUSADR00' TO AUD-PROGRAMA
                MOVE 'CA' TO AUD-EVENTO
                MOVE 'CL' TO AUD-ENTITY-TYPE
                MOVE CUS-ID TO AUD-ENTITY-KEY
                MOVE 'ACTUALIZACION DIRECCIONES' TO AUD-OBSERVACIONES
                MOVE 'O' TO AUD-RESULTADO
                WRITE AUDITLOG-RECORD
                CLOSE AUDITLOG-FILE
            END-IF.
       *
        END PROGRAM CUSADR00.
