
#include <Array.au3>
#include <File.au3>
#include <Misc.au3>

Func checker($argFile = "")

	Opt("SendKeyDelay", 10)

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
		Local $sControl = ControlGetFocus($hWnd)
		Local $previous = ""
		Local $current = ""

		Do

			$current = ControlGetText($hWnd, "", $sControl)

			ConsoleWrite($current & " - " & $previous & @LF)

			If $previous == $current Then

				Send("{DOWN}")
				$current = ControlGetText($hWnd, "", $sControl)

				If $previous == $current Then
					ExitLoop
				EndIf

			EndIf

			If _ArraySearch($aArray, $current) > -1 Then
				Send("{TAB}")
				Send("{TAB}")
				Send("{SPACE}")
				Send("{TAB}")
			EndIf

			Send("{DOWN}")

			$previous = $current

		Until False

	Else

		MsgBox(0, "Nenhum processo na lista", "Nenhum processo na lista")

	EndIf

EndFunc