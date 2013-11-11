#include <Misc.au3>

Func _CheckUpdate($serverFile)
    Local $currentVersion = FileGetVersion(@ScriptFullPath)
    Local $serverVersion = FileGetVersion($serverFile)
    If @Compiled And FileExists($serverFile) And _VersionCompare($serverVersion, $currentVersion) == 1 Then
        _selfupdate($serverFile)
        Exit
    EndIf
EndFunc

Func _selfupdate($serverFile, $timer = 1500)
    Run(@ComSpec & " /c ping 127.0.0.1 -n 1 -w " & $timer & ' & move /Y "' & @ScriptName & '" "' & @ScriptName & '.old" & copy /y "' & $serverFile & '" "' & @ScriptName & '" & start "Title" "' & @ScriptName & '"', @ScriptDir, @SW_HIDE)
EndFunc