       *================================================================*
       * TLRSMG00 - RESUMEN / CIERRE DE CAJA                           *
       * PROPOSITO: MOSTAR RESUMEN DIARIO, CALCULAR DIFERENCIAS        *
       * EQUIPO: VENTANILLA - 2002                                     *
       * ARCHIVOS: TELLEREC                                             *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. TLRSMG00.
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
            SELECT TELLEREC-FILE
                ASSIGN TO 'TELLEREC.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS TLR-ID
                FILE STATUS IS FL-TELLEREC-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  TELLEREC-FILE
            RECORD 150 CHARACTERS.
        COPY FD-TELLEREC REPLACING TELLEREC-FILE BY TELLEREC-FILE
                TELLEREC-RECORD BY TELLEREC-RECORD.
       *================================================================*
        WORKING-STORAGE SECTION.
        COPY CPY-COMMON.
        COPY CPY-SCREEN.
       *
        01  WS-CRT-STATUS                  PIC 9(04).
            88  WS-CRT-PF1                VALUE 1001.
            88  WS-CRT-PF4                VALUE 1004.
            88  WS-CRT-PF12               VALUE 1012.
            88  WS-CRT-ENTER              VALUE 0013.
            88  WS-CRT-CLEAR              VALUE 0000.
       *
        01  WS-VARIABLES.
            05  WS-USUARIO                 PIC X(08).
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-CONFIRMA                PIC X(01).
            05  WS-TOTAL-INGRESOS          PIC 9(09)V99 COMP-3.
            05  WS-TOTAL-INGRESOS-DISP     PIC Z(08)9.99.
            05  WS-TOTAL-EGRESOS           PIC 9(09)V99 COMP-3.
            05  WS-TOTAL-EGRESOS-DISP      PIC Z(08)9.99.
            05  WS-TEORICO                 PIC 9(09)V99 COMP-3.
            05  WS-TEORICO-DISP            PIC Z(08)9.99.
            05  WS-ACTUAL-DISP             PIC Z(08)9.99.
            05  WS-DIFERENCIA              PIC S9(09)V99 COMP-3.
            05  WS-DIFERENCIA-DISP         PIC -Z(08)9.99.
            05  WS-FONDO-CIERRE            PIC 9(09)V99 COMP-3.
            05  WS-FONDO-CIERRE-DISP       PIC Z(08)9.99.
            05  WS-AJUSTE                  PIC 9(09)V99 COMP-3.
            05  WS-AJUSTE-DISP             PIC Z(08)9.99.
       *
        01  WS-AUDIT-DATA.
            05  WS-AUDIT-PROGRAMA          PIC X(08) VALUE 'TLRSMG00'.
            05  WS-AUDIT-INFO              PIC X(60).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-RESUMEN.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                   VALUE ' BANCO NACIONAL - RESUMEN DE CAJA'.
                10  LINE 01  COL 65  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                   VALUE ' CAJERO: '.
                10  LINE 02  COL 10  PIC X(08) FROM WS-USUARIO.
       *
            05  SCR-CUERPO.
                10  LINE 04  COL 05  PIC X(30) VALUE 'RESUMEN DIARIO DE CAJA'.
                10  LINE 05  COL 05  PIC X(15) VALUE 'FONDO INICIAL:'.
                10  LINE 05  COL 25  PIC Z(08)9.99 FROM TLR-FONDO-INICIAL.
       *
                10  LINE 07  COL 05  PIC X(20) VALUE 'INGRESOS:'.
                10  LINE 08  COL 07  PIC X(15) VALUE 'DEPOSITOS:'.
                10  LINE 08  COL 25  PIC Z(08)9.99 FROM TLR-TOTAL-DEPOSITOS.
                10  LINE 08  COL 40  PIC Z(08)9.
                   FROM TLR-COUNT-DEPOSITOS.
       *
                10  LINE 10  COL 05  PIC X(20) VALUE 'EGRESOS:'.
                10  LINE 11  COL 07  PIC X(15) VALUE 'RETIROS:'.
                10  LINE 11  COL 25  PIC Z(08)9.99 FROM TLR-TOTAL-RETIROS.
                10  LINE 11  COL 40  PIC Z(08)9.
                   FROM TLR-COUNT-RETIROS.
                10  LINE 12  COL 07  PIC X(15) VALUE 'TRANSFERENCIAS:'.
                10  LINE 12  COL 25  PIC Z(08)9.99
                   FROM TLR-TOTAL-TRANSFERENCIAS.
                10  LINE 12  COL 40  PIC Z(08)9.
                   FROM TLR-COUNT-TRANSFERENCIAS.
                10  LINE 13  COL 07  PIC X(15) VALUE 'PAGOS:'.
                10  LINE 13  COL 25  PIC Z(08)9.99 FROM TLR-TOTAL-PAGOS.
                10  LINE 13  COL 40  PIC Z(08)9.
                   FROM TLR-COUNT-PAGOS.
                10  LINE 14  COL 07  PIC X(15) VALUE 'CHEQUES:'.
                10  LINE 14  COL 25  PIC Z(08)9.99 FROM TLR-TOTAL-CHEQUES.
                10  LINE 14  COL 40  PIC Z(08)9.
                   FROM TLR-COUNT-CHEQUES.
       *
                10  LINE 16  COL 05  PIC X(20) VALUE 'TOTAL INGRESOS:'.
                10  LINE 16  COL 25  PIC Z(08)9.99
                   FROM WS-TOTAL-INGRESOS-DISP.
                10  LINE 17  COL 05  PIC X(20) VALUE 'TOTAL EGRESOS:'.
                10  LINE 17  COL 25  PIC Z(08)9.99
                   FROM WS-TOTAL-EGRESOS-DISP.
       *
                10  LINE 19  COL 05  PIC X(20) VALUE 'SALDO TEORICO:'.
                10  LINE 19  COL 22  PIC Z(08)9.99 FROM WS-TEORICO-DISP.
                10  LINE 20  COL 05  PIC X(20) VALUE 'FONDO ACTUAL:'.
                10  LINE 20  COL 22  PIC Z(08)9.99 FROM WS-ACTUAL-DISP.
                10  LINE 21  COL 05  PIC X(20) VALUE 'DIFERENCIA:'.
                10  LINE 21  COL 22  PIC -Z(08)9.99 FROM WS-DIFERENCIA-DISP.
       *
            05  SCR-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 22  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                   BLINK.
       *
            05  SCR-PIE.
                10  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 24  COL 05  PIC X(60)
                   VALUE 'PF1=AJUSTE  PF4=CIERRE  PF12=SALIR'.
       *
        *--- PANTALLA DE AJUSTE ---*
        01  SCR-AJUSTE.
            05  LINE 05  COL 05  PIC X(30) VALUE 'AJUSTE DE CAJA'.
            05  LINE 07  COL 05  PIC X(20) VALUE 'FONDO ACTUAL:'.
            05  LINE 07  COL 22  PIC Z(08)9.99 FROM TLR-FONDO-ACTUAL.
            05  LINE 08  COL 05  PIC X(20) VALUE 'FONDO REAL:'.
            05  LINE 08  COL 22  PIC Z(08)9.99
                USING WS-FONDO-CIERRE-DISP AUTO PROMPT '________.__'.
            05  LINE 09  COL 05  PIC X(20) VALUE 'DIFERENCIA:'.
            05  LINE 09  COL 22  PIC -Z(08)9.99 FROM WS-DIFERENCIA-DISP.
            05  LINE 11  COL 05  PIC X(40)
                VALUE 'INGRESE MONTO REAL EN CAJA Y CONFIRME'.
            05  LINE 23  COL 01  PIC X(80) VALUE ALL '-'.
            05  LINE 24  COL 05  PIC X(40)
                VALUE 'ENTER=ACEPTAR  PF12=CANCELAR'.
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
        RESUMEN-LOOP.
            PERFORM 2000-CALCULAR-RESUMEN.
            PERFORM 3000-MOSTRAR.
            ACCEPT SCR-RESUMEN.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    PERFORM 4000-AJUSTAR
                    GO TO RESUMEN-LOOP
       *
                WHEN WS-CRT-PF4
                    PERFORM 5000-CONFIRMAR-CIERRE
                    IF WS-CONFIRMA = 'S'
                        PERFORM 6000-CERRAR-CAJA
                        IF WS-RETCODE = 00
                            MOVE 'CAJA CERRADA EXITOSAMENTE'
                              TO WS-MENSAJE
                            PERFORM 7000-AUDITAR
                            MOVE 00 TO LS-RETCODE
                            GOTO MAIN-EXIT
                        END-IF
                    END-IF
                    GO TO RESUMEN-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GOTO MAIN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO RESUMEN-LOOP
       *
                WHEN OTHER
                    GO TO RESUMEN-LOOP
            END-EVALUATE.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            DISPLAY SPACES UPON CRT.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            OPEN I-O TELLEREC-FILE.
            MOVE WS-USUARIO TO TLR-ID.
            MOVE WS-FECHA TO TLR-DATE.
            READ TELLEREC-FILE KEY IS TLR-ID
                INVALID KEY
                    MOVE 'SIN SESION DE CAJA' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 1000-EXIT
            END-READ.
            IF NOT TLR-STATUS-ABIERTO
                MOVE 'CAJA NO ESTA ABIERTA' TO WS-MENSAJE-ERROR
                MOVE 99 TO LS-RETCODE
                GOTO 1000-EXIT
            END-IF.
        1000-EXIT.
            EXIT.
       *
        2000-CALCULAR-RESUMEN.
            MOVE TLR-TOTAL-DEPOSITOS TO WS-TOTAL-INGRESOS.
            MOVE WS-TOTAL-INGRESOS TO WS-TOTAL-INGRESOS-DISP.
       *
            COMPUTE WS-TOTAL-EGRESOS =
                TLR-TOTAL-RETIROS +
                TLR-TOTAL-TRANSFERENCIAS +
                TLR-TOTAL-PAGOS +
                TLR-TOTAL-CHEQUES.
            MOVE WS-TOTAL-EGRESOS TO WS-TOTAL-EGRESOS-DISP.
       *
            COMPUTE WS-TEORICO =
                TLR-FONDO-INICIAL + TLR-TOTAL-DEPOSITOS
                - WS-TOTAL-EGRESOS.
            MOVE WS-TEORICO TO WS-TEORICO-DISP.
            MOVE TLR-FONDO-ACTUAL TO WS-ACTUAL-DISP.
       *
            COMPUTE WS-DIFERENCIA =
                TLR-FONDO-ACTUAL - WS-TEORICO.
            MOVE WS-DIFERENCIA TO WS-DIFERENCIA-DISP.
       *
            IF WS-DIFERENCIA NOT = ZERO
                MOVE 'ADVERTENCIA: DIFERENCIA DETECTADA'
                  TO WS-MENSAJE-ERROR
            ELSE
                MOVE 'CAJA CUADRADA - SIN DIFERENCIAS' TO WS-MENSAJE
            END-IF.
       *
        3000-MOSTRAR.
            PERFORM 3100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            DISPLAY SCR-RESUMEN.
       *
        3100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        4000-AJUSTAR.
            MOVE TLR-FONDO-ACTUAL TO WS-FONDO-CIERRE.
            MOVE WS-FONDO-CIERRE TO WS-FONDO-CIERRE-DISP.
            MOVE WS-DIFERENCIA TO WS-DIFERENCIA-DISP.
       *
        4100-AJUSTE-LOOP.
            PERFORM 3100-LIMPIAR.
            DISPLAY SCR-AJUSTE.
            ACCEPT SCR-AJUSTE.
       *
            IF WS-CRT-PF12
                GOTO 4000-EXIT
            END-IF.
       *
            MOVE WS-FONDO-CIERRE-DISP TO WS-FONDO-CIERRE.
            COMPUTE WS-DIFERENCIA =
                WS-FONDO-CIERRE - WS-TEORICO.
            MOVE WS-DIFERENCIA TO WS-DIFERENCIA-DISP.
       *
            IF WS-CRT-ENTER
                MOVE WS-FONDO-CIERRE TO TLR-FONDO-CIERRE
                MOVE WS-FONDO-CIERRE TO TLR-FONDO-ACTUAL
                MOVE WS-DIFERENCIA TO TLR-DIFERENCIA
                IF WS-DIFERENCIA = ZERO
                    MOVE 'S' TO TLR-CUADRADO
                ELSE
                    MOVE 'N' TO TLR-CUADRADO
                END-IF
                REWRITE TELLEREC-RECORD
                    INVALID KEY
                        MOVE 'ERROR AL AJUSTAR' TO WS-MENSAJE-ERROR
                        GOTO 4000-EXIT
                END-REWRITE
                MOVE 'AJUSTE APLICADO' TO WS-MENSAJE
                GOTO 4000-EXIT
            END-IF.
       *
            GO TO 4100-AJUSTE-LOOP.
        4000-EXIT.
            EXIT.
       *
        5000-CONFIRMAR-CIERRE.
            CALL 'COMMSGF' USING 'Q001'
                                 'CONFIRMA CIERRE DE CAJA?'
                                 'Q'
                                 WS-CONFIRMA.
       *
        6000-CERRAR-CAJA.
            MOVE WS-USUARIO TO TLR-ID.
            MOVE WS-FECHA TO TLR-DATE.
            READ TELLEREC-FILE KEY IS TLR-ID
                INVALID KEY
                    MOVE 'ERROR LEER CAJA' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 6000-EXIT
            END-READ.
       *
            MOVE WS-HORA TO TLR-HORA-CIERRE.
            MOVE 'C' TO TLR-STATUS.
            MOVE WS-FONDO-CIERRE TO TLR-FONDO-CIERRE.
            COMPUTE WS-DIFERENCIA =
                TLR-FONDO-ACTUAL - WS-TEORICO.
            MOVE WS-DIFERENCIA TO TLR-DIFERENCIA.
            IF WS-DIFERENCIA = ZERO
                MOVE 'S' TO TLR-CUADRADO
            ELSE
                MOVE 'N' TO TLR-CUADRADO
            END-IF.
       *
            REWRITE TELLEREC-RECORD
                INVALID KEY
                    MOVE 'ERROR AL CERRAR CAJA' TO WS-MENSAJE-ERROR
                    MOVE 99 TO LS-RETCODE
                    GOTO 6000-EXIT
            END-REWRITE.
       *
            MOVE 00 TO LS-RETCODE.
        6000-EXIT.
            EXIT.
       *
        7000-AUDITAR.
            STRING 'CIERRE CAJA ' TLR-ID ' DIF:'
                   WS-DIFERENCIA
              INTO WS-AUDIT-INFO.
            CALL 'AUDTRL00' USING WS-AUDIT-PROGRAMA WS-AUDIT-INFO.
       *
        9000-FINALIZAR.
            CLOSE TELLEREC-FILE.
            GOBACK.
       *
        END PROGRAM TLRSMG00.
