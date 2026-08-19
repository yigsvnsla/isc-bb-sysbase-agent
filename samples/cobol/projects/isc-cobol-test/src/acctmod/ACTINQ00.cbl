       *================================================================*
       * ACTINQ00 - CONSULTA DE CUENTA                                *
       * PROPOSITO: VISUALIZAR DATOS COMPLETOS DE UNA CUENTA          *
       * EQUIPO: CONTABLE - 2003                                      *
       * ARCHIVOS: ACCOUNT, ACCTXREF (LECTURA)                        *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. ACTINQ00.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'ACTINQ00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-ACTNBR                  PIC X(10).
            05  WS-DUMMY                   PIC X(01).
            05  WS-IND                     PIC 9(03).
            05  WS-REL-COUNT               PIC 9(03).
            05  WS-BALANCE-DISP            PIC -(11)9.99.
            05  WS-XR-COUNT                PIC 9(02).
            05  WS-XR-IND                  PIC 9(02).
       *
        01  WS-XREF-LIST.
            05  WS-XR-ENTRY                OCCURS 10.
                10  WS-XR-CUS-ID           PIC X(10).
                10  WS-XR-ROL              PIC X(02).
                10  WS-XR-STAT             PIC X(01).
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
                    VALUE ' CONSULTA DE CUENTA'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID.
                10  LINE 04  COL 05  PIC X(15) VALUE 'NUMERO CUENTA:'.
                10  LINE 04  COL 22  PIC X(10)
                    USING WS-ACTNBR AUTO PROMPT '__________'.
                10  LINE 04  COL 35  PIC X(15) VALUE 'ENTER=CONSULTA'.
       *
            05  SCR-DATOS.
                10  LINE 06  COL 05  PIC X(10) VALUE 'TIPO:'.
                10  LINE 06  COL 16  PIC X(02) FROM ACT-TYPE.
                10  LINE 06  COL 25  PIC X(15) VALUE 'MONEDA:'.
                10  LINE 06  COL 35  PIC X(03) FROM ACT-CURRENCY.
                10  LINE 06  COL 45  PIC X(15) VALUE 'ESTATUS:'.
                10  LINE 06  COL 55  PIC X(01) FROM ACT-STATUS.
       *
                10  LINE 08  COL 05  PIC X(15) VALUE 'SALDO ACTUAL:'.
                10  LINE 08  COL 22  PIC -(11)9.99 FROM ACT-BALANCE.
                10  LINE 08  COL 45  PIC X(20) VALUE 'DISPONIBLE:'.
                10  LINE 08  COL 62  PIC -(11)9.99
                    FROM ACT-BALANCE-DISPONIBLE.
                10  LINE 09  COL 05  PIC X(15) VALUE 'RETENIDO:'.
                10  LINE 09  COL 22  PIC -(11)9.99
                    FROM ACT-BALANCE-RETENIDO.
                10  LINE 09  COL 45  PIC X(15) VALUE 'SOBREGIRO:'.
                10  LINE 09  COL 62  PIC -(11)9.99
                    FROM ACT-BALANCE-SOBREGIRO.
                10  LINE 10  COL 05  PIC X(15) VALUE 'PROMEDIO:'.
                10  LINE 10  COL 22  PIC -(11)9.99
                    FROM ACT-BALANCE-PROMEDIO.
                10  LINE 10  COL 45  PIC X(20) VALUE 'SALDO ANTERIOR:'.
                10  LINE 10  COL 62  PIC -(11)9.99
                    FROM ACT-BALANCE-ANTERIOR.
       *
                10  LINE 12  COL 05  PIC X(20) VALUE 'LIMITE SOBREGIRO:'.
                10  LINE 12  COL 28  PIC -(09)9.99
                    FROM ACT-OVERDRAFT-LIMIT.
                10  LINE 12  COL 45  PIC X(20) VALUE 'TASA SOBREGIR:'.
                10  LINE 12  COL 62  PIC 9(03).9(04)
                    FROM ACT-OVERDRAFT-RATE.
                10  LINE 13  COL 05  PIC X(20) VALUE 'TASA INTERES:'.
                10  LINE 13  COL 28  PIC 9(03).9(04)
                    FROM ACT-INTEREST-RATE.
                10  LINE 13  COL 45  PIC X(20) VALUE 'INTERES ACRU:'.
                10  LINE 13  COL 62  PIC -(09)9.99
                    FROM ACT-INTEREST-ACCRUED.
                10  LINE 14  COL 05  PIC X(20) VALUE 'COMISION MENSUAL:'.
                10  LINE 14  COL 28  PIC -(07)9.99
                    FROM ACT-MONTHLY-FEE.
       *
                10  LINE 16  COL 05  PIC X(15) VALUE 'FECHA APERTURA:'.
                10  LINE 16  COL 22  PIC 9(08) FROM ACT-DATE-OPEN.
                10  LINE 16  COL 40  PIC X(15) VALUE 'CIERRE:'.
                10  LINE 16  COL 55  PIC 9(08) FROM ACT-DATE-CLOSE.
                10  LINE 17  COL 05  PIC X(20) VALUE 'ULT ACTIVIDAD:'.
                10  LINE 17  COL 28  PIC 9(08) FROM ACT-DATE-LAST-ACTIVITY.
                10  LINE 17  COL 45  PIC X(20) VALUE 'ULT INT CALC:'.
                10  LINE 17  COL 62  PIC 9(08)
                    FROM ACT-DATE-LAST-INT-CALC.
                10  LINE 18  COL 05  PIC X(20) VALUE 'ULT ESTADO CT:'.
                10  LINE 18  COL 28  PIC 9(08)
                    FROM ACT-DATE-LAST-STATEMENT.
       *
                10  LINE 20  COL 05  PIC X(15) VALUE 'SUCURSAL:'.
                10  LINE 20  COL 16  PIC X(04) FROM ACT-BRANCH-OPEN.
                10  LINE 20  COL 25  PIC X(15) VALUE 'OFICIAL:'.
                10  LINE 20  COL 40  PIC X(08) FROM ACT-OFFICER.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF11=AYUDA  PF12=RETORNAR'.
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
            MOVE SPACES TO WS-ACTNBR.
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
                    PERFORM 3000-CONSULTAR-CUENTA
                    GO TO INQUIRY-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'ACTINQ00'
                    GO TO INQUIRY-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO INQUIRY-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-ACTNBR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO INQUIRY-LOOP
       *
                WHEN OTHER
                    MOVE 'USE ENTER=CONS  PF12=RETORNAR'
                      TO WS-MENSAJE-ERROR
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
            MOVE 'INGRESE NUMERO DE CUENTA Y PRESIONE ENTER'
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
        3000-CONSULTAR-CUENTA.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-ACTNBR = SPACES OR = LOW-VALUES
                MOVE 'INGRESE NUMERO DE CUENTA' TO WS-MENSAJE-ERROR
                GO TO 3000-EXIT
            END-IF.
       *
            OPEN I-O ACCOUNT-FILE.
            IF FL-ACCOUNT-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO CUENTAS'
                  TO WS-MENSAJE-ERROR
                GO TO 3000-EXIT
            END-IF.
       *
            MOVE WS-ACTNBR TO ACT-NBR.
            READ ACCOUNT-FILE KEY IS ACT-NBR
                INVALID KEY
                    MOVE 'CUENTA NO ENCONTRADA' TO WS-MENSAJE-ERROR
                    CLOSE ACCOUNT-FILE
                    GO TO 3000-EXIT
            END-READ.
       *
            IF FL-ACCOUNT-STATUS = '00'
                PERFORM 4000-CONSULTAR-XREF
                MOVE 'CUENTA ENCONTRADA - PRESIONE PF12=SALIR'
                  TO WS-MENSAJE
            ELSE
                MOVE 'ERROR AL LEER CUENTA' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE ACCOUNT-FILE.
        3000-EXIT.
            EXIT.
       *
        4000-CONSULTAR-XREF.
            MOVE 0 TO WS-XR-COUNT.
       *
            OPEN I-O ACCTXREF-FILE.
            IF FL-ACCTXREF-STATUS NOT = '00'
                GO TO 4000-EXIT
            END-IF.
       *
            MOVE SPACES TO AXR-ID.
            START ACCTXREF-FILE KEY IS NOT < AXR-ID
                INVALID KEY
                    CLOSE ACCTXREF-FILE
                    GO TO 4000-EXIT
            END-START.
       *
            MOVE 'N' TO WS-SWITCH-EOF.
            PERFORM UNTIL WS-EOF-YES
                READ ACCTXREF-FILE NEXT RECORD
                    AT END
                        MOVE 'Y' TO WS-SWITCH-EOF
                        GO TO 4000-CONTINUE
                END-READ
       *
                IF AXR-ACCOUNT-NBR = WS-ACTNBR
                    ADD 1 TO WS-XR-COUNT
                    MOVE AXR-CUSTOMER-ID
                      TO WS-XR-CUS-ID(WS-XR-COUNT)
                    MOVE AXR-ROL TO WS-XR-ROL(WS-XR-COUNT)
                    MOVE AXR-STATUS TO WS-XR-STAT(WS-XR-COUNT)
                END-IF
       *
                IF WS-XR-COUNT >= 10
                    MOVE 'Y' TO WS-SWITCH-EOF
                END-IF
            END-PERFORM.
       *
        4000-CONTINUE.
            CLOSE ACCTXREF-FILE.
       *
            PERFORM VARYING WS-XR-IND FROM 1 BY 1
                UNTIL WS-XR-IND > WS-XR-COUNT
                COMPUTE WS-LINEA = 20 + WS-XR-IND
                STRING 'CLIENTE: ' WS-XR-CUS-ID(WS-XR-IND)
                       ' ROL: ' WS-XR-ROL(WS-XR-IND)
                  INTO WS-DUMMY
                DISPLAY WS-DUMMY AT LINE WS-LINEA COLUMN 45
            END-PERFORM.
        4000-EXIT.
            EXIT.
       *
        END PROGRAM ACTINQ00.
