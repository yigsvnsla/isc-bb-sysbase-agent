      *================================================================*
      * CPY-SCREEN - LAYOUTS DE PANTALLA COMPARTIDOS                  *
      * EQUIPO: DESARROLLO CANALES - 2002                              *
      *================================================================*
      * REUTILIZADO POR TODOS LOS MODULOS CON SCREEN SECTION           *
      *================================================================*
      *
      *========= CABECERA ESTANDAR =========*
       01  SC-CABECERA.
           05  SC-CAB-HDR.
               10  SC-HDR-FECHA           PIC 9(08) FROM WS-BUSINESS-DATE.
               10  SC-HDR-HORA            PIC 9(06) FROM WS-CURRENT-TIME.
               10  SC-HDR-USUARIO         PIC X(08) FROM WS-USUARIO-ID.
               10  SC-HDR-SUCURSAL        PIC X(04) FROM WS-SUCURSAL-ID.
               10  SC-HDR-SISTEMA         PIC X(20) VALUE 'BANCO NACIONAL'.
               10  SC-HDR-PROGRAMA        PIC X(08) FROM WS-PROGRAMA-ID.
      *
      *========= LINEA SEPARADORA =========*
       01  SC-LINEA.
           05  SC-LINEA-BLANCO            PIC X(80) VALUE SPACES.
      *
      *========= LINEA ESTATUS / PF-KEYS =========*
       01  SC-PF-STATUS.
           05  SC-PF-TEXTO                PIC X(79).
           05  SC-PF-IND                  PIC 99.
               88  SC-PF-EXIT             VALUE 03.
               88  SC-PF-HELP             VALUE 01.
               88  SC-PF-RETURN           VALUE 12.
               88  SC-PF-CLEAR            VALUE 00.
      *
      *========= MENSAJE DE ERROR =========*
       01  SC-MSG-ERROR.
           05  SC-MSG-ERROR-TEXTO         PIC X(60).
           05  SC-MSG-ERROR-COD           PIC 99.
           05  SC-MSG-ERROR-BLINK         PIC X VALUE 'Y'.
               88  SC-MSG-BLINK-ON        VALUE 'Y'.
               88  SC-MSG-BLINK-OFF       VALUE 'N'.
      *
      *========= CAMPOS DE SELECCION DE MENU =========*
       01  SC-SEL-MENU.
           05  SC-SEL-OPCION              PIC 99.
           05  SC-SEL-VALIDO              PIC X.
               88  SC-SEL-VALIDO-YES      VALUE 'Y'.
               88  SC-SEL-VALIDO-NO       VALUE 'N'.
      *
      *========= CONFIRMACION ESTANDAR =========*
       01  SC-CONFIRMA.
           05  SC-CONF-TEXTO              PIC X(40).
           05  SC-CONF-RESPUESTA          PIC X.
               88  SC-CONF-SI             VALUE 'S'.
               88  SC-CONF-NO             VALUE 'N'.
               88  SC-CONF-CANCELAR       VALUE 'C'.
      *
      *========= CAMPOS DE BUSQUEDA =========*
       01  SC-SEARCH-KEY.
           05  SC-SEARCH-TYPE             PIC X(02).
               88  SC-SEARCH-BY-ID        VALUE '01'.
               88  SC-SEARCH-BY-NAME      VALUE '02'.
               88  SC-SEARCH-BY-RFC       VALUE '03'.
               88  SC-SEARCH-BY-ACCOUNT   VALUE '04'.
           05  SC-SEARCH-VALUE            PIC X(30).
           05  SC-SEARCH-RESULT-COUNT     PIC 9(04).
           05  SC-SEARCH-RESULT-TABLE     OCCURS 20.
               10  SC-SEARCH-RESULT-ID    PIC 9(10).
               10  SC-SEARCH-RESULT-NAME  PIC X(40).
               10  SC-SEARCH-RESULT-TYPE  PIC X(02).
