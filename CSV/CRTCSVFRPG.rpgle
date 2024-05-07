      *****************************************************************
      * CRTCSVF command - Create CSV format file
      **************************************************************************
      * use REXX procedure 'MAKE' to compile
     H* You may include some compile options here (H-spec).
      *****************************************************************
      /IF DEFINED(SHORTREC)
     FIN        IP   F  999        DISK    INFDS(iofeedback)
      /ELSE
     FIN        IP   F 9999        DISK    INFDS(iofeedback)
      /ENDIF
      * Printer file for debug output
     FQPRINT    O    F  132        PRINTER USROPN OFLIND(*INOV)
      *****************************************************************
      * Program version
     D*version          C                   '2-11 2000-02-18'
     D*version          C                   '2-12 2000-03-23'
     D*version          C                   '2-13 2001-08-22'
     D*version          C                   '2-14 2001-12-09'
     Dversion          C                   '2-15 2011-08-14'
      * User space error code
     D/COPY QSYSINC/QRPGLESRC,QUSEC
      * File I/O feedback
     Diofeedback       DS
     D currec                397    400B 0
      * Program status data structure
     Dpsds            SDS
     D pgm_proc                1     10
     D pgm_error         *STATUS
     D pgm_line               21     28S 0
      *****************************************************************
      * Procedures definition
      *
      * Retreive error information .............................................
     Dgeterrinfo       PR           128
      * Convert numeric to char ................................................
     Dn2c              PR            12
     D numeric                       10I 0 VALUE
      * Debug print out ........................................................
     Ddp               PR
     D instr                        132    VALUE
      * Stream file APIs .......................................................
      * ILE C/400 Programmer's Reference   2.1.7 Data Type Compatibility
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
      * Prototypes and valiables for iconv() APIs ..............................
      * OS/400 National Language Support APIs V4  2.1 Data Conversion APIs
     Diconv_o          PR            52    EXTPROC('iconv_open')
     D                                 *   VALUE
     D                                 *   VALUE
     Diconv            PR            10U 0 EXTPROC('iconv')
     D                               52    VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     Diconv_c          PR            10I 0 EXTPROC('iconv_close')
     D                               52    VALUE
      *
     Diconv_t          DS
     D return_value                  10I 0
     D cd                            10I 0 DIM(12)
      *
     Dtocode           DS
     D IBMCCSID_2                     8    INZ('IBMCCSID')
     D toccsid                        5
     D conv_rvd_2                    19    INZ(*ALLX'00')
      *
     Dfromcode         DS
     D IBMCCSID_1                     8    INZ('IBMCCSID')
     D fromccsid                      5
     D*conv_options                   7    INZ('0000010')
     D conv_options                   7    INZ('0000001')
     D conv_rvd_1                    12    INZ(*ALLX'00')
      *
     Dccsid            S              5S 0
     Dibuf             S          32767
     Dobuf             S          32767
     Dobuflen          S             10U 0 INZ(%SIZE(obuf))
     Dibuf_p           S               *
     Dobuf_p           S               *
     Disav             S               *
     Dosav             S               *
     Dinbytesleft      S             10U 0
     Doutbytesleft     S             10U 0
     Diconv_ret        S             10U 0
     Dnewbuflen        S             10U 0
      * Retreive file information API ..........................................
      * OS/400 File APIs V4R1  1.9 Retrieve Database File Description API
      *
     D/COPY QSYSINC/QRPGLESRC,QDBRTVFD
      *
     Drtvbuf           S          32767    BASED(spc_ptr)
     Dfile_name        S             20    INZ('IN        *LIBL')
     Dspc_size         S              9B 0
     Dspc_ptr          S               *
     Dchg_attr         DS
     D nbr_attr                       9B 0 INZ(1)
     D attr_key                       9B 0 INZ(3)
     D data_size                      9B 0 INZ(1)
     D attr_data                      1    INZ('1')
     Doffset           S              5  0
     Dfld_num          S              3  0 INZ(0)
     Ddbfflde          S                   LIKE(QDBFFLDE) DIM(100)
     Ddbfftyp          S                   LIKE(QDBFFTYP) DIM(100)
     Ddbffobo          S              5P 0 DIM(100)
     Ddbffldb          S              5P 0 DIM(100)
     Ddbffldd          S              5P 0 DIM(100)
     Ddbffldp          S              5P 0 DIM(100)
     Ddbfcsid          S                   LIKE(QDBFCSID) DIM(100)
     Ddbfch            S             60    DIM(100)
     Dcolhdg           S             60
      * Retrieve Language Information (QLGRLNGI) API ...........................
      * OS/400 National Language Support APIs  1.7
      *
     D*COPY QSYSINC/QRPGLESRC,QLGRLNGI
     D/COPY QSYSINC/QRPGSRC,QLGRLNGI
      *
     Dlng_rcv_size     S              9B 0 INZ(%SIZE(QLGR0200))
      * Message API variables ..................................................
     Dmsg_data         S            200
     Dmsg_file         S             20    INZ('QCPFMSG   *LIBL')
     Dmsg_len          S              9B 0
     Dmsg_lvl          S              1
     Dstack_ent        S             10
     Dstack_ctr        S              9B 0 INZ(1)
     D*stack_len        S              9B 0 INZ(%SIZE(stack_ent))
     D*stack_qual       S             20    INZ('*NONE     *NONE')
     D*msg_wait         S              9B 0 INZ(0)
     D*stack_type       S             10    INZ('*CHAR')
     D*stack_csid       S              9B 0
      *
     Dmsg_data_a       S            204
     Dmsg_len_a        S              9B 0
      *****************************************************************
      * Other variables
      * US-ASCII (ANSI X3.4-1986) characters (95)
     Da_c              C                   ' !"#$%&''()*+,-./-
     D                                     0123456789:;<=>?-
     D                                     @ABCDEFGHIJKLMNO-
     D                                     PQRSTUVWXYZÝ\¨^_-
     D                                     `abcdefghijklmno-
     D                                     pqrstuvwxyz{|}µ'
      *
     Da_x              C                   X'202122232425262728292A2B2C2D2E2F-
      *                                      sp ! " # $ % & ' ( ) * + , - . /
     D                                     303132333435363738393A3B3C3D3E3F-
      *                                     0 1 2 3 4 5 6 7 8 9 : ; < = > ?
     D                                     404142434445464748494A4B4C4D4E4F-
      *                                     @ A B C D E F G H I J K L M N O
     D                                     505152535455565758595A5B5C5D5E5F-
      *                                     P Q R S T U V W X Y Z Ý \ ¨ ^ _
     D                                     606162636465666768696A6B6C6D6E6F-
      *                                     ` a b c d e f g h i j k l m n o
     D                                     707172737475767778797A7B7C7D7E'
      *                                     p q r s t u v w x y z { | } µ
     Dtype_conv        DS
     D zw                      1     31S 0
     D pw                     16     31P 0
     D cw                      1     31
     Dcw2              S             33
      *
     Dquote            S              1    INZ('"')
     Dibufpos_chr      S              1
     Ddecpos           S             31P 0
     Drcd_ctr          S              9P 0 INZ(0)
     Drcderr_ctr       S              9P 0 INZ(0)
      *
     Dcrlf             S              2    INZ(X'0D0A')
     Dnull             C                   X'00'
      *
     Dstart_time       S               Z
     Dend_time         S               Z
      * Debug printout string
     Dpm               S            132
      **************************************************************************
     IIN        AA  10
      /IF DEFINED(SHORTREC)
     I                                  1  999  INREC
      /ELSE
     I                                  1 9999  INREC
      /ENDIF
      /EJECT
      **************************************************************************
      * Main
      *****************************************************************
      * Initialize
      * Main process
      *   Convert RDB to CSV
     C   10              EXSR      #TOCSV
      *   Character code conversion
     C   10              EXSR      #ICONV
      *   Write to STMF
     C   10              EXSR      #WRITE
      * End program
      *   Close stream file
     CLR                 EXSR      #CLOSE
      *   Close code conversion routine
     CLR                 EXSR      #ICONV_C
      /EJECT
      **************************************************************************
      * Subroutines
      *****************************************************************
     C     *INZSR        BEGSR
      * Initialize
     C                   EXSR      #INIT
      *   Prepare user space
     C                   EXSR      #PPRUS
      *   Retrieve database file information
     C                   EXSR      #RTVFD
      *   Retrieve database file field information
     C                   EXSR      #GETFFD
      *   Open code conversion routine
     C                   EXSR      #ICONV_O
      *   Open stream file
     C                   EXSR      #OPEN
      *   Write additonal information to the SMTF
     C                   EXSR      #ADDINF
      *
     C                   ENDSR
      *****************************************************************
     C     #INIT         BEGSR
      *
     C     *ENTRY        PLIST
     C                   PARM                    tostmf          256        I
     C                   PARM                    ovrwrt            4        I
     C                   PARM                    dbfccsid          5 0      I
     C                   PARM                    stmfccsid         5 0      I
     C                   PARM                    addinf            7        I
     C                   PARM                    rcderr            4 0      I
     C                   PARM                    rcderrmsg         7        I
     C                   PARM                    rplchr            1        I
     C                   PARM                    flddlm            1        I
     C                   PARM                    debug             4        I
      *
     C                   PARM                    jobccsid          5 0      I
     C                   PARM                    nbrcurrcd        10 0      I
     C                   PARM                    msg_data        200        I/O
      * Remember start time
     C                   TIME                    start_time
      * Debug mode?
     C     debug         COMP      '*YES'                                 90
     C   90              OPEN      QPRINT
     C   90              CALLP     dp('Debug mode.  ' +
     C                                      %TRIM(%EDITC(*DATE : 'Y')))
     C   90              CALLP     dp('*** CRTCSVF version ' +
     C                                      %TRIM(version) + ' ***')
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Input Parameters')
     C   90              CALLP     dp(' tostmf    : ' + tostmf)
     C   90              CALLP     dp(' ovrwrt    : ' + ovrwrt)
     C   90              CALLP     dp(' dbfccsid  : ' + %TRIMR(n2c(dbfccsid)) +
     C                                ' (0 = *JOB, -1 = *FILE')
     C   90              CALLP     dp(' stmfccsid : ' + %TRIMR(n2c(stmfccsid))+
     C                                ' (0 = *SYSTEM)')
     C   90              CALLP     dp(' addinf    : ' + addinf)
     C   90              CALLP     dp(' rcderr    : ' + %TRIMR(n2c(rcderr)) +
     C                                ' (0 = *ABORT, -1 = *IGNORE)')
     C   90              CALLP     dp(' rcderrmsg : ' + rcderrmsg)
     C   90              CALLP     dp(' rplchr    : ' + rplchr)
     C   90              CALLP     dp(' flddlm    : ' + flddlm)
     C   90              CALLP     dp(' debug     : ' + debug)
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp(' jobccsid  : ' + n2c(jobccsid))
     C   90              CALLP     dp(' nbrcurrcd : ' + n2c(nbrcurrcd))
      * Set APIs not to raise an exception
      *   System API Programming Version 4 SC41-5800-00
      *   2.4.3.2 Receiving the Error Code without the Exception Data--Example
     C                   Z-ADD     16            QUSBPRV
      *
     C                   ENDSR
      *****************************************************************
      * Create user space to retrieve database file information
     C     #PPRUS        BEGSR
      *
     C                   EVAL      spc_name = 'QDBRTVFD  QTEMP'
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp(' Create User Space ''' +
     C                               %TRIMR(%SUBST(spc_name : 11 : 10)) + '/' +
     C                               %TRIMR(%SUBST(spc_name : 1 : 10)) + '''.')
      *
     C                   CALL      'QUSCRTUS'
     C                   PARM                    spc_name         20        I
     C                   PARM      *BLANKS       spc_attr         10        I
     C                   PARM      1024          spc_size                   I
     C                   PARM      null          spc_init          1        I
     C                   PARM      '*CHANGE'     spc_aut          10        I
     C                   PARM      'QDBRTVFD'    spc_text         50        I
     C                   PARM      '*NO'         spc_replace      10        I
     C                   PARM                    QUSEC                      I/O
     C                   PARM      '*USER'       spc_domain       10        I
      *
     C                   IF        QUSBAVL > 0
     C                   IF        QUSEI =  'CPF9870'
     C   90              CALLP     dp(' User Space already exists.')
     C                   ELSE
     C                   EVAL      msg_data = 'EAPI QUSCRTUS failed : ' + QUSEI
     C                   EXSR      #SNDPM
     C                   ENDIF
     C                   ELSE
     C   90              CALLP     dp(' API QUSCRTUS successful.')
     C   90              CALLP     dp('   user space ' + %TRIM(spc_name) +
     C                                    ' created.')
     C                   ENDIF
      *   Change USRSPC to extendable
     C                   CALL      'QUSCUSAT'
     C                   PARM                    lib_name         10        O
     C                   PARM                    spc_name                   I
     C                   PARM                    chg_attr                   I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   EVAL      msg_data = 'EAPI QUSCUSAT failed : ' + QUSEI
     C                   EXSR      #SNDPM
     C                   END
     C   90              CALLP     dp(' API QUSCUSAT successful.')
      *   Retrieve pointer to user space
     C                   CALL      'QUSPTRUS'
     C                   PARM                    spc_name                   I
     C                   PARM                    spc_ptr                    O
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   EVAL      msg_data = 'EAPI QUSPTRUS failed : ' + QUSEI
     C                   EXSR      #SNDPM
     C                   END
     C   90              CALLP     dp(' API QUSPTRUS successful.')
      *
     C                   ENDSR
      *****************************************************************
      * Retrieve database file information
     C     #RTVFD        BEGSR
      *
     C                   CALL      'QDBRTVFD'
     C                   PARM                    rtvbuf                     O
     C                   PARM      32767         spc_size                   I
     C                   PARM                    file_used        20        O
     C                   PARM      'FILD0200'    rtv_fmt           8        I
     C                   PARM                    file_name                  I
     C                   PARM      '*FIRST'      rec_fmt          10        I
     C                   PARM      '1'           override          1        I
     C                   PARM      '*FILETYPE'   system_loc       10        I
     C                   PARM      '*EXT'        format_type      10        I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   EVAL      msg_data = 'EAPI QDBRTVFD failed : ' + QUSEI
     C                   EXSR      #SNDPM
     C                   END
     C   90              CALLP     dp(' API QDBRTVFD successful.')
      * Copy database file information to data structure 'QDBQ41'
     C                   MOVEL     rtvbuf        QDBQ41
     C                   EVAL      msg_data = 'IFile information : ' +
     C                             %TRIMR(%SUBST(file_used : 10)) + '/' +
     C                             %TRIMR(%SUBST(file_used : 1 : 10)) + '(' +
     C                             %TRIM(QDBFTEXT) + ') ' +
     C                             'record length = ' + %TRIMR(n2c(QDBFRLEN)) +
     C                             ' field number = ' + %TRIMR(n2c(QDBLDNUM)) +
     C                             ' CCSID = ' + n2c(QDBFRCID)
     C                   EXSR      #SNDPM
      * Check record length
      /IF DEFINED(SHORTREC)
     C                   IF        QDBLDNUM > 999
     C                   EVAL      msg_data = 'ERecord length must be less ' +
     C                                        'than 1,000.'
      /ELSE
     C                   IF        QDBLDNUM > 9999
     C                   EVAL      msg_data = 'ERecord length must be less ' +
     C                                        'than 10,000.'
      /ENDIF
     C                   EXSR      #SNDPM
     C                   END
      *
     C                   ENDSR
      *****************************************************************
      * Retrieve database file field information
     C     #GETFFD       BEGSR
      *
     C                   EVAL      offset = %SIZE(QDBQ41) + 1
      * Get information of each field
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('  US_Offset ExtFldName DataType     ' +
     C                                'OutBufOffset Length Digits DecPos ' +
     C                                'CCSID  COLHDG')
     C                   DO        QDBLDNUM
      *   Copy field information to data structure 'QDBQ44'
     C                   EVAL      QDBQ42 = %SUBST(rtvbuf : offset)
     C                   EVAL      colhdg =
     C                             %TRIM(%SUBST(rtvbuf :
     C                                   offset + QDBDFCHD : 20)) + ' ' +
     C                             %TRIM(%SUBST(rtvbuf :
     C                                   offset + QDBDFCHD + 20 : 20)) + ' ' +
     C                             %TRIM(%SUBST(rtvbuf :
     C                                   offset + QDBDFCHD + 40 : 20))
      *   Only ZONE/PACK/CHAR(except graphic/varying) fields will be converted
     C                   MOVE      ' '           valid_ftyp        1
     C                   IF        ((QDBFFTYP = X'0002') AND (QDBFFLDD < 32)) OR
     C                             ((QDBFFTYP = X'0003') AND (QDBFFLDD < 32)) OR
     C                             ((QDBFFTYP = X'0004') AND (QDBFFKBS <> 'H'))
     C                             OR (QDBFFTYP = X'0006')
     C                             OR (QDBFFTYP = X'000B')
     C                             OR (QDBFFTYP = X'000C')
     C                             OR (QDBFFTYP = X'000D')
      *     Count field number
     C                   ADD       1             fld_num
     C                   MOVE      '>'           valid_ftyp
      *     Copy field information to array
     C                   EVAL      dbfflde(fld_num) = QDBFFLDE
     C                   EVAL      dbfftyp(fld_num) = QDBFFTYP
     C                   EVAL      dbffobo(fld_num) = QDBFFOBO + 1
     C                   EVAL      dbffldb(fld_num) = QDBFFLDB
     C                   EVAL      dbffldd(fld_num) = QDBFFLDD
     C                   EVAL      dbffldp(fld_num) = QDBFFLDP
     C                   EVAL      dbfcsid(fld_num) = QDBFCSID
     C                   EVAL      dbfch(fld_num) = colhdg
     C                   ENDIF
      *   Print field information
     C   90              SELECT
     C                   WHEN      QDBFFTYP = X'0000'
     C                   MOVEL     'BINARY      'ftyp             12
     C                   WHEN      QDBFFTYP = X'0001'
     C                   MOVEL     'FLOAT       'ftyp
     C                   WHEN      QDBFFTYP = X'0002'
     C                   MOVEL     'ZONED DEC   'ftyp
     C                   WHEN      QDBFFTYP = X'0003'
     C                   MOVEL     'PACKED DEC  'ftyp
     C                   WHEN      QDBFFTYP = X'0004'
     C                   MOVEL     'CHAR        'ftyp
     C                   WHEN      QDBFFTYP = X'8004'
     C                   MOVEL     'VAR CHAR    'ftyp
     C                   WHEN      QDBFFTYP = X'0005'
     C                   MOVEL     'GRAPHIC     'ftyp
     C                   WHEN      QDBFFTYP = X'0006'
     C                   MOVEL     'DBCS CAPABLE'ftyp
     C                   WHEN      QDBFFTYP = X'8005'
     C                   MOVEL     'VAR GRAPHIC 'ftyp
     C                   WHEN      QDBFFTYP = X'8006'
     C                   MOVEL     'VAR DBCS    'ftyp
     C                   WHEN      QDBFFTYP = X'000B'
     C                   MOVEL     'DATE        'ftyp
     C                   WHEN      QDBFFTYP = X'000C'
     C                   MOVEL     'TIME        'ftyp
     C                   WHEN      QDBFFTYP = X'000D'
     C                   MOVEL     'TIMESTAMP   'ftyp
     C                   WHEN      QDBFFTYP = X'FFFF'
     C                   MOVEL     'NULL        'ftyp
     C                   OTHER
     C                   MOVEL     '*UNKNOWN    'ftyp
     C                   ENDSL
      *
     C   90              CALLP     dp('   ' + %EDITC(offset : 'P') + '  ' +
     C                                valid_ftyp +
     C                                %SUBST(QDBFFLDE : 1 : 10) + ' ' +
     C                                ftyp + ' ' +
     C                                %EDITC(QDBFFOBO : 'P') + '   ' +
     C                                %EDITC(QDBFFLDB : 'P') + '  ' +
     C                                %EDITC(QDBFFLDD : 'P') + '  ' +
     C                                %EDITC(QDBFFLDP : 'P') + '  ' +
     C                                %EDITC(QDBFCSID : 'P') + '  ' + colhdg)
      *   Set offset to next field information
     C                   ADD       QDBFDEFL      offset
      *   Offset value about to exceed buffer length
      *   Only in unusual circumstances is this number exceeded.
     C                   IF        offset > 32000
     C                   EVAL      msg_data = 'IFile information too large. ' +
     C                             %TRIMR(n2c(fld_num)) +
     C                             'th and later fields are ignored.'
     C                   EXSR      #SNDPM
     C                   LEAVE
     C                   END
      *   Only first 100 fields will be processed
     C                   IF        fld_num >= 100
     C                   EVAL      msg_data = 'IField count exceeded 100. ' +
     C                                        'Subsequent fields ' +
     C                                        'will be ignored.'
     C                   EXSR      #SNDPM
     C                   LEAVE
     C                   END
     C                   ENDDO
      *
     C                   ENDSR
      *****************************************************************
      * Initialize iconv
     C     #ICONV_O      BEGSR
     C   90              CALLP     dp(' ')
      * CCSID for database file (EBCDIC)
     C                   SELECT
      *   *JOB
     C                   WHEN      dbfccsid = 0
     C                   EVAL      ccsid = jobccsid
     C                   IF        ccsid = 0
     C   90              CALLP     dp(' Job CCSID is 0 (65535), trying' +
     C                                ' FILE CCSID.')
     C                   EVAL      ccsid = %DEC(QDBFRCID)
     C                   ENDIF
      *   *FILE
     C                   WHEN      dbfccsid = -1
     C                   EVAL      ccsid = %DEC(QDBFRCID)
     C                   IF        ccsid = 0
     C   90              CALLP     dp(' File CCSID is 0 (65535), trying' +
     C                                ' JOB CCSID.')
     C                   EVAL      ccsid = jobccsid
     C                   ENDIF
      *   other CCSID
     C                   OTHER
     C                   EVAL      ccsid = dbfccsid
     C                   ENDSL
      *   Unable to set valid CCSID
     C   90              CALLP     dp(' Using EBCDIC CCSID for database' +
     C                                ' file - ' + n2c(ccsid))
     C                   IF        ccsid = 0
     C                   EVAL      msg_data = 'ECCSID 65535 for database ' +
     C                                        ' file is not valid.'
     C                   EXSR      #SNDPM
     C                   ENDIF
      *
     C                   MOVE      ccsid         fromccsid
      * CCSID for stream file (ASCII)
     C   90              CALLP     dp(' ')
      *   *SYSTEM
     C                   IF        stmfccsid = 0
     C                   EVAL      QLGPID = '*OPSYS '
     C                   EVAL      QLGPO  = '0000'
     C                   EVAL      QLGLID00 = '*SYSVAL   '
      *     Call Retrieve Language Information API
     C                   CALL      'QLGRLNGI'
     C                   PARM                    QLGR0200                   O
     C                   PARM                    lng_rcv_size               I
     C                   PARM      'LNGI0100'    lng_sel_fmt       8        I
     C                   PARM                    QLGI010000                 I
     C                   PARM      'LNGR0200'    lng_out_fmt       8        I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   EVAL      msg_data = 'EAPI QLGRLNGI failed : ' + QUSEI
     C                   EXSR      #SNDPM
     C                   ENDIF
      *
     C   90              CALLP     dp(' API QLGRLNGI successful.')
     C   90              CALLP     dp('  Selected NLV : ' + QLGSNLV00)
     C   90              CALLP     dp('  Primary Language NLV : ' + QLGPLNLV00)
     C   90              CALLP     dp('  AS400 EBCDIC CCSID : ' +
     C                                                          n2c(QLGCCSID03))
     C   90              CALLP     dp('  PC ASCII CCSID  : ' + n2c(QLGCCSID04))
     C   90              CALLP     dp('  ISO ASCII CCSID  : ' + n2c(QLGCCSID05))
     C   90              CALLP     dp('  Language ID : ' + QLGLI04)
     C                   EVAL      stmfccsid = QLGCCSID04
     C                   ENDIF
      *
     C                   EVAL      ccsid = stmfccsid
      *
     C   90              CALLP     dp(' Using stream file CCSID - ' +
     C                                                 n2c(ccsid))
     C                   MOVE      ccsid         toccsid
      * Open iconv
     C                   EVAL      iconv_t = iconv_o(%ADDR(tocode)
     C                               : %ADDR(fromcode))
      *
     C                   IF        return_value = -1
     C                   EVAL      msg_data = 'Eiconv_open failed. ' +
     C                             'EBCDIC CCSID - ' + fromccsid +
     C                             ' / ASCII CCSID - ' + toccsid + geterrinfo
     C                   EXSR      #SNDPM
     C                   ENDIF
     C   90              CALLP     dp(' iconv_open() successful.')
      *
     C                   ENDSR
      *****************************************************************
      * Open stream file
     C     #OPEN         BEGSR
     C                   EVAL      stmf = %TRIMR(tostmf) + null
     C   90              CALLP     dp(' ')
      *   Unlink existing stream file
     C                   IF        ovrwrt = '*YES'
      *
     C                   IF        -1 = unlink(%ADDR(stmf))
     C   90              CALLP     dp(' unlink() failed. ' + geterrinfo)
     C                   ELSE
     C                   EVAL      msg_data = 'IFile ''' + %TRIM(tostmf) +
     C                                        ''' deleted.'
     C                   EXSR      #SNDPM
     C                   ENDIF
     C                   ENDIF
      * Open stream file
     C                   EVAL      fd = open(%ADDR(stmf)
     C                               : O_CREAT + O_WRONLY + O_TRUNC + O_CODEPAGE
     C                               : S_IRWXU + S_IROTH
     C                               : stmfccsid)
      *
     C                   IF        fd = -1
     C                   EVAL      msg_data = 'EFailed to open file ''' +
     C                                      %TRIM(tostmf) + '''. ' + geterrinfo
     C                   ELSE
     C                   EVAL      msg_data = 'IFile ''' + %TRIM(tostmf) +
     C                                               ''' created.'
     C                   ENDIF
     C                   EXSR      #SNDPM
     C                   Z-ADD     1             stmfopened        1 0
      *
     C                   ENDSR
      *****************************************************************
      * Write additional information
     C     #ADDINF       BEGSR
      * column heading
     C                   Z-ADD     1             ibufpos           5 0
     C                   IF        addinf = '*BOTH' OR addinf = '*COLHDG'
     C                   DO        fld_num       I                 3 0
     C                   EVAL      %SUBST(ibuf : ibufpos) = quote +
     C                             %TRIM(dbfch(I)) + quote + flddlm
     C                   EVAL      ibufpos = ibufpos +
     C                             %LEN(%TRIM(dbfch(I))) + 3
     C                   ENDDO
     C                   EVAL      ibufpos = ibufpos - 1
     C                   EXSR      #ICONV
     C                   EXSR      #WRITE
     C                   ENDIF
      * Field name (external)
     C                   Z-ADD     1             ibufpos
     C                   IF        addinf = '*BOTH' OR addinf = '*FLDNAM'
     C                   DO        fld_num       I
     C                   EVAL      %SUBST(ibuf : ibufpos) = quote +
     C                             %TRIM(dbfflde(I)) + quote + flddlm
     C                   EVAL      ibufpos = ibufpos +
     C                             %LEN(%TRIM(dbfflde(I))) + 3
     C                   ENDDO
     C                   EVAL      ibufpos = ibufpos - 1
     C                   EXSR      #ICONV
     C                   EXSR      #WRITE
     C                   ENDIF
      *
     C                   ENDSR
      *****************************************************************
      * RDB -> CSV conversion
     C     #TOCSV        BEGSR
      *
     C                   Z-ADD     1             ibufpos
      * Process fields in a record
     C                   DO        fld_num       I
      *   ZONE
     C                   IF        dbfftyp(I) = X'0002'
     C                   Z-ADD     0             zw
     C                   EVAL      %SUBST(cw : 31 - dbffldb(I) + 1 : dbffldb(I))
     C                             = %SUBST(INREC : dbffobo(I) : dbffldb(I))
     C                   Z-ADD     1             dec_error         1 0
     C                   Z-ADD     zw            nw               31 0
     C                   Z-ADD     0             dec_error
     C                   ENDIF
      *   PACK
     C                   IF        dbfftyp(I) = X'0003'
     C                   Z-ADD     0             pw
     C                   EVAL      %SUBST(cw : 31 - dbffldb(I) + 1 : dbffldb(I))
     C                             = %SUBST(INREC : dbffobo(I) : dbffldb(I))
     C                   Z-ADD     2             dec_error
     C                   Z-ADD     pw            nw
     C                   Z-ADD     0             dec_error
     C                   ENDIF
      *   Numeric to character conversion
     C                   IF        dbfftyp(I) = X'0002' OR dbfftyp(I) = X'0003'
      *     numeric value is 0
     C                   IF        nw = 0
      *       No decimal fraction
     C                   IF        dbffldp(I) = 0
     C                   EVAL      %SUBST(ibuf : ibufpos : 1) = '0'
     C                   EVAL      ibufpos = ibufpos + 1
      *       Has decimal fraction
     C                   ELSE
     C                   EVAL      %SUBST(ibuf : ibufpos : 3) = '0.0'
     C                   EVAL      ibufpos = ibufpos + 3
     C                   ENDIF
      *     numeric value is not 0
     C                   ELSE
      *       No decimal fraction
     C                   IF        dbffldp(I) = 0
     C                   EVAL      cw2 = %EDITC(nw : 'P')
     C                   EVAL      %SUBST(ibuf : ibufpos : 33) = %TRIML(cw2)
     C                   EVAL      ibufpos = ibufpos + %LEN(%TRIM(cw2))
      *       Has decimal fraction
     C                   ELSE
     C                   EVAL      decpos = 10 ** dbffldp(I)
     C     nw            DIV       decpos        nw2              31 0
     C                   MVR                     nw3              31 0
     C                   EVAL      cw2 = %TRIM(%EDITC(nw2 : 'P')) + '.' +
     C                             %SUBST(%EDITW(nw3 : '0                   -
     C                                        ') : 32 - dbffldp(I))
      *       Add '-' if integer part is 0 and fraction part is minus
     C                   IF        (nw2 = 0) AND (nw < 0)
     C                   EVAL      cw2 = '-' + cw2
     C                   ENDIF
      *       Remove trailing 0s
     C                   EVAL      end_pos = %LEN(%TRIMR(cw2))
     C                   DOW       end_pos > 2 AND
     C                             %SUBST(cw2 : end_pos : 1) = '0'
     C                   SUB       1             end_pos           5 0
     C                   ENDDO
     C                   IF        %SUBST(cw2 : end_pos : 1) = '.'
     C                   ADD       1             end_pos
     C                   ENDIF
      *
     C                   EVAL      %SUBST(ibuf : ibufpos : end_pos) =
     C                             %SUBST(cw2 : 1 : end_pos)
     C                   EVAL      ibufpos = ibufpos + end_pos
     C                   ENDIF
     C                   ENDIF
     C                   ENDIF
      *   Character
     C                   IF        dbfftyp(I) = X'0004' OR dbfftyp(I) = X'0006'
     C                   EVAL      %SUBST(ibuf : ibufpos : dbffldb(I) + 1) =
     C                                 quote +
     C                                 %SUBST(INREC : dbffobo(I) : dbffldb(I))
      *     Remove trailing blanks
     C                   EVAL      end_pos = ibufpos + dbffldb(I)
      *       Last character is shift-in
     C                   IF        %SUBST(ibuf : end_pos : 1) = X'0F'
     C                   SETON                                        50
     C                   EVAL      %SUBST(ibuf : end_pos : 1) = ' '
     C                   ELSE
     C                   SETOFF                                       50
     C                   ENDIF
      *       Search non-blank character from last position of the field
     C                   DOW       end_pos > ibufpos AND
     C                             %SUBST(ibuf : end_pos : 1) = ' '
     C                   SUB       1             end_pos
     C                   ENDDO
     C                   ADD       1             end_pos
      *       Pad shif-in
     C   50              EVAL      %SUBST(ibuf : end_pos : 1) = X'0F'
     C   50              ADD       1             end_pos
     C                   EVAL      %SUBST(ibuf : end_pos : 1) = quote
      *       Replace double quotation character
     C                   SUB       1             end_pos
     C                   ADD       1             ibufpos
     C                   SETOFF                                       50
      *
     C     ibufpos       DO        end_pos       J                 5 0
     C                   EVAL      ibufpos_chr = %SUBST(ibuf : J : 1)
     C                   SELECT
     C                   WHEN      ibufpos_chr = X'0E'
     C                   SETON                                        50
     C                   WHEN      ibufpos_chr = X'0F'
     C                   SETOFF                                       50
     C                   WHEN      (ibufpos_chr = quote) AND (*IN50 = *OFF)
      *       is replace character '"' ?
      *         Yes
     C                   IF        rplchr = '"'
     C                   EVAL      %SUBST(ibuf : J + 1 : end_pos - J + 2) =
     C                                 %SUBST(ibuf : J : end_pos - J + 2)
     C                   ADD       1             J
     C                   ADD       1             end_pos
      *         No
     C                   ELSE
     C                   EVAL      %SUBST(ibuf : J : 1) = rplchr
     C                   POST      IN
     C                   EVAL      msg_data = 'CQuotation replaced at RRN ' +
     C                             %TRIMR(n2c(currec)) + ', field ' +
     C                             %TRIMR(dbfflde(I)) + '.'
     C                   EXSR      #SNDPM
     C                   ENDIF
     C                   ENDSL
     C                   ENDDO
      *
     C                   EVAL      ibufpos = end_pos + 2
     C                   ENDIF
      *   Date
     C                   IF        dbfftyp(I) = X'000B'
     C                   EVAL      date_work = %SUBST(INREC : dbffobo(I) : 10)
     C     '-':'/'       XLATE     date_work     date_work        10
     C                   EVAL      %SUBST(ibuf : ibufpos : 12) =
     C                                 quote + date_work + quote
     C                   EVAL      ibufpos = ibufpos + 12
     C                   ENDIF
      *   Time
     C                   IF        dbfftyp(I) = X'000C'
     C                   EVAL      time_work = %SUBST(INREC : dbffobo(I) : 8)
     C     '.':':'       XLATE     time_work     time_work         8
     C                   EVAL      %SUBST(ibuf : ibufpos : 10) =
     C                                 quote + time_work + quote
     C                   EVAL      ibufpos = ibufpos + 10
     C                   ENDIF
      *   Timestamp
     C                   IF        dbfftyp(I) = X'000D'
     C                   EVAL      %SUBST(ibuf : ibufpos : 28) =
     C                                 quote + %SUBST(INREC : dbffobo(I) : 26) +
     C                                 quote
     C                   EVAL      ibufpos = ibufpos + 28
     C                   ENDIF
      * Insert field delimiter
     C                   IF        I <  fld_num
     C                   EVAL      %SUBST(ibuf : ibufpos : 1) = flddlm
     C                   ADD       1             ibufpos
     C                   ENDIF
      *
     C                   ENDDO
      * Increment record count
     C                   ADD       1             rcd_ctr
     C                   ADD       1             rcd_ctr_d         7 0
     C                   IF        rcd_ctr_d >= 1000
     C                   EVAL      msg_data = 'S' +
     C                                 %TRIMR(n2c(rcd_ctr)) + '/' +
     C                                 %TRIMR(n2c(nbrcurrcd)) +
     C                                 ' records processed.'
     C                   EXSR      #SNDPM
     C                   Z-ADD     0             rcd_ctr_d
     C                   ENDIF
      *
     C                   ENDSR
      *****************************************************************
      * Character code conversion
     C     #ICONV        BEGSR
      *
     C                   EVAL      inbytesleft = ibufpos - 1
     C                   EVAL      outbytesleft = obuflen
     C                   EVAL      ibuf_p = %ADDR(ibuf)
     C                   EVAL      obuf_p = %ADDR(obuf)
     C                   EVAL      isav = ibuf_p
     C                   EVAL      osav = obuf_p
     C                   EVAL      iconv_ret = iconv(iconv_t
     C                               : %ADDR(ibuf_p)
     C                               : %ADDR(inbytesleft)
     C                               : %ADDR(obuf_p)
     C                               : %ADDR(outbytesleft))
     C                   EVAL      newbuflen = obuflen - outbytesleft
      *
     C                   IF        iconv_ret <> 0
     C                   POST      IN
     C                   EVAL      msg_data = 'CCode conversio failed ' +
     C                             'at RRN ' + %TRIMR(n2c(currec)) + geterrinfo
     C                   EXSR      #SNDPM
     C                   ENDIF
      *
     C                   IF        inbytesleft > 0
     C                   POST      IN
     C                   EVAL      msg_data = 'CIncomplete code conversion ' +
     C                                'at RRN ' + %TRIMR(n2c(currec)) + ', ' +
     C                                %TRIMR(n2c(inbytesleft)) +
     C                                ' bytes abandoned.'
     C                   EXSR      #SNDPM
     C                   ENDIF
      *
     C                   ENDSR
      *****************************************************************
      * Write to stream file
     C     #WRITE        BEGSR
      *
     C                   IF        iconv_ret <> 0
     C                   EVAL      bytesw = write(fd : %ADDR(crlf) : 2)
     C                   ELSE
     C                   EVAL      %SUBST(obuf : newbuflen + 1 : 2) = crlf
     C                   EVAL      bytesw = write(fd : osav : newbuflen + 2)
      *
     C                   IF        (bytesw = -1) OR (bytesw <> newbuflen + 2)
     C                   EVAL      msg_data = 'Ewrite() failed.' + geterrinfo
     C                   EXSR      #SNDPM
     C                   ENDIF
     C                   ENDIF
      *
     C                   ENDSR
      *****************************************************************
      * Close stream file
     C     #CLOSE        BEGSR
      *
     C                   IF        -1 = close(fd)
     C                   EVAL      msg_data = 'Eclose() failed.' + geterrinfo
     C                   EXSR      #SNDPM
     C                   ENDIF
     C                   Z-ADD     0             stmfopened
     C   90              CALLP     dp(' Stream file ''' + %TRIM(tostmf) +
     C                                                 ''' closed.')
      *
     C                   ENDSR
      *****************************************************************
      * Close iconv
     C     #ICONV_C      BEGSR
      *
     C                   IF        iconv_c(iconv_t) = -1
     C                   EVAL      msg_data = 'Eiconv_close() failed.'
     C                                                + geterrinfo
     C                   EXSR      #SNDPM
     C                   ENDIF
     C   90              CALLP     dp(' iconv_close() successful.')
      * Normal end.
     C                   EVAL      msg_data = 'IProcess completed. Total ' +
     C                               %TRIMR(n2c(rcd_ctr)) + ' record(s), ' +
     C                               %TRIMR(n2c(rcderr_ctr)) + ' error(s).'
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('(' + %SUBST(msg_data : 1 : 1) + ') ' +
     C                                      %SUBST(msg_data : 2))
     C   90              CLOSE     QPRINT
      *
     C                   ENDSR
      *****************************************************************
      * Send program message
     C     #SNDPM        BEGSR
      *
     C                   EVAL      msg_lvl = %SUBST(msg_data : 1 : 1)
     C                   IF        msg_lvl = 'C'
     C                   EXSR      #ESTMF
     C                   ENDIF
     C                   EVAL      msg_data = %SUBST(msg_data : 2)
     C                   EVAL      msg_len = %LEN(%TRIMR(msg_data))
      *
     C   90              CALLP     dp('(' + msg_lvl + ') ' + msg_data)
      * Record error message - continue or abort ?
     C                   IF        msg_lvl = 'C'
     C                   ADD       1             rcderr_ctr
     C                   SELECT
      *   RCDERR(*ABORT)
     C                   WHEN      rcderr = 0
     C                   EVAL      msg_lvl = 'E'
      *   RCDERR(*IGNORE)
     C                   WHEN      rcderr = -1
     C                   EVAL      msg_lvl = 'I'
      *   RCDERR(value)
     C                   OTHER
     C                   IF        rcderr_ctr > rcderr
     C                   EVAL      msg_lvl = 'E'
     C                   ELSE
     C                   EVAL      msg_lvl = 'I'
     C                   ENDIF
     C                   ENDSL
     C                   ENDIF
      * message type
      *   status message ('S')
     C                   IF        msg_lvl = 'S'
     C                   EVAL      msg_id = 'CPF9898'
     C                   EVAL      msg_type = '*STATUS'
     C                   EVAL      stack_ent = '*EXT'
      *   information message ('E' and 'I')
     C                   ELSE
     C                   EVAL      msg_id = 'CPI8859'
     C                   EVAL      msg_type = '*INFO'
     C                   EVAL      stack_ent = '*'
     C                   ENDIF
     C*                  EVAL      msg_id = 'CPF9897'
     C*                  EVAL      msg_type = '*ESCAPE'
      * Send status and second-level message
     C                   IF        rcderrmsg = '*SECLVL' OR rcderrmsg = '*BOTH'
     C                             OR msg_lvl = 'S'
      *
     C                   CALL      'QMHSNDPM'
     C                   PARM                    msg_id            7        I
     C                   PARM                    msg_file                   I
     C                   PARM                    msg_data                   I
     C                   PARM                    msg_len                    I
     C                   PARM                    msg_type         10        I
     C                   PARM                    stack_ent                  I
     C                   PARM                    stack_ctr                  I
     C                   PARM                    msg_key           4        O
     C                   PARM                    QUSEC                      I/O
      *
     C*                  PARM                    stack_len                  I
     C*                  PARM                    stack_qual                 I
     C*                  PARM                    msg_wait                   I
     C*                  PARM                    stack_type                 I
     C*                  PARM                    stack_csid                 I
     C                   ENDIF
      * Aborting the program
     C                   IF        msg_lvl = 'E'
     C                   EVAL      msg_data = 'EProgram aborted. ' +
     C                                %TRIMR(n2c(rcd_ctr)) + '/' +
     C                                %TRIMR(n2c(nbrcurrcd)) +
     C                                ' records processed, ' +
     C                                %TRIMR(n2c(rcderr_ctr)) +
     C                                ' error(s) found. reason - ' + msg_data
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('(' + %SUBST(msg_data : 1 : 1) + ') ' +
     C                                      %SUBST(msg_data : 2))
     C                   EXSR      #ESTMF
     C                   EVAL      *INLR = '1'
     C                   RETURN
     C                   ENDIF
      *
     C                   ENDSR
      *****************************************************************
      * Write error message to STMF
     C     #ESTMF        BEGSR
      *   convert EBCDIC to ASCII / add CRLF / write to stream file
     C                   IF        (rcderrmsg = '*STMF' OR rcderrmsg = '*BOTH')
     C                             AND (stmfopened = 1)
     C                   EVAL      msg_data_a = quote +
     C                             %TRIMR(%SUBST(msg_data : 2)) + quote
     C                   EVAL      msg_len_a = %LEN(%TRIMR(msg_data_a))
     C     a_c:a_x       XLATE     msg_data_a    msg_data_a
     C                   EVAL      %SUBST(msg_data_a : msg_len_a + 1 : 2) = crlf
     C                   EVAL      bytesw = write(fd : %ADDR(msg_data_a) :
     C                                                 msg_len_a + 2)
      *   fatal error during write operation
     C                   IF        bytesw <> (msg_len_a + 2)
     C                   EVAL      msg_data = 'EProgram aborted. ' +
     C                                'Cannot write record error information ' +
     C                                'to stream file.' + geterrinfo
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('(' + %SUBST(msg_data : 1 : 1) + ') ' +
     C                                      %SUBST(msg_data : 2))
     C                   EVAL      *INLR = '1'
     C                   RETURN
     C                   ENDIF
     C                   ENDIF
      *
     C                   ENDSR
      *****************************************************************
     C     *PSSR         BEGSR
      * Program error subroutine
      *   Decimal data error
     C                   IF        pgm_error = 907 AND dec_error > 0
     C                   POST      IN
     C                   EVAL      msg_data = 'CDecimal data error at RRN ' +
     C                             %TRIMR(n2c(currec)) + ', field ''' +
     C                             %TRIMR(dbfflde(I)) + ''''
     C                   EXSR      #SNDPM
     C                   IF        dec_error = 1
     C                   Z-ADD     0             zw
     C                   ELSE
     C                   Z-ADD     0             pw
     C                   ENDIF
     C                   EVAL      %SUBST(INREC : dbffobo(I) : dbffldb(I)) =
     C                             %SUBST(cw : 31 - dbffldb(I) + 1 : dbffldb(I))
     C                   MOVE      '*DETC '      ReturnPt          6
      *   Unexpected error
     C                   ELSE
     C                   POST      IN
     C                   EVAL      msg_data = 'EUnexpected error ' +
     C                             %TRIMR(n2c(pgm_error)) + ' at statement ' +
     C                             %TRIMR(n2c(pgm_line)) + '.'
     C                   EXSR      #SNDPM
     C*                  MOVE      '*CANCL'      ReturnPt          6
     C                   ENDIF
      *
     C                   ENDSR     ReturnPt
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
     C                   RETURN    ' - ' + %TRIM(n2c(errnum)) + ' : ' +
     C                             %STR(strerror(errnum))
     Pgeterrinfo       E
