             PGM
             DCL        VAR(&COUNT) TYPE(*DEC) LEN(3 0)

             QSH CMD('touch -C943 /tmp/cpytoimpf.csv')

             SNDPGMMSG  MSG('START LOOP1')
             CHGVAR     VAR(&COUNT) VALUE(0)
 LOOP1:      CPYTOIMPF  FROMFILE(QUSRSYS/QAEZDISK) +
                          TOSTMF('/tmp/cpytoimpf.csv') RCDDLM(*CRLF)
             SNDPGMMSG  MSG(END)
             CHGVAR     VAR(&COUNT) VALUE(&COUNT + 1)
             IF         COND(&COUNT >= 3) THEN(GOTO CMDLBL(NEXT))
             GOTO       CMDLBL(LOOP1)

 NEXT:       SNDPGMMSG  MSG('START LOOP2')
             CHGVAR     VAR(&COUNT) VALUE(0)
 LOOP2:      CRTCSVF    FILE(QUSRSYS/QAEZDISK) +
                          TOSTMF('/tmp/crtcsvf.csv')
             SNDPGMMSG  MSG(END)
             CHGVAR     VAR(&COUNT) VALUE(&COUNT + 1)
             IF         COND(&COUNT >= 3) THEN(GOTO CMDLBL(EXIT))
             GOTO       CMDLBL(LOOP2)

 EXIT:       ENDPGM
