             PGM        PARM(&CRYPTMODE &INDATA &PASSWORD &VERBOSE)
             DCL        VAR(&CRYPTMODE) TYPE(*CHAR) LEN(1)
             DCL        VAR(&INDATA) TYPE(*CHAR) LEN(2048)
             DCL        VAR(&PASSWORD) TYPE(*CHAR) LEN(16)
             DCL        VAR(&OUTDATA) TYPE(*CHAR) LEN(2048)
             DCL        VAR(&VERBOSE) TYPE(*CHAR) LEN(1)
             DCL        VAR(&ERRID) TYPE(*CHAR) LEN(10)

             CALL       PGM(CRYPTOWRAP) PARM(&CRYPTMODE &INDATA +
                          &PASSWORD &OUTDATA &VERBOSE &ERRID)
             IF         COND(&ERRID = ' ') THEN(SNDPGMMSG +
                          MSG(&OUTDATA))
             ELSE       CMD(SNDPGMMSG MSG(&ERRID))

             ENDPGM
