      **************************************************************************
      * Convert SCS/AFP spoold file to stream file
      *
      * Restrisction
      *   Cannot handle spool file larger than 16M.
      **************************************************************************
      * Compilation
      *   CRTRPGMOD MODULE(TIFFLIB/SPL2STMFRP) SRCFILE(TIFFLIB/QRPGLESRC)
      *   CRTPGM PGM(TIFFLIB/SPL2STMFRP) BNDSRVPGM(QWPZHPT1) BNDDIR(QC2LE)
     H* You may include some compile options here (H-spec).
      * Printer file for debug output
     FQPRINT    O    F  132        PRINTER USROPN OFLIND(*INOV)
      *****************************************************************
      * Program version
     D*version          C                   '0-02 99-11-04'
     D*version          C                   '0-03 00-03-18'
     Dversion          C                   '0-04 04-05-23'
      * Changed to initialize fields, QWPJSN "Job System Name", QWPSCD
      * "Splf Create Date" to "*ONLY", and QWPSCT "Splf Create Time" to blank.
      * ........................................................................
      * User space error code
     D/COPY QSYSINC/QRPGLESRC,QUSEC
      * Retreive error information .............................................
     Dgeterrinfo       PR           128
      * Convert numeric to char ................................................
     Dn2c              PR            12
     D numeric                       10I 0 VALUE
      * Qual to string .........................................................
     Dq2s              PR            21
     D qual                          20    VALUE
      * Send program message ...................................................
     Dsndpm            PR
     D msg_data                     256    VALUE
     D msg_t                          1    VALUE
      * Debug print out ........................................................
     Ddp               PR
     D instr                        132    VALUE
      * Host print transform API ...............................................
     Dhpt              PR                  EXTPROC('QwpzHostPrintTransform')
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
      * Option specific input/output information
     D/COPY QSYSINC/QRPGLESRC,QWPZ
      * variables for Host Print Transform API
     Dhptopt           S              9B 0
     Dhptosilen        S              9B 0 INZ(%LEN(QWPPTOSI))
     Dhptsplbuflen     S              9B 0
     Dhptosolen        S              9B 0 INZ(%LEN(QWPPTOSO))
     Dhptosolena       S              9B 0
     Dxbufspc_p        S               *
     Dhptxbuflen       S              9B 0 INZ(200000)
     Dhptxbuflena      S              9B 0
      * Size of user space
     Dspc_size         S              9B 0
      * Stream file APIs .......................................................
     Dunlink           PR             9B 0 EXTPROC('unlink')
     D                                 *   VALUE
     Dopen             PR            10I 0 EXTPROC('open')
     D                                 *   VALUE
     D                               10I 0 VALUE
     D                               10U 0 VALUE OPTIONS(*NOPASS)
     D                               10U 0 VALUE OPTIONS(*NOPASS)
     D O_CREAT         S             10I 0 INZ(8)
     D O_WRONLY        S             10I 0 INZ(2)
     D O_TRUNC         S             10I 0 INZ(64)
     D O_CODEPAGE      S             10I 0 INZ(8388608)
     D S_IRWXU         S             10I 0 INZ(448)
     D S_IROTH         S             10I 0 INZ(4)
     Dwrite            PR            10I 0 EXTPROC('write')
     D                               10I 0 VALUE
     D                                 *   VALUE
     D                               10I 0 VALUE
     Dclose            PR            10I 0 EXTPROC('close')
     D                               10I 0 VALUE
      *
     Dfd               S             10I 0
     Dbytesw           S             10I 0
     Dstmf             S            257
      * 'QSPOPNSP/QSPGETSP/QSPCLOSP' spool file APIs variables .................
     Dspl_hdl          S              9B 0
     Dspl_nbr_b        S              9B 0
     Dspl_bufnbr       S              9B 0
      * Get Spooled File Data ..................................................
     D/COPY QSYSINC/QRPGLESRC,QSPGETSP
     Dgen_hdr          S            128    BASED(splspc_p)
     Dbuf_inf          S             40    BASED(bufp)
     Dbuf_inf2         S             44    BASED(bufp2)
     Dsplbuf           S           5000    BASED(splbuf_p)
      * Misc ...................................................................
     Dmsg_data         S            256
     Dstart_time       S               Z
     Dend_time         S               Z
      * Debug printout string ..................................................
     Dpm               S            132
      /EJECT
      **************************************************************************
      * Main
      *****************************************************************
      * Initialize
     C                   EXSR      #INIT
      * Prepare user space
     C                   EXSR      #PPRUS
      * Retrieve spool file
     C                   EXSR      #RTVSP
      * Create stream file
     C                   EXSR      #OPEN
      * Perform HTP
      *   initialize HPT
     C                   EVAL      hptopt = 10
     C                   EXSR      #HPT
      *   process file
     C                   EVAL      hptopt = 20
     C                   EXSR      #HPT
      *   set pointer to first buffer
     C                   EVAL      bufp = splspc_p + QSPOFB
      *   loop thru buffer
     C                   DO        QSPBRTN01
      *     retrieve 'Buffer information'
     C                   EVAL      QSPSPFRB = buf_inf
      *     set pointer to 'offset to general information buffer'
     C                   EVAL      bufp2 = splspc_p + QSPOGI
      *     retrieve 'General data (information buffer)'
     C                   EVAL      QSPSPFRG = buf_inf2
      *     transform data
     C                   EVAL      hptopt = 30
     C                   EXSR      #HPT
      *     increment pointer by 'length of all buffer information'
     C                   EVAL      bufp = bufp + QSPLBI
     C                   END
      *   end file
     C                   EVAL      hptopt = 40
     C                   EXSR      #HPT
      *   terminate HTP
     C                   EVAL      hptopt = 50
     C                   EXSR      #HPT
      *   Close stream file
     C                   EXSR      #CLOSE
      * End program
     C                   SETON                                        LR
     C                   RETURN
      /EJECT
      **************************************************************************
      * Subroutines
      *****************************************************************
      * Initialize
     C     #INIT         BEGSR
      *
     C     *ENTRY        PLIST
     C                   PARM                    spl_name         10        I
     C                   PARM                    stmf_path       128        I
     C                   PARM                    wscst            20        I
     C                   PARM                    spl_job          26        I
     C                   PARM                    spl_nbr           4 0      I
     C                   PARM                    stmf_replace      4        I
     C                   PARM                    debug             4        I
      * Remember start time
     C                   TIME                    start_time
      * Debug mode?
     C     debug         COMP      '*YES'                                 90
     C   90              OPEN      QPRINT
     C   90              CALLP     dp('Debug mode.  ' +
     C                                      %TRIM(%EDITC(*DATE : 'Y')))
     C   90              CALLP     dp('*** SPL2STMF version ' +
     C                                      %TRIM(version) + ' ***')
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Input Parameters')
     C   90              CALLP     dp(' splf     : ' + spl_name)
     C   90              CALLP     dp(' stmf     : ' + stmf_path)
     C   90              CALLP     dp(' wscst    : ' + q2s(wscst))
     C   90              CALLP     dp(' spl_job  : ' + spl_job)
     C   90              CALLP     dp(' spl_nbr  : ' + n2c(spl_nbr))
     C   90              CALLP     dp(' replace  : ' + stmf_replace)
      * Set APIs not to raise an exception
      *   System API Programming Version 4 SC41-5800-00
      *   2.4.3.2 Receiving the Error Code without the Exception Data--Example
     C                   Z-ADD     16            QUSBPRV
      *
     C                   ENDSR
      *****************************************************************
      * Create user space to retrieve spool data
     C     #PPRUS        BEGSR
     C                   EVAL      splspc_name = 'QSPGETSP  QTEMP'
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Create User Space ' + q2s(splspc_name))
      *
     C                   CALL      'QUSCRTUS'
     C                   PARM                    splspc_name      20        I
     C                   PARM      *BLANKS       spc_attr         10        I
     C                   PARM      1024          spc_size                   I
     C                   PARM      X'00'         spc_init          1        I
     C                   PARM      '*CHANGE'     spc_aut          10        I
     C                   PARM      'SPL2STMF'    spc_text         50        I
     C                   PARM      '*NO'         spc_replace      10        I
     C                   PARM                    QUSEC                      I/O
     C                   PARM      '*USER'       spc_domain       10        I
      *
     C                   IF        QUSBAVL > 0
     C                   IF        QUSEI =  'CPF9870'
     C   90              CALLP     dp(' User Space ' + %TRIMR(q2s(splspc_name))
     C                                + ' already exists.')
     C                   ELSE
     C                   EVAL      msg_data = 'API QUSCRTUS failed : ' + QUSEI
     C                   EXSR      #QUIT
     C                   END
     C                   ELSE
     C   90              CALLP     dp(' API QUSCRTUS successful.')
     C                   END
      *   Retrieve pointer to user space
     C                   CALL      'QUSPTRUS'
     C                   PARM                    splspc_name                I
     C                   PARM                    splspc_p                   O
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   EVAL      msg_data = 'API QUSPTRUS failed : ' + QUSEI
     C                   EXSR      #QUIT
     C                   END
     C   90              CALLP     dp(' API QUSPTRUS successful.')
      * Create user space for translation
     C                   EVAL      xbufspc_name = 'QWPZHPT1  QTEMP'
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Create User Space ' + q2s(xbufspc_name))
      *
     C                   CALL      'QUSCRTUS'
     C                   PARM                    xbufspc_name     20        I
     C                   PARM      *BLANKS       spc_attr                   I
     C                   PARM      200000        spc_size                   I
     C                   PARM      X'00'         spc_init                   I
     C                   PARM      '*CHANGE'     spc_aut                    I
     C                   PARM      'SPL2STMF'    spc_text                   I
     C                   PARM      '*NO'         spc_replace                I
     C                   PARM                    QUSEC                      I/O
     C                   PARM      '*USER'       spc_domain                 I
      *
     C                   IF        QUSBAVL > 0
     C                   IF        QUSEI =  'CPF9870'
     C   90              CALLP     dp(' User Space ' + %TRIMR(q2s(xbufspc_name))
     C                                + ' already exists.')
     C                   ELSE
     C                   EVAL      msg_data = 'API QUSCRTUS failed : ' + QUSEI
     C                   EXSR      #QUIT
     C                   END
     C                   ELSE
     C   90              CALLP     dp(' API QUSCRTUS successful.')
     C                   END
      *   Retrieve pointer to user space
     C                   CALL      'QUSPTRUS'
     C                   PARM                    xbufspc_name               I
     C                   PARM                    xbufspc_p                  O
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   EVAL      msg_data = 'API QUSPTRUS failed : ' + QUSEI
     C                   EXSR      #QUIT
     C                   END
     C   90              CALLP     dp(' API QUSPTRUS successful.')
      *
     C                   ENDSR
      *****************************************************************
      * Retrieve spool file
     C     #RTVSP        BEGSR
      *
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Retrieve spool file.')
      * Open spool file
     C                   CALL      'QSPOPNSP'
     C                   PARM                    spl_hdl                    O
     C                   PARM                    spl_job          26        I
     C                   PARM      *BLANKS       spl_ijobi        16        I
     C                   PARM      *BLANKS       spl_ispli        16        I
     C                   PARM                    spl_name                   I
     C                   PARM      spl_nbr       spl_nbr_b                  I
     C                   PARM      -1            spl_bufnbr                 I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   EVAL      msg_data = 'API QSPOPNSP failed : ' + QUSEI
     C                   EXSR      #QUIT
     C                   END
     C   90              CALLP     dp(' API QSPOPNSP successful. spl_hdl = ' +
     C                                                          n2c(spl_hdl))
      * Get spool data
     C                   CALL      'QSPGETSP'
     C                   PARM                    spl_hdl                    I
     C                   PARM                    splspc_name                I
     C                   PARM      'SPFR0200'    fmt_name          8        I
     C                   PARM      -1            spl_bufnbr                 I
     C                   PARM      '*WAIT     '  spl_end          10        I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   EVAL      msg_data = 'API QSPGETSP failed : ' + QUSEI
     C                   EXSR      #QUIT
     C                   END
     C   90              CALLP     dp(' API QSPGETSP successful.')
      *   retrieve 'General header'
     C                   EVAL      QSPSPFRH = gen_hdr
     C   90              CALLP     dp(' generic header :'
     C                              + ' level = ' + QSPSFILL
     C                              + ' format = ' + QSPFN
     C                              + ' complete = ' + QSPICI
     C                              + ' sizeofUS = ' + %TRIMR(n2c(QSPUSU))
     C                              + ' reqbuf = ' + %TRIMR(n2c(QSPBR00))
     C                              + ' retbuf = '+%TRIMR(n2c(QSPBRTN01)))
      * Close spool file
     C                   CALL      'QSPCLOSP'
     C                   PARM                    spl_hdl                    I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   EVAL      msg_data = 'API QSPCLOSP failed : ' + QUSEI
     C                   EXSR      #QUIT
     C                   END
     C   90              CALLP     dp(' API QSPCLOSP successful.')
      *
     C                   IF        QSPICI <> 'C'
     C                   EVAL      msg_data = 'Cannot process sppoled file ' +
     C                                        'larger than 16M.'
     C                   EXSR      #QUIT
     C                   END
      *
     C                   ENDSR
      *****************************************************************
     C     #HPT          BEGSR
      * Clear option specific I/O information
     C                   CLEAR                   QWPPTOSI
     C                   CLEAR                   QWPPTOSO
      *   API parameters
     C                   EVAL      splbuf_p = splspc_p
     C                   EVAL      hptsplbuflen = 0
     C                   EVAL      hptosolena = 0
     C                   EVAL      hptxbuflena = 0
      * Set parameters for QWPZHPTR
     C                   SELECT
      * 10 = initialize HPT
      *                  (no further parameters required)
      * 20 = process file
     C                   WHEN      hptopt = 20
      *   Option specific input information
     C                   EVAL      QWPPDN = '*NONE'
     C                   EVAL      QWPJN = %SUBST(spl_job : 1 : 10)
     C                   EVAL      QWPUN = %SUBST(spl_job : 11 : 10)
     C                   EVAL      QWPJNBR = %SUBST(spl_job : 21 : 6)
     C                   EVAL      QWPSNBR = spl_nbr
     C                   EVAL      QWPSN = spl_name
     C                   EVAL      QWPRAD = '0'
     C                   EVAL      QWPWCOBJ = %SUBST(wscst : 1 : 10)
     C                   EVAL      QWPWCOL = %SUBST(wscst : 11 : 10)
     C                   EVAL      QWPMTM = '*WSCST'
      * Added for V5R2 API change 2004-05-23 -- start
     C                   EVAL      QWPJSN = '*ONLY'
     C                   EVAL      QWPSCD = '*ONLY'
     C                   EVAL      QWPSCT = '      '
      * Added for V5R2 API change 2004-05-23 -- end
      * 30 = transform data
     C                   WHEN      hptopt = 30
      *   Option specific input information
     C                   EVAL      QWPRAD = '0'
      *     Adjust page number
     C                   EVAL      QWPNBRCP = QSPNBRPE
     C                   ADD       QSPNBRPE      total_pages       9 0
     C                   IF        QSPBNBR = 1
     C                   IF        (QSPNBRPE > 0) AND (QSPLPC = 'Y')
     C                   SUB       1             QWPNBRCP
     C                   ENDIF
     C                   ELSE
     C                   IF        QSPLPC = 'N'
     C                   ADD       1             QWPNBRCP
     C                   ENDIF
     C                   ENDIF
      *   API parameters
     C                   EVAL      splbuf_p = splspc_p + QSPOPD00
     C                   EVAL      hptsplbuflen = QSPSPD00
      * 40 = end file
      *                  (no further parameters required)
      * 50 = terminate HPT
      *                  (no further parameters required)
     C                   ENDSL
      * perform HPT
     C                   EXSR      #EXHPT
     C                   IF        hptopt = 30
      *   Increment counter
     C                   ADD       1             counter           7 0
     C                   IF        counter >= 5
     C                   CALLP     sndpm(%TRIMR(n2c(total_pages)) +
     C                                   ' pages processed. (' + %TRIMR(
     C                                   n2c((QSPBNBR / QSPBRTN01) * 100)) +
     C                                   '%)' : 'S')
     C                   Z-ADD     0             counter
     C                   ENDIF
     C                   ENDIF
      * debug information print out
     C   90              CALLP     dp('hptopt = ' + n2c(hptopt))
     C   90              SELECT
     C                   WHEN      hptopt = 10
     C                   CALLP     dp(' QUSBAVL = ' + %TRIMR(n2c(QUSBAVL)))
     C                   WHEN      hptopt = 20
     C                   CALLP     dp(' QUSBAVL = ' + %TRIMR(n2c(QUSBAVL)) +
     C                             ' splbuflen = ' + %TRIMR(n2c(hptsplbuflen)) +
     C                             ' hptosolena = ' + %TRIMR(n2c(hptosolena)) +
     C                             ' hptxbuflena = ' + n2c(hptxbuflena))
     C                   CALLP     dp('  Option specific input information /' +
     C                             ' device = ''' + %TRIM(QWPPDN) + '''' +
     C                             ' job = ' + %TRIM(QWPJN) + '/' +
     C                                  %TRIM(QWPUN) + '/' + %TRIM(QWPJNBR))
     C                   CALLP     dp('   spoolfile = ''' + %TRIM(QWPSN) + ''''
     C                             + ' spoolNo = ' + %TRIMR(n2c(QWPSNBR)) +
     C                             ' pages = ' + %TRIMR(n2c(QWPNBRCP)) +
     C                             ' WSCST = ' + '''' + %TRIM(QWPWCOL) + '/' +
     C                                           %TRIM(QWPWCOBJ) + '''' +
     C                             ' Mmodel = ''' + %TRIM(QWPMTM) + '''')
     C                   CALLP     dp('  Option specific output information /' +
     C                             ' transform file = ' + QWPTFIL +
     C                             ' pass data = ' + QWPPID)
     C                   WHEN      hptopt = 30 or hptopt = 40
     C                   IF        hptopt = 30
     C                   CALLP     dp(' buffer info :' +
     C                             ' No = ' + %TRIMR(n2c(QSPBNBR)) +
     C                             ' len = '+%TRIMR(n2c(QSPLBI)) +
     C                             ' numentry = ' + %TRIMR(n2c(QSPNBRPE)) +
     C                             ' offset = ' + %TRIMR(n2c(QSPOPD00)) +
     C                             ' size = ' + %TRIMR(n2c(QSPSPD00)) +
     C                             ' / page info : LastPageCont = ' + QSPLPC)
     C                   ENDIF
     C                   CALLP     dp(' QUSBAVL = ' + %TRIMR(n2c(QUSBAVL)) +
     C                             ' splbuflen = ' + %TRIMR(n2c(hptsplbuflen)) +
     C                             ' hptosolena = ' + %TRIMR(n2c(hptosolena)) +
     C                             ' hptxbuflena = ' + %TRIMR(n2c(hptxbuflena))+
     C                             ' pages(OSI) = ' + %TRIMR(n2c(QWPNBRCP)) +
     C                             ' done(OSO) = ' + QWPDTFIL)
     C                   WHEN      hptopt = 50
     C                   CALLP     dp(' QUSBAVL = ' + %TRIMR(n2c(QUSBAVL)) +
     C                             ' hptxbuflena = ' + %TRIMR(n2c(hptxbuflena)))
     C                   ENDSL
      *
     C                   IF        QUSBAVL > 0
      * retry hpt if CPF6DF5 (process option parameter not valid)
     C  N99              IF        (QUSEI  = 'CPF6DF5') AND (hptopt = 10)
     C   90              CALLP     dp('** hpt sequence error detected **')
      *   avoid loop
     C                   SETON                                        99
      *   terminate HTP then try again
     C   90              CALLP     dp('** reset hpt - process option 50 **')
     C                   EVAL      hptopt = 50
     C                   EXSR      #EXHPT
     C   90              CALLP     dp('** retry hpt - process option 10 **')
     C                   EVAL      hptopt = 10
     C                   CLEAR                   QWPPTOSI
     C                   CLEAR                   QWPPTOSO
     C                   EXSR      #EXHPT
     C                   ELSE
      * reset hpt and exit
     C                   EVAL      msg_data = 'API QwpzHostPrintTransform ' +
     C                               'failed : ' + QUSEI + ' hptopt = ' +
     C                               %TRIM(%EDITC(hptopt:'J'))
     C   90              CALLP     dp('** reset hpt - process option 50 **')
     C                   EVAL      hptopt = 50
     C                   EXSR      #EXHPT
     C                   EXSR      #QUIT
     C                   ENDIF
     C                   ENDIF
      * write data to stream file
     C                   IF        hptxbuflena > 0
     C                   EVAL      bytesw = write(fd : xbufspc_p : hptxbuflena)
     C                   IF        bytesw <> hptxbuflena
     C                   EVAL      msg_data = 'write() failed. ' + geterrinfo
     C                   EXSR      #QUIT
     C                   ENDIF
     C                   ENDIF
      *
     C                   ENDSR
      *****************************************************************
     C     #EXHPT        BEGSR
      * perform HPT
     C                   CALLP     hpt(%ADDR(hptopt) :
     C                                 %ADDR(QWPPTOSI) :
     C                                 %ADDR(hptosilen) :
     C                                 splbuf_p :
     C                                 %ADDR(hptsplbuflen) :
     C                                 %ADDR(QWPPTOSO) :
     C                                 %ADDR(hptosolen) :
     C                                 %ADDR(hptosolena) :
     C                                 xbufspc_p :
     C                                 %ADDR(hptxbuflen) :
     C                                 %ADDR(hptxbuflena) :
     C                                 %ADDR(QUSEC))
      *
     C                   ENDSR
      *****************************************************************
     C     #OPEN         BEGSR
      *
     C                   EVAL      stmf = %TRIM(stmf_path) + X'00'
      * stream file exists?
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Checking output stream file.')
     C   90              CALLP     dp(' file name = ' + %STR(%ADDR(stmf)))
     C                   EVAL      fd = open(%ADDR(stmf) : 1)
      *   yes
 I   C                   IF        fd <> -1
     C   90              CALLP     dp(' stream file already exists.')
  I  C                   IF        -1 = close(fd)
     C                   EVAL      msg_data = 'close() failed. ' + geterrinfo
     C                   EXSR      #QUIT
  E  C                   ENDIF
      *     replace(*yes) specified?
  I  C                   IF        stmf_replace = '*YES'
   I C                   IF        -1 = unlink(%ADDR(stmf))
     C                   EVAL      msg_data = 'unlink() failed. ' + geterrinfo
     C                   EXSR      #QUIT
   X C                   ELSE
     C   90              CALLP     dp(' unlink() successful.')
     C                   CALLP     sndpm('Stream file ' + %TRIMR(stmf_path) +
     C                                   ' removed.' : 'D')
   E C                   ENDIF
  X  C                   ELSE
     C                   EVAL      msg_data = 'file already exists.'
     C                   EXSR      #QUIT
  E  C                   ENDIF
 X   C                   ELSE
     C   90              CALLP     dp(' stream file not found.')
 E   C                   ENDIF
      * open(create) stream file
     C                   EVAL      fd = open(%ADDR(stmf)
     C                               : O_CREAT + O_WRONLY + O_TRUNC + O_CODEPAGE
     C                               : S_IRWXU + S_IROTH
     C                               : 819)
     C                   IF        fd = -1
     C                   EVAL      msg_data = 'open() failed. ' + geterrinfo
     C                   EXSR      #QUIT
     C                   ENDIF
     C   90              CALLP     dp('Stream file opened.')
     C   90              CALLP     dp(' ')
      *
     C                   ENDSR
      *****************************************************************
     C     #CLOSE        BEGSR
      * Clear status message
     C                   CALLP     sndpm(' ' : 'X')
      * Close stream file
     C                   IF        -1 = close(fd)
     C                   EVAL      msg_data = 'close() failed. ' + geterrinfo
     C                   EXSR      #QUIT
     C                   ENDIF
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Stream file closed.')
     C   90              CALLP     dp(' ')
      *
     C                   TIME                    end_time
     C     end_time      SUBDUR    start_time    dur:*S            9 0
     C     dur           DIV       60            dur_min           7 0
     C                   MVR                     dur_sec           2 0
     C                   EVAL      msg_data = 'execution time ' +
     C                                %TRIMR(n2c(dur_min)) + ' min ' +
     C                                %TRIMR(n2c(dur_sec)) + ' sec, ' +
     C                                'total pages = ' + n2c(total_pages)
     C   90              CALLP     dp(msg_data)
     C   90              CALLP     dp('SPL2STMF completed successfully.')
     C                   CALLP     sndpm('Stream file generated. ' +
     C                                   msg_data : 'C')
      *
     C                   ENDSR
      *****************************************************************
     C     #QUIT         BEGSR
      * abort
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Fatal error : ' + msg_data)
     C                   CALLP     sndpm('Command failed. reason - ' + msg_data
     C                                   : 'E')
     C                   EVAL      *INLR = '1'
     C                   RETURN
      *
     C                   ENDSR
      *****************************************************************
     OQPRINT    E                           1
     O                       pm                 132
      /EJECT
      *****************************************************************
      * debug print out
     Pdp               B
     Ddp               PI
     D instr                        132    VALUE
      *
     Dcurtime          S               Z
     DcurtimeHMS       S               T
     C                   MOVEL     instr         pm
      *
      * get current time
     C                   TIME                    curtime
     C                   MOVE      curtime       curtimeHMS
     C                   MOVE      curtimeHMS    hms               6 0
     C                   EXTRCT    curtime:*MS   ms                6 0
     C                   EVAL      pm = %EDITW(hms : '  :  :  ') + '.' +
     C                                  %SUBST(%EDITW(ms : '0      ') : 2 : 3) +
     C                                  '|' + %TRIMR(pm)
     C
     C                   EXCEPT
      *
     C                   RETURN
      *
     Pdp               E
      *****************************************************************
     Pn2c              B
     Dn2c              PI            12
     D numeric                       10I 0 VALUE
      *
     C                   RETURN    %TRIML(%EDITC(numeric : 'P'))
     Pn2c              E
      *****************************************************************
     Pq2s              B
     Dq2s              PI            21
     D qual                          20    VALUE
      *
     C                   RETURN       %TRIMR(%SUBST(qual : 11 : 10)) + '/' +
     C                                %SUBST(qual :  1 : 10)
     Pq2s              E
      *****************************************************************
     Pgeterrinfo       B
     Dgeterrinfo       PI           128
      *
     Dgeterrno         PR              *   EXTPROC('__errno')
      *
     Dstrerror         PR              *   EXTPROC('strerror')
     D errno                         10I 0 VALUE
      *
     Derrnum           S             10I 0 BASED(errnum_p)
      *
     C                   EVAL      errnum_p = geterrno
      *
     C                   RETURN    %TRIM(%EDITC(errnum : '3')) + ' : ' +
     C                             %STR(strerror(errnum))
     Pgeterrinfo       E
      *****************************************************************
     Psndpm            B
     Dsndpm            PI
     D msg_data                     256    VALUE
     D msg_t                          1    VALUE
      *
     Dmsg_file         S             20    INZ('QCPFMSG   *LIBL')
     Dmsg_len          S              9B 0
     Dstack_ctr        S              9B 0 INZ(1)
      *
     C                   EVAL      msg_len = %LEN(%TRIMR(msg_data))
     C                   SELECT
      * escape message (fatal error) 512
     C                   WHEN      msg_t = 'E'
     C                   EVAL      msg_type = '*ESCAPE'
     C                   EVAL      msg_id = 'CPF9897'
     C                   EVAL      stack_ent = '*'
     C                   EVAL      stack_ctr = 3
      * daignostic message (information, warning) 132
     C                   WHEN      msg_t = 'D'
     C                   EVAL      msg_type = '*DIAG'
     C                   EVAL      msg_id = 'CPDA0FF'
     C                   EVAL      stack_ent = '*'
     C                   EVAL      stack_ctr = 0
      * completion message (normal end) 255
     C                   WHEN      msg_t = 'C'
     C                   EVAL      msg_type = '*COMP'
     C                   EVAL      msg_id = 'CPI8859'
     C                   EVAL      stack_ent = '*'
     C                   EVAL      stack_ctr = 3
      * status message
     C                   WHEN      msg_t = 'S'
     C                   EVAL      msg_type = '*STATUS'
     C                   EVAL      msg_id = 'CPF9898'
     C                   EVAL      stack_ent = '*EXT'
     C                   EVAL      stack_ctr = 1
      * clear status message
     C                   WHEN      msg_t = 'X'
     C                   EVAL      msg_type = '*STATUS'
     C                   EVAL      msg_id = 'CPI9801'
     C                   EVAL      stack_ent = '*EXT'
     C                   EVAL      stack_ctr = 1
      * invalid msg_t
     C                   OTHER
     C                   RETURN
     C                   ENDSL
      *
     C                   CALL      'QMHSNDPM'
     C                   PARM                    msg_id            7        I
     C                   PARM                    msg_file                   I
     C                   PARM                    msg_data                   I
     C                   PARM                    msg_len                    I
     C                   PARM                    msg_type         10        I
     C                   PARM                    stack_ent        10        I
     C                   PARM                    stack_ctr                  I
     C                   PARM                    msg_key           4        O
     C                   PARM                    QUSEC                      I/O
      *
     C                   RETURN
     Psndpm            E
