      *****************************************************************
      * User function for FD_ macros
      *     opr : 'SET' or 'CLR' or 'ISSET'                                    I
      *     sd :  socket descriptor                                            I
      *     mask : pointer to the array                                        -
      *     return :  0 normal end. flag is NOT set if opr-ISSET specified.
      *               1 normal end. flag is set if opr-ISSET specified.
      *              -1 invalid opr.
      *              -2 socket descriptor out of range.
      *****************************************************************
     HNOMAIN
      * Prototype for itself.
      /COPY H,UNIX
      *
     PFD_              B                   EXPORT
     DFD_              PI            10I 0
     D opr                            5    VALUE
     D sd                            10I 0 VALUE
     D mask_p                          *   VALUE
      *
     Dinta             S             10U 0 DIM(7) BASED(mask_p)
     Dbitopr_work      DS
     D chr4                    1      4
     D  chra                          1    OVERLAY(chr4) DIM(4)
     D int4                    1      4U 0
     Dchrposc          S              1
     Dbitstr           C                   X'0102040810204080'
      *
      * Original FD macros written in C language manipulate 7 elements array of
      * unsigned integer (10U0 in ILE-RPG). Socket descriptor is set as follows.
      * (defined at fd_set in QSYSINC/SYS.TYPES)
      *
      *   inta
      *    1   | 31- 24| 23- 16| 15-  8|  7-  0|  <- each line represents
      *    2   | 63- 56| 55- 48| 47- 40| 39- 32|        one element (10U0)
      *    .....................................
      *    7   |223-216|215-208|207-200|199-192|
      *            1       2       3       4    chra <- divide to 4 chars
      *
      * This procedure doesn't include equivalent to FD_ZERO.
      * You can use CLEAR opcode to initialize the array.
     C*                  CLEAR                   inta
      *
     C                   Z-ADD     0             rc                3 0
      * Check operator
     C                   IF        (opr <> 'SET') and (opr <> 'CLR') and
     C                             (opr <> 'ISSET')
     C                   RETURN    -1
     C                   ENDIF
      * Check range of descriptor
     C                   IF        (sd < 0) or (223 < sd)
     C                   RETURN    -2
     C                   ENDIF
      *
      * Get index of element
     C     sd            DIV       32            intidx            3 0
     C                   MVR                     remainder         3 0
     C                   ADD       1             intidx
      * Copy an element to array of chars
     C                   MOVE      inta(intidx)  int4
      * Get index of array of chars
     C     remainder     DIV       8             chridx            3 0
     C                   MVR                     chrpos            1 0
     C     4             SUB       chridx        chridx
      * Bit operations
     C                   EVAL      chrposc = %SUBST(bitstr : chrpos + 1 : 1)
     C                   SELECT
      *   FD_SET
     C                   WHEN      opr = 'SET'
     C                   BITON     chrposc       chra(chridx)
     C                   MOVE      int4          inta(intidx)
      *   FD_CLR
     C                   WHEN      opr = 'CLR'
     C                   BITOFF    chrposc       chra(chridx)
     C                   MOVE      int4          inta(intidx)
      *   FD_ISSET
     C                   WHEN      opr = 'ISSET'
     C                   TESTB     chrposc       chra(chridx)             10
     C   10              EVAL      rc = 1
     C                   ENDSL
      *
     C                   RETURN    rc
      *
     PFD_              E
