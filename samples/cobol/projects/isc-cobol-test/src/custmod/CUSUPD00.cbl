       *================================================================*
       * CUSUPD00 - MODIFICACION DE CLIENTE                           *
       * PROPOSITO: ACTUALIZAR DATOS DE CLIENTE EXISTENTE             *
       * EQUIPO: COMERCIAL - 2004                                     *
       * ARCHIVOS: CUSTOMER (LECTURA/ESCRITURA)                       *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. CUSUPD00.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'CUSUPD00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-CUSTID                  PIC X(10).
            05  WS-DUMMY                   PIC X(01).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-INGRESO-MENSUAL-DISP    PIC 9(09)V99 COMP-3.
            05  WS-INGRESO-MENSUAL-EDIT    PIC Z(09)9.99.
            05  WS-VAL-RETORNO             PIC 99.
       *
        01  WS-CAMPOS-ANTERIORES.
            05  WS-ANT-NAME                PIC X(60).
            05  WS-ANT-FIRST-LASTNAME      PIC X(30).
            05  WS-ANT-SECOND-LASTNAME     PIC X(30).
            05  WS-ANT-STRET               PIC X(40).
            05  WS-ANT-NUM-EXT             PIC X(10).
            05  WS-ANT-NUM-INT             PIC X(10).
            05  WS-ANT-COLONIA             PIC X(30).
            05  WS-ANT-CIUDAD              PIC X(30).
            05  WS-ANT-ESTADO              PIC X(20).
            05  WS-ANT-PAIS                PIC X(20).
            05  WS-ANT-CP                  PIC X(05).
            05  WS-ANT-TELEFONO1           PIC X(15).
            05  WS-ANT-TELEFONO2           PIC X(15).
            05  WS-ANT-CELULAR             PIC X(15).
            05  WS-ANT-EMAIL               PIC X(50).
            05  WS-ANT-EMPRESA             PIC X(40).
            05  WS-ANT-PUESTO              PIC X(30).
            05  WS-ANT-INGRESO-MENSUAL     PIC 9(09)V99 COMP-3.
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-UPDATE.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' MODIFICACION DE CLIENTE'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID.
                10  LINE 04  COL 05  PIC X(10) VALUE 'CLIENTE:'.
                10  LINE 04  COL 16  PIC X(10)
                    USING WS-CUSTID AUTO PROMPT '__________'.
                10  LINE 04  COL 30  PIC X(15) VALUE 'ENTER=CONSULTA'.
       *
            05  SCR-DATOS.
                10  LINE 06  COL 05  PIC X(10) VALUE 'NOMBRE:'.
                10  LINE 06  COL 16  PIC X(60)
                    USING CUS-NAME AUTO.
                10  LINE 07  COL 05  PIC X(15) VALUE 'APELLIDO PAT:'.
                10  LINE 07  COL 22  PIC X(30)
                    USING CUS-FIRST-LASTNAME AUTO.
                10  LINE 07  COL 55  PIC X(15) VALUE 'APELLIDO MAT:'.
                10  LINE 08  COL 05  PIC X(10) VALUE 'RFC:'.
                10  LINE 08  COL 16  PIC X(13) FROM CUS-RFC.
                10  LINE 08  COL 35  PIC X(10) VALUE 'CURP:'.
                10  LINE 08  COL 45  PIC X(18) FROM CUS-CURP.
       *
                10  LINE 10  COL 05  PIC X(15) VALUE 'CALLE:'.
                10  LINE 10  COL 22  PIC X(40)
                    USING CUS-STRET AUTO.
                10  LINE 11  COL 05  PIC X(15) VALUE 'NUM EXT:'.
                10  LINE 11  COL 22  PIC X(10)
                    USING CUS-NUM-EXT AUTO.
                10  LINE 11  COL 40  PIC X(15) VALUE 'NUM INT:'.
                10  LINE 11  COL 55  PIC X(10)
                    USING CUS-NUM-INT AUTO.
                10  LINE 12  COL 05  PIC X(15) VALUE 'COLONIA:'.
                10  LINE 12  COL 22  PIC X(30)
                    USING CUS-COLONIA AUTO.
                10  LINE 12  COL 55  PIC X(10) VALUE 'CP:'.
                10  LINE 12  COL 65  PIC X(05)
                    USING CUS-CP AUTO.
                10  LINE 13  COL 05  PIC X(15) VALUE 'CIUDAD:'.
                10  LINE 13  COL 22  PIC X(30)
                    USING CUS-CIUDAD AUTO.
                10  LINE 13  COL 55  PIC X(10) VALUE 'ESTADO:'.
                10  LINE 13  COL 65  PIC X(20)
                    USING CUS-ESTADO AUTO.
                10  LINE 14  COL 05  PIC X(10) VALUE 'PAIS:'.
                10  LINE 14  COL 22  PIC X(20)
                    USING CUS-PAIS AUTO.
       *
                10  LINE 16  COL 05  PIC X(10) VALUE 'TEL1:'.
                10  LINE 16  COL 22  PIC X(15)
                    USING CUS-TELEFONO1 AUTO.
                10  LINE 16  COL 40  PIC X(10) VALUE 'TEL2:'.
                10  LINE 16  COL 55  PIC X(15)
                    USING CUS-TELEFONO2 AUTO.
                10  LINE 17  COL 05  PIC X(10) VALUE 'CEL:'.
                10  LINE 17  COL 22  PIC X(15)
                    USING CUS-CELULAR AUTO.
                10  LINE 17  COL 40  PIC X(10) VALUE 'EMAIL:'.
                10  LINE 17  COL 55  PIC X(50)
                    USING CUS-EMAIL AUTO.
       *
                10  LINE 19  COL 05  PIC X(15) VALUE 'EMPRESA:'.
                10  LINE 19  COL 22  PIC X(40)
                    USING CUS-EMPRESA AUTO.
                10  LINE 20  COL 05  PIC X(15) VALUE 'PUESTO:'.
                10  LINE 20  COL 22  PIC X(30)
                    USING CUS-PUESTO AUTO.
                10  LINE 21  COL 05  PIC X(20) VALUE 'INGRESO MENSUAL:'.
                10  LINE 21  COL 30  PIC Z(09)9.99
                    USING WS-INGRESO-MENSUAL-EDIT AUTO.
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
       *
            PERFORM 1000-INICIALIZAR.
       *
        UPDATE-LOOP.
            PERFORM 3000-REFRESCAR.
            DISPLAY SCR-UPDATE.
            ACCEPT SCR-UPDATE.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 4000-CONSULTAR-CLIENTE
                    GO TO UPDATE-LOOP
       *
                WHEN WS-CRT-PF3
                    PERFORM 5000-GUARDAR-CAMBIOS
                    GO TO UPDATE-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'CUSUPD00'
                    GO TO UPDATE-LOOP
       *
                WHEN WS-CRT-PF12
                    PERFORM 6000-CONFIRMAR-SALIDA
                    IF WS-CONFIRMED
                        GO TO UPDATE-EXIT
                    ELSE
                        GO TO UPDATE-LOOP
                    END-IF
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-CUSTID
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    PERFORM 2000-LIMPIAR-CAMPOS
                    GO TO UPDATE-LOOP
       *
                WHEN OTHER
                    MOVE 'TECLA NO VALIDA - USE ENTER PF3 PF12'
                      TO WS-MENSAJE-ERROR
                    GO TO UPDATE-LOOP
            END-EVALUATE.
       *
        UPDATE-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE ID CLIENTE, ENTER=CONSULTAR, PF3=GUARDAR'
              TO WS-MENSAJE.
            PERFORM 1100-LIMPIAR.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        2000-LIMPIAR-CAMPOS.
            MOVE SPACES TO CUS-NAME
                           CUS-FIRST-LASTNAME
                           CUS-SECOND-LASTNAME
                           CUS-RFC
                           CUS-CURP
                           CUS-STRET
                           CUS-NUM-EXT
                           CUS-NUM-INT
                           CUS-COLONIA
                           CUS-CIUDAD
                           CUS-ESTADO
                           CUS-PAIS
                           CUS-CP
                           CUS-TELEFONO1
                           CUS-TELEFONO2
                           CUS-CELULAR
                           CUS-EMAIL
                           CUS-EMPRESA
                           CUS-PUESTO.
            MOVE ZEROS TO CUS-INGRESO-MENSUAL
                          WS-INGRESO-MENSUAL-EDIT.
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
                MOVE 'ERROR AL ABRIR ARCHIVO CLIENTES'
                  TO WS-MENSAJE-ERROR
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
                MOVE CUSTOMER-RECORD TO WS-CAMPOS-ANTERIORES
                MOVE CUS-INGRESO-MENSUAL TO WS-INGRESO-MENSUAL-DISP
                MOVE WS-INGRESO-MENSUAL-DISP TO WS-INGRESO-MENSUAL-EDIT
                MOVE 'CLIENTE ENCONTRADO - MODIFIQUE CAMPOS'
                  TO WS-MENSAJE
            ELSE
                MOVE 'ERROR AL LEER CLIENTE' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE CUSTOMER-FILE.
        4000-EXIT.
            EXIT.
       *
        5000-GUARDAR-CAMBIOS.
            IF WS-CUSTID = SPACES
                MOVE 'PRIMERO CONSULTE UN CLIENTE' TO WS-MENSAJE-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-CONFIRMA.
            DISPLAY 'CONFIRMA GUARDAR CAMBIOS? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRMA AT LINE 23 COLUMN 40.
            IF WS-CONFIRMA NOT = 'S' AND NOT = 's'
                MOVE 'CAMBIO CANCELADO' TO WS-MENSAJE
                GOTO 5000-EXIT
            END-IF.
       *
            OPEN I-O CUSTOMER-FILE.
            IF FL-CUSTOMER-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO CLIENTES'
                  TO WS-MENSAJE-ERROR
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
            MOVE WS-INGRESO-MENSUAL-EDIT TO WS-INGRESO-MENSUAL-DISP.
            MOVE WS-INGRESO-MENSUAL-DISP TO CUS-INGRESO-MENSUAL.
            MOVE WS-FECHA TO CUS-FECHA-ULT-MOD
                             CUS-FECHA-ULT-OP.
            MOVE WS-USUARIO-ID TO CUS-USUARIO-ULT-MOD.
       *
            REWRITE CUSTOMER-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ACTUALIZAR CLIENTE'
                      TO WS-MENSAJE-ERROR
                    CLOSE CUSTOMER-FILE
                    GOTO 5000-EXIT
            END-REWRITE.
       *
            IF FL-CUSTOMER-STATUS = '00'
                PERFORM 7000-REGISTRAR-AUDITORIA
                MOVE 'CLIENTE ACTUALIZADO EXITOSAMENTE' TO WS-MENSAJE
            ELSE
                STRING 'ERROR AL ACTUALIZAR COD '
                       FL-CUSTOMER-STATUS INTO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE CUSTOMER-FILE.
        5000-EXIT.
            EXIT.
       *
        6000-CONFIRMAR-SALIDA.
            MOVE SPACES TO WS-CONFIRMA.
            DISPLAY 'SALIR DE MODIFICACION? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRMA AT LINE 23 COLUMN 40.
            IF WS-CONFIRMA = 'S' OR 's'
                MOVE 'Y' TO WS-SWITCH-CONFIRM
            ELSE
                MOVE 'N' TO WS-SWITCH-CONFIRM
                MOVE 'SALIDA CANCELADA' TO WS-MENSAJE
            END-IF.
       *
        7000-REGISTRAR-AUDITORIA.
            OPEN I-O AUDITLOG-FILE.
            IF FL-AUDITLOG-STATUS = '00'
                MOVE 0 TO AUD-SEQ
                START AUDITLOG-FILE KEY IS NOT < AUD-SEQ
                    INVALID KEY
                        MOVE 0 TO AUD-SEQ
                        GOTO 7000-ESCRIBIR
                END-START
                READ AUDITLOG-FILE NEXT RECORD
                    AT END
                        MOVE 0 TO AUD-SEQ
                        GOTO 7000-ESCRIBIR
                END-READ
                IF AUD-SEQ IS NUMERIC
                    ADD 1 TO AUD-SEQ
                END-IF
        7000-ESCRIBIR.
                MOVE WS-FECHA TO AUD-DATE
                MOVE WS-HORA TO AUD-TIME
                MOVE WS-USUARIO-ID TO AUD-USUARIO
                MOVE 'CUSUPD00' TO AUD-PROGRAMA
                MOVE 'CA' TO AUD-EVENTO
                MOVE 'CL' TO AUD-ENTITY-TYPE
                MOVE CUS-ID TO AUD-ENTITY-KEY
                MOVE 'MODIFICACION DE CLIENTE' TO AUD-OBSERVACIONES
                MOVE 'O' TO AUD-RESULTADO
                WRITE AUDITLOG-RECORD
                CLOSE AUDITLOG-FILE
            END-IF.
       *
        END PROGRAM CUSUPD00.
