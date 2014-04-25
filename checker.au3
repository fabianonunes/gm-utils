﻿#Region
#AutoIt3Wrapper_Outfile=D:\Checker
#AutoIt3Wrapper_Res_Fileversion=0.0.0.2
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Icon=editor.ico
#EndRegion

#include <Array.au3>
#include <File.au3>
#include <Misc.au3>

Opt("SendKeyDelay", 30)

Local $fileText = FileOpenDialog("Lista de processos", "c:\", "Text files (*.txt)")

Local $processoRegexp = "[0-9]{0,7}-[0-9]{1,2}[-.][0-9]{4}[-.][0-9][-.][0-9]{2}[-.][0-9]{4}"

Local $aArray = StringRegExp(FileRead($fileText), $processoRegexp, 3)

Local $title = "Sistema de Apoio a Gabinetes -"
Local $editor = "Consultar minutas assinadas ou devolvidas para o Gabinete - GBMNTRAM"
Local $focused


If UBound($aArray) > 0 Then

	Local $hWnd = WinActivate($title, $editor)
	Local $sControl = ControlGetFocus($hWnd)
	Local $previous = ""

	Do

		$previous = ControlGetText($hWnd, "", $sControl)

		If _ArraySearch($aArray, $previous) > -1 Then
			Opt("SendKeyDelay", 150)
			Send("{TAB}{TAB}{SPACE}{TAB}{DOWN}")
			Opt("SendKeyDelay", 30)
		Else
			Send("{DOWN}")
		EndIf

	Until $previous == ControlGetText($hWnd, "", $sControl)

Else

	MsgBox(0, "Nenhum processo na lista", "Nenhum processo na lista")

EndIf