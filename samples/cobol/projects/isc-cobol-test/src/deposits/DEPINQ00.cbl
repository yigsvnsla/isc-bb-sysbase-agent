       *================================================================*
       * DEPINQ00 - CONSULTA DE DEPOSITO                              *
       * PROPOSITO: VISUALIZAR DATOS COMPLETOS DE UN DEPOSITO         *
       * EQUIPO: AHORRO Y DEPOSITOS - 2001                            *
       * ARCHIVOS: DEPMAST (LECTURA)                                  *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. DEPINQ00.
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
            SELECT DEPMAST-FILE
                ASSIGN TO 'DEPMAST.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS DEP-NBR
                FILE STATUS IS FL-DEPMAST-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  DEPMAST-FILE
            RECORD 200 CHARACTERS.
        COPY FD-DEPMAST.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'DEPINQ00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-DEPNBR                  PIC X(10).
            05  WS-DUMMY                   PIC X(01).
            05  WS-AUDIT-DATA              PIC X(60).
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
                    VALUE ' CONSULTA DE DEPOSITO'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID.
                10  LINE 04  COL 05  PIC X(18) VALUE 'NUMERO DEPOSITO:'.
                10  LINE 04  COL 25  PIC X(10)
                    USING WS-DEPNBR AUTO PROMPT '__________'.
                10  LINE 04  COL 40  PIC X(20) VALUE 'ENTER=CONSULTA'.
       *
            05  SCR-DATOS.
                10  LINE 06  COL 05  PIC X(15) VALUE 'CLIENTE:'.
                10  LINE 06  COL 20  PIC X(10) FROM DEP-CUSTOMER-ID.
                10  LINE 06  COL 40  PIC X(15) VALUE 'TIPO:'.
                10  LINE 06  COL 55  PIC X(02) FROM DEP-TYPE.
       *
                10  LINE 07  COL 05  PIC X(15) VALUE 'PRODUCTO:'.
                10  LINE 07  COL 20  PIC X(04) FROM DEP-PRODUCT.
                10  LINE 07  COL 40  PIC X(15) VALUE 'ESTATUS:'.
                10  LINE 07  COL 55  PIC X(01) FROM DEP-STATUS.
       *
                10  LINE 09  COL 05  PIC X(15) VALUE 'SALDO:'.
                10  LINE 09  COL 22  PIC -(11)9.99 FROM DEP-BALANCE.
                10  LINE 09  COL 45  PIC X(20) VALUE 'SALDO MINIMO:'.
                10  LINE 09  COL 62  PIC -(11)9.99 FROM DEP-BALANCE-MIN.
       *
                10  LINE 10  COL 05  PIC X(20) VALUE 'INTERES ACRUADO:'.
                10  LINE 10  COL 25  PIC -(09)9.99 FROM DEP-INTEREST-ACCRUED.
                10  LINE 10  COL 45  PIC X(20) VALUE 'TASA INTERES:'.
                10  LINE 10  COL 62  PIC 9(03).9(04) FROM DEP-INTEREST-RATE.
       *
                10  LINE 12  COL 05  PIC X(15) VALUE 'APERTURA:'.
                10  LINE 12  COL 20  PIC 9(08) FROM DEP-DATE-OPEN.
                10  LINE 12  COL 40  PIC X(15) VALUE 'VENCIMIENTO:'.
                10  LINE 12  COL 55  PIC 9(08) FROM DEP-DATE-MATURITY.
       *
                10  LINE 13  COL 05  PIC X(15) VALUE 'ULT INTERES:'.
                10  LINE 13  COL 20  PIC 9(08) FROM DEP-DATE-LAST-INT.
                10  LINE 13  COL 40  PIC X(15) VALUE 'ULT TXN:'.
                10  LINE 13  COL 55  PIC 9(08) FROM DEP-DATE-LAST-TXN.
       *
                10  LINE 15  COL 05  PIC X(15) VALUE 'PLAZO DIAS:'.
                10  LINE 15  COL 20  PIC 9(04) FROM DEP-TERM-DAYS.
                10  LINE 15  COL 30  PIC X(15) VALUE 'PLAZO MESES:'.
                10  LINE 15  COL 45  PIC 9(03) FROM DEP-TERM-MONTHS.
       *
                10  LINE 16  COL 05  PIC X(20) VALUE 'RENOVACIONES:'.
                10  LINE 16  COL 20  PIC 9(03) FROM DEP-RENEWAL-COUNT.
                10  LINE 16  COL 30  PIC X(20) VALUE 'AUTO-RENOVAR:'.
                10  LINE 16  COL 50  PIC X(01) FROM DEP-RENEWAL-AUTO.
       *
                10  LINE 18  COL 05  PIC X(15) VALUE 'SUCURSAL:'.
                10  LINE 18  COL 20  PIC X(04) FROM DEP-BRANCH.
                10  LINE 18  COL 30  PIC X(20) VALUE 'CTA LIGADA:'.
                10  LINE 18  COL 50  PIC X(10) FROM DEP-ACCOUNT-LINKED.
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
            MOVE SPACES TO WS-DEPNBR.
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
                    PERFORM 3000-CONSULTAR-DEPOSITO
                    GO TO INQUIRY-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'DEPINQ00'
                    GO TO INQUIRY-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO INQUIRY-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-DEPNBR
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
            MOVE 'INGRESE NUMERO DE DEPOSITO Y PRESIONE ENTER'
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
        3000-CONSULTAR-DEPOSITO.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-DEPNBR = SPACES OR = LOW-VALUES
                MOVE 'INGRESE NUMERO DE DEPOSITO' TO WS-MENSAJE-ERROR
                GO TO 3000-EXIT
            END-IF.
       *
            OPEN I-O DEPMAST-FILE.
            IF FL-DEPMAST-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR ARCHIVO DEPOSITOS'
                  TO WS-MENSAJE-ERROR
                GO TO 3000-EXIT
            END-IF.
       *
            MOVE WS-DEPNBR TO DEP-NBR.
            READ DEPMAST-FILE KEY IS DEP-NBR
                INVALID KEY
                    MOVE 'DEPOSITO NO ENCONTRADO' TO WS-MENSAJE-ERROR
                    CLOSE DEPMAST-FILE
                    GO TO 3000-EXIT
            END-READ.
       *
            IF FL-DEPMAST-STATUS = '00'
                MOVE 'DEPOSITO ENCONTRADO - PRESIONE PF12=SALIR'
                  TO WS-MENSAJE
                STRING 'DEPINQ00 DEP=' WS-DEPNBR
                  INTO WS-AUDIT-DATA
                CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                      WS-AUDIT-DATA
            ELSE
                MOVE 'ERROR AL LEER DEPOSITO' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE DEPMAST-FILE.
        3000-EXIT.
            EXIT.
       *
        END PROGRAM DEPINQ00.
