Option Explicit

Dim ftpHost, ftpUser, ftpPass As String
Dim ftpClCmd, ftpCmdLibl As String
Dim rtvType As String
Dim splFileName, splJobName, splUserName, splJobNo, splFileNo As String
Dim dftPath, getFilePath, getFileName, ftpScriptPath, ftpBatchPath, ftpGetFilePath As String
Const dq As String = """"
Dim ThisBook As Workbook
Dim ThisSheet As Worksheet
Dim ftpSuccess As Boolean

' Main routine

Sub main()

    ' Get access information from Excel sheet
    ftpHost = Range("C5").Value
    ftpUser = UCase(Range("C6").Value)
    ftpPass = UCase(Range("C7").Value)
    
    ' Type of data
    rtvType = UCase(Range("C10").Value)

    ' Run command and get spool file
    ftpClCmd = UCase(Range("C13").Value)
    ftpCmdLibl = UCase(Range("C14").Value)

    ' Get existing spool file
    splFileName = UCase(Range("C17").Value)
    splJobName = UCase(Range("C18").Value)
    splUserName = UCase(Range("C19").Value)
    splJobNo = Format("000000", Range("C20").Value)
    splFileNo = UCase(Range("C21").Value)

    ' Set path (file name) to related files
    dftPath = ThisWorkbook.Path
    getFileName = Range("C24").Value
    getFilePath = dftPath & "\" & getFileName
    ftpScriptPath = dftPath & "\ftpScript.txt"
    ftpBatchPath = dftPath & "\ftpBatch.bat"
    
    ' Run subprocedures
    genFtpScript
    runBatchFtp
    
    If ftpSuccess Then
        readTxt
        MsgBox "データの取得が完了しました。" & vbCrLf & _
        "再度実行する場合は作成されたExcelを閉じてください。", vbInformation
    Else
        MsgBox "取得されたデータはありません。", vbExclamation
    End If

End Sub

' Create ftp Script from values in Excel sheet

Sub genFtpScript()

    Dim fNo As Integer
    Dim dt As Date
    Dim hhnnss As String
    
    fNo = FreeFile
    Open ftpScriptPath For Output As #fNo
    ftpGetFilePath = getFilePath & ".txt"

    ' Open FTP connection
    ' FTP Host (Host name or IP Address)
    Print #fNo, "open " & ftpHost
    ' User ID and Password
    Print #fNo, "user " & ftpUser & " " & ftpPass
    ' Space for readability
    Print #fNo, ""
    
    ' Run command
    If rtvType = "A" Then
        ' Set user portion of library list respectively
        Print #fNo, "quote rcmd CHGLIBL LIBL(" & ftpCmdLibl & ")"
        ' Exec CL command which creates spool file
        Print #fNo, "quote rcmd " & ftpClCmd
        Print #fNo, ""
    End If
    
    ' Restore programs from SAVF
    ' CRTSAVF FILE(QTEMP/SAVF)
    Print #fNo, "quote rcmd CRTSAVF FILE(QTEMP/SAVF)"
    ' Put SAVF
    Print #fNo, "bi"
    Print #fNo, "put " & dq & dftPath & "\pgms.savf" & dq & " QTEMP/SAVF"
    ' Space for readability
    Print #fNo, vbCrLf
    Print #fNo, "quote rcmd RSTOBJ OBJ(*ALL) SAVLIB(QTEMP) DEV(*SAVF) " & _
                "MBROPT(*ALL) OBJTYPE(*PGM) SAVF(QTEMP/SAVF) ALWOBJDIF(*ALL) RSTLIB(QTEMP)"
    
    Select Case rtvType
        Case "A"
            ' Run program to exec CPYSPLF and adjust Shift-code at a time
            Print #fNo, "quote rcmd CALL PGM(QTEMP/SPL2TXT)"
            Print #fNo, ""
        Case "B"
            Print #fNo, "quote rcmd CRTPF FILE(QTEMP/SPLF) RCDLEN(400) IGCDTA(*YES) "
            Print #fNo, "quote rcmd CPYSPLF FILE(" & splFileName & ") TOFILE(QTEMP/SPLF) " & _
                "JOB(" & splJobNo & "/" & splUserName & "/" & splJobName & ") SPLNBR(" & splFileNo & ")"
            Print #fNo, "quote rcmd OVRDBF FILE(SPLF) TOFILE(QTEMP/SPLF)"
            Print #fNo, "quote rcmd CALL PGM(QTEMP/SHIFT)"
            Print #fNo, "quote rcmd DLTOVR FILE(SPLF)"
            Print #fNo, ""
    End Select
            
    ' Set Receiving ASCII to SJIS (CCSID-943)
    Print #fNo, "quote type C 943"
    ' Get file
    Print #fNo, "get QTEMP/SPLF " & dq & ftpGetFilePath & dq
    Print #fNo, vbCrLf
    ' For debug on IBM i side
    ' Print #fNo, "quote rcmd DSPJOBLOG OUTPUT(*PRINT)"
    
    ' Quit FTP
    Print #fNo, vbCrLf
    Print #fNo, "quit"

    Close #fNo

End Sub

' Create batch file and run

Sub runBatchFtp()
    
    Dim fNo As Integer
    Dim Wsh, strCmd, execCmd, resCmd As String
    Dim FSO As Object

    ' Create batch file to run ftp
    fNo = FreeFile

    Open ftpBatchPath For Output As #fNo
    Print #fNo, "ftp -n -v -s:" & dq & ftpScriptPath & dq
    Print #fNo, "exit"

    Close #fNo

    ' Run ftp.exe
    Set Wsh = CreateObject("WScript.Shell")
    strCmd = dq & ftpBatchPath & dq & " > " & dq & dftPath & "\ftpBatch.log" & dq

    Set execCmd = Wsh.Exec(strCmd)

    ' Wait for the batch to end
    Do Until execCmd.StdOut.AtEndOfStream
        resCmd = resCmd & execCmd.StdOut.ReadLine & vbCrLf
    Loop

    Set execCmd = Nothing
    Set Wsh = Nothing
    
    ' Delete ftp script and batch files
    Set FSO = CreateObject("Scripting.FileSystemObject")
    If Range("C27").Value = "" Then
        FSO.Deletefile ftpScriptPath, True
        FSO.Deletefile ftpBatchPath, True
        FSO.Deletefile dftPath & "\ftpBatch.log", True
    End If

    ' Check if transferred file exists
    If FSO.FileExists(ftpGetFilePath) Then
        ftpSuccess = True
    Else
        ftpSuccess = False
    End If

End Sub

' Read data in plain text file into new worksheet

Sub readTxt()

    Dim i As Long
    Dim FSO, TS As Object
    Dim textRecord As String
    
    Set ThisBook = Workbooks.Add
    
    ' Add new worksheet
    With ThisBook
        Set ThisSheet = .Worksheets.Add(after:=.Sheets(.Sheets.Count))
    End With
        
    ' Delete unused worksheets
    Application.DisplayAlerts = False
    For i = 1 To Application.SheetsInNewWorkbook
        ThisBook.Sheets(1).Delete
    Next
    Application.DisplayAlerts = True
    
    ' Set format of data to insert
    ThisSheet.Range("A:A").NumberFormat = "@"
    
    ' Open file
    Set FSO = CreateObject("Scripting.FileSystemObject")
    Set TS = FSO.GetFile(ftpGetFilePath).OpenAsTextStream(1, -2)
        
    ' Read record and write to workseet
    i = 0
    Do Until TS.AtEndOfStream
        textRecord = TS.ReadLine
        ThisSheet.Cells(i + 1, 1).Value = textRecord
        i = i + 1
    Loop
        
    If i = 0 Then
        Application.DisplayAlerts = False
        ThisBook.Close
        Application.DisplayAlerts = True
        MsgBox "取得されたデータはありません。", vbCritical
        ' End this program immediately
        End
    End If
        
    TS.Close
    Set TS = Nothing
    Set FSO = Nothing
       
    ' Assign name to worksheet
    ThisSheet.Name = Left(getFileName, 31)
        
    ' Set font
    With ThisSheet
        .Range("A1:A" & i).RowHeight = 9
        .Range("A1:A" & i).Font.Size = 9
        .Range("A1:A" & i).Font.Name = "ＭＳ ゴシック"
    End With
        
    ' Set appearance
    With ThisSheet.PageSetup
        .PrintArea = "$A$1:$M$" & i
        .Zoom = False
        .FitToPagesTall = False
        .FitToPagesWide = 1
    End With
        
    ActiveWindow.View = xlPageBreakPreview
    ActiveWindow.Zoom = 90
    
    ' Overwrite existing file without alert
    Application.DisplayAlerts = False
    ActiveWorkbook.SaveAs Filename:=getFilePath & ".xlsx"
    Application.DisplayAlerts = True
    
    ThisBook.Activate
        
End Sub
