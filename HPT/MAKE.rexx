/* REXX procedure to make SPL2STMF command */
SAY " "
SAY "Start SPL2STMF compilation."
SAY " You must have authority to exec CRTxxx."
SAY " "
SAY "    * * * * * * * * * * * * * * * * * * * * * * "
SAY " "
/* SAY "Input object library name."    */
/* PULL OLIB                           */
OLIB = 'HPT'
/* PULL SLIB                           */
SLIB = 'HPT'
/* PULL OPTION                         */
OPTION = 1
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

SAY 'Start creating SPL2STMF command...'
  SAY '  creating main program module SPL2STMFRP...'
  'CRTRPGMOD MODULE(QTEMP/SPL2STMFRP) SRCFILE(&SLIB/SOURCE) ',
  'DBGVIEW(&DEBUG) OPTIMIZE(&OPT) TGTRLS(&TGTRLS)'
  SAY "  result->" RC
  SAY '  creating main program SPL2STMFRP...'
  'CRTPGM PGM(&OLIB/SPL2STMFRP) MODULE(QTEMP/SPL2STMFRP) ',
  'BNDSRVPGM(QWPZHPT1) BNDDIR(QC2LE) TGTRLS(&TGTRLS)'
  SAY "  result->" RC
  SAY '  creating pnlgrp...'
  'CRTPNLGRP PNLGRP(&OLIB/SPL2STMFHL) SRCFILE(&SLIB/SOURCE)'
  SAY "  result->" RC
  SAY '  creating command...'
  'CRTCMD CMD(&OLIB/SPL2STMF) PGM(SPL2STMFRP) SRCFILE(&SLIB/SOURCE) ',
  'HLPPNLGRP(&OLIB/SPL2STMFHL) HLPID(*CMD)'
  SAY "  result->" RC

SAY " "
SAY "Compile finished. Confirm error(s) if exists."
SAY " "
