      *================================================================*
      * COMUTIL - UTILERIAS GENERALES DEL SISTEMA                     *
      * PROPOSITO: FUNCIONES COMUNES DE STRING, NUMERO, FORMATO       *
      * EQUIPO: HERRAMIENTAS - 2001                                   *
      * USO:   CALL 'COMUTIL' USING OPERACION  PARAM1  PARAM2  RET   *
      * OPERACIONES:                                                   *
      *   'PAD'   - RELLENAR CON CARACTER A LONGITUD                 *
      *   'TRIM'  - ELIMINAR ESPACIOS SOBRANTES                      *
      *   'FMT'   - FORMATEAR MONTO CON COMAS Y DECIMALES            *
      *   'MONEDA'- AGREGAR SIMBOLO MONEDA                           *
      *   'UPPER' - CONVERTIR A MAYUSCULAS                           *
      *   'LOWER' - CONVERTIR A MINUSCULAS                           *
      *   'ZERO'  - REEMPLAZAR CEROS POR ESPACIOS                    *
      *   'MASK'  - APLICAR MASCARA DE FORMATO                       *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMUTIL.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-OPERACION                  PIC X(06).
       01  WS-ORIGEN                     PIC X(30).
       01  WS-DESTINO                    PIC X(30).
       01  WS-LONGITUD                   PIC 9(02).
       01  WS-RELLENO                    PIC X(01).
       01  WS-CONTADOR                   PIC 9(03).
       01  WS-CARACTER                    PIC X(01).
       01  WS-MONTO-ENTRADA              PIC S9(13)V99 COMP-3.
       01  WS-MONTO-SALIDA               PIC -(10)9.99.
       01  WS-MONTO-EDITADO              PIC X(15).
       01  WS-MASCARA                    PIC X(20).
       01  WS-POS                        PIC 9(02).
       01  WS-CHAR                       PIC X(01).
       01  WS-I                          PIC 9(03).
       01  WS-J                          PIC 9(03).
       01  WS-DIGITO                     PIC 9(01).
       01  WS-TOTAL                      PIC 9(10).
       01  WS-COMP-9                     PIC 9(10)V99 COMP-3.
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-OPERACION                   PIC X(06).
       01  LS-PARAM1                      PIC X(30).
       01  LS-PARAM2                      PIC X(30).
       01  LS-RETORNO                     PIC X(30).
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-OPERACION
                                 LS-PARAM1
                                 LS-PARAM2
                                 LS-RETORNO.
      *
       MAIN.
           MOVE LS-OPERACION TO WS-OPERACION.
           MOVE LS-PARAM1 TO WS-ORIGEN.
           MOVE LS-PARAM2 TO WS-DESTINO.
      *
           EVALUATE WS-OPERACION
               WHEN 'PAD'
                   PERFORM 1000-PADDING
               WHEN 'TRIM'
                   PERFORM 2000-TRIM
               WHEN 'FMT'
                   PERFORM 3000-FORMATEAR-MONTO
               WHEN 'MONEDA'
                   PERFORM 4000-AGREGAR-MONEDA
               WHEN 'UPPER'
                   PERFORM 5000-A-MAYUSCULAS
               WHEN 'LOWER'
                   PERFORM 6000-A-MINUSCULAS
               WHEN 'ZERO'
                   PERFORM 7000-ZERO-SUPRESS
               WHEN 'MASK'
                   PERFORM 8000-APLICAR-MASCARA
               WHEN OTHER
                   MOVE WS-ORIGEN TO LS-RETORNO
           END-EVALUATE.
      *
           GOBACK.
      *
      *--- PADDING ---*
       1000-PADDING.
           MOVE LS-PARAM2(1:1) TO WS-RELLENO.
           MOVE LS-PARAM2(2:2) TO WS-LONGITUD.
           MOVE WS-ORIGEN TO WS-DESTINO.
      *
           PERFORM VARYING WS-CONTADOR FROM 1 BY 1
               UNTIL WS-CONTADOR > WS-LONGITUD
               OR WS-DESTINO(WS-CONTADOR:1) = SPACE
               CONTINUE
           END-PERFORM.
      *
           PERFORM UNTIL WS-CONTADOR > WS-LONGITUD
               MOVE WS-RELLENO TO WS-DESTINO(WS-CONTADOR:1)
               ADD 1 TO WS-CONTADOR
           END-PERFORM.
      *
           MOVE WS-DESTINO TO LS-RETORNO.
      *
      *--- TRIM ---*
       2000-TRIM.
           MOVE SPACES TO WS-DESTINO.
           MOVE 1 TO WS-CONTADOR.
           MOVE 1 TO WS-POS.
      *
           PERFORM UNTIL WS-CONTADOR > 30
               IF WS-ORIGEN(WS-CONTADOR:1) NOT = SPACE
                   MOVE WS-ORIGEN(WS-CONTADOR:1)
                     TO WS-DESTINO(WS-POS:1)
                   ADD 1 TO WS-POS
               END-IF
               ADD 1 TO WS-CONTADOR
           END-PERFORM.
      *
           MOVE WS-DESTINO TO LS-RETORNO.
      *
      *--- FORMATEAR MONTO ---*
       3000-FORMATEAR-MONTO.
           MOVE WS-ORIGEN TO WS-MONTO-ENTRADA.
           MOVE WS-MONTO-ENTRADA TO WS-MONTO-EDITADO.
           MOVE WS-MONTO-EDITADO TO LS-RETORNO.
      *
      *--- AGREGAR MONEDA ---*
       4000-AGREGAR-MONEDA.
           MOVE WS-ORIGEN TO WS-MONTO-ENTRADA.
           MOVE WS-MONTO-ENTRADA TO WS-MONTO-EDITADO.
           STRING '$ ' WS-MONTO-EDITADO INTO WS-DESTINO.
           MOVE WS-DESTINO TO LS-RETORNO.
      *
      *--- A MAYUSCULAS ---*
       5000-A-MAYUSCULAS.
           MOVE WS-ORIGEN TO WS-DESTINO.
           PERFORM VARYING WS-CONTADOR FROM 1 BY 1
               UNTIL WS-CONTADOR > 30
               MOVE WS-DESTINO(WS-CONTADOR:1) TO WS-CARACTER
               IF WS-CARACTER >= 'a' AND WS-CARACTER <= 'z'
                   COMPUTE WS-CHAR =
                       FUNCTION ORD(WS-CARACTER) - 32
                   MOVE FUNCTION CHAR(WS-CHAR)
                     TO WS-DESTINO(WS-CONTADOR:1)
               END-IF
           END-PERFORM.
           MOVE WS-DESTINO TO LS-RETORNO.
      *
      *--- A MINUSCULAS ---*
       6000-A-MINUSCULAS.
           MOVE WS-ORIGEN TO WS-DESTINO.
           PERFORM VARYING WS-CONTADOR FROM 1 BY 1
               UNTIL WS-CONTADOR > 30
               MOVE WS-DESTINO(WS-CONTADOR:1) TO WS-CARACTER
               IF WS-CARACTER >= 'A' AND WS-CARACTER <= 'Z'
                   COMPUTE WS-CHAR =
                       FUNCTION ORD(WS-CARACTER) + 32
                   MOVE FUNCTION CHAR(WS-CHAR)
                     TO WS-DESTINO(WS-CONTADOR:1)
               END-IF
           END-PERFORM.
           MOVE WS-DESTINO TO LS-RETORNO.
      *
      *--- SUPRESION DE CEROS ---*
       7000-ZERO-SUPRESS.
           MOVE WS-ORIGEN TO WS-DESTINO.
           PERFORM VARYING WS-CONTADOR FROM 1 BY 1
               UNTIL WS-CONTADOR > 30
               IF WS-DESTINO(WS-CONTADOR:1) = '0'
                   MOVE SPACE TO WS-DESTINO(WS-CONTADOR:1)
               ELSE
                   EXIT PERFORM
               END-IF
           END-PERFORM.
           MOVE WS-DESTINO TO LS-RETORNO.
      *
      *--- APLICAR MASCARA ---*
       8000-APLICAR-MASCARA.
           MOVE LS-PARAM2 TO WS-MASCARA.
           MOVE SPACES TO WS-DESTINO.
           MOVE 1 TO WS-I.
           MOVE 1 TO WS-J.
      *
           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > 20 OR WS-MASCARA(WS-I:1) = SPACE
               IF WS-MASCARA(WS-I:1) = 'X'
                   MOVE WS-ORIGEN(WS-J:1) TO WS-DESTINO(WS-I:1)
                   ADD 1 TO WS-J
               ELSE
                   IF WS-MASCARA(WS-I:1) = '9'
                       MOVE WS-ORIGEN(WS-J:1) TO WS-DESTINO(WS-I:1)
                       ADD 1 TO WS-J
                   ELSE
                       MOVE WS-MASCARA(WS-I:1)
                         TO WS-DESTINO(WS-I:1)
                   END-IF
               END-IF
           END-PERFORM.
      *
           MOVE WS-DESTINO TO LS-RETORNO.
      *
       END PROGRAM COMUTIL.
