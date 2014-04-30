#include <Misc.au3>

Local $installerPath = "K:\001 - JOD - GMJOD (2013)\005 - DIVERSOS\Utilitarios\Scripts\spdf-2.4"
Local $targetPath = @TempDir & "\spdf.exe"
Local $installerVersion = FileGetVersion($installerPath)

Local $regPath = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\SumatraPDF"

If IsAdmin() Then
	$regPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SumatraPDF"
EndIf

Local $version = RegRead($regPath, "DisplayVersion")

If @error <> 0 Then
	FileCopy($installerPath, $targetPath)
	ConsoleWrite(@TempDir&@LF)
	Run(@ComSpec & " /c " & $targetPath & " /s /opt plugin,pdffilter", @ScriptDir, @SW_HIDE)
	MsgBox(0, "Sumatra", "Sumatra Instalado")
EndIf



