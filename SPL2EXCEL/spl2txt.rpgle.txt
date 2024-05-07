             PGM

             DCL        VAR(&SPLF) TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&USER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBNO) TYPE(*CHAR) LEN(6)
             DCL        VAR(&ERROR) TYPE(*CHAR) LEN(1)

             DCL        VAR(&RCVVAR) TYPE(*CHAR) LEN(70)         /* OUTPUT */
             DCL        VAR(&LENRCVVAR) TYPE(*CHAR) LEN(4) +
                          VALUE(X'00000046')                     /* INPUT */
             DCL        VAR(&INFMTNAM) TYPE(*CHAR) LEN(8) +
                          VALUE(SPRL0100)                        /* INPUT */
             DCL        VAR(&QUSEC) TYPE(*CHAR) LEN(16) +
                          VALUE(X'00000010000000004040404040404000') +
                                                                 /* OUTPUT */
             DCL        VAR(&BAVL) TYPE(*CHAR) LEN(4)
             DCL        VAR(&BAVL_D) TYPE(*DEC) LEN(6)
             DCL        VAR(&EI) TYPE(*CHAR) LEN(7)

             /* CALL RETRIEVE IDENTITY OF LAST SPOOLED FILE CREATED */
             /* (QSPRILSP) API                                      */
             CALL       PGM(QSPRILSP) PARM(&RCVVAR &LENRCVVAR +
                          &INFMTNAM &QUSEC)

             /* CHECK ERROR */
             CHGVAR     VAR(&BAVL) VALUE(%SST(&QUSEC 5 4))
             CHGVAR     VAR(&BAVL_D) VALUE(%BIN(&BAVL))
             CHGVAR     VAR(&ERROR) VALUE(' ')
             IF         COND(&BAVL_D > 0) THEN(DO)
             CHGVAR     VAR(&EI) VALUE(%SST(&QUSEC 9 7))
             CHGVAR     VAR(&ERROR) VALUE('1')
             GOTO       CMDLBL(EXIT)
             ENDDO

             /* CONVERT RETURN VALUES */
             CHGVAR     VAR(&SPLF) VALUE(%SST(&RCVVAR 9 10))
             CHGVAR     VAR(&JOB) VALUE(%SST(&RCVVAR 19 10))
             CHGVAR     VAR(&USER) VALUE(%SST(&RCVVAR 29 10))
             CHGVAR     VAR(&JOBNO) VALUE(%SST(&RCVVAR 39 10))

             /* EXEC CPYSPLF */
             CRTPF FILE(QTEMP/SPLF) RCDLEN(400) IGCDTA(*YES)
             CPYSPLF    FILE(&SPLF) TOFILE(QTEMP/SPLF) +
                          JOB(&JOBNO/&USER/&JOB) SPLNBR(*LAST)
             DLTSPLF    FILE(&SPLF) JOB(&JOBNO/&USER/&JOB) +
                          SPLNBR(*LAST)

             /* ADJUST SHIFT-CODE */
             OVRDBF     FILE(SPLF) TOFILE(QTEMP/SPLF)
             CALL       PGM(QTEMP/SHIFT)
             DLTOVR     FILE(SPLF)

             GOTO       CMDLBL(EXIT)

 EXIT:
             ENDPGM
