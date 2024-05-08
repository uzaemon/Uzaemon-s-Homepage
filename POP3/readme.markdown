# Installation

**OS/400 Objects**

1. Download 'pop3.exe' and execute it on Windows95/98/NT/2000/XP to extract 'pop3.savf' and "Rcvmail.java".
1. Create save-file on your AS/400.
1. Connect to the AS/400 using any FTP client software.
1. Put the distribution (pop3.savf) to the save-file in binary mode.
1. Create/restore object to library "POP3" from the save-file using RSTOBJ or RSTLIB command.
1. Run the REXX procedure.

**Stream files**

1. Download [JavaMail](https://www.oracle.com/java/technologies/javamail-releases.html) and [JAF (JavaBeans Activation Framework)](https://www.oracle.com/java/technologies/downloads.html) and unzip downloaded files.
1. Create directory "/JavaMail" on your OS/400.
1. Connect to the OS/400 using any FTP client software.
1. Put the Java source file "Rcvmail.java" to the directory "/JavaMail" in binary mode.
1. Put Sun's .jar files, "mail.jar", "activation.jar" and "mailapi.jar" (this file is not necessary for JDK 1.2 or later) to the directory "/JavaMail" in binary mode.
1. CPY or put "jt400.jar" to the directory "/JavaMail" in binary mode.
1. Compile the Java program.

## Note

"jt400.jar" can be obtained many places, e.g. if your are using V5R2 and Access for Wndows, you may find "jt400.jar" at :

- Access_for_Windows_install_directory\jt400\lib
- http://www-1.ibm.com/servers/eserver/iseries/toolbox/downloads.htm (registration required)
- \QIBM\ProdData\HTTP\Public\jt400\lib
- \QIBM\ProdData\Access\Web2\lib
- If newer version of WebSphere Application Server has been installed on your OS/400, mail.jar and activation.jar may be found at "/QIBM/ProdData/WebASxxx/java/ext" directory.

To copy from PC to AS/400, use FTP, NetServer, etc. To copy inside OS/400, use CPY command, for example :

```
> CPY OBJ('/QIBM/ProdData/HTTP/Public/jt400/lib/jt400.jar') TOOBJ('/JavaMai
  l/jt400.jar')
```

In this senario, "jt400.jar" is copoied to directory "/Javamail" but it is absolutely possible to use existing "jt400.jar" if you specify the CLASSPATH environment variable when compile and run the Java program.

In either case, run CRTJVAPGM to achive the best performance.

```
> SBMJOB CMD(CRTJVAPGM CLSF('/JavaMail/*') OPTIMIZE(40))
  Job 081009/XXXXX/QDFTJOBD submitted to job queue QBATCH in library QGPL.
```

As CRTJVAPGM takes long time and enormous CPU time, I recommned to run the commnad when the system is idle.

## Sample instruction

Create save-file on the target AS/400:

```
> CRTSAVF FILE(QGPL/POP3)
  File POP3 created in library QGPL.
```

Send save-file from Windows95/98/NT/2000 command prompt:

```
C:\>ftp your_as400_hostname
Connected to ????.
220-QTCP AT ????.
220 CONNECTION WILL CLOSE IF IDLE MORE THAN 5 MINUTES.
User (????:(none)): as400_user_id
331 ENTER PASSWORD.
Password:enter_password_for_the_user_id
230 ???? LOGGED ON.
ftp> bi
200 REPRESENTATION TYPE IS BINARY IMAGE.
ftp> quote site namefmt 0
250  NOW USING NAMING FORMAT "0".
ftp> put pop3.savf qgpl/pop3
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO MEMBER POP3 IN FILE POP3 IN LIBRARY QGPL.
250 FILE TRANSFER COMPLETED SUCCESSFULLY.
ftp: 101904 bytes sent in 4.33Seconds 23.56Kbytes/sec.
```
(Put stream files)
```
ftp> quote site namefmt 1
250  NOW USING NAMING FORMAT "1".
ftp> cd /JavaMail
250 "/JavaMail" IS CURRENT DIRECTORY.
ftp> put activation.jar
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO /JavaMail/activation.jar
250 FILE TRANSFER COMPLETED SUCCESSFULLY.
ftp: 54665 bytes sent in 0.00Seconds 54665000.00Kbytes/sec.
ftp> put jt400.jar
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO /JavaMail/jt400.jar
250 FILE TRANSFER COMPLETED SUCCESSFULLY.
ftp: 3436558 bytes sent in 1091.23Seconds 3.15Kbytes/sec.
ftp> put mail.jar
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO /JavaMail/mail.jar
250 FILE TRANSFER COMPLETED SUCCESSFULLY.
ftp: 305434 bytes sent in 49.86Seconds 6.13Kbytes/sec.
ftp> put Rcvmail.java
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO /JavaMail/Rcvmail.java
250 FILE TRANSFER COMPLETED SUCCESSFULLY.
ftp: 20659 bytes sent in 0.00Seconds 20659000.00Kbytes/sec.
```
Optionally, you may put "mailapi.jar" also.
```
ftp> dir
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
125 LIST STARTED.
XXXXX           54665 03/05/18 01:06:11 *STMF      activation.jar
XXXXX         3436558 03/05/18 01:39:50 *STMF      jt400.jar
XXXXX          305434 03/05/18 01:40:55 *STMF      mail.jar
XXXXX           20659 03/05/18 01:41:24 *STMF      Rcvmail.java
250 LIST COMPLETED.
ftp: 255 bytes received in 0.00Seconds 255000.00Kbytes/sec.
ftp> quit
221 QUIT SUBCOMMAND RECEIVED.
```

Go back to the 5250 session to restore and make objects. You should examine source file POP3/SOURCE.MAKE to appropriately complie object. For example, if you are using V5R2, new OUTPUT paramter can be specified to RUNJVA command.

```
> RSTLIB SAVLIB(POP3) DEV(*SAVF) SAVF(QGPL/POP3)
  2 objects restored from POP3 to POP3.
> CHGCURLIB CURLIB(POP3)
  Current library changed to POP3.
> STRREXPRC SRCMBR(MAKE) SRCFILE(POP3/SOURCE)
  Start RCVM compilation.
   You must have authority to create objects.

      * * * * * * * * * * * * * * * * * * * * * *

  creating CL program ...
    result-> 0
  creating CMD definition ...
    result-> 0
  creating database files ...
    result-> 0
    result-> 0

  Compile finished. Confirm error(s) if exists.

  Press ENTER to end terminal session.
> DLTF FILE(QGPL/POP3) Object POP3 in QGPL type *FILE deleted.
```

**Start Qshell session to compile the Java program :**

```
> QSH
> cd /JavaMail
  $
> ls -la
  total: 3.776 megabytes
  drwxrwxrwx   2 XXXXX   0                 86016 May 12 11:40 .
  drwxrwxrwx  42 QSYS    0                208896 May 11 12:55 ..
  -rwxrwxrwx   1 XXXXX   0                 54665 May 12 11:14 activation.jar
  -rwxrwxr-x   1 XXXXX   0               2749457 Aug  3  2001 jt400.jar
  -rwxrwxrwx   1 XXXXX   0                305434 May 12 11:14 mail.jar
  -rwxrwxrwx   1 XXXXX   0                172919 May 12 11:18 mailapi.jar
  -rwxrwxrwx   1 XXXXX   0                 20659 May 11 12:59 Rcvmail.java
  $
```

Compile the Java program "Rcvmail" in accordance with JDK enviroment of your AS/400. You may, of course, compile the program on you PC which has JDK or Java development environment and send compled "Rcvmail.class" to "/JavaMail" directory of AS/400.

Here's how I compiled the program using OS/400 V4R5 and V5R2 as a test. Earlier version of OS/400 JDKs can compile the program but I have no test environment (as always, everything's at your own risk).

