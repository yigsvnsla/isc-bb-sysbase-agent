       *================================================================*
       * DEPINT00 - CONFIGURACION DE TASAS DE INTERES                  *
       * PROPOSITO: MANTENIMIENTO DE TABLA RATEFILE                    *
       * EQUIPO: TESORERIA - 1999 (ACTUALIZADO 2003)                  *
       * ARCHIVOS: RATEFILE (LECTURA/ESCRITURA)                        *
       *================================================================*
        IDENTIFICATION DIVISION.
        PROGRAM-ID. DEPINT00.
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
            SELECT RATEFILE-FILE
                ASSIGN TO 'RATEFILE.DAT'
                ORGANIZATION IS INDEXED
                ACCESS MODE IS DYNAMIC
                RECORD KEY IS RAT-CODIGO
                FILE STATUS IS FL-RATEFILE-STATUS.
       *================================================================*
        DATA DIVISION.
        FILE SECTION.
        FD  RATEFILE-FILE
            RECORD 100 CHARACTERS.
        COPY FD-RATEFILE.
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
            05  WS-PROGRAMA-ID             PIC X(08) VALUE 'DEPINT00'.
            05  WS-FECHA                   PIC 9(08).
            05  WS-HORA                    PIC 9(06).
            05  WS-FECHA-DDMM              PIC 9(08).
            05  WS-MENSAJE                 PIC X(60).
            05  WS-MENSAJE-ERROR           PIC X(60).
            05  WS-RETCODE                 PIC 99.
            05  WS-CONFIRM                 PIC X(01).
            05  WS-AUDIT-DATA              PIC X(60).
            05  WS-FLAG-MODIFICAR          PIC X(01).
                88  WS-ES-ALTA             VALUE 'A'.
                88  WS-ES-CAMBIO           VALUE 'C'.
            05  WS-IND                     PIC 9(02).
            05  WS-VER-COUNT               PIC 9(03).
            05  WS-VER-PAGE                PIC 9(02).
            05  WS-VER-PAGE-MAX            PIC 9(02).
            05  WS-VER-LINE                PIC 9(02).
            05  WS-VER-IND                 PIC 9(03).
       *
        01  WS-VER-TABLE.
            05  WS-VER-ENTRY               OCCURS 30.
                10  WS-VER-CODIGO          PIC X(06).
                10  WS-VER-DESC            PIC X(35).
                10  WS-VER-TASA            PIC 9(03)V9(06) COMP-3.
                10  WS-VER-STATUS          PIC X(01).
       *
       *================================================================*
        SCREEN SECTION.
       *
        01  SCR-MENU-TASAS.
            05  SCR-CABECERA.
                10  LINE 01  COL 01  PIC X(80)
                    VALUE ' BANCO NACIONAL - SISTEMA INTEGRAL BANCARIO'.
                10  LINE 01  COL 62  PIC 9(08) FROM WS-FECHA-DDMM.
                10  LINE 01  COL 72  PIC 9(06) FROM WS-HORA.
                10  LINE 02  COL 01  PIC X(80)
                    VALUE ' CONFIGURACION DE TASAS DE INTERES'.
                10  LINE 02  COL 60  PIC X(08) FROM WS-USUARIO-ID.
       *
            05  SCR-FUNCION.
                10  LINE 04  COL 05  PIC X(40)
                    VALUE 'SELECCIONE: PF1=ALTAS  PF2=CONS  PF3=EDIT'.
                10  LINE 04  COL 50  PIC X(30)
                    VALUE 'PF4=LISTAR  PF12=RETORNAR'.
       *
            05  SCR-LISTA-ENCAB.
                10  LINE 06  COL 05  PIC X(06) VALUE 'CODIGO'.
                10  LINE 06  COL 15  PIC X(35) VALUE 'DESCRIPCION'.
                10  LINE 06  COL 55  PIC X(10) VALUE 'TASA ANUAL'.
                10  LINE 06  COL 70  PIC X(06) VALUE 'STATUS'.
                10  LINE 07  COL 05  PIC X(70) VALUE ALL '-'.
       *
            05  SCR-LISTA                  OCCURS 12.
                10  SCR-L-CODIGO           PIC X(06) FROM WS-VER-CODIGO
                    LINE 08 COL 05.
                10  SCR-L-DESC             PIC X(35) FROM WS-VER-DESC
                    LINE 08 COL 15.
                10  SCR-L-TASA             PIC 9(03).9(06)
                    LINE 08 COL 55 FROM WS-VER-TASA.
                10  SCR-L-STATUS           PIC X(01) FROM WS-VER-STATUS
                    LINE 08 COL 70.
       *
            05  SCR-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF1=ALT  PF2=CONS  PF3=EDIT  PF4=LIST  PF11=AYU'.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'PF12=RET  PF7=PANT  PF8=SIG'.
       *
        01  SCR-DETALLE.
            05  SCR-DET-CAB.
                10  LINE 04  COL 05  PIC X(20) VALUE 'CODIGO TASA:'.
                10  LINE 04  COL 25  PIC X(06)
                    USING RAT-CODIGO AUTO PROMPT '______'.
                10  LINE 04  COL 40  PIC X(30)
                    VALUE 'ENTER=CONSULTA'.
       *
            05  SCR-DET-DATOS.
                10  LINE 06  COL 05  PIC X(15) VALUE 'DESCRIPCION:'.
                10  LINE 06  COL 25  PIC X(35)
                    USING RAT-DESCRIPCION AUTO.
                10  LINE 07  COL 05  PIC X(15) VALUE 'TIPO:'.
                10  LINE 07  COL 25  PIC X(02)
                    USING RAT-TIPO AUTO PROMPT '__'.
                10  LINE 07  COL 35  PIC X(40)
                    VALUE 'AC=ACTIVO  PA=PASIVO  PE=PENA  MO=MORA'.
                10  LINE 08  COL 05  PIC X(15) VALUE 'PRODUCTO:'.
                10  LINE 08  COL 25  PIC X(04)
                    USING RAT-PRODUCT AUTO PROMPT '____'.
       *
                10  LINE 10  COL 05  PIC X(15) VALUE 'PLAZO MIN:'.
                10  LINE 10  COL 25  PIC 9(04)
                    USING RAT-PLAZO-MIN AUTO.
                10  LINE 10  COL 40  PIC X(15) VALUE 'PLAZO MAX:'.
                10  LINE 10  COL 60  PIC 9(04)
                    USING RAT-PLAZO-MAX AUTO.
       *
                10  LINE 11  COL 05  PIC X(15) VALUE 'MONTO MIN:'.
                10  LINE 11  COL 25  PIC -(11)9.99
                    USING RAT-MONTO-MIN AUTO.
                10  LINE 11  COL 50  PIC X(15) VALUE 'MONTO MAX:'.
                10  LINE 11  COL 70  PIC -(11)9.99
                    USING RAT-MONTO-MAX AUTO.
       *
                10  LINE 13  COL 05  PIC X(15) VALUE 'TASA ANUAL:'.
                10  LINE 13  COL 25  PIC 9(03).9(06)
                    USING RAT-TASA-ANUAL AUTO.
                10  LINE 14  COL 05  PIC X(15) VALUE 'TASA MENSUAL:'.
                10  LINE 14  COL 25  PIC 9(03).9(06)
                    USING RAT-TASA-MENSUAL AUTO.
                10  LINE 15  COL 05  PIC X(15) VALUE 'TASA DIARIA:'.
                10  LINE 15  COL 25  PIC 9(03).9(06)
                    USING RAT-TASA-DIARIA AUTO.
                10  LINE 16  COL 05  PIC X(15) VALUE 'CAT:'.
                10  LINE 16  COL 25  PIC 9(03).9(06)
                    USING RAT-TASA-CAT AUTO.
       *
                10  LINE 18  COL 05  PIC X(15) VALUE 'FECHA INICIO:'.
                10  LINE 18  COL 25  PIC 9(08)
                    USING RAT-FECHA-INICIO AUTO.
                10  LINE 18  COL 45  PIC X(15) VALUE 'FECHA FIN:'.
                10  LINE 18  COL 65  PIC 9(08)
                    USING RAT-FECHA-FIN AUTO.
       *
                10  LINE 20  COL 05  PIC X(15) VALUE 'STATUS:'.
                10  LINE 20  COL 25  PIC X(01)
                    USING RAT-STATUS AUTO PROMPT '_'.
                10  LINE 20  COL 35  PIC X(30)
                    VALUE 'V=VIGENTE  H=HISTORICO  P=PEND'.
       *
            05  SCR-DET-PIE.
                10  LINE 22  COL 01  PIC X(80) VALUE ALL '-'.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE.
                10  LINE 23  COL 05  PIC X(60) FROM WS-MENSAJE-ERROR
                    BLINK.
                10  LINE 24  COL 02  PIC X(78)
                    VALUE 'ENTER=GUARDAR  PF11=AYU  PF12=CANCEL'.
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
       *
            PERFORM 1000-INICIALIZAR.
       *
        MAIN-LOOP.
            PERFORM 2000-REFRESCAR-MENU.
            DISPLAY SCR-MENU-TASAS.
            ACCEPT SCR-MENU-TASAS.
       *
            EVALUATE TRUE
                WHEN WS-CRT-PF1
                    PERFORM 3000-ALTA-TASA
                    GO TO MAIN-LOOP
       *
                WHEN WS-CRT-PF2
                    PERFORM 4000-CONSULTAR-TASA
                    GO TO MAIN-LOOP
       *
                WHEN WS-CRT-PF3
                    PERFORM 5000-EDITAR-TASA
                    GO TO MAIN-LOOP
       *
                WHEN WS-CRT-PF4
                    PERFORM 6000-LISTAR-TASAS
                    GO TO MAIN-LOOP
       *
                WHEN WS-CRT-PF7
                    IF WS-VER-PAGE > 1
                        SUBTRACT 1 FROM WS-VER-PAGE
                    ELSE
                        MOVE 'YA ESTA EN PRIMERA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO MAIN-LOOP
       *
                WHEN WS-CRT-PF8
                    IF WS-VER-PAGE < WS-VER-PAGE-MAX
                        ADD 1 TO WS-VER-PAGE
                    ELSE
                        MOVE 'YA ESTA EN ULTIMA PAGINA'
                          TO WS-MENSAJE-ERROR
                    END-IF
                    GO TO MAIN-LOOP
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'DEPINT00'
                    GO TO MAIN-LOOP
       *
                WHEN WS-CRT-PF12
                    MOVE 00 TO LS-RETCODE
                    GO TO MAIN-EXIT
       *
                WHEN WS-CRT-CLEAR
                    MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR
                    GO TO MAIN-LOOP
       *
                WHEN OTHER
                    MOVE 'TECLA NO VALIDA' TO WS-MENSAJE-ERROR
                    GO TO MAIN-LOOP
            END-EVALUATE.
       *
        MAIN-EXIT.
            EXIT.
       *
        1000-INICIALIZAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE 'SELECCIONE OPERACION - PF4=LISTAR TASAS' TO WS-MENSAJE.
            MOVE 1 TO WS-VER-PAGE.
            PERFORM 1100-LIMPIAR.
       *
        1100-LIMPIAR.
            DISPLAY SPACES UPON CRT.
       *
        2000-REFRESCAR-MENU.
            PERFORM 1100-LIMPIAR.
            CALL 'COMDATE' USING 'NOW'
                                 WS-FECHA
                                 WS-HORA.
            MOVE WS-FECHA TO WS-BUSINESS-DATE.
            MOVE WS-HORA TO WS-CURRENT-TIME.
            MOVE WS-FECHA TO WS-FECHA-DDMM.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
        3000-ALTA-TASA.
            MOVE 'A' TO WS-FLAG-MODIFICAR.
            MOVE SPACES TO RAT-CODIGO
                           RAT-DESCRIPCION
                           RAT-TIPO
                           RAT-PRODUCT
                           RAT-STATUS.
            MOVE 0 TO RAT-PLAZO-MIN
                      RAT-PLAZO-MAX
                      RAT-MONTO-MIN
                      RAT-MONTO-MAX
                      RAT-TASA-ANUAL
                      RAT-TASA-MENSUAL
                      RAT-TASA-DIARIA
                      RAT-TASA-CAT
                      RAT-FECHA-INICIO
                      RAT-FECHA-FIN.
       *
            PERFORM 3100-EDITAR-PANTALLA THRU 3100-EXIT.
            IF WS-CONFIRMED
                PERFORM 3200-GUARDAR-TASA
            END-IF.
       *
        3100-EDITAR-PANTALLA.
            MOVE SPACES TO WS-MENSAJE-ERROR.
            PERFORM 1100-LIMPIAR.
            DISPLAY SCR-DETALLE.
            ACCEPT SCR-DETALLE.
       *
            EVALUATE TRUE
                WHEN WS-CRT-ENTER
                    PERFORM 3150-VALIDAR-TASA
                    IF WS-ERROR-NO
                        MOVE 'Y' TO WS-SWITCH-CONFIRM
                    END-IF
       *
                WHEN WS-CRT-PF11
                    CALL 'COMHELP' USING 'DEPINT00'
                    GO TO 3100-EDITAR-PANTALLA
       *
                WHEN WS-CRT-PF12
                        MOVE 'N' TO WS-SWITCH-CONFIRM
                    MOVE 'OPERACION CANCELADA' TO WS-MENSAJE
       *
                WHEN OTHER
                    MOVE 'USE ENTER=GUARDAR  PF12=CANCEL'
                      TO WS-MENSAJE-ERROR
                    GO TO 3100-EDITAR-PANTALLA
            END-EVALUATE.
        3100-EXIT.
            EXIT.
       *
        3150-VALIDAR-TASA.
            MOVE 'N' TO WS-SWITCH-ERROR.
            IF RAT-CODIGO = SPACES
                MOVE 'CODIGO TASA REQUERIDO' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 3150-EXIT
            END-IF.
            IF RAT-DESCRIPCION = SPACES
                MOVE 'DESCRIPCION REQUERIDA' TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 3150-EXIT
            END-IF.
            IF RAT-TASA-ANUAL <= 0
                MOVE 'TASA ANUAL DEBE SER MAYOR A CERO'
                  TO WS-MENSAJE-ERROR
                MOVE 'Y' TO WS-SWITCH-ERROR
                GOTO 3150-EXIT
            END-IF.
        3150-EXIT.
            EXIT.
       *
        3200-GUARDAR-TASA.
            OPEN I-O RATEFILE-FILE.
            IF FL-RATEFILE-STATUS NOT = '00'
                OPEN OUTPUT RATEFILE-FILE
                IF FL-RATEFILE-STATUS NOT = '00'
                    MOVE 'ERROR AL ABRIR RATEFILE' TO WS-MENSAJE-ERROR
                    GOTO 3200-EXIT
                END-IF
            END-IF.
       *
            MOVE WS-FECHA TO RAT-FECHA-ALTA.
            MOVE WS-USUARIO-ID TO RAT-USUARIO-ALTA.
       *
            IF WS-ES-ALTA
                WRITE RATEFILE-RECORD
                    INVALID KEY
                        MOVE 'ERROR AL CREAR TASA (DUPLICADO?)'
                          TO WS-MENSAJE-ERROR
                        CLOSE RATEFILE-FILE
                        GOTO 3200-EXIT
                END-WRITE
            ELSE
                REWRITE RATEFILE-RECORD
                    INVALID KEY
                        MOVE 'ERROR AL ACTUALIZAR TASA'
                          TO WS-MENSAJE-ERROR
                        CLOSE RATEFILE-FILE
                        GOTO 3200-EXIT
                END-REWRITE
            END-IF.
       *
            CLOSE RATEFILE-FILE.
            MOVE 'TASA GUARDADA EXITOSAMENTE' TO WS-MENSAJE.
       *
            STRING 'DEPINT00 TASA=' RAT-CODIGO
              INTO WS-AUDIT-DATA.
            CALL 'AUDTRL00' USING WS-PROGRAMA-ID
                                  WS-AUDIT-DATA.
        3200-EXIT.
            EXIT.
       *
        4000-CONSULTAR-TASA.
            MOVE SPACES TO RAT-CODIGO
                           WS-MENSAJE-ERROR.
            MOVE 'C' TO WS-FLAG-MODIFICAR.
       *
            PERFORM 1100-LIMPIAR.
            DISPLAY SCR-DETALLE.
            ACCEPT SCR-DETALLE.
       *
            IF WS-CRT-PF12
                GO TO 4000-EXIT
            END-IF.
       *
            IF RAT-CODIGO = SPACES
                MOVE 'INGRESE CODIGO DE TASA' TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            OPEN I-O RATEFILE-FILE.
            IF FL-RATEFILE-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR RATEFILE' TO WS-MENSAJE-ERROR
                GO TO 4000-EXIT
            END-IF.
       *
            READ RATEFILE-FILE KEY IS RAT-CODIGO
                INVALID KEY
                    MOVE 'TASA NO ENCONTRADA' TO WS-MENSAJE-ERROR
                    CLOSE RATEFILE-FILE
                    GO TO 4000-EXIT
            END-READ.
       *
            CLOSE RATEFILE-FILE.
            MOVE 'TASA ENCONTRADA - PRESIONE PF12=SALIR' TO WS-MENSAJE.
       *
            PERFORM 1100-LIMPIAR.
            DISPLAY SCR-DETALLE.
            ACCEPT SCR-DETALLE.
        4000-EXIT.
            EXIT.
       *
        5000-EDITAR-TASA.
            MOVE 'C' TO WS-FLAG-MODIFICAR.
            PERFORM 4000-CONSULTAR-TASA.
            IF WS-MENSAJE-ERROR NOT = SPACES
                GOTO 5000-EXIT
            END-IF.
       *
            MOVE SPACES TO WS-MENSAJE-ERROR.
            PERFORM 3100-EDITAR-PANTALLA THRU 3100-EXIT.
            IF WS-CONFIRMED
                PERFORM 3200-GUARDAR-TASA
            END-IF.
        5000-EXIT.
            EXIT.
       *
        6000-LISTAR-TASAS.
            MOVE 0 TO WS-VER-COUNT.
            MOVE 1 TO WS-VER-PAGE.
            MOVE SPACES TO WS-MENSAJE-ERROR.
       *
            OPEN I-O RATEFILE-FILE.
            IF FL-RATEFILE-STATUS NOT = '00'
                MOVE 'ERROR AL ABRIR RATEFILE' TO WS-MENSAJE-ERROR
                GOTO 6000-EXIT
            END-IF.
       *
            MOVE SPACES TO RAT-CODIGO.
            START RATEFILE-FILE KEY IS NOT < RAT-CODIGO
                INVALID KEY
                    MOVE 'NO HAY TASAS REGISTRADAS' TO WS-MENSAJE-ERROR
                    CLOSE RATEFILE-FILE
                    GOTO 6000-EXIT
            END-START.
       *
            MOVE 'N' TO WS-SWITCH-EOF.
            PERFORM UNTIL WS-EOF-YES
                READ RATEFILE-FILE NEXT RECORD
                    AT END
                        MOVE 'Y' TO WS-SWITCH-EOF
                        GOTO 6000-CONTINUE
                END-READ
       *
                IF FL-RATEFILE-STATUS = '00'
                    ADD 1 TO WS-VER-COUNT
                    MOVE RAT-CODIGO TO WS-VER-CODIGO(WS-VER-COUNT)
                    MOVE RAT-DESCRIPCION TO WS-VER-DESC(WS-VER-COUNT)
                    MOVE RAT-TASA-ANUAL TO WS-VER-TASA(WS-VER-COUNT)
                    MOVE RAT-STATUS TO WS-VER-STATUS(WS-VER-COUNT)
                END-IF
       *
                IF WS-VER-COUNT >= 30
                    MOVE 'Y' TO WS-SWITCH-EOF
                END-IF
            END-PERFORM.
       *
        6000-CONTINUE.
            CLOSE RATEFILE-FILE.
       *
            IF WS-VER-COUNT = 0
                MOVE 'NO HAY TASAS REGISTRADAS' TO WS-MENSAJE-ERROR
                GOTO 6000-EXIT
            END-IF.
       *
            COMPUTE WS-VER-PAGE-MAX =
                (WS-VER-COUNT - 1) / 12 + 1.
            IF WS-VER-PAGE-MAX < 1
                MOVE 1 TO WS-VER-PAGE-MAX
            END-IF.
       *
            STRING WS-VER-COUNT ' TASA(S) ENCONTRADAS'
              INTO WS-MENSAJE.
        6000-EXIT.
            EXIT.
       *
        END PROGRAM DEPINT00.
