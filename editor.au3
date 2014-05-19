#Region
#AutoIt3Wrapper_Outfile=K:\001 - JOD - GMJOD (2013)\005 - DIVERSOS\Utilitarios\Scripts\Editor
#__AutoIt3Wrapper_Outfile=D:\GMJD\Editor.exe
#AutoIt3Wrapper_Res_Fileversion=0.0.0.57
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Icon=icons\editor.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\stamp.ico
#AutoIt3Wrapper_Res_Icon_Add=icons\checker.ico
#EndRegion

#include <Array.au3>
#include <Misc.au3>
#include "helpers.au3"
#include "lib\FileRegister.au3"
#include "self_update.au3"
#include "updates.au3"
#include "about.au3"
#include "carimbar.au3"
#include "checker.au3"
#include "planilha.au3"

FileRegister("fab", 'D:\GMJD\Editor.exe stamp "%1"', 'Carimbar', 0, "D:\GMJD\Editor.exe,5")
FileRegister("fab", 'D:\GMJD\Editor.exe check "%1"', 'Selecionar', 1, "D:\GMJD\Editor.exe,5")
FileRegister("fab", 'D:\GMJD\Editor.exe planilhar "%1"', 'Planilhar', 0, "D:\GMJD\Editor.exe,5")

If UBound($CmdLine) > 1 Then

	If $CmdLine[1] == "stamp" Then

		TraySetIcon("icons\stamp.ico")
		carimbar($CmdLine[2])

	ElseIf $CmdLine[1] == "check" Then

		TraySetIcon("icons\checker.ico")
		checker($CmdLine[2])

	ElseIf $CmdLine[1] == "planilhar" Then

		TraySetIcon("icons\checker.ico")
		planilhar($CmdLine[2])

	EndIf

	Exit

EndIf

Opt("TrayOnEventMode", 1)
Opt("TrayMenuMode", 1)
Opt("SendKeyDelay", 45)

;~ config tray
TraySetClick(16)
TraySetIcon("icons\editor.ico")
TraySetState()

Local $loadingItem = TrayCreateItem("Carregando...")
TraySetToolTip("Carregando...")
Sleep(5000)
TrayItemDelete($loadingItem)

TraySetOnEvent(-9, "createMenu")

; ~ ao adicionar um novo item, essas variaveis devem ser atualizadas
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
				TrayItemSetState($idItem, 256 + 1)
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


		Send("!pe{RIGHT}e")

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

		Opt("SendKeyDelay", 15)

		setFocusText($title, $editor, $result[0])
		Send("{TAB}")

		setFocusText($title, $editor, $result[1])
		Send("{TAB}")

		setFocusText($title, $editor, $result[2])
		Send("{TAB}")

		setFocusText($title, $editor, $result[4])
		Send("{TAB}")

		setFocusText($title, $editor, $result[5])
		Send("{F8}")

		Opt("SendKeyDelay", 45)

	EndIf

EndFunc

Func setFocusText($title, $text, $value)
	Local $focused = ControlGetFocus($title, $text)
	ControlSetText ($title, $text, $focused, $value )
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