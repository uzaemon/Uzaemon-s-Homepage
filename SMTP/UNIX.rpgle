      ********************************************************************
      * Prototypes and valiables for Sockets APIs
      * Sockets Programming V4 SC41-5422-00 Chapter 3.  Application Programming
      * OS/400 UNIX-Type APIs V4 SC41-5875-00 Chapter 7.  Sockets APIs
      *
      * socket()--Create Socket ................................................
     Dsocket           PR            10I 0 EXTPROC('socket')
     D addr_family                   10I 0 VALUE
     D type                          10I 0 VALUE
     D protocol                      10I 0 VALUE
      *
      * Socket descriptor
     Dsd               S             10I 0
      * Internet domain                                       QSYSINC/SYS.SOCKET
     DAF_INET          S             10I 0 INZ(2)
      * stream                                                QSYSINC/SYS.SOCKET
     DSOCK_STREAM      S             10I 0 INZ(1)
      * choose default                                        QSYSINC/NETINET.IN
     DIPPROTO_IP       S             10I 0 INZ(0)
      *
      * inet_addr()--Translate Full Address to 32-bit IP Address................
     Dinet_addr        PR            10U 0 EXTPROC('inet_addr')
     D addr_str_p                      *
      *
      * A "-1" returned from inet_addr()                      QSYSINC/NETINET.IN
     DIPADDR_NONE      S             10U 0 INZ(4294967295)
      *
      * gethostbyname()--Get Host Information for Host Name ....................
     Dgethostbyname    PR              *   EXTPROC('gethostbyname')
      * (Input)  The pointer to the character string that contains the name of t
     D host_name                       *   VALUE
      *
      * inet_ntoa()--Translate IP Address to Dotted Decimal Format .............
     Dinet_ntoa        PR              *   EXTPROC('inet_ntoa')
     D s_addr                        10U 0 VALUE
      *
      * connect()--Establish Connection or Destination Address .................
     Dconnect          PR            10I 0 EXTPROC('connect')
     D sd                            10I 0 VALUE
     D sockaddr_p                      *   VALUE
     D addr_length                   10I 0 VALUE
      *
      * gethostname()--Retrieve Host Name ......................................
     Dgethostname      PR            10I 0 EXTPROC('gethostname')
     D name                            *   VALUE
     D length                        10I 0 VALUE
      *
      * getdomainname()--Retrieve Domain Name ..................................
     Dgetdomainname    PR            10I 0 EXTPROC('getdomainname')
     D name                            *   VALUE
     D length                        10I 0 VALUE
      *
      * select()--Wait for Events on Multiple Sockets ..........................
     Dselect           PR            10I 0 EXTPROC('select')
     D max_descriptor                10I 0 VALUE
     D read_set                        *   VALUE
     D write_set                       *   VALUE
     D exception_set                   *   VALUE
     D wait_time                       *   VALUE
      *
      * read()--Receive Data ...................................................
     Dread             PR            10I 0 EXTPROC('read')
     D sd                            10I 0 VALUE
     D buffer_p                        *   VALUE
     D buffer_length                 10I 0 VALUE
      *
      * write()--Send Data .....................................................
     Dwrite            PR            10I 0 EXTPROC('write')
     D sd                            10I 0 VALUE
     D buffer_p                        *   VALUE
     D buffer_length                 10I 0 VALUE
      *
     Dbuffer_length    S             10I 0
     Dbytesr           S                   LIKE(ssize_t)
     Dbytesw           S                   LIKE(ssize_t)
      *
      * Used by functions that return a count of bytes or      QSYSINC/SYS.TYPES
     Dssize_t          S             10I 0
      *
      * close()--End Socket Connection .........................................
     Dclose            PR            10I 0 EXTPROC('close')
     D descriptor                    10I 0 VALUE
      ********************************************************************
      * User function for FD_ macros ...........................................
     DFD_              PR            10I 0
     D opr                            5    VALUE
     D sd                            10I 0 VALUE
     D mask_p                          *   VALUE
      ********************************************************************
      * generic socket address .............................. QSYSINC/SYS.SOCKET
     Dsockaddr         DS
      * address family
     D sa_family                      5U 0
      * address
     D sa_data                       14
      *
      * socket address (internet) ........................... QSYSINC/NETINET.IN
     Dsockaddr_in      DS
      * address family (AF_INET)
     D sin_family                     5I 0
      * port number
     D sin_port                       5U 0
      * IP address
     D sin_addr                      10U 0
      * reserved - must be 0x00's
     D sin_zero                       8
      * host entry ............................................. QSYSINC/H.NETDB
     Dhostent          DS                  BASED(hostp)
      * host name
     D h_name                          *
      * NULL-terminated list of host aliases
     D h_aliases                       *
      * address family of address
     D h_addrtype                    10I 0
      * length of each address in h_addr_list
     D h_length                      10I 0
      * NULL-terminated list of host addresses
     D h_addr_list                     *
      *
     D*hostp            S               *
      * internet address .................................... QSYSINC/NETINET.IN
     Din_addr          DS                  BASED(in_addr_p)
      * IP address
     D s_addr                        10U 0
      *
     Din_addr_p        S               *   BASED(in_addr_pp)
      * timeval strucutre ..................................... QSYSINC/SYS.TIME
     Dtimeval          DS
      * second
     D tv_sec                        10I 0
      * microseconds
     D tv_usec                       10I 0
      *
      ********************************************************************
      * Prototypes and valiables for Integrated File System APIs
      * OS/400 UNIX-Type APIs V4 SC41-5875-00 Chapter 2. IFS APIs
      *
      * open()--Open File ......................................................
     Dopen             PR            10I 0 EXTPROC('open')
     D path                            *   VALUE
     D oflag                         10I 0 VALUE
     D mode                          10U 0 VALUE OPTIONS(*NOPASS)
     D codepage                      10U 0 VALUE OPTIONS(*NOPASS)
      *
     Dfildes           S             10I 0
      *
      * File Access Modes for open() ........................... QSYSINC/H.FCNTL
      *   Open for reading only
     DO_RDONLY         C                   1
      *   Open for writing only
     DO_WRONLY         C                   2
      *   Open for reading and writing
     DO_RDWR           C                   4
      * oflag Values for open() ................................ QSYSINC/H.FCNTL
      *   Create file if it doesn't exist
     DO_CREAT          C                   8
      *   Exclusive use flag
     DO_EXCL           C                   16
      *   Truncate flag
     DO_TRUNC          C                   64
      * File Status Flags for open() and fcntl() ............... QSYSINC/H.FCNTL
      *   No delay...return EAGAIN if it will block
     DO_NONBLOCK       C                   128
      *   Set append mode
     DO_APPEND         C                   256
      *   code page flag
     DO_CODEPAGE       C                   8388608
      *   text data flag
     DO_TEXTDATA       C                   16777216
      * oflag Share Mode Values for open() ..................... QSYSINC/H.FCNTL
      *   Share with readers only
     DO_SHARE_RDONLY   C                   65536
      *   Share with writers only
     DO_SHARE_WRONLY   C                   131072
      *   Share with readers and writers
     DO_SHARE_RDWR     C                   262144
      *   Share with neither readers nor writers
     DO_SHARE_NONE     C                   524288
      * Definitions of File Modes and File Types .............. QSYSINC/SYS.STAT
      *   Read for owner
     DS_IRUSR          C                   256
      *   Write for owner
     DS_IWUSR          C                   128
      *   Execute and Search for owner
     DS_IXUSR          C                   64
      *   Read, Write, Execute for owner (S_IRUSR|S_IWUSR|S_IXUSR)
     DS_IRWXU          C                   448
      *   Read for group
     DS_IRGRP          C                   32
      *   Write for group
     DS_IWGRP          C                   16
      *   Execute and Search for group
     DS_IXGRP          C                   8
      *   Read, Write, Execute for group (S_IRGRP|S_IWGRP|S_IXGRP)
     DS_IRWXG          C                   56
      *   Read for other
     DS_IROTH          C                   4
      *   Write for other
     DS_IWOTH          C                   2
      *   Execute and Search for other
     DS_IXOTH          C                   1
      *   Read, Write, Execute for other (S_IROTH|S_IWOTH|S_IXOTH)
     DS_IRWXO          C                   7
      *
      * creat()--Create or Rewrite File ........................................
     Dcreat            PR            10I 0 EXTPROC('creat')
     D path                            *   VALUE
     D mode                          10I 0 VALUE
      *
      * unlink()--Remove Link to File ..........................................
     Dunlink           PR            10I 0 EXTPROC('unlink')
     D path                            *   VALUE
      *
      * ftruncate()--Truncate File .............................................
     Dftruncate        PR            10I 0 EXTPROC('ftruncate')
     D fildes                        10I 0 VALUE
     D offset                        10I 0 VALUE
      *
      * lseek -- Set File Read/Write Offset ....................................
     Dlseek            PR            10I 0 EXTPROC('lseek')
     D fildes                        10I 0 VALUE
     D offset                        10I 0 VALUE
     D whence                        10I 0 VALUE
      * off_t ................................................ QSYSINC/SYS.TYPES
      *
      * The origin must be one of the following constants ..... QSYSINC/H.UNISTD
      * Seek to given position
     DSEEK_SET         C                       0
      * Seek relative to current position
     DSEEK_CUR         C                       1
      * Seek relative to end of file
     DSEEK_END         C                       2
      * stat()--Get File Information ...........................................
     Dstat             PR            10I 0 EXTPROC('stat')
     D path                            *   VALUE
     D buf                             *   VALUE
      *
      * structure stat ........................................ QSYSINC/SYS.STAT
     Dstatinfo         DS
      * Data types in () are defined at QSYSINC/SYS.TYPES
      * File mode (typedef unsigned int   mode_t;)
     D st_mode                       10U 0
      * File serial number (typedef unsigned int   ino_t;)
     D st_ino                        10U 0
      * Number of links (typedef unsigned short nlink_t;)
     D*st_nlink                       5U 0
     D st_nlink                      10U 0
      * User ID of the owner of file (typedef unsigned int   uid_t;)
     D st_uid                        10U 0
      * Group ID of the group of file (typedef unsigned int   gid_t;)
     D st_gid                        10U 0
      * For regular files, the file size in bytes (typedef int  off_t;)
     D st_size                       10I 0
      * Time of last access (typedef long int time_t;)
     D st_atime                      10I 0
      * Time of last data modification typedef (long int time_t;)
     D st_mtime                      10I 0
      * Time of last file status change (typedef long int time_t;)
     D st_ctime                      10I 0
      * ID of device containing file (typedef unsigned int   dev_t;)
     D st_dev                        10U 0
      * Size of a block of the file (typedef unsigned int   size_t;)
     D st_blksize                    10U 0
      * Allocation size of the file    unsigned long
     D st_allocsize                  10U 0
      * AS/400 object type (typedef char qp0l_objtype_tÝ11¨;)
     D st_objtype                    11
      * Object data codepage           unsigned short
     D st_codepage                    5U 0
      * reserved - must be 0x00's      charÝ62¨
     D st_reserved1                  62    INZ(*ALLX'00')
      * File serial number generation id  unsigned int
     D st_ino_gen_id                 10U 0
      *
      ********************************************************************
      * ILE C/C++ for AS/400 Run-Time Library Reference V4 SC09-2715-00
      *
      * fopen() -- Open Files ..................................................
     Dfopen            PR              *   EXTPROC('fopen')
     D file                            *   VALUE
     D mode                            *   VALUE
      *
      * fread() -- Read Items ..................................................
     Dfread            PR            10I 0 EXTPROC('fread')
     D buffer                          *   VALUE
     D size                          10I 0 VALUE
     D count                         10I 0 VALUE
     D fp                              *   VALUE
      *
      * fclose() -- Close Stream ...............................................
     Dfclose           PR            10I 0 EXTPROC('fclose')
     D fp                              *   VALUE
      *
      * ferror() -- Test for Read/Write Errors .................................
     Dferror           PR            10I 0 EXTPROC('ferror')
     D fp                              *   VALUE
      *
      * feof() -- Test End-of-File Indicator ...................................
     Dfeof             PR            10I 0 EXTPROC('feof')
     D fp                              *   VALUE
      *
      * fseek -- Reposition File Position ......................................
     Dfseek            PR            10I 0 EXTPROC('fseek')
     D fp                              *   VALUE
     D offset                        10I 0 VALUE
     D origin                        10I 0 VALUE
      *
      ********************************************************************
      * Prototypes and valiables for errno APIs
      *   QSYSINC/SYS.ERRORNO has descriptions of errno.
      *   service program is QSYS/QC2UTIL1
      *
      * Undoumented? errno function ............................................
     Dgeterrno         PR              *   EXTPROC('__errno')
      *
      * strerror() -- Set Pointer to Run-Time Error Message ....................
     Dstrerror         PR              *   EXTPROC('strerror')
     D errno                         10I 0 VALUE
      *
      ********************************************************************
      * Prototypes and valiables for getenv() APIs
      *
      * Prototype for getenv() API .............................................
     Dgetenv           PR              *   EXTPROC('Qp0zGetEnvCCSID')
     D                                 *   VALUE
     D                                 *   VALUE
      *
      *****************************************************************
      * Prototypes and valiables for iconv() APIs
      * OS/400 National Language Support APIs V4  2.1 Data Conversion APIs
      *
      * iconv_open()--Code Conversion Allocation API ...........................
     Diconv_o          PR            52    EXTPROC('iconv_open')
     D                                 *   VALUE
     D                                 *   VALUE
      *
      * iconv()--Code Conversion API ...........................................
     Diconv            PR            10U 0 EXTPROC('iconv')
     D                               52    VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
     D                                 *   VALUE
      *
      * iconv_close()--Code Conversion Deallocation API ........................
     Diconv_c          PR            10I 0 EXTPROC('iconv_close')
     D                               52    VALUE
      *
     Diconv_t          DS
     D iconv_return                  10I 0
     D iconv_cd                      10I 0 DIM(12)
      *
     Dtocode           DS
     D IBMCCSID_2                     8    INZ('IBMCCSID')
     D iconv_toccsid                  5
     D iconv_rvd_2                   19    INZ(*ALLX'00')
      *
     Dfromcode         DS
     D IBMCCSID_1                     8    INZ('IBMCCSID')
     D iconv_frmccsid                 5
     D iconv_options                  7    INZ('0000010')
     D iconv_rvd_1                   12    INZ(*ALLX'00')
      *
      ********************************************************************
      * Prototypes and valiables for misc APIs
      *
      * Prototype for strlen() API .............................................
     Dstrlen           PR            10I 0 EXTPROC('strlen')
     D                                 *   VALUE
      **************************************************************************
      * Constants
     DNULL             C                   X'00'
     DCRLF             C                   X'0D0A'
