Func InstallInlineExtension ()

	Local $source = "K:\001 - JOD - GMJOD (2013)\005 - DIVERSOS\Utilitarios\Scripts\"
	Local $target = "D:\GMJD\"
	Local $extensionName = "inlinedisposition-1.0.2.4-sm+fx.xpi"

	If Not(FileExists($target & $extensionName)) Then
		FileCopy($source & $extensionName, $target & $extensionName, 9)
	EndIf

	RegWrite("HKEY_CURRENT_USER\Software\Mozilla\Firefox\Extensions", "{123647d5-da43-4344-bfe2-fc093bdf8f5e}", "REG_SZ", $target & $extensionName)

EndFunc

Func UpdateDotm ()

	Local $localFile = @AppDataDir & "\Microsoft\Word\INICIALIZAÇÃO\GMJD.dotm"
	Local $serverFile = "K:\001 - JOD - GMJOD (2013)\005 - DIVERSOS\Utilitarios\Modelos\GMJD.dotm"
	_CheckFileUpdate($localFile, $serverFile)

	$localFile = @AppDataDir & "\Microsoft\QuickStyles\GMJD.dotx"
	$serverFile = "K:\001 - JOD - GMJOD (2013)\005 - DIVERSOS\Utilitarios\Modelos\GMJD.dotx"
	_CheckFileUpdate($localFile, $serverFile)

EndFunc
