      *****************************************************************
      * Send program message
      *     return :  0 Normal end
      *              -1 mge_type not valid
      *              -2 API-QMHSNDPM Failed
      *     msg_data : Message text                                           I
      *     msg_num  : 1 - send escape message (fatal error, CPF9899)         I
      *                2 - send escape message (recoverble error, CPI3701)
      *                3 - send daignostic message (information, warning)
      *                4 - send completion message (normal end)
      *     excpID : Exception ID                                             O
      *****************************************************************
     HNOMAIN
      * User space error code.
      /COPY QSYSINC/QRPGLESRC,QUSEC
      * Prototype for itself.
      /COPY H,USER
      *
     Psndpm            B                   EXPORT
     Dsndpm            PI            10I 0
     D msg_data                     256    VALUE
     D msg_num                        1P 0 VALUE
     D excpID                         7
      *
     Dmsg_file         S             20    INZ('QCPFMSG   *LIBL')
     Dmsg_len          S              9B 0
     Dstack_ctr        S              9B 0 INZ(1)
      *
     C                   EVAL      msg_len = %LEN(%TRIMR(msg_data))
     C                   SELECT
      * 1 - send escape message (fatal error) 512
     C                   WHEN      msg_num = 1
     C                   EVAL      msg_type = '*ESCAPE'
     C                   EVAL      msg_id = 'CPF9897'
     C                   EVAL      stack_ent = '*'
     C                   EVAL      stack_ctr = 3
      * 2 - send escape message (recoverble/partial error) 512
     C                   WHEN      msg_num = 2
     C                   EVAL      msg_type = '*ESCAPE'
     C                   EVAL      msg_id = 'CPF9898'
     C                   EVAL      stack_ent = '*'
     C                   EVAL      stack_ctr = 3
      * 3 - send daignostic message (information, warning) 132
     C                   WHEN      msg_num = 3
     C                   EVAL      msg_type = '*DIAG'
     C                   EVAL      msg_id = 'CPDA0FF'
     C                   EVAL      stack_ent = '*'
     C                   EVAL      stack_ctr = 0
      * 4 - send completion message (normal end) 255
     C                   WHEN      msg_num = 4
     C                   EVAL      msg_type = '*COMP'
     C                   EVAL      msg_id = 'CPI8859'
     C                   EVAL      stack_ent = '*'
     C                   EVAL      stack_ctr = 3
      * invalid msg_num
     C                   OTHER
     C                   RETURN    -1
     C                   ENDSL
      *
     C                   CALL      'QMHSNDPM'
     C                   PARM                    msg_id            7        I
     C                   PARM                    msg_file                   I
     C                   PARM                    msg_data                   I
     C                   PARM                    msg_len                    I
     C                   PARM                    msg_type         10        I
     C                   PARM                    stack_ent        10        I
     C                   PARM                    stack_ctr                  I
     C                   PARM                    msg_key           4        O
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   MOVE      QUSEI         excpID
     C                   RETURN    -2
     C                   ENDIF
      *
     C                   RETURN                  0
     Psndpm            E
