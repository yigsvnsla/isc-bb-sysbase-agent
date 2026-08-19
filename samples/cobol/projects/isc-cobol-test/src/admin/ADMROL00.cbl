      *================================================================*
      * ADMROL00 - ADMINISTRACION DE ROLES Y PERMISOS                 *
      * EQUIPO: SEGURIDAD INFORMATICA - 2003                           *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADMROL00.
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-PS2.
       OBJECT-COMPUTER. IBM-PS2.
       SPECIAL-NAMES.
           CRT STATUS IS WS-CRT-STATUS.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-CRT-STATUS                  PIC 9(04).
           88  WS-CRT-PF12               VALUE 1012.
           88  WS-CRT-ENTER              VALUE 0013.
       01  WS-VARIABLES.
           05  WS-USUARIO                 PIC X(08).
           05  WS-FECHA                   PIC 9(08).
           05  WS-HORA                    PIC 9(06).
           05  WS-MENSAJE                 PIC X(60).
           05  WS-MENSAJE-ERROR           PIC X(60).
           05  WS-RETCODE                 PIC 99.
           05  WS-PROGRAMA                PIC X(08) VALUE 'ADMROL00'.
           05  WS-ROL-SEL                 PIC X(03).
           05  WS-AUDIT-DATA              PIC X(60).
       01  WS-ROL-TABLE.
           05  WS-ROL-ENTRY               OCCURS 7.
               10  WS-ROL-CODE            PIC X(03).
               10  WS-ROL-NAME            PIC X(20).
               10  WS-ROL-PERM-COUNT      PIC 9(02).
               10  WS-ROL-PERMISSIONS     OCCURS 10.
                   15  WS-ROL-PERM-PROG   PIC X(08).
                   15  WS-ROL-PERM-DESC   PIC X(30).
       01  WS-ROL-COUNT                   PIC 9(02).
       01  WS-I                           PIC 9(02).
       01  WS-J                           PIC 9(02).
       01  WS-INDEX-SEL                   PIC 9(02).
       01  WS-NEW-PERM-PROG               PIC X(08).
       01  WS-NEW-PERM-DESC               PIC X(30).
       SCREEN SECTION.
       01  SCR-ROL-LIST.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - ROLES DEL SISTEMA'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 03  COL 05  PIC X(40) VALUE 'CODIGO  ROL'.
           05  LINE 05  COL 05  PIC X(03) FROM WS-ROL-CODE(1).
           05  LINE 05  COL 10  PIC X(20) FROM WS-ROL-NAME(1).
           05  LINE 06  COL 05  PIC X(03) FROM WS-ROL-CODE(2).
           05  LINE 06  COL 10  PIC X(20) FROM WS-ROL-NAME(2).
           05  LINE 07  COL 05  PIC X(03) FROM WS-ROL-CODE(3).
           05  LINE 07  COL 10  PIC X(20) FROM WS-ROL-NAME(3).
           05  LINE 08  COL 05  PIC X(03) FROM WS-ROL-CODE(4).
           05  LINE 08  COL 10  PIC X(20) FROM WS-ROL-NAME(4).
           05  LINE 09  COL 05  PIC X(03) FROM WS-ROL-CODE(5).
           05  LINE 09  COL 10  PIC X(20) FROM WS-ROL-NAME(5).
           05  LINE 10  COL 05  PIC X(03) FROM WS-ROL-CODE(6).
           05  LINE 10  COL 10  PIC X(20) FROM WS-ROL-NAME(6).
           05  LINE 11  COL 05  PIC X(03) FROM WS-ROL-CODE(7).
           05  LINE 11  COL 10  PIC X(20) FROM WS-ROL-NAME(7).
           05  LINE 14  COL 05  PIC X(20) VALUE 'SELECCIONE ROL:'.
           05  LINE 14  COL 25  PIC X(03) USING WS-ROL-SEL AUTO.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=VER/EDITAR  PF12=RETORNAR'.
       01  SCR-PERM-EDIT.
           05  LINE 01  COL 01  PIC X(80)
               VALUE ' BANCO NACIONAL - PERMISOS DE ROL'.
           05  LINE 01  COL 72  PIC X(08) FROM WS-USUARIO.
           05  LINE 03  COL 05  PIC X(15) VALUE 'ROL:'.
           05  LINE 03  COL 15  PIC X(03)
               FROM WS-ROL-CODE(WS-INDEX-SEL).
           05  LINE 03  COL 25  PIC X(20)
               FROM WS-ROL-NAME(WS-INDEX-SEL).
           05  LINE 05  COL 05  PIC X(60)
               VALUE 'PROGRAMA     DESCRIPCION'.
           05  LINE 07  COL 05  PIC X(08)
               FROM WS-ROL-PERM-PROG(WS-INDEX-SEL, 1).
           05  LINE 07  COL 18  PIC X(30)
               FROM WS-ROL-PERM-DESC(WS-INDEX-SEL, 1).
           05  LINE 08  COL 05  PIC X(08)
               FROM WS-ROL-PERM-PROG(WS-INDEX-SEL, 2).
           05  LINE 08  COL 18  PIC X(30)
               FROM WS-ROL-PERM-DESC(WS-INDEX-SEL, 2).
           05  LINE 09  COL 05  PIC X(08)
               FROM WS-ROL-PERM-PROG(WS-INDEX-SEL, 3).
           05  LINE 09  COL 18  PIC X(30)
               FROM WS-ROL-PERM-DESC(WS-INDEX-SEL, 3).
           05  LINE 14  COL 05  PIC X(15) VALUE 'NUEVO PROGRAMA:'.
           05  LINE 14  COL 25  PIC X(08) USING WS-NEW-PERM-PROG AUTO.
           05  LINE 15  COL 05  PIC X(15) VALUE 'DESCRIPCION:'.
           05  LINE 15  COL 25  PIC X(30) USING WS-NEW-PERM-DESC AUTO.
           05  LINE 22  COL 02  PIC X(60) FROM WS-MENSAJE.
           05  LINE 24  COL 02  PIC X(78)
               VALUE 'ENTER=AGREGAR  PF12=RETORNAR'.
       LINKAGE SECTION.
       01  LS-USUARIO                     PIC X(08).
       01  LS-RETCODE                     PIC 99.
       PROCEDURE DIVISION USING LS-USUARIO LS-RETCODE.
       MAIN.
           MOVE SPACES TO WS-MENSAJE WS-MENSAJE-ERROR.
           MOVE LS-USUARIO TO WS-USUARIO.
           MOVE 00 TO LS-RETCODE.
           PERFORM 1000-INICIALIZAR.
           PERFORM 1100-CARGAR-ROLES.
       0100-LISTA.
           PERFORM 2000-PANTALLA-LISTA.
           ACCEPT SCR-ROL-LIST.
           IF WS-CRT-PF12 GO TO 9000-EXIT.
           IF WS-ROL-SEL = SPACES
               MOVE 'SELECCIONE UN ROL' TO WS-MENSAJE-ERROR
               GO TO 0100-LISTA.
           MOVE 0 TO WS-INDEX-SEL.
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 7
               IF WS-ROL-CODE(WS-I) = WS-ROL-SEL
                   MOVE WS-I TO WS-INDEX-SEL
               END-IF.
           IF WS-INDEX-SEL = 0
               MOVE 'ROL NO ENCONTRADO' TO WS-MENSAJE-ERROR
               GO TO 0100-LISTA.
       0200-PERMISOS.
           PERFORM 2100-PANTALLA-PERM.
           ACCEPT SCR-PERM-EDIT.
           IF WS-CRT-PF12 GO TO 0100-LISTA.
           IF WS-NEW-PERM-PROG = SPACES
               MOVE 'INGRESE PROGRAMA' TO WS-MENSAJE-ERROR
               GO TO 0200-PERMISOS.
           ADD 1 TO WS-ROL-PERM-COUNT(WS-INDEX-SEL).
           MOVE WS-NEW-PERM-PROG
             TO WS-ROL-PERM-PROG(WS-INDEX-SEL,
                                 WS-ROL-PERM-COUNT(WS-INDEX-SEL)).
           MOVE WS-NEW-PERM-DESC
             TO WS-ROL-PERM-DESC(WS-INDEX-SEL,
                                 WS-ROL-PERM-COUNT(WS-INDEX-SEL)).
           MOVE SPACES TO WS-NEW-PERM-PROG WS-NEW-PERM-DESC.
           MOVE 'PERMISO AGREGADO' TO WS-MENSAJE.
           GO TO 0200-PERMISOS.
       1000-INICIALIZAR.
           CALL 'COMDATE' USING 'NOW' WS-FECHA WS-HORA.
           MOVE 'SELECCIONE ROL PARA VER/EDITAR' TO WS-MENSAJE.
           PERFORM 1100-LIMPIAR.
       1100-LIMPIAR. DISPLAY SPACES UPON CRT.
       1100-CARGAR-ROLES.
           MOVE 'ADM' TO WS-ROL-CODE(1). MOVE 'ADMINISTRADOR' TO WS-ROL-NAME(1).
           MOVE 5 TO WS-ROL-PERM-COUNT(1).
           MOVE 'ADMMNU00' TO WS-ROL-PERM-PROG(1, 1).
           MOVE 'SECUSR00' TO WS-ROL-PERM-PROG(1, 2).
           MOVE 'ADMPAR00' TO WS-ROL-PERM-PROG(1, 3).
           MOVE 'ADMAUD00' TO WS-ROL-PERM-PROG(1, 4).
           MOVE 'ADMCFG00' TO WS-ROL-PERM-PROG(1, 5).
           MOVE 'GER' TO WS-ROL-CODE(2). MOVE 'GERENTE' TO WS-ROL-NAME(2).
           MOVE 2 TO WS-ROL-PERM-COUNT(2).
           MOVE 'CRDLMT00' TO WS-ROL-PERM-PROG(2, 1).
           MOVE 'ADMBRH00' TO WS-ROL-PERM-PROG(2, 2).
           MOVE 'SUP' TO WS-ROL-CODE(3). MOVE 'SUPERVISOR' TO WS-ROL-NAME(3).
           MOVE 2 TO WS-ROL-PERM-COUNT(3).
           MOVE 'CRDBLK00' TO WS-ROL-PERM-PROG(3, 1).
           MOVE 'CRDREP00' TO WS-ROL-PERM-PROG(3, 2).
           MOVE 'CAJ' TO WS-ROL-CODE(4). MOVE 'CAJERO' TO WS-ROL-NAME(4).
           MOVE 2 TO WS-ROL-PERM-COUNT(4).
           MOVE 'CRDINQ00' TO WS-ROL-PERM-PROG(4, 1).
           MOVE 'CRDPIN00' TO WS-ROL-PERM-PROG(4, 2).
           MOVE 'OFI' TO WS-ROL-CODE(5). MOVE 'OFICIAL' TO WS-ROL-NAME(5).
           MOVE 2 TO WS-ROL-PERM-COUNT(5).
           MOVE 'CRDMOV00' TO WS-ROL-PERM-PROG(5, 1).
           MOVE 'CRDALR00' TO WS-ROL-PERM-PROG(5, 2).
           MOVE 'AUD' TO WS-ROL-CODE(6). MOVE 'AUDITOR' TO WS-ROL-NAME(6).
           MOVE 1 TO WS-ROL-PERM-COUNT(6).
           MOVE 'ADMAUD00' TO WS-ROL-PERM-PROG(6, 1).
           MOVE 'CON' TO WS-ROL-CODE(7). MOVE 'CONSULTA' TO WS-ROL-NAME(7).
           MOVE 1 TO WS-ROL-PERM-COUNT(7).
           MOVE 'CRDINQ00' TO WS-ROL-PERM-PROG(7, 1).
           MOVE 7 TO WS-ROL-COUNT.
       2000-PANTALLA-LISTA.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-ROL-LIST.
       2100-PANTALLA-PERM.
           PERFORM 1100-LIMPIAR.
           DISPLAY SCR-PERM-EDIT.
       9000-EXIT.
           MOVE 00 TO LS-RETCODE.
           EXIT PROGRAM.
       END PROGRAM ADMROL00.
