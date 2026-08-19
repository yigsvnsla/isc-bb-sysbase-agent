       *================================================================*
       * DEPOPN00 - APERTURA DE DEPOSITO                              *
       * PROPOSITO: ALTA DE NUEVO DEPOSITO (AHORRO/PLAZO/RECURRENTE)  *
       * EQUIPO: AHORRO Y DEPOSITOS - 2002                            *
       * ARCHIVOS: DEPMAST (ESCRITURA), RATEFILE (LECTURA), TRANLOG   *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. DEPOPN00.
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
       *
            SELECT RATEFILE-FILE
                ASSIGN TO 'RATEFILE.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS RAT-CODIGO
                FILE STATUS IS FL-RATEFILE-STATUS.
       *
            SELECT TRANLOG-FILE
                ASSIGN TO 'TRANLOG.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS TRN-SEQ
                FILE STATUS IS FL-TRANLOG-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  DEPMAST-FILE
            RECORD 200 CHARACTERS.
        COPY FD-DEPMAST.
       *
        FD  RATEFILE-FILE
            RECORD 100 CHARACTERS.
        COPY FD-RATEFILE.
       *
        FD  TRANLOG-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TRANLOG.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'DEPOPN00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-DEPNBR                  PIC X(10).
            05  WS-CUSTOMER-ID             PIC X(10).
            05  WS-DEP-TYPE                PIC X(02).
            05  WS-DEP-PRODUCT             PIC X(04).
            05  WS-DEP-AMOUNT              PIC 9(13)V99 COMP-3.
            05  WS-DEP-TERM-DAYS           PIC 9(04).
            05  WS-DEP-TERM-MONTHS         PIC 9(03).
            05  WS-DEP-AUTO-RENEW          PIC X(01).
            05  WS-DEP-ACCT-LINKED         PIC X(10).
            05  WS-CONFIRM                 PIC X(01).
            05  WS-AUDIT-DATA              PIC X(60).
            05  WS-TRN-SEQ-AUX             PIC 9(10).
            05  WS-TASA-ENCONTRADA         PIC X(01).
                88  WS-TASA-OK             VALUE 'S'.
                88  WS-TASA-NO             VALUE 'N'.
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
                    VALUE ' APERTURA DE DEPOSITO'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-DATOS.
                10  LINE 04  COL 05  PIC X(20) VALUE 'CLIENTE:'.
                10  LINE 04  COL 25  PIC X(10)
                    USING WS-CUSTOMER-ID AUTO PROMPT '__________'.
                10  LINE 04  COL 40  PIC X(30)
                    VALUE 'ENTER=CONS CLIENTE  PF1=SRH'.
       *
                10  LINE 06  COL 05  PIC X(20) VALUE 'TIPO DEPOSITO:'.
                10  LINE 06  COL 25  PIC X(02)
                    USING WS-DEP-TYPE AUTO PROMPT '__'.
                10  LINE 06  COL 35  PIC X(40)
                    VALUE 'AH=AHORRO  PL=PLAZO  RC=RECUR'.
       *
                10  LINE 07  COL 05  PIC X(20) VALUE 'PRODUCTO:'.
                10  LINE 07  COL 25  PIC X(04)
                    USING WS-DEP-PRODUCT AUTO PROMPT '____'.
       *
                10  LINE 08  COL 05  PIC X(20) VALUE 'MONTO:'.
                10  LINE 08  COL 25  PIC -(11)9.99
                    USING WS-DEP-AMOUNT AUTO.
       *
                10  LINE 10  COL 05  PIC X(20) VALUE 'PLAZO DIAS:'.
                10  LINE 10  COL 25  PIC 9(04)
                    USING WS-DEP-TERM-DAYS AUTO.
                10  LINE 10  COL 40  PIC X(20) VALUE 'PLAZO MESES:'.
                10  LINE 10  COL 60  PIC 9(03)
                    USING WS-DEP-TERM-MONTHS AUTO.
       *
                10  LINE 12  COL 05  PIC X(20) VALUE 'AUTO-RENOVAR:'.
                10  LINE 12  COL 25  PIC X(01)
                    USING WS-DEP-AUTO-RENEW AUTO PROMPT '_'.
                10  LINE 12  COL 35  PIC X(20) VALUE '(Y/N)'.
       *
                10  LINE 13  COL 05  PIC X(20) VALUE 'CTA LIGADA:'.
                10  LINE 13  COL 25  PIC X(10)
                    USING WS-DEP-ACCT-LINKED AUTO PROMPT '__________'.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF1=SRH CLI  PF11=AYU  PF12=CANCEL  ENTER=OK'.
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
            MOVE SPACES TO WS-CUSTOMER-ID
                           WS-DEP-TYPE
                           WS-DEP-PRODUCT
                           WS-DEP-AUTO-RENEW
                           WS-DEP-ACCT-LINKED.
            MOVE 0 TO WS-DEP-AMOUNT
                      WS-DEP-TERM-DAYS
                      WS-DEP-TERM-MONTHS.
       *
            PERFORM 1000-INICIALIZAR.
       *
        OPEN-LOOP.
            PERFORM 2000-REFRESCAR.
            DISPLAY SCR-APERTURA.
            ACCEPT SCR-APERTURA.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    CALL 'CUSSRH00' USING WS-USUARIO-ID WS-RETCODE
                    GO TO OPEN-LOOP
       *
                WHEN WS-CRT-ENTER
                    PERFORM 3000-VALIDAR-DATOS
                    IF WS-ERROR-NO
                        PERFORM 4000-PROCESAR-APERTURA
                    END-IF
                    GO TO OPEN-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'DEPOPN00'
                    GO TO OPEN-LOOP
       *
                WHEN WS-CRT-PF12
                    PERFORM 5000-CONFIRMAR-CANCELACION
                    IF WS-CONFIRMED
                        MOVE 00 TO LS-RETCODE
                        GO TO OPEN-EXIT
                    ELSE
                        GO TO OPEN-LOOP
                    END-IF
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-CUSTOMER-ID
                                   WS-DEP-TYPE
                                   WS-DEP-PRODUCT
                                   WS-DEP-AUTO-RENEW
                                   WS-DEP-ACCT-LINKED
                    MOVE 0 TO WS-DEP-AMOUNT
                              WS-DEP-TERM-DAYS
                              WS-DEP-TERM-MONTHS
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO OPEN-LOOP
       *
                WHEN OTHER
                    MOVE 'LLENE CAMPOS O USE PF1=SRH  PF12=CANCEL'
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
            MOVE 'INGRESE DATOS DEL DEPOSITO - PF1=BUSCAR CLIENTE'
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
        3000-VALIDAR-DATOS.
            MOVE 'N' TO WS-SWITCH-ERROR.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-CUSTOMER-ID = SPACES OR = LOW-VALUES
                MOVE 'INGRESE CLIENTE O USE PF1 PARA BUSCAR'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-DEP-TYPE NOT = 'AH' AND NOT = 'PL' AND NOT = 'RC'
                MOVE 'TIPO DEPOSITO INVALIDO (AH/PL/RC)'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
            IF WS-DEP-AMOUNT <= 0
                MOVE 'MONTO DEBE SER MAYOR A CERO'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 3000-EXIT
            END-IF.
       *
        3000-EXIT.
            EXIT.
       *
        4000-PROCESAR-APERTURA.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            PERFORM 4100-LEER-TASA.
            IF WS-TASA-NO
                MOVE 'NO SE ENCONTRO TASA PARA PRODUCTO/PLAZO'
                  TO WS-MENSAJE-ERROR
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-CONFIRM.
            DISPLAY 'CONFIRMAR APERTURA DE DEPOSITO? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRM AT LINE 23 COLUMN 46.
            IF WS-CONFIRM NOT = 'S' AND NOT = 's'
                MOVE 'APERTURA CANCELADA' TO WS-MENSAJE
                GOTO 4000-EXIT
            END-IF.
       *
            OPEN I-O DEPMAST-FILE.
            IF FL-DEPMAST-STATUS NOT = '00'
                OPEN OUTPUT DEPMAST-FILE
                IF FL-DEPMAST-STATUS NOT = '00'
                    MOVE 'ERROR AL ABRIR DEPMAST' TO WS-MENSAJE-ERROR
                    GOTO 4000-EXIT
                END-IF
            END-IF.
       *
            PERFORM 4200-GENERAR-NUMERO.
            MOVE WS-DEPNBR TO DEP-NBR.
            MOVE WS-CUSTOMER-ID TO DEP-CUSTOMER-ID.
            MOVE WS-DEP-TYPE TO DEP-TYPE.
            MOVE WS-DEP-PRODUCT TO DEP-PRODUCT.
            MOVE WS-DEP-AMOUNT TO DEP-BALANCE
                                  DEP-BALANCE-MIN.
            MOVE 0 TO DEP-BALANCE-PROMEDIO
                      DEP-INTEREST-ACCRUED.
            MOVE RAT-TASA-ANUAL TO DEP-INTEREST-RATE.
            MOVE WS-FECHA TO DEP-DATE-OPEN.
            MOVE WS-FECHA TO DEP-DATE-LAST-INT.
            MOVE WS-FECHA TO DEP-DATE-LAST-TXN.
            MOVE WS-FECHA TO DEP-DATE-LAST-STATEMENT.
       *
            CALL 'COMDATE' USING 'ADD'
                                 WS-FECHA
                                 WS-DEP-TERM-DAYS.
            MOVE WS-FECHA TO DEP-DATE-MATURITY.
       *
            MOVE WS-DEP-TERM-DAYS TO DEP-TERM-DAYS.
            MOVE WS-DEP-TERM-MONTHS TO DEP-TERM-MONTHS.
            MOVE 0 TO DEP-RENEWAL-COUNT.
            IF WS-DEP-AUTO-RENEW = 'Y' OR 'y'
                MOVE 'Y' TO DEP-RENEWAL-AUTO
            ELSE
                MOVE 'N' TO DEP-RENEWAL-AUTO
            END-IF.
            MOVE 'A' TO DEP-STATUS.
            MOVE WS-SUCURSAL-ID TO DEP-BRANCH.
            MOVE WS-USUARIO-ID TO DEP-OFFICER.
            MOVE WS-DEP-ACCT-LINKED TO DEP-ACCOUNT-LINKED.
       *
            WRITE DEPMAST-RECORD
                INVALID KEY
                    MOVE 'ERROR AL ESCRIBIR DEPOSITO'
                      TO WS-MENSAJE-ERROR
                    CLOSE DEPMAST-FILE
                    GOTO 4000-EXIT
            END-WRITE.
       *
            CLOSE DEPMAST-FILE.
       *
            PERFORM 4300-ESCRIBIR-TRANLOG.
            PERFORM 4400-AUDITAR.
       *
            STRING 'DEPOSITO ' WS-DEPNBR ' CREADO OK'
              INTO WS-MENSAJE.
       *
        4000-EXIT.
            EXIT.
       *
        4100-LEER-TASA.
            MOVE 'N' TO WS-TASA-ENCONTRADA.
       *
            OPEN I-O RATEFILE-FILE.
            IF FL-RATEFILE-STATUS NOT = '00' AND NOT = '23'
                GOTO 4100-EXIT
            END-IF.
       *
            MOVE WS-DEP-PRODUCT TO RAT-CODIGO(1:4).
            MOVE 'PA' TO RAT-CODIGO(5:2).
            READ RATEFILE-FILE KEY IS RAT-CODIGO
                INVALID KEY
                    CLOSE RATEFILE-FILE
                    GOTO 4100-EXIT
            END-READ.
       *
            IF FL-RATEFILE-STATUS = '00'
                IF RAT-STATUS-VIGENTE
                    MOVE 'S' TO WS-TASA-ENCONTRADA
                END-IF
            END-IF.
       *
            CLOSE RATEFILE-FILE.
        4100-EXIT.
            EXIT.
       *
        4200-GENERAR-NUMERO.
            MOVE WS-FECHA TO WS-DEPNBR(1:8).
            MOVE WS-DEP-TYPE TO WS-DEPNBR(9:2).
       *
        4300-ESCRIBIR-TRANLOG.
            OPEN I-O TRANLOG-FILE.
            IF FL-TRANLOG-STATUS NOT = '00'
                OPEN OUTPUT TRANLOG-FILE
                IF FL-TRANLOG-STATUS NOT = '00'
                    GOTO 4300-EXIT
                END-IF
            END-IF.
       *
            MOVE 0 TO TRN-SEQ.
            START TRANLOG-FILE KEY IS NOT < TRN-SEQ
                INVALID KEY
                    MOVE 1 TO TRN-SEQ
                    GOTO 4300-ESCRIBE
            END-START.
       *
            READ TRANLOG-FILE NEXT RECORD
                AT END
                    MOVE 1 TO TRN-SEQ
                    GOTO 4300-ESCRIBE
            END-READ.
       *
            IF TRN-SEQ > 0
                ADD 1 TO TRN-SEQ
                MOVE TRN-SEQ TO WS-TRN-SEQ-AUX
                MOVE WS-TRN-SEQ-AUX TO TRN-SEQ
            ELSE
                MOVE 1 TO TRN-SEQ
            END-IF.
       *
        4300-ESCRIBE.
            MOVE WS-FECHA TO TRN-DATE.
            MOVE WS-HORA TO TRN-TIME.
            MOVE 'APE' TO TRN-TYPE.
            MOVE WS-DEPNBR TO TRN-ACCOUNT-NBR.
            MOVE SPACES TO TRN-ACCOUNT-DEST.
            MOVE WS-CUSTOMER-ID TO TRN-CUSTOMER-ID.
            MOVE WS-DEP-AMOUNT TO TRN-AMOUNT.
            MOVE 0 TO TRN-AMOUNT-TAX.
            MOVE WS-DEP-AMOUNT TO TRN-AMOUNT-TOTAL.
            MOVE WS-DEP-AMOUNT TO TRN-AMOUNT-ORIGINAL.
            MOVE 0 TO TRN-FEE-AMOUNT.
            MOVE SPACES TO TRN-FEE-CODE.
            MOVE WS-SUCURSAL-ID TO TRN-BRANCH.
            MOVE SPACES TO TRN-TELLER-ID.
            MOVE WS-USUARIO-ID TO TRN-USER-ID.
            MOVE SPACES TO TRN-TERMINAL.
            MOVE '01' TO TRN-CHANNEL.
            MOVE SPACES TO TRN-REFERENCE.
            MOVE 0 TO TRN-CHQ-NBR.
            MOVE SPACES TO TRN-CHQ-BANK.
            MOVE SPACES TO TRN-CHQ-ACCOUNT.
            MOVE 'C' TO TRN-STATUS.
            MOVE 0 TO TRN-REVERSE-SEQ.
            MOVE 'APERTURA DEPOSITO' TO TRN-DESCRIPTION.
       *
            WRITE TRANLOG-RECORD
                INVALID KEY
                    DISPLAY 'ERROR AL ESCRIBIR TRANLOG'
            END-WRITE.
       *
            CLOSE TRANLOG-FILE.
        4300-EXIT.
            EXIT.
       *
        4400-AUDITAR.
            STRING 'DEPOPN00 DEP=' WS-DEPNBR ' CTA=' WS-CUSTOMER-ID
              INTO WS-AUDIT-DATA.
            CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                  WS-AUDIT-DATA.
       *
        5000-CONFIRMAR-CANCELACION.
            MOVE SPACES TO WS-CONFIRM.
            DISPLAY 'CANCELAR APERTURA? (S/N): '
                AT LINE 23 COLUMN 05.
            ACCEPT WS-CONFIRM AT LINE 23 COLUMN 34.
            IF WS-CONFIRM = 'S' OR WS-CONFIRM = 's'
                MOVE 'Y' TO WS-SWITCH-CONFIRM
            ELSE
                MOVE 'N' TO WS-SWITCH-CONFIRM
                MOVE 'OPERACION CONTINUA' TO WS-MENSAJE
            END-IF.
       *
        END PROGRAM DEPOPN00.
