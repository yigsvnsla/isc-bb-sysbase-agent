       IDENTIFICATION DIVISION.
       PROGRAM-ID. CICSAPP.
       AUTHOR. ISC-FIXTURE.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-RESPONSE          PIC S9(08) COMP VALUE ZEROS.
       01  WS-ACCOUNT-ID        PIC X(10) VALUE SPACES.
       01  WS-AMOUNT            PIC 9(09)V99 VALUE ZEROS.

       LINKAGE SECTION.
       01  DFHCOMMAREA.
           05  CA-ACTION        PIC X(01).
           05  CA-ACCOUNT-ID    PIC X(10).
           05  CA-STATUS        PIC X(02).

       PROCEDURE DIVISION.
       MAIN-PARA.
           EXEC CICS RECEIVE MAP('ACCTMAP')
               MAPSET('ACCTSET')
               INTO(WS-ACCOUNT-ID)
               RESP(WS-RESPONSE)
           END-EXEC.

           IF WS-RESPONSE = 0
               EXEC CICS READ
                   DATASET('ACCTFILE')
                   INTO(WS-AMOUNT)
                   RIDFLD(WS-ACCOUNT-ID)
                   RESP(WS-RESPONSE)
               END-EXEC
           END-IF.

           EXEC CICS SEND MAP('ACCTMAP')
               MAPSET('ACCTSET')
               FROM(WS-AMOUNT)
               ERASE
           END-EXEC.

           EXEC CICS RETURN
               TRANSID('ACCT')
               COMMAREA(DFHCOMMAREA)
           END-EXEC.
