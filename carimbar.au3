
#include <Array.au3>
#include <File.au3>
#include <Misc.au3>
#include "encode.au3"

Local $stampsPath

Func carimbar($argFile = "")

	Local $aArray = 0, $row

	Local $tableFile
	If FileExists($argFile) Then
		$tableFile = $argFile
	Else
		$tableFile = FileOpenDialog("Lista de processos", "c:\", "Guias de Carimbo (*.prc)|Arquivos de texto (*.txt)|Todos os arquivos (*.*)")
	EndIf

	$stampsPath = $tableFile & "\..\Carimbos\"

	While Not FileExists($stampsPath)
		If MsgBox(5, "Erro", "Pasta de carimbos não encontrada") == 2 Then
			Exit
		EndIf
	WEnd

	_FileReadToArray($tableFile, $aArray, 0)

	Local $files = _FileListToArray($tableFile & "\..\Votos\", "*.pdf", 1, true)

	Local $processoRegexp = "[0-9]{0,7}-[0-9]{1,2}[-.][0-9]{4}[-.][0-9][-.][0-9]{2}[-.][0-9]{4}"
	Local $barcode, $matches, $index, $i

	DirCreate($tableFile & "\..\Carimbados\")

	ProgressOn("Carimbar Documentos", "Carimbando ...", "Aguarde...")

	For $i = 1 To UBound($files)-1

		ProgressSet(100*$i/(UBound($files)-1), "Carimbando " & $i & " de " & (UBound($files)-1))

		$matches = StringRegExp($files[$i], $processoRegexp, 1)

		If UBound($matches) < 1 Then
			ContinueLoop
		EndIf

		ConsoleWrite($matches[0]&@LF)

		$index = findRow($aArray, $matches[0])

		If $index < 0 Then
			ContinueLoop
		EndIf

		$row = $aArray[$index]

		$barcode = StringRegExpReplace($matches[0], "[^0-9]", "")
		$barcode = StringFormat("%020s", $barcode)

		$row = StringSplit($row, Chr(9))

		stamp($files[$i], $barcode, $row, StringFormat("%03s", $index + 1))

	Next

	ProgressSet(100, "Concluido")
	Sleep(2000)
	ProgressOff()

EndFunc

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

	  $jsObj.addWatermarkFromFile($stampsPath & "TIMBRE.pdf")

	  $stamp = $stampsPath & $opts[2] & ".pdf"
	  If FileExists($stamp) Then
		 $jsObj.addWatermarkFromFile($stamp, 0, 0)
	  EndIf

	  $stamp = $stampsPath & $opts[3] & ".pdf"
	  If FileExists($stamp) Then
		 $jsObj.addWatermarkFromFile($stamp, 0, 0)
	  EndIf

	  stampForm($jsObj, $stampsPath & "BARCODE.pdf", "barcode", spartanEncode128C($barcode))

	  If UBound($opts) > 4 And $opts[4] <> "" Then
		 $formData = "* " & StringRegExpReplace($opts[4], ";\s*", Chr(10) & "* ")
		 stampForm($jsObj, $stampsPath & "AM.pdf", "AM", $formData)
	  EndIf

	  $pdDoc.Save(1, $filename & "\..\..\Carimbados\" & $index & "_" & $opts[1] & ".pdf")

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

