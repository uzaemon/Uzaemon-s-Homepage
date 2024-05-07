/* REXX procedure to make ILE-RPG SMTP client */
SAY " "
SAY "Start SNDM compilation."
SAY " You must have authority to exec CRTxxx."
SAY " Confirm that you have IBM supplied library QSYSINC."
SAY " This procedure changes job's CURLIB before compilation."
SAY " "
SAY "    * * * * * * * * * * * * * * * * * * * * * * "
SAY " "
/* SAY "Input object library name."    */
/* PULL OLIB                           */
OLIB = 'SMTP'
/* PULL SLIB                           */
SLIB = 'SMTP'
/* PULL OPTION                         */
OPTION = 0
/* PULL TGTRLS                         */
TGTRLS = '*CURRENT'
/* TGTRLS = 'V3R7M0'                   */

IF OPTION = 0 THEN DO
  DEBUG = "*NONE"
  OPT = "*FULL"
END
IF OPTION = 1 THEN DO
  DEBUG = "*ALL"
  OPT = "*NONE"
END

SAY " "
/* OUT = '*PRINT'                      */
MO.1 = 'SNDM'
MO.2 = 'CDATE'
MO.3 = 'FD_'
MO.4 = 'GETERRINFO'
MO.5 = 'GETFILENAM'
MO.6 = 'GETJOBINFO'
MO.7 = 'GETPFINFO'
MO.8 = 'PREPAREUS'
MO.9 = 'SNDPM'

SAY 'Change current library to "SMTP"...'
  'CHGCURLIB CURLIB(&SLIB)'
  SAY "  result->" RC

SAY " "
SAY 'Start creating modules for SNDM...'
DO I = 1 TO 9
  SAY '  creating module 'MO.I'...'
  'CRTRPGMOD MODULE(QTEMP/'MO.I') SRCFILE(&SLIB/QRPGLESRC)',
  'OPTION(*SHOWCPY) DBGVIEW(&DEBUG) OPTIMIZE(&OPT) TGTRLS(&TGTRLS)'
  SAY "  result->" RC
END
  SAY 'Creating main program (SNDM)...'
'CRTPGM PGM(&OLIB/SNDM) MODULE(',
'QTEMP/'MO.1' QTEMP/'MO.2' QTEMP/'MO.3' QTEMP/'MO.4' QTEMP/'MO.5' ',
'QTEMP/'MO.6' QTEMP/'MO.7' QTEMP/'MO.8' QTEMP/'MO.9' ',
') ENTMOD(QTEMP/'MO.1') BNDDIR(QSYS/QC2LE) TGTRLS(&TGTRLS)'
  SAY "  result->" RC
SAY " "
SAY 'Start creating command ...'
  SAY '  creating pnlgrp...'
  'CRTPNLGRP PNLGRP(&OLIB/SNDMHLP) SRCFILE(&SLIB/QCMDSRC)'
  SAY "  result->" RC
  SAY '  creating command...'
  'CRTCMD CMD(&OLIB/SNDM) PGM(SNDM) SRCFILE(&SLIB/QCMDSRC) ',
  'HLPPNLGRP(&OLIB/SNDMHLP) HLPID(*CMD)'
  SAY "  result->" RC

SAY " "
SAY "Compile finished. Confirm error(s) if exists."
SAY " "
