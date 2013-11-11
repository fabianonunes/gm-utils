#include <Array.au3>

Func getPK($id)

	Local $url = "http://ext02.tst.jus.br/pls/ap01/ap_proc100.dados_processos?num_proc="&$id[0]&"&dig_proc="&$id[1]&"&ano_proc="&$id[2]&"&num_orgao="&$id[3]&"&TRT_proc="&$id[4]&"&vara_proc="&$id[5]
	Local $oHTTP = ObjCreate("winhttp.winhttprequest.5.1")
	Local $mask = "num_int=([0-9]*)&ano_int=([0-9]{4})"

	$oHTTP.Open("GET", $url, False)
	$oHTTP.Option(6) = False
	$oHTTP.Send()
	$HeaderResponses = $oHTTP.GetAllResponseHeaders()
	return StringRegExp($HeaderResponses, $mask, 1)

EndFunc

Func openAll($id)
	Local $pk = getPK($id)
	ShellExecute("http://aplicacao6.tst.jus.br/esij/VisualizarPecas.do?visualizarTodos=1&anoProcInt="&$pk[1]&"&numProcInt="&$pk[0])
EndFunc

Func parseProcesso($processo)
	Local $processoRegexp = "([1-9][0-9]{0,6})-([0-9]{1,2})[-.]([0-9]{4})[-.]([0-9])[-.]([0-9]{2})[-.]([0-9]{4})"
	return StringRegExp($processo, $processoRegexp, 1)
EndFunc

Func openESij($id)
	If($id <> 0) Then
		Local $url = "https://aplicacao6.tst.jus.br/esij/ConsultarProcesso.do?consultarNumeracao=Consultar&numProc="&$id[0]&"&digito="&$id[1]&"&anoProc="&$id[2]&"&justica="&$id[3]&"&numTribunal="&$id[4]&"&numVara="&$id[5]
		ShellExecute($url)
	EndIf
EndFunc