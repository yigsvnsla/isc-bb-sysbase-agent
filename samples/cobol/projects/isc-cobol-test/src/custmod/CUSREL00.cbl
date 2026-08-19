       *================================================================*
       * CUSREL00 - RELACIONES CLIENTE-CUENTA                          *
       * PROPOSITO: ADMINISTRAR TITULARES COTITULARES BENEFICIARIOS    *
       * EQUIPO: COMERCIAL - 2004                                     *
       * ARCHIVOS: ACCTXREF, ACCOUNT (LECTURA Y ESCRITURA)             *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. CUSREL00.
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
            SELECT ACCTXREF-FILE
                ASSIGN TO 'ACCTXREF.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS AXR-ID
                FILE STATUS IS FL-ACCTXREF-STATUS.
       *
            SELECT ACCOUNT-FILE
                ASSIGN TO 'ACCOUNT.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS ACT-NBR
                FILE STATUS IS FL-ACCOUNT-STATUS.
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
        FD  ACCTXREF-FILE
            RECORD 80 CHARACTERS.
        COPY FD-ACCOUNTXR.
       *
        FD  ACCOUNT-FILE
            RECORD 200 CHARACTERS.
        COPY FD-ACCOUNT.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'CUSREL00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-CUSTID                  PIC X(10).
            05  WS-DUMMY                   PIC X(01).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-PORCENTAJE-EDIT         PIC Z(03)9.99.
            05  WS-PORCENTAJE-DISP         PIC 9(03)V99 COMP-3.
            05  WS-OPCION                  PIC 9(02).
            05  WS-IND                     PIC 9(03).
            05  WS-REL-COUNT               PIC 9(03).
            05  WS-ACT-NBR                 PIC X(10).
            05  WS-ACT-TYPE-DISP           PIC X(02).
            05  WS-AXR-ROL-DISP            PIC X(15).
       *
        01  WS-RELACIONES.
            05  WS-REL-ENTRY               OCCURS 20.
                10  WS-REL-AXR-ID          PIC X(20).
                10  WS-REL-CUSTOMER-ID     PIC X(10).
                10  WS-REL-ACCOUNT-NBR     PIC X(10).
                10  WS-REL-ROL             PIC X(02).
                10  WS-REL-PORCENTAJE      PIC 9(03)V99 COMP-3.
                10  WS-REL-STATUS          PIC X(01).
       *
        01  WS-NEW-REL.
            05  WS-NEW-ACT-NBR             PIC X(10).
            05  WS-NEW-ROL                 PIC X(02).
            05  WS-NEW-PORCENTAJE          PIC 9(03)V99 COMP-3.
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-RELACIONES.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' RELACIONES CLIENTE-CUENTA'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID-CLIENTE.
                10  LINE 04  COL 05  PIC X(10) VALUE 'CLIENTE:'.
                10  LINE 04  COL 16  PIC X(10)
                    USING WS-CUSTID AUTO PROMPT '__________'.
                10  LINE 04  COL 30  PIC X(20) VALUE 'ENTER=CONSULTAR'.
       *
            05  SCR-LISTA-REL.
                10  LINE 06  COL 05  PIC X(60) VALUE ALL '-'.
                10  LINE 07  COL 05  PIC X(05) VALUE 'NUM'.
                10  LINE 07  COL 10  PIC X(10) VALUE 'CUENTA'.
                10  LINE 07  COL 22  PIC X(15) VALUE 'ROL'.
                10  LINE 07  COL 40  PIC X(10) VALUE 'PORCENTAJE'.
                10  LINE 07  COL 55  PIC X(10) VALUE 'ESTATUS'.
                10  LINE 08  COL 05  PIC X(60) VALUE ALL '-'.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF3=AGREGAR  PF4=BAJA  PF11=AYUDA'.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF12=RETORNAR'.
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
            MOVE 0 TO WS-REL-COUNT.
       *
            PERFORM 1000-INICIALIZAR.
       *
        REL-LOOP.
            PERFORM 3000-REFRESCAR.
            DISPLAY SCR-RELACIONES.
            ACCEPT SCR-RELACIONES.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 4000-CONSULTAR-RELACIONES
                    GO TO REL-LOOP
       *
                WHEN WS-CRT-PF3
                    PERFORM 5000-AGREGAR-RELACION
                    GO TO REL-LOOP
       *
                WHEN WS-CRT-PF4
                    PERFORM 6000-BAJA-RELACION
                    GO TO REL-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'CUSREL00'
                    GO TO REL-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO REL-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-CUSTID
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    MOVE 0 TO WS-REL-COUNT
                    GO TO REL-LOOP
       *
                WHEN OTHER
                    MOVE 'USE PF3=AGREGAR PF4=BAJA PF12=SALIR'
                      TO WS-MENSAJE-ERROR
                    GO TO REL-LOOP
            END-EVALUATE.
       *
        REL-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE ID CLIENTE PARA VER RELACIONES' TO WS-MENSAJE.
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
        4000-CONSULTAR-RELACIONES.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            MOVE 0 TO WS-REL-COUNT.
       *
            IF WS-CUSTID = SPACES
                MOVE 'INGRESE ID DE CLIENTE' TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            OPEN I-O ACCTXREF-FILE.
            IF FL-ACCTXREF-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO XREF'
                  TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE SPACES TO AXR-ID.
            START ACCTXREF-FILE KEY IS NOT < AXR-ID
                INVALID KEY
                    MOVE 'NO HAY RELACIONES REGISTRADAS'
                      TO WS-MENSAJE-ERROR
                    CLOSE ACCTXREF-FILE
                    GOTO 4000-EXIT
            END-START.
       *
            MOVE 'N' TO WS-SWITCH-EOF.
            PERFORM UNTIL WS-EOF-YES
                READ ACCTXREF-FILE NEXT RECORD
                    AT END
                        MOVE 'Y' TO WS-SWITCH-EOF
                        GOTO 4000-CONTINUE
                END-READ
       *
                IF AXR-CUSTOMER-ID = WS-CUSTID
                    ADD 1 TO WS-REL-COUNT
                    MOVE AXR-ID TO WS-REL-AXR-ID(WS-REL-COUNT)
                    MOVE AXR-CUSTOMER-ID
                      TO WS-REL-CUSTOMER-ID(WS-REL-COUNT)
                    MOVE AXR-ACCOUNT-NBR
                      TO WS-REL-ACCOUNT-NBR(WS-REL-COUNT)
                    MOVE AXR-ROL TO WS-REL-ROL(WS-REL-COUNT)
                    MOVE AXR-PORCENTAJE
                      TO WS-REL-PORCENTAJE(WS-REL-COUNT)
                    MOVE AXR-STATUS TO WS-REL-STATUS(WS-REL-COUNT)
                END-IF
       *
                IF WS-REL-COUNT >= 20
                    MOVE 'Y' TO WS-SWITCH-EOF
                END-IF
            END-PERFORM.
       *
        4000-CONTINUE.
            CLOSE ACCTXREF-FILE.
       *
            IF WS-REL-COUNT = 0
                MOVE 'NO SE ENCONTRARON RELACIONES' TO WS-MENSAJE-ERROR
            ELSE
                STRING WS-REL-COUNT ' RELACION(ES) ENCONTRADA(S)'
                  INTO WS-MENSAJE
                PERFORM 4200-MOSTRAR-RELACIONES
            END-IF.
        4000-EXIT.
            EXIT.
       *
        4200-MOSTRAR-RELACIONES.
            PERFORM VARYING WS-IND FROM 1 BY 1
                UNTIL WS-IND > WS-REL-COUNT
                COMPUTE WS-LINEA = WS-IND + 8
                IF WS-LINEA > 21
                    EXIT PERFORM
                END-IF
                DISPLAY WS-IND AT LINE WS-LINEA COLUMN 05
                DISPLAY WS-REL-ACCOUNT-NBR(WS-IND)
                    AT LINE WS-LINEA COLUMN 10
                MOVE WS-REL-ROL(WS-IND) TO WS-AXR-ROL-DISP
                EVALUATE WS-REL-ROL(WS-IND)
                    WHEN 'TI'
                        MOVE 'TITULAR' TO WS-AXR-ROL-DISP
                    WHEN 'CO'
                        MOVE 'COTITULAR' TO WS-AXR-ROL-DISP
                    WHEN 'BE'
                        MOVE 'BENEFICIARIO' TO WS-AXR-ROL-DISP
                    WHEN 'AU'
                        MOVE 'AUTORIZADO' TO WS-AXR-ROL-DISP
                    WHEN 'FI'
                        MOVE 'FIRMA' TO WS-AXR-ROL-DISP
                    WHEN 'GA'
                        MOVE 'GARANTE' TO WS-AXR-ROL-DISP
                    WHEN OTHER
                        MOVE WS-REL-ROL(WS-IND) TO WS-AXR-ROL-DISP
                END-EVALUATE
                DISPLAY WS-AXR-ROL-DISP AT LINE WS-LINEA COLUMN 22
                MOVE WS-REL-PORCENTAJE(WS-IND) TO WS-PORCENTAJE-DISP
                MOVE WS-PORCENTAJE-DISP TO WS-PORCENTAJE-EDIT
                DISPLAY WS-PORCENTAJE-EDIT AT LINE WS-LINEA COLUMN 40
                MOVE WS-REL-STATUS(WS-IND) TO WS-AXR-ROL-DISP
                EVALUATE WS-REL-STATUS(WS-IND)
                    WHEN 'A'
                        MOVE 'ACTIVO' TO WS-AXR-ROL-DISP
                    WHEN 'I'
                        MOVE 'INACTIVO' TO WS-AXR-ROL-DISP
                    WHEN 'S'
                        MOVE 'SUSPENDIDO' TO WS-AXR-ROL-DISP
                    WHEN OTHER
                        MOVE 'DESCONOCIDO' TO WS-AXR-ROL-DISP
                END-EVALUATE
                DISPLAY WS-AXR-ROL-DISP AT LINE WS-LINEA COLUMN 55
            END-PERFORM.
       *
        5000-AGREGAR-RELACION.
            IF WS-CUSTID = SPACES
                MOVE 'PRIMERO CONSULTE UN CLIENTE' TO WS-MENSAJE-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-NEW-ACT-NBR
                           WS-NEW-ROL.
            MOVE 0 TO WS-NEW-PORCENTAJE.
       *
            DISPLAY 'CUENTA: ' AT LINE 20 COLUMN 05.
            ACCEPT WS-NEW-ACT-NBR AT LINE 20 COLUMN 14.
       *
            IF WS-NEW-ACT-NBR = SPACES
                MOVE 'INGRESE NUMERO DE CUENTA' TO WS-MENSAJE-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            OPEN I-O ACCOUNT-FILE.
            IF FL-ACCOUNT-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO CUENTAS'
                  TO WS-MENSAJE-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            MOVE WS-NEW-ACT-NBR TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CUENTA NO ENCONTRADA' TO WS-MENSAJE-ERROR
                    CLOSE ACCOUNT-FILE
                    GOTO 5000-EXIT
            END-READ.
            CLOSE ACCOUNT-FILE.
       *
            DISPLAY 'ROL (TI/CO/BE/AU/FI/GA): ' AT LINE 21 COLUMN 05.
            ACCEPT WS-NEW-ROL AT LINE 21 COLUMN 32.
       *
            IF WS-NEW-ROL = SPACES
                MOVE 'SELECCIONE ROL' TO WS-MENSAJE-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            DISPLAY 'PORCENTAJE (000.00): ' AT LINE 21 COLUMN 40.
            ACCEPT WS-PORCENTAJE-EDIT AT LINE 21 COLUMN 62.
            MOVE WS-PORCENTAJE-EDIT TO WS-PORCENTAJE-DISP.
            MOVE WS-PORCENTAJE-DISP TO WS-NEW-PORCENTAJE.
       *
            STRING WS-CUSTID DELIMITED BY SPACES
                   WS-NEW-ACT-NBR DELIMITED BY SPACES
              INTO AXR-ID.
            MOVE WS-CUSTID TO AXR-CUSTOMER-ID.
            MOVE WS-NEW-ACT-NBR TO AXR-ACCOUNT-NBR.
            MOVE WS-NEW-ROL TO AXR-ROL.
            MOVE WS-NEW-PORCENTAJE TO AXR-PORCENTAJE.
            MOVE WS-FECHA TO AXR-FECHA-ALTA.
            MOVE ZEROS TO AXR-FECHA-BAJA.
            MOVE 'A' TO AXR-STATUS.
            MOVE WS-USUARIO-ID TO AXR-USUARIO-ALTA.
       *
            OPEN I-O ACCTXREF-FILE.
            IF FL-ACCTXREF-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO XREF'
                  TO WS-MENSAJE-ERROR
                GOTO 5000-EXIT
            END-IF.
       *
            WRITE ACCTXREF-RECORD
                INVALID KEY
                    MOVE 'ERROR AL CREAR RELACION - DUPLICADO'
                      TO WS-MENSAJE-ERROR
                    CLOSE ACCTXREF-FILE
                    GOTO 5000-EXIT
            END-WRITE.
       *
            IF FL-ACCTXREF-STATUS = '00'
                PERFORM 7000-REGISTRAR-AUDITORIA
                MOVE 'RELACION AGREGADA EXITOSAMENTE' TO WS-MENSAJE
                PERFORM 4000-CONSULTAR-RELACIONES
            ELSE
                MOVE 'ERROR AL CREAR RELACION' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE ACCTXREF-FILE.
        5000-EXIT.
            EXIT.
       *
        6000-BAJA-RELACION.
            IF WS-REL-COUNT = 0
                MOVE 'NO HAY RELACIONES PARA DAR DE BAJA'
                  TO WS-MENSAJE-ERROR
                GOTO 6000-EXIT
            END-IF.
       *
            DISPLAY 'NUMERO DE RELACION A ELIMINAR: '
                AT LINE 20 COLUMN 05.
            ACCEPT WS-OPCION AT LINE 20 COLUMN 35.
       *
            IF WS-OPCION < 1 OR WS-OPCION > WS-REL-COUNT
                MOVE 'NUMERO INVALIDO' TO WS-MENSAJE-ERROR
                GOTO 6000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-CONFIRMA.
            DISPLAY 'CONFIRMA BAJA DE RELACION? (S/N): '
                AT LINE 21 COLUMN 05.
            ACCEPT WS-CONFIRMA AT LINE 21 COLUMN 40.
            IF WS-CONFIRMA NOT = 'S' AND NOT = 's'
                MOVE 'BAJA CANCELADA' TO WS-MENSAJE
                GOTO 6000-EXIT
            END-IF.
       *
            OPEN I-O ACCTXREF-FILE.
            IF FL-ACCTXREF-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR ARCHIVO' TO WS-MENSAJE-ERROR
                GOTO 6000-EXIT
            END-IF.
       *
            MOVE WS-REL-AXR-ID(WS-OPCION) TO AXR-ID.
            READ ACCTXREF-FILE KEY IS AXR-ID
                INVALID KEY
                    MOVE 'RELACION NO ENCONTRADA' TO WS-MENSAJE-ERROR
                    CLOSE ACCTXREF-FILE
                    GOTO 6000-EXIT
            END-READ.
       *
            MOVE 'I' TO AXR-STATUS.
            MOVE WS-FECHA TO AXR-FECHA-BAJA.
            REWRITE ACCTXREF-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ACTUALIZAR RELACION'
                      TO WS-MENSAJE-ERROR
                    CLOSE ACCTXREF-FILE
                    GOTO 6000-EXIT
            END-REWRITE.
       *
            IF FL-ACCTXREF-STATUS = '00'
                PERFORM 7000-REGISTRAR-AUDITORIA
                MOVE 'RELACION DADA DE BAJA' TO WS-MENSAJE
                PERFORM 4000-CONSULTAR-RELACIONES
            ELSE
                MOVE 'ERROR AL DAR BAJA' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE ACCTXREF-FILE.
        6000-EXIT.
            EXIT.
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
                MOVE 'CUSREL00' TO AUD-PROGRAMA
                MOVE 'AL' TO AUD-EVENTO
                MOVE 'CL' TO AUD-ENTITY-TYPE
                MOVE AXR-ID TO AUD-ENTITY-KEY
                MOVE 'RELACION CLIENTE-CUENTA' TO AUD-OBSERVACIONES
                MOVE 'O' TO AUD-RESULTADO
                WRITE AUDITLOG-RECORD
                CLOSE AUDITLOG-FILE
            END-IF.
       *
        END PROGRAM CUSREL00.
