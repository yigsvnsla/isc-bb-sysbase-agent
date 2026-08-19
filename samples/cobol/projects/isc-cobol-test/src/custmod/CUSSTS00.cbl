       *================================================================*
       * CUSSTS00 - CAMBIO DE ESTATUS DE CLIENTE                      *
       * PROPOSITO: CAMBIAR ESTATUS DEL CLIENTE (A/I/B/F)             *
       * EQUIPO: COMERCIAL - 2005                                     *
       * ARCHIVOS: CUSTOMER (LECTURA/ESCRITURA)                       *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. CUSSTS00.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'CUSSTS00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-CUSTID                  PIC X(10).
            05  WS-DUMMY                   PIC X(01).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-ESTATUS-ACTUAL          PIC X(01).
            05  WS-ESTATUS-NUEVO           PIC X(01).
            05  WS-MOTIVO-CAMBIO           PIC X(40).
            05  WS-VAL-RETORNO             PIC 99.
       *
        01  WS-ESTATUS-DESC.
            05  WS-EST-DISP                PIC X(15).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-STATUS.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' CAMBIO DE ESTATUS DE CLIENTE'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID.
                10  LINE 04  COL 05  PIC X(10) VALUE 'CLIENTE:'.
                10  LINE 04  COL 16  PIC X(10)
                    USING WS-CUSTID AUTO PROMPT '__________'.
                10  LINE 04  COL 30  PIC X(20) VALUE 'ENTER=CONSULTAR'.
       *
            05  SCR-MUESTRA.
                10  LINE 06  COL 05  PIC X(15) VALUE 'NOMBRE:'.
                10  LINE 06  COL 22  PIC X(60) FROM CUS-NAME.
                10  LINE 07  COL 05  PIC X(15) VALUE 'RFC:'.
                10  LINE 07  COL 22  PIC X(13) FROM CUS-RFC.
                10  LINE 08  COL 05  PIC X(20) VALUE 'ESTATUS ACTUAL:'.
                10  LINE 08  COL 28  PIC X(15) FROM WS-EST-DISP.
       *
            05  SCR-CAMBIO.
                10  LINE 10  COL 05  PIC X(20) VALUE 'NUEVO ESTATUS:'.
                10  LINE 10  COL 28  PIC X(01)
                    USING WS-ESTATUS-NUEVO AUTO PROMPT '_'.
                10  LINE 10  COL 35  PIC X(40)
                    VALUE 'A=ACTIVO  I=INACTIVO  B=BLOQ  F=FALLEC'.
                10  LINE 12  COL 05  PIC X(15) VALUE 'MOTIVO:'.
                10  LINE 12  COL 22  PIC X(40)
                    USING WS-MOTIVO-CAMBIO AUTO.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF3=CAMBIAR  PF11=AYUDA  PF12=RETORNAR'.
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
        STS-LOOP.
            PERFORM 3000-REFRESCAR.
            DISPLAY SCR-STATUS.
            ACCEPT SCR-STATUS.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 4000-CONSULTAR-CLIENTE
                    GO TO STS-LOOP
       *
                WHEN WS-CRT-PF3
                    PERFORM 5000-CAMBIAR-ESTATUS
                    GO TO STS-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'CUSSTS00'
                    GO TO STS-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO STS-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-CUSTID
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    MOVE SPACES TO WS-ESTATUS-NUEVO WS-MOTIVO-CAMBIO
                    GO TO STS-LOOP
       *
                WHEN OTHER
                    MOVE 'USE ENTER=CONS PF3=CAMBIAR PF12=SALIR'
                      TO WS-MENSAJE-ERROR
                    GO TO STS-LOOP
            END-EVALUATE.
       *
        STS-EXIT.
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
                GO TO 4000-EXIT
            END-IF.
       *
            OPEN I-O CUSTOMER-FILE.
            IF FL-CUSTOMER-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO CLIENTES'
                  TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            MOVE WS-CUSTID TO CUS-ID.
            READ CUSTOMER-FILE KEY IS CUS-ID
                INVALID KEY
                    MOVE 'CLIENTE NO ENCONTRADO' TO WS-MENSAJE-ERROR
                    CLOSE CUSTOMER-FILE
                    GO TO 4000-EXIT
            END-READ.
       *
            IF FL-CUSTOMER-STATUS = '00'
                MOVE CUS-STATUS TO WS-ESTATUS-ACTUAL
                PERFORM 4200-MOSTRAR-ESTATUS-ACTUAL
                MOVE 'CLIENTE ENCONTRADO - INDIQUE NUEVO ESTATUS'
                  TO WS-MENSAJE
            ELSE
                MOVE 'ERROR AL LEER CLIENTE' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE CUSTOMER-FILE.
        4000-EXIT.
            EXIT.
       *
        4200-MOSTRAR-ESTATUS-ACTUAL.
            EVALUATE WS-ESTATUS-ACTUAL
                WHEN 'A'
                    MOVE 'ACTIVO' TO WS-EST-DISP
                WHEN 'I'
                    MOVE 'INACTIVO' TO WS-EST-DISP
                WHEN 'B'
                    MOVE 'BLOQUEADO' TO WS-EST-DISP
                WHEN 'F'
                    MOVE 'FALLECIDO' TO WS-EST-DISP
                WHEN OTHER
                    MOVE 'DESCONOCIDO' TO WS-EST-DISP
            END-EVALUATE.
       *
        5000-CAMBIAR-ESTATUS.
            IF WS-CUSTID = SPACES
                MOVE 'PRIMERO CONSULTE UN CLIENTE' TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            IF WS-ESTATUS-NUEVO = SPACES
                MOVE 'INGRESE NUEVO ESTATUS (A/I/B/F)'
                  TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            IF WS-ESTATUS-NUEVO NOT = 'A' AND NOT = 'I'
                AND NOT = 'B' AND NOT = 'F'
                MOVE 'ESTATUS INVALIDO USE A I B O F'
                  TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            IF WS-ESTATUS-NUEVO = WS-ESTATUS-ACTUAL
                MOVE 'EL NUEVO ESTATUS ES IGUAL AL ACTUAL'
                  TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            IF WS-MOTIVO-CAMBIO = SPACES
                MOVE 'INGRESE MOTIVO DEL CAMBIO' TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-CONFIRMA.
            DISPLAY 'CONFIRMA CAMBIO DE ESTATUS? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRMA AT LINE 23 COLUMN 40.
            IF WS-CONFIRMA NOT = 'S' AND NOT = 's'
                MOVE 'CAMBIO CANCELADO' TO WS-MENSAJE
                GO TO 5000-EXIT
            END-IF.
       *
            OPEN I-O CUSTOMER-FILE.
            IF FL-CUSTOMER-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR ARCHIVO' TO WS-MENSAJE-ERROR
                GO TO 5000-EXIT
            END-IF.
       *
            MOVE WS-CUSTID TO CUS-ID.
            READ CUSTOMER-FILE KEY IS CUS-ID
                INVALID KEY
                    MOVE 'CLIENTE NO ENCONTRADO' TO WS-MENSAJE-ERROR
                    CLOSE CUSTOMER-FILE
                    GO TO 5000-EXIT
            END-READ.
       *
            MOVE WS-ESTATUS-NUEVO TO CUS-STATUS.
            MOVE WS-FECHA TO CUS-FECHA-ULT-MOD
                             CUS-FECHA-ULT-OP.
            MOVE WS-USUARIO-ID TO CUS-USUARIO-ULT-MOD.
       *
            REWRITE CUSTOMER-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ACTUALIZAR CLIENTE'
                      TO WS-MENSAJE-ERROR
                    CLOSE CUSTOMER-FILE
                    GO TO 5000-EXIT
            END-REWRITE.
       *
            IF FL-CUSTOMER-STATUS = '00'
                PERFORM 6000-REGISTRAR-AUDITORIA
                MOVE 'ESTATUS CAMBIADO EXITOSAMENTE' TO WS-MENSAJE
                MOVE WS-ESTATUS-NUEVO TO WS-ESTATUS-ACTUAL
                PERFORM 4200-MOSTRAR-ESTATUS-ACTUAL
            ELSE
                MOVE 'ERROR AL ACTUALIZAR ESTATUS' TO WS-MENSAJE-ERROR
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
                        GO TO 6000-ESCRIBIR
                END-START
                READ AUDITLOG-FILE NEXT RECORD
                    AT END
                        MOVE 0 TO AUD-SEQ
                        GO TO 6000-ESCRIBIR
                END-READ
                IF AUD-SEQ IS NUMERIC
                    ADD 1 TO AUD-SEQ
                END-IF
        6000-ESCRIBIR.
                MOVE WS-FECHA TO AUD-DATE
                MOVE WS-HORA TO AUD-TIME
                MOVE WS-USUARIO-ID TO AUD-USUARIO
                MOVE 'CUSSTS00' TO AUD-PROGRAMA
                MOVE 'CA' TO AUD-EVENTO
                MOVE 'CL' TO AUD-ENTITY-TYPE
                MOVE CUS-ID TO AUD-ENTITY-KEY
                STRING 'ESTATUS ' WS-ESTATUS-ACTUAL '->'
                       WS-ESTATUS-NUEVO INTO AUD-OBSERVACIONES
                MOVE 'O' TO AUD-RESULTADO
                WRITE AUDITLOG-RECORD
                CLOSE AUDITLOG-FILE
            END-IF.
       *
        END PROGRAM CUSSTS00.
