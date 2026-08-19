        *================================================================*
        * TDCLS000 - LIQUIDACION / CANCELACION DE CD                   *
        * PROPOSITO: LIQUIDAR CERTIFICADO ANTES DE VENCIMIENTO O VCTO *
        * EQUIPO: MESAS DE DINERO - 2006                               *
        * ARCHIVOS: TIMEDEP, TRANLOG                                  *
        *================================================================*
         IDENTIFICATION DIVISION.
         PROGRAM-ID. TDCLS000.
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
             05  WS-PROGRAMA-ID             PIC X(08) VALUE 'TDCLS000'.
             05  WS-FECHA                   PIC 9(08).
             05  WS-HORA                    PIC 9(06).
             05  WS-FECHA-DDMM              PIC 9(08).
             05  WS-MENSAJE                 PIC X(60).
             05  WS-MENSAJE-ERROR           PIC X(60).
             05  WS-RETCODE                 PIC 99.
             05  WS-CERT-NBR                PIC X(15).
             05  WS-PENALTY-AMOUNT          PIC 9(13)V99 COMP-3.
             05  WS-PAYOUT-AMOUNT           PIC 9(13)V99 COMP-3.
             05  WS-INTEREST-EARNED         PIC 9(13)V99 COMP-3.
             05  WS-EARLY-CLOSE             PIC X(01).
                 88  WS-ANTES-VCTO          VALUE 'S'.
                 88  WS-EN-VCTO             VALUE 'N'.
             05  WS-CONFIRM                 PIC X(01).
             05  WS-AUDIT-DATA              PIC X(60).
             05  WS-TRN-SEQ-AUX             PIC 9(10).
        *
        *================================================================*
         SCREEN SECTION.
        *
         01  SCR-LIQUIDACION.
             05  SCR-CABECERA.
                 10  LINE 01  COL 01  PIC X(80)
                     VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                 10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                 10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                 10  LINE 02  COL 01  PIC X(80)
                     VALUE ' LIQUIDACION DE CERTIFICADO'.
                 10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
        *
             05  SCR-ID.
                 10  LINE 04  COL 05  PIC X(20) VALUE 'CERTIFICADO:'.
                 10  LINE 04  COL 25  PIC X(15)
                     USING WS-CERT-NBR AUTO PROMPT '_______________'.
                 10  LINE 04  COL 45  PIC X(20) VALUE 'ENTER=CONSULTA'.
        *
             05  SCR-DATOS.
                 10  LINE 06  COL 05  PIC X(15) VALUE 'CLIENTE:'.
                 10  LINE 06  COL 20  PIC X(10) FROM TD-CUSTOMER-ID.
                 10  LINE 06  COL 40  PIC X(15) VALUE 'TIPO:'.
                 10  LINE 06  COL 55  PIC X(02) FROM TD-TYPE.
                 10  LINE 07  COL 05  PIC X(15) VALUE 'MONTO:'.
                 10  LINE 07  COL 22  PIC -(11)9.99 FROM TD-AMOUNT.
                 10  LINE 07  COL 45  PIC X(20) VALUE 'INTERES:'.
                 10  LINE 07  COL 65  PIC -(11)9.99 FROM TD-AMOUNT-INTEREST.
                 10  LINE 08  COL 05  PIC X(15) VALUE 'TOTAL:'.
                 10  LINE 08  COL 22  PIC -(11)9.99 FROM TD-AMOUNT-TOTAL.
                 10  LINE 08  COL 45  PIC X(15) VALUE 'VCTO:'.
                 10  LINE 08  COL 55  PIC 9(08) FROM TD-DATE-MATURITY.
        *
             05  SCR-PENALTY.
                 10  LINE 10  COL 05  PIC X(20) VALUE 'PENALIZACION:'.
                 10  LINE 10  COL 28  PIC -(11)9.99 FROM WS-PENALTY-AMOUNT
                     BLINK.
                 10  LINE 11  COL 05  PIC X(20) VALUE 'INTERES GANADO:'.
                 10  LINE 11  COL 28  PIC -(11)9.99 FROM WS-INTEREST-EARNED.
                 10  LINE 12  COL 05  PIC X(20) VALUE 'LIQUIDO A PAGAR:'.
                 10  LINE 12  COL 28  PIC -(11)9.99 FROM WS-PAYOUT-AMOUNT.
        *
             05  SCR-PIE.
                 10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                 10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                 10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                     BLINK.
                 10  LINE 24  COL 02  PIC X(78)
                     VALUE 'ENTER=CONFIRMAR LIQUIDACION  PF11=AYU'.
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
             MOVE SPACES TO WS-CERT-NBR.
             MOVE 0 TO WS-PENALTY-AMOUNT
                       WS-PAYOUT-AMOUNT
                       WS-INTEREST-EARNED.
        *
             PERFORM 1000-INICIALIZAR.
        *
         CLS-LOOP.
             PERFORM 2000-REFRESCAR.
             DISPLAY SCR-LIQUIDACION.
             ACCEPT SCR-LIQUIDACION.
        *
             EVALUATE TRUE
                 WHEN WS-CRT-ENTER
                     IF WS-CERT-NBR NOT = SPACES
                         AND TD-AMOUNT = 0
                         PERFORM 3000-CARGAR-CD
                     ELSE
                         PERFORM 4000-PROCESAR-LIQUIDACION
                     END-IF
                     GO TO CLS-LOOP
        *
                 WHEN WS-CRT-PF11
                     CALL 'COMHELP' USING 'TDCLS000'
                     GO TO CLS-LOOP
        *
                 WHEN WS-CRT-PF12
                     MOVE 00 TO LS-RETCODE
                     GO TO CLS-EXIT
        *
                 WHEN WS-CRT-CLEAR
                     MOVE SPACES TO WS-CERT-NBR
                     MOVE 0 TO WS-PENALTY-AMOUNT
                               WS-PAYOUT-AMOUNT
                               WS-INTEREST-EARNED
                     MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                     GO TO CLS-LOOP
        *
                 WHEN OTHER
                     MOVE 'INGRESE CD Y ENTER  PF12=RET'
                       TO WS-MENSAJE-ERROR
                     GO TO CLS-LOOP
             END-EVALUATE.
        *
         CLS-EXIT.
             EXIT.
        *
         1000-INICIALIZAR.
             CALL 'COMDATE' USING 'NOW'
                                  WS-FECHA
                                  WS-HORA.
             MOVE WS-FECHA TO WS-BUSINESS-DATE.
             MOVE WS-HORA TO WS-CURRENT-TIME.
             MOVE WS-FECHA TO WS-FECHA-DDMM.
             MOVE 'INGRESE NUMERO DE CD Y PRESIONE ENTER' TO WS-MENSAJE.
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
         3000-CARGAR-CD.
             MOVE SPACES TO WS-MENSAJE-ERROR.
        *
             IF WS-CERT-NBR = SPACES OR = LOW-VALUES
                 MOVE 'INGRESE NUMERO DE CERTIFICADO'
                   TO WS-MENSAJE-ERROR
                 GOTO 3000-EXIT
             END-IF.
        *
             OPEN I-O TIMEDEP-FILE.
             IF FL-TIMEDEP-STATUS NOT = '00' AND NOT = '23'
                 MOVE 'ERROR AL ABRIR TIMEDEP' TO WS-MENSAJE-ERROR
                 GOTO 3000-EXIT
             END-IF.
        *
             MOVE WS-CERT-NBR TO TD-NBR.
             READ TIMEDEP-FILE KEY IS TD-NBR
                 INVALID KEY
                     MOVE 'CERTIFICADO NO ENCONTRADO'
                       TO WS-MENSAJE-ERROR
                     CLOSE TIMEDEP-FILE
                     GOTO 3000-EXIT
             END-READ.
        *
             IF FL-TIMEDEP-STATUS = '00'
                 IF TD-STATUS NOT = 'A'
                     MOVE 'CD NO ESTA ACTIVO' TO WS-MENSAJE-ERROR
                     CLOSE TIMEDEP-FILE
                     GOTO 3000-EXIT
                 END-IF
                 PERFORM 3100-CALCULAR-PENALTY
                 MOVE 'CD ENCONTRADO - REVISE PENALIZACION'
                   TO WS-MENSAJE
             ELSE
                 MOVE 'ERROR AL LEER CD' TO WS-MENSAJE-ERROR
             END-IF.
        *
             CLOSE TIMEDEP-FILE.
         3000-EXIT.
             EXIT.
        *
         3100-CALCULAR-PENALTY.
             MOVE 0 TO WS-PENALTY-AMOUNT
                       WS-INTEREST-EARNED.
        *
             IF TD-DATE-MATURITY > WS-FECHA
                 MOVE 'S' TO WS-EARLY-CLOSE
                 COMPUTE WS-PENALTY-AMOUNT =
                     TD-AMOUNT * TD-EARLY-PENALTY-RATE / 100
                 COMPUTE WS-INTEREST-EARNED =
                     TD-AMOUNT * TD-INTEREST-RATE / 100
                     * (WS-FECHA - TD-DATE-ISSUE) / 360
             ELSE
                 MOVE 'N' TO WS-EARLY-CLOSE
                 MOVE TD-AMOUNT-INTEREST TO WS-INTEREST-EARNED
             END-IF.
        *
             COMPUTE WS-PAYOUT-AMOUNT =
                 TD-AMOUNT + WS-INTEREST-EARNED
                 - WS-PENALTY-AMOUNT.
             IF WS-PAYOUT-AMOUNT < 0
                 MOVE 0 TO WS-PAYOUT-AMOUNT
             END-IF.
        *
         4000-PROCESAR-LIQUIDACION.
             MOVE SPACES TO WS-MENSAJE-ERROR.
        *
             IF WS-PAYOUT-AMOUNT <= 0
                 MOVE 'CALCULO INVALIDO - REVISE DATOS'
                   TO WS-MENSAJE-ERROR
                 GOTO 4000-EXIT
             END-IF.
        *
             MOVE SPACES TO WS-CONFIRM.
             DISPLAY 'LIQUIDAR CD ' WS-CERT-NBR
                     ' POR ' WS-PAYOUT-AMOUNT '? (S/N): '
                 AT LINE 23 COLUMN 05.
             ACCEPT WS-CONFIRM AT LINE 23 COLUMN 60.
             IF WS-CONFIRM NOT = 'S' AND NOT = 's'
                 MOVE 'LIQUIDACION CANCELADA' TO WS-MENSAJE
                 GOTO 4000-EXIT
             END-IF.
        *
             OPEN I-O TIMEDEP-FILE.
             IF FL-TIMEDEP-STATUS NOT = '00'
                 MOVE 'ERROR AL ABRIR TIMEDEP' TO WS-MENSAJE-ERROR
                 GOTO 4000-EXIT
             END-IF.
        *
             MOVE WS-CERT-NBR TO TD-NBR.
             READ TIMEDEP-FILE KEY IS TD-NBR
                 INVALID KEY
                     MOVE 'ERROR AL LEER CD' TO WS-MENSAJE-ERROR
                     CLOSE TIMEDEP-FILE
                     GOTO 4000-EXIT
             END-READ.
        *
             IF WS-ANTES-VCTO
                 MOVE 'E' TO TD-STATUS
             ELSE
                 MOVE 'C' TO TD-STATUS
             END-IF.
        *
             MOVE WS-INTEREST-EARNED TO TD-AMOUNT-INTEREST.
             COMPUTE TD-AMOUNT-TOTAL =
                 TD-AMOUNT + WS-INTEREST-EARNED.
             MOVE WS-FECHA TO TD-DATE-LAST-INT-PAYMENT.
        *
             REWRITE TIMEDEP-RECORD
                 INVALID KEY
                     MOVE 'ERROR AL ACTUALIZAR CD'
                       TO WS-MENSAJE-ERROR
                     CLOSE TIMEDEP-FILE
                     GOTO 4000-EXIT
             END-REWRITE.
        *
             CLOSE TIMEDEP-FILE.
        *
             PERFORM 5000-ESCRIBIR-TRANLOG.
             PERFORM 6000-AUDITAR.
        *
             STRING 'CD ' WS-CERT-NBR ' LIQUIDADO POR '
                    WS-PAYOUT-AMOUNT
               INTO WS-MENSAJE.
         4000-EXIT.
             EXIT.
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
             MOVE 'CIE' TO TRN-TYPE.
             MOVE WS-CERT-NBR TO TRN-ACCOUNT-NBR.
             MOVE TD-ACCOUNT-DEST TO TRN-ACCOUNT-DEST.
             MOVE TD-CUSTOMER-ID TO TRN-CUSTOMER-ID.
             MOVE WS-PAYOUT-AMOUNT TO TRN-AMOUNT.
             MOVE 0 TO TRN-AMOUNT-TAX.
             MOVE WS-PAYOUT-AMOUNT TO TRN-AMOUNT-TOTAL.
             MOVE TD-AMOUNT TO TRN-AMOUNT-ORIGINAL.
             MOVE WS-PENALTY-AMOUNT TO TRN-FEE-AMOUNT.
             MOVE 'PE02' TO TRN-FEE-CODE.
             MOVE TD-BRANCH TO TRN-BRANCH.
             MOVE SPACES TO TRN-TELLER-ID.
             MOVE WS-USUARIO-ID TO TRN-USER-ID.
             MOVE SPACES TO TRN-TERMINAL.
             MOVE '01' TO TRN-CHANNEL.
             MOVE SPACES TO TRN-REFERENCE.
             MOVE 0 TO TRN-CHQ-NBR.
             MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
             MOVE 'C' TO TRN-STATUS.
             MOVE 0 TO TRN-REVERSE-SEQ.
             MOVE 'LIQUIDACION CD' TO TRN-DESCRIPTION.
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
             STRING 'TDCLS000 CD=' WS-CERT-NBR ' MONTO='
                    WS-PAYOUT-AMOUNT
               INTO WS-AUDIT-DATA.
             CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                   WS-AUDIT-DATA.
        *
         END PROGRAM TDCLS000.