- Compile under V4R5 (Default JDK 1.1.8)

```
> javac -classpath .:./mail.jar:./mailapi.jar:./activation.jar:./jt400.jar:/QIB
  M/ProdData/Java400/jdk118/lib/classes.zip -deprecation Rcvmail.java
  Rcvmail.java:58: Note: The constructor java.io.PrintStream(java.io.OutputStre
  am) has been deprecated.
          PrintStream consoleout = new PrintStream(new FileOutputStream(debugfi
  le, true));
                                   ^
  Note: Rcvmail.java uses a deprecated API.  Please consult the documentation f
  or a better alternative.
  2 warnings
  $
```

- Compile under V4R5 (JDK 1.3)

```
> /QIBM/ProdData/Java400/jdk13/bin/javac -classpath .:./mail.jar:./activation.j
  ar:./jt400.jar:/QIBM/ProdData/Java400/jdk13/lib/rt.jar Rcvmail.java
  $
```

- Compile under V5R2 (Default JDK 1.3.1)

```
> javac -classpath .:./mail.jar:./activation.jar:./jt400.jar Rcvmail.java
$
```


<p></p>
<br>

---

# RCVM - Usage

There are two ways to use this mail (POP3) client program. Primary interface is OS/400 command interface, "RCVM" which make it easier to run the program by providing default values and validate input fields. Java program "Rcvmail.class" runs by itself on OS/400 and even other Java execution environments.

