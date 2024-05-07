      *****************************************************************
      * Get physical file information
      *     spc_name : 'name______library___'                                 I
      *     file_name : 'file______library___'                                I
      *     actual_name : Qualified returned file name                        O
      *     pflf : *PF or *LF                                                 O
      *     file_type : *SRC or *DATA                                         O
      *     program described file or external : *PGM or *EXT                 O
      *     max_fields : Maximum number of fields (1-8000)                    O
      *     record_len : Maximum Record Length (1-32766)                      O
      *     file_ccsid : CCSID of the file                                    O
      *     excpID : Exception ID                                             O
      *     rc :  0 normal end
      *          -1 Failed to get pointer to user space (API-QUSPTRUS)
      *          -2 Failed to retreive file definition templete (API-QDBRTVFD)
      *          -3 Failed to retreive format definition templete (API-QDBRTVFD)
      *****************************************************************
     HNOMAIN
      * User space error code.
      /COPY QSYSINC/QRPGLESRC,QUSEC
      * Header for API-QDBRTVFD
      /COPY QSYSINC/QRPGLESRC,QDBRTVFD
      * Prototype for itself.
      /COPY H,USER
      *
     Pgetpfinfo        B                   EXPORT
     Dgetpfinfo        PI            10I 0
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
     Dspc_size         S              9B 0
     Drtvbuf           S          32767    BASED(spc_ptr)
      *
      * Get pointer to user space
     C                   CALL      'QUSPTRUS'
     C                   PARM                    spc_name                   I
     C                   PARM                    spc_ptr                    O
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   MOVE      QUSEI         excpID
     C                   RETURN                  -1
     C                   END
      * Retreive file information FILD0100 (File definition templete)
     C                   CALL      'QDBRTVFD'
     C                   PARM                    rtvbuf                     O
     C                   PARM      32767         spc_size                   I
     C                   PARM                    actual_name      20        O
     C                   PARM      'FILD0100'    rtv_fmt           8        I
     C                   PARM                    file_name                  I
     C                   PARM      '*FIRST'      rec_fmt          10        I
     C                   PARM      '1'           override          1        I
     C                   PARM      '*FILETYPE'   system_loc       10        I
     C                   PARM      '*EXT'        format_type      10        I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   MOVE      QUSEI         excpID
     C                   RETURN                  -2
     C                   END
      * Copy file information to data structure
     C                   MOVEL     rtvbuf        QDBQ25
      * Check the file
      *   Attribute Bytes
     C                   MOVEL     QDBBITS27     attr_1            1
      *     *PF or *LF?
     C                   TESTB     '2'           attr_1                   30
     C   30              EVAL      pflf = '*LF'
     C  N30              EVAL      pflf = '*PF'
      *     *SRC or *DATA?
     C                   TESTB     '4'           attr_1                   30
     C   30              EVAL      file_type = '*SRC'
     C  N30              EVAL      file_type = '*DATA'
      *   Program described?
     C                   TESTB     '7'           QDBBITS29                30
     C   30              EVAL      pgmd = '*PGM'
     C  N30              EVAL      pgmd = '*EXT'
      *   Maximum number of fields (1-8000)
     C                   Z-ADD     QDBXFNUM      max_fields
      *   Maximum Record Length (1-32766)
     C                   Z-ADD     QDBFMXRL      record_len
      * Retreive file information FILD0200 (Format definition templete)
     C                   CALL      'QDBRTVFD'
     C                   PARM                    rtvbuf                     O
     C                   PARM      32767         spc_size                   I
     C                   PARM                    actual_name      20        O
     C                   PARM      'FILD0200'    rtv_fmt           8        I
     C                   PARM                    file_name                  I
     C                   PARM      '*FIRST'      rec_fmt          10        I
     C                   PARM      '1'           override          1        I
     C                   PARM      '*FILETYPE'   system_loc       10        I
     C                   PARM      '*EXT'        format_type      10        I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   MOVE      QUSEI         excpID
     C                   RETURN                  -3
     C                   END
      * Copy file information to data structure
     C                   MOVEL     rtvbuf        QDBQ41
      *   Get CCSID of the file
     C                   Z-ADD     QDBFRCID      file_ccsid
      *
     C                   RETURN                  0
     Pgetpfinfo        E
