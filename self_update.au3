#include <Misc.au3>

Func _CheckProgramUpdate($serverFile)
    Local $currentVersion = FileGetVersion(@ScriptFullPath)
    Local $serverVersion = FileGetVersion($serverFile)
    If @Compiled And FileExists($serverFile) And _VersionCompare($serverVersion, $currentVersion) == 1 Then
        _selfupdate($serverFile)
        Exit
    EndIf
EndFunc

Func _CheckFileUpdate($localFile, $serverFile)

	Local $serverDate = FileGetTime($serverFile, 0, 1)
	Local $localDate = FileGetTime($localFile, 0, 1)

	If ($localDate == 0 Or Number($serverDate) > Number($localDate) ) Then
		ConsoleWrite($serverDate & " - " & $localDate & @LF)
		_updateFile($localFile, $serverFile)
	EndIf

EndFunc

Func _selfupdate($serverFile, $timer = 1500)
    Run(@ComSpec & " /c ping 127.0.0.1 -n 1 -w " & $timer & ' & move /Y "' & @ScriptName & '" "' & @ScriptName & '.old" & copy /y "' & $serverFile & '" "' & @ScriptName & '" & start "Title" "' & @ScriptName & '"', @ScriptDir, @SW_HIDE)
EndFunc

Func _updateFile($localFile, $serverFile)
	FileMove($localFile, $localFile & '.old', 1)
	FileCopy($serverFile, $localFile)
EndFunc