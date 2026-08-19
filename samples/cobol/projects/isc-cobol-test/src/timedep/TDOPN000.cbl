        *================================================================*
        * TDOPN000 - APERTURA DE CERTIFICADO DE DEPOSITO               *
        * PROPOSITO: EMITIR NUEVO CERTIFICADO DE DEPOSITO A PLAZO     *
        * EQUIPO: MESAS DE DINERO - 2006                               *
        * ARCHIVOS: TIMEDEP, RATEFILE, TRANLOG                         *
        *================================================================*
         IDENTIFICATION DIVISION.
         PROGRAM-ID. TDOPN000.
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
         FD  TIMEDEP-FILE
             RECORD 180 CHARACTERS.
         COPY FD-TIMEDEP.
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
             05  WS-PROGRAMA-ID             PIC X(08) VALUE 'TDOPN000'.
             05  WS-FECHA                   PIC 9(08).
             05  WS-HORA                    PIC 9(06).
             05  WS-FECHA-DDMM              PIC 9(08).
             05  WS-MENSAJE                 PIC X(60).
             05  WS-MENSAJE-ERROR           PIC X(60).
             05  WS-RETCODE                 PIC 99.
             05  WS-CUSTOMER-ID             PIC X(10).
             05  WS-CERTIFICATE-NBR         PIC X(15).
             05  WS-TD-TYPE                 PIC X(02).
             05  WS-TD-AMOUNT               PIC 9(13)V99 COMP-3.
             05  WS-TD-TERM-DAYS            PIC 9(04).
             05  WS-TD-INT-TYPE             PIC X(01).
             05  WS-TD-PAY-FREQ             PIC X(01).
             05  WS-TD-ACCT-DEST            PIC X(10).
             05  WS-CONFIRM                 PIC X(01).
             05  WS-AUDIT-DATA              PIC X(60).
             05  WS-TRN-SEQ-AUX             PIC 9(10).
             05  WS-INTEREST-CALC           PIC 9(13)V99 COMP-3.
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
                     VALUE ' APERTURA DE CERTIFICADO DE DEPOSITO'.
                 10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
        *
             05  SCR-DATOS.
                 10  LINE 04  COL 05  PIC X(20) VALUE 'CLIENTE:'.
                 10  LINE 04  COL 25  PIC X(10)
                     USING WS-CUSTOMER-ID AUTO PROMPT '__________'.
                 10  LINE 04  COL 40  PIC X(30)
                     VALUE 'ENTER=CONS  PF1=SRH'.
        *
                 10  LINE 06  COL 05  PIC X(20) VALUE 'TIPO CD:'.
                 10  LINE 06  COL 25  PIC X(02)
                     USING WS-TD-TYPE AUTO PROMPT '__'.
                 10  LINE 06  COL 35  PIC X(40)
                     VALUE 'FI=FIJO  RE=REINFORZABLE  CA=CAPITAL'.
        *
                 10  LINE 07  COL 05  PIC X(20) VALUE 'MONTO:'.
                 10  LINE 07  COL 25  PIC -(11)9.99
                     USING WS-TD-AMOUNT AUTO.
        *
                 10  LINE 09  COL 05  PIC X(20) VALUE 'PLAZO DIAS:'.
                 10  LINE 09  COL 25  PIC 9(04)
                     USING WS-TD-TERM-DAYS AUTO.
        *
                 10  LINE 10  COL 05  PIC X(20) VALUE 'TIPO INTERES:'.
                 10  LINE 10  COL 25  PIC X(01)
                     USING WS-TD-INT-TYPE AUTO PROMPT '_'.
                 10  LINE 10  COL 35  PIC X(30)
                     VALUE 'S=SIMPLE  C=COMPUESTO'.
        *
                 10  LINE 11  COL 05  PIC X(20) VALUE 'FREC PAGO:'.
                 10  LINE 11  COL 25  PIC X(01)
                     USING WS-TD-PAY-FREQ AUTO PROMPT '_'.
                 10  LINE 11  COL 35  PIC X(40)
                     VALUE 'M=MEN  T=TRI  S=SEM  V=VCTO'.
        *
                 10  LINE 13  COL 05  PIC X(20) VALUE 'CTA DESTINO:'.
                 10  LINE 13  COL 25  PIC X(10)
                     USING WS-TD-ACCT-DEST AUTO PROMPT '__________'.
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
                            WS-TD-TYPE
                            WS-TD-INT-TYPE
                            WS-TD-PAY-FREQ
                            WS-TD-ACCT-DEST.
             MOVE 0 TO WS-TD-AMOUNT WS-TD-TERM-DAYS.
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
                     CALL 'COMHELP' USING 'TDOPN000'
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
                                    WS-TD-TYPE
                                    WS-TD-INT-TYPE
                                    WS-TD-PAY-FREQ
                                    WS-TD-ACCT-DEST
                     MOVE 0 TO WS-TD-AMOUNT WS-TD-TERM-DAYS
                     MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                     GO TO OPEN-LOOP
        *
                 WHEN OTHER
                     MOVE 'LLENE CAMPOS - PF1=SRH CLI  PF12=CANCEL'
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
             MOVE 'INGRESE DATOS DEL CERTIFICADO - PF1=BUSCAR CLIENTE'
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
                 MOVE 'INGRESE CLIENTE O USE PF1' TO WS-MENSAJE-ERROR
                 MOVE 'Y' TO WS-SWITCH-ERROR
                 GOTO 3000-EXIT
             END-IF.
        *
             IF WS-TD-TYPE NOT = 'FI' AND NOT = 'RE' AND NOT = 'CA'
                 MOVE 'TIPO INVALIDO (FI/RE/CA)' TO WS-MENSAJE-ERROR
                 MOVE 'Y' TO WS-SWITCH-ERROR
                 GOTO 3000-EXIT
             END-IF.
        *
             IF WS-TD-AMOUNT <= 0
                 MOVE 'MONTO DEBE SER MAYOR A CERO' TO WS-MENSAJE-ERROR
                 MOVE 'Y' TO WS-SWITCH-ERROR
                 GOTO 3000-EXIT
             END-IF.
        *
             IF WS-TD-TERM-DAYS <= 0
                 MOVE 'PLAZO DEBE SER MAYOR A CERO' TO WS-MENSAJE-ERROR
                 MOVE 'Y' TO WS-SWITCH-ERROR
                 GOTO 3000-EXIT
             END-IF.
        *
             IF WS-TD-INT-TYPE NOT = 'S' AND NOT = 'C'
                 MOVE 'TIPO INTERES INVALIDO (S/C)' TO WS-MENSAJE-ERROR
                 MOVE 'Y' TO WS-SWITCH-ERROR
                 GOTO 3000-EXIT
             END-IF.
        *
             IF WS-TD-PAY-FREQ NOT = 'M' AND NOT = 'T'
                 AND NOT = 'S' AND NOT = 'V'
                 MOVE 'FRECUENCIA INVALIDA (M/T/S/V)'
                   TO WS-MENSAJE-ERROR
                 MOVE 'Y' TO WS-SWITCH-ERROR
                 GOTO 3000-EXIT
             END-IF.
        *
             IF WS-TD-ACCT-DEST = SPACES
                 MOVE 'CTA DESTINO REQUERIDA' TO WS-MENSAJE-ERROR
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
             IF RAT-TASA-ANUAL = 0
                 MOVE 'NO SE ENCONTRO TASA PARA PRODUCTO'
                   TO WS-MENSAJE-ERROR
                 GOTO 4000-EXIT
             END-IF.
        *
             MOVE SPACES TO WS-CONFIRM.
             DISPLAY 'CONFIRMAR APERTURA DE CD? (S/N): '
                 AT LINE 23 COLUMN 05.
             ACCEPT WS-CONFIRM AT LINE 23 COLUMN 41.
             IF WS-CONFIRM NOT = 'S' AND NOT = 's'
                 MOVE 'APERTURA CANCELADA' TO WS-MENSAJE
                 GOTO 4000-EXIT
             END-IF.
        *
             OPEN I-O TIMEDEP-FILE.
             IF FL-TIMEDEP-STATUS NOT = '00'
                 OPEN OUTPUT TIMEDEP-FILE
                 IF FL-TIMEDEP-STATUS NOT = '00'
                     MOVE 'ERROR AL ABRIR TIMEDEP' TO WS-MENSAJE-ERROR
                     GOTO 4000-EXIT
                 END-IF
             END-IF.
        *
             PERFORM 4200-GENERAR-NUMERO.
             MOVE WS-CERTIFICATE-NBR TO TD-NBR.
             MOVE WS-CUSTOMER-ID TO TD-CUSTOMER-ID.
             MOVE WS-CERTIFICATE-NBR TO TD-CERTIFICATE-NBR.
             MOVE WS-TD-TYPE TO TD-TYPE.
             MOVE WS-TD-AMOUNT TO TD-AMOUNT.
             MOVE 0 TO TD-AMOUNT-INTEREST.
             MOVE WS-TD-AMOUNT TO TD-AMOUNT-TOTAL
                                  TD-AMOUNT-MIN.
             MOVE RAT-TASA-ANUAL TO TD-INTEREST-RATE.
             MOVE WS-TD-INT-TYPE TO TD-INTEREST-TYPE.
             MOVE WS-TD-PAY-FREQ TO TD-PAYMENT-FREQ.
             MOVE WS-TD-TERM-DAYS TO TD-TERM-DAYS.
             COMPUTE TD-TERM-MONTHS = WS-TD-TERM-DAYS / 30.
             MOVE WS-FECHA TO TD-DATE-ISSUE.
             CALL 'COMDATE' USING 'ADD'
                                  WS-FECHA
                                  WS-TD-TERM-DAYS.
             MOVE WS-FECHA TO TD-DATE-MATURITY.
             MOVE WS-FECHA TO TD-DATE-LAST-INT-PAYMENT.
             MOVE 'A' TO TD-STATUS.
             MOVE 0 TO TD-RENEWAL-COUNT.
             MOVE 0 TO TD-EARLY-PENALTY-RATE.
             MOVE WS-TD-ACCT-DEST TO TD-ACCOUNT-DEST.
             MOVE WS-SUCURSAL-ID TO TD-BRANCH.
        *
             WRITE TIMEDEP-RECORD
                 INVALID KEY
                     MOVE 'ERROR AL ESCRIBIR TIMEDEP' TO WS-MENSAJE-ERROR
                     CLOSE TIMEDEP-FILE
                     GOTO 4000-EXIT
             END-WRITE.
        *
             CLOSE TIMEDEP-FILE.
        *
             PERFORM 4300-ESCRIBIR-TRANLOG.
             PERFORM 4400-AUDITAR.
        *
             STRING 'CD ' TD-CERTIFICATE-NBR ' CREADO EXITOSAMENTE'
               INTO WS-MENSAJE.
        *
         4000-EXIT.
             EXIT.
        *
         4100-LEER-TASA.
             MOVE 0 TO RAT-TASA-ANUAL.
        *
             OPEN I-O RATEFILE-FILE.
             IF FL-RATEFILE-STATUS NOT = '00' AND NOT = '23'
                 GOTO 4100-EXIT
             END-IF.
        *
             STRING 'TDP' WS-TD-TYPE INTO RAT-CODIGO.
             READ RATEFILE-FILE KEY IS RAT-CODIGO
                 INVALID KEY
                     CLOSE RATEFILE-FILE
                     GOTO 4100-EXIT
             END-READ.
        *
             CLOSE RATEFILE-FILE.
         4100-EXIT.
             EXIT.
        *
         4200-GENERAR-NUMERO.
             MOVE 'CD' TO WS-CERTIFICATE-NBR(1:2).
             MOVE WS-FECHA TO WS-CERTIFICATE-NBR(3:8).
             MOVE WS-TD-TYPE TO WS-CERTIFICATE-NBR(11:2).
             MOVE '01' TO WS-CERTIFICATE-NBR(13:2).
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
             ADD 1 TO TRN-SEQ.
             MOVE TRN-SEQ TO WS-TRN-SEQ-AUX.
             MOVE WS-TRN-SEQ-AUX TO TRN-SEQ.
        *
         4300-ESCRIBE.
             MOVE WS-FECHA TO TRN-DATE.
             MOVE WS-HORA TO TRN-TIME.
             MOVE 'APE' TO TRN-TYPE.
             MOVE WS-CERTIFICATE-NBR TO TRN-ACCOUNT-NBR.
             MOVE WS-TD-ACCT-DEST TO TRN-ACCOUNT-DEST.
             MOVE WS-CUSTOMER-ID TO TRN-CUSTOMER-ID.
             MOVE WS-TD-AMOUNT TO TRN-AMOUNT
                                   TRN-AMOUNT-TOTAL
                                   TRN-AMOUNT-ORIGINAL.
             MOVE 0 TO TRN-AMOUNT-TAX.
             MOVE 0 TO TRN-FEE-AMOUNT.
             MOVE SPACES TO TRN-FEE-CODE.
             MOVE WS-SUCURSAL-ID TO TRN-BRANCH.
             MOVE SPACES TO TRN-TELLER-ID.
             MOVE WS-USUARIO-ID TO TRN-USER-ID.
             MOVE SPACES TO TRN-TERMINAL.
             MOVE '01' TO TRN-CHANNEL.
             MOVE SPACES TO TRN-REFERENCE.
             MOVE 0 TO TRN-CHQ-NBR.
             MOVE SPACES TO TRN-CHQ-BANK TRN-CHQ-ACCOUNT.
             MOVE 'C' TO TRN-STATUS.
             MOVE 0 TO TRN-REVERSE-SEQ.
             MOVE 'APERTURA CD' TO TRN-DESCRIPTION.
        *
             WRITE TRANLOG-RECORD
                 INVALID KEY
                     DISPLAY 'ERROR TRANLOG'
             END-WRITE.
        *
             CLOSE TRANLOG-FILE.
         4300-EXIT.
             EXIT.
        *
         4400-AUDITAR.
             STRING 'TDOPN000 CD=' WS-CERTIFICATE-NBR
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
         END PROGRAM TDOPN000.
