      *================================================================*
      * CPY-CODTAB - TABLAS DE CODIFICACION COMPARTIDA                *
      * PROPOSITO: VALORES ESTANDAR PARA CAMPOS CODIFICADOS           *
      * EQUIPO: ARQUITECTURA - 2002                                    *
      *================================================================*
      *
      *----------------------------------------------------------------*
      * TIPO DE IDENTIFICACION                                        *
      *----------------------------------------------------------------*
       01  WS-TIPO-IDENTIFICACION.
           05  WS-TIPID-CREDENCIAL         PIC 9(13).
           05  WS-TIPID-PASAPORTE          PIC X(09).
           05  WS-TIPID-RFC                PIC X(13).
           05  WS-TIPID-CURP               PIC X(18).
      *
      *----------------------------------------------------------------*
      * TABLA DE PRODUCTOS                                            *
      *----------------------------------------------------------------*
       01  WS-PRODUCT-TABLE.
           05  WS-PRODUCT-ENTRY            OCCURS 50.
               10  WS-PROD-CODE            PIC X(04).
               10  WS-PROD-DESC            PIC X(30).
               10  WS-PROD-TYPE            PIC X(02).
               10  WS-PROD-CURRENCY        PIC X(03).
               10  WS-PROD-STATUS          PIC X(01).
      *
      *----------------------------------------------------------------*
      * TABLA DE ESTADOS / MUNICIPIOS                                 *
      *----------------------------------------------------------------*
       01  WS-ESTADO-TABLE.
           05  WS-ESTADO-ENTRY             OCCURS 32.
               10  WS-EST-CODE             PIC X(02).
               10  WS-EST-NAME             PIC X(30).
      *
      *----------------------------------------------------------------*
      * TABLA DE ACTIVIDADES ECONOMICAS                               *
      *----------------------------------------------------------------*
       01  WS-ACTIVIDAD-TABLE.
           05  WS-ACTIVIDAD-ENTRY          OCCURS 99.
               10  WS-ACT-COD              PIC X(06).
               10  WS-ACT-DESC             PIC X(40).
      *
      *----------------------------------------------------------------*
      * TABLA DE MOTIVOS DE BAJA / CANCELACION                        *
      *----------------------------------------------------------------*
       01  WS-MOTIVOS-BAJA.
           05  WS-MOTIVO-BAJA-ENTRY        OCCURS 20.
               10  WS-MOT-BAJA-COD         PIC X(02).
               10  WS-MOT-BAJA-DESC        PIC X(35).
                   88  WS-MOT-SOLICITUD    VALUE 'SOLICITUD CLIENTE'.
                   88  WS-MOT-SALDO-CERO   VALUE 'SALDO CERO'.
                   88  WS-MOT-FRAUDE       VALUE 'FRAUDE / SOSPECHA'.
                   88  WS-MOT-ORDEN-JUD    VALUE 'ORDEN JUDICIAL'.
                   88  WS-MOT-FALLECIMIENTO VALUE 'FALLECIMIENTO'.
                   88  WS-MOT-MAL-MANEJO   VALUE 'MAL MANEJO'.
                   88  WS-MOT-PRODUCTO     VALUE 'CAMBIO PRODUCTO'.
      *
      *----------------------------------------------------------------*
      * TABLA DE TASA DE CAMBIO POR DIA                               *
      *----------------------------------------------------------------*
       01  WS-TC-DIARIO.
           05  WS-TC-FECHA                 PIC 9(08).
           05  WS-TC-TABLE.
               10  WS-TC-ENTRY             OCCURS 10.
                   15  WS-TC-MONEDA        PIC X(03).
                   15  WS-TC-COMPRA        PIC 9(07)V9(06) COMP-3.
                   15  WS-TC-VENTA         PIC 9(07)V9(06) COMP-3.
