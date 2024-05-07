      *****************************************************************
      * convert numeric to string
      *     return : string
      *     instr : numeric                                                   I
      *
     Pn2c              B
     Dn2c              PI            12
     D numeric                       10I 0 VALUE
      *
     C                   RETURN    %TRIML(%EDITC(numeric : 'P'))
     Pn2c              E
      *****************************************************************
      * debug print out
      *     return : (none)
      *     instr : Print string                                              I
      *    (pm : Current time (HH:MM:SS.mmm) + instr                         )M
      *
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
     C                                  vb + %TRIMR(pm)
     C
     C                   EXCEPT
      *
     C                   RETURN
      *
     Pdp               E
      *****************************************************************
      * send / print error message
      *     return : (none)
      *     em : error message                                                I
      *     info : additional error information (return code, etc.)           I
      *     c_error : if specified add c error info                           I
      *    (msg : error message text                                         )M
      *    (debug : debug mode = '*YES' or '*NO'                             )R
      *
     Pem               B
     Dem               PI
     D em                            80    VALUE
     D info                         128    VALUE
     D c_error                        1P 0 VALUE OPTIONS(*NOPASS)
      *
     Derrstr           S            128
     Derrno            S             10I 0
     Drc               S             10I 0
     Dinfolen          S             10I 0
     Dexcp             S              7
      *
      * additional error information
     C                   IF        %PARMS > 2
     C                   EVAL      errno = geterrinfo(errstr)
     C                   IF        info <> ' '
     C                   EVAL      msg = ' (' + %TRIMR(info) + ', ' +
     C                                   %TRIMR(n2c(errno)) + ':' +
     C                                   %TRIMR(errstr) + ')'
     C                   ELSE
     C                   EVAL      msg = ' (' + %TRIMR(n2c(errno)) + ':'
     C                                   + %TRIMR(errstr) + ')'
     C                   ENDIF
     C                   ELSE
     C                   EVAL      msg = ' (' + %TRIMR(info) + ')'
     C                   ENDIF
      * concat error message and info if exists
     C                   IF        info <> ' ' or %PARMS > 2
     C                   EVAL      msg = %TRIMR(em) + msg
     C                   ELSE
     C                   EVAL      msg = em
     C                   ENDIF
      *
     C                   IF        debug = '*YES'
     C   90              CALLP     dp(%SUBST(msg : 1 : 112))
     C                   ENDIF
      *
     C                   RETURN
      *
     Pem               E
      *****************************************************************
      * encode mail address and description
      *     return : length of outstr
      *              < 0 return code form procedure 'smtphead'
      *     mtype : 'From:', 'To:', 'cc:', 'bcc:', 'Reply-To:'                I
      *     mail_addr : mail address                                          I
      *     mail_desc : mail address description                              I
      *     outstr : encoded string                                           O
      *
     Pencodemailaddr   B
     Dencodemailaddr   PI            10I 0
     D mtype                          9    VALUE
     D mail_addr                     64    VALUE
     D mail_desc                     64    VALUE
     D outstr                       512
      *
     Doutstrlen        S              3P 0
      *
      * mail adderss description is blank
     C                   IF        mail_desc = ' '
     C                   EVAL      outstr = mtype
     C                   EVAL      outstrlen = %LEN(%TRIM(mtype))
      *     encode mail description
     C                   ELSE
     C                   EVAL      outstrlen = smtphead(%TRIM(mail_desc) :
     C                                                              outstr)
     C                   IF        outstrlen < 0
     C                   RETURN    outstrlen
     C                   ENDIF
     C                   EVAL      outstr = %TRIM(mtype) + ' "' +
     C                                  %SUBST(outstr : 1 : outstrlen) + '"'
     C                   EVAL      outstrlen = outstrlen + 3 +
     C                                                 %LEN(%TRIM(mtype))
      *       folding
     C                   IF        outstrlen - fold + 8 > 65
     C                   EVAL      %SUBST(outstr : outstrlen + 1 : 2) = CRLF
     C                   EVAL      outstrlen = outstrlen + 2
     C                   ENDIF
     C                   ENDIF
      *     append mail address
     C                   EVAL      outstr = %SUBST(outstr : 1 : outstrlen) +
     C                                      ' <' + %TRIM(mail_addr) + '>'
     C                   EVAL      outstrlen = outstrlen +
     C                                   %LEN(%TRIM(mail_addr)) + 3
      *
     C                   RETURN    outstrlen
     Pencodemailaddr   E
      *****************************************************************
      * Generate SMTP mail header
      *     return :  length of outstr
      *               0 nothing to process
      *              -1, -2, -3, -4 return code from other procedures
      *              -5 invalid character set (should not happen though)
      *     instr : input string (EBCDIC)                                    I
      *     outstr : encoded string (EBCDIC)                                 O
      *    (dftjobccsid : CCSID of instr                                    )R
      *    (charset : 'US-ASCII' or 'US-ASCII-NONSAFE' or 'ISO-8859-1'      )M
      *    (     or 'ISO-2022-JP' (Japanese)                                )
      *    (fold : last folding position of encoded string                  )M
      *
     Psmtphead         B
     Dsmtphead         PI            10I 0
     D instr                         64    VALUE
     D outstr                       256
      *
     Dinstrlen         S              3P 0
     Dascii            S            256
     Drc               S              3P 0
      *
     C                   EVAL      instrlen = %LEN(%TRIMR(instr))
     C                   IF        instrlen = 0
     C                   RETURN    0
     C                   ENDIF
      * determine character set
     C     a_c:toblank   XLATE     instr         nonasciichr      64
      *   Includes non-ascii char(s) ?
     C                   IF        %LEN(%TRIM(nonasciichr)) > 0
      *     Japanese
     C                   IF        dftjobccsid = 5026 OR dftjobccsid = 5035 OR
     C                             dftjobccsid = 1390 OR dftjobccsid = 1399
     C                   EVAL      charset = 'ISO-2022-JP'
     C                   ELSE
      *     Latin-1
     C                   EVAL      charset = 'ISO-8859-1'
     C                   ENDIF
     C                   ELSE
     C     a_s_c:toblank XLATE     instr         nonasciichr
      *   Includes non-safe char(s) ?
     C                   IF        %LEN(%TRIM(nonasciichr)) > 0
      *     Non Safe ASCII
     C                   EVAL      charset = 'US-ASCII-NONSAFE'
     C                   ELSE
      *     Safe ASCII
     C                   EVAL      charset = 'US-ASCII'
     C                   ENDIF
     C                   ENDIF
      * encode string
     C                   SELECT
      *   Plain ASCII
     C                   WHEN      charset = 'US-ASCII'
     C                   EVAL      outstr = instr
     C                   RETURN    %LEN(%TRIM(instr))
      *   US-ASCII(not safe)
     C                   WHEN      charset = 'US-ASCII-NONSAFE'
     C                   EVAL      charset = 'US-ASCII'
     C     a_c:a_x       XLATE     instr         ascii
     C                   RETURN    Qencode(instr : ascii : instrlen : outstr)
      *   ISO-8859-1
     C                   WHEN      charset = 'ISO-8859-1'
      *     convert jobccsid -> 819
     C     1             OCCUR     iconv_t_a
     C                   EVAL      rc = iconvw(%TRIMR(instr) + NULL : ascii)
     C                   IF        rc < 0
     C                   RETURN    rc
     C                   ENDIF
     C                   RETURN    Qencode(instr : ascii : instrlen : outstr)
      *   ISO-2022-JP -> 'B' encode
     C                   WHEN      charset = 'ISO-2022-JP'
      *     convert jobccsid -> 932/5052
     C                   EVAL      rc = to2022(instr : ascii : 1)
     C                   IF        rc < 0
     C                   RETURN    rc
     C                   ENDIF
     C                   RETURN    Bencode(ascii : rc : outstr)
      *
     C                   ENDSL
      *
     C                   RETURN    -5
      *
     Psmtphead         E
      *****************************************************************
      * 'Q' encode for SBCS mail header
      *     return :  length of newbuf
      *              -4 especials found     <- 2002-05-06 out of use
      *     ebcdic : input string (EBCDIC)                                    I
      *     ascii : input string (ASCII)                                      I
      *     buflen : length of input string                                   I
      *     newbuf : output (converted) string                                O
      *    (structured : string is in structured field of mail header        )R
      *    (charset : 'US-ASCII' or 'US-ASCII-NONSAFE' or 'ISO-8859-1'       )R
      *    (fold : > 0 if folding occured                                    )M
      *
     PQencode          B
     DQencode          PI             3P 0
     D ebcdic                        64    VALUE
     D ascii                         64    VALUE
     D buflen                         3P 0 VALUE
     D newbuf                       256
      *
     Dbufpos           S              3P 0
      *
     Dctoh             DS
     D achr                    2      2
     D bin                     1      2B 0
     Dissafe           S              3P 0
     Dcslen            S              3P 0
     Dechr             S              1
     Dhex              C                   '0123456789ABCDEF'
      *
     C                   EVAL      cslen = %LEN(%TRIM(charset))
     C                   EVAL      newbuf = '=?' + %TRIM(charset) + '?Q?'
     C                   EVAL      bufpos = cslen + 6
     C                   EVAL      fold = 0
      *
     C                   DO        buflen        I                 3 0
      *   Safe ASCII?
     C                   MOVE      X'0000'       bin
     C                   EVAL      achr = %SUBST(ascii : I : 1)
      * 2002-05-06 allow especial characters.
      *     especials not allowed for structured field
     C*                  IF        structured = 1 and
     C*                            %SCAN(achr : especials) > 0
     C*                  RETURN    -4
     C*                  ENDIF
      *     quote UNSAFE ASCII characters
     C                   EVAL      issafe = %SCAN(achr : a_s_x)
     C                   IF        issafe = 0
     C     bin           DIV       16            bin_h             2 0
     C                   MVR                     bin_l             2 0
     C                   EVAL      %SUBST(newbuf : bufpos : 3) =
     C                             '=' + %SUBST(hex : bin_h + 1 : 1) +
     C                             %SUBST(hex : bin_l + 1 : 1)
     C                   EVAL      bufpos = bufpos + 3
     C                   ELSE
      *     SAFE ASCII
      *       replace SPACE by '_'
     C                   EVAL      echr = %SUBST(ebcdic : I : 1)
     C                   IF        echr = ' '
     C                   EVAL      %SUBST(newbuf : bufpos : 1) = '_'
     C                   ELSE
     C                   EVAL      %SUBST(newbuf : bufpos : 1) = echr
     C                   ENDIF
     C                   EVAL      bufpos = bufpos + 1
     C                   ENDIF
      *   folding
     C                   IF        9 + bufpos - fold > 65
     C                   EVAL      %SUBST(newbuf : bufpos : cslen + 10) =
     C                             '?=' + X'0D0A' + ' =?' + %TRIM(charset) +
     C                                                         '?Q?'
     C                   EVAL      fold = bufpos + 4
     C                   EVAL      bufpos = bufpos + cslen + 10
     C                   ENDIF
      *   quit conversion if string length is going to exceed 256.
     C                   IF        bufpos > 240
     C                   LEAVE
     C                   ENDIF
     C                   ENDDO
      *
     C                   EVAL      %SUBST(newbuf : bufpos : 2) = '?='
     C                   EVAL      bufpos = bufpos + 2
      *
     C                   RETURN    bufpos - 1
     PQencode          E
      *****************************************************************
      * 'B' encode for DBCS mail header
      *     return :  length of newbuf
      *              -4 especials found     <- 2002-05-06 out of use
      *     ascii : input string                                              I
      *     buflen : length of input string                                   I
      *     newbuf : output (converted) string                                O
      *    (structured : string is in structured field of mail header        )R
      *    (charset : 'US-ASCII' or 'US-ASCII-NONSAFE' or 'ISO-8859-1'       )R
      *    (fold : > 0 if folding occured                                    )M
      *
     PBencode          B
     DBencode          PI             3P 0
     D ascii                        256    VALUE
     D buflen                         3P 0 VALUE
     D newbuf                       256
      *
     Dbufpos           S              3P 0
     Dcslen            S              3P 0
     Dchr              S              1
     Desc              S              3    INZ(G0ascii)
     Dline             S             44
     Dlinel            S              2P 0
      *
     C                   EVAL      cslen = %LEN(%TRIM(charset))
     C                   EVAL      newbuf = '=?' + %TRIM(charset) + '?B?'
     C                   EVAL      bufpos = cslen + 6
     C                   EVAL      fold = 0
      *
