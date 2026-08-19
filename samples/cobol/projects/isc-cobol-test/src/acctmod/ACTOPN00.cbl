       *================================================================*
       * ACTOPN00 - APERTURA DE CUENTA                               *
       * PROPOSITO: CREAR NUEVA CUENTA, REGISTRAR TITULAR Y DEPOSITO *
       * EQUIPO: CONTABLE - 2002 (REVISADO 2005)                      *
       * ARCHIVOS: ACCOUNT, ACCTXREF, TRANLOG (ESCRITURA)             *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. ACTOPN00.
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
            SELECT ACCOUNT-FILE
                ASSIGN TO 'ACCOUNT.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS ACT-NBR
                FILE STATUS IS FL-ACCOUNT-STATUS.
       *
            SELECT ACCTXREF-FILE
                ASSIGN TO 'ACCTXREF.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS AXR-ID
                FILE STATUS IS FL-ACCTXREF-STATUS.
       *
            SELECT TRANLOG-FILE
                ASSIGN TO 'TRANLOG.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS TRN-SEQ
                FILE STATUS IS FL-TRANLOG-STATUS.
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
        FD  ACCOUNT-FILE
            RECORD 200 CHARACTERS.
        COPY FD-ACCOUNT.
       *
        FD  ACCTXREF-FILE
            RECORD 80 CHARACTERS.
        COPY FD-ACCOUNTXR.
       *
        FD  TRANLOG-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TRANLOG.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'ACTOPN00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-CUSTID                  PIC X(10).
            05  WS-CONFIRMA                PIC X(01).
            05  WS-ACCOUNT-NBR             PIC X(10).
            05  WS-NEXT-ACT-SEQ            PIC 9(10).
            05  WS-DEPOSITO-INICIAL        PIC 9(09)V99 COMP-3.
            05  WS-DEPOSITO-EDIT           PIC Z(09)9.99.
            05  WS-DEPOSITO-MIN            PIC 9(09)V99 COMP-3.
            05  WS-SEQ-NBR                 PIC 9(10).
            05  WS-OVERDRAFT-EDIT          PIC Z(09)9.99.
            05  WS-OVERDRAFT-LIMIT-DISP    PIC 9(09)V99 COMP-3.
            05  WS-DUMMY                   PIC X(01).
            05  WS-VAL-RETORNO             PIC 99.
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-APERTURA.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' APERTURA DE CUENTA'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-DATOS.
                10  LINE 04  COL 05  PIC X(15) VALUE 'CLIENTE ID:'.
                10  LINE 04  COL 22  PIC X(10)
                    USING WS-CUSTID AUTO PROMPT '__________'.
                10  LINE 04  COL 35  PIC X(20) VALUE 'PF3=BUSCAR CLIENTE'.
       *
                10  LINE 06  COL 05  PIC X(15) VALUE 'TIPO CUENTA:'.
                10  LINE 06  COL 22  PIC X(02)
                    USING ACT-TYPE AUTO PROMPT '__'.
                10  LINE 06  COL 30  PIC X(40)
                    VALUE 'CH=CHEQ  AH=AHORRO  NO=NOMINA  IN=INV'.
       *
                10  LINE 07  COL 05  PIC X(15) VALUE 'MONEDA:'.
                10  LINE 07  COL 22  PIC X(03)
                    USING ACT-CURRENCY AUTO PROMPT '___'.
                10  LINE 07  COL 30  PIC X(30)
                    VALUE 'MXN=MX  USD=US  EUR=EU'.
       *
                10  LINE 09  COL 05  PIC X(20) VALUE 'DEPOSITO INICIAL:'.
                10  LINE 09  COL 30  PIC Z(09)9.99
                    USING WS-DEPOSITO-EDIT AUTO.
       *
                10  LINE 11  COL 05  PIC X(20) VALUE 'SOBREGIRO LIMITE:'.
                10  LINE 11  COL 30  PIC Z(09)9.99
                    USING WS-OVERDRAFT-EDIT AUTO.
       *
                10  LINE 13  COL 05  PIC X(15) VALUE 'SUCURSAL:'.
                10  LINE 13  COL 22  PIC X(04)
                    USING ACT-BRANCH-OPEN AUTO PROMPT '____'.
                10  LINE 13  COL 30  PIC X(15) VALUE 'OFICIAL:'.
                10  LINE 13  COL 45  PIC X(08)
                    USING ACT-OFFICER AUTO.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF3=BSQ CLTE  PF4=GUARDAR  PF11=AYUDA'.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF12=CANCELAR'.
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
            PERFORM 2000-LIMPIAR-CAMPOS.
       *
        OPEN-LOOP.
            PERFORM 3000-REFRESCAR.
            DISPLAY SCR-APERTURA.
            ACCEPT SCR-APERTURA.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF3
                    CALL 'CUSSRH00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO OPEN-LOOP
       *
                WHEN WS-CRT-PF4
                    PERFORM 4000-GUARDAR-CUENTA
                    GO TO OPEN-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'ACTOPN00'
                    GO TO OPEN-LOOP
       *
                WHEN WS-CRT-PF12
                    PERFORM 5000-CONFIRMAR-CANCELAR
                    IF WS-CONFIRMED
                        GO TO OPEN-EXIT
                    ELSE
                        GO TO OPEN-LOOP
                    END-IF
       *
                WHEN WS-CRT-CLEAR
                    PERFORM 2000-LIMPIAR-CAMPOS
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO OPEN-LOOP
       *
                WHEN OTHER
                    MOVE 'USE PF3=BSQ PF4=GURDAR PF12=CANCELAR'
                      TO WS-MENSAJE-ERROR
                    GO TO OPEN-LOOP
            END-EVALUATE.
       *
        OPEN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE DATOS DE LA CUENTA, PF4=GUARDAR'
              TO WS-MENSAJE.
            PERFORM 1100-LIMPIAR.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        2000-LIMPIAR-CAMPOS.
            MOVE SPACES TO ACT-TYPE
                           ACT-CURRENCY
                           ACT-BRANCH-OPEN
                           ACT-OFFICER.
            MOVE ZEROS TO WS-DEPOSITO-EDIT
                          WS-DEPOSITO-INICIAL
                          WS-OVERDRAFT-EDIT
                          WS-OVERDRAFT-LIMIT-DISP.
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
        4000-GUARDAR-CUENTA.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-CUSTID = SPACES
                MOVE 'INGRESE O BUSQUE ID DE CLIENTE'
                  TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            IF ACT-TYPE = SPACES
                MOVE 'SELECCIONE TIPO DE CUENTA (CH/AH/NO/IN)'
                  TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            IF ACT-CURRENCY = SPACES
                MOVE 'SELECCIONE MONEDA (MXN/USD/EUR)'
                  TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            IF ACT-BRANCH-OPEN = SPACES
                MOVE 'INGRESE SUCURSAL' TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            MOVE WS-DEPOSITO-EDIT TO WS-DEPOSITO-INICIAL.
            MOVE WS-OVERDRAFT-EDIT TO WS-OVERDRAFT-LIMIT-DISP.
       *
            IF ACT-TYPE = 'CH'
                MOVE 500 TO WS-DEPOSITO-MIN
            ELSE
                IF ACT-TYPE = 'AH'
                    MOVE 100 TO WS-DEPOSITO-MIN
                ELSE
                    IF ACT-TYPE = 'NO'
                        MOVE 0 TO WS-DEPOSITO-MIN
                    ELSE
                        MOVE 1000 TO WS-DEPOSITO-MIN
                    END-IF
                END-IF
            END-IF.
       *
            IF WS-DEPOSITO-INICIAL < WS-DEPOSITO-MIN
                STRING 'DEPOSITO MINIMO ES ' WS-DEPOSITO-MIN
                  INTO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            PERFORM 6000-GENERAR-NUMERO-CUENTA.
       *
            MOVE WS-ACCOUNT-NBR TO ACT-NBR.
            MOVE WS-DEPOSITO-INICIAL TO ACT-BALANCE
                                        ACT-BALANCE-DISPONIBLE.
            MOVE ZEROS TO ACT-BALANCE-RETENIDO
                          ACT-BALANCE-SOBREGIRO
                          ACT-BALANCE-PROMEDIO
                          ACT-BALANCE-ANTERIOR
                          ACT-INTEREST-ACCRUED
                          ACT-TXN-COUNT-TODAY
                          ACT-TXN-COUNT-MONTH
                          ACT-CHECKS-ISSUED
                          ACT-CHECKS-BOUNCED
                          ACT-CHQ-STOP-COUNT.
            MOVE WS-OVERDRAFT-LIMIT-DISP TO ACT-OVERDRAFT-LIMIT.
            MOVE 0 TO ACT-OVERDRAFT-RATE.
            MOVE 0 TO ACT-INTEREST-RATE.
            MOVE 0 TO ACT-MONTHLY-FEE.
            MOVE WS-FECHA TO ACT-DATE-OPEN.
            MOVE ZEROS TO ACT-DATE-CLOSE.
            MOVE WS-FECHA TO ACT-DATE-LAST-ACTIVITY.
            MOVE ZEROS TO ACT-DATE-LAST-INT-CALC.
            MOVE ZEROS TO ACT-DATE-LAST-STATEMENT.
            MOVE 'A' TO ACT-STATUS.
            MOVE WS-USUARIO-ID TO ACT-USER-LAST-MOD.
            MOVE SPACES TO ACT-CHQBOOK-NBR.
            MOVE 1 TO ACT-CHQ-NEXT.
            MOVE 0 TO ACT-CHQ-LAST-USED.
       *
            OPEN I-O ACCOUNT-FILE.
            IF FL-ACCOUNT-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO CUENTAS'
                  TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            WRITE ACCOUNT-RECORD
                INVALID KEY
                    MOVE 'ERROR AL CREAR CUENTA - DUPLICADA'
                      TO WS-MENSAJE-ERROR
                    CLOSE ACCOUNT-FILE
                    GO TO 4000-EXIT
            END-WRITE.
       *
            IF FL-ACCOUNT-STATUS NOT = '00'
                STRING 'ERROR AL CREAR CUENTA COD '
                       FL-ACCOUNT-STATUS INTO WS-MENSAJE-ERROR
                CLOSE ACCOUNT-FILE
                GO TO 4000-EXIT
            END-IF.
       *
            CLOSE ACCOUNT-FILE.
       *
            PERFORM 7000-CREAR-ACCTXREF.
            PERFORM 8000-REGISTRAR-TRANSACCION.
            PERFORM 9000-REGISTRAR-AUDITORIA.
       *
            MOVE 'CUENTA CREADA EXITOSAMENTE' TO WS-MENSAJE.
            STRING 'CTA: ' WS-ACCOUNT-NBR INTO WS-MENSAJE.
       *
        4000-EXIT.
            EXIT.
       *
        5000-CONFIRMAR-CANCELAR.
            MOVE SPACES TO WS-CONFIRMA.
            DISPLAY 'CANCELAR APERTURA DE CUENTA? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRMA AT LINE 23 COLUMN 45.
            IF WS-CONFIRMA = 'S' OR 's'
                MOVE 'Y' TO WS-SWITCH-CONFIRM
            ELSE
                MOVE 'N' TO WS-SWITCH-CONFIRM
                MOVE 'OPERACION CANCELADA' TO WS-MENSAJE
            END-IF.
       *
        6000-GENERAR-NUMERO-CUENTA.
            MOVE 1 TO WS-NEXT-ACT-SEQ.
            OPEN I-O ACCOUNT-FILE.
            IF FL-ACCOUNT-STATUS = '00'
                MOVE HIGH-VALUES TO ACT-NBR
                START ACCOUNT-FILE KEY IS NOT < ACT-NBR
                    INVALID KEY
                        MOVE 1 TO WS-NEXT-ACT-SEQ
                        GO TO 6000-CONTINUE
                END-START
                READ ACCOUNT-FILE NEXT RECORD
                    AT END
                        MOVE 1 TO WS-NEXT-ACT-SEQ
                        GO TO 6000-CONTINUE
                END-READ
                IF ACT-NBR IS NUMERIC
                    COMPUTE WS-NEXT-ACT-SEQ =
                        FUNCTION NUMVAL(ACT-NBR) + 1
                END-IF
            END-IF.
        6000-CONTINUE.
            CLOSE ACCOUNT-FILE.
            MOVE WS-NEXT-ACT-SEQ TO WS-ACCOUNT-NBR.
       *
        7000-CREAR-ACCTXREF.
            STRING WS-CUSTID DELIMITED BY SPACES
                   WS-ACCOUNT-NBR DELIMITED BY SPACES
              INTO AXR-ID.
            MOVE WS-CUSTID TO AXR-CUSTOMER-ID.
            MOVE WS-ACCOUNT-NBR TO AXR-ACCOUNT-NBR.
            MOVE 'TI' TO AXR-ROL.
            MOVE 10000 TO AXR-PORCENTAJE.
            MOVE WS-FECHA TO AXR-FECHA-ALTA.
            MOVE ZEROS TO AXR-FECHA-BAJA.
            MOVE 'A' TO AXR-STATUS.
            MOVE WS-USUARIO-ID TO AXR-USUARIO-ALTA.
       *
            OPEN I-O ACCTXREF-FILE.
            IF FL-ACCTXREF-STATUS = '00'
                WRITE ACCTXREF-RECORD
                    INVALID KEY
                        MOVE 'ERROR AL CREAR RELACION TITULAR'
                          TO WS-MENSAJE-ERROR
                END-WRITE
            END-IF.
            CLOSE ACCTXREF-FILE.
       *
        8000-REGISTRAR-TRANSACCION.
            OPEN I-O TRANLOG-FILE.
            MOVE 0 TO TRN-SEQ.
            START TRANLOG-FILE KEY IS NOT < TRN-SEQ
                INVALID KEY
                    MOVE 0 TO TRN-SEQ
                    GO TO 8000-ESCRIBIR
            END-START.
            READ TRANLOG-FILE NEXT RECORD
                AT END
                    MOVE 0 TO TRN-SEQ
                    GO TO 8000-ESCRIBIR
            END-READ.
            IF TRN-SEQ IS NUMERIC
                ADD 1 TO TRN-SEQ
            END-IF.
        8000-ESCRIBIR.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'APE' TO TRN-TYPE.
            MOVE WS-ACCOUNT-NBR TO TRN-ACCOUNT-NBR.
            MOVE SPACES TO TRN-ACCOUNT-DEST.
            MOVE WS-CUSTID TO TRN-CUSTOMER-ID.
            MOVE WS-DEPOSITO-INICIAL TO TRN-AMOUNT.
            MOVE ZEROS TO TRN-AMOUNT-TAX.
            MOVE WS-DEPOSITO-INICIAL TO TRN-AMOUNT-TOTAL.
            MOVE WS-DEPOSITO-INICIAL TO TRN-AMOUNT-ORIGINAL.
            MOVE ZEROS TO TRN-FEE-AMOUNT.
            MOVE SPACES TO TRN-FEE-CODE.
            MOVE ACT-BRANCH-OPEN TO TRN-BRANCH.
            MOVE SPACES TO TRN-TELLER-ID.
            MOVE WS-USUARIO-ID TO TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '03' TO TRN-CHANNEL.
            MOVE 'APERTURA DE CUENTA' TO TRN-REFERENCE.
            MOVE 0 TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE 0 TO TRN-REVERSE-SEQ.
            MOVE 'APERTURA DE CUENTA' TO TRN-DESCRIPTION.
            WRITE TRANLOG-RECORD.
            CLOSE TRANLOG-FILE.
       *
        9000-REGISTRAR-AUDITORIA.
            OPEN I-O AUDITLOG-FILE.
            IF FL-AUDITLOG-STATUS = '00'
                MOVE 0 TO AUD-SEQ
                START AUDITLOG-FILE KEY IS NOT < AUD-SEQ
                    INVALID KEY
                        MOVE 0 TO AUD-SEQ
                        GO TO 9000-ESCRIBIR
                END-START
                READ AUDITLOG-FILE NEXT RECORD
                    AT END
                        MOVE 0 TO AUD-SEQ
                        GO TO 9000-ESCRIBIR
                END-READ
                IF AUD-SEQ IS NUMERIC
                    ADD 1 TO AUD-SEQ
                END-IF
        9000-ESCRIBIR.
                MOVE WS-FECHA TO AUD-DATE
                MOVE WS-HORA TO AUD-TIME
                MOVE WS-USUARIO-ID TO AUD-USUARIO
                MOVE 'ACTOPN00' TO AUD-PROGRAMA
                MOVE 'AL' TO AUD-EVENTO
                MOVE 'CT' TO AUD-ENTITY-TYPE
                MOVE WS-ACCOUNT-NBR TO AUD-ENTITY-KEY
                MOVE 'APERTURA DE CUENTA' TO AUD-OBSERVACIONES
                MOVE 'O' TO AUD-RESULTADO
                WRITE AUDITLOG-RECORD
                CLOSE AUDITLOG-FILE
            END-IF.
       *
        END PROGRAM ACTOPN00.
