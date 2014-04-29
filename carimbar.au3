#Region
#AutoIt3Wrapper_Outfile=D:\GMJD\Carimbador.exe
#AutoIt3Wrapper_Res_Fileversion=0.0.0.11
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Icon=icons\stamp.ico
#EndRegion

#include <Array.au3>
#include <File.au3>
#include <Misc.au3>

#include "encode.au3"

Opt("MustDeclareVars", 1)

Local $aArray = 0, $row

Local $tableFile
If UBound($CmdLine) > 1 And FileExists($CmdLine[1]) Then
	$tableFile = $CmdLine[1]
Else
	$tableFile = FileOpenDialog("Lista de processos", "c:\", "Guias de Carimbo (*.prc)|Arquivos de texto (*.txt)")
EndIf

Local $stampsPath = $tableFile & "\..\Carimbos\"

While Not FileExists($stampsPath)
	If MsgBox(5, "Erro", "Pasta de carimbos não encontrada") == 2 Then
		Exit
	EndIf
WEnd

_FileReadToArray($tableFile, $aArray, 0)

ConsoleWrite((UBound($tableFile))&@LF)

Local $files = _FileListToArray($tableFile & "\..", "*.pdf", 1, true)

Local $processoRegexp = "[0-9]{0,7}-[0-9]{1,2}[-.][0-9]{4}[-.][0-9][-.][0-9]{2}[-.][0-9]{4}"
Local $barcode, $matches, $index

DirCreate($tableFile & "\..\Carimbados\")

ProgressOn("Carimbar Documentos", "Carimbando ...", "Aguarde...")

For $i = 1 To UBound($files)-1

	ProgressSet(100*$i/(UBound($files)-1), "Carimbando " & $i & " de " & (UBound($files)-1))

	$matches = StringRegExp($files[$i], $processoRegexp, 1)

	If UBound($matches) < 1 Then
		ContinueLoop
	EndIf

	$index = findRow($aArray, $matches[0])
	$row = $aArray[$index]

	If $row < 0 Then
		ContinueLoop
	EndIf

	$barcode = StringRegExpReplace($matches[0], "[^0-9]", "")
	$barcode = StringFormat("%020s", $barcode)

	$row = StringSplit($row, Chr(9))

	stamp($files[$i], $barcode, $row, StringFormat("%03s", $index))

Next

ProgressSet(100, "Concluido")
Sleep(2000)
ProgressOff()

Func findRow($aTable, $id)

   Local $index = _ArraySearch($aTable, "^" & $id, 0, 0, 0, 3)

   return $index

EndFunc

Func stamp($filename, $barcode, $opts, $index)

   Local $pdDoc = ObjCreate("AcroExch.PDDoc")
   Local $formDoc, $jsObj, $jsFormObj, $stamp, $tempBarcode, $formData

   If IsObj($pdDoc) Then

	  $pdDoc.Open($filename)

	  $jsObj = $pdDoc.GetJSObject()

	  $jsObj.addWatermarkFromFile($stampsPath & "TIMBRE.pdf", 0, 0)

	  $stamp = $stampsPath & $opts[2] & ".pdf"
	  If FileExists($stamp) Then
		 $jsObj.addWatermarkFromFile($stamp, 0, 0)
	  EndIf

	  $stamp = $stampsPath & $opts[3] & ".pdf"
	  If FileExists($stamp) Then
		 $jsObj.addWatermarkFromFile($stamp, 0, 0)
	  EndIf

	  stampForm($jsObj, $stampsPath & "BARCODE.pdf", "barcode", spartanEncode128C($barcode))

	  If UBound($row) > 4 And $row[4] <> "" Then
		 $formData = "* " & StringRegExpReplace($row[4], ";\s*", Chr(10) & "* ")
		 stampForm($jsObj, $stampsPath & "AM.pdf", "AM", $formData)
	  EndIf

	  $pdDoc.Save(1, $filename & "\..\carimbados\" & $index & "_" & $row[1] & ".pdf")

	  $pdDoc.Close()

   EndIf

EndFunc

Func stampForm($jsObj, $fileForm, $field, $data)

   Local $tempBarcode = _TempFile("%TEMP%", "~", ".pdf")

   Local $formDoc = ObjCreate("AcroExch.PDDoc")
   $formDoc.Open($fileForm)

   Local $jsFormObj = $formDoc.GetJSObject()
   $jsFormObj.getField($field).Value = $data
   $jsFormObj.flattenPages()

   $formDoc.Save(1, $tempBarcode)
   $formDoc.Close()

   $jsObj.addWatermarkFromFile($tempBarcode, 0, 0)
   FileDelete($tempBarcode)

EndFunc

