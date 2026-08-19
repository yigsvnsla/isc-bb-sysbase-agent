       *================================================================*
       * CUSMNT00 - ALTA DE CLIENTE                                   *
       * PROPOSITO: REGISTRO DE NUEVO CLIENTE EN EL SISTEMA           *
       * EQUIPO: COMERCIAL - 2002                                     *
       * ARCHIVOS: CUSTOMER, ACCTXREF (ESCRITURA)                      *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. CUSMNT00.
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
            SELECT ACCTXREF-FILE
                ASSIGN TO 'ACCTXREF.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS AXR-ID
                FILE STATUS IS FL-ACCTXREF-STATUS.
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
        FD  ACCTXREF-FILE
            RECORD 80 CHARACTERS.
        COPY FD-ACCOUNTXR.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'CUSMNT00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-DUMMY                   PIC X(01).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-INGRESO-MENSUAL-DISP    PIC 9(09)V99 COMP-3.
            05  WS-INGRESO-MENSUAL-EDIT    PIC Z(09)9.99.
            05  WS-VAL-RETORNO             PIC 99.
            05  WS-AUD-SEQ-NBR             PIC 9(10).
            05  WS-NEXT-CUS-ID             PIC 9(10).
            05  WS-NEXT-CUS-ID-DISP        PIC Z(09)9.
            05  WS-ABRE-CUENTA             PIC X(01).
            05  W-IND                      PIC 9(02).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-ALTA.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' ALTA DE CLIENTE'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-DATOS.
                10  LINE 04  COL 05  PIC X(15) VALUE 'TIPO PERSONA:'.
                10  LINE 04  COL 22  PIC X(02)
                    USING CUS-ID-TYPE AUTO PROMPT '__'.
                10  LINE 04  COL 30  PIC X(30)
                    VALUE 'PF=PFISICA  PM=MORAL  GO=GOB'.
       *
                10  LINE 05  COL 05  PIC X(10) VALUE 'NOMBRE:'.
                10  LINE 05  COL 16  PIC X(60)
                    USING CUS-NAME AUTO.
                10  LINE 06  COL 05  PIC X(15) VALUE 'APELLIDO PAT:'.
                10  LINE 06  COL 22  PIC X(30)
                    USING CUS-FIRST-LASTNAME AUTO.
                10  LINE 06  COL 55  PIC X(15) VALUE 'APELLIDO MAT:'.
                10  LINE 07  COL 05  PIC X(10) VALUE 'RFC:'.
                10  LINE 07  COL 16  PIC X(13)
                    USING CUS-RFC AUTO PROMPT '_____________'.
                10  LINE 07  COL 35  PIC X(10) VALUE 'CURP:'.
                10  LINE 07  COL 45  PIC X(18)
                    USING CUS-CURP AUTO.
       *
                10  LINE 09  COL 05  PIC X(15) VALUE 'CALLE:'.
                10  LINE 09  COL 22  PIC X(40)
                    USING CUS-STRET AUTO.
                10  LINE 10  COL 05  PIC X(15) VALUE 'NUM EXT:'.
                10  LINE 10  COL 22  PIC X(10)
                    USING CUS-NUM-EXT AUTO.
                10  LINE 10  COL 40  PIC X(15) VALUE 'NUM INT:'.
                10  LINE 10  COL 55  PIC X(10)
                    USING CUS-NUM-INT AUTO.
                10  LINE 11  COL 05  PIC X(15) VALUE 'COLONIA:'.
                10  LINE 11  COL 22  PIC X(30)
                    USING CUS-COLONIA AUTO.
                10  LINE 11  COL 55  PIC X(10) VALUE 'CP:'.
                10  LINE 11  COL 65  PIC X(05)
                    USING CUS-CP AUTO.
                10  LINE 12  COL 05  PIC X(15) VALUE 'CIUDAD:'.
                10  LINE 12  COL 22  PIC X(30)
                    USING CUS-CIUDAD AUTO.
                10  LINE 12  COL 55  PIC X(10) VALUE 'ESTADO:'.
                10  LINE 12  COL 65  PIC X(20)
                    USING CUS-ESTADO AUTO.
                10  LINE 13  COL 05  PIC X(15) VALUE 'PAIS:'.
                10  LINE 13  COL 22  PIC X(20)
                    USING CUS-PAIS AUTO.
       *
                10  LINE 15  COL 05  PIC X(15) VALUE 'TEL1:'.
                10  LINE 15  COL 22  PIC X(15)
                    USING CUS-TELEFONO1 AUTO.
                10  LINE 15  COL 40  PIC X(15) VALUE 'TEL2:'.
                10  LINE 15  COL 55  PIC X(15)
                    USING CUS-TELEFONO2 AUTO.
                10  LINE 16  COL 05  PIC X(10) VALUE 'CEL:'.
                10  LINE 16  COL 22  PIC X(15)
                    USING CUS-CELULAR AUTO.
                10  LINE 16  COL 40  PIC X(10) VALUE 'EMAIL:'.
                10  LINE 16  COL 55  PIC X(50)
                    USING CUS-EMAIL AUTO.
       *
                10  LINE 18  COL 05  PIC X(15) VALUE 'EMPRESA:'.
                10  LINE 18  COL 22  PIC X(40)
                    USING CUS-EMPRESA AUTO.
                10  LINE 19  COL 05  PIC X(15) VALUE 'PUESTO:'.
                10  LINE 19  COL 22  PIC X(30)
                    USING CUS-PUESTO AUTO.
                10  LINE 20  COL 05  PIC X(20) VALUE 'INGRESO MENSUAL:'.
                10  LINE 20  COL 30  PIC Z(09)9.99
                    USING WS-INGRESO-MENSUAL-EDIT AUTO.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF3=GUARDAR  PF11=AYUDA  PF12=CANCELAR'.
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
            MOVE 'N' TO WS-ABRE-CUENTA.
       *
            PERFORM 1000-INICIALIZAR.
            PERFORM 2000-LIMPIAR-CAMPOS.
       *
        ALTA-LOOP.
            PERFORM 3000-REFRESCAR.
            DISPLAY SCR-ALTA.
            ACCEPT SCR-ALTA.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF3
                    PERFORM 4000-GUARDAR-CLIENTE
                    GO TO ALTA-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'CUSMNT00'
                    GO TO ALTA-LOOP
       *
                WHEN WS-CRT-PF12
                    PERFORM 5000-CONFIRMAR-CANCELAR
                    IF WS-CONFIRMED
                        GO TO ALTA-EXIT
                    ELSE
                        GO TO ALTA-LOOP
                    END-IF
       *
                WHEN WS-CRT-CLEAR
                    PERFORM 2000-LIMPIAR-CAMPOS
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO ALTA-LOOP
       *
                WHEN OTHER
                    MOVE 'USE PF3=GUARDAR PF12=CANCELAR'
                      TO WS-MENSAJE-ERROR
                    GO TO ALTA-LOOP
            END-EVALUATE.
       *
        ALTA-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE DATOS DEL CLIENTE, PF3=GUARDAR'
              TO WS-MENSAJE.
            PERFORM 1100-LIMPIAR.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        2000-LIMPIAR-CAMPOS.
            MOVE SPACES TO CUS-ID
                           CUS-ID-TYPE
                           CUS-NAME
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
        4000-GUARDAR-CLIENTE.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF CUS-ID-TYPE = SPACES
                MOVE 'SELECCIONE TIPO PERSONA (PF/PM/GO)'
                  TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF CUS-NAME = SPACES
                MOVE 'NOMBRE ES REQUERIDO' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            IF CUS-RFC = SPACES
                MOVE 'RFC ES REQUERIDO' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            CALL 'COMVALF' USING 'REQ'
                                 CUS-NAME
                                 SPACES
                                 WS-VAL-RETORNO.
            IF WS-VAL-RETORNO NOT = 0
                MOVE 'NOMBRE ES REQUERIDO' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            CALL 'COMVALF' USING 'RFC'
                                 CUS-RFC
                                 SPACES
                                 WS-VAL-RETORNO.
            IF WS-VAL-RETORNO NOT = 0
                MOVE 'FORMATO RFC INVALIDO' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            PERFORM 6000-GENERAR-ID-CLIENTE.
       *
            MOVE WS-INGRESO-MENSUAL-EDIT TO WS-INGRESO-MENSUAL-DISP.
            MOVE WS-INGRESO-MENSUAL-DISP TO CUS-INGRESO-MENSUAL.
       *
            OPEN I-O CUSTOMER-FILE.
            IF FL-CUSTOMER-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO CLIENTES'
                  TO WS-MENSAJE-ERROR
                CLOSE CUSTOMER-FILE
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE WS-FECHA TO CUS-FECHA-ALTA
                             CUS-FECHA-ULT-MOD
                             CUS-FECHA-ULT-OP.
            MOVE WS-USUARIO-ID TO CUS-USUARIO-ALTA
                                  CUS-USUARIO-ULT-MOD.
            MOVE 'A' TO CUS-STATUS.
            MOVE '01' TO CUS-SEGMENTO.
            MOVE 'A' TO CUS-RIESGO-CATEGORIA.
       *
            WRITE CUSTOMER-RECORD
                INVALID KEY
                    MOVE 'ERROR AL CREAR CLIENTE - YA EXISTE'
                      TO WS-MENSAJE-ERROR
                    CLOSE CUSTOMER-FILE
                    GOTO 4000-EXIT
            END-WRITE.
       *
            IF FL-CUSTOMER-STATUS NOT = '00'
                STRING 'ERROR AL CREAR CLIENTE COD '
                       FL-CUSTOMER-STATUS INTO WS-MENSAJE-ERROR
                CLOSE CUSTOMER-FILE
                GOTO 4000-EXIT
            END-IF.
       *
            CLOSE CUSTOMER-FILE.
       *
            PERFORM 7000-REGISTRAR-AUDITORIA.
       *
            MOVE 'CLIENTE CREADO EXITOSAMENTE' TO WS-MENSAJE.
            PERFORM 8000-PREGUNTAR-ABRIR-CUENTA.
       *
        4000-EXIT.
            EXIT.
       *
        5000-CONFIRMAR-CANCELAR.
            MOVE SPACES TO WS-CONFIRMA.
            DISPLAY 'CANCELAR ALTA DE CLIENTE? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRMA AT LINE 23 COLUMN 40.
            IF WS-CONFIRMA = 'S' OR 's'
                MOVE 'Y' TO WS-SWITCH-CONFIRM
            ELSE
                MOVE 'N' TO WS-SWITCH-CONFIRM
                MOVE 'OPERACION CANCELADA' TO WS-MENSAJE
            END-IF.
       *
        6000-GENERAR-ID-CLIENTE.
            MOVE 1 TO WS-NEXT-CUS-ID.
            OPEN I-O CUSTOMER-FILE.
            IF FL-CUSTOMER-STATUS = '00'
                MOVE HIGH-VALUES TO CUS-ID
                START CUSTOMER-FILE KEY IS NOT < CUS-ID
                    INVALID KEY
                        MOVE 1 TO WS-NEXT-CUS-ID
                        GOTO 6000-CONTINUE
                END-START
                READ CUSTOMER-FILE NEXT RECORD
                    AT END
                        MOVE 1 TO WS-NEXT-CUS-ID
                        GOTO 6000-CONTINUE
                END-READ
                IF CUS-ID IS NUMERIC
                    COMPUTE WS-NEXT-CUS-ID = FUNCTION NUMVAL(CUS-ID)
                                           + 1
                END-IF
            END-IF.
        6000-CONTINUE.
            CLOSE CUSTOMER-FILE.
            MOVE WS-NEXT-CUS-ID TO CUS-ID.
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
                MOVE 'CUSMNT00' TO AUD-PROGRAMA
                MOVE 'AL' TO AUD-EVENTO
                MOVE 'CL' TO AUD-ENTITY-TYPE
                MOVE CUS-ID TO AUD-ENTITY-KEY
                MOVE 'ALTA DE CLIENTE' TO AUD-OBSERVACIONES
                MOVE 'O' TO AUD-RESULTADO
                WRITE AUDITLOG-RECORD
                CLOSE AUDITLOG-FILE
            END-IF.
       *
        8000-PREGUNTAR-ABRIR-CUENTA.
            MOVE SPACES TO WS-CONFIRMA.
            DISPLAY 'DESEA ABRIR CUENTA PARA ESTE CLIENTE? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRMA AT LINE 23 COLUMN 50.
            IF WS-CONFIRMA = 'S' OR 's'
                MOVE 'Y' TO WS-SWITCH-CONFIRM
                CALL 'ACTOPN00' USING WS-USUARIO-ID
                                      WS-RETCODE
            ELSE
                MOVE 'N' TO WS-SWITCH-CONFIRM
            END-IF.
       *
        END PROGRAM CUSMNT00.
