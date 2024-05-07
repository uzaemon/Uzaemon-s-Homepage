             CMD        PROMPT('Create CSV format Stream File')

             PARM       KWD(FILE) TYPE(Q1) MIN(1) +
                          PROMPT('File')
 Q1:         QUAL       TYPE(*NAME) MIN(1)
             QUAL       TYPE(*NAME) DFT(*LIBL) SPCVAL((*LIBL) +
                          (*CURLIB)) PROMPT('Library')

             PARM       KWD(TOSTMF) TYPE(*PNAME) LEN(256) MIN(1) +
                          EXPR(*YES) CASE(*MIXED) PROMPT('To stream +
                          file')

             PARM       KWD(MBR) TYPE(*NAME) DFT(*FIRST) +
                          SPCVAL((*FIRST)) PROMPT('Member name')

             PARM       KWD(OVRWRT) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*YES) VALUES(*YES *NO) +
                          PROMPT('Overwrite existing stream file')

             PARM       KWD(DBFCCSID) TYPE(*DEC) LEN(5 0) DFT(*JOB) +
                          RANGE(1 65533) SPCVAL((*JOB 0) (*FILE +
                          -1)) PROMPT('Datebase file CCSID')

             PARM       KWD(STMFCCSID) TYPE(*DEC) LEN(5 0) +
                          DFT(*SYSTEM) RANGE(1 32767) +
                          SPCVAL((*SYSTEM 0)) PROMPT('Stream file +
                          code page')

             PARM       KWD(ADDINF) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                          DFT(*NONE) VALUES(*NONE *FLDNAM *COLHDG +
                          *BOTH) PMTCTL(*PMTRQS) PROMPT('Additional +
                          information')

             PARM       KWD(RCDERR) TYPE(*DEC) LEN(4) DFT(*ABORT) +
                          RANGE(1 9999) SPCVAL((*ABORT 0) (*IGNORE +
                          -1)) PMTCTL(*PMTRQS) PROMPT('Allow record +
                          error')

             PARM       KWD(RCDERRMSG) TYPE(*CHAR) LEN(7) RSTD(*YES) +
                          DFT(*BOTH) VALUES(*BOTH *STMF *SECLVL +
                          *NONE) PMTCTL(*PMTRQS) PROMPT('Record +
                          error message')

             PARM       KWD(RPLCHR) TYPE(*CHAR) LEN(1) +
                          DFT(*DOUBLEQUOTE) SPCVAL((*DOUBLEQUOTE +
                          '"') (*SPACE ' ')) PMTCTL(*PMTRQS) +
                          PROMPT('String delimiter replace char')

             PARM       KWD(FLDDLM) TYPE(*CHAR) LEN(1) DFT(*COMMA) +
                          REL(*NE '"') SPCVAL((*COMMA ',') (*SPACE +
                          ' ')) PMTCTL(*PMTRQS) PROMPT('Field +
                          delimiter')

             PARM       KWD(DEBUG) TYPE(*CHAR) LEN(4) RSTD(*YES) +
                          DFT(*NO) VALUES('*YES' *NO) +
                          PMTCTL(*PMTRQS) PROMPT('Debug print out')

