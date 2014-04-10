#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Sobre...", 228, 81, -1, -1)
$Group1 = GUICtrlCreateGroup("", 9, 8, 207, 65)
$Label1 = GUICtrlCreateLabel("Desenvolvido por", 16, 24, 103, 17)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
$Label2 = GUICtrlCreateLabel("Fabiano Nunes", 128, 24, 76, 17)
$Label3 = GUICtrlCreateLabel("http://github.com/fabianonunes/gm-utils", 16, 48, 196, 17)
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetCursor (-1, 0)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetIcon("editor.ico")

#EndRegion ### END Koda GUI section ###

Func About ()

	GUISetState(@SW_SHOW)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_HIDE)
				ExitLoop
		EndSwitch
	WEnd

EndFunc
