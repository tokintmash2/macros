Sub RunMacroOnAllFilesInFolder()
    Dim FolderPath As String
    Dim FileName As String
    Dim wdDoc As Document
    Dim dlg As FileDialog

    ' Prompt user to select folder
    Set dlg = Application.FileDialog(msoFileDialogFolderPicker)
    If dlg.Show = -1 Then
        FolderPath = dlg.SelectedItems(1) & "\"
    Else
        MsgBox "No folder selected. Exiting..."
        Exit Sub
    End If

    ' Loop through all Word documents in the folder
    FileName = Dir(FolderPath & "*.docx")
    Do While FileName <> ""
        Set wdDoc = Documents.Open(FolderPath & FileName)
        
        ' Call your macro here
        Call FormatModerateSetTables()
        
        wdDoc.Save
        wdDoc.Close
        FileName = Dir
    Loop
End Sub

' Ask for first page
' Set tables to autofit window

Sub FormatModerateSetTables()
    Dim sec As Section
    Dim shp As Shape
    Dim i As Integer
    Dim rng As Range
    Dim enableDifferentFirstPage As VbMsgBoxResult
    Dim tbl As Table
    Dim cell As Cell

    ' Prompt the user to ask if they want different first page headers and footers
    enableDifferentFirstPage = MsgBox("Different first page?", vbYesNo + vbQuestion, "Header/Footer Option")

    ' Un-frame all framed objects
    For Each shp In ActiveDocument.Shapes
        If shp.Type = msoTextBox Then
            shp.ConvertToInlineShape
        End If
    Next shp

    ' Un-frame text frames
    For i = ActiveDocument.Frames.Count To 1 Step -1
        With ActiveDocument.Frames(i)
            .Range.ParagraphFormat.Borders(wdBorderLeft).LineStyle = wdLineStyleNone
            .Range.ParagraphFormat.Borders(wdBorderRight).LineStyle = wdLineStyleNone
            .Range.ParagraphFormat.Borders(wdBorderTop).LineStyle = wdLineStyleNone
            .Range.ParagraphFormat.Borders(wdBorderBottom).LineStyle = wdLineStyleNone
            .Delete
        End With
    Next i

    ' Set margins
    With ActiveDocument.PageSetup
        .TopMargin = CentimetersToPoints(2.54)
        .BottomMargin = CentimetersToPoints(2.54)
        .LeftMargin = CentimetersToPoints(1.9)
        .RightMargin = CentimetersToPoints(1.9)
    End With

    ' Remove all section breaks
    Set rng = ActiveDocument.Content
    With rng.Find
        .Text = "^b"
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindContinue
        .Execute Replace:=wdReplaceAll
    End With

    ' Ensure there's only one section in the document
    Set sec = ActiveDocument.Sections(1)

    ' Set page setup for the single section
    With sec.PageSetup
        ' Set orientation
        .Orientation = wdOrientPortrait
        
        ' Set paper size
        .PaperSize = wdPaperA4

        ' Set header and footer distance
        .HeaderDistance = CentimetersToPoints(1.27)  ' 0.5 inch
        .FooterDistance = CentimetersToPoints(1.27)  ' 0.5 inch
        
        ' Set Different First Page Header/Footer based on user input
        If enableDifferentFirstPage = vbYes Then
            .DifferentFirstPageHeaderFooter = True
        Else
            .DifferentFirstPageHeaderFooter = False
        End If
    End With
    
    ' Set default font
    With ActiveDocument.Styles(wdStyleNormal).Font
        .Name = "Arial"
        .Size = 12
    End With
    
    ' Format all tables
    For Each tbl In ActiveDocument.Tables
        tbl.AutoFitBehavior wdAutoFitWindow
        For Each cell In tbl.Range.Cells
            cell.VerticalAlignment = wdCellAlignVerticalTop
        Next cell
    Next tbl
End Sub

