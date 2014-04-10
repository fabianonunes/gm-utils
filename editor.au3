#Region
#AutoIt3Wrapper_Outfile=K:\001 - JOD - GMJOD (2013)\005 - DIVERSOS\Utilitarios\Scripts\Editor
#AutoIt3Wrapper_Res_Fileversion=0.0.0.29
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Icon=editor.ico
#EndRegion


#include <Array.au3>
#include <Misc.au3>
#include "helpers.au3"
#include-once
#include "self_update.au3"
#include "updates.au3"
#include "about.au3"

Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 1)
Opt("SendKeyDelay", 25)

;~ config tray
TraySetClick(16)
TraySetIcon("editor.ico")
TraySetState()

$loadingItem = TrayCreateItem("Carregando...")
TraySetToolTip("Carregando...")
Sleep(5000)
TrayItemDelete($loadingItem)

TraySetOnEvent(-9, "createMenu")

Global $items = 20, $menuItems[$items], $menuElements[$items+4], $lastClick

TraySetToolTip("Click: Editor" & @LF & "Ctrl + Click: e-SIJ" & @LF & "Shift + Click: Visualizar todos (PDFs)")

Func createMenu()

	Local $processoRegexp = "[0-9]{0,7}-[0-9]{1,2}[-.][0-9]{4}[-.][0-9][-.][0-9]{2}[-.][0-9]{4}"

	clearMenu()

	Local $result = StringRegExp(ClipGet(), $processoRegexp, 3)

	If IsArray($result) Then

 		$result = _ArrayUnique($result)
		_ArrayDelete($result, 0)

		_ArrayInsert($result, 0, "-")

		For $element In $result

			Local $index = _ArraySearch($menuItems, $element)

			If $index == -1 Then
				_ArrayPush($menuItems, $element)
			Else
				_ArrayDelete($menuItems, $index)
				_ArrayAdd($menuItems, $element)
			EndIf

		Next

	EndIf

 	_ArrayPush($menuElements, TrayCreateItem("Sobre..."), 0)
	TrayItemSetOnEvent(-1, "About")

 	_ArrayPush($menuElements, TrayCreateItem("Atualizar"), 0)
	TrayItemSetOnEvent(-1, "Update")

	_ArrayPush($menuElements, TrayCreateItem("Sair"), 0)
	TrayItemSetOnEvent(-1, "ExitScript")

	_ArrayPush($menuElements, TrayCreateItem(""), 0)

	Local $order = 0, $idItem
	For $element In $menuItems

		If StringLen($element) > 0 Then

			If $element == "-" Then
				If $order > 0 Then
					$element = ""
				Else
					ContinueLoop
				EndIf
			EndIf

			$idItem = TrayCreateItem($element)

			If $element == $lastClick Then
				TrayItemSetState($idItem, 256)
			EndIf

			_ArrayPush($menuElements, $idItem, 0)

			TrayItemSetOnEvent(-1, "openEditorFromTray")

			$order += 1

		EndIf

	Next

EndFunc

Func clearMenu()
	For $element In $menuElements
		TrayItemDelete($element)
	Next
	For $i = 0 To $items + 1 Step 1
		$menuElements[$i] = ""
 	Next
EndFunc

Func openEditorFromTray()

;~  get item value before clear
	Local $value = TrayItemGetText(@TRAY_ID)

;~  salva o item clicado
	$lastClick = $value

	Local $id = parseProcesso($value)

;~ 	disable menu to avoid double execution
	TraySetOnEvent(-9, "")

	clearMenu()
	_ArrayPush($menuElements, TrayCreateItem("Aguarde a última operação..."), 0)

	If _IsPressed("11") Then
		openESij($id)
	ElseIf _IsPressed("10") Then
		openAll($id)
	Else
		openEditor($id)
	EndIf

;~  renable menu creation
	TraySetOnEvent(-9, "createMenu")

EndFunc

Func openEditor($result)

	Local $title = "Sistema de Apoio a Gabinetes -"
	Local $editor = "Editor do eRecurso - GBeRecur"
	Local $focused

	If $result <> 0 Then

		Local $active = WinActivate($title)
		Local $editorTimeout = 0

		If $active == 0 Then
			MsgBox(0, "Oops!", "Não foi possível abrir o Editor. Você abriu o SAG?")
			Return 0
		EndIf


		Send("!pe{RIGHT}{ENTER}")

		While($focused <> "Edit1")

			WinActivate($title)

			$focused = ControlGetFocus($title, $editor)
			Sleep(200)

			$editorTimeout += 1

			If $editorTimeout > 4 Then
				MsgBox(0, "Oops!", "O Editor não respondeu. Será que o SAG está travado?")
				Return 0
			EndIf


		WEnd

		Send($result[0])

;~ 		it isn't necessary to send a tab when the number has 7 digits
		If(StringLen($result[0])<7) Then
			Send("{TAB}")
		EndIf

		Send($result[1]&$result[2])

;~ 		it is necessary to send justice code when the number has 7 digits
		If(StringLen($result[0])>6) Then
			Send($result[3])
		EndIf

		Send($result[4]&$result[5]&"{F8}")

	EndIf

EndFunc

Func Update()
	UpdateDotm()
	Local $update = _CheckProgramUpdate("K:\001 - JOD - GMJOD (2013)\005 - DIVERSOS\Utilitarios\Scripts\Editor")
	If $update Then
		MsgBox(1, "Atualizado", "Atualizado")
	EndIf
EndFunc

Func ExitScript()
	Exit
EndFunc

Global $timeout = 0
While 1
    Sleep(50)

	If($timeout = 0 Or Mod($timeout, 1000*60*10) == 0) Then
		_CheckProgramUpdate("K:\001 - JOD - GMJOD (2013)\005 - DIVERSOS\Utilitarios\Scripts\Editor")
		UpdateDotm()
		$timeout = 0
	EndIf

	$timeout+=50

WEnd