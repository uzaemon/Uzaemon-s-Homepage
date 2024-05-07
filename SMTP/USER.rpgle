      * Prototypes for user difined functions
      *
      * Retreive error information .............................................
     Dgeterrinfo       PR            10I 0
     D errstr                       128
      *
      * Get file name from full path ...........................................
     Dgetfilename      PR            10I 0
     D path                          64    VALUE
     D filename                      64
      *
      * Get character-type current date string .................................
     Dcdate            PR            10I 0
     D datestring                    31
     D excpID                         7
      *
      * Send program message ...................................................
     Dsndpm            PR            10I 0
     D buffer                       256    VALUE
     D msg_num                        1P 0 VALUE
     D excpID                         7
      *
      * Prepare user space .....................................................
     Dprepareus        PR            10I 0
     D spc_name                      20    VALUE
     D excpID                         7
      *
      * Retreive source file information .......................................
     Dgetpfinfo        PR            10I 0
     D spc_name                      20    VALUE
     D file_name                     20    VALUE
     D actual_name                   20
     D pflf                           3
     D file_type                      5
     D pgmd                           4
     D max_fields                     5P 0
     D record_len                     5P 0
     D file_ccsid                     5P 0
     D excpID                         7
      *
      * Retreive job information ...............................................
     Dgetjobinfo       PR            10I 0
     D spc_name                      20    VALUE
     D job_name                      10
     D user_name                     10
     D job_number                     5
     D act_time                      13
     D jobccsid                       9B 0
     D dftjobccsid                    9B 0
     D excpID                         7
      *
      * SBCS character tables *****************************************
      *
      * US-ASCII (ANSI X3.4-1986) characters (95)
     Da_c              S             95
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
      *
     Dtoblank          S             95    INZ(*ALL' ')
      *
      * 'safe' ASCII chars other than especialsÝRFC2047 p3¨ and
      *       quoted chars for EBCDIC gateway ÝRFC2045 p20¨)  (69)
      * (These characters are also invariant EBCDIC characters)
     Da_s_c            C                   ' %&''*+-0123456789-
     D                                     ABCDEFGHIJKLMNOPQRSTUVWXYZ-
     D                                     abcdefghijklmnopqrstuvwxyz'
      *
     Da_s_x            C                   X'202526272A2B2D30313233343536373839-
      *                                      sp % & ' * + - 0 1 2 3 4 5 6 7 8 9
     D                                     4142434445464748494A4B4C4D-
      *                                     A B C D E F G H I J K L M
     D                                     4E4F505152535455565758595A-
      *                                     N O P Q R S T U V W X Y Z
     D                                     6162636465666768696A6B6C6D-
      *                                     a b c d e f g h i j k l m
     D                                     6E6F707172737475767778797A'
      *                                     n o p q r s t u v w x y z
     Da_c_c            S             98
     Da_c_x            S             98
      * ISO-2022-JP escape sequences
     DG0ascii          C                   X'1B2842'
     DG0roman          C                   X'1B284A'
     DG0kana           C                   X'1B2849'
     DG0k78            C                   X'1B2440'
     DG0k83            C                   X'1B2442'
      * especial characters (RFC2047 section 2)
     Despecials        C                   X'28293C3E402C3B3A222F5B5D3F2E3D'
      *                                       ( ) < > @ , ; : " / Ý ¨ ? . =
