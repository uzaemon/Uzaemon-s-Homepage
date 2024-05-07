import java.util.Properties;
import java.util.Date;
import javax.mail.*;
import javax.mail.internet.*;
import java.io.*;
import java.sql.*;

public class Rcvmail {

  private static String homedir = "";
  private static String maildir = "";
  private static String debug = "false";
  private static int reclvl = 0;

  public static void main(String args[]) {

    int arglen = args.length;
    if (arglen < 2) {
      System.out.println("Required parameter(s) missing.");
      System.out.println("usage: java rcvmail account password [mailserver] [timeout] " +
                         "[homedir] [leavemail] [replacehtmlcid] [rcvlogtype] [rcvlogfile] " +
                         "[rdbdire] [rdbuserid] [rdbpassword] [debug] [debugfile]");
      System.exit(1);
    }

    // check and set parameters
    String account = args[0]; // mail user account
    String password = args[1]; // password for the mail server
    String mailserver = "localhost"; // POP3 server
    String timeout = "30", timeout_ms = ""; // communication timeout
    String leavemail = "false"; // leave mail on server
    String replacehtmlcid = "true"; // Replace cid (Contents ID) in html file
    String rcvlogtype = "file"; // log type, local RDBE of OS/400 or tab-saparated file
    String rcvlogfile = "rcvmlog"; // receive mail log file
    String rdbdire = mailserver; // local RDBE
    String rdbuserid = account; // user ID for local RDBE
    String rdbpassword = password; // password for local RDBE
    String debugfile = "rcvmdebug.txt"; // Debug output file

    if ((arglen > 2) && (args[2].trim().length() > 0)) mailserver = args[2];
    if (arglen > 3) timeout = args[3];
    if ((arglen > 4) && (args[4].trim().length() > 0)) homedir = args[4];
    if ((arglen > 5) && (args[5].equals("true") || args[5].equals("false"))) leavemail = args[5];
    if ((arglen > 6) && (args[6].equals("true") || args[6].equals("false"))) replacehtmlcid = args[6];
    if ((arglen > 7) && (args[7].equals("none") || args[7].equals("file") || args[7].equals("rdb"))) rcvlogtype = args[7];
    if ((arglen > 8) && (args[8].trim().length() > 0)) rcvlogfile = args[8];
    if ((arglen > 9) && (args[9].trim().length() > 0)) rdbdire = args[9];
    if ((arglen > 10) && (args[10].trim().length() > 0)) rdbuserid = args[10];
    if ((arglen > 11) && (args[11].trim().length() > 0)) rdbpassword = args[11];
    if ((arglen > 12) && (args[12].equals("both") || args[12].equals("false") ||
                               args[12].equals("rcvmail") || args[12].equals("javamail"))) debug = args[12];
    if ((args.length > 13) && (args[13].trim().length() > 0)) debugfile = args[13];

    // Set debug output
    if (!debug.equalsIgnoreCase("false")) {
      try {
        PrintStream consoleout = new PrintStream(new FileOutputStream(debugfile, true));
        System.setOut(consoleout);
        System.setErr(consoleout);
      } catch (Exception e) {
        e.printStackTrace();
        System.out.println("Exception occured. " + e);
        System.exit(3);
      }
    }

    debugOut("");
    debugOut("......................................................");
    debugOut("  Rcvmail, yet another simple JavaMail POP3 client.");
    debugOut("    All rights reserved.  version 0.6 2003-05-11");
    debugOut("......................................................");

    debugOut("User [" + account + "], POP3 server [" + mailserver + "], timeout = [" + timeout + "], ");
    debugOut("  homedir = [" + homedir + "], leavemail = [" + leavemail + "], replacehtmlcid = [" + replacehtmlcid + "],");
    debugOut("  rcvlogtype = [" + rcvlogtype  + "], rcvlogfile = \"" + rcvlogfile + "\", ");
    debugOut("  rdbdire = [" + rdbdire + "], rdbuserid = [" + rdbuserid + "], ");
    debugOut("  debug = [" + debug + "], debugfile = \"" + debugfile + "\".");

    try {

      // set properties
      Properties prop = new Properties();

      // set timeout value in milliseconds. Default is infinite.
      timeout_ms = String.valueOf(Integer.valueOf(timeout).intValue() * 1000);
      prop.put("mail.pop3.connectiontimeout", timeout_ms); // socket connection timeout
      prop.put("mail.pop3.timeout", timeout_ms); // socket I/O timeout
      debugOut("Socket connection and I/O timeout set to " + Integer.valueOf(timeout).intValue() + " sec.");

      // set debug mode for Javamail
      if (debug.equalsIgnoreCase("both") || debug.equalsIgnoreCase("javamail")) {
        prop.put("mail.debug", "true");
        debugOut("JavaMail debug function activated.");
      }

      // connect to mail server
      Session session = Session.getDefaultInstance(prop, null);
      Store store = session.getStore("pop3");
      store.connect(mailserver, account, password);
      debugOut("Connected to POP3 server.");

      // open mail folder
      Folder folder = store.getFolder("INBOX");
      folder.open(Folder.READ_WRITE);
      debugOut("POP3 folder opened.");

      // cast the folder to POP3
      com.sun.mail.pop3.POP3Folder pop3f = (com.sun.mail.pop3.POP3Folder)folder;

      // check if mail exists
      if (folder.getMessageCount() == 0) {
        debugOut("No mail, exiting...");
        folder.close(false);
        store.close();
        debugOut("Connection closed.");
        System.exit(4);
      }

      // get message(s)
      Message[] messages = folder.getMessages();
      int msglen = messages.length;
      int skippedmail = 0;
      debugOut(msglen + " mail(s) waiting.");

      // setup mail receive log database or file
      PreparedStatement pstmt = null;
      Connection conn = null;
      File rcvmaillog = new File(rcvlogfile);
      OutputStreamWriter logosw = null;
      String logfempty = "false";

      if (rcvlogtype.equals("rdb")) {
        // establish JDBC connection to RDBDIRE on OS/400
        Class.forName("com.ibm.as400.access.AS400JDBCDriver");
        conn = DriverManager.getConnection("jdbc:as400://" + rdbdire, rdbuserid, rdbpassword);
        debugOut("Connected to database [" + rdbdire + "] to record mail receive log.");

        pstmt = conn.prepareStatement(
          "INSERT INTO " + rcvlogfile + " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
      }

      if (rcvlogtype.equals("file")) {
        // check if mail receive log file is empty
        debugOut("Check if mail log file \"" + rcvlogfile + "\" is empty or not.");
        if (rcvmaillog.length() == 0) {
          debugOut("Mail log file \"" + rcvlogfile + "\" is empty, will set UTF16-LE BOM.");
          logfempty = "true";
        }
        // setup mali receive log file (no buffering)
        logosw = new OutputStreamWriter(new FileOutputStream(rcvlogfile, true), "UTF-16LE");
        debugOut("Mail log file \"" + rcvlogfile + "\" opened.");
      }

      // Process each mail message
      Address[] sender, recipients;
      StringBuffer logsb = new StringBuffer();
      String fromaddr, toaddr, subject, sentdate, uid;
      int mailsize ;

      for (int i = 0; i < msglen; i++) {
        // initialize valiables
        sender = null; recipients = null; fromaddr = ""; toaddr = ""; subject = "";
        sentdate = ""; uid = ""; mailsize = 0; maildir = "";

        debugOut("Receiving mail " + (i + 1) + " of " + msglen +
                 " ******************************************");

        // retrieve only first sender
        sender = messages[i].getFrom();
        if (sender[0] != null) {
          fromaddr = MimeUtility.decodeText(sender[0].toString());
          debugOut("From : " + fromaddr);
        }

        // get recipients ("To" only)
        if ((recipients = messages[i].getRecipients(Message.RecipientType.TO)) != null) {
          debugOut("Number of recipients = " + recipients.length + ".");
          for (int j = 0; j < recipients.length; j++) {
            if (j != 0) toaddr = toaddr + ", ";
            toaddr = toaddr + MimeUtility.decodeText(recipients[j].toString());
          }
        }

        debugOut("To : " + toaddr);
        subject = messages[i].getSubject();
        debugOut("Subject : " + subject);
        Date date = messages[i].getSentDate();
        sentdate = (date != null ? date.toString() : "(unknown)");
        debugOut("Date : " + sentdate);
        mailsize = messages[i].getSize();
        debugOut("Size : " + mailsize);
        uid = pop3f.getUID(messages[i]);
        debugOut("UID : " + uid);

        // create directory to store message using UID
        maildir = homedir + "/" + pop3f.getUID(messages[i]) + "/";
        File path = new File(maildir);

        // check directory status
        if (!path.exists()) {
          if (path.mkdir()) {
            debugOut("Mail directory \"" + maildir + "\" created.");
          } else {
            debugOut("Cannot create mail directory \"" + maildir + "\".");
            System.exit(5);
          }
        } else {
          debugOut("Mail directory \"" + maildir + "\" already exists.");
          if (path.list().length == 0) {
            debugOut("Directory \"" + maildir + "\" is empty. Use this directory to store mail content.");
          } else {
            debugOut("Directory \"" + maildir + "\" already contains " + path.list().length + " file(s). Skip this mail.");
            skippedmail++;
            continue;
          }
        }

        // start save content
        Object content = messages[i].getContent();

        if (content instanceof Multipart) {
          processMultipart((Multipart)content);
        } else {
          savePart(messages[i]);
        }

        // write received mail information to database file
        if (rcvlogtype.equals("rdb")) {
          debugOut("Insert received mail information to database file \"" + rcvlogfile + "\" on OS/400");
          pstmt.setString(1, mailserver);
          pstmt.setString(2, account);
          pstmt.setString(3, new File(homedir).getCanonicalPath());
          pstmt.setString(4, leavemail);
          pstmt.setString(5, replacehtmlcid);
          pstmt.setString(6, debug);
          pstmt.setString(7, new File(debugfile).getCanonicalPath());
          pstmt.setString(8, fromaddr);
          pstmt.setString(9, toaddr);
          pstmt.setString(10, subject);
          pstmt.setString(11, sentdate);
          pstmt.setInt(12, mailsize);
          pstmt.setString(13, uid);
          pstmt.setTimestamp(14 , new Timestamp(new Date().getTime()));

          pstmt.executeUpdate();
          debugOut("SQL statement completed, record inserted successfully.");
        }
        // write received mail information to tab-saparated file
        if (rcvlogtype.equals("file")) {
          logsb.setLength(0);
          // set BOM (Byte Order Mark) of UTF-16LE (for Windows)
          if (logfempty == "true") {
            // Actual UTF-16LE starts from u+FFFE. Java UTF-16LE converter seems to reverse this sequence.
            debugOut("Log file is empty, set BOM for UTF-16LE.");
            logosw.write("\uFEFF");
            logfempty = "false";
          }
          logsb.append(mailserver).append("\t").append(account).append("\t");
          logsb.append(new File(homedir).getCanonicalPath()).append("\t");
          logsb.append(leavemail).append("\t").append(replacehtmlcid).append("\t");
          logsb.append(debug).append("\t").append(new File(debugfile).getCanonicalPath()).append("\t");
          logsb.append(fromaddr).append("\t").append(toaddr).append("\t").append(subject).append("\t");
          logsb.append(sentdate).append("\t").append(mailsize).append("\t").append(uid).append("\t");
          logsb.append(new Timestamp(new Date().getTime())).append("\r\n");
          logosw.write(logsb.toString());
          debugOut("Mail receive log added to file \"" + rcvlogfile + "\".");
        }

        // do not delete mail if "leavemail" specified as "true"
        if (leavemail.equalsIgnoreCase("false")) {
          messages[i].setFlag(Flags.Flag.DELETED, true);
          debugOut("This mail marked to be deleted.");
        } else {
          debugOut("This mail will be left on mail server.");
        }

        // replace cid in HTML file with local file name
        if (replacehtmlcid.equalsIgnoreCase("true")) {
          debugOut("");
          debugOut("Try to replace cid in HTML file with local file name, if any." +
                   " ++++++++++++++++++");
          replaceCID();
        }
      }  // end message processing loop

      // close mail receive log file
      if (rcvlogtype.equals("rdb")) {
        pstmt.close();
        conn.close();
        debugOut("Connection to mail receive log database closed.");
      }
      if (rcvlogtype.equals("file")) {
        logosw.close();
        debugOut("Mail receive log file closed.");
      }

      // close folder
      folder.close(true);
      store.close();
      debugOut("Connection closed.");
      debugOut("Mail " + (msglen - skippedmail) + "/" + msglen + " received.");
      if (skippedmail > 0) {
        System.exit(6);
      }

    } catch (Exception e) {
      e.printStackTrace();
      debugOut("Exception occured. : " + e);
      System.exit(7);
    }
  }

  // Redirect debug output
  public static void debugOut(String logmsg) {
    if (debug.equalsIgnoreCase("both") || debug.equalsIgnoreCase("rcvmail")) {
      System.out.println("[" + new Date() + "] " + logmsg);
    }
  }

  // Hnadle multipart message
  public static void processMultipart(Multipart mp) throws MessagingException, IOException {
    int count = mp.getCount();
    debugOut("Part count : " + count);

    for (int i = 0; i < count; i++) {
        debugOut("Processing part " + (i + 1) + " of " + count +
                 " ---------------------");
        savePart(mp.getBodyPart(i));
    }
  }

  // Determine content type
  public static String checkContentType(String type) {
    String extension = "";

    if ((type.length() >= 10) && type.substring(0, 10).equalsIgnoreCase("text/plain")) {
      extension = "txt";
    } else if ((type.length() >= 9) && type.substring(0, 9).equalsIgnoreCase("text/html")) {
      extension = "htm";
    } else if ((type.length() >= 9) && type.substring(0, 9).equalsIgnoreCase("image/gif")) {
      extension = "gif";
    } else if ((type.length() >= 10) && type.substring(0, 10).equalsIgnoreCase("image/jpeg")) {
      extension = "jpg";
    } else if ((type.length() >= 9) && type.substring(0, 9).equalsIgnoreCase("image/png")) {
      extension = "png";
    } else {
      extension = "out";
    }
    debugOut("Extension set to [" + extension + "].");
    return extension;
  }

  // Save individual part. If multipart, process recursively
  public static void savePart(Part part) throws MessagingException, IOException {
    String filename = part.getFileName();
    String disp = part.getDisposition();
    String type = part.getContentType();
    String contentID = ((MimePart)part).getContentID();

    if (contentID != null) {
      if (contentID.length() > 0) contentID = contentID.substring(1, contentID.length() - 1);
    }
    debugOut("Part information : Filename = \"" + filename + "\", Disposition = [" +
             disp + "], ContentType = [" + type + "], ContentID = [" + contentID + "].");

    if (disp == null) {
      if ((type.length() >= 10) && type.substring(0, 10).equalsIgnoreCase("multipart/")) {
        reclvl++;
        debugOut("This part contains multipart. Recursive parsing ===================== " + reclvl);
        processMultipart((Multipart)part.getContent());
        debugOut("Recursive parsing finished ========================================== " + reclvl);
        reclvl--;
        return;
      } else {
      if (filename == null) filename = "body." + checkContentType(type);
      if (contentID != null) filename = contentID + "-----" + filename;
      }
    } else if (disp.equalsIgnoreCase(Part.ATTACHMENT)) {
      // do nothing, assuming attachment file always has filename...
    } else if (disp.equalsIgnoreCase(Part.INLINE)) {
      if (filename == null) filename = "inline." + checkContentType(type);
      if (contentID != null) filename = contentID + "-----" + filename;
    }

    filename = MimeUtility.decodeText(maildir + filename);
    debugOut("Filename is \"" + filename + "\".");

    try {
      File file = new File(filename);

      // do not overwrite existing file
      while (file.exists()) {
        debugOut("File \"" + filename + "\" already exists.");
        int fnlen = filename.length();
        int pos = filename.lastIndexOf(".");
        if (pos != -1) {
          filename = filename.substring(0, pos) + "~" + "." +
                     filename.substring(pos + 1, fnlen);
        } else {
          filename = filename + "~";
        }
        file = new File(filename);
        debugOut("Duplicating file found, filename changed to \"" + filename + "\".");
      }

      // write part to file
      BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(file));
      BufferedInputStream bis = new BufferedInputStream(part.getInputStream());
      debugOut("Writing part to file \"" + filename + "\".");
      int c;
      while ((c = bis.read()) != -1) {
        bos.write(c);
      }
      bos.flush();
      bos.close();
      bis.close();
      debugOut("\"" + filename + "\" saved.");
    }
    catch (IOException e) {
      e.printStackTrace();
      debugOut("Failed to save file. : " + e);
      System.exit(8);
    }
  }

