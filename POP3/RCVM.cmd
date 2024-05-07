             CMD        PROMPT('Receive POP3 Mail')

             /* REQUIRED PARAMETERS */

             PARM       KWD(ACCOUNT) TYPE(*CHAR) LEN(10) MIN(1) +
                          EXPR(*YES) CASE(*MIXED) PROMPT('Mail +
                          account')

             PARM       KWD(PASSWORD) TYPE(*CHAR) LEN(128) MIN(1) +
                          CASE(*MIXED) DSPINPUT(*NO) +
                          PROMPT('Password for the mail account')

             /* OPTIONAL PARAMETERS */

             PARM       KWD(MAILSERVER) TYPE(*CHAR) LEN(64) +
                          DFT(*LOCALHOST) SPCVAL((*LOCALHOST +
                          'localhost')) PROMPT('POP3 server name')

             PARM       KWD(TIMEOUT) TYPE(*DEC) LEN(3 0) DFT(30) +
                          RANGE(1 999) PROMPT('Communication +
                          timeout (sec)')

             PARM       KWD(HOMEDIR) TYPE(*PNAME) LEN(128) +
                          DFT(*HOME) SPCVAL((*HOME *HOME)) +
                          EXPR(*YES) CASE(*MIXED) PROMPT('Directory +
                          to store mail')

             PARM       KWD(LEAVEMAIL) TYPE(*CHAR) LEN(5) RSTD(*YES) +
                          DFT(*NO) SPCVAL((*YES 'true') (*NO +
                          'false')) PROMPT('Leave mail after received')

             /* PMTRQS PARAMETERS */

             PARM       KWD(REPLACECID) TYPE(*CHAR) LEN(5) +
                          RSTD(*YES) DFT(*YES) SPCVAL((*YES 'true') +
                          (*NO 'false')) PROMPT('Replace cid in +
                          HTML part')

             PARM       KWD(RCVLOGTYPE) TYPE(*CHAR) LEN(5) +
                          RSTD(*YES) DFT(*RDB) SPCVAL((*NONE +
                          'none') (*RDB 'rdb') (*STMF 'file')) +
                          PROMPT('Receive mail log file')

 CTL1:       PMTCTL     CTL(RCVLOGTYPE) COND((*NE 'none'))

             PARM       KWD(RCVLOGFILE) TYPE(*PNAME) LEN(128) +
                          DFT('rcvmlog') EXPR(*YES) CASE(*MIXED) +
                          PMTCTL(CTL1) PROMPT('Mail recieve log +
                          file name')

 CTL2:       PMTCTL     CTL(RCVLOGTYPE) COND((*EQ 'rdb'))

             PARM       KWD(RDBDIRE) TYPE(*CHAR) LEN(18) +
                          DFT(*SYSNAME) CASE(*MIXED) PMTCTL(CTL2) +
                          PROMPT('RDB directory entry')

             PARM       KWD(RDBUSERID) TYPE(*CHAR) LEN(10) +
                          DFT(*ACCOUNT) CASE(*MIXED) PMTCTL(CTL2) +
                          PROMPT('UserID for RDB')

             PARM       KWD(RDBPASS) TYPE(*CHAR) LEN(128) +
                          CASE(*MIXED) DSPINPUT(*NO) PMTCTL(CTL2) +
                          PROMPT('Password for RDB')

             PARM       KWD(DEBUG) TYPE(*CHAR) LEN(9) RSTD(*YES) +
                          DFT(*NO) SPCVAL((*NO 'false') (*PGM +
                          'rcvmail') (*JAVAMAIL 'javamail') (*BOTH +
                          'both')) PMTCTL(*PMTRQS) PROMPT('Debug +
                          output type')

             PARM       KWD(DEBUGFILE) TYPE(*PNAME) LEN(128) +
                          DFT('rcvmdebug.txt') EXPR(*YES) +
                          CASE(*MIXED) PMTCTL(*PMTRQS) +
                          PROMPT('Debug output stream file')

