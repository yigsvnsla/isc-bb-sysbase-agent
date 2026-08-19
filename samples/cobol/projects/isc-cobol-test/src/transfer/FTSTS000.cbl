       *================================================================*
       * FTSTS000 - CONSULTA ESTADO DE TRANSFERENCIA                  *
       * PROPOSITO: VISUALIZAR ESTADO DE TRANSFERENCIA POR REFERENCIA *
       * EQUIPO: TRANSACCIONES ELECTRONICAS - 2004                   *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. FTSTS000.
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
            SELECT TRANLOG-FILE
                ASSIGN TO 'TRANLOG.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS TRN-SEQ
                ALTERNATE RECORD KEY IS TRN-REFERENCE
                    WITH DUPLICATES
                FILE STATUS IS FL-TRANLOG-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'FTSTS000'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-REFERENCE               PIC X(20).
            05  WS-AUDIT-DATA              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-STATUS.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' CONSULTA ESTADO DE TRANSFERENCIA'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-ID.
                10  LINE 04  COL 05  PIC X(20) VALUE 'REFERENCIA:'.
                10  LINE 04  COL 25  PIC X(20)
                    USING WS-REFERENCE AUTO PROMPT '___________________'.
                10  LINE 04  COL 50  PIC X(20) VALUE 'ENTER=CONSULTA'.
       *
            05  SCR-DATOS.
                10  LINE 06  COL 05  PIC X(15) VALUE 'FECHA:'.
                10  LINE 06  COL 20  PIC 9(08) FROM TRN-DATE.
                10  LINE 06  COL 40  PIC X(15) VALUE 'HORA:'.
                10  LINE 06  COL 55  PIC 9(06) FROM TRN-TIME.
       *
                10  LINE 07  COL 05  PIC X(15) VALUE 'TIPO:'.
                10  LINE 07  COL 20  PIC X(03) FROM TRN-TYPE.
                10  LINE 07  COL 30  PIC X(20) VALUE 'CTA ORIGEN:'.
                10  LINE 07  COL 50  PIC X(10) FROM TRN-ACCOUNT-NBR.
       *
                10  LINE 08  COL 05  PIC X(20) VALUE 'CTA DESTINO:'.
                10  LINE 08  COL 25  PIC X(10) FROM TRN-ACCOUNT-DEST.
       *
                10  LINE 10  COL 05  PIC X(15) VALUE 'MONTO:'.
                10  LINE 10  COL 22  PIC -(11)9.99 FROM TRN-AMOUNT.
                10  LINE 10  COL 45  PIC X(15) VALUE 'COMISION:'.
                10  LINE 10  COL 62  PIC -(07)9.99 FROM TRN-FEE-AMOUNT.
       *
                10  LINE 11  COL 05  PIC X(15) VALUE 'TOTAL:'.
                10  LINE 11  COL 22  PIC -(11)9.99 FROM TRN-AMOUNT-TOTAL.
       *
                10  LINE 13  COL 05  PIC X(15) VALUE 'REFERENCIA:'.
                10  LINE 13  COL 20  PIC X(20) FROM TRN-REFERENCE.
       *
                10  LINE 14  COL 05  PIC X(15) VALUE 'ESTATUS:'.
                10  LINE 14  COL 20  PIC X(01) FROM TRN-STATUS.
                10  LINE 14  COL 25  PIC X(40)
                    VALUE 'P=PENDIENTE  C=CONFIRMADO  R=RECHAZADO'.
                10  LINE 14  COL 25  PIC X(40)
                    VALUE 'V=REVERSADO'.
       *
                10  LINE 15  COL 05  PIC X(15) VALUE 'DESCRIPCION:'.
                10  LINE 15  COL 22  PIC X(30) FROM TRN-DESCRIPTION.
       *
                10  LINE 17  COL 05  PIC X(15) VALUE 'USUARIO:'.
                10  LINE 17  COL 20  PIC X(08) FROM TRN-USER-ID.
                10  LINE 17  COL 40  PIC X(15) VALUE 'SUCURSAL:'.
                10  LINE 17  COL 55  PIC X(04) FROM TRN-BRANCH.
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
            MOVE SPACES TO WS-REFERENCE.
       *
            PERFORM 1000-INICIALIZAR.
       *
        STS-LOOP.
            PERFORM 2000-REFRESCAR.
            DISPLAY SCR-STATUS.
            ACCEPT SCR-STATUS.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 3000-CONSULTAR-TRF
                    GO TO STS-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'FTSTS000'
                    GO TO STS-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO STS-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-REFERENCE
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO STS-LOOP
       *
                WHEN OTHER
                    MOVE 'INGRESE REFERENCIA Y ENTER  PF12=RET'
                      TO WS-MENSAJE-ERROR
                    GO TO STS-LOOP
            END-EVALUATE.
       *
        STS-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'INGRESE REFERENCIA DE TRANSFERENCIA' TO WS-MENSAJE.
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
        3000-CONSULTAR-TRF.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            IF WS-REFERENCE = SPACES OR = LOW-VALUES
                MOVE 'INGRESE REFERENCIA' TO WS-MENSAJE-ERROR
                GO TO 3000-EXIT
            END-IF.
       *
            OPEN I-O TRANLOG-FILE.
            IF FL-TRANLOG-STATUS NOT = '00' AND NOT = '23'
                MOVE 'ERROR AL ABRIR TRANLOG' TO WS-MENSAJE-ERROR
                GO TO 3000-EXIT
            END-IF.
       *
            MOVE WS-REFERENCE TO TRN-REFERENCE.
            READ TRANLOG-FILE KEY IS TRN-REFERENCE
                INVALID KEY
                    MOVE 'TRANSFERENCIA NO ENCONTRADA'
                      TO WS-MENSAJE-ERROR
                    CLOSE TRANLOG-FILE
                    GO TO 3000-EXIT
            END-READ.
       *
            IF FL-TRANLOG-STATUS = '00'
                MOVE 'TRANSFERENCIA ENCONTRADA - PF12=RET'
                  TO WS-MENSAJE
                STRING 'FTSTS000 REF=' WS-REFERENCE
                  INTO WS-AUDIT-DATA
                CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                      WS-AUDIT-DATA
            ELSE
                MOVE 'ERROR AL LEER TRANLOG' TO WS-MENSAJE-ERROR
            END-IF.
       *
            CLOSE TRANLOG-FILE.
        3000-EXIT.
            EXIT.
       *
        END PROGRAM FTSTS000.
