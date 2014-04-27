#include <Array.au3>

Opt("MustDeclareVars", 1)

Func spartanEncode128C($code)

   ; http://en.wikipedia.org/wiki/Code_128
   ; http://grandzebu.net/informatique/codbar-en/code128.htm

   Local $c      = Chr(210)
   Local $check  = 105
   Local $sub    = ""

   $code = StringRegExpReplace($code, "[^\d]", "") ; this is sparta

   If Mod(StringLen($code), 2) > 0 Then
	  $code = "0" & $code ; this is spaaaaarta
   EndIf

   For $i = 1 To StringLen($code) Step 2
	  $sub     = 0 + StringMid($code, $i, 2)
	  $check  += $sub * ( ($i-1)/2 + 1 )
	  $c      &= Chr($sub + ($sub < 95 ? 32 : 105))
   Next

   $check  = Mod($check, 103)
   $c     &= Chr($check + ($check < 95 ? 32 : 105)) & Chr(211)

   Return $c

EndFunc
