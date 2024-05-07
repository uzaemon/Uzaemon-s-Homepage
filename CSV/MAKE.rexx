/* REXX procedure to make CRTCSVF command */
SAY " "
SAY "Start CRTCSVF compilation."
SAY " You must have authority to exec CRTxxx."
SAY " "
SAY "    * * * * * * * * * * * * * * * * * * * * * * "
SAY " "
/* SAY "Input object library name."    */
/* PULL OLIB                           */
OLIB = 'CSV'
/* PULL SLIB                           */
SLIB = 'CSV'
/* PULL OPTION                         */
OPTION = 0
/* PULL TGTRLS                         */
TGTRLS = 'V5R2M0'
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
/* D1 = 'SHORTREC'                     */

SAY 'Start creating CRTCSVF command...'
  SAY '  creating CL program CRTCSVFCLP...'
  'CRTCLPGM PGM(&OLIB/CRTCSVFCLP) SRCFILE(&SLIB/SOURCE) TGTRLS(&TGTRLS)'
  SAY "  result->" RC
  SAY '  creating main program module CRTCSVFRPG...'
  'CRTRPGMOD MODULE(QTEMP/CRTCSVFRPG) SRCFILE(&SLIB/SOURCE) ',
  'DBGVIEW(&DEBUG) OPTIMIZE(&OPT) TGTRLS(&TGTRLS) ',
  'DEFINE(&D1) BNDDIR(QC2LE)'
  SAY "  result->" RC
  SAY '  creating main program CRTCSVFRPG...'
  'CRTPGM PGM(&OLIB/CRTCSVFRPG) MODULE(QTEMP/CRTCSVFRPG) ',
  'BNDDIR(QC2LE) DETAIL(*BASIC) TGTRLS(&TGTRLS)'
  SAY "  result->" RC
  SAY '  creating pnlgrp...'
  'CRTPNLGRP PNLGRP(&OLIB/CRTCSVFHLP) SRCFILE(&SLIB/SOURCE)'
  SAY "  result->" RC
  SAY '  creating command...'
  'CRTCMD CMD(&OLIB/CRTCSVF) PGM(CRTCSVFCLP) SRCFILE(&SLIB/SOURCE) ',
  'HLPPNLGRP(&OLIB/CRTCSVFHLP) HLPID(*CMD)'
  SAY "  result->" RC

SAY " "
SAY "Compile finished. Confirm error(s) if exists."
SAY " "
