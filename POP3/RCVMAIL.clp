             PGM        PARM(&ACCOUNT &PASSWORD &MAILSERVER &TIMEOUT +
                          &HOMEDIR &LEAVEMAIL &REPLACECID +
                          &RCVLOGTYPE &RCVLOGFILE &RDBDIRE +
                          &RDBUSERID &RDBPASS &DEBUG &DEBUGFILE)

             DCL        VAR(&ACCOUNT) TYPE(*CHAR) LEN(10)
             DCL        VAR(&PASSWORD) TYPE(*CHAR) LEN(128)
             DCL        VAR(&MAILSERVER) TYPE(*CHAR) LEN(64)
             DCL        VAR(&TIMEOUT) TYPE(*DEC) LEN(3 0)
             DCL        VAR(&HOMEDIR) TYPE(*CHAR) LEN(128)
             DCL        VAR(&LEAVEMAIL) TYPE(*CHAR) LEN(5)
             DCL        VAR(&REPLACECID) TYPE(*CHAR) LEN(5)
             DCL        VAR(&RCVLOGTYPE) TYPE(*CHAR) LEN(5)
             DCL        VAR(&RCVLOGFILE) TYPE(*CHAR) LEN(128)
             DCL        VAR(&RDBDIRE) TYPE(*CHAR) LEN(18)
             DCL        VAR(&RDBUSERID) TYPE(*CHAR) LEN(10)
             DCL        VAR(&RDBPASS) TYPE(*CHAR) LEN(128)
             DCL        VAR(&DEBUG) TYPE(*CHAR) LEN(9)
             DCL        VAR(&DEBUGFILE) TYPE(*CHAR) LEN(128)

             DCL        VAR(&USER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SYSNAME) TYPE(*CHAR) LEN(8)
             DCL        VAR(&TIMEOUTC) TYPE(*CHAR) LEN(5)
             DCL        VAR(&MSGID) TYPE(*CHAR) LEN(7)
             DCL        VAR(&MSG) TYPE(*CHAR) LEN(132)
             DCL        VAR(&MSGDTA) TYPE(*CHAR) LEN(4)
             DCL        VAR(&RTNCDE) TYPE(*DEC) LEN(3 0)
             MONMSG     MSGID(CPF0000) EXEC(GOTO CMDLBL(ERROR))

             /* Set parameters */
             RTVJOBA    USER(&USER)
             IF         COND(&HOMEDIR = '*HOME') THEN(CHGVAR +
                          VAR(&HOMEDIR) VALUE('/home/' |< &USER))
             RTVNETA    SYSNAME(&SYSNAME)
             IF         COND(&RDBDIRE = '*SYSNAME') THEN(CHGVAR +
                          VAR(&RDBDIRE) VALUE(&SYSNAME))
             IF         COND(&RDBUSERID = '*ACCOUNT') THEN(CHGVAR +
                          VAR(&RDBUSERID) VALUE(&ACCOUNT))
             IF         COND(&RDBPASS = '*PASSWORD') THEN(CHGVAR +
                          VAR(&RDBPASS) VALUE(&PASSWORD))
             CHGVAR     VAR(&TIMEOUTC) VALUE(&TIMEOUT)

             /* Call Java program */
             RUNJVA     CLASS('Rcvmail') PARM(&ACCOUNT &PASSWORD +
                          &MAILSERVER &TIMEOUTC &HOMEDIR &LEAVEMAIL +
                          &REPLACECID &RCVLOGTYPE &RCVLOGFILE +
                          &RDBDIRE &RDBUSERID &RDBPASS &DEBUG +
                          &DEBUGFILE) +
                          CLASSPATH('/JavaMail:/JavaMail/mail.jar:/Ja+
                          vaMail/activation.jar:/JavaMail/jt400.jar') +
                          PROP((user.timezone UTC) (java.version 1.3))
             /* Specify this parameter for V5R2 or later */
             /*           OUTPUT(*PRINT)                 */
             MONMSG     MSGID(JVA0000) EXEC(DO)
             RCVMSG     PGMQ(*SAME (* QJVAUTLJVM)) MSGTYPE(*EXCP) +
                          RMV(*NO) MSG(&MSG) MSGDTA(&MSGDTA) +
                          MSGID(&MSGID)
             CHGVAR     VAR(&RTNCDE) VALUE(%BIN(&MSGDTA))
             IF         COND(&RTNCDE = 3) THEN(CHGVAR VAR(&MSG) +
                          VALUE('Exception during System.setOut.'))
             IF         COND(&RTNCDE = 4) THEN(CHGVAR VAR(&MSG) +
                          VALUE('No mail.'))
             IF         COND(&RTNCDE = 5) THEN(CHGVAR VAR(&MSG) +
                          VALUE('Cannot create mail directory.'))
             IF         COND(&RTNCDE = 6) THEN(CHGVAR VAR(&MSG) +
                          VALUE('Not all mail received.'))
             IF         COND(&RTNCDE = 7) THEN(CHGVAR VAR(&MSG) +
                          VALUE('Exception in main().'))
             IF         COND(&RTNCDE = 8) THEN(CHGVAR VAR(&MSG) +
                          VALUE('Cannot save part.'))
             IF         COND(&RTNCDE = 9) THEN(CHGVAR VAR(&MSG) +
                          VALUE('Failed 2o replace CID of HTML file.'))
             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(&MSG) +
                          MSGTYPE(*ESCAPE)
             GOTO       CMDLBL(EXIT)
             ENDDO
             GOTO       CMDLBL(NOERROR)

             /* Unexpected error */
 ERROR:      CHGVAR     VAR(&MSG) VALUE('Unexpected error in CL +
                          program.')
             SNDPGMMSG  MSGID(CPF9897) MSGF(QCPFMSG) MSGDTA(&MSG) +
                          MSGTYPE(*ESCAPE)
             GOTO       CMDLBL(EXIT)

             /* Normal end */
 NOERROR:    CHGVAR     VAR(&MSG) VALUE('Mail received.')
             SNDPGMMSG  MSGID(CPI8871) MSGF(QCPFMSG) MSGDTA(&MSG) +
                          MSGTYPE(*INFO)
             GOTO       CMDLBL(EXIT)

 EXIT:       ENDPGM
