     H NOMAIN
      * Common structure for error code parameter
      /COPY QSYSINC/QRPGLESRC,QUSEC
      *
      * Generate Pseudorandom Numbers (QC3GENRN, Qc3GenPRNs) API
     D Qc3GenPRNs      PR                  EXTPROC('Qc3GenPRNs')
     D                               16    OPTIONS(*VARSIZE)                    O
     D                               10I 0 CONST                                I
     D                                1    CONST                                I
     D                                1    CONST                                I
     D  errCode                            LIKE(QUSEC)                          I/O
      *
      * Calculate Hash (QC3CALHA, Qc3CalculateHash) API
     D Qc3CalcHash     PR                  EXTPROC('Qc3CalculateHash')
     D                               24    CONST OPTIONS(*VARSIZE)              I
     D                               10I 0 CONST                                I
     D                                8    CONST                                I
     D                               20    CONST OPTIONS(*VARSIZE)              I
     D                                8    CONST                                I
     D                                1    CONST                                I
     D                               10    CONST                                I
     D                               20    OPTIONS(*VARSIZE)                    O
     D  errCode                            LIKE(QUSEC)                          I/O
      *
      * Encrypt Data (QC3ENCDT, Qc3EncryptData) API
     D Qc3EncryptData  PR                  EXTPROC('Qc3EncryptData')
     D                             1024    OPTIONS(*VARSIZE)                    I
     D                               10I 0 CONST                                I
     D                                8    CONST                                I
     D                               64    CONST OPTIONS(*VARSIZE)              I
     D                                8    CONST                                I
     D                              128    CONST                                I
     D                                8    CONST                                I
     D                                1    CONST                                I
     D                               10    CONST                                I
     D                             2048    OPTIONS(*VARSIZE)                    O
     D                               10I 0 CONST                                I
     D                               10I 0                                      O
      * Format ERRC0100, QUSEC include file in the QSYSINC library
     D  errCode                            LIKE(QUSEC)                          I/O
      *
      * Decrypt Data (QC3DECDT, Qc3DecryptData) API
     D Qc3DecryptData  PR                  EXTPROC('Qc3DecryptData')
     D                             2048    CONST                                I
     D                               10I 0 CONST                                I
     D                               64    CONST                                I
     D                                8    CONST                                I
     D                              128    CONST                                I
     D                                8    CONST                                I
     D                                1    CONST                                I
     D                               10    CONST                                I
     D                             1024    OPTIONS(*VARSIZE)                    O
     D                               10I 0 CONST                                I
     D                               10I 0                                      O
     D  errCode                            LIKE(QUSEC)                          I/O
      *
      * Encode an EBCDIC string using base64encoding
     D base64eb        PR            10I 0 EXTPROC('apr_base64_encode_binary')  O
     D                             2048    OPTIONS(*VARSIZE)                    O
     D                             1024    CONST OPTIONS(*VARSIZE)              I
     D                               10I 0 VALUE                                I
      *
      * Decode an EBCDIC string to plain text
     D base64db        PR            10I 0 EXTPROC('apr_base64_decode_binary')  O
     D                             1024    OPTIONS(*VARSIZE)                    O
     D                                 *   VALUE OPTIONS(*STRING)               I
      *
      /COPY *LIBL/CRYPTO,CRYPTOPROT
      *
      * Send program message for verbose mode
     D sndPmsg         PR
     D                              255    VALUE                                I
      *
      * Convert binary string to HEX string
     D toHexStr        PR           512                                         O
     D                              256    VALUE                                I
     D                                3P 0 VALUE                                I
      *
      * Encrypt/decrypt main procedure *********************************
     P crypt           B                   EXPORT
      *
     D crypt           PI            10                                         error ID
     D  cryptmode                     1    VALUE                                enc:'e', dec:'d'
     D  indata                     2048    VALUE                                input data
     D  password                     16    VALUE                                password
     D  outdata                    2048                                         output data
     D  verbose                       1    VALUE OPTIONS(*NOPASS)               verbose
      *
      ************************
      * Cryptographic common includes
      /COPY QSYSINC/QRPGLESRC,QC3CCI
      * Common error code parameter
     D errCode         DS                  LIKEDS(QUSEC)
      * #01 - Generate random salt.
     D salt            S              8    INZ(*BLANKS)
      *
     D secretKeyData   S             24    INZ(*BLANKS)                         Pass + salt
     D secretKeyDataLen...
     D                 S             10I 0
     D secretKey       S             16                                         MD5 16 bytes
      *
     D IVData          S             40    INZ(*BLANKS)
     D IV              S             16                                         MD5 16 bytes
      *
     D algoDescDS      DS                  LIKEDS(QC3D0200)
      *
     D keyDescDS       DS                  QUALIFIED
     D  #QC3KT                             LIKE(QC3KT)
     D  #QC3KSL                            LIKE(QC3KSL)
     D  #QC3KF                             LIKE(QC3KF)
     D  #QC3ERVED02                        LIKE(QC3ERVED02)
     D  QC3KS                      2048                                         Missing field
      *
     D indataLen       S              3P 0
     D indataAsc       S           1024
     D rtnDataLen      S             10I 0
     D encData         S           2048
     D encDataLen      S             10I 0
     D b64Str          S           2048
     D b64StrLen       S             10I 0
      *
      * US-ASCII (ANSI X3.4-1986) characters (95 chars)
     D ebcdicChrs      C                   ' !"#$%&''()*+,-./0123456789:;<=>?-
     D                                     @ABCDEFGHIJKLMNOPQRSTUVWXYZÝ\¨^_-
     D                                     `abcdefghijklmnopqrstuvwxyz{|}µ'
     D asciiChrs       C                   X'202122232425262728292A2B2C2D2E2F-
      *                                      sp ! " # $ % & ' ( ) * + , - . /
     D                                     303132333435363738393A3B3C3D3E3F-
      *                                     0 1 2 3 4 5 6 7 8 9 : ; < = > ?
     D                                     404142434445464748494A4B4C4D4E4F-
      *                                     @ A B C D E F G H I J K L M N O
     D                                     505152535455565758595A5B5C5D5E5F-
      *                                     P Q R S T U V W X Y Z Ý ¥ ¨ ^ _
     D                                     606162636465666768696A6B6C6D6E6F-
      *                                     ` a b c d e f g h i j k l m n o
     D                                     707172737475767778797A7B7C7D7E'
      *                                     p q r s t u v w x y z { | } µ
      ************************
      /FREE

       IF cryptmode = 'E' or cryptmode = 'e'; // Perform encryption

         // #01 - Generate random salt.
         EXSR clearErrCode;
         Qc3GenPRNs(salt : %LEN(salt) : '0' : '0' : errCode);

         IF errCode.QUSBAVL = 0;
           IF verbose = 'V' or verbose = 'v';
             sndPmsg('salt=' + toHexStr(salt : %LEN(salt)));
           ENDIF;
         ELSE;
           RETURN '#01' + errCode.QUSEI;
         ENDIF;

         EXSR generateKey;

         // #02 - Encrypt data
         EXSR setCryptDS;

         indataLen = %LEN(%TRIMR(indata));
         indataAsc = %XLATE(ebcdicChrs : asciiChrs : indata);

         EXSR clearErrCode;
         Qc3EncryptData(indataAsc : indataLen : 'DATA0100' :
                        algoDescDS : 'ALGD0200' : keyDescDS : 'KEYD0200' :
                        '0' : ' ' : outdata :  %SIZE(outdata) :
                        rtnDataLen : errCode);

         IF errCode.QUSBAVL = 0;
         // sndPmsg('enc=' + toHexStr(outdata : rtnDataLen)); // For debug
         ELSE;
           RETURN '#02' + errCode.QUSEI;
         ENDIF;

         // Base64 encode for output
         encData = %XLATE(ebcdicChrs : asciiChrs : 'Salted__') + salt +
                   %SUBST(outdata : 1 : rtnDataLen);
         encDataLen = 8 + 8 + rtnDataLen;
         // sndPmsg('enc=' + toHexStr(encData : encDataLen)); // For debug

         b64StrLen = base64eb(b64str : encData : encDataLen);
         IF verbose = 'V' or verbose = 'v';
           sndPmsg(b64Str);
         ENDIF;
         outdata = b64Str;

       ENDIF; // End of encryption.

       ///////////////////////

       IF cryptmode = 'D' or cryptmode = 'd'; // Perform decryption

         // Base64 dncode for input
         b64Str = indata;
         encDataLen = base64db(encData : b64str);
         // sndPmsg('enc=' + toHexStr(encData : encDataLen)); // For debug

         // #03 - Check if salt exists.
         IF %SUBST(encData : 1 : 8) <>
            %XLATE(ebcdicChrs : asciiChrs : 'Salted__');
           RETURN '#03No salt';
         ENDIF;

         // Extract salt.
         salt = %SUBST(encData : 9 : 8);
         IF verbose = 'V' or verbose = 'v';
           sndPmsg('salt=' + toHexStr(salt : %LEN(salt)));
         ENDIF;

         EXSR generateKey;

         // #04 - Dncrypt data
         EXSR setCryptDS;

         EXSR clearErrCode;
         Qc3DecryptData(%SUBST(encData : 17 : encDataLen - 16) :
                        encDataLen - 16 :
                        algoDescDS : 'ALGD0200' : keyDescDS : 'KEYD0200' :
                        '0' : ' ' : outdata :  %SIZE(outdata) :
                        rtnDataLen : errCode);

         IF errCode.QUSBAVL = 0;
         // sndPmsg('enc=' + toHexStr(outdata : rtnDataLen)); // For debug
         ELSE;
           RETURN '#04' + errCode.QUSEI;
         ENDIF;

         outdata = %XLATE(asciiChrs : ebcdicChrs :
                   %SUBST(outdata : 1 : rtnDataLen));
         IF verbose = 'V' or verbose = 'v';
           sndPmsg(outdata);
         ENDIF;

       ENDIF; // End of decryption.

       RETURN *BLANKS;

       // Subroutines ////////

       // Cleat error code data structure
       BEGSR clearErrCode;

         errCode = *ALLX'00';
         errCode.QUSBPRV = %SIZE(errCode);

       ENDSR;

       // Generate secret key and IV from password and salt
       BEGSR generateKey;

         // #S1 - Generate secret key as MD5(password + salt).
         secretKeyData = %XLATE(ebcdicChrs : asciiChrs : %TRIMR(password)) +
                         salt;
         secretKeyDataLen = %LEN(%TRIMR(password)) + %LEN(salt);
         QC3HA = 1; // MD5. Documented in RFC 1321.

         EXSR clearErrCode;
         Qc3CalcHash(secretKeyData : secretKeyDataLen :
                        'DATA0100' : QC3D0500 :
                        'ALGD0500' : '0' : ' ' : secretKey : errCode);

         IF errCode.QUSBAVL = 0;
           IF verbose = 'V' or verbose = 'v';
             sndPmsg('key=' + toHexStr(secretKey : %LEN(secretKey)));
           ENDIF;
         ELSE;
           RETURN '#S1' + errCode.QUSEI;
         ENDIF;

         // #S2 - Generate IV as MD5(Key + password + salt).
         QC3HA = 1; // MD5. Documented in RFC 1321.
         IVData = secretKey + secretKeyData;

         EXSR clearErrCode;
         Qc3CalcHash(IVData : %LEN(secretKey) + secretKeyDataLen :
                        'DATA0100' : QC3D0500 :
                        'ALGD0500' : '0' : ' ' : IV : errCode);

         IF errCode.QUSBAVL = 0;
           IF verbose = 'V' or verbose = 'v';
             sndPmsg('iv =' + toHexStr(IV : %LEN(IV)));
           ENDIF;
         ELSE;
           RETURN '#S2' + errCode.QUSEI;
         ENDIF;

       ENDSR;

       // Set data structures of crypt APIs to "AES/CBC/PKCS5Padding".
       BEGSR setCryptDS;

         // Key Description Format KEYD0200
         keyDescDS = *ALLX'00';
         keyDescDS.#QC3KT    = 22; // The type of key. (22 = AES)
         keyDescDS.#QC3KSL   = 16; // Length of the key string.
         keyDescDS.#QC3KF    = '0'; // The format of the key string field. (0 = Binary string)
         keyDescDS.#QC3ERVED02 = *ALLX'00'; // Must be null (binary 0s).
         keyDescDS.QC3KS     = secretKey ; // The key to use in the encrypt operation.

         // Algorithm Description Format ALGD0200
         algoDescDS = *ALLX'00';
         algoDescDS.QC3BCA   = 22; // Block cipher algorithm is AES.
         algoDescDS.QC3BL    = 16; // Block Length is 16.
         algoDescDS.QC3MODE  = '1'; // Mode is CBC.
         algoDescDS.QC3PO    = '2'; // Pad option is "PKCS #5 padding."
         algoDescDS.QC3PC    = X'00'; // The pad character for pad option 1.
         algoDescDS.QC3ERVED = X'00'; // Reserved. Must be null (binary 0s).
         algoDescDS.QC3MACL  = 0; // Not used.
         algoDescDS.QC3EKS   = 0; // Only for RC2.
         algoDescDS.QC3IV    = IV; // Initialization vector or counter.

       ENDSR;

      /END-FREE
      *
     P crypt           E
      *****************************************************************
      * Send daignostic message (information, warning)
     P sndPmsg         B
      *
     D sndPmsg         PI
     D  msg_data                    255    VALUE
      *
     D msg_file        S             20    INZ('QCPFMSG   *LIBL')
     D msg_len         S              9B 0
     D stack_ctr       S              9B 0
      *
     C                   EVAL      msg_len = %LEN(%TRIMR(msg_data))
      *
     C                   CALL      'QMHSNDPM'
     C                   PARM      'CPI8859'     msg_id            7        I
     C                   PARM                    msg_file                   I
     C                   PARM                    msg_data                   I
     C                   PARM                    msg_len                    I
     C                   PARM      '*DIAG'       msg_type         10        I
     C                   PARM      '*'           stack_ent        10        I
     C                   PARM      0             stack_ctr                  I
     C                   PARM                    msg_key           4        O
     C                   PARM                    QUSEC                      I/O
      *
     C                   RETURN
      *
     P sndPmsg         E
      *****************************************************************
     P toHexStr        B
      *
     D toHexStr        PI           512
     D  str                         256    VALUE
     D  strLen                        3P 0 VALUE
      *
     D hexStr          S            512    INZ(*BLANKS)
     D hexStr_pos      S              3P 0 INZ(1)
     D hexChr          C                   '0123456789ABCDEF'
     D ctoh            DS
     D  bin_h_c                1      1
     D  achr                   2      2
     D  bin                    1      2B 0
      *
     C                   DO        strLen        I                 3 0
     C                   EVAL      achr = %SUBST(str : I : 1)
     C                   MOVE      X'00'         bin_h_c
     C     bin           DIV       16            bin_h             2 0
     C                   MVR                     bin_l             2 0
     C                   EVAL      %SUBST(hexStr : hexStr_pos : 2) =
     C                                 %SUBST(hexChr : bin_h + 1 : 1) +
     C                                 %SUBST(hexChr : bin_l + 1 : 1)
     C                   ADD       2             hexStr_pos
     C                   ENDDO
      *
     C                   RETURN    hexStr
      *
     P toHexStr        E
