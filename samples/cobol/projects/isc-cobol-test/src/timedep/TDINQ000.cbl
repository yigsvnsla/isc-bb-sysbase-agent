        *================================================================*
        * TDINQ000 - CONSULTA DE CERTIFICADO DE DEPOSITO               *
        * PROPOSITO: VISUALIZAR DATOS COMPLETOS DE UN CD              *
        * EQUIPO: MESAS DE DINERO - 2006                               *
        * ARCHIVOS: TIMEDEP (LECTURA)                                 *
        *================================================================*
         IDENTIFICATION DIVISION.
         PROGRAM-ID. TDINQ000.
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
        *================================================================*
         DATA DIVISION.
         FILE SECTION.
         FD  TIMEDEP-FILE
             RECORD 180 CHARACTERS.
         COPY FD-TIMEDEP.
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
             05  WS-PROGRAMA-ID             PIC X(08) VALUE 'TDINQ000'.
             05  WS-FECHA                   PIC 9(08).
             05  WS-HORA                    PIC 9(06).
             05  WS-FECHA-DDMM              PIC 9(08).
             05  WS-MENSAJE                 PIC X(60).
             05  WS-MENSAJE-ERROR           PIC X(60).
             05  WS-RETCODE                 PIC 99.
             05  WS-CERT-NBR                PIC X(15).
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
                     VALUE ' CONSULTA DE CERTIFICADO DE DEPOSITO'.
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
        *
                 10  LINE 07  COL 05  PIC X(15) VALUE 'MONTO:'.
                 10  LINE 07  COL 22  PIC -(11)9.99 FROM TD-AMOUNT.
                 10  LINE 07  COL 45  PIC X(20) VALUE 'INTERES DEVENG:'.
                 10  LINE 07  COL 65  PIC -(11)9.99 FROM TD-AMOUNT-INTEREST.
        *
                 10  LINE 08  COL 05  PIC X(15) VALUE 'TOTAL:'.
                 10  LINE 08  COL 22  PIC -(11)9.99 FROM TD-AMOUNT-TOTAL.
        *
                 10  LINE 10  COL 05  PIC X(15) VALUE 'TASA:'.
                 10  LINE 10  COL 22  PIC 9(03).9(06) FROM TD-INTEREST-RATE.
                 10  LINE 10  COL 45  PIC X(20) VALUE 'TIPO INT:'.
                 10  LINE 10  COL 62  PIC X(01) FROM TD-INTEREST-TYPE.
                 10  LINE 10  COL 68  PIC X(20) VALUE 'S=Simple C=Comp'.
        *
                 10  LINE 11  COL 05  PIC X(20) VALUE 'FRECUENCIA PAGO:'.
                 10  LINE 11  COL 25  PIC X(01) FROM TD-PAYMENT-FREQ.
                 10  LINE 11  COL 30  PIC X(25)
                     VALUE 'M=MEN  T=TRI  S=SEM  V=VCT'.
        *
                 10  LINE 13  COL 05  PIC X(15) VALUE 'PLAZO DIAS:'.
                 10  LINE 13  COL 20  PIC 9(04) FROM TD-TERM-DAYS.
                 10  LINE 13  COL 30  PIC X(15) VALUE 'PLAZO MESES:'.
                 10  LINE 13  COL 45  PIC 9(03) FROM TD-TERM-MONTHS.
        *
                 10  LINE 14  COL 05  PIC X(15) VALUE 'EMISION:'.
                 10  LINE 14  COL 20  PIC 9(08) FROM TD-DATE-ISSUE.
                 10  LINE 14  COL 40  PIC X(15) VALUE 'VENCIMIENTO:'.
                 10  LINE 14  COL 55  PIC 9(08) FROM TD-DATE-MATURITY.
        *
                 10  LINE 15  COL 05  PIC X(20) VALUE 'ULT PAGO INTERES:'.
                 10  LINE 15  COL 25  PIC 9(08) FROM TD-DATE-LAST-INT-PAYMENT.
        *
                 10  LINE 17  COL 05  PIC X(15) VALUE 'ESTATUS:'.
                 10  LINE 17  COL 20  PIC X(01) FROM TD-STATUS.
                 10  LINE 17  COL 25  PIC X(30)
                     VALUE 'A=ACT C=CANC R=RENO E=EARLY'.
                 10  LINE 17  COL 60  PIC X(20) VALUE 'RENOVACIONES:'.
                 10  LINE 17  COL 75  PIC 9(02) FROM TD-RENEWAL-COUNT.
        *
                 10  LINE 18  COL 05  PIC X(20) VALUE 'PENALIZACION:'.
                 10  LINE 18  COL 25  PIC 9(03).9(04)
                     FROM TD-EARLY-PENALTY-RATE.
                 10  LINE 18  COL 45  PIC X(20) VALUE 'CTA DESTINO:'.
                 10  LINE 18  COL 65  PIC X(10) FROM TD-ACCOUNT-DEST.
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
             MOVE SPACES TO WS-CERT-NBR.
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
                     PERFORM 3000-CONSULTAR-CD
                     GO TO INQUIRY-LOOP
        *
                 WHEN WS-CRT-PF11
                     CALL 'COMHELP' USING 'TDINQ000'
                     GO TO INQUIRY-LOOP
        *
                 WHEN WS-CRT-PF12
                     MOVE 00 TO LS-RETCODE
                     GO TO INQUIRY-EXIT
        *
                 WHEN WS-CRT-CLEAR
                     MOVE SPACES TO WS-CERT-NBR
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
             MOVE 'INGRESE NUMERO DE CERTIFICADO Y PRESIONE ENTER'
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
         3000-CONSULTAR-CD.
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
             IF FL-TIMEDEP-STATUS = '00'
                 MOVE 'CD ENCONTRADO - PRESIONE PF12=SALIR'
                   TO WS-MENSAJE
                 STRING 'TDINQ000 CD=' WS-CERT-NBR
                   INTO WS-AUDIT-DATA
                 CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                       WS-AUDIT-DATA
             ELSE
                 MOVE 'ERROR AL LEER CD' TO WS-MENSAJE-ERROR
             END-IF.
        *
             CLOSE TIMEDEP-FILE.
         3000-EXIT.
             EXIT.
        *
         END PROGRAM TDINQ000.
