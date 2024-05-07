             CMD        PROMPT('Convert Spooled File to STMF')

             PARM       KWD(FILE) TYPE(*NAME) MIN(1) MAX(1) +
                          FILE(*OUT) EXPR(*YES) PROMPT('Spooled +
                          file name')

             PARM       KWD(TOSTMF) TYPE(*PNAME) LEN(256) MIN(1) +
                          EXPR(*YES) CASE(*MIXED) PROMPT('Stream +
                          file path name')

             PARM       KWD(WSCST) TYPE(Q1) MIN(1) MAX(1) +
                          PROMPT('Workstation Customizing Object')
 Q1:         QUAL       TYPE(*NAME) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB)) MIN(0) EXPR(*YES) +
                          PROMPT('Library')

             PARM       KWD(JOB) TYPE(Q2) DFT(*) SNGVAL((*)) MAX(1) +
                          PROMPT('Job name')
 Q2:         QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES) +
                          PROMPT('User')
             QUAL       TYPE(*CHAR) LEN(6) RANGE(000000 999999) +
                          SPCVAL(('      ')) EXPR(*YES) +
                          PROMPT('Number')

             PARM       KWD(SPLNBR) TYPE(*DEC) LEN(4) DFT(*LAST) +
                          RANGE(1 9999) SPCVAL((*ONLY 0) (*LAST +
                          -1)) PROMPT('Spooled file number')

             PARM       KWD(REPLACE) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) +
                          PROMPT('Replace stream file')

             PARM       KWD(DEBUG) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES(*YES *NO) PMTCTL(*PMTRQS) +
                          PROMPT('Enable debug print out')
