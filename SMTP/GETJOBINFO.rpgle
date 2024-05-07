      *****************************************************************
      * Get current job information
      *     job_name : job name                                               O
      *     user_name : user name                                             O
      *     job_number : job number                                           O
      *     act_time : Date Job Active                                        O
      *     dftjobccsid : Default Coded Char Set Id                           O
      *     excpID : Exception ID                                             O
      *     rc :  0 normal end
      *          -1 Failed to get pointer to user space (API-QUSPTRUS)
      *          -2 Failed to retreive job info (API-QUSRJOBI)
      *****************************************************************
     HNOMAIN
      * User space error code.
      /COPY QSYSINC/QRPGLESRC,QUSEC
      * Header for API-QUSRJOBI
      /COPY QSYSINC/QRPGLESRC,QUSRJOBI
      * Prototype for itself.
      /COPY H,USER
      *
     Pgetjobinfo       B                   EXPORT
     Dgetjobinfo       PI            10I 0
     D spc_name                      20    VALUE
     D job_name                      10
     D user_name                     10
     D job_number                     5
     D act_time                      13
     D jobccsid                       9B 0
     D dftjobccsid                    9B 0
     D excpID                         7
      *
     Drtvbuf           S          32767    BASED(spc_ptr)
     Dspc_size         S              9B 0
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
      * Retreive job information
     C                   CALL      'QUSRJOBI'
     C                   PARM                    rtvbuf                     O
     C                   PARM      32767         spc_size                   I
     C                   PARM      'JOBI0400'    rtv_fmt           8        I
     C                   PARM      '*'           qualifiedjobn    26        I
     C                   PARM      *BLANKS       internaljobid    16        I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   MOVE      QUSEI         excpID
     C                   RETURN                  -2
     C                   END
      * Copy job information to data structure
     C                   MOVEL     rtvbuf        QUSI0400
      * Get job info
     C                   MOVE      QUSJN06       job_name
     C                   MOVE      QUSUN05       user_name
     C                   MOVE      QUSJNBR05     job_number
     C                   MOVE      QUSDJA        act_time
     C                   Z-ADD     QUSCCSID07    jobccsid
     C                   Z-ADD     QUSDCCSI      dftjobccsid
      *
     C                   RETURN                  0
     Pgetjobinfo       E
