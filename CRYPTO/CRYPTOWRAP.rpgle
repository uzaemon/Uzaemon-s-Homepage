      * Wrapper for CRYPTO procedure
      /COPY *LIBL/CRYPTO,CRYPTOPROT
      *
     C     *ENTRY        PLIST
     C                   PARM                    cryptmode         1            I
     C                   PARM                    indata         2048            I
     C                   PARM                    password         16            I
     C                   PARM                    outdata        2048            O
     C                   PARM                    verbose           1            I
     C                   PARM                    errid            10            O
      *
     C                   EVAL      errid = crypt(cryptmode : indata :
     C                                     password : outdata : verbose)
     C                   EVAL      *INLR = *ON
