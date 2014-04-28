#include <Array.au3>
#include <File.au3>
#include <Misc.au3>

#include "encode.au3"

Opt("MustDeclareVars", 1)

Local $aArray = 0, $row
Local $tableFile = "e:\carimbar\tp.txt"

Local $stampsPath = $tableFile & "\..\Carimbos\"

_FileReadToArray($tableFile, $aArray, 0)

Local $files = _FileListToArray($tableFile & "\..", "*.pdf", 1, true)

Local $processoRegexp = "[0-9]{0,7}-[0-9]{1,2}[-.][0-9]{4}[-.][0-9][-.][0-9]{2}[-.][0-9]{4}"
Local $barcode, $matches

DirCreate($tableFile & "\..\Carimbados\")

For $i = 1 To UBound($files)-1

   $matches = StringRegExp($files[$i], $processoRegexp, 1)

   If UBound($matches) < 1 Then
	  ContinueLoop
   EndIf

   $row = findRow($aArray, $matches[0])

   If $row < 0 Then
	  ContinueLoop
   EndIf

   $barcode = StringRegExpReplace($matches[0], "[^0-9]", "")
   $barcode = StringFormat("%020s", $barcode)

   $row = StringSplit($row, Chr(9))

   stamp($files[$i], $barcode, $row)

Next

Func findRow($aTable, $id)

   Local $index = _ArraySearch($aTable, "^" & $id, 0, 0, 0, 3)

   return $index > -1 ? $aTable[$index] : -1

EndFunc

Func stamp($filename, $barcode, $opts)

   Local $pdDoc = ObjCreate("AcroExch.PDDoc")
   Local $formDoc, $jsObj, $jsFormObj, $stamp, $tempBarcode, $formData

   If IsObj($pdDoc) Then

	  $pdDoc.Open($filename)

	  $jsObj = $pdDoc.GetJSObject()

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

	  $pdDoc.Save(1, $filename & "\..\carimbados\" & $row[1] & ".pdf")

	  $pdDoc.Close()

	  ConsoleWrite($row[1] & @LF)

	  ;ShellExecuteWait(_PathFull($filename & "\..\carimbados\" & $row[1] & ".pdf"), "", "", "print")

	  ;Sleep(2)


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

Func toAcroPath($path)
   return "/" & StringReplace(StringReplace($path, ":", ""), "\", "/")
EndFunc