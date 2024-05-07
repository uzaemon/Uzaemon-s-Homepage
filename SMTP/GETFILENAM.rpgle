      *****************************************************************
      * Get file name from full-path
      *     return :  0 file name retreived successfully
      *              -1 path is blank
      *              -2 no file specified
      *              -3 DBCS in path name not allowed
      *     path : full IFS path                                              I
      *     filename : retreived file name                                    O
      *****************************************************************
     HNOMAIN
      * Prototype for itself.
      /COPY H,USER
      *
     Pgetfilename      B                   EXPORT
     Dgetfilename      PI            10I 0
     D path                          64    VALUE
     D filename                      64
      *
     Dpath_length      S              3P 0
     Dshift_out        S              1    INZ(X'0E')
      *
     C                   EVAL      path_length = %LEN(%TRIM(path))
      * path is blank
     C                   IF        path_length = 0
     C                   RETURN                  -1
     C                   ENDIF
      * no file specified
     C                   IF        %SUBST(path : path_length : 1) = '/'
     C                   RETURN                  -2
     C                   ENDIF
      * path separater exists?
     C                   IF        %SCAN('/' : path) <> 0
      *   Search path separater from end of string
     C     2             DO        path_length   I                 3 0
     C                   IF        %SUBST(path : path_length - I + 1 : 1) = '/'
     C                   EVAL      filename = %SUBST(path : path_length - I + 2)
     C                   LEAVE
     C                   ENDIF
     C                   ENDDO
     C                   ELSE
      *   file name = path
     C                   EVAL      filename = path
     C                   ENDIF
      * DBCS in file name not allowed
     C                   IF        %SCAN(shift_out : filename) > 0
     C                   RETURN                  -3
     C                   ENDIF
      *
     C                   RETURN                  0
     Pgetfilename      E
