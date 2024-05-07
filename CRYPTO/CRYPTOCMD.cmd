             CMD        PROMPT('AES ENCRYPTION/DECRIPTION')
             PARM       KWD(CRYPTMODE) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          SPCVAL((*ENC 'E') (*DEC 'D')) MIN(1) +
                          CASE(*MONO) PROMPT('ENCRYPTION/DECRIPTION')
             PARM       KWD(INDATA) TYPE(*CHAR) LEN(2048) MIN(1) +
                          CASE(*MIXED) PROMPT('INPUT DATA')
             PARM       KWD(PASSWORD) TYPE(*CHAR) LEN(16) MIN(1) +
                          ALWUNPRT(*NO) CASE(*MIXED) PROMPT(PASSWORD)
             PARM       KWD(VERBOSE) TYPE(*CHAR) LEN(1) RSTD(*YES) +
                          DFT(*NO) SPCVAL((*YES 'V') (*NO ' ')) +
                          CASE(*MONO) PROMPT('VERBOSE MODE')
