
#include <Array.au3>
#include <File.au3>
#include <Misc.au3>
#include "helpers.au3"

Func planilhar($argFile = "")

	Opt("SendKeyDelay", 20)

	Local $fileText

	If FileExists($argFile) Then
		$fileText = $argFile
	Else
		$fileText = FileOpenDialog("Lista de processos", "c:\", "Arquivos de Texto (*.txt)|Todos os arquivos (*.*)")
	EndIf

	Local $processoRegexp = "[0-9]{0,7}-[0-9]{1,2}[-.][0-9]{4}[-.][0-9][-.][0-9]{2}[-.][0-9]{4}"

	Local $aArray = StringRegExp(FileRead($fileText), $processoRegexp, 3)

	Local $title = "Sistema de Apoio a Gabinetes -"
	Local $editor = ""; "Consultar minutas assinadas ou devolvidas para o Gabinete - GBMNTRAM"
	Local $focused

	If UBound($aArray) > 0 Then

		Local $hWnd = WinActivate($title, $editor)

		Local $current = ""
		Local $trt = ""

		Do

			Local $numero = _getSelectedText($hWnd)

			If Number($numero) == 0 Then
				ExitLoop
			EndIf

			If _ArraySearch($aArray, "^"&$numero, 0, 0, 0, 3) == -1 Then
				Send("{DOWN}")
				ContinueLoop
			EndIf

			Send("{TAB}")

			Local $digito = _getSelectedText($hWnd)
			Send("{TAB}")

			Local $ano = _getSelectedText($hWnd)
			Send("{TAB}")

			Local $justica = _getSelectedText($hWnd)
			Send("{TAB}")

			If StringLen($justica) == 2 Then
				$trt = $justica
				$justica = "5"
			Else
				$trt = _getSelectedText($hWnd)
				Send("{TAB}")
			EndIf

			Local $vara = _getSelectedText($hWnd)

			$current = $numero & "-" & $digito & "." & $ano & "." & $justica & "." & $trt & "." & $vara


			If StringRegExp($current, $processoRegexp, 1) == 0 Then
				ExitLoop
			EndIf

			If _ArraySearch($aArray, $current) > -1 Then
				Send("{TAB}{TAB}{TAB}{TAB}{TAB}")
				Send("{SPACE}")
				; - vai e volta
				Send("{DOWN}")
				Send("^{PGDN}")
				Sleep(50)
				Send("^{PGDN}")
				Sleep(200)
			Else
				Send("{DOWN}")
				Send("+{TAB}+{TAB}")
				Send("+{TAB}+{TAB}")
				Sleep(20)
			EndIf


		Until False

	Else

		MsgBox(0, "Nenhum processo na lista", "Nenhum processo na lista")

	EndIf


EndFunc
