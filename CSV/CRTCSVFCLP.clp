             PGM        PARM(&FILE &TOSTMF &MBR &OVRWRT &DBFCCSID +
                          &STMFCCSID &ADDINF &RCDERR &RCDERRMSG +
                          &RPLCHR &FLDDLM &DEBUG)

             DCL        VAR(&FILE) TYPE(*CHAR) LEN(20)
             DCL        VAR(&TOSTMF) TYPE(*CHAR) LEN(256)
             DCL        VAR(&MBR) TYPE(*CHAR) LEN(10)
             DCL        VAR(&OVRWRT) TYPE(*CHAR) LEN(4)
             DCL        VAR(&DBFCCSID) TYPE(*DEC) LEN(5 0)
             DCL        VAR(&STMFCCSID) TYPE(*DEC) LEN(5 0)
             DCL        VAR(&ADDINF) TYPE(*CHAR) LEN(7)
             DCL        VAR(&RCDERR) TYPE(*DEC) LEN(4 0)
             DCL        VAR(&RCDERRMSG) TYPE(*CHAR) LEN(7)
             DCL        VAR(&RPLCHR) TYPE(*CHAR) LEN(1)
             DCL        VAR(&FLDDLM) TYPE(*CHAR) LEN(1)
             DCL        VAR(&DEBUG) TYPE(*CHAR) LEN(4)

             DCL        VAR(&JOBCCSID) TYPE(*DEC) LEN(5 0)
             DCL        VAR(&NBRCURRCD) TYPE(*DEC) LEN(10 0)
             DCL        VAR(&MSG_DATA) TYPE(*CHAR) LEN(200)

             DCL        VAR(&W) TYPE(*CHAR) LEN(8)
             DCL        VAR(&MSG) TYPE(*CHAR) LEN(300)

             MONMSG     MSGID(CPA0000 CPD0000 CEE0000 CPF0000 +
                          CPI0000 MCH0000 RNX0000 RNQ0000) +
                          EXEC(GOTO CMDLBL(ERROR))

             CHKOBJ     OBJ(%SST(&FILE 11 10)/%SST(&FILE 1 10)) +
                          OBJTYPE(*FILE) MBR(&MBR)
             RTVMBRD    FILE(%SST(&FILE 11 10)/%SST(&FILE 1 10)) +
                          MBR(&MBR) NBRCURRCD(&NBRCURRCD)
             OVRDBF     FILE(IN) TOFILE(%SST(&FILE 11 10)/%SST(&FILE +
                          1 10)) MBR(&MBR)
             RTVJOBA    CCSID(&JOBCCSID)

             CALL       PGM(CRTCSVFRPG) PARM(&TOSTMF &OVRWRT +
                          &DBFCCSID &STMFCCSID &ADDINF &RCDERR +
                          &RCDERRMSG &RPLCHR &FLDDLM &DEBUG +
                          &JOBCCSID &NBRCURRCD &MSG_DATA)
             IF         COND(%SST(&MSG_DATA 1 1) = 'E') +
                          THEN(SNDPGMMSG MSGID(CPF9897) +
                          MSGF(QCPFMSG) MSGDTA(%SST(&MSG_DATA 2 +
                          199)) MSGTYPE(*ESCAPE))
             ELSE       CMD(SNDPGMMSG MSG(%SST(&MSG_DATA 2 199)))
             DLTOVR     FILE(IN)
             SNDPGMMSG  MSGID(CPI9801) MSGF(QCPFMSG) TOPGMQ(*EXT) +
                          MSGTYPE(*STATUS)
             GOTO       CMDLBL(END)

 ERROR:      RCVMSG     MSGTYPE(*EXCP) MSG(&MSG)
             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA('Command +
                          failed. reason - ' |< &MSG) MSGTYPE(*ESCAPE)
             GOTO       CMDLBL(END)

 END:        ENDPGM
