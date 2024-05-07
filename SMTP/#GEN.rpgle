      *****************************************************************
      * Generate message
     C     #GEN          BEGSR
     C   90              CALLP     dp('Start generating mail message.')
      * read the environment variable, 'PREENCODEDMAILMESSAGE'
     C                   EVAL      envname = 'PREENCODEDMAILMESSAGE' + NULL
     C                   EVAL      env_p = getenv(%ADDR(envname) :
     C                                            %ADDR(envccsid))
     C                   IF        (env_p <> *NULL) and (%LEN(%STR(env_p)) > 0)
     C                   EVAL      tmpf = %STR(env_p)
     C                   EVAL      tmpfn = %TRIM(tmpf) + NULL
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Skip generation, use pre-encoded file '''
     C                                + %TRIM(tmpf)  + '''.')
     C                   GOTO      #GENEXIT
     C                   ENDIF
      * open character conversion routine
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Open character conversion routine.')
      *   Mail header
      *     Determine CCSID for mail header information (description, subject)
      *       *DFTJOBCCSID
     C                   IF        hdrccsid = 0
     C                   MOVE      dftjobccsid   iconv_frmccsid
      *       specific CCSID
     C                   ELSE
     C                   MOVE      hdrccsid      iconv_frmccsid
     C                   ENDIF
      *       ISO-2022-JP (Japanese)
     C                   IF        iconv_frmccsid = '05026' OR
     C                             iconv_frmccsid = '05035' OR
     C                             iconv_frmccsid = '01390' OR
     C                             iconv_frmccsid = '01399'
      *         another mail header for DBCS encode (to2022)
     C                   EVAL      iconv_index = 3
     C                   MOVE      '00932'       iconv_toccsid
     C                   EXSR      #ICONV_O
     C                   SETON                                        33
     C                   MOVE      '05052'       iconv_toccsid
      *       ISO-8859-1 (Latin-1)
     C                   ELSE
     C                   MOVE      '00819'       iconv_toccsid
     C                   ENDIF
     C                   EVAL      iconv_index = 1
     C                   EXSR      #ICONV_O
      *   message text (file)
      *     Determine CCSID for message body file
     C                   SELECT
      *       *DFTJOBCCSID
     C                   WHEN      dbfccsid = 0
     C                   MOVE      dftjobccsid   iconv_frmccsid
      *       *FILE
     C                   WHEN      dbfccsid = -1
     C                   MOVE      file_ccsid    iconv_frmccsid
      *       specific CCSID
     C                   OTHER
     C                   MOVE      dbfccsid      iconv_frmccsid
     C                   ENDSL
      *       ISO-2022-JP (Japanese)
     C                   IF        iconv_frmccsid = '05026' OR
     C                             iconv_frmccsid = '05035' OR
     C                             iconv_frmccsid = '01390' OR
     C                             iconv_frmccsid = '01399'
      *         another mail header for DBCS encode (to2022)
     C                   EVAL      iconv_index = 4
     C                   MOVE      '00932'       iconv_toccsid
     C                   EXSR      #ICONV_O
     C                   SETON                                        34
     C                   MOVE      '05052'       iconv_toccsid
      *       ISO-8859-1 (Latin-1)
     C                   ELSE
     C                   MOVE      '00819'       iconv_toccsid
     C                   ENDIF
     C                   EVAL      iconv_index = 2
     C                   EXSR      #ICONV_O
      * open work file to write mail message
     C                   TIME                    curtime
     C                   MOVE      curtime       curtimec         26
     C                   EVAL      tmpf = %TRIM(tmpdir) + '/SNDM_' +
     C                                    %TRIM(job_number) + '-' +
     C                                    %TRIM(user_name) + '-' +
     C                                    %TRIM(job_name) + '_' +
     C                                    %SUBST(curtimec : 1 : 23) + '.TXT'
      *
     C                   EVAL      tmpfn = %TRIMR(tmpf) + NULL
     C                   EVAL      tmpfd = creat(%ADDR(tmpfn) : 448)
     C                   IF        tmpfd = -1
     C                   CALLP     em(em1(10) : 'PATH-' + tmpf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
      *
     C                   EVAL      tmpfexists  = 1
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Mail message will be stored to ''' +
     C                                %TRIM(tmpf)  + ''' temporarily.')
      * Generate mail header
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Compose mail header...')
      *   Structured header items
     C                   EVAL      structured = 1
      *   'From'
     C                   EVAL      tmpfwblen = encodemailaddr('From:' :
     C                                    from_mailaddr : from_desc : tmpfwb)
      *     conversion/encode error
     C                   EVAL      header_info = 'FROM'
     C                   EVAL      header_value = from_desc
     C                   EXSR      #HENCE
      *     write to work file
     C                   EXSR      #WTMPFA
     C   90              CALLP     dp('  ''From:'' field, length-' +
     C                                   %TRIMR(n2c(tmpfwblen)) + ', charset=' +
     C                                   %TRIMR(charset) + '.')
      *   recipients ('To', 'cc'. exclude 'bcc')
     C                   DO        2             I
     C                   DO        to_list       J
     C                   EVAL      recp_type =
     C                                     %SUBST(to : to_replacem(J) + 131 : 4)
     C                   IF        recp_type = recp_type_a(I)
     C                   EVAL      tmpfwblen = encodemailaddr(recp_text_a(I) :
     C                               %SUBST(to : to_replacem(J) +  3 : 64) :
     C                               %SUBST(to : to_replacem(J) + 67 : 64) :
     C                                                                tmpfwb)
      *     conversion/encode error
     C                   EVAL      header_info = 'ELEM=' +
     C                                       %TRIMR(n2c(J)) + ', TO'
     C                   EVAL      header_value =
     C                                     %SUBST(to : to_replacem(J) + 67 : 64)
     C                   EXSR      #HENCE
     C                   SUB       1             recp_num(I)
     C                   IF        recp_num(I) > 0
     C                   EVAL      tmpfwblen = tmpfwblen + 1
     C                   EVAL      %SUBST(tmpfwb : tmpfwblen : 1) = ','
     C                   ENDIF
      *     write to work file
     C                   EXSR      #WTMPFA
     C   90              CALLP     dp('  ''To:'' field, type-' + %TRIMR(
     C                                   recp_type) + ', element number-' +
     C                                   %TRIMR(n2c(J)) + ', length-' +
     C                                   %TRIMR(n2c(tmpfwblen)) +
     C                                   ', charset=' + %TRIMR(charset) + '.')
     C                   MOVE      '     '       recp_text_a(I)
     C                   ENDIF
     C                   ENDDO
     C                   ENDDO
      *   'Reply-to'
     C                   IF        repto_list > 0
     C                   EVAL      tmpfwblen = encodemailaddr('Reply-To:' :
     C                                    repto_mailaddr : repto_desc : tmpfwb)
      *     conversion/encode error
     C                   EVAL      header_info = 'REPLYTO'
     C                   EVAL      header_value = repto_desc
     C                   EXSR      #HENCE
      *     write to work file
     C                   EXSR      #WTMPFA
     C   90              CALLP     dp('  ''Reply-To:'' field, length-' +
     C                                   %TRIMR(n2c(tmpfwblen)) +
     C                                   ', charset=' + %TRIMR(charset) + '.')
     C                   ENDIF
      *   Non-structured header items
     C                   EVAL      structured = 0
      *   'Subject'
     C                   EVAL      tmpfwblen = smtphead(subject : tmpfwb)
      *     conversion/encode error
     C                   EVAL      header_info = 'SUBJECT'
     C                   EVAL      header_value = subject
     C                   EXSR      #HENCE
      *     write to work file
     C                   EVAL      tmpfwb = 'Subject: ' + tmpfwb
     C                   EVAL      tmpfwblen = tmpfwblen + 9
     C                   EXSR      #WTMPFA
     C   90              CALLP     dp('  ''Subject:'' field, length-' +
     C                                   %TRIMR(n2c(tmpfwblen)) +
     C                                   ', charset=' + %TRIMR(charset) + '.')
      *   'Date'
     C                   IF        -1 = cdate(tmpfwb : excp)
     C                   CALLP     em(em1(12) : excp)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   EVAL      boundary = %SUBST(tmpfwb : 6 : 20)
     C                   EVAL      tmpfwb = 'Date: ' + %SUBST(tmpfwb : 1 : 31)
     C                   EVAL      tmpfwblen = 37
     C                   EXSR      #WTMPFA
     C   90              CALLP     dp('  ''Date:'' field, length-' +
     C                                   %TRIMR(n2c(tmpfwblen)) + '.')
      *   'MIME-Version'
     C                   EVAL      tmpfwb = 'MIME-Version: 1.0'
     C                   EVAL      tmpfwblen = 17
     C                   EXSR      #WTMPFA
      *   'Content-Type'
     C                   EXSR      #CHKBODY
      *     multipart
     C                   IF        at_list > 0
      *       if day is one digit, add preceding '0'
     C                   IF        %SUBST(boundary : 2 : 1) = ' '
     C                   EVAL      boundary = '0' + boundary
     C                   ENDIF
     C                   EVAL      boundary = '--=_Next_Part_' +
     C                                        %SUBST(boundary : 1 : 2) + '_' +
     C                                        %SUBST(boundary : 4 : 3) + '_' +
     C                                        %SUBST(boundary : 8 : 4) + '_' +
     C                                        %SUBST(boundary : 13 : 2) + '.' +
     C                                        %SUBST(boundary : 16 : 2) + '.' +
     C                                        %SUBST(boundary : 19 : 2)
      * 2002-05-06 removed space characters between "boundary" and "=".
     C                   EVAL      tmpfwb = 'Content-Type: multipart/mixed; ' +
     C                                      'boundary="' + boundary + '"'
     C*                                     'boundary = "' + boundary + '"'
     C                   EVAL      tmpfwblen = 44 + 34
     C                   EXSR      #WTMPFA
      *     text only
     C                   ELSE
     C*                  IF        charset <> 'US-ASCII'
     C                   EVAL      tmpfwb = 'Content-Type: text/plain; ' +
     C                                      'charset="' + %TRIMR(charset) + '"'
     C                   EVAL      tmpfwblen = 36 + %LEN(%TRIMR(charset))
     C                   IF        charset = 'ISO-8859-1'
     C                   EVAL      %SUBST(tmpfwb : tmpfwblen + 1) = CRLF +
     C                                      'Content-Transfer-Encoding: ' +
     C                                      'quoted-printable'
     C                   EVAL      tmpfwblen = tmpfwblen + 45
     C                   ENDIF
     C                   EXSR      #WTMPFA
     C*                  ENDIF
     C                   ENDIF
      *   Additional mail header information
     C                   EVAL      tmpfwb = 'X-Mailer: SMTP Client for IBM ' +
     C                                      'OS400  version ' + version
     C                   EVAL      tmpfwblen = 45 + %LEN(version)
     C                   EXSR      #WTMPFA
      *   end of mail header
     C                   EVAL      tmpfwblen = 0
     C                   EXSR      #WTMPFA
      * Mail body
      *   multipart message
     C                   IF        at_list > 0
     C                   EVAL      tmpfwb = 'This is a multi-part message in' +
     C                                      ' MIME format.' + CRLF
     C                   EVAL      tmpfwblen = 46
     C                   EXSR      #WTMPFA
      *     write boundary
     C                   EVAL      tmpfwb = '--' + boundary
     C                   EVAL      tmpfwblen = 36
     C                   EXSR      #WTMPFA
      *     'Content-Type: text/plain'
     C*                  IF        charset <> 'US-ASCII'
     C                   EVAL      tmpfwb = 'Content-Type: text/plain; ' +
     C                                      'charset="' + %TRIMR(charset) + '"'
     C                   EVAL      tmpfwblen = 36 + %LEN(%TRIMR(charset))
     C                   IF        charset = 'ISO-8859-1'
     C                   EVAL      %SUBST(tmpfwb : tmpfwblen + 1) = CRLF +
     C                                      'Content-Transfer-Encoding: ' +
     C                                      'quoted-printable'
     C                   EVAL      tmpfwblen = tmpfwblen + 45
     C                   ENDIF
     C                   EVAL      %SUBST(tmpfwb : tmpfwblen + 1) = CRLF
     C                   EVAL      tmpfwblen = tmpfwblen + 2
     C                   EXSR      #WTMPFA
     C*                  ENDIF
     C                   ENDIF
      *   message text
     C                   EXSR      #WBODY
      *   attachment file(s)
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Base64 encode for ' + %TRIM(n2c(at_list))
     C                                + ' attachment file(s).')
     C                   DO        at_list       I
      *     write boundary
     C                   EVAL      tmpfwb = CRLF + '--' + boundary
     C                   EVAL      tmpfwblen = 38
     C                   EXSR      #WTMPFA
      *     'Content-Type: application/octet-stream'
     C                   EVAL      tmpfwb = 'Content-Type: ' +
     C                                      'application/octet-stream; name="' +
     C                                      %TRIMR(atc_fname(I)) + '"'
     C                   EVAL      tmpfwblen = %LEN(%TRIMR(tmpfwb))
     C                   EXSR      #WTMPFA
     C                   EVAL      tmpfwb = 'Content-Transfer-Encoding: ' +
     C                                      'base64'
     C                   EVAL      tmpfwblen = 33
     C                   EXSR      #WTMPFA
      * 2003-04-06 added "Content-Disposition" header.
     C                   EVAL      tmpfwb = 'Content-Disposition: attachment;' +
     C                                      CRLF + ' filename="' +
     C                                      %TRIMR(atc_fname(I)) + '"' + CRLF
     C                   EVAL      tmpfwblen = %LEN(%TRIMR(tmpfwb))
     C                   EXSR      #WTMPFA
      *     base64 encode
     C                   EXSR      #WATC
     C                   ENDDO
      * end of mail message
      *   multipart message
     C                   IF        at_list > 0
     C                   EVAL      tmpfwb = CRLF + '--' + boundary + '--' + CRLF
     C                   EVAL      tmpfwblen = 42
     C                   EXSR      #WTMPFA
     C                   ENDIF
      *   close temp file
     C                   IF        -1 = close(tmpfd)
     C                   CALLP     em(em1(31) : ' PATH-' + tmpf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('file ''' + %TRIM(tmpf) + ''' closed.')
      *   close character conversion routine
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Close character conversion routine.')
     C                   EVAL      iconv_index = 1
     C                   EXSR      #ICONV_C
     C                   EVAL      iconv_index = 2
     C                   EXSR      #ICONV_C
     C   33              EVAL      iconv_index = 3
     C   33              EXSR      #ICONV_C
     C   34              EVAL      iconv_index = 4
     C   34              EXSR      #ICONV_C
      *
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Mail message generated. Total ' +
     C                                %TRIMR(n2c(tmpf_size)) + ' byte.')
      *
     C     #GENEXIT      TAG
     C                   ENDSR
      *****************************************************************
      * open iconv
     C     #ICONV_O      BEGSR
      *
     C     iconv_index   OCCUR     iconv_t_a
     C                   EVAL      iconv_t_a = iconv_o(%ADDR(tocode) :
     C                                                 %ADDR(fromcode))
     C                   IF        iconv_a_ret = -1
     C                   CALLP     em(em1(11) : ' CCSID ' + iconv_frmccsid +
     C                                               '->' + iconv_toccsid : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  iconv_o() successful. OCCUR ' +
     C                                %TRIMR(n2c(iconv_index)) + ', ' +
     C                                iconv_frmccsid + '->' + iconv_toccsid)
      *
     C                   ENDSR
      *****************************************************************
      * close iconv
     C     #ICONV_C      BEGSR
      *
      * close character conversion routine
      *
     C     iconv_index   OCCUR     iconv_t_a
     C                   IF        -1 = iconv_c(iconv_t_a)
     C                   CALLP     em(em1(33) : ' OCCUR ' + n2c(iconv_index))
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  iconv closed. OCCUR ' +
     C                                   %TRIMR(n2c(iconv_index)) + '.')
      *
     C                   ENDSR
      *****************************************************************
      * header encodng error
     C     #HENCE        BEGSR
      * invalid character in mail address description
     C                   IF        tmpfwblen = -4
     C                   CALLP     em(em1(35) : %TRIM(header_info) + '-' + lk +
     C                                   %TRIM(header_value) + rk)
     C                   EXSR      #ABORT
     C                   ENDIF
      * iconv() returned error
     C                   IF        tmpfwblen < 0
     C                   CALLP     em(em1(18) : ' RC=' +
     C                                   %TRIMR(n2c(tmpfwblen)) +
     C                                   ', ' + %TRIM(header_info) + '-' + lk +
     C                                   %TRIM(header_value) + rk : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
      * non-JIS DBCS character found
     C                   IF        invalidDBCSn > 0 and invalidDBCS = '*ABORT'
     C                   CALLP     em(em1(19) : %TRIM(header_info) + '-' + lk +
     C                                   %TRIM(header_value) + rk)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   IF        invalidDBCSn > 0
     C                   EVAL      rc = sndpm(%TRIMR(em3(3)) + ' (' +
     C                                     %TRIM(header_info) + ')' : 3 : excp)
     C                   ENDIF
      *
     C                   ENDSR
      *****************************************************************
      * convert EBCDIC to ASCII / add CRLF / write to temporaly file
     C     #WTMPFA       BEGSR
      *
      * append CRLF to write buffer
     C                   EVAL      %SUBST(tmpfwb : tmpfwblen + 1 : 2) = CRLF
     C                   EVAL      tmpfwblen = tmpfwblen + 2
      * 512 byte (tmpfwb) is too long for most message
     C                   IF        tmpfwblen > 100
     C     a_c:a_x       XLATE     tmpfwb        tmpfwb
     C                   ELSE
     C                   MOVEL     tmpfwb        tmpfwb2         100
     C     a_c:a_x       XLATE     tmpfwb2       tmpfwb2
     C                   MOVEL     tmpfwb2       tmpfwb
     C                   ENDIF
      *
     C                   EXSR      #WTMPF
      *
     C                   ENDSR
      *****************************************************************
      * write to temporaly file
     C     #WTMPF        BEGSR
      *
      * write XLATEd message (ASCII) to temp file
     C                   EVAL      bytesw = write(tmpfd : %ADDR(tmpfwb)
     C                                                            : tmpfwblen)
     C                   IF        bytesw = -1
     C                   CALLP     em(em1(16) : 'PATH-' + tmpf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
      * write operation not complete
     C                   IF        bytesw <> tmpfwblen
     C                   CALLP     em(em1(26) : 'PATH-' + %TRIM(tmpf) +
     C                                   ', ' + %EDITC(bytesw : '3') +
     C                                   ' / ' + %EDITC(tmpfwblen : '3'))
     C                   EXSR      #ABORT
     C                   ENDIF
      * accumulate total bytes written to temp file
     C                   EVAL      tmpf_size = tmpf_size + bytesw
      *
     C                   ENDSR
      *****************************************************************
      * check message text encoding
     C     #CHKBODY      BEGSR
      *
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Process message body file ''' +
     C                                %TRIMR(bdyf) +'''.')
      *
     C                   EVAL      charset = 'US-ASCII'
     C                   Z-ADD     0             nonascii_rcd      9 0
     C                   MOVE      *BLANKS       nonascii_txt     89
      * open body file
     C                   EVAL      bdyfn = %TRIMR(bdyf) + X'00'
     C                   EVAL      bdyf_mode = %TRIMR(bdyf_mode) + ' ccsid=' +
     C                                 %TRIM(%EDITC(file_ccsid : '3')) + X'00'
     C                   EVAL      bdyfp = fopen(%ADDR(bdyfn) :
     C                                                       %ADDR(bdyf_mode))
     C                   IF        bdyfp = *NULL
     C                   CALLP     em(em1(13) : 'FILE-' + bdyf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  body file opened.')
      *
D    C                   DO        *HIVAL
      * fread() raised error - confirm error reason
 I   C                   IF        fread(%ADDR(bdyfrb) : 1 : 9999 : bdyfp) < 1
      *   read error
  I  C                   IF        ferror(bdyfp) <> 0
     C                   CALLP     em(em1(14) : 'FILE-' + bdyf : 1)
     C                   EXSR      #ABORT
  E  C                   ENDIF
      *   EOF
  I  C                   IF        feof(bdyfp) <> 0
     C   90              CALLP     dp('  End of file.')
  X  C                   ELSE
     C                   CALLP     em(em1(15) : 'FILE-' + bdyf : 1)
     C                   EXSR      #ABORT
  E  C                   ENDIF
<-   C                   LEAVE
 E   C                   ENDIF
      *
     C                   ADD       1             nonascii_rcd
      *   remove SEQNO and DATE from source file
 I   C                   IF        file_type = '*SRC'
     C                   EVAL      bdyfrb = %SUBST(bdyfrb : 13 : 80)
 E   C                   ENDIF
     C                   EVAL      bdyfrblen = %LEN(%TRIMR(bdyfrb))
      *   Non-ASCII character exists?
 D   C                   DO        bdyfrblen     I
  I  C                   IF        %SCAN(%SUBST(bdyfrb : I : 1) : a_c) = 0
     C   90              CALLP     dp('  non-ascii character found at record ' +
     C                                %TRIMR(n2c(nonascii_rcd)) +
     C                                ', column ' + %TRIMR(n2c(I)) + '.')
     C   90              CALLP     dp('  text-' + lk + %TRIMR(bdyfrb) + rk)
     C   90              EVAL      %SUBST(nonascii_txt : I + 8 : 1) = hat
     C   90              CALLP     dp(nonascii_txt)
     C                   SELECT
     C                   WHEN      file_ccsid = 5026 OR file_ccsid = 5035 OR
     C                             file_ccsid = 1390 OR file_ccsid = 1399
     C                   EVAL      charset = 'ISO-2022-JP'
     C                   OTHER
     C                   EVAL      charset = 'ISO-8859-1'
     C                   ENDSL
     C                   LEAVE
  E  C                   ENDIF
 E   C                   ENDDO
      *
 I   C                   IF        charset <> 'US-ASCII'
<-   C                   LEAVE
 E   C                   ENDIF
      *
E    C                   ENDDO
      * close body file
     C                   IF        fclose(bdyfp) <> 0
     C                   CALLP     em(em1(16) : 'FILE-' + bdyf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  body file closed.')
     C   90              CALLP     dp('  Message text charset = ' + charset)
      *
     C                   ENDSR
      *****************************************************************
      * write message text to temp file
     C     #WBODY        BEGSR
      *
     C                   Z-ADD     0             bdyf_line         9 0
      * reopen body file
     C                   EVAL      bdyfp = fopen(%ADDR(bdyfn) :
     C                                                       %ADDR(bdyf_mode))
     C                   IF        bdyfp = *NULL
     C                   CALLP     em(em1(13) : 'FILE-' + bdyf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  body file reopened.')
      *
D    C                   DO        *HIVAL
      * fread() raised error - confirm error reason
 I   C                   IF        fread(%ADDR(bdyfrb) : 1 : 9999 : bdyfp) < 1
      *   read error
  I  C                   IF        ferror(bdyfp) <> 0
     C                   CALLP     em(em1(14) : 'FILE-' + bdyf : 1)
     C                   EXSR      #ABORT
  E  C                   ENDIF
      *   EOF
  I  C                   IF        feof(bdyfp) <> 0
     C   90              CALLP     dp('  End of file.')
  X  C                   ELSE
     C                   CALLP     em(em1(15) : 'FILE-' + bdyf : 1)
     C                   EXSR      #ABORT
  E  C                   ENDIF
<-   C                   LEAVE
 E   C                   ENDIF
      *   remove SEQNO and DATE from source file
 I   C                   IF        file_type = '*SRC'
     C                   EVAL      bdyfrb = %SUBST(bdyfrb : 13 : 80)
 E   C                   ENDIF
     C                   EVAL      bdyfrblen = %LEN(%TRIMR(bdyfrb))
     C                   ADD       1             bdyf_line
      *   write to temp file
      *     blank line
     C                   IF        bdyfrblen = 0
     C                   EVAL      tmpfwb = CRLF
     C                   EVAL      tmpfwblen = 2
     C                   EXSR      #WTMPF
      *     process by charset
     C                   ELSE
  3  C                   SELECT
  |   *     US-ASCII
  W  C                   WHEN      charset = 'US-ASCII'
     C                   EVAL      tmpfwb = bdyfrb
     C                   EVAL      tmpfwblen = %LEN(%TRIMR(bdyfrb))
      *       for transparency (RFC821 4.5.2.)
     C                   IF        tmpfwblen = 1 and
     C                                     %SUBST(tmpfwb : 1 : 1) = '.'
     C                   EVAL      tmpfwb = '..'
     C                   EVAL      tmpfwblen = 2
     C                   ENDIF
     C                   EXSR      #WTMPFA
      *     ISO-8859-1
  W  C                   WHEN      charset = 'ISO-8859-1'
     C                   EVAL      tmpfwblen = quotedprintable(bdyfrb : tmpfwb)
      *       iconv() failed
     C                   IF        tmpfwblen < 0
     C                   CALLP     em(em1(18) : ' RC=' +
     C                                    %TRIMR(n2c(tmpfwblen)) + ', LINE-' +
     C                                    %TRIMR(n2c(bdyf_line)) + ', FILE-' +
     C                                    bdyf)
     C                   EXSR      #ABORT
     C                   ENDIF
      *       write to temp file
     C                   EVAL      %SUBST(tmpfwb : tmpfwblen + 1 : 2) = CRLF
     C                   ADD       2             tmpfwblen
     C                   EXSR      #WTMPF
      *     ISO-2022-JP
  W  C                   WHEN      charset = 'ISO-2022-JP'
     C                   EVAL      tmpfwblen = to2022(bdyfrb : tmpfwb : 2)
      *       iconv() failed
     C                   IF        tmpfwblen < 0
     C                   CALLP     em(em1(18) : ' RC=' +
     C                                    %TRIMR(n2c(tmpfwblen)) + ', LINE-' +
     C                                    %TRIMR(n2c(bdyf_line)) + ', FILE-' +
     C                                    bdyf)
     C                   EXSR      #ABORT
     C                   ENDIF
      *       invalid DBCS character found
     C                   IF        invalidDBCSn > 0 and invalidDBCS = '*ABORT'
     C                   CALLP     em(em1(19) : ' LINE-' +
     C                                    %TRIMR(n2c(bdyf_line)) + ', FILE-' +
     C                                    bdyf)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   IF        invalidDBCSn > 0
     C                   EVAL      rc = sndpm(%TRIM(em3(3)) + ' FILE-' +
     C                                  %TRIM(bdyf) + ', LINE-' +
     C                                  %TRIMR(n2c(bdyf_line)) : 3 : excp)
     C                   ENDIF
      *       for transparency (RFC821 4.5.2.)
     C                   IF        tmpfwblen = 1 and
     C                                     %SUBST(tmpfwb : 1 : 1) = X'2E'
     C                   MOVEL     X'2E2E'       tmpfwb
     C                   EVAL      tmpfwblen = 2
     C                   ENDIF
      *       write to temp file
     C                   EVAL      %SUBST(tmpfwb : tmpfwblen + 1 : 2) = CRLF
     C                   ADD       2             tmpfwblen
     C                   EXSR      #WTMPF
  |   *
  O  C                   OTHER
  E  C                   ENDSL
     C                   ENDIF
      *
E    C                   ENDDO
      * close body file
     C                   IF        fclose(bdyfp) <> 0
     C                   CALLP     em(em1(16) : 'FILE-' + bdyf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  body file closed. Total ' +  %TRIM(
     C                                %EDITC(bdyf_line : 'P')) + ' line(s).')
      *
     C                   ENDSR
      *****************************************************************
      * encode attachment file and write to temp file
     C     #WATC         BEGSR
      * open attachment file
     C                   EVAL      atcfn = %TRIM(at_elem(I)) + NULL
     C                   EVAL      atcfd = open(%ADDR(atcfn) : 1)
      *
     C                   IF        atcfd = -1
     C                   CALLP     em(em1(21) : 'PATH-' + at_elem(I) : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  ' + %TRIMR(n2c(I)) + '/' +
     C                                       %TRIMR(n2c(at_list)))
     C   90              CALLP     dp('    file ''' + %TRIM(at_elem(I)) +
     C                                        ''' opened for base64 encode.')
     C                   Z-ADD     0             rtotal            9 0
  |  C                   Z-ADD     0             inscrlf           3 0
      * read 2850 byte -> base64 -> write 3900 byte
      *   2850 byte (before encode) = 57(chars/line) * 50(line)
      *   57 -base64encode-> * 4/3 + CRLF = 78byte
      *   78 * 50 = 3900 byte (after encode)
      *
      * read stream file
 D   C                   DO        atc_st_size(I)J
 |   C                   EVAL      atcfrblen = read(atcfd : %ADDR(atcfrb) :
     C                                                                   2850)
     C                   IF        atcfrblen = -1
     C                   CALLP     em(em1(22) : 'PATH-' + at_elem(I) : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
      * end of file
     C                   IF        atcfrblen = 0
 L   C                   LEAVE
 |   C                   ENDIF
     C                   Z-ADD     atcfrblen     b64instrlen       9 0
      * accumulate read bytes
     C                   ADD       atcfrblen     rtotal
      * adjust to miltiply of 3 if less than 2850 bytes read
     C                   IF        atcfrblen < 2850
      *   don't use %DIV/%REM for V4R2 or earlier version
     C     atcfrblen     DIV       3             b64count          9 0
     C                   MVR                     b64mod            1 0
     C     3             SUB       b64mod        b64pad            1 0
     C                   IF        b64mod > 0
     C                   EVAL      %SUBST(atcfrb : atcfrblen + 1 : b64pad)
     C                                                                = X'0000'
     C                   ADD       b64pad        b64instrlen
     C                   ENDIF
     C                   ENDIF
      * Base64 encode. should be faster than procedure call...
     C                   Z-ADD     1             tmpfwblen
  D  C                   DO        b64instrlen   K
  |  C                   EVAL      b64i = %SUBST(atcfrb : K : 3)
  |  C                   MOVE      *ALLX'00'     b64ap
      * 1st byte of outchr
     C                   MOVE      b64i1         b64ap1L
     C                   DIV       4             b64ap1
      * 2nd
     C                   TESTB     '6'           b64i1                    20
     C   20              BITON     '2'           b64ap2L
     C                   TESTB     '7'           b64i1                    20
     C   20              BITON     '3'           b64ap2L
     C                   TESTB     '0'           b64i2                    20
     C   20              BITON     '4'           b64ap2L
     C                   TESTB     '1'           b64i2                    20
     C   20              BITON     '5'           b64ap2L
     C                   TESTB     '2'           b64i2                    20
     C   20              BITON     '6'           b64ap2L
     C                   TESTB     '3'           b64i2                    20
     C   20              BITON     '7'           b64ap2L
      * 3rd
     C                   TESTB     '4'           b64i2                    20
     C   20              BITON     '2'           b64ap3L
     C                   TESTB     '5'           b64i2                    20
     C   20              BITON     '3'           b64ap3L
     C                   TESTB     '6'           b64i2                    20
     C   20              BITON     '4'           b64ap3L
     C                   TESTB     '7'           b64i2                    20
     C   20              BITON     '5'           b64ap3L
     C                   TESTB     '0'           b64i3                    20
     C   20              BITON     '6'           b64ap3L
     C                   TESTB     '1'           b64i3                    20
     C   20              BITON     '7'           b64ap3L
      * 4th
     C                   BITOFF    '01'          b64i3
     C                   MOVE      b64i3         b64ap4L
      *
  |  C                   EVAL      %SUBST(tmpfwbb64 : tmpfwblen : 4) =
     C                                  %SUBST(b64a : b64ap1 + 1 : 1) +
     C                                  %SUBST(b64a : b64ap2 + 1 : 1) +
     C                                  %SUBST(b64a : b64ap3 + 1 : 1) +
     C                                  %SUBST(b64a : b64ap4 + 1 : 1)
  |  C                   ADD       4             tmpfwblen
  |   *   append CRLF in every 19 encodes (57->76byte)
  |  C                   ADD       1             inscrlf
  |I C                   IF        inscrlf = 19
   | C                   EVAL      %SUBST(tmpfwbb64 : tmpfwblen : 2) = CRLF
   | C                   ADD       2             tmpfwblen
   | C                   Z-ADD     0             inscrlf
  |E C                   ENDIF
  E  C                   ENDDO     3
      *
     C                   EVAL      tmpfwblen = tmpfwblen - 1
      * adjust last line
     C                   IF        atcfrblen < 2850
      *   remove appended CRLF
     C                   IF        inscrlf = 0
     C                   SUB       2             tmpfwblen
     C                   ENDIF
      *   adjust '='
     C                   IF        b64mod > 0
     C                   EVAL      %SUBST(tmpfwbb64 : tmpfwblen - b64pad + 1 :
     C                                                b64pad) = X'3D3D'
     C                   ENDIF
      *   add CRLF
     C                   EVAL      %SUBST(tmpfwbb64 : tmpfwblen + 1 : 2) = CRLF
     C                   ADD       2             tmpfwblen
     C                   ENDIF
      * accumulate total bytes written
     C                   ADD       tmpfwblen     wtotal            9 0
      * write to temp file
     C                   EVAL      bytesw = write(tmpfd : %ADDR(tmpfwbb64)
     C                                                            : tmpfwblen)
     C                   IF        bytesw = -1
     C                   CALLP     em(em1(16) : 'PATH-' + tmpf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
      * write operation not complete
     C                   IF        bytesw <> tmpfwblen
     C                   CALLP     em(em1(26) : 'PATH-' + %TRIM(tmpf) +
     C                               ', WROTE-' +
     C                               %TRIMR(n2c(bytesw)) + ', BUFFER-' +
     C                               %TRIMR(n2c(tmpfwblen)) + ')')
     C                   EXSR      #ABORT
     C                   ENDIF
      * accumulate total bytes written to temp file
     C                   EVAL      tmpf_size = tmpf_size + bytesw
      * no more data to read
     C                   IF        atcfrblen < 2850
 L   C                   LEAVE
 |   C                   ENDIF
 |    *
 E   C                   ENDDO     2850
      * close attachment file
     C                   IF        -1 = close(atcfd)
     C                   CALLP     em(em1(23) : 'PATH-' + at_elem(I) : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('    file closed.')
      * compare read total with file size
     C                   IF        rtotal <> atc_st_size(I)
     C                   CALLP     em(em1(25) : 'PATH-' +
     C                               %TRIM(at_elem(I)) + ', READ-' +
     C                               %TRIMR(n2c(rtotal)) + ', FILE-' +
     C                               %TRIMR(n2c(atc_st_size(I))) + ')')
     C                   EXSR      #ABORT
     C                   ENDIF
      * print statistic
     C   90              CALLP     dp('    Total bytes read ' +
     C                               %TRIMR(n2c(rtotal)) + ', bytes written ' +
     C                               %TRIMR(n2c(wtotal)) + '.')
      *
     C                   ENDSR
      *****************************************************************