  // Replace CID to link to image files
  public static void replaceCID() throws IOException {
    String htmlfile = "body.htm";
    String tmpfile = "temp";
    String readline = "";
    boolean replaced = false;

    try {
      htmlfile = maildir + htmlfile;
      tmpfile = maildir + tmpfile;
      File infile = new File(htmlfile);
      File outfile = new File(tmpfile);

      // get file list in mail directory
      File dir = new File(maildir);
      String filelist[] = dir.list();

      // open HTML file for input and temp file for output
      while (infile.exists()) {
        debugOut("Replacing cid in file \"" + htmlfile + "\".");
        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(infile)));
        BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(outfile)));


        // read html file and match cid with filelist
        while ((readline = br.readLine()) != null) {
          int spos = readline.indexOf("\"cid:");
          if (spos != -1) {
            int epos = readline.indexOf("\"", spos + 5);
            String cid = readline.substring(spos + 5, epos);
            debugOut("cid \"" + cid + "\" found.");

            // if file exists, rename the file and replace the cid with the file name
            for (int i = 0; i < filelist.length; i++) {
              if (cid.length() > (filelist[i]).length()) {
              } else if (!cid.equals((filelist[i]).substring(0, cid.length()))) {
              } else {
                debugOut("Corresponding cid file found.");
                readline = readline.substring(0, spos + 1) + filelist[i] + readline.substring(epos);
                debugOut("cid changed to link to image file [" + readline + "].");
                replaced = true;
                break;
              }
            }
          }
          bw.write(readline + "\n");
        }
        bw.close();
        br.close();

        if (replaced == true) {
          infile.delete();
          debugOut("File \"" + htmlfile + "\" deleted.");
          File newfile = new File(htmlfile);
          outfile.renameTo(newfile);
          debugOut("File \"" + tmpfile + "\" renamed to \"" + htmlfile + "\".");
          replaced = false;
        } else {
          outfile.delete();
          debugOut("File \"" + tmpfile + "\" deleted.");
        }

        // look for next html file
        int fnlen = htmlfile.length();
        int pos = htmlfile.lastIndexOf(".");
        htmlfile = htmlfile.substring(0, pos) + "~" + "." +
                   htmlfile.substring(pos + 1, fnlen);
        infile = new File(htmlfile);
        outfile = new File(tmpfile);
      }
    }
    catch (IOException e) {
      e.printStackTrace();
      debugOut("Failed to replace CID of HTML file. : " + e);
      System.exit(9);
    }
  }

}

