       *================================================================*
       * LONAMR00 - TABLA DE AMORTIZACION COMPLETA                     *
       * PROPOSITO: DESPLEGAR TABLA DE AMORTIZACION DEL PRESTAMO       *
       * EQUIPO: CREDITO Y COBRANZA - 2005                             *
       * ARCHIVOS: LOANMAST                                             *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. LONAMR00.
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
            88  WS-CRT-PF4                VALUE 1004.
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
            05  WS-PAGINA                  PIC 9(04).
            05  WS-LINEA                   PIC 9(02).
            05  WS-I                       PIC 9(04).
            05  WS-J                       PIC 9(04).
            05  WS-REG-POR-PAG             PIC 9(02) VALUE 14.
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'LONAMR00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-BUSQUEDA.
            05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - TABLA DE AMORTIZACION'.
            05  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
            05  LINE 02  COL 01  PIC X(80)
               VALUE ' INGRESE NUMERO DE PRESTAMO:'.
            05  LINE 02  COL 32  PIC X(10)
               USING WS-LOAN-NBR AUTO PROMPT '__________'.
            05  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
            05  LINE 24  COL 05  PIC X(60)
               VALUE 'ENTER=CONSULTAR  PF12=SALIR'.
       *
        01  SCR-TABLA.
            05  SCR-CAB.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - TABLA DE AMORTIZACION'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' PRESTAMO:'.
                10  LINE 02  COL 12  PIC X(10) FROM LON-NBR.
                10  LINE 02  COL 30  PIC X(15) VALUE 'CLIENTE:'.
                10  LINE 02  COL 45  PIC X(10) FROM LON-CUSTOMER-ID.
                10  LINE 02  COL 60  PIC X(15) VALUE 'SALDO:'.
                10  LINE 02  COL 72  PIC Z(12)9.99 FROM LON-BALANCE.
       *
            05  SCR-HEADER.
                10  LINE 03  COL 01  PIC X(80)
                   VALUE 'CUOTA FECHA VCTO   MONTO     PRINCIPAL  INTERES
      -    '   SALDO     EST'.
       *
            05  SCR-INST-LINE OCCURS 14.
                10  LINE-PLUS 4            PIC 9(04) FROM WS-I.
                10  LINE-PLUS 10           PIC 9(08) FROM WS-I.
                10  LINE-PLUS 20           PIC Z(08)9.99 FROM WS-I.
                10  LINE-PLUS 30           PIC Z(08)9.99 FROM WS-I.
                10  LINE-PLUS 40           PIC Z(08)9.99 FROM WS-I.
                10  LINE-PLUS 50           PIC Z(08)9.99 FROM WS-I.
                10  LINE-PLUS 60           PIC X(01) FROM WS-I.
       *
            05  SCR-MSG.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'PF7=PAG ANT  PF8=PAG SIG  PF4=IMPRIMIR  PF12=SAL
      -    'IR'.
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
                    MOVE 1 TO WS-PAGINA
                    PERFORM 4000-DESPLIEGA-TABLA
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
            MOVE 1 TO WS-PAGINA.
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
                    MOVE 'PRESTAMO NO ENCONTRADO'
                      TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 3000-EXIT
            END-READ.
       *
            MOVE 00 TO LS-RETCODE.
            MOVE 'PRESTAMO ENCONTRADO' TO WS-MENSAJE.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA
                                  'CONSULTA AMORTIZACION'.
       *
        3000-EXIT.
            EXIT.
       *
        4000-DESPLIEGA-TABLA.
            PERFORM 2100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
       *
        4100-PAGINA-LOOP.
            PERFORM 5000-MOSTRAR-PAGINA.
            ACCEPT SCR-TABLA.
       *
            IF WS-CRT-PF8
                COMPUTE WS-PAGINA = WS-PAGINA + 1
                IF WS-PAGINA > LON-PAYMENTS-TOTAL / WS-REG-POR-PAG + 1
                    SUBTRACT 1 FROM WS-PAGINA
                    MOVE 'ULTIMA PAGINA' TO WS-MENSAJE-ERROR
                END-IF
                GO TO 4100-PAGINA-LOOP
            END-IF.
       *
            IF WS-CRT-PF7
                IF WS-PAGINA > 1
                    SUBTRACT 1 FROM WS-PAGINA
                ELSE
                    MOVE 'PRIMERA PAGINA' TO WS-MENSAJE-ERROR
                END-IF
                GO TO 4100-PAGINA-LOOP
            END-IF.
       *
            IF WS-CRT-PF4
                DISPLAY 'IMPRIMIENDO...' UPON PRINTER
                MOVE 'ENVIADO A IMPRESORA' TO WS-MENSAJE
                GO TO 4100-PAGINA-LOOP
            END-IF.
       *
            IF WS-CRT-PF12 OR WS-CRT-CLEAR
                GOTO 4000-EXIT
            END-IF.
       *
            GO TO 4100-PAGINA-LOOP.
       *
        4000-EXIT.
            EXIT.
       *
        5000-MOSTRAR-PAGINA.
            COMPUTE WS-I = (WS-PAGINA - 1) * WS-REG-POR-PAG + 1.
            MOVE 4 TO WS-LINEA.
       *
            PERFORM UNTIL WS-I > LON-PAYMENTS-TOTAL
                OR WS-LINEA > 18
                DISPLAY LON-INST-NBR(WS-I)
                  AT LINE WS-LINEA COLUMN 02
                DISPLAY LON-INST-DUE-DATE(WS-I)
                  AT LINE WS-LINEA COLUMN 08
                DISPLAY LON-INST-AMOUNT(WS-I)
                  AT LINE WS-LINEA COLUMN 18
                DISPLAY LON-INST-PRINCIPAL(WS-I)
                  AT LINE WS-LINEA COLUMN 28
                DISPLAY LON-INST-INTEREST(WS-I)
                  AT LINE WS-LINEA COLUMN 38
                DISPLAY LON-INST-BALANCE(WS-I)
                  AT LINE WS-LINEA COLUMN 48
                DISPLAY LON-INST-STATUS(WS-I)
                  AT LINE WS-LINEA COLUMN 58
                ADD 1 TO WS-I
                ADD 1 TO WS-LINEA
            END-PERFORM.
       *
            STRING 'PAGINA ' WS-PAGINA ' DE '
                   LON-PAYMENTS-TOTAL ' CUOTAS'
              INTO WS-MENSAJE.
       *
        END PROGRAM LONAMR00.