## OS/400 command interface

```
                            Receive POP3 Mail (RCVM)

 Type choices, press Enter.

 Mail account . . . . . . . . . . ACCOUNT      >           
 Password for the mail account  . PASSWORD     >


 POP3 server name . . . . . . . . MAILSERVER     *LOCALHOST
                                                 
 Communication timeout (sec)  . . TIMEOUT        30   
 Directory to store mail  . . . . HOMEDIR        *HOME
                   
 Leave mail after received  . . . LEAVEMAIL      *NO 
 Replace cid in HTML part . . . . REPLACECID     *YES
 Receive mail log file  . . . . . RCVLOGTYPE     *RDB 
 Mail recieve log file name . . . RCVLOGFILE     'rcvmlog'
                   
 RDB directory entry  . . . . . . RDBDIRE        *SYSNAME                   
 UserID for RDB . . . . . . . . . RDBUSERID      *ACCOUNT  
 Password for RDB . . . . . . . . RDBPASS



                   追加のパラメーター

 Debug output type  . . . . . . . DEBUG          *NO      
 Debug output stream file . . . . DEBUGFILE      'rcvmdebug.txt'
                                                                                
Most keywords are self-describing and you will find it easy to use.
```

Most keywords are self-describing and you will find it easy to use.

**Sample operation**

Assuming that :

- Local RDBDIRE is "ISERIES"
- Directory "/home/xxxxx" already exists.
- The OS/400 (localhost) is working as mail server.
- User "xxxxx" has a mail account on the OS/400.
- HTML mail with attachment and embedded image for use "xxxxx" is waiting .

To receive a mail for user "xxxxx", run RCVM command as follows

```
> RCVM ACCOUNT(XXXXX) PASSWORD() TIMEOUT(10) RCVLOGFILE(pop3.rcvmlog) RDBDI
  RE(ISERIES) RDBPASS() DEBUG(*BOTH)
  Mail received.                                                                
```

If you had not edited SOURCE(MAKE) and specified OUTPUT(*PRINT), you'll see annoying screen after execution, so just press enter to exit to 5250 screen. When successful, the received mails (and debug output if directory not specified) are stored in user home directory "/home/xxxxx".

