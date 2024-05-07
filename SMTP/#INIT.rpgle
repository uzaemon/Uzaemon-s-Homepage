      *****************************************************************
      * Initialize routine
     C     #INIT         BEGSR
      * Debug mode?
     C     debug         COMP      '*YES'                                 90
      * Print debug information
     C   90              OPEN      QPRINT
     C   90              CALLP     dp('Debug mode.  ' +
     C                                      %TRIM(%EDITC(*DATE : 'Y')))
     C   90              CALLP     dp('*** SMTP client for AS/400 version ' +
     C                                      %TRIM(version) + ' ***')
     C   90              CALLP     dp(' ')
      * prepare user space for retreive job/file APIs
     C                   EVAL      rc = prepareus(spc_name : excp)
     C                   IF        rc <> 0
     C                   IF        excp = 'CPF9870'
     C   90              CALLP     dp('User space ''' +
     C                                %TRIM(%SUBST(spc_name : 11 : 10)) + '/' +
     C                                %TRIM(%SUBST(spc_name :  1 : 10)) +
     C                                ''' already exists. using this one...')
     C                   ELSE
     C                   CALLP     em(em1(1) : 'RC=' + %TRIMR(n2c(rc)) + ', ' +
     C                                                                     excp)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   ELSE
     C   90              CALLP     dp('User space ''' +
     C                                %TRIM(%SUBST(spc_name : 11 : 10)) + '/' +
     C                                %TRIM(%SUBST(spc_name :  1 : 10)) +
     C                                                ''' created.')
     C                   ENDIF
     C   90              CALLP     dp(' ')
      * get current job information
     C                   EVAL      rc = getjobinfo(spc_name : job_name :
     C                                  user_name : job_number : act_time :
     C                                  jobccsid : dftjobccsid : excp)
     C                   IF        rc <> 0
     C                   CALLP     em(em1(2) : 'RC=' + %TRIMR(n2c(rc)) + ', ' +
     C                                                                     excp)
     C                   EXSR      #ABORT
     C                   ENDIF
      * print current job information
     C   90              CALLP     dp('Job information')
     C   90              CALLP     dp('  Job            : ' +
     C                                %TRIM(job_number) + '/' +
     C                                %TRIM(user_name) + '/' +
     C                                %TRIM(job_name))
     C   90              CALLP     dp('  activated time : ' + act_time)
     C   90              CALLP     dp('  jobccsid       : ' + n2c(jobccsid))
     C   90              CALLP     dp('  dftjobccsid    : ' + n2c(dftjobccsid))
     C   90              CALLP     dp(' ')
      * prepare translation table for SMTP session
     C   90              CALLP     dp('Open character conversion routine.')
      *   set 'from' CCSID to ASCII(ISO-8859-1)
     C                   MOVE      '00819'       iconv_frmccsid
      *   set 'to' CCSID to EBCDIC
     C                   IF        hdrccsid = 0
     C                   MOVE      dftjobccsid   iconv_toccsid
      *       specific CCSID
     C                   ELSE
     C                   MOVE      hdrccsid      iconv_toccsid
     C                   ENDIF
      *       use only SBCS characters here
     C                   IF        iconv_toccsid = '05026' or
     C                             iconv_toccsid = '01390'
     C                   MOVE      '00290'       iconv_toccsid
     C                   ENDIF
     C                   IF        iconv_toccsid = '05035' or
     C                             iconv_toccsid = '01399'
     C                   MOVE      '01027'       iconv_toccsid
     C                   ENDIF
      *   open iconv
     C                   EVAL      iconv_index = 5
     C                   EXSR      #ICONV_O
      *   generate translation table variables
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp(' Translation table for XLATE.')
     C     5             OCCUR     iconv_t_a
      *     US ASCII character set
      *       X'A2' = Cent sign, X'A3' = Pound sign, X'A5' = Yen sign
     C                   MOVE      *BLANKS       a_c_256         256
     C                   EVAL      rc = iconvw(a_x + X'A2A3A5' + NULL : a_c_256)
      *       iconv() returned error
     C                   IF        rc < 0
     C                   CALLP     em(em1(18) : ' RC=' + %TRIMR(n2c(rc)))
     C                   EXSR      #ABORT
     C                   ENDIF
      *     print EBCDIC internal table
     C                   MOVEL     a_c_256       a_c_c
     C                   MOVEL     a_c_c         a_c
     C   90              CALLP     dp(' a_c_c :' + a_c_c)
     C                   EVAL      a_c_x = a_x + X'0D0A' + X'1B'
      *     variant characters
     C                   EVAL      lk = %SUBST(a_c : 60 : 1)
     C                   EVAL      rk = %SUBST(a_c : 62 : 1)
     C                   EVAL      hat = %SUBST(a_c : 63 : 1)
     C                   EVAL      vb = %SUBST(a_c : 93 : 1)
     C     2             SUBST     a_c_c:96      CRLF_e            2
     C     1             SUBST     a_c_c:98      ESC_e             1
      *   close iconv
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Close character conversion routine.')
     C                   EXSR      #ICONV_C
      * Print input parameters
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Input Parameters')
      *   'from'
     C   90              CALLP     dp('  From     : ' + lk +
     C                                %TRIM(from_mailaddr) + rk + ' ' + lk +
     C                                %TRIM(from_desc) + rk)
      *   'to'
     C   90              CALLP     dp('  To       : ' + %TRIMR(n2c(to_list)) +
     C                                ' recipient(s)')
     C                   DO        to_list       I
     C                   EVAL      recp_type =
     C                                     %SUBST(to : to_replacem(I) + 131 : 4)
     C   90              CALLP     dp('             ' + lk + %TRIM(%SUBST(
     C                                to : to_replacem(I) +  3 : 64
     C                                      )) + rk + ' ' + lK + %TRIM(%SUBST(
     C                                to : to_replacem(I) + 67 : 64
     C                                      )) + rk + ' ' + lk + recp_type + rk)
     C                   DO        3             J
     C                   IF        recp_type = recp_type_a(J)
     C                   ADD       1             recp_num(J)
     C                   ENDIF
     C                   ENDDO
     C                   ENDDO
      *   'body'
     C                   EVAL      bdyf =
     C                                %TRIM(%SUBST(body_file : 11 : 10)) + '/' +
     C                                %TRIM(%SUBST(body_file :  1 : 10))
     C                   IF        body_member <> '*FIRST'
     C                   EVAL      bdyf = %TRIMR(bdyf) + '(' +
     C                                %TRIM(body_member) + ')'
     C                   ENDIF
     C   90              CALLP     dp('  File     : ' + %TRIMR(bdyf))
      *   'subject'
     C   90              CALLP     dp('  Subject  : ' + lk + %TRIMR(subject)
     C                                                                    + rk)
      *   'attachment'
     C   90              CALLP     dp('  Attach   : ' + %TRIMR(n2c(at_list)) +
     C                                ' attachment(s)')
     C                   Z-ADD     0             I
     C                   DOW       at_list > I
     C                   ADD       1             I
     C   90              CALLP     dp('              ' + lk + %TRIM(at_elem(I))
     C                                                                    + rk)
     C                   ENDDO
      *   'replyto'
     C                   IF        %LEN(%TRIM(repto_mailaddr)) = 0
     C                   EVAL      repto_list = 0
     C   90              CALLP     dp('  Reply-To : none')
     C                   ELSE
     C   90              CALLP     dp('  Reply-To : ' + lk +
     C                                %TRIM(repto_mailaddr) + rk + ' ' + lk +
     C                                %TRIM(repto_desc) + rk)
     C                   ENDIF
      *   'smtphost'
     C   90              CALLP     dp('  SMTPhost : '+lk + %TRIM(smtphost) + rk)
      *   'CCSID'
     C   90              CALLP     dp('  DBFCCSID : ' + %TRIMR(n2c(dbfccsid))
     C                                   + ' (0 = *DFTJOBCCSID, -1 = *FILE)')
     C   90              CALLP     dp('  HDRCCSID : ' + %TRIMR(n2c(hdrccsid))
     C                                   + ' (0 = *DFTJOBCCSID)')
      *   other options
     C   90              CALLP     dp('  options  : invalidDBCS = ' +
     C                                %TRIM(invalidDBCS) + ', debug = ' + debug)
     C   90              CALLP     dp(' ')
      * get body_file information
     C                   EVAL      rc = getpfinfo(spc_name : body_file :
     C                                  actual_name : pflf : file_type :
     C                                  pgmd : max_fields : record_len :
     C                                  file_ccsid : excp)
     C                   IF        rc <> 0
     C                   CALLP     em(em1(3) : 'FILE-' + %TRIM(bdyf) + ', RC=' +
     C                                %TRIMR(n2c(rc)) + ', ' + excp)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   MOVE      *BLANKS       as400name        21
     C                   EVAL      as400name =
     C                                %TRIMR(%SUBST(actual_name : 11 : 10)) +
     C                                '/' +
     C                                %TRIMR(%SUBST(actual_name :  1 : 10))
     C   90              CALLP     dp('body_file information')
     C   90              CALLP     dp('  Actual file    : ' + as400name)
     C   90              CALLP     dp('  PF or LF       : ' + pflf)
     C   90              CALLP     dp('  PF type        : ' + file_type)
     C   90              CALLP     dp('  PGM described? : ' + pgmd)
     C   90              CALLP     dp('  Max fields     : ' + n2c(max_fields))
     C   90              CALLP     dp('  Max record len : ' + n2c(record_len))
     C   90              CALLP     dp('  File CCSID     : ' + n2c(file_ccsid))
      *   file must be *SRC or program described file
     C                   IF        file_type <> '*SRC'
     C                   IF        pgmd <> '*PGM'
     C                   CALLP     em(em1(4) : 'FILE-' + %TRIMR(as400name) +
     C                                       ', PF/LF-' + pflf +
     C                                       ', TYPE-' + file_type +
     C                                       ', DESCRIBE-' + pgmd)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   ENDIF
      *   text length must be 80
     C                   IF        (file_type = '*SRC' and record_len <> 92) or
     C                             (file_type = '*DATA' and record_len <> 80)
     C                   CALLP     em(em1(5) : 'FILE-' + %TRIMR(as400name) +
     C                                         ', RECORDLEN-' + n2c(record_len))
     C                   EXSR      #ABORT
     C                   ENDIF
      *   file CCSID out of range (37 - 61712 allowed)
     C                   IF        file_ccsid < 37 or 61712 < file_ccsid
      *** 2000/01/03 modify to allow CCSID 65535 (program-described file)
     C   90              CALLP     dp('  File CCSID ' + %TRIMR(n2c(file_ccsid))
     C                                + ' may not valid, trying anyway...')
     C*                  CALLP     em(em1(6) : 'FILE-' + %TRIMR(as400name) +
     C*                                        ', CCSID-' + n2c(file_ccsid))
     C*                  EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp(' ')
      * check attachment files (STMF)
     C                   IF        at_list > 0
     C   90              CALLP     dp('Attachment file(s) information')
     C                   ENDIF
      *
     C                   DO        at_list       I
     C                   EVAL      atcfn = %TRIM(at_elem(I)) + NULL
     C                   IF        -1 = stat(%ADDR(atcfn) : %ADDR(statinfo))
     C                   CALLP     em(em1(7) : 'PATH-' + at_elem(I) : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
      *   extract file name from path
     C                   EVAL      rc = getfilename(at_elem(I) : atc_fname(I))
      *   store st_size to array
     C                   EVAL      atc_st_size(I) = st_size
      *   print file information
     C   90              CALLP     dp('  PATH-''' + %TRIMR(at_elem(I)) +
     C                                ''', FILENAME-''' + %TRIMR(atc_fname(I)) +
     C                                ''', SIZE-' +
     C                                %TRIMR(n2c(st_size)) + ', TYPE-' +
     C                                %TRIMR(%SUBST(st_objtype : 1 : 10)) + '.')
      *   invalid file name
     C                   IF        rc < 0
     C                   CALLP     em(em1(24) : ' RC=' + %TRIMR(n2c(rc)) +
     C                                    ', PATH-' + %TRIM(at_elem(I)))
     C                   EXSR      #ABORT
     C                   ENDIF
      *   path must be stream file or doc
     C                   IF        (%SUBST(st_objtype : 1 : 10)  <> '*STMF') AND
     C                             (%SUBST(st_objtype : 1 : 10)  <> '*DOC')  AND
     C                             (%SUBST(st_objtype : 1 : 10)  <> '*DSTMF')
     C                   CALLP     em(em1(17) : 'PATH-' + %TRIM(at_elem(I)) +
     C                             ', TYPE-' + %SUBST(st_objtype : 1 : 10))
     C                   EXSR      #ABORT
     C                   ENDIF
      *   file size is 0
     C                   IF        st_size = 0
     C                   CALLP     em(em1(27) : 'PATH-' + at_elem(I))
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   ENDDO
      * check work directory
      *   root directory not allowed
     C                   IF        tmpdir = '/'
     C                   CALLP     em(em1(34) : ' ')
     C                   EXSR      #ABORT
     C                   END
     C                   EVAL      tmpdirn = %TRIM(tmpdir) + NULL
      *   path not available
     C                   IF        -1 = stat(%ADDR(tmpdirn) : %ADDR(statinfo))
     C                   CALLP     em(em1(8) : 'PATH-' + tmpdir : 1)
     C                   EXSR      #ABORT
     C                   END
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Work directory is '''
     C                                    + %TRIM(tmpdir) + '''')
      *   path not directory
     C                   IF        %SUBST(st_objtype : 1 : 10)  <> '*DIR'
     C                   CALLP     em(em1(9) : 'PATH-' + %TRIM(tmpdir) +
     C                             ', TYPE-' + %SUBST(st_objtype : 1 : 10))
     C                   EXSR      #ABORT
     C                   ENDIF
      *
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Paramater check passed.')
     C   90              CALLP     dp(' ')
      *
     C                   ENDSR
      *****************************************************************
