; Takes a TICKET constant and returns a string used
; to route it to the corresponding struct array
Func RouteArray($ticket)
    Select
        Case $ticket == $TICKET_99
            return "s99"

        Case $ticket == $TICKET_XFER
            return "xfer"

        Case $ticket == $TICKET_NVM
            return "nvm"

        Case $ticket == $TICKET_MO
            return "mo"

        Case $ticket == $TICKET_DP
            return "dp"

        Case $ticket == $TICKET_OPEN
            return "open"

        Case Else
            MsgBox(0, "", "ERROR: RouteArray value not determined. Returning 'open'")
            return "open"

    EndSelect
EndFunc


; Set all elements of given array in given struct to 0
; Loop as little as possible, while effectively cleaning out the array
Func ClearArray(ByRef $struct, $ticket)
    Local $var = RouteArray($ticket)
    ; Set the limit for the loop to the first member of the array
    ; Which we can assume is the length of the array 
    Local $limit = DllStructGetData($struct, $var, 1)
    For $i = 1 To $limit + 1
        DllStructSetData($struct, $var, 0, $i)
        If @error Then
            MsgBox(0, "", "Error in ClearArray at i=" & $i & " error: " & _HandleStructError(@error))
            return 0
        EndIf
    Next
EndFunc

; Sets a struct array to a given array
; Clears struct array before setting new one to avoid unwanted values
; Assumes $array[0] is the length of the array
Func SetArray(ByRef $struct, $ticket, ByRef $array)
    ClearArray($struct, $ticket)
    Local $var = RouteArray($ticket)
    For $i = 0 To $array[0]
        DllStructSetData($struct, $var, $array[$i], $i + 1)
        If @error Then
            MsgBox(0, "", "Error in SetArray at i=" & $i & " error: " & _HandleStructError(@error))
            return 0
        EndIf
    Next
EndFunc

; Returns an array containing contents of given array in given struct
Func GetArray(ByRef $struct, $ticket)
    Local $var = RouteArray($ticket)
    Local $result[1] = [0]
    Local $limit = DllStructGetData($struct, $var, 1)
    Local $length = 0
    ; set $i to 2 so we can get an accurate length
    ; because we ignore @CRLFs and 0 values
    For $i = 2 To $limit + 1
        Local $data = DllStructGetData($struct, $var, $i)
        If $data <> 0 Then
            _ArrayAdd($result, $data)
            $length += 1
        EndIf
    Next
    $result[0] = $length
    return $result
EndFunc

; Handles struct error messages
Func _HandleStructError($error)
    Switch $error
        Case 1
            return "Struct not a correct struct returned by DllStructCreate."

        Case 2
            return "Element value out of range."

        Case 3
            return "Index would be outside of the struct."

        Case 4
            return "Element data type is unknown."

        Case 5
            return "Index <= 0."
    EndSwitch
EndFunc
