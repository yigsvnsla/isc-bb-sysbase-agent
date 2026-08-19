        *================================================================*
        * TDINT000 - CALCULO DE INTERESES DE CD                        *
        * PROPOSITO: CALCULAR INTERES SIMPLE O COMPUESTO               *
        * EQUIPO: MESAS DE DINERO - 2007                               *
        * ARCHIVOS: TIMEDEP, TRANLOG                                  *
        *================================================================*
         IDENTIFICATION DIVISION.
         PROGRAM-ID. TDINT000.
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
             SELECT TIMEDEP-FILE
                 ASSIGN TO 'TIMEDEP.DAT'
                 ORGANIZATION IS INDEXED
                 ACCESS MODE IS DYNAMIC
                 RECORD KEY IS TD-NBR
                 FILE STATUS IS FL-TIMEDEP-STATUS.
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
         FD  TIMEDEP-FILE
             RECORD 180 CHARACTERS.
         COPY FD-TIMEDEP.
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
             05  WS-PROGRAMA-ID             PIC X(08) VALUE 'TDINT000'.
             05  WS-FECHA                   PIC 9(08).
             05  WS-HORA                    PIC 9(06).
             05  WS-FECHA-DDMM              PIC 9(08).
             05  WS-MENSAJE                 PIC X(60).
             05  WS-MENSAJE-ERROR           PIC X(60).
             05  WS-RETCODE                 PIC 99.
             05  WS-CERT-NBR                PIC X(15).
             05  WS-CALC-AMOUNT             PIC 9(13)V99 COMP-3.
             05  WS-CALC-RATE               PIC 9(03)V9(06) COMP-3.
             05  WS-CALC-DAYS               PIC 9(04).
             05  WS-CALC-INTEREST           PIC 9(13)V99 COMP-3.
             05  WS-CALC-PRINCIPAL          PIC 9(13)V99 COMP-3.
             05  WS-CALC-COMPOUND           PIC 9(13)V99 COMP-3.
             05  WS-CALC-TEMP               PIC 9(13)V99 COMP-3.
             05  WS-CONFIRM                 PIC X(01).
             05  WS-AUDIT-DATA              PIC X(60).
             05  WS-TRN-SEQ-AUX             PIC 9(10).
             05  WS-INT-PAYABLE             PIC 9(13)V99 COMP-3.
             05  WS-FREQ-DAYS               PIC 9(04).
             05  WS-PAY-DUE                 PIC X(01).
                 88  WS-PAGO-PENDIENTE      VALUE 'S'.
                 88  WS-PAGO-NO             VALUE 'N'.
        *
        *================================================================*
         SCREEN SECTION.
        *
         01  SCR-INTERES.
             05  SCR-CABECERA.
                 10  LINE 01  COL 01  PIC X(80)
                     VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                 10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                 10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                 10  LINE 02  COL 01  PIC X(80)
                     VALUE ' CALCULO DE INTERESES - CD'.
                 10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
        *
             05  SCR-ID.
                 10  LINE 04  COL 05  PIC X(20) VALUE 'CERTIFICADO:'.
                 10  LINE 04  COL 25  PIC X(15)
                     USING WS-CERT-NBR AUTO PROMPT '_______________'.
                 10  LINE 04  COL 45  PIC X(20) VALUE 'ENTER=CALCULAR'.
        *
             05  SCR-DATOS.
                 10  LINE 06  COL 05  PIC X(15) VALUE 'CLIENTE:'.
                 10  LINE 06  COL 20  PIC X(10) FROM TD-CUSTOMER-ID.
                 10  LINE 06  COL 45  PIC X(15) VALUE 'MONTO:'.
                 10  LINE 06  COL 62  PIC -(11)9.99 FROM TD-AMOUNT.
        *
                 10  LINE 08  COL 05  PIC X(15) VALUE 'TIPO INT:'.
                 10  LINE 08  COL 20  PIC X(01) FROM TD-INTEREST-TYPE.
                 10  LINE 08  COL 25  PIC X(25)
                     VALUE 'S=SIMPLE  C=COMPUESTO'.
                 10  LINE 08  COL 55  PIC X(15) VALUE 'TASA:'.
                 10  LINE 08  COL 70  PIC 9(03).9(06)
                     FROM TD-INTEREST-RATE.
        *
                 10  LINE 10  COL 05  PIC X(20) VALUE 'INTERES CALCULADO:'.
                 10  LINE 10  COL 28  PIC -(11)9.99 FROM WS-CALC-INTEREST.
                 10  LINE 11  COL 05  PIC X(20) VALUE 'NUEVO SALDO TOTAL:'.
                 10  LINE 11  COL 28  PIC -(11)9.99 FROM WS-CALC-PRINCIPAL.
        *
             05  SCR-PIE.
                 10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                 10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                 10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                     BLINK.
                 10  LINE 24  COL 02  PIC X(78)
                     VALUE 'ENTER=CALC/ACTUALIZA  PF11=AYU  PF12=RET'.
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
             MOVE SPACES TO WS-CERT-NBR.
             MOVE 0 TO WS-CALC-INTEREST
                       WS-CALC-PRINCIPAL.
        *
             PERFORM 1000-INICIALIZAR.
        *
         INT-LOOP.
             PERFORM 2000-REFRESCAR.
             DISPLAY SCR-INTERES.
             ACCEPT SCR-INTERES.
        *
             EVALUATE TRUE
                 WHEN WS-CRT-ENTER
                     PERFORM 3000-CALCULAR-INTERES
                     GO TO INT-LOOP
        *
                 WHEN WS-CRT-PF11
                     CALL 'COMHELP' USING 'TDINT000'
                     GO TO INT-LOOP
        *
                 WHEN WS-CRT-PF12
                     MOVE 00 TO LS-RETCODE
                     GO TO INT-EXIT
        *
                 WHEN WS-CRT-CLEAR
                     MOVE SPACES TO WS-CERT-NBR
                     MOVE 0 TO WS-CALC-INTEREST
                               WS-CALC-PRINCIPAL
                     MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                     GO TO INT-LOOP
        *
                 WHEN OTHER
                     MOVE 'INGRESE CD Y ENTER  PF12=RET'
                       TO WS-MENSAJE-ERROR
                     GO TO INT-LOOP
             END-EVALUATE.
        *
         INT-EXIT.
             EXIT.
        *
         1000-INICIALIZAR.
             CALL 'COMDATE' USING 'NOW'
                                  WS-FECHA
                                  WS-HORA.
             MOVE WS-FECHA TO WS-BUSINESS-DATE.
             MOVE WS-HORA TO WS-CURRENT-TIME.
             MOVE WS-FECHA TO WS-FECHA-DDMM.
             MOVE 'INGRESE CD Y ENTER PARA CALCULAR INTERES'
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
         3000-CALCULAR-INTERES.
             MOVE SPACES TO WS-MENSAJE-ERROR.
        *
             IF WS-CERT-NBR = SPACES OR = LOW-VALUES
                 MOVE 'INGRESE NUMERO DE CERTIFICADO'
                   TO WS-MENSAJE-ERROR
                 GO TO 3000-EXIT
             END-IF.
        *
             OPEN I-O TIMEDEP-FILE.
             IF FL-TIMEDEP-STATUS NOT = '00' AND NOT = '23'
                 MOVE 'ERROR AL ABRIR TIMEDEP' TO WS-MENSAJE-ERROR
                 GO TO 3000-EXIT
             END-IF.
        *
             MOVE WS-CERT-NBR TO TD-NBR.
             READ TIMEDEP-FILE KEY IS TD-NBR
                 INVALID KEY
                     MOVE 'CERTIFICADO NO ENCONTRADO'
                       TO WS-MENSAJE-ERROR
                     CLOSE TIMEDEP-FILE
                     GO TO 3000-EXIT
             END-READ.
        *
             IF FL-TIMEDEP-STATUS NOT = '00'
                 MOVE 'ERROR AL LEER CD' TO WS-MENSAJE-ERROR
                 CLOSE TIMEDEP-FILE
                 GO TO 3000-EXIT
             END-IF.
        *
             IF TD-STATUS NOT = 'A'
                 MOVE 'CD NO ACTIVO' TO WS-MENSAJE-ERROR
                 CLOSE TIMEDEP-FILE
                 GO TO 3000-EXIT
             END-IF.
        *
             PERFORM 3100-CALCULAR-POR-TIPO.
        *
             MOVE SPACES TO WS-CONFIRM.
             DISPLAY 'ACTUALIZAR CD CON INTERES DE '
                     WS-CALC-INTEREST '? (S/N): '
                 AT LINE 23 COLUMN 05.
             ACCEPT WS-CONFIRM AT LINE 23 COLUMN 55.
             IF WS-CONFIRM NOT = 'S' AND NOT = 's'
                 MOVE 'CALCULO CANCELADO' TO WS-MENSAJE
                 CLOSE TIMEDEP-FILE
                 GO TO 3000-EXIT
             END-IF.
        *
             MOVE WS-CALC-INTEREST TO TD-AMOUNT-INTEREST.
             MOVE WS-CALC-PRINCIPAL TO TD-AMOUNT-TOTAL.
             MOVE WS-FECHA TO TD-DATE-LAST-INT-PAYMENT.
        *
             IF WS-PAGO-PENDIENTE
                 PERFORM 3200-PAGAR-INTERES
             END-IF.
        *
             REWRITE TIMEDEP-RECORD
                 INVALID KEY
                     MOVE 'ERROR AL ACTUALIZAR CD'
                       TO WS-MENSAJE-ERROR
                     CLOSE TIMEDEP-FILE
                     GO TO 3000-EXIT
             END-REWRITE.
        *
             CLOSE TIMEDEP-FILE.
        *
             PERFORM 5000-ESCRIBIR-TRANLOG.
             PERFORM 6000-AUDITAR.
        *
             STRING 'INTERES CALCULADO: ' WS-CALC-INTEREST
               INTO WS-MENSAJE.
         3000-EXIT.
             EXIT.
        *
         3100-CALCULAR-POR-TIPO.
             MOVE TD-AMOUNT TO WS-CALC-AMOUNT.
             MOVE TD-INTEREST-RATE TO WS-CALC-RATE.
        *
             CALL 'COMDATE' USING 'DIFF'
                                  WS-FECHA
                                  TD-DATE-ISSUE.
             MOVE WS-FECHA TO WS-CALC-DAYS.
             IF WS-CALC-DAYS = 0
                 MOVE 1 TO WS-CALC-DAYS
             END-IF.
        *
             IF TD-INT-SIMPLE
                 COMPUTE WS-CALC-INTEREST =
                     WS-CALC-AMOUNT * WS-CALC-RATE / 100
                     * WS-CALC-DAYS / 360
                 COMPUTE WS-CALC-PRINCIPAL =
                     TD-AMOUNT + WS-CALC-INTEREST
             ELSE
                 IF TD-INT-COMPUESTO
                     MOVE TD-AMOUNT TO WS-CALC-PRINCIPAL
                     MOVE 0 TO WS-CALC-COMPOUND
                     COMPUTE WS-CALC-TEMP =
                         WS-CALC-RATE / 100 / 360
                     COMPUTE WS-CALC-COMPOUND =
                         WS-CALC-AMOUNT *
                         (1 + WS-CALC-TEMP) ** WS-CALC-DAYS
                     COMPUTE WS-CALC-INTEREST =
                         WS-CALC-COMPOUND - TD-AMOUNT
                     MOVE WS-CALC-COMPOUND TO WS-CALC-PRINCIPAL
                 END-IF
             END-IF.
        *
             MOVE 'N' TO WS-PAY-DUE.
             EVALUATE TD-PAYMENT-FREQ
                 WHEN 'M'
                     MOVE 30 TO WS-FREQ-DAYS
                 WHEN 'T'
                     MOVE 90 TO WS-FREQ-DAYS
                 WHEN 'S'
                     MOVE 180 TO WS-FREQ-DAYS
                 WHEN 'V'
                     MOVE 9999 TO WS-FREQ-DAYS
             END-EVALUATE.
        *
             IF WS-CALC-DAYS >= WS-FREQ-DAYS
                 MOVE 'S' TO WS-PAY-DUE
             END-IF.
        *
         3200-PAGAR-INTERES.
             MOVE WS-CALC-INTEREST TO WS-INT-PAYABLE.
             MOVE 0 TO TD-AMOUNT-INTEREST.
        *
         5000-ESCRIBIR-TRANLOG.
             OPEN I-O TRANLOG-FILE.
             IF FL-TRANLOG-STATUS NOT = '00'
                 OPEN OUTPUT TRANLOG-FILE
                 IF FL-TRANLOG-STATUS NOT = '00'
                     GOTO 5000-EXIT
                 END-IF
             END-IF.
        *
             MOVE 0 TO TRN-SEQ.
             START TRANLOG-FILE KEY IS NOT < TRN-SEQ
                 INVALID KEY
                     MOVE 1 TO TRN-SEQ
                     GOTO 5000-ESCRIBE
             END-START.
        *
             READ TRANLOG-FILE NEXT RECORD
                 AT END
                     MOVE 1 TO TRN-SEQ
                     GOTO 5000-ESCRIBE
             END-READ.
        *
             ADD 1 TO TRN-SEQ.
             MOVE TRN-SEQ TO WS-TRN-SEQ-AUX.
             MOVE WS-TRN-SEQ-AUX TO TRN-SEQ.
        *
         5000-ESCRIBE.
             MOVE WS-FECHA TO TRN-DATE.
             MOVE WS-HORA TO TRN-TIME.
             MOVE 'INT' TO TRN-TYPE.
             MOVE WS-CERT-NBR TO TRN-ACCOUNT-NBR.
             MOVE TD-ACCOUNT-DEST TO TRN-ACCOUNT-DEST.
             MOVE TD-CUSTOMER-ID TO TRN-CUSTOMER-ID.
             MOVE WS-CALC-INTEREST TO TRN-AMOUNT.
             MOVE 0 TO TRN-AMOUNT-TAX.
             MOVE WS-CALC-INTEREST TO TRN-AMOUNT-TOTAL.
             MOVE WS-CALC-INTEREST TO TRN-AMOUNT-ORIGINAL.
             MOVE 0 TO TRN-FEE-AMOUNT.
             MOVE SPACES TO TRN-FEE-CODE.
             MOVE TD-BRANCH TO TRN-BRANCH.
             MOVE SPACES TO TRN-TELLER-ID.
             MOVE WS-USUARIO-ID TO TRN-USER-ID.
             MOVE SPACES TO TRN-TERMINAL.
             MOVE '04' TO TRN-CHANNEL.
             MOVE SPACES TO TRN-REFERENCE.
             MOVE 0 TO TRN-CHQ-NBR.
             MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
             MOVE 'C' TO TRN-STATUS.
             MOVE 0 TO TRN-REVERSE-SEQ.
             MOVE 'CALCULO INTERES CD' TO TRN-DESCRIPTION.
        *
             WRITE TRANLOG-RECORD
                 INVALID KEY
                     DISPLAY 'ERROR TRANLOG'
             END-WRITE.
        *
             CLOSE TRANLOG-FILE.
         5000-EXIT.
             EXIT.
        *
         6000-AUDITAR.
             STRING 'TDINT000 CD=' WS-CERT-NBR ' INT='
                    WS-CALC-INTEREST
               INTO WS-AUDIT-DATA.
             CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                   WS-AUDIT-DATA.
        *
         END PROGRAM TDINT000.
