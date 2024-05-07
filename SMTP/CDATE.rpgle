      *****************************************************************
      * Get current Date/Time
      *     (No input parameter)
      *     datestring : ex. 'Date: Sat, 22 Feb 1997 01:23:45 +0900'          O
      *     excpID : Exception ID                                             O
      *     return :  0 Normal end
      *              -1 Failed to get current date/time (API-QWCCVTDT)
      *****************************************************************
     HNOMAIN
      * Prototype for itself.
      /COPY H,USER
      * User space error code.
      /COPY QSYSINC/QRPGLESRC,QUSEC
      *
     Pcdate            B                   EXPORT
     Dcdate            PI            10I 0
     D datestring                    31
     D excpID                         7
      *
     DdtoutDS          DS
     D dtout_str               1     18
     D dtout_hour              1      2B 0 INZ(0)
     D dtout_minutes           3      4B 0 INZ(0)
     D dtout_seconds           5      6B 0 INZ(0)
     D dtout_msecond           7      8B 0 INZ(0)
     D dtout_day               9     10B 0 INZ(0)
     D dtout_month            11     12B 0 INZ(0)
     D dtout_year             13     14B 0 INZ(0)
     D dtout_tzone            15     16B 0 INZ(0)
     D dtout_dow              17     18B 0 INZ(0)
      *
     Ddowc             S             21    INZ('SunMonTueWedThuFriSat')
     Ddow              S              3    DIM(7)
     Dmoyc             S             36    INZ('JanFebMarAprMayJunJulAugSepOct-
     D                                     NovDec')
     Dmoy              S              3    DIM(12)
      *
     C                   MOVEA     dowc          dow
     C                   MOVEA     moyc          moy
     C                   MOVE      *BLANKS       datestring
      *
     C                   CALL      'QWCCVTDT'
     C                   PARM      '*CURRENT  '  dtinfmt          10
     C                   PARM      *BLANKS       dtinvar          10
     C                   PARM      '*DOS      '  dtoutfmt         10
     C                   PARM                    dtoutvar         11
     C                   PARM                    QUSEC
      *
     C                   IF        QUSBAVL > 0
     C                   MOVE      QUSEI         excpID
     C                   RETURN    -1
     C                   ENDIF
      *
     C                   EVAL      %SUBST(dtout_str:2:1) = %SUBST(dtoutvar:1:1)
     C                   EVAL      %SUBST(dtout_str:4:1) = %SUBST(dtoutvar:2:1)
     C                   EVAL      %SUBST(dtout_str:6:1) = %SUBST(dtoutvar:3:1)
     C                   EVAL      %SUBST(dtout_str:8:1) = %SUBST(dtoutvar:4:1)
     C                   EVAL      %SUBST(dtout_str:10:1) = %SUBST(dtoutvar:5:1)
     C                   EVAL      %SUBST(dtout_str:12:1) = %SUBST(dtoutvar:6:1)
     C                   EVAL      %SUBST(dtout_str:13:2) = %SUBST(dtoutvar:7:2)
     C                   EVAL      %SUBST(dtout_str:15:2) = %SUBST(dtoutvar:9:2)
     C                   EVAL      %SUBST(dtout_str:18:1) = %SUBST(dtoutvar:11)
      *
     C                   Z-ADD     0             hms               6 0
     C                   EVAL      hms = dtout_hour * 10000 +
     C                                   dtout_minutes * 100 + dtout_seconds
      *
     C     dtout_tzone   DIV       60            tzone_h           2 0
     C                   MVR                     tzone_m           2 0
     C                   MOVE      *BLANKS       tzone_c           5
     C                   EVAL      tzone_c = %TRIM(%EDITW(tzone_h :'0  ')) +
     C                                       %TRIM(%EDITW(tzone_m :'0  '))
      * tzone is negative!
     C                   IF        dtout_tzone > 0
     C                   EVAL      tzone_c = '-' + tzone_c
     C                   ELSE
     C                   EVAL      tzone_c = '+' + tzone_c
     C                   ENDIF
      *
     C                   EVAL      datestring =
     C                              dow(dtout_dow + 1) + ', ' +
     C                              %TRIM(%EDITC(dtout_day :'4')) + ' ' +
     C                              moy(dtout_month) + ' ' +
     C                              %TRIM(%EDITC(dtout_year :'4')) +
     C                              %EDITW(hms :'0  :  :  ') + ' ' +
     C                              tzone_c
     C                   RETURN    0
      *
     Pcdate            E
