      *================================================================*
      * FD-PARAMSTR - PARAMETROS GENERALES DEL SISTEMA                *
      * EQUIPO: ADMINISTRACION DE SISTEMAS - 2000                     *
      * ARCHIVO: PARAMSTR.DAT (INDEXADO)                               *
      * CLAVE:   PAR-CODIGO (X(08))                                    *
      *================================================================*
      *
     FD  PARAMSTR-FILE
         RECORD 150 CHARACTERS.
      *
       01  PARAMSTR-RECORD.
           05  PAR-CODIGO                  PIC X(08).
           05  PAR-GRUPO                   PIC X(10).
               88  PAR-GRUPO-GENERAL       VALUE 'GENERAL'.
               88  PAR-GRUPO-TASAS         VALUE 'TASAS'.
               88  PAR-GRUPO-LIMITES       VALUE 'LIMITES'.
               88  PAR-GRUPO-HORARIOS      VALUE 'HORARIO'.
               88  PAR-GRUPO-COMISIONES    VALUE 'COMISION'.
               88  PAR-GRUPO-SEGURIDAD     VALUE 'SEGURIDAD'.
               88  PAR-GRUPO-CONTABILIDAD  VALUE 'CONTABLE'.
           05  PAR-DESCRIPCION             PIC X(40).
           05  PAR-VALOR-TEXTO             PIC X(40).
           05  PAR-VALOR-NUMERICO          PIC S9(13)V99 COMP-3.
           05  PAR-VALOR-FECHA             PIC 9(08).
           05  PAR-TIPO-DATO               PIC X(01).
               88  PAR-TIPO-TEXTO          VALUE 'T'.
               88  PAR-TIPO-NUMERO         VALUE 'N'.
               88  PAR-TIPO-FECHA          VALUE 'F'.
               88  PAR-TIPO-BOOLEANO       VALUE 'B'.
           05  PAR-MODIFICABLE             PIC X(01).
               88  PAR-MOD-SI              VALUE 'S'.
               88  PAR-MOD-NO              VALUE 'N'.
           05  PAR-FECHA-MOD               PIC 9(08).
           05  PAR-USUARIO-MOD             PIC X(08).
      *
           05  PAR-FILLER                  PIC X(05).
