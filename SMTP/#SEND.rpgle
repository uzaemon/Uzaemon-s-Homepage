      *****************************************************************
      * send temporary file to SMTP server
     C     #SEND         BEGSR
      *
      * open socket
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Start communication.')
     C                   EVAL      sd = socket(AF_INET : SOCK_STREAM :
     C                                         IPPROTO_IP)
     C                   IF        sd = -1
     C                   CALLP     em(em2(1) : 'socket()' : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   EVAL      socketopened = 1
     C   90              CALLP     dp('  socket() successful. sd = ' + n2c(sd))
      * retreive local host/domain name
     C                   IF        -1 = gethostname(%ADDR(localhost) : 64)
     C                   CALLP     em(em2(12) : 'gethostname()' : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   EVAL      localhost = %STR(%ADDR(localhost))
     C                   IF        0 = %SCAN('.' : localhost)
     C                   CALLP     em(em2(14) : '''.'' missing. ' +
     C                                     'localhost = ' + %TRIMR(localhost))
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   EVAL      localdomain = %SUBST(localhost :
     C                                           %SCAN('.' : localhost) + 1)
     C                   IF        %SUBST(localdomain : 1 : 1) = ' '
     C                   CALLP     em(em2(14) : 'domain name invalid. ' +
     C                                     'localhost = ' + %TRIMR(localhost))
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  local host is ''' +
     C                                         %TRIM(localhost) +
     C                              ''', local domain is ''' +
     C                                         %TRIM(localdomain) + '''.')
      * retreive IP address from host name
     C                   IF        smtphost = '*LOCALHOST'
     C                   EVAL      smtphost = localhost
     C                   ENDIF
     C                   EVAL      smtphostn = %TRIM(smtphost) + NULL
     C                   EVAL      hostp = gethostbyname(%ADDR(smtphostn))
      *
     C                   IF        hostp = *NULL
     C                   CALLP     em(em2(2) : ' HOST-''' + %TRIM(smtphost) +
     C                                                ''' gethostbyname()' : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   EVAL      in_addr_pp = h_addr_list
     C   90              CALLP     dp('  gethostbyname() successful.' +
     C                                ' host ''' + %STR(h_name) +
     C                                ''' (' + %STR(inet_ntoa(s_addr)) + ')' +
     C                                ' retrieved.')
      * establish connection
     C                   EVAL      sin_family = AF_INET
     C                   EVAL      sin_port = 25
     C                   EVAL      sin_addr = s_addr
     C                   EVAL      sin_zero = *ALLX'00'
     C                   IF        -1 = connect(sd : %ADDR(sockaddr_in) :
     C                                         %SIZE(sockaddr_in))
      *
     C                   CALLP     em(em2(3) : 'connect()' : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  connect() successful.')
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Start SMTP session. ''' + CRLF_e +
     C                                     ''' represents CRLF and ''' + ESC_e +
     C                                     ''' represents ESC.')
      *   set read/write mask for select()
     C                   EXSR      #FDSET
      *   set select() time-out (60 seconds)
     C                   EVAL      tv_sec = 60
     C                   EVAL      tv_usec = 0
      *
     C                   EXSR      #READS                                   R<-
      * send SMTP command
     C                   EVAL      wline = 'HELO ' + %TRIMR(localdomain) +
     C                                                              CRLF_e
     C                   EXSR      #WLINE                                   S->
     C                   EXSR      #READS                                   R<-
     C                   EVAL      wline = 'MAIL FROM:<' +
     C                                     %TRIM(from_mailaddr) + '>' + CRLF_e
     C                   EXSR      #WLINE                                   S->
     C                   EXSR      #READS                                   R<-
     C                   DO        to_list       I
     C                   EVAL      wline = 'RCPT TO:<' +
     C                             %TRIM(%SUBST(to : to_replacem(I) +  3 : 64))
     C                                                          + '>' + CRLF_e
     C                   EXSR      #WLINE                                   S->
     C                   EXSR      #READS                                   R<-
     C                   ENDDO
     C                   EVAL      wline = 'DATA' + CRLF_e
     C                   EXSR      #WLINE                                   S->
     C                   EXSR      #READS                                   R<-
      * send body (temporary file)
     C                   EXSR      #SBODY                                   S->
      * end SMTP session
     C                   EVAL      wline = CRLF_e + '.' + CRLF_e
     C                   EXSR      #WLINE                                   S->
     C                   EXSR      #READS                                   R<-
     C                   EVAL      wline = 'QUIT' + CRLF_e
     C                   EXSR      #WLINE                                   S->
     C                   EXSR      #READS                                   R<-
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('SMTP session ended.')
      * end communication
     C                   IF        -1 = close(sd)
     C                   CALLP     em(em2(6) : 'close()' : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   EVAL      socketopened = 0
     C   90              CALLP     dp('  socket closed successfully.')
      *
     C   90              CALLP     dp(' ')
     C   90              CALLP     dp('Program complete.')
      *
     C                   ENDSR
      *****************************************************************
      * set mask (socket descriptor)
     C     #FDSET        BEGSR
      *
     C                   CLEAR                   rwmask
     C                   EVAL      rc = FD_('SET' : sd : %ADDR(rwmask))
      *   failed to set mask
     C                   IF        rc < 0
     C                   CALLP     em(em2(13) : ' RC=' + %TRIMR(n2c(rc)) +
     C                                         ', SD-' + %TRIMR(n2c(sd)) + '.')
     C                   EXSR      #ABORT
     C                   ENDIF
      *
     C   90              CALLP     dp('  select() mask set to ' +
     C                                  %TRIM(%EDITC(rwmask(1) : '3')) + '-' +
     C                                  %TRIM(%EDITC(rwmask(2) : '3')) + '-' +
     C                                  %TRIM(%EDITC(rwmask(3) : '3')) + '-' +
     C                                  %TRIM(%EDITC(rwmask(4) : '3')) + '-' +
     C                                  %TRIM(%EDITC(rwmask(5) : '3')) + '-' +
     C                                  %TRIM(%EDITC(rwmask(6) : '3')) + '-' +
     C                                  %TRIM(%EDITC(rwmask(7) : '3')))
      *
     C                   ENDSR
      *****************************************************************
      * receive data from socket
     C     #READS        BEGSR
      * check if socket readable
     C                   MOVEA     rwmask        rwmask_w
     C                   EVAL      rc = select(sd + 1 : %ADDR(rwmask_w) :
     C                                        *NULL : *NULL : %ADDR(timeval))
     C                   SELECT
      *   select() returned error
     C                   WHEN      rc = -1
     C                   CALLP     em(em2(10) : 'select()' : 1)
     C                   EXSR      #ABORT
      *   select timed out
     C                   WHEN      rc = 0
     C                   CALLP     em(em2(11) : 'select()')
     C                   EXSR      #ABORT
      *   something to read from socket
     C                   OTHER
     C                   EVAL      bytesr = read(sd : %ADDR(rbuf) : 1000)
      *
     C                   IF        bytesr = -1
     C                   CALLP     em(em2(4) : 'read()' : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
      *     server closed socket
     C                   IF        bytesr = 0
     C                   CALLP     em(em2(8) : 'read()')
     C                   EXSR      #ABORT
     C                   ENDIF
      *     check received data
     C                   IF        bytesr < 80
     C                   EVAL      dolinelen = bytesr
     C                   ELSE
     C                   EVAL      dolinelen = 80
     C                   ENDIF
      *     unexpected data (multiline replies, etc.)
     C                   IF        (%SUBST(rbuf : 4 : 1) <> X'20') or
     C                             (bytesr < 4)
     C                   EVAL      rbufx = rbuf
     C     a_c_x:a_c_c   XLATE     rbufx         rbufx
     C                   CALLP     em(em2(20) : ' RSP' + lk +
     C                                  %SUBST(rbufx : 1 : dolinelen) + rk +
     C                                        ' REQ' + lk + %TRIM(wline) + rk)
     C                   EXSR      #ABORT
     C                   ENDIF
      *     SMTP negative response (other than 2xx, 3xx)
     C                   IF        (%SUBST(rbuf : 1 : 1) < X'32') or
     C                             (%SUBST(rbuf : 1 : 1) > X'33')
     C                   EVAL      rbufx = rbuf
     C     a_c_x:a_c_c   XLATE     rbufx         rbufx
     C                   CALLP     em(em2(19) : ' RSP' + lk +
     C                                  %SUBST(rbufx : 1 : dolinelen) + rk +
     C                                        ' REQ' + lk + %TRIM(wline) + rk)
     C                   EXSR      #ABORT
     C                   ENDIF
      *     line not end with CRLF
     C                   IF        %SUBST(rbuf : bytesr - 1 : 2) <> CRLF
     C                   EVAL      rbufx = rbuf
     C     a_c_x:a_c_c   XLATE     rbufx         rbufx
     C                   CALLP     em(em2(9) : ' RSP' + lk +
     C                                  %SUBST(rbufx : 1 : dolinelen) + rk)
     C                   EXSR      #ABORT
     C                   ENDIF
      *     print received data
     C   90              EVAL      fl = 'R<-' + lk
   D C   90              DO        bytesr        K
   | C                   IF        (K + 99) > bytesr
     C                   EVAL      dolinelen = bytesr - K + 1
     C                   ELSE
     C                   Z-ADD     100           dolinelen         3 0
     C                   ENDIF
     C                   EVAL      doline = %SUBST(rbuf : K : dolinelen)
     C     a_c_x:a_c_c   XLATE     doline        doline          100
     C                   CALLP     dp(fl + %SUBST(doline : 1 : dolinelen) + rk)
   | C                   EVAL      fl = '   ' + lk
   E C                   ENDDO     100
      *
     C   90              CALLP     dp('  read ' + %TRIMR(n2c(bytesr))
     C                                          + ' bytes.')
     C                   ENDSL
      *
     C                   ENDSR
      *****************************************************************
      * xlate (EBCDIC -> ASCII) and send line
     C     #WLINE        BEGSR
      *
     C                   EVAL      wbuflen = %LEN(%TRIMR(wline))
     C     a_c_c:a_c_x   XLATE     wline         wlinex
     C                   EVAL      wbuf = wlinex
     C                   EXSR      #WRITES
      *
     C                   ENDSR
      *****************************************************************
      * send message body (temporary file)
     C     #SBODY        BEGSR
     C                   Z-ADD     0             rtotal
      * reopen mail message file
     C                   EVAL      tmpfd = open(%ADDR(tmpfn) : 1)
     C                   IF        tmpfd = -1
     C                   CALLP     em(em1(29) : ' PATH-' + tmpf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  file ''' + %TRIM(tmpf) +
     C                                                     ''' repoened.')
      * read stream file
     C                   DO        *HIVAL
     C                   EVAL      wbuflen = read(tmpfd : %ADDR(wbuf) : 4000)
     C                   IF        wbuflen = -1
     C                   CALLP     em(em1(30) : 'PATH-' + tmpf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
      *   end of file
     C                   IF        wbuflen = 0
     C                   LEAVE
     C                   ENDIF
      *   accumulate read bytes
     C                   ADD       wbuflen       rtotal
     C                   EXSR      #WRITES
      *   no more data to read (maybe)
     C                   IF        wbuflen < 4000
     C                   LEAVE
     C                   ENDIF
      *
     C                   ENDDO
      * close temp file
     C                   IF        -1 = close(tmpfd)
     C                   CALLP     em(em1(31) : ' PATH-' + tmpf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C   90              CALLP     dp('  file ''' + %TRIM(tmpf) + ''' closed.')
      * exit if environment variable, 'PREENCODEDMAILMESSAGE' used
     C                   IF        (env_p <> *NULL) and (%LEN(%STR(env_p)) > 0)
     C                   GOTO      #SBODYEXIT
     C                   ENDIF
      * compare read total with file size
     C                   IF        rtotal <> tmpf_size
     C                   CALLP     em(em1(32) : 'PATH-' +
     C                               %TRIM(tmpf) + ', READ-' +
     C                               %TRIMR(n2c(rtotal)) + ', FILE-' +
     C                               %TRIMR(n2c(tmpf_size)) + ')')
     C                   EXSR      #ABORT
     C                   ENDIF
      * delete temp file
     C                   IF        debug = '*NO '
     C                   IF        -1 = unlink(%ADDR(tmpfn))
     C                   CALLP     em(em1(28) : ' PATH-' + tmpf : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
     C                   EVAL      tmpfexists = 0
     C   90              CALLP     dp('  unlink() successful. file ''' +
     C                                tmpf + ''' deleted.')
     C                   ENDIF
      *
     C     #SBODYEXIT    TAG
     C                   ENDSR
      *****************************************************************
      * send data to socket
     C     #WRITES       BEGSR
      * write until all buffer is sent
     C                   Z-ADD     wbuflen       byteswleft        9 0
 D   C                   DO        *HIVAL
      * check if socket writable
     C                   MOVEA     rwmask        rwmask_w
     C                   EVAL      rc = select(sd + 1 : *NULL :
     C                                 %ADDR(rwmask_w) : *NULL : %ADDR(timeval))
     C                   SELECT
      *   select() returned error
     C                   WHEN      rc = -1
     C                   CALLP     em(em2(10) : 'select()' : 1)
     C                   EXSR      #ABORT
      *   select timed out
     C                   WHEN      rc = 0
     C                   CALLP     em(em2(11) : 'select()')
     C                   EXSR      #ABORT
      *   something to write to socket
     C                   OTHER
 |    *     print writing data
     C   90              CALLP     dp('  write ' + %TRIMR(n2c(wbuflen))
     C                                           + ' bytes.')
     C   90              EVAL      fl = 'S->' + lk
   D C   90              DO        wbuflen       K
   | C                   IF        (K + 99) > wbuflen
     C                   EVAL      dolinelen = wbuflen - K + 1
     C                   ELSE
     C                   Z-ADD     100           dolinelen         3 0
     C                   ENDIF
     C                   EVAL      doline = %SUBST(wbuf : K : dolinelen)
     C     a_c_x:a_c_c   XLATE     doline        doline          100
     C                   CALLP     dp(fl + %SUBST(doline : 1 : dolinelen) + rk)
   | C                   EVAL      fl = '   ' + lk
   E C                   ENDDO     100
      *   send data to socket
     C                   EVAL      bytesw = write(sd : %ADDR(wbuf) : wbuflen)
      *
     C                   IF        bytesw = -1
     C                   CALLP     em(em2(5) : 'write()' : 1)
     C                   EXSR      #ABORT
     C                   ENDIF
      *   write() returned 0
     C                   IF        bytesw = 0
     C                   CALLP     em(em2(7) : 'write()')
     C                   EXSR      #ABORT
     C                   ENDIF
      *
     C   90              CALLP     dp('  wrote ' + %TRIMR(n2c(bytesw))
     C                                           + ' bytes.')
      *   no more write?
     C                   EVAL      byteswleft = byteswleft - bytesw
     C                   IF        byteswleft = 0
     C                   LEAVE
     C                   ENDIF
     C                   EVAL      wbuflen = wbuflen - bytesw
     C                   EVAL      wbuf = %SUBST(wbuf : bytesw + 1 : wbuflen)
 |    *
     C                   ENDSL
 E   C                   ENDDO
      *
     C                   ENDSR
      *****************************************************************
