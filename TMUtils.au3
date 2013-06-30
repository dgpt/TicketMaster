; Returns an array of elements delimited by a <C-R>
; Returns an array of [0] if delimiter not found
Func ParseInput(ByRef $input)
    Local $text = GUICtrlRead($input)
    Local $result = StringSplit($text, @CRLF, 1)
    ;_ArrayDisplay($result)
    ; @error = 1 when @CRLF is not found
    If @error == 1 Then
        Local $result[1] = [0]
        If $text == "" Then
            return $result
        Else
            $result[0] = 1
            _ArrayAdd($result, $text)
            return $result
        EndIf
    Else
        return $result
    EndIf
EndFunc


; Convenience Wrapper
Func DbgMsg($message)
    MsgBox(0, "", $message)
EndFunc
