# Installation

1. Download hpt.exe and execute it on Windows95/98/NT to extract hpt.savf.
1. Create save-file on your AS/400.
1. Connect to the AS/400 using any FTP client software.
1. Put the distribution (hpt.savf) to the save-file in binary mode.
1. Restore objects from the save-file using RSTOBJ command.

## Sample instruction

Create save-file on the target AS/400:

<code>
> CRTSAVF FILE(QGPL/HPT)
  File HPT created in library QGPL.
</code>

Send save-file from Windows95/98/NT/2000 command prompt:

<code>
E:\>ftp your_as400_hostname
Connected to ????.
220-QTCP AT ????.
220 CONNECTION WILL CLOSE IF IDLE MORE THAN 5 MINUTES.
User (????:(none)): as400_user_id
331 ENTER PASSWORD.
Password:enter_password_for_the_user_id
230 ???? LOGGED ON.
ftp> bi
200 REPRESENTATION TYPE IS BINARY IMAGE.
ftp> put hpt.savf qgpl/hpt (replace
200 PORT SUBCOMMAND REQUEST SUCCESSFUL.
150 SENDING FILE TO MEMBER HPT IN FILE HPT IN LIBRARY QGPL.
250 FILE TRANSFER COMPLETED SUCCESSFULLY.
287232 bytes sent in 1.10 seconds (260.88 Kbytes/sec)
ftp> quit
221 QUIT SUBCOMMAND RECEIVED.
</code>

Go back to the 5250 session:

<code>
> DSPSAVF FILE(QGPL/HPT)
> CRTLIB LIB(HPT)
  Library HPT created.
> RSTOBJ OBJ(*ALL) SAVLIB(HPT) DEV(*SAVF) SAVF(QGPL/HPT)
  2 objects restored from HPT to HPT.
> STRREXPRC SRCMBR(MAKE) SRCFILE(HPT/SOURCE)
</code>

<p></p>
<br>

---

# Usage

## SPL2STMF

**Syntax**

<code>
                     CONVERT SPOOLED FILE TO STMF (SPL2STMF)

 TYPE CHOICES, PRESS ENTER.

 SPOOLED FILE NAME  . . . . . . . FILE                     
 STREAM FILE NAME . . . . . . . . TOSTMF         
                   
 WORKSTATION CUSTOMIZING OBJECT   WSCST                    
   LIBRARY  . . . . . . . . . . .                  *LIBL     
 JOB NAME . . . . . . . . . . . . JOB            *         
   USER NAME  . . . . . . . . . .                            
   JOB NUMBER . . . . . . . . . .                        
 SPOOLED FILE NUMBER  . . . . . . SPLNBR         *LAST 
 REPLACE STREAM FILE  . . . . . . REPLACE        *YES

                            ADDITIONAL PARAMETERS

 ENABLE DEBUG PRINT OUT . . . . . DEBUG          *NO 
</code>

**Operation (SCS spooled file to text stream file)**

<code>
> ADDLIBLE LIB(HPT) POSITION(*LAST)
  LIBRARY HPT ADDED TO LIBRARY LIST.
> OVRPRTF FILE(QPSUPRTF) CHRID(*JOBCCSID)
> STRSEU SRCFILE(HPT/SOURCE) SRCMBR(SPL2STMFRP) OPTION(6)
  MEMBER SPL2STMFRP HAS BEEN PRINTED.
> SPL2STMF FILE(QPSUPRTF) TOSTMF('/tmp/spl2stmfrp.txt') WSCST(TEXTJ)
  Stream file generated sucessfully. execution time 0 min 2 sec, total
    pages = 14
> DLTOVR FILE(QPSUPRTF) 
</code>

## TIFF2PDF

**Syntax**

<code>
                         Convert TIFF to PDF (TIFF2PDF)

 TYPE CHOICES, PRESS ENTER.

 TIFF path name . . . . . . . . . TIFF           
                   
 PDF path name  . . . . . . . . . PDF            
</code>
                    
**Operation (AFP spooled file to PDF)**

<code>
> ADDLIBLE LIB(HPT) POSITION(*LAST)
  LIBRARY HPT ADDED TO LIBRARY LIST.
> ADDLIBLE LIB(TIFFLIB) POSITION(*LAST)
  LIBRARY TIFFLIB ADDED TO LIBRARY LIST.
> OVRPRTF FILE(QPSUPRTF) DEVTYPE(*AFPDS) CDEFNT(QFNT61/X0N13N) IGCCDEFNT(QF
  NT61/X0M26F)
> STRSEU SRCFILE(HPT/SOURCE) SRCMBR(SPL2STMFRP) OPTION(6)
  MEMBER SPL2STMFRP HAS BEEN PRINTED.
> SPL2STMF FILE(QPSUPRTF) TOSTMF('/tmp/spl2stmfrp.tif') WSCST(QWPTIFFG4)
  Stream file generated sucessfully. execution time 0 min 2 sec, total
    pages = 14
> TIFF2PDF TIFF('/tmp/spl2stmfrp.tif') PDF('/tmp/spl2stmfrp.pdf')
  TIFF2PDF completed successfully.
> DLTOVR FILE(QPSUPRTF)                                            
</code>

## Note

- Major limitations

  - SPL2STMF cannot convert spooled file larger than 16MB.
  - TIFF2PDF supports only A4 paper size.

- Before you start

  - Add library 'HPT' and/or 'TIFFLIB' (or library which contains necessary objects) to your library list. 

- Make your own WSCST

  - SPL2STMF requires WSCST object name. You may exec 'WRKOBJ OBJ(QSYS/*ALL) OBJTYPE(*WSCST)' to determine which WSCST to use. You can create your own WSCST for special purpose. For example, to convert DBCS(Japanese) SCS spooled file to plain Shift-JIS text file, use following WSCST source file.

<code>
        *************** BEGINNING OF DATA ******************************************
0001.00 :WSCST DEVCLASS=TRANSFORM.
0002.00
0003.00     :TRNSFRMTBL.
0004.00     :PRTDTASTRM
0005.00       DATASTREAM=IBMNONPAGES.   /* printer datastream IBM 5577 (SHIFT-JIS) */
0051.00     :SPACE
0052.00       DATA ='20'X.
0055.00 /*  :CARRTN         */
0056.00 /*    DATA ='0D'X.  */
0057.00     :FORMFEED
0058.00       DATA ='0C'X.
0059.00     :LINEFEED
0060.00       DATA ='0D0A'X.
0417.00 :EWSCST.
        ****************** END OF DATA *********************************************
</code>
