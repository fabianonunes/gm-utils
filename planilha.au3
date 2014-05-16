
#include <Array.au3>
#include <File.au3>
#include <Misc.au3>


checker("e:\tp")
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
		Local $current = ""
		Local $trt = ""

		Do

			Local $numero = ControlGetText($hWnd, "", $sControl)

			If _ArraySearch($aArray, "^"&$numero, 0, 0, 0, 3) == -1 Then
				Send("{DOWN}")
				ContinueLoop
			EndIf

			Send("{TAB}")

			Local $digito = ControlGetText($hWnd, "", $sControl)
			Send("{TAB}")

			Local $ano = ControlGetText($hWnd, "", $sControl)
			Send("{TAB}")

			Local $justica = ControlGetText($hWnd, "", $sControl)
			Send("{TAB}")

			If StringLen($justica) == 2 Then
				$trt = $justica
				$justica = "5"
			Else
				$trt = ControlGetText($hWnd, "", $sControl)
				Send("{TAB}")
			EndIf

			Local $vara = ControlGetText($hWnd, "", $sControl)

			$current = $numero & "-" & $digito & "." & $ano & "." & $justica & "." & $trt & "." & $vara

			ConsoleWrite($current & @LF)

			If StringRegExp($current, $processoRegexp, 1) == 0 Then
				ExitLoop
			EndIf

			ConsoleWrite($current & @LF)

			If _ArraySearch($aArray, $current) > -1 Then
				Send("{TAB}{TAB}{TAB}{TAB}{TAB}")
				Send("{SPACE}")
				; - vai e volta
				Send("{DOWN}")
				Send("^{PGDN}")
				Sleep(100)
				Send("^{PGDN}")
				Sleep(100)
			Else
				Send("{DOWN}")
				Send("+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}")
				Sleep(20)
			EndIf


		Until False

	Else

		MsgBox(0, "Nenhum processo na lista", "Nenhum processo na lista")

	EndIf

EndFunc