1    C                   DO        buflen        I                 3 0
|    C                   EVAL      chr = %SUBST(ascii : I : 1)
      *   escape char
 2   C                   IF        chr = X'1B'
 |   C                   EVAL      esc = %SUBST(ascii : I : 3)
     C                   EVAL      I = I + 2
     C                   EVAL      linel = linel + 3
      *     normal char
 E   C                   ELSE
      *       DBCS
  3  C                   IF        esc = G0k78 or esc = G0k83
  |  C                   EVAL      I = I + 1
  |  C                   EVAL      linel = linel + 2
      *       SBCS
  E  C                   ELSE
      * 2002-05-06 allow especial characters.
      *         especials not allowed for structured field
     C*                  IF        structured = 1 and
     C*                            %SCAN(chr : especials) > 0
     C*                  RETURN    -4
     C*                  ENDIF
  |  C                   EVAL      linel = linel + 1
  3  C                   ENDIF
 2   C                   ENDIF
      *   Base64 encode when line legnth exceeds 35 bytes or end of string
 2   C                   IF        (linel > 35) or (I >= buflen)
 |   C                   EVAL      line = %SUBST(ascii : I - linel + 1 : linel)
      *   add ascii escape sequence if not end as SBCS
  3  C                   IF        esc <> G0ascii and esc <> G0roman
  |  C                   EVAL      %SUBST(line : linel + 1 : 3) = G0ascii
  |  C                   EVAL      linel = linel + 3
  3  C                   ENDIF
      *   adjust to multiple of 3 for base64 encode
     C     linel         DIV       3             b64count          3 0
     C                   MVR                     b64mod            3 0
     C     3             SUB       b64mod        b64pad            3 0
  3  C                   IF        b64mod > 0
  |  C                   EVAL      %SUBST(line : linel + 1 : b64pad) = X'0000'
  |  C                   EVAL      linel = linel + b64pad
  3  C                   ENDIF
      *   Base64 encode (3 to 4)
  3  C                   DO        linel         J                 3 0
  |  C                   EVAL      %SUBST(newbuf : bufpos : 4) =
     C                               base64e(%SUBST(line : J : 3))
  |  C                   EVAL      bufpos = bufpos + 4
  3  C                   ENDDO     3
     C                   Z-ADD     0             linel
      *   Pad '='
  3  C                   IF        b64mod > 0
     C                   EVAL      %SUBST(newbuf : bufpos - b64pad : b64pad) =
     C                                                                    '=='
     C                   ENDIF
      *   end of input string or maximum line length
  3  C                   IF        (I >= buflen) or (bufpos > 180)
  |  C                   EVAL      %SUBST(newbuf : bufpos : 2) = '?='
  |  C                   EVAL      bufpos = bufpos + 2
 <-  C                   LEAVE
  |   *   folding
  E  C                   ELSE
  |  C                   EVAL      %SUBST(newbuf : bufpos : cslen + 10) =
     C                             '?=' + X'0D0A' + ' =?' +
     C                                          %TRIM(charset) + '?B?'
     C                   EVAL      fold = bufpos + 6
     C                   EVAL      bufpos = bufpos + cslen + 10
      *     add ascii escape sequence if not end as SBCS
   4 C                   IF        esc <> G0ascii and esc <> G0roman
   | C                   EVAL      %SUBST(newbuf : bufpos : 4) = base64e(esc)
   | C                   EVAL      bufpos = bufpos + 4
  |4 C                   ENDIF
  3  C                   ENDIF
 |    *
