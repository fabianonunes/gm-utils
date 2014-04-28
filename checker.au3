#Region
#AutoIt3Wrapper_Outfile=D:\Checker.exe
#AutoIt3Wrapper_Res_Fileversion=0.0.0.8
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Icon=icons\checker.ico
#EndRegion

#include <Array.au3>
#include <File.au3>
#include <Misc.au3>

Opt("SendKeyDelay", 30)

Local $fileText
If UBound($CmdLine) > 1 And FileExists($CmdLine[1]) Then
	$fileText = $CmdLine[1]
Else
	$fileText = FileOpenDialog("Lista de processos", "c:\", "Text files (*.txt)")
EndIf

Local $processoRegexp = "[0-9]{0,7}-[0-9]{1,2}[-.][0-9]{4}[-.][0-9][-.][0-9]{2}[-.][0-9]{4}"

Local $aArray = StringRegExp(FileRead($fileText), $processoRegexp, 3)

Local $title = "Sistema de Apoio a Gabinetes -"
Local $editor = ""; "Consultar minutas assinadas ou devolvidas para o Gabinete - GBMNTRAM"
Local $focused


If UBound($aArray) > 0 Then

	Local $hWnd = WinActivate($title, $editor)
	Local $sControl = ControlGetFocus($hWnd)
	Local $previous = ""

	Do

		$previous = ControlGetText($hWnd, "", $sControl)

		If _ArraySearch($aArray, $previous) > -1 Then
			Send("{TAB}{TAB}")
			Opt("SendKeyDelay", 150)
			Send("{SPACE}{TAB}{DOWN}")
			Opt("SendKeyDelay", 30)
		Else
			Send("{DOWN}")
		EndIf

	Until $previous == ControlGetText($hWnd, "", $sControl)

Else

	MsgBox(0, "Nenhum processo na lista", "Nenhum processo na lista")

EndIf
