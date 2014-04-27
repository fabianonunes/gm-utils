#include <Array.au3>
#include <File.au3>
#include <Misc.au3>

#include "encode.au3"

Opt("MustDeclareVars", 1)

Local $aArray = 0, $row

_FileReadToArray("e:\carimbar\tp.txt", $aArray, 0)

Local $files = _FileListToArray("E:\carimbar\tp.txt\..", "*.pdf", 1, true)

For $i = 1 To UBound($files)-1

   $row = findRow($aArray, $files[$i])

   If $row < 0 Then
	  ContinueLoop
   EndIf

   $row = StringSplit($row, Chr(9))

   _ArrayDisplay($row)

Next

Func findRow($aTable, $id)

   Local $processoRegexp = "[0-9]{0,7}-[0-9]{1,2}[-.][0-9]{4}[-.][0-9][-.][0-9]{2}[-.][0-9]{4}"
   Local $index, $matches

   $matches = StringRegExp($id, $processoRegexp, 1)

   If UBound($matches) > 0 Then
	  $id = $matches[0]
      $index = _ArraySearch($aTable, "^" & $id, 0, 0, 0, 3)
	  If $index > -1 Then
		 return $aTable[$index]
	  EndIf
   Else
	  return -1
   EndIf

EndFunc
