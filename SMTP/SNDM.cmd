             CMD        PROMPT('Send SMTP Mail')

             /* REQUIRED PARAMETERS */

             PARM       KWD(FROM) TYPE(FROM) MIN(1) PROMPT('Sender')
 FROM:       ELEM       TYPE(*CHAR) LEN(64) MIN(1) EXPR(*YES) +
                          PROMPT('Mail address')
             ELEM       TYPE(*CHAR) LEN(64) EXPR(*YES) +
                          PROMPT('Description')

             /* Maximum total number of recipients is 100. (RFC821 4.5.3) */
             PARM       KWD(TO) TYPE(TO) MIN(1) MAX(30) +
                          PROMPT('Recipient')
 TO:         ELEM       TYPE(*CHAR) LEN(64) EXPR(*YES) PROMPT('Mail +
                          address')
             ELEM       TYPE(*CHAR) LEN(64) EXPR(*YES) +
                          PROMPT('Description')
             ELEM       TYPE(*CHAR) LEN(4) RSTD(*YES) DFT(*TO) +
                          VALUES(*TO *CC *BCC) PROMPT('Recipient type')

             PARM       KWD(FILE) TYPE(FILE) MIN(1) +
                          PROMPT('Mail body file')
 FILE:       QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB)) EXPR(*YES) PROMPT('Library')

             /* OPTIONAL PARAMETERS */

             PARM       KWD(MBR) TYPE(*NAME) DFT(*FIRST) +
                          SPCVAL((*FIRST)) EXPR(*YES) PROMPT('Member')

             PARM       KWD(SUBJECT) TYPE(*CHAR) LEN(64) EXPR(*YES) +
                          PROMPT('Subject')

             PARM       KWD(ATTACHMENT) TYPE(*PNAME) LEN(64) MAX(5) +
                          EXPR(*YES) PROMPT('Attachment')

             PARM       KWD(REPLYTO) TYPE(REPLYTO) PROMPT('Reply-to')
 REPLYTO:    ELEM       TYPE(*CHAR) LEN(64) EXPR(*YES) PROMPT('Mail +
                          address')
             ELEM       TYPE(*CHAR) LEN(64) EXPR(*YES) +
                          PROMPT('Description')

             PARM       KWD(SMTPHOST) TYPE(*CHAR) LEN(64) +
                          DFT(*LOCALHOST) SPCVAL((*LOCALHOST)) +
                          EXPR(*YES) PROMPT('Mail (SMTP) server name')

             /* PMTRQS PARAMETERS */

             PARM       KWD(NONJISDBCS) TYPE(*CHAR) LEN(8) +
                          RSTD(*YES) DFT(*ABORT) VALUES(*ABORT +
                          *REPLACE) PMTCTL(*PMTRQS) +
                          PROMPT('Non-JIS character action')

             PARM       KWD(HDRCCSID) TYPE(*DEC) LEN(5 0) +
                          DFT(*DFTJOBCCSID) RANGE(37 61712) +
                          SPCVAL((*DFTJOBCCSID 0)) PMTCTL(*PMTRQS) +
                          PROMPT('Message header CCSID')

             PARM       KWD(DBFCCSID) TYPE(*DEC) LEN(5 0) +
                          DFT(*DFTJOBCCSID) RANGE(37 61712) +
                          SPCVAL((*DFTJOBCCSID 0) (*FILE -1)) +
                          PMTCTL(*PMTRQS) PROMPT('Database file CCSID')

             PARM       KWD(TMPDIR) TYPE(*PNAME) LEN(64) DFT('/TMP') +
                          PMTCTL(*PMTRQS) +
                          PROMPT('Work directory')

             PARM       KWD(DEBUG) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*NO *YES) PMTCTL(*PMTRQS) +
                          PROMPT('Debug print out')

