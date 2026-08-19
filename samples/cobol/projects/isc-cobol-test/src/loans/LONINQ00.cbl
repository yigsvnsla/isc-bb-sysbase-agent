       *================================================================*
       * LONINQ00 - CONSULTA DE PRESTAMO                               *
       * PROPOSITO: VISUALIZAR DATOS COMPLETOS DEL PRESTAMO            *
       * EQUIPO: CREDITO Y COBRANZA - 2004                             *
       * ARCHIVOS: LOANMAST                                             *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. LONINQ00.
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
            SELECT LOANMAST-FILE
                ASSIGN TO 'LOANMAST.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS LON-NBR
                FILE STATUS IS FL-LOANMAST-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  LOANMAST-FILE
            RECORD 350 CHARACTERS.
        COPY FD-LOANMAST REPLACING LOANMAST-FILE BY LOANMAST-FILE
                LOANMAST-RECORD BY LOANMAST-RECORD.
       *================================================================*
        WORKING-STORAGE SECTION.
        COPY CPY-COMMON.
        COPY CPY-SCREEN.
       *
        01  WS-CRT-STATUS                  PIC 9(04).
            88  WS-CRT-PF1                VALUE 1001.
            88  WS-CRT-PF7                VALUE 1007.
            88  WS-CRT-PF8                VALUE 1008.
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-ENTER              VALUE 0013.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-LOAN-NBR                PIC X(10).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-I                       PIC 9(04).
            05  WS-J                       PIC 9(04).
            05  WS-K                       PIC 9(04).
            05  WS-PAGINA-INST             PIC 9(04).
            05  WS-INST-DESDE              PIC 9(04).
            05  WS-INST-HASTA              PIC 9(04).
            05  WS-LON-TYPE-DESC           PIC X(15).
            05  WS-LON-AMORT-DESC          PIC X(15).
            05  WS-LON-STATUS-DESC         PIC X(15).
            05  WS-LON-CLASS-DESC          PIC X(20).
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'LONINQ00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-BUSQUEDA.
            05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - CONSULTA DE PRESTAMO'.
            05  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
            05  LINE 02  COL 01  PIC X(80)
               VALUE ' INGRESE NUMERO DE PRESTAMO:'.
            05  LINE 02  COL 32  PIC X(10)
               USING WS-LOAN-NBR AUTO PROMPT '__________'.
            05  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
            05  LINE 24  COL 05  PIC X(60)
               VALUE 'ENTER=CONSULTAR  PF12=SALIR'.
       *
        01  SCR-PRESTAMO.
            05  SCR-CAB.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - DATOS DEL PRESTAMO'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
       *
            05  SCR-CUERPO.
                10  LINE 03  COL 02  PIC X(15) VALUE 'PRESTAMO:'.
                10  LINE 03  COL 15  PIC X(10) FROM LON-NBR.
                10  LINE 03  COL 30  PIC X(15) VALUE 'CLIENTE:'.
                10  LINE 03  COL 45  PIC X(10) FROM LON-CUSTOMER-ID.
       *
                10  LINE 04  COL 02  PIC X(15) VALUE 'TIPO:'.
                10  LINE 04  COL 10  PIC X(15) FROM WS-LON-TYPE-DESC.
                10  LINE 04  COL 30  PIC X(15) VALUE 'PRODUCTO:'.
                10  LINE 04  COL 45  PIC X(04) FROM LON-PRODUCT-CODE.
       *
                10  LINE 05  COL 02  PIC X(15) VALUE 'MONTO APROB:'.
                10  LINE 05  COL 18  PIC Z(12)9.99 FROM LON-AMOUNT-APPROVED.
                10  LINE 05  COL 40  PIC X(15) VALUE 'DESEMBOLSADO:'.
                10  LINE 05  COL 55  PIC Z(12)9.99 FROM LON-AMOUNT-DISBURSED.
       *
                10  LINE 06  COL 02  PIC X(15) VALUE 'SALDO ACTUAL:'.
                10  LINE 06  COL 18  PIC Z(12)9.99 FROM LON-BALANCE.
                10  LINE 06  COL 40  PIC X(15) VALUE 'VENCIDO:'.
                10  LINE 06  COL 55  PIC Z(12)9.99 FROM LON-BALANCE-PAST-DUE.
       *
                10  LINE 07  COL 02  PIC X(15) VALUE 'TASA:'.
                10  LINE 07  COL 10  PIC 9(03).9(04) FROM LON-INTEREST-RATE.
                10  LINE 07  COL 25  PIC X(10) VALUE 'TASA MORA:'.
                10  LINE 07  COL 38  PIC 9(03).9(04) FROM LON-INTEREST-MORA.
       *
                10  LINE 08  COL 02  PIC X(15) VALUE 'PLAZO (MES):'.
                10  LINE 08  COL 18  PIC 9(04) FROM LON-TERM-MONTHS.
                10  LINE 08  COL 30  PIC X(15) VALUE 'FRECUENCIA:'.
                10  LINE 08  COL 45  PIC X(01) FROM LON-FREQUENCY.
       *
                10  LINE 09  COL 02  PIC X(15) VALUE 'TOTAL CUOTAS:'.
                10  LINE 09  COL 18  PIC 9(04) FROM LON-PAYMENTS-TOTAL.
                10  LINE 09  COL 35  PIC X(15) VALUE 'PAGADAS:'.
                10  LINE 09  COL 50  PIC 9(04) FROM LON-PAYMENTS-MADE.
                10  LINE 09  COL 60  PIC X(10) VALUE 'VENCIDAS:'.
                10  LINE 09  COL 72  PIC 9(04) FROM LON-PAYMENTS-OVERDUE.
       *
                10  LINE 10  COL 02  PIC X(15) VALUE 'AMORTIZACION:'.
                10  LINE 10  COL 18  PIC X(15) FROM WS-LON-AMORT-DESC.
                10  LINE 10  COL 40  PIC X(15) VALUE 'CUOTA:'.
                10  LINE 10  COL 50  PIC Z(08)9.99
                   FROM LON-INSTALLMENT-AMOUNT.
       *
                10  LINE 11  COL 02  PIC X(15) VALUE 'APROBACION:'.
                10  LINE 11  COL 18  PIC 9(08) FROM LON-DATE-APPROVAL.
                10  LINE 11  COL 35  PIC X(15) VALUE 'DESEMBOLSO:'.
                10  LINE 11  COL 50  PIC 9(08) FROM LON-DATE-DISBURSEMENT.
                10  LINE 12  COL 02  PIC X(15) VALUE '1ER PAGO:'.
                10  LINE 12  COL 18  PIC 9(08) FROM LON-DATE-FIRST-PAYMENT.
                10  LINE 12  COL 40  PIC X(15) VALUE 'VENCIMIENTO:'.
                10  LINE 12  COL 55  PIC 9(08) FROM LON-DATE-MATURITY.
       *
                10  LINE 13  COL 02  PIC X(15) VALUE 'GARANTIA:'.
                10  LINE 13  COL 18  PIC X(02) FROM LON-COLLATERAL-TYPE.
                10  LINE 13  COL 25  PIC X(40) FROM LON-COLLATERAL-DESC.
                10  LINE 14  COL 02  PIC X(15) VALUE 'VALOR GAR:'.
                10  LINE 14  COL 18  PIC Z(12)9.99 FROM LON-COLLATERAL-VALUE.
       *
                10  LINE 15  COL 02  PIC X(15) VALUE 'ESTATUS:'.
                10  LINE 15  COL 12  PIC X(15) FROM WS-LON-STATUS-DESC.
                10  LINE 15  COL 35  PIC X(15) VALUE 'CLASIF:'.
                10  LINE 15  COL 50  PIC X(20) FROM WS-LON-CLASS-DESC.
                10  LINE 15  COL 70  PIC X(10) VALUE 'OFICIAL:'.
                10  LINE 15  COL 75  PIC X(08) FROM LON-OFFICER.
       *
            05  SCR-MSG.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'PF7=ANT INST  PF8=SIG INST  PF12=SALIR'.
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
            MOVE SPACES TO WS-USUARIO WS-MENSAJE WS-MENSAJE-ERROR.
            MOVE LS-USUARIO TO WS-USUARIO.
            MOVE 99 TO LS-RETCODE.
            PERFORM 1000-INICIALIZAR.
       *
        BUSQUEDA-LOOP.
            PERFORM 2000-MOSTRAR-BUSQUEDA.
            ACCEPT SCR-BUSQUEDA.
       *
            IF WS-CRT-PF12
                GOTO MAIN-EXIT
            END-IF.
       *
            IF WS-CRT-ENTER
                PERFORM 3000-CONSULTAR
                IF WS-RETCODE = 00
                    PERFORM 4000-DESPLIEGA-PRESTAMO
                END-IF
            END-IF.
            GO TO BUSQUEDA-LOOP.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            DISPLAY SPACES UPON CRT.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            OPEN I-O LOANMAST-FILE.
            MOVE 1 TO WS-PAGINA-INST.
            MOVE 'INGRESE NUMERO DE PRESTAMO' TO WS-MENSAJE.
       *
        2000-MOSTRAR-BUSQUEDA.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            DISPLAY SCR-BUSQUEDA.
       *
        2100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        3000-CONSULTAR.
            MOVE WS-LOAN-NBR TO LON-NBR.
            READ LOANMAST-FILE KEY IS LON-NBR
                INVALID KEY
                    MOVE 'PRESTAMO NO ENCONTRADO' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 3000-EXIT
            END-READ.
       *
            EVALUATE LON-TYPE
                WHEN 'PL' MOVE 'PERSONAL' TO WS-LON-TYPE-DESC
                WHEN 'HI' MOVE 'HIPOTECARIO' TO WS-LON-TYPE-DESC
                WHEN 'AU' MOVE 'AUTOMOTRIZ' TO WS-LON-TYPE-DESC
                WHEN 'CO' MOVE 'COMERCIAL' TO WS-LON-TYPE-DESC
                WHEN 'PR' MOVE 'PRENDARIO' TO WS-LON-TYPE-DESC
                WHEN 'RE' MOVE 'REVOLVENTE' TO WS-LON-TYPE-DESC
                WHEN OTHER MOVE 'OTRO' TO WS-LON-TYPE-DESC
            END-EVALUATE.
       *
            EVALUATE LON-AMORT-TYPE
                WHEN 'F' MOVE 'FRANCESA' TO WS-LON-AMORT-DESC
                WHEN 'A' MOVE 'ALEMANA' TO WS-LON-AMORT-DESC
                WHEN 'M' MOVE 'AMERICANA' TO WS-LON-AMORT-DESC
                WHEN 'C' MOVE 'CUOTA FIJA' TO WS-LON-AMORT-DESC
                WHEN OTHER MOVE 'ESTANDAR' TO WS-LON-AMORT-DESC
            END-EVALUATE.
       *
            EVALUATE LON-STATUS
                WHEN 'A' MOVE 'ACTIVO' TO WS-LON-STATUS-DESC
                WHEN 'P' MOVE 'PAGADO' TO WS-LON-STATUS-DESC
                WHEN 'C' MOVE 'CASTIGADO' TO WS-LON-STATUS-DESC
                WHEN 'R' MOVE 'REESTRUC' TO WS-LON-STATUS-DESC
                WHEN 'L' MOVE 'JUDICIAL' TO WS-LON-STATUS-DESC
                WHEN OTHER MOVE 'OTRO' TO WS-LON-STATUS-DESC
            END-EVALUATE.
       *
            EVALUATE LON-CLASSIFICATION
                WHEN '1' MOVE 'NORMAL' TO WS-LON-CLASS-DESC
                WHEN '2' MOVE 'SUBESTANDAR' TO WS-LON-CLASS-DESC
                WHEN '3' MOVE 'DUDOSO' TO WS-LON-CLASS-DESC
                WHEN '4' MOVE 'PERDIDA' TO WS-LON-CLASS-DESC
                WHEN OTHER MOVE 'N/A' TO WS-LON-CLASS-DESC
            END-EVALUATE.
       *
            MOVE 1 TO WS-PAGINA-INST.
            MOVE 'PRESTAMO ENCONTRADO' TO WS-MENSAJE.
            MOVE 00 TO LS-RETCODE.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA
                                  'CONSULTA PRESTAMO'.
       *
        3000-EXIT.
            EXIT.
       *
        4000-DESPLIEGA-PRESTAMO.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
       *
        4100-PAGINA-LOOP.
            PERFORM 5000-DESPLIEGA-INSTALMENTS.
            DISPLAY SCR-PRESTAMO.
            ACCEPT SCR-PRESTAMO.
       *
            IF WS-CRT-PF8
                IF WS-PAGINA-INST < LON-PAYMENTS-TOTAL
                    ADD 5 TO WS-PAGINA-INST
                ELSE
                    MOVE 'ULTIMA PAGINA DE CUOTAS'
                      TO WS-MENSAJE-ERROR
                END-IF
                GO TO 4100-PAGINA-LOOP
            END-IF.
       *
            IF WS-CRT-PF7
                IF WS-PAGINA-INST > 1
                    SUBTRACT 5 FROM WS-PAGINA-INST
                ELSE
                    MOVE 'PRIMERA PAGINA DE CUOTAS'
                      TO WS-MENSAJE-ERROR
                END-IF
                GO TO 4100-PAGINA-LOOP
            END-IF.
       *
            IF WS-CRT-PF12
                GOTO 4000-EXIT
            END-IF.
       *
            IF WS-CRT-CLEAR
                GOTO 4000-EXIT
            END-IF.
       *
            GO TO 4100-PAGINA-LOOP.
       *
        4000-EXIT.
            EXIT.
       *
        5000-DESPLIEGA-INSTALMENTS.
            DISPLAY 'CUOTAS:' AT LINE 17 COLUMN 02.
            DISPLAY 'NUM  FECHA VCTO  MONTO       PRINCIPAL   '
                    'INTERES     SALDO    EST' AT LINE 18 COLUMN 02.
       *
            MOVE WS-PAGINA-INST TO WS-I.
            MOVE 19 TO WS-K.
       *
            PERFORM UNTIL WS-I > LON-PAYMENTS-TOTAL
                          OR WS-I > WS-PAGINA-INST + 4
                DISPLAY LON-INST-NBR(WS-I) AT LINE WS-K COLUMN 02
                DISPLAY LON-INST-DUE-DATE(WS-I) AT LINE WS-K COLUMN 07
                DISPLAY LON-INST-AMOUNT(WS-I) AT LINE WS-K COLUMN 18
                DISPLAY LON-INST-PRINCIPAL(WS-I) AT LINE WS-K COLUMN 29
                DISPLAY LON-INST-INTEREST(WS-I) AT LINE WS-K COLUMN 40
                DISPLAY LON-INST-BALANCE(WS-I) AT LINE WS-K COLUMN 51
                DISPLAY LON-INST-STATUS(WS-I) AT LINE WS-K COLUMN 62
                ADD 1 TO WS-I
                ADD 1 TO WS-K
            END-PERFORM.
       *
        END PROGRAM LONINQ00.
