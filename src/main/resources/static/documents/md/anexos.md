# Anexos

## Anexo 1 — Cabecera obligatoria de procedimientos almacenados (.sp)

El Anexo 1 contiene información que permite la revisión de código estático a través de la herramienta **Sonarqube**. A continuación se detalla el uso de cada etiqueta obligatoria:

| Etiqueta | Usado para |
|---|---|
| `Archivo:` | Corresponde al nombre del archivo físico del programa. |
| `Motor de Base:` | Nombre del motor, los valores permitidos son: `SYBASE`, `SQLSERVER`, `ORACLE`, `MYSQL`. Deben ser definidos en mayúscula. |
| `Base de datos:` | Nombre de la base de datos donde se ejecuta el script. |
| `Servidor:` | Nombre del servidor donde se ejecuta el script. |
| `Aplicacion:` | Nombre de la aplicación. |
| `Store procedure:` / `View:` / `Function:` / `Script:` | Nombre del Procedimiento / Nombre de la vista / Nombre de la función / (En blanco). |
| `Procesamiento:` | Tipo de proceso, puede tener tres valores: `OLTP` (operaciones transaccionales); `BATCH` (procesos por lotes — no acceden a `db_temporal` ni `db_general`); `BATCH ESPECIAL` (procesos por lotes con gran volumen de información donde `tempdb` al llegar al límite genera log suspend — sí acceden a `db_general` y `db_temporal` para evitar log suspend). |
| `Ult.ControlTarea:` | Corresponde al código de tarea asignado. Código Rational: inicia con el prefijo `R-` (ej. `R-BVIRM24`). Código Jira: inicia con el prefijo `J-` (ej. `J-CYBERBANK-4928`). |
| `Ult.Referencia:` | Corresponde a la referencia de control de cambios que se hace al programa: `REF 1` corresponde a la Emisión Inicial del programa y **no se declara REF 1 en el cuerpo del programa**. `REF #` (con # distinto de uno) es obligatorio que cumpla lo indicado en la sección "Referencia de cambio en el código adicionado" de `sybase-sqlserver.md`. |
| `PROPOSITO:` | Descripción de uso del programa. El motivo de modificación puede escribirse en varias líneas. |

Plantilla / ejemplo real de cabecera:

```sql
/**********************************************************************/
/* Archivo:              pa_onb_iclientesprecal.sp                    */
/* Motor de Base:        SQLSERVER                                    */
/* Base de datos:        cob_cuentas                                  */
/* Servidor:             SATBBSRV                                     */
/* Aplicacion:           Retanqueo                                    */
/* Stored procedure:     pa_onb_iclientesprecal                       */
/* Procesamiento:        OLTP                                         */
/* Ult.ControlTarea:     J-BVIRM24                                    */
/* Ult.Referencia:       REF 1                                        */
/* Disenado por:         Elizabeth Sangucho                           */
/* Fecha de escritura:   15/Jul/2022                                  */
/**********************************************************************/
/*                          IMPORTANTE                                */
/*  Este programa es parte de los paquetes bancarios propiedad de     */
/*  "BANCO BOLIVARIANO C.A."                                          */
/*  Su uso no autorizado queda expresamente prohibido asi como        */
/*  cualquier alteracion o agregado hecho por alguno de sus           */
/*  usuarios sin el debido consentimiento por escrito de la           */
/*  Presidencia Ejecutiva de BANCO BOLIVARIANO o su representante     */
/**********************************************************************/
/* PROPOSITO:                                                         */
/*    Procesamiento para descartar clientes que no pasan el seguro    */
/*    para rutas online o express                                     */
/**********************************************************************/
/* REF   FECHA          AUTOR                  TAREA                  */
/*  1    15/Jul/2022    Elizabeth Sangucho     BVIRM24                */
/*       Emision inicial                                              */
/**********************************************************************/
```

## Anexo 2 — Cabecera obligatoria de programas SQR (.sqr)

Plantilla / ejemplo real de cabecera SQR:

```sql
!**********************************************************************
!* Archivo:             ca_fincua.sqr                                 *
!* Base de datos:       cob_cartera                                   *
!* Producto:            CCA                                           *
!* Disenado por:        Lucia Altamirano B.                           *
!* Fecha de escritura:  05/NOV/2004                                   *
!**********************************************************************
!*                          IMPORTANTE                                *
!*  Este programa es parte de los paquetes bancarios propiedad de     *
!*  "BANCO BOLIVARIANO"                                                *
!*  Su uso no autorizado queda expresamente prohibido asi como        *
!*  cualquier alteracion o agregado hecho por alguno de sus           *
!*  usuarios sin el debido consentimiento por escrito de la           *
!*  Presidencia Ejecutiva de BANCO BOLIVARIANO o su representante.    *
!**********************************************************************
!*                          PROPOSITO                                 *
!*  Generar archivo con informacion de cuadre de informacion          *
!*  reportada a procesos de Finanware                                 *
!**********************************************************************
!*                          MODIFICACIONES                            *
!* REF  FECHA        AUTOR              TAREA RATIONAL       DESCRIPCION        *
!*  1   27/Abr/2010  Adriana Martinez   CCA-CC-9914          Migracion Sybase 15 *
!*  2   22.jul.2015  Lourdes Reyes      CCA-CC-SGC00020808   Cambio x tipoCredito *
!**********************************************************************
```

## Anexo 3 — Cabecera obligatoria de scripts (.sql)

Plantilla mínima a completar (mínimo 2 líneas describiendo el propósito):

```
Nombre script:
Realizado por:
Fecha:
Propósito: (mínimo 2 líneas describiendo el propósito)
Tarea rational:
```

## Anexo 4 — Nemónicos de aplicación

> Si una aplicación no aparece en este listado, indícalo explícitamente al usuario en lugar de inventar un nemónico; el nemónico oficial proviene de la herramienta Rational ClearQuest (ver sección 4.3 / 5.x en los estándares por motor).

| Nombre de Producto | Nemónico |
|---|---|
| Costeo - MyABCM | ABC |
| Sistema de Accionistas | ACC |
| Activos Fijos | ACF |
| Accionistas | ACS |
| Administración y Control | ADCON |
| Administración | ADM |
| Administrador de Tarifas | ADTAR |
| Cuenta de Ahorros | AHO |
| ALERT MANAGER | ALM |
| Tarjetas Corporativas | ATC |
| Administración de Tarjetas | ATM |
| BATCH | BAT |
| BBP-Bank | BBPB |
| Cheques Banco Central Micros | BCM |
| Blindado | BI |
| Banca Internet Bolivariano | BIB |
| Transportación de Valores | BLI |
| 24Movil | BMO |
| BUSSINESS PROCESS MANAGEMENT | BPM |
| Blade Server + VMWare | BSVMW |
| Botón de pagos | BTNPG |
| Banca Virtual | BV |
| Cajeros Automáticos | CAJ |
| Call Center | CAL |
| Cambios | CAM |
| Catastros | CAS |
| Cartera | CCA |
| Casilleros de Correspondencia | CCC |
| Comercio Exterior | CEX |
| CHATBOT – Canal de mensajería asistida por Robot | CHBOT |
| Cheques | CHQ |
| Cámara - CheqScan | CHQSC |
| CobisIP | CIP |
| Cobranzas | COB |
| Colegios | COL |
| Contabilidad | CON |
| Cobis Procesador Servicios | CPS |
| Crédito | CRE |
| Finanware - CRM Analítico | CRM |
| CRM OPERATIVO | CRMO |
| Casilleros de Seguridad | CSC |
| Cobis Services Processor | CSP |
| Cuenta Corriente | CTE |
| Finanware - CYPLA | CYPLA |
| Documentación del Centro de Computo | DCC |
| Digitalización | DIGI |
| Finanware - DIS | DIS |
| Document Management System Portal | DMS |
| Datawarehouse | DWH |
| Datawarehouse Panama | DWHP |
| Ecuagiros | ECU |
| Factoring | FAC |
| Facturación Electrónica | FACEL |
| Finanware - Análisis Financiero | FAF |
| Finanware-BIADMIN | FBA |
| Finanware - BENCHMARK | FBEN |
| Firmas | FIR |
| Fiscales | FIS |
| Fondos | FON |
| Framework de Seguridad | FRM |
| Garantías | GAR |
| Gestión de Cobranzas | GCOB |
| Grabador Interactivo de Genesys | GIR |
| Infraestructura Banca Virtual | IBV |
| Infochannel | IFC |
| Internet | INT |
| Intranet Aplicativa | INTA |
| Intranet | INTRA |
| Finanware - IRBA | IRBA |
| Impresión Tarjetas Micros | ITM |
| Anexos IVA | IVA |
| 24Fono | IVR |
| Punto veinti4 | KSK |
| Leasing | LEA |
| Migración CRM a Dynamics 365 | MCRM |
| Middleware | MDW |
| MIGRACION | MIG |
| Migración Robot de Giros | MIGROB |
| Master Information Subsystem | MIS |
| Monitor Plus | MPL |
| BBP-Monitor Plus | MPLBBP |
| Micrositio QuickPay | MQP |
| Mesa de Dinero | MSD |
| Módulo de Transmisión y Recepción de Archivos | MTRA |
| Notificaciones | NOTIF |
| Novedades del Centro de Computo | NOV |
| Novedades Panamá | NOVP |
| Administrador de Procedimientos | Octadocs |
| Bridger-OFAC | OFAC |
| OFFLINE | OFFL |
| BBP-ADMIN COBIS | PADM |
| Pagos | PAG |
| BBP-Administración de Tarjetas | PATM |
| BBP-24Movil | PBMO |
| BBP-Banca Virtual | PBV |
| BBP-Cartera | PCCA |
| BBP-Contabilidad | PCON |
| BBP-Crédito | PCRE |
| BBP-Cuenta Corriente | PCTE |
| Proceso de Documentación | PDC |
| BBP-Digitalización | PDIGI |
| Portal Documental | PDOC |
| BBP-Datawarehouse | PDWH |
| Personalización | PER |
| Depósitos a Plazo Fijo | PFI |
| Pilot / Finanware | PFW |
| BBP-Garantías | PGAR |
| BBP-Intranet | PINTRA |
| Plataforma Dominium | PLAT |
| BBP-Master Information Subsystem | PMIS |
| BBP-Novedades del Centro de Computo | PNOV |
| BBP-Depósitos a Plazo Fijo | PPFI |
| BBP-Portal Web | PPW |
| Producto | PRO |
| Sistema de Proveeduría | PROV |
| BBP-Portal TRisk Security | PRSK |
| PRUEBA2 | PRUE |
| Proveeduría | PRV |
| BBP-Tarjetas de Crédito | PTCRE |
| BBP-Tesorería | PTES |
| Q-MATIC | QMT |
| BBP - Registro de Asistencia | RABBP |
| Reclamos | REC |
| Recaudaciones | RECA |
| RED | RED |
| Referencias | REF |
| Referencias Bancarias | REFBA |
| Remesas y Cámara | REM |
| Finanware - Rentabilidad | REN |
| Finanware - Reportes | REP |
| Recursos Humanos | RHH |
| Finanware - Reportes Legales | RLEG |
| Finanware - RML | RML |
| Sistema de Administración de Cobranzas | SAC |
| Sistema de Administración de Tesorería | SAT |
| Sistema de Calificación | SC |
| Seguridades | SEG |
| Seguros | SGR |
| Sistema Integrado | SI |
| Sistemas de Información | SIG |
| Sistema de Pases | SPA |
| SWIFT | SWF |
| BBP-SWIFT | SWFBBP |
| Switch | Switch |
| Tarjeta Bancard | TBC |
| Tarjetas de Crédito | TCRE |
| Tesoreria | TES |
| Finanware - VAR | VAR |
| Verificación de Referencias | VCR |
| VIRTUAL DOCUMENT TRANSACTION | VDT |
| Cuenta Virtual | VIR |
| VERSADIAL | VSD |
| Verificación Telefónica | VTF |
| 24Movil WAP | WAP |
| WebSphere | WSP |
| Servicios Bancarios | ZSB |