|2   C                   ENDIF
1    C                   ENDDO
      *
     C                   RETURN    bufpos - 1
     PBencode          E
      *****************************************************************
      * Convert EBCDIC string to ISO-2022-JP
      *   - Convert SBCS katakana to DBCS katakana
      *   - Detect non-JIS (IBM selected/User defined) DBCS character
      *     and replace with EBCDIC X'447D' (thick '=')
      *
      *     return : length of ISO-2022-JP string
      *               0 no graphic character found
      *              -1 iconv error (->932)
      *              -2 invalid character (< X'40') found in EBCDIC string
      *              -3 iconv error (->5052)
      *     ebcdic : ebcdic representation of original string                 I
      *     newbuf : ISO-2022-JP string                                       O
      *     iconv_index : 1 = jobccsid->932/5052, 2 = fileccsid->932/5052     O
      *    (iconv_t_a : iconv descriptor array                               )R
      *    (invalidDBCSn : non-JIS character counter                         )M
      *    (invalidDBCSt : total number of non-JIS character                 )M
      *
     Pto2022           B
     Dto2022           PI            10I 0
     D ebcdic                        80    VALUE
     D c2022                        256
     D iconv_index                    1P 0 VALUE
      *
     DI                S              9P 0
     Debcdic_len       S              3P 0
     Dc932             S            256
     Dc932_len         S             10I 0
     Dc932_chr         S              1
     Dkanji_flag       S              1P 0 INZ(0)
     Dm_kana           S              3P 0
     Dn_ebcdic         S            321
     Dn_ebcdic_pos     S              3P 0
     Dc2022_len        S             10I 0
      * SBCS katakana CP 897 (Japanese ASCII nonextended)
     DSBCSkana         C                   X'A1A2A3A4A5A6A7A8A9AAABACADAEAF-
      *                                       . ( ) ,  WoXaXiXuXeXiYaYuYoTu
     D                                     B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF-
      *                                     - A I U E OKaKiKuKeKoSaSiSuSeSo
     D                                     C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF-
      *                                    TaTiTuTeToNaNiNuNeNoHaHiFuHeHoMa
     D                                     D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF'
      *                                    MiMuMeMoYaYuYoRaRiRuReRoWaNn
     DSBCSkanaM        C                   X'B3DEB6DEB7DEB8DEB9DEBADE-
      *                                      Vu  Ga  Gi  Gu  Ge  Go
     D                                     BBDEBCDEBDDEBEDEBFDE-
      *                                    Za  Ji  Zu  Ze  Zo
     D                                     C0DEC1DEC2DEC3DEC4DE-
      *                                    Da  Di  Du  De  Do
     D                                     CADECBDECCDECDDECEDE-
      *                                    Ba  Bi  Bu  Be  Bo
     D                                     CADFCBDFCCDFCDDFCEDF'
      *                                    Pa  Pi  Pu  Pe  Po
      * DBCS katakana CP 300 (DBCS portion of EBCDIC CCSID 5026/5035/1390/1399)
     DDBCSkana         C                   X'4341434243434344434543464347-
      *                                      .   (   )   ,       Wo  Xa
     D                                     43484349435143524353435443554356-
      *                                    Xi  Xu  Xe  Xo  Xya Xyu Xyo Xtu
     D                                     43584381438243834384438543864387-
      *                                    -   A   I   U   E   O   Ka  Ki
     D                                     43884389438A438C438D438E438F4390-
      *                                    Ku  Ke  Ko  Sa  Si  Su  Se  So
     D                                     43914392439343944395439643974398-
      *                                    Ta  Ti  Tu  Te  To  Na  Ni  Nu
     D                                     4399439A439D439E439F43A243A343A4-
      *                                    Ne  No  Ha  Hi  Fu  He  Ho  Ma
     D                                     43A543A643A743A843A943AA43AC43AD-
      *                                    Mi  Mu  Me  Mo  Ya  Yu  Yo  Ra
     D                                     43AE43AF43BA43BB43BC43BD43BE43BF'
      *                                    Ri  Ru  Re  Ro  Wa  Nn
     DDBCSkanaM        C                   X'43D443C043C143C243C343C4-
      *                                      Vu  Ga  Gi  Gu  Ge  Go
     D                                     43C543C643C743C843C9-
      *                                    Za  Ji  Zu  Ze  Zo
     D                                     43CA43CB43CC43CD43CE-
      *                                    Da  Di  Du  De  Do
     D                                     43CF43D043D143D243D3-
      *                                    Ba  Bi  Bu  Be  Bo
     D                                     43D543D643D743D843D9'
      *                                    Pa  Pi  Pu  Pe  Po
      *
      * no character other than space (X'40') found
     C                   EVAL      ebcdic_len = %LEN(%TRIMR(ebcdic))
     C                   IF        ebcdic_len = 0
     C                   RETURN    0
     C                   ENDIF
      * convert to 932(SJIS)
     C                   ADD       2             iconv_index
     C     iconv_index   OCCUR     iconv_t_a
     C                   EVAL      c932_len = iconvw(%TRIMR(ebcdic) + NULL :
     C                                                                c932)
     C                   IF        c932_len < 0
     C                   RETURN    -1
     C                   ENDIF
      * remove control characters (DBCS shift codes) from EBCDIC string
     C                   DO        ebcdic_len    I
     C                   IF        %SUBST(ebcdic : I : 1) < X'3F'
     C                   EVAL      %SUBST(ebcdic : I) = %SUBST(ebcdic : I + 1)
     C                   SUB       1             I
     C                   SUB       1             ebcdic_len
     C                   ENDIF
     C                   ENDDO
      * no graphic character found (string contains only shift codes)
     C                   IF        ebcdic_len = 0
     C                   RETURN    0
     C                   ENDIF
      * invalid control character found
     C                   IF        c932_len <> ebcdic_len
     C                   RETURN    -2
     C                   ENDIF
      * check if cp932 string contains SBCS katakana and non-JIS kanji
     C                   EVAL      n_ebcdic_pos = 1
     C                   EVAL      invalidDBCSn = 0
      *
     C                   DO        ebcdic_len    I
     C                   EVAL      c932_chr = %SUBST(c932 : I : 1)
      *
     C                   SELECT
      *   SJIS structure
      *     X'00' - X'1F'          control character
      *     X'20' - X'7F'          SBCS ASCII (alphabet/numeric/symbol)
      *     X'81' - X'9F'          first byte of DBCS - 1
      *       X'8140' - X'84BE'      non-kanji DBCS
      *       X'889F' - X'9872'      JIS level1
      *       X'989F' - X'9FFC'      JIS level2 - 1
      *     X'A1' - X'DF'          SBCS katakana
      *     X'E0' - X'FC'          first byte of DBCS - 2
      *       X'E040' - X'EAA4'      JIS level2 - 2
      *       X'F0' - X'F9'          user defined character area (IBM)
      *       X'FA40' - X'FC4B'      IBM selected character
      *
      *   SBCS katakana
     C                   WHEN      X'A1' <= c932_chr and c932_chr <= X'DF'
     C                   IF        kanji_flag = 0
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 1) = X'0E'
     C                   EVAL      kanji_flag = 1
     C                   ADD       1             n_ebcdic_pos
     C                   ENDIF
     C                   EVAL      m_kana = %SCAN(%SUBST(c932 : I : 2) :
     C                                                          SBCSkanaM)
      *     one SBCS katakana -> one DBCS katakana
     C                   IF        m_kana = 0
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 2) =
     C                                   %SUBST(DBCSkana :
     C                                   %SCAN(c932_chr : SBCSkana) * 2 - 1 : 2)
      *     two SBCS katakana -> one DBCS katakana (dakuon/han-dakuon)
     C                   ELSE
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 4) =
     C                                   %SUBST(DBCSkanaM : m_kana : 2)
     C                   ADD       1             I
     C                   ENDIF
     C                   ADD       2             n_ebcdic_pos
      *   DBCS
     C                   WHEN      (X'81' <= c932_chr and c932_chr <= X'9F') or
     C                             (X'E0' <= c932_chr and c932_chr <= X'FC')
     C                   IF        kanji_flag = 0
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 1) = X'0E'
     C                   EVAL      kanji_flag = 1
     C                   ADD       1             n_ebcdic_pos
     C                   ENDIF
      *     non-JIS kanji
     C                   IF        X'F0' <= c932_chr
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 2) = X'447D'
     C                   ADD       1             invalidDBCSn
     C                   ADD       1             invalidDBCSt
     C   90              CALLP     dp('  non-JIS character' + X'0E' +
     C                                %SUBST(ebcdic : I : 2) + X'0F' + 'found.')
      *     (probably) JIS kanji
     C                   ELSE
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 2) =
     C                                   %SUBST(ebcdic : I : 2)
     C                   ENDIF
     C                   ADD       2             n_ebcdic_pos
     C                   ADD       1             I
      *   other (just replace)
     C                   OTHER
     C                   IF        kanji_flag = 1
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 1) = X'0F'
     C                   EVAL      kanji_flag = 0
     C                   ADD       1             n_ebcdic_pos
     C                   ENDIF
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 1) =
     C                                           %SUBST(ebcdic : I : 1)
     C                   ADD       1             n_ebcdic_pos
     C                   ENDSL
     C                   ENDDO
      *
     C                   IF        kanji_flag = 1
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 1) = X'0F'
     C                   EVAL      kanji_flag = 0
     C                   ADD       1             n_ebcdic_pos
     C                   ENDIF
      *
     C                   EVAL      %SUBST(n_ebcdic : n_ebcdic_pos : 1) = NULL
      * convert to 5052(JIS)
     C                   SUB       2             iconv_index
     C     iconv_index   OCCUR     iconv_t_a
     C                   EVAL      c2022_len = iconvw(n_ebcdic : c2022)
     C                   IF        c2022_len < 0
     C                   RETURN    -3
     C                   ENDIF
      * force ascii escape sequence at end of string
     C                   EVAL      %SUBST(c2022 : c2022_len + 1 : 3) = G0ascii
      *
     C                   RETURN    c2022_len + 3
     Pto2022           E
      *****************************************************************
      * Base64 encode (3 to 4)
      *     inchr : 3 bytes string to convert                                 I
      *     return : Converted character (ASCII)
      *
     Pbase64e          B
     Dbase64e          PI             4
     D inchr                          3    VALUE
      *
     Dchrs             DS
     D i1                      1      1
     D i2                      2      2
     D i3                      3      3
     Dap1DS            DS
     D ap1                     1      2U 0 INZ(0)
     D ap1L                    2      2
     Dap2DS            DS
     D ap2                     1      2U 0 INZ(0)
     D ap2L                    2      2
     Dap3DS            DS
     D ap3                     1      2U 0 INZ(0)
     D ap3L                    2      2
     Dap4DS            DS
     D ap4                     1      2U 0 INZ(0)
     D ap4L                    2      2
      *
     Db64e             C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ-
     D                                     abcdefghijklmnopqrstuvwxyz-
     D                                     0123456789+/'
     C                   MOVE      inchr         chrs
      * 1st byte of outchr
     C                   MOVE      i1            ap1L
     C                   DIV       4             ap1
      * 2nd
     C                   TESTB     '6'           i1                       20
     C   20              BITON     '2'           ap2L
     C                   TESTB     '7'           i1                       20
     C   20              BITON     '3'           ap2L
     C                   TESTB     '0'           i2                       20
     C   20              BITON     '4'           ap2L
     C                   TESTB     '1'           i2                       20
     C   20              BITON     '5'           ap2L
     C                   TESTB     '2'           i2                       20
     C   20              BITON     '6'           ap2L
     C                   TESTB     '3'           i2                       20
     C   20              BITON     '7'           ap2L
      * 3rd
     C                   TESTB     '4'           i2                       20
     C   20              BITON     '2'           ap3L
     C                   TESTB     '5'           i2                       20
     C   20              BITON     '3'           ap3L
     C                   TESTB     '6'           i2                       20
     C   20              BITON     '4'           ap3L
     C                   TESTB     '7'           i2                       20
     C   20              BITON     '5'           ap3L
     C                   TESTB     '0'           i3                       20
     C   20              BITON     '6'           ap3L
     C                   TESTB     '1'           i3                       20
     C   20              BITON     '7'           ap3L
      * 4th
     C                   BITOFF    '01'          i3
     C                   MOVE      i3            ap4L
      *
     C                   RETURN    %SUBST(b64e : ap1 + 1 : 1) +
     C                             %SUBST(b64e : ap2 + 1 : 1) +
     C                             %SUBST(b64e : ap3 + 1 : 1) +
     C                             %SUBST(b64e : ap4 + 1 : 1)
      *
     Pbase64e          E
      *****************************************************************
      * quoted-printable encode
      *     return : length of encoded string
      *               0 no graphic character found
      *              -1 iconv error
      *     ebcdic : ebcdic representation of original string                 I
      *     newbuf : quoted-printable string                                  O
      *    (iconv_t_a : iconv descriptor array                               )R
      *
     Pquotedprintable  B
     Dquotedprintable  PI            10I 0
     D ebcdic                        80    VALUE
     D newbuf                       256
      *
     Dascii            S            256
     Dascii_len        S             10I 0
     Dnewbuf_pos       S              3P 0 INZ(1)
     Dline_len         S              3P 0 INZ(0)
     DI                S              9P 0
      *
     Dctoh             DS
     D bin_h_c                 1      1
     D achr                    2      2
     D bin                     1      2B 0
     Dhex              C                   X'30313233343536373839414243444546'
      *                                       0 1 2 3 4 5 6 7 8 9 A B C D E F
      *
      * no character other than space (X'40') found
     C                   IF        %LEN(%TRIMR(ebcdic)) = 0
     C                   RETURN    0
     C                   ENDIF
      * convert to ascii
     C     2             OCCUR     iconv_t_a
     C                   EVAL      ascii_len = iconvw(%TRIMR(ebcdic) + NULL :
     C                                                               ascii)
     C                   IF        ascii_len < 0
     C                   RETURN    -1
     C                   ENDIF
      * quoted-printable encode
     C                   DO        ascii_len     I
      *   insert soft line break
     C                   IF        line_len > 73
     C                   EVAL      %SUBST(newbuf : newbuf_pos : 3) =
     C                                                           X'3D' + CRLF
     C                   ADD       3             newbuf_pos
     C                   Z-ADD     0             line_len
     C                   ENDIF
     C                   EVAL      achr = %SUBST(ascii : I : 1)
      *   space or numeric or alphabet?
     C                   IF        achr = X'20'                            or
     C                               ((X'30' <= achr) and (achr <= X'39')) or
     C                               ((X'41' <= achr) and (achr <= X'5A')) or
     C                               ((X'61' <= achr) and (achr <= X'7A'))
     C                   EVAL      %SUBST(newbuf : newbuf_pos : 1) = achr
     C                   ADD       1             newbuf_pos
     C                   ADD       1             line_len
      *   convert non-alphanumeric characters to hex
     C                   ELSE
     C                   MOVE      NULL          bin_h_c
     C     bin           DIV       16            bin_h             2 0
     C                   MVR                     bin_l             2 0
     C                   EVAL      %SUBST(newbuf : newbuf_pos : 3) = X'3D' +
     C                                 %SUBST(hex : bin_h + 1 : 1) +
     C                                 %SUBST(hex : bin_l + 1 : 1)
     C                   ADD       3             newbuf_pos
     C                   ADD       3             line_len
     C                   ENDIF
     C                   ENDDO
      *
     C                   RETURN    newbuf_pos - 1
     Pquotedprintable  E
      *****************************************************************
      * iconv() wrapper
      *     instr : input string                                              I
      *     ostr : output string                                              O
      *     return :  length of ostr
      *               -1 iconv() returned error
      *    (iconv_index : index of array iconv_t_a                            )
      *
     Piconvw           B
     Diconvw           PI            10I 0
     D instr                        512    VALUE
     D ostr                         256
      *
     Dibuf_p           S               *
     Dobuf_p           S               *
     Disav             S               *
     Dosav             S               *
     Dibuflen          S             10U 0 INZ(0)
     Dobuflen          S             10U 0 INZ(512)
     Diconv_ret        S             10U 0
      *
     C                   EVAL      ibuf_p = %ADDR(instr)
     C                   EVAL      obuf_p = %ADDR(ostr)
     C                   EVAL      isav = ibuf_p
     C                   EVAL      osav = obuf_p
      *
     C                   EVAL      iconv_ret = iconv(iconv_t_a
     C                               : %ADDR(ibuf_p) : %ADDR(ibuflen)
     C                               : %ADDR(obuf_p) : %ADDR(obuflen))
     C                   IF        iconv_ret <> 0
     C                   RETURN    -1
     C                   ENDIF
      *
     C                   EVAL      obuflen = strlen(osav)
     C                   EVAL      ostr = %STR(osav : obuflen)
      *
     C                   RETURN    obuflen
     Piconvw           E