```
                             Work with Object Links

 Directory  . . . . :   /home/xxxxx

 Type options, press Enter.
   2=Edit   3=Copy   4=Remove   5=Display   7=Rename   8=Display attributes
   11=Change current directory ...

 Opt   Object link            Type             Attribute    Text
       .                      DIR
       ..                     DIR
       rcvmdebug.txt          STMF
       JW370113.NOT           DIR





 Parameters or command
 ===>
 F3=Exit   F4=Prompt   F5=Refresh   F9=Retrieve   F12=Cancel   F17=Position to
 F22=Display entire field           F23=More options
```
                                                                                
A mail may have multiple parts and all parts are store in the same directory, in this example, "JW370113.NOT". In this case, the directory contains four files.

- body.htm
- body.txt
- desktop.ini
- /home/xxxxx/JW370113.NOT/000901c31d3a$659cf640$0201a8c0@user-----Blue hills.jpg

"body.htm" and "body.txt" are mail body and the names are fixed by the program. "desktop.ini" is am attachment file. The last image file is inline image file which is reffered by the "body.htm".

When RCVM received mail(s) without problem, it writes mail receive log to log file specified by RCVLOGFILE paramter. As it is not possible to what character code people use, the log file "POP3/RCVMLOG" contains character data as UNICODE. Run Query and see what has received.

```
> RUNQRY QRY(*NONE) QRYFILE((POP3/RCVMLOG))
```

If you want to use the log file from legacy languages and you want only single charset, access the log file via logical file which converts CCSID 13488(UTF-16 big endien) to other CCSID, such as 37 (US English).

```
> RUNQRY QRY(*NONE) QRYFILE((POP3/RCVMLOG))


 WORK WITH DATA IN A FILE                       Mode . . . . :   CHANGE
 Format . . . . :   RCVMLR                      File . . . . :   RCVMLOGL

 Received time (UTC):  2003-05-18-12.43.53.815000
 POP3 server hostname: localhost
       
 POP3 mail account:    XXXXX     
 Mail store home dir:  /home/XXXXX
                                                                       
 Leave mail on server: false
 Replace HTML CID:     true
 Debug option:         both   
 Debug output file:    /home/XXXXX/rcvmdebug.txt
                                                                       
 'From' header:        Somebody <foo@abc.com>
       
 'To' header:          "XXXXX@as400" <XXXXX@as400.bar.com>
       
 'Subject' header:     This is a test mail
                                                                       
 F3=Exit                 F5=Refresh               F6=Select format
 F9=Insert               F10=Entry                F11=Change      
```

## Evoke from command line (Qshell or CMD.exe) interface

The RCVM command is just a from-end to simple Java program "Rcvmail". You can use Java program Rcvmail directly even without AS/400. As the main purpose of creating this program is batch B2B or B2C data transfer, so I don't explain about this issue in detail. But if your AS/400 is out of service by some reason, it is worth to know how to run the program on Windows.

Install JRE or JDK to your Windows PC and run Rcvmail Java program without parameter.

```
E:\JavaMail>"D:\Program Files\IBM\Client Access\JRE\Bin\java" -cp .;mail.jar;act
ivation.jar;jt400.jar Rcvmail
Required parameter(s) missing.
usage: java rcvmail account password [mailserver] [timeout] [homedir] [leavemail
] [replacehtmlcid] [rcvlogtype] [rcvlogfile] [rdbdire] [rdbuserid] [rdbpassword]
 [debug] [debugfile]
```

To receive mails whitout AS/400 (DB2/400) connection, call the Java program as follows.

```
E:\JavaMail>"D:\Program Files\IBM\Client Access\JRE\Bin\java" -cp .;mail.jar;act
ivation.jar;jt400.jar Rcvmail mail_account mail_password mail_server 10 . false
 true file rcvlogfile.txt xx xx xx both rcvmdebug.txt
```

Notify that "file" is specified as rcvlogtype. In this case, Rcvmail does not try to connect to OS/400 and store mail receive log to specified file ("rcvlogfile.txt" in this example). Encoding of this file is also UNICODE (UTF-16 little endien), so you can open the log file using UNICODE enabled softwares, such as Notepad.exe on Windows XP or Excel 2002 (each field is tab-separated) for later use.


