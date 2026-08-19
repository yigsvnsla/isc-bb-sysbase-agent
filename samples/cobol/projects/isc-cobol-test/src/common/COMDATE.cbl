      *================================================================*
      * COMDATE - RUTINAS DE FECHA Y HORA                             *
      * PROPOSITO: PROVEER FECHAS/HORAS A TODOS LOS MODULOS           *
      * EQUIPO: BASE - 1996 (MODIFICADO 2002, 2007)                   *
      * USO:   CALL 'COMDATE' USING FUNCION  PARAM1 PARAM2           *
      * FUNCIONES:                                                     *
      *   'NOW'   - FECHA Y HORA ACTUAL                              *
      *   'VAL'   - VALIDAR FECHA (YYYYMMDD)                          *
      *   'JUL'   - CONVERTIR A JULIANO                              *
      *   'GRG'   - CONVERTIR DE JULIANO A GREGORIANO                *
      *   'ADD'   - SUMAR DIAS A UNA FECHA                           *
      *   'DIFF'  - DIFERENCIA EN DIAS ENTRE DOS FECHAS              *
      *   'BUS'   - VALIDAR SI ES DIA HABIL                          *
      *   'FMT'   - FORMATO DD/MM/YYYY                               *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMDATE.
      *================================================================*
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      *
       01  WS-FECHA-ACTUAL.
           05  WS-FEC-ANO                  PIC 9(04).
           05  WS-FEC-MES                  PIC 9(02).
           05  WS-FEC-DIA                  PIC 9(02).
       01  WS-TIEMPO-ACTUAL.
           05  WS-TIE-HORA                 PIC 9(02).
           05  WS-TIE-MIN                  PIC 9(02).
           05  WS-TIE-SEG                  PIC 9(02).
      *
       01  WS-FECHA-JULIANA               PIC 9(07).
       01  WS-DIAS-MES                    PIC 9(02).
       01  WS-BISIESTO                    PIC X(01).
           88  WS-ES-BISIESTO             VALUE 'S'.
           88  WS-NO-ES-BISIESTO          VALUE 'N'.
       01  WS-INDICE                      PIC 9(04).
       01  WS-TABLE-DIAS-MES.
           05  WS-DIAS-ENTRY              PIC 9(02)
               OCCURS 12.
               88  WS-DIAS-ENE            VALUE 31.
               88  WS-DIAS-FEB            VALUE 28.
               88  WS-DIAS-MAR            VALUE 31.
               88  WS-DIAS-ABR            VALUE 30.
               88  WS-DIAS-MAY            VALUE 31.
               88  WS-DIAS-JUN            VALUE 30.
               88  WS-DIAS-JUL            VALUE 31.
               88  WS-DIAS-AGO            VALUE 31.
               88  WS-DIAS-SEP            VALUE 30.
               88  WS-DIAS-OCT            VALUE 31.
               88  WS-DIAS-NOV            VALUE 30.
               88  WS-DIAS-DIC            VALUE 31.
      *
       01  WS-PARAM-FECHA                 PIC 9(08).
       01  WS-PARAM-FECHA2                PIC 9(08).
       01  WS-PARAM-DIAS                  PIC 9(04).
       01  WS-PARAM-RESULT                PIC 9(08).
       01  WS-PARAM-RESULT-DIAS           PIC 9(04).
       01  WS-PARAM-FORMATO               PIC X(10).
       01  WS-PARAM-VALIDO                PIC X(01).
      *
       01  WS-DIAS-ACUM                   PIC 9(04).
       01  WS-DIAS-FEC1                   PIC 9(04).
       01  WS-DIAS-FEC2                   PIC 9(04).
      *
      *================================================================*
       LINKAGE SECTION.
      *
       01  LS-FUNCION                     PIC X(03).
       01  LS-PARAM1.
           05  LS-PARAM1-VAL              PIC X(10).
       01  LS-PARAM2.
           05  LS-PARAM2-VAL              PIC X(10).
      *
      *================================================================*
       PROCEDURE DIVISION USING LS-FUNCION
                                 LS-PARAM1
                                 LS-PARAM2.
      *
       MAIN-RTN.
           MOVE FUNCTION CURRENT-DATE TO WS-FECHA-ACTUAL.
      *
           EVALUATE LS-FUNCION
               WHEN 'NOW'
                   PERFORM 1000-GET-NOW
      *
               WHEN 'VAL'
                   PERFORM 2000-VALIDAR-FECHA
      *
               WHEN 'JUL'
                   PERFORM 3000-FECHA-A-JULIANO
      *
               WHEN 'GRG'
                   PERFORM 4000-JULIANO-A-FECHA
      *
               WHEN 'ADD'
                   PERFORM 5000-SUMAR-DIAS
      *
               WHEN 'DIFF'
                   PERFORM 6000-DIFERENCIA-DIAS
      *
               WHEN 'BUS'
                   PERFORM 7000-DIA-HABIL
      *
               WHEN 'FMT'
                   PERFORM 8000-FORMATEAR
      *
               WHEN OTHER
                   MOVE 'N' TO WS-PARAM-VALIDO
           END-EVALUATE.
      *
           GOBACK.
      *
      *--- OBTENER FECHA Y HORA ACTUAL ---*
       1000-GET-NOW.
           MOVE WS-FEC-ANO                TO WS-PARAM-RESULT(1:4)
           MOVE WS-FEC-MES                TO WS-PARAM-RESULT(5:2)
           MOVE WS-FEC-DIA                TO WS-PARAM-RESULT(7:2)
           MOVE WS-PARAM-RESULT           TO LS-PARAM1(1:8)
           MOVE WS-TIE-HORA               TO LS-PARAM2(1:2)
           MOVE WS-TIE-MIN                TO LS-PARAM2(3:2)
           MOVE WS-TIE-SEG                TO LS-PARAM2(5:2).
      *
      *--- VALIDAR FECHA ---*
       2000-VALIDAR-FECHA.
           MOVE LS-PARAM1(1:8) TO WS-PARAM-FECHA.
           MOVE WS-PARAM-FECHA(1:4) TO WS-FEC-ANO.
           MOVE WS-PARAM-FECHA(5:2) TO WS-FEC-MES.
           MOVE WS-PARAM-FECHA(7:2) TO WS-FEC-DIA.
      *
           IF WS-FEC-ANO < 1900 OR WS-FEC-ANO > 2100
               MOVE 'N' TO WS-PARAM-VALIDO
               GOTO 2000-EXIT
           END-IF.
      *
           IF WS-FEC-MES < 1 OR WS-FEC-MES > 12
               MOVE 'N' TO WS-PARAM-VALIDO
               GOTO 2000-EXIT
           END-IF.
      *
           PERFORM 2100-CALCULAR-DIAS-MES.
           IF WS-FEC-DIA < 1
               OR WS-FEC-DIA > WS-DIAS-MES
               MOVE 'N' TO WS-PARAM-VALIDO
           ELSE
               MOVE 'S' TO WS-PARAM-VALIDO
           END-IF.
      *
       2000-EXIT.
           MOVE WS-PARAM-VALIDO TO LS-PARAM2(1:1).
      *
       2100-CALCULAR-DIAS-MES.
           MOVE WS-DIAS-ENTRY(WS-FEC-MES) TO WS-DIAS-MES.
           IF WS-FEC-MES = 02
               PERFORM 2200-CALCULAR-BISIESTO
               IF WS-ES-BISIESTO
                   MOVE 29 TO WS-DIAS-MES
               END-IF
           END-IF.
      *
       2200-CALCULAR-BISIESTO.
           IF WS-FEC-ANO / 400 * 400 = WS-FEC-ANO
               MOVE 'S' TO WS-BISIESTO
           ELSE
               IF WS-FEC-ANO / 100 * 100 = WS-FEC-ANO
                   MOVE 'N' TO WS-BISIESTO
               ELSE
                   IF WS-FEC-ANO / 4 * 4 = WS-FEC-ANO
                       MOVE 'S' TO WS-BISIESTO
                   ELSE
                       MOVE 'N' TO WS-BISIESTO
                   END-IF
               END-IF
           END-IF.
      *
      *--- CONVERTIR FECHA A JULIANO ---*
       3000-FECHA-A-JULIANO.
           MOVE LS-PARAM1(1:8) TO WS-PARAM-FECHA.
           MOVE WS-PARAM-FECHA(1:4) TO WS-FEC-ANO.
           MOVE WS-PARAM-FECHA(5:2) TO WS-FEC-MES.
           MOVE WS-PARAM-FECHA(7:2) TO WS-FEC-DIA.
      *
           MOVE 0 TO WS-DIAS-ACUM.
           PERFORM VARYING WS-INDICE FROM 1 BY 1
               UNTIL WS-INDICE > WS-FEC-MES - 1
               PERFORM 2100-CALCULAR-DIAS-MES
               ADD WS-DIAS-MES TO WS-DIAS-ACUM
           END-PERFORM.
           ADD WS-FEC-DIA TO WS-DIAS-ACUM.
      *
           MOVE WS-FEC-ANO TO WS-FECHA-JULIANA(1:4).
           MOVE WS-DIAS-ACUM TO WS-FECHA-JULIANA(5:3).
           MOVE WS-FECHA-JULIANA TO LS-PARAM2(1:7).
      *
      *--- CONVERTIR JULIANO A FECHA ---*
       4000-JULIANO-A-FECHA.
           MOVE LS-PARAM1(1:7) TO WS-FECHA-JULIANA.
           MOVE WS-FECHA-JULIANA(1:4) TO WS-FEC-ANO.
           MOVE WS-FECHA-JULIANA(5:3) TO WS-DIAS-ACUM.
      *
           MOVE 1 TO WS-FEC-MES.
           PERFORM UNTIL WS-DIAS-ACUM <= 0
               PERFORM 2100-CALCULAR-DIAS-MES
               SUBTRACT WS-DIAS-MES FROM WS-DIAS-ACUM
               IF WS-DIAS-ACUM > 0
                   ADD 1 TO WS-FEC-MES
               ELSE
                   ADD WS-DIAS-MES TO WS-DIAS-ACUM
                   MOVE WS-DIAS-ACUM TO WS-FEC-DIA
               END-IF
           END-PERFORM.
      *
           MOVE WS-FEC-ANO TO WS-PARAM-RESULT(1:4).
           MOVE WS-FEC-MES TO WS-PARAM-RESULT(5:2).
           MOVE WS-FEC-DIA TO WS-PARAM-RESULT(7:2).
           MOVE WS-PARAM-RESULT TO LS-PARAM2(1:8).
      *
      *--- SUMAR DIAS A UNA FECHA ---*
       5000-SUMAR-DIAS.
           MOVE LS-PARAM1(1:8) TO WS-PARAM-FECHA.
           MOVE LS-PARAM2(1:04) TO WS-PARAM-DIAS.
           PERFORM 3000-FECHA-A-JULIANO.
           ADD WS-PARAM-DIAS TO WS-DIAS-ACUM.
           MOVE WS-FECHA-JULIANA TO LS-PARAM1(1:7).
           PERFORM 4000-JULIANO-A-FECHA.
      *
      *--- DIFERENCIA EN DIAS ---*
       6000-DIFERENCIA-DIAS.
           MOVE LS-PARAM1(1:8) TO WS-PARAM-FECHA.
           PERFORM 3000-FECHA-A-JULIANO.
           MOVE WS-DIAS-ACUM TO WS-DIAS-FEC1.
           MOVE WS-FEC-ANO TO WS-DIAS-FEC1(5:4).
      *
           MOVE LS-PARAM2(1:8) TO WS-PARAM-FECHA2.
           MOVE WS-PARAM-FECHA2 TO LS-PARAM1.
           PERFORM 3000-FECHA-A-JULIANO.
           MOVE WS-DIAS-ACUM TO WS-DIAS-FEC2.
           MOVE WS-FEC-ANO TO WS-DIAS-FEC2(5:4).
      *
           COMPUTE WS-PARAM-RESULT-DIAS =
               FUNCTION ABS(WS-DIAS-FEC2 - WS-DIAS-FEC1).
           MOVE WS-PARAM-RESULT-DIAS TO LS-PARAM2(1:4).
      *
      *--- VERIFICAR DIA HABIL ---*
       7000-DIA-HABIL.
           MOVE LS-PARAM1(1:8) TO WS-PARAM-FECHA.
           MOVE WS-PARAM-FECHA(1:4) TO WS-FEC-ANO.
           MOVE WS-PARAM-FECHA(5:2) TO WS-FEC-MES.
           MOVE WS-PARAM-FECHA(7:2) TO WS-FEC-DIA.
      *
           CALL 'COMDATE' USING 'JUL'
                                LS-PARAM1
                                LS-PARAM2.
      *--- CALCULO DIA SEMANA (ALGORITMO ZELLER) ---*
           COMPUTE WS-INDICE = (WS-FEC-DIA
               + (13 * (WS-FEC-MES + 1) / 5)
               + WS-FEC-ANO
               + (WS-FEC-ANO / 4)
               - (WS-FEC-ANO / 100)
               + (WS-FEC-ANO / 400))
               FUNCTION MOD 7.
      *
           IF WS-INDICE = 0 OR WS-INDICE = 6
               MOVE 'N' TO WS-PARAM-VALIDO
           ELSE
               MOVE 'S' TO WS-PARAM-VALIDO
           END-IF.
           MOVE WS-PARAM-VALIDO TO LS-PARAM2(1:1).
      *
      *--- FORMATEAR FECHA ---*
       8000-FORMATEAR.
           MOVE LS-PARAM1(1:8) TO WS-PARAM-FECHA.
           MOVE WS-PARAM-FECHA(7:2) TO LS-PARAM2(1:2).
           MOVE '/' TO LS-PARAM2(3:1).
           MOVE WS-PARAM-FECHA(5:2) TO LS-PARAM2(4:2).
           MOVE '/' TO LS-PARAM2(6:1).
           MOVE WS-PARAM-FECHA(1:4) TO LS-PARAM2(7:4).
      *
       END PROGRAM COMDATE.
