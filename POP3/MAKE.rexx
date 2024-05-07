/* Utility compile REXX proc */
SAY " "
SAY "Start RCVM frontend compilation."
SAY " You must have authority to create objects."
SAY " "
SAY "    * * * * * * * * * * * * * * * * * * * * * * "
SAY " "
/* SAY "Input source library name."    */
/* PULL SLIB                           */
SLIB = 'POP3'
/* SAY "Input source file name."    */
/* PULL SFIL                           */
SFIL = 'SOURCE'
/* SAY "Input object library name."    */
/* PULL OLIB                           */
OLIB = 'POP3'
OUT = "*PRINT"
DEBUG = "*ALL"
TGT = '*CURRENT'

'ADDLIBLE LIB(&OLIB)'
SAY 'creating CL program ...'
'CRTCLPGM PGM(&OLIB/RCVMAIL) SRCFILE(&SLIB/&SFIL)'
SAY "  result->" RC
SAY 'creating CMD definition ...'
'CRTCMD CMD(&OLIB/RCVM) PGM(&OLIB/RCVMAIL) SRCFILE(&SLIB/&SFIL)'
SAY "  result->" RC
SAY 'creating database files ...'
'CRTPF FILE(&OLIB/RCVMLOG) SRCFILE(&SLIB/&SFIL)'
SAY "  result->" RC
'CRTLF FILE(&OLIB/RCVMLOGL) SRCFILE(&SLIB/&SFIL)'
SAY "  result->" RC

SAY " "
SAY "Compile finished. Confirm error(s) if exists."
SAY " "
