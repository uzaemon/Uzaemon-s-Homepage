      *****************************************************************
      * Prepare user space for APIs
      *     spc_name : 'name______library___'                                 I
      *     excpID : Exception ID                                             O
      *     rc :  0 normal end
      *          -1 Failed to create user space (API-QUSCRTUS)
      *          -2 Failed to change user space attribute (API-QUSCUSAT)
      *****************************************************************
     HNOMAIN
      * User space error code.
      /COPY QSYSINC/QRPGLESRC,QUSEC
      * Prototype for itself.
      /COPY H,USER
      *
     Pprepareus        B                   EXPORT
     Dprepareus        PI            10I 0
     D spc_name                      20    VALUE
     D excpID                         7
      *
     Dspc_size         S              9B 0
     Dchg_attr         DS
     D nbr_attr                       9B 0 INZ(1)
     D attr_key                       9B 0 INZ(3)
     D data_size                      9B 0 INZ(1)
     D attr_data                      1    INZ('1')
      *
      * Set user space not to raise exception
     C                   Z-ADD     16            QUSBPRV
      * Create user space
     C                   CALL      'QUSCRTUS'
     C                   PARM                    spc_name                   I
     C                   PARM      *BLANKS       spc_attr         10        I
     C                   PARM      1024          spc_size                   I
     C                   PARM      X'00'         spc_init          1        I
     C                   PARM      '*CHANGE'     spc_aut          10        I
     C                   PARM      *BLANKS       spc_text         50        I
     C*                  PARM      '*YES'        spc_replace      10        I
     C                   PARM      '*NO'         spc_replace      10        I
     C                   PARM                    QUSEC                      I/O
     C                   PARM      '*USER'       spc_domain       10        I
      *
     C                   IF        QUSBAVL > 0
     C                   MOVE      QUSEI         excpID
     C                   RETURN                  -1
     C                   END
      * Change the user space to extendable
     C                   CALL      'QUSCUSAT'
     C                   PARM                    lib_name         10        O
     C                   PARM                    spc_name                   I
     C                   PARM                    chg_attr                   I
     C                   PARM                    QUSEC                      I/O
      *
     C                   IF        QUSBAVL > 0
     C                   MOVE      QUSEI         excpID
     C                   RETURN                  -2
     C                   END
      *
     C                   RETURN                  0
     Pprepareus        E
