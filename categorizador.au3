
#include <Array.au3>
#include <File.au3>
#include <Misc.au3>
#include "helpers.au3"

Local $title = "Sistema de Apoio a Gabinetes -"
Local $editor = ""; "Consultar minutas assinadas ou devolvidas para o Gabinete - GBMNTRAM"

Local $window = WinActivate($title)

Local $control = ControlGetFocus($window)

ConsoleWrite(ControlGetText($window, "", $control) & @LF)
ConsoleWrite(" = = = = = " & @LF)

Opt("SendKeyDelay", 50)

While WinActive($window)

	Send("{ENTER}")

	WinWaitActive($title, "Editor do eRecurso - GBeRecur")

	Send("{TAB}{TAB}{TAB}{TAB}{TAB}")
	Send("{ENTER}")
	Send("{F6}")
	Send("52{TAB}")
	Sleep(500)

	Local $warning = WinWait("Atenção !!", "", 1)
	If $warning <> 0 Then
		Send("{ENTER}")
		Send("^{F4}")
		Send("!N")
	Else
		Send("^{F4}")
		Send("!S")
		WinWait("Atenção !!", "", 1)
		Send("{ENTER}")
	EndIf

	Send("{DOWN}")

WEnd
