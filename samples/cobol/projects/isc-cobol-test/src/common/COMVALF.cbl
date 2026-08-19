      *================================================================*
      * COMVALF - VALIDACION DE CAMPOS                                *
      * PROPOSITO: VALIDACION CENTRALIZADA DE DATOS DE ENTRADA        *
      * CREADO: 1999 - DEPARTAMENTO DE DESARROLLO                     *
      * USO:   CALL 'COMVALF' USING TIPO  VALOR  PARAM  RETORNO      *
      * TIPOS DE VALIDACION:                                           *
      *   'NUM'   - VALIDAR NUMERICO                                  *
      *   'ALF'   - VALIDAR ALFANUMERICO                              *
      *   'REQ'   - VALIDAR REQUERIDO (NO VACIO)                      *
      *   'RAN'   - VALIDAR RANGO (MIN/MAX)                           *
      *   'LEN'   - VALIDAR LONGITUD                                  *
      *   'EMAIL' - VALIDAR FORMATO EMAIL                             *
      *   'RFC'   - VALIDAR FORMATO RFC                               *
      *   'CURP'  - VALIDAR FORMATO CURP                              *
      *   'FEC'   - VALIDAR FECHA                                     *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMVALF.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-TIPO                       PIC X(05).
       01  WS-VALOR                      PIC X(60).
       01  WS-PARAM                      PIC X(20).
       01  WS-RETORNO                    PIC 99.
       01  WS-IND                        PIC 9(03).
       01  WS-LONGITUD                   PIC 9(02).
       01  WS-MIN                        PIC 9(10).
       01  WS-MAX                        PIC 9(10).
       01  WS-VALOR-NUM                  PIC 9(10).
       01  WS-VALOR-COMP                PIC 9(10)V99 COMP-3.
       01  WS-ESPACIO-ENCONTRADO        PIC X(01).
       01  WS-VALIDO                     PIC X(01).
       01  WS-CONTADOR                   PIC 9(03).
       01  WS-RFC-DIGITO                 PIC X(01).
       01  WS-SUMA                       PIC 9(04).
       01  WS-RESTO                      PIC 9(02).
       01  WS-FECHA-AUX                  PIC 9(08).
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-TIPO                        PIC X(05).
       01  LS-VALOR                       PIC X(60).
       01  LS-PARAM                       PIC X(20).
       01  LS-RETORNO                     PIC 99.
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-TIPO
                                 LS-VALOR
                                 LS-PARAM
                                 LS-RETORNO.
      *
       MAIN.
           MOVE LS-TIPO   TO WS-TIPO.
           MOVE LS-VALOR  TO WS-VALOR.
           MOVE LS-PARAM  TO WS-PARAM.
           MOVE 0 TO WS-RETORNO.
      *
           EVALUATE WS-TIPO
               WHEN 'NUM'
                   PERFORM 1000-VALIDAR-NUMERICO
               WHEN 'ALF'
                   PERFORM 2000-VALIDAR-ALFANUMERICO
               WHEN 'REQ'
                   PERFORM 3000-VALIDAR-REQUERIDO
               WHEN 'RAN'
                   PERFORM 4000-VALIDAR-RANGO
               WHEN 'LEN'
                   PERFORM 5000-VALIDAR-LONGITUD
               WHEN 'EMAIL'
                   PERFORM 6000-VALIDAR-EMAIL
               WHEN 'RFC'
                   PERFORM 7000-VALIDAR-RFC
               WHEN 'CURP'
                   PERFORM 8000-VALIDAR-CURP
               WHEN 'FEC'
                   PERFORM 9000-VALIDAR-FECHA
               WHEN OTHER
                   MOVE 99 TO WS-RETORNO
           END-EVALUATE.
      *
           MOVE WS-RETORNO TO LS-RETORNO.
           GOBACK.
      *
      *--- VALIDAR NUMERICO ---*
       1000-VALIDAR-NUMERICO.
           MOVE WS-VALOR TO WS-VALOR-NUM.
           IF WS-VALOR-NUM IS NUMERIC
               MOVE 0 TO WS-RETORNO
           ELSE
               MOVE 1 TO WS-RETORNO
           END-IF.
      *
      *--- VALIDAR ALFANUMERICO ---*
       2000-VALIDAR-ALFANUMERICO.
           MOVE 'N' TO WS-ESPACIO-ENCONTRADO.
           INSPECT WS-VALOR TALLYING WS-IND
               FOR CHARACTERS BEFORE INITIAL ' '.
           IF WS-IND = 0
               MOVE 1 TO WS-RETORNO
           ELSE
               MOVE 0 TO WS-RETORNO
           END-IF.
      *
      *--- VALIDAR REQUERIDO ---*
       3000-VALIDAR-REQUERIDO.
           IF WS-VALOR = SPACES
               MOVE 1 TO WS-RETORNO
           ELSE
               IF WS-VALOR = LOW-VALUES
                   MOVE 2 TO WS-RETORNO
               ELSE
                   MOVE 0 TO WS-RETORNO
               END-IF
           END-IF.
      *
      *--- VALIDAR RANGO ---*
       4000-VALIDAR-RANGO.
           MOVE WS-PARAM(1:10) TO WS-MIN.
           MOVE WS-PARAM(11:10) TO WS-MAX.
           MOVE WS-VALOR TO WS-VALOR-NUM.
      *
           IF WS-VALOR-NUM IS NUMERIC
               IF WS-VALOR-NUM >= WS-MIN
                   AND WS-VALOR-NUM <= WS-MAX
                   MOVE 0 TO WS-RETORNO
               ELSE
                   MOVE 2 TO WS-RETORNO
               END-IF
           ELSE
               MOVE 1 TO WS-RETORNO
           END-IF.
      *
      *--- VALIDAR LONGITUD ---*
       5000-VALIDAR-LONGITUD.
           MOVE WS-PARAM TO WS-LONGITUD.
           MOVE 0 TO WS-CONTADOR.
      *
           INSPECT WS-VALOR TALLYING WS-CONTADOR
               FOR CHARACTERS BEFORE INITIAL SPACE.
           IF WS-CONTADOR = WS-LONGITUD
               MOVE 0 TO WS-RETORNO
           ELSE
               MOVE 1 TO WS-RETORNO
           END-IF.
      *
      *--- VALIDAR EMAIL ---*
       6000-VALIDAR-EMAIL.
           MOVE 0 TO WS-RETORNO.
           MOVE 0 TO WS-CONTADOR.
           INSPECT WS-VALOR TALLYING WS-CONTADOR
               FOR CHARACTERS BEFORE '@'.
      *
           IF WS-CONTADOR = 0 OR WS-CONTADOR > 40
               MOVE 1 TO WS-RETORNO
               GOTO 6000-EXIT
           END-IF.
      *
           MOVE 0 TO WS-CONTADOR.
           INSPECT WS-VALOR TALLYING WS-CONTADOR
               FOR CHARACTERS BEFORE '.'.
           IF WS-CONTADOR = 0
               MOVE 2 TO WS-RETORNO
               GOTO 6000-EXIT
           END-IF.
      *
           MOVE 0 TO WS-CONTADOR.
           INSPECT WS-VALOR TALLYING WS-CONTADOR
               FOR CHARACTERS BEFORE ' '.
           IF WS-CONTADOR NOT = 0
               MOVE 3 TO WS-RETORNO
           END-IF.
       6000-EXIT.
           EXIT.
      *
      *--- VALIDAR RFC (BASICO) ---*
       7000-VALIDAR-RFC.
           MOVE WS-VALOR TO WS-RFC-DIGITO.
           MOVE 0 TO WS-RETORNO.
      *
           INSPECT WS-VALOR TALLYING WS-IND
               FOR CHARACTERS BEFORE SPACE.
           IF WS-IND NOT = 13 AND WS-IND NOT = 12
               MOVE 1 TO WS-RETORNO
               GOTO 7000-EXIT
           END-IF.
      *
           IF WS-IND = 13
               IF NOT (WS-VALOR(11:1) IS NUMERIC
                   AND WS-VALOR(12:1) IS NUMERIC
                   AND WS-VALOR(13:1) IS NUMERIC)
                   MOVE 2 TO WS-RETORNO
                   GOTO 7000-EXIT
               END-IF
           END-IF.
      *
       7000-EXIT.
           EXIT.
      *
      *--- VALIDAR CURP ---*
       8000-VALIDAR-CURP.
           MOVE WS-VALOR TO WS-RFC-DIGITO.
           INSPECT WS-VALOR TALLYING WS-IND
               FOR CHARACTERS BEFORE SPACE.
           IF WS-IND NOT = 18
               MOVE 1 TO WS-RETORNO
           ELSE
               MOVE 0 TO WS-RETORNO
           END-IF.
      *
      *--- VALIDAR FECHA ---*
       9000-VALIDAR-FECHA.
           MOVE WS-VALOR(1:8) TO WS-FECHA-AUX.
           CALL 'COMDATE' USING 'VAL'
                                WS-FECHA-AUX
                                WS-VALIDO.
           IF WS-VALIDO = 'S'
               MOVE 0 TO WS-RETORNO
           ELSE
               MOVE 1 TO WS-RETORNO
           END-IF.
      *
       END PROGRAM COMVALF.
