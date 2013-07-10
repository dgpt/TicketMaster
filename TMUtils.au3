#CS
##############

Various utilities

- Input parsing
- Logging
- Convenience Wrappers for AutoIt Functions
- Struct Wrappers

##############
#CE

;;;;;;;;;;;;;;;;;;;;;;
;; Input Parsing    ;;
;;;;;;;;;;;;;;;;;;;;;;

; Returns an array of elements delimited by a <C-R>
; Returns an array of [0] if delimiter not found
Func ParseInput(ByRef $input)
    Local $text = GUICtrlRead($input)
    Local $result = StringSplit($text, @CRLF, 1)
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

;;;;;;;;;;;;;;;;;;;;;;;
;; Logging Utilities ;;
;;;;;;;;;;;;;;;;;;;;;;;

; Takes an array, puts it in the log file, creates if doesn't exist.
; Returns 0 if failed, 1 if successful
Func LogArray(ByRef $array)
    ; Build results from passed array
    Local $result = ""
    For $i = 1 To UBound($array) - 1
        $result = $result & $array[$i] & @CRLF
    Next
    ; Opens log file from preferences, handles errors
    Local $logpath = GetPref("log_path")
    Local $logfile = FileOpen($logpath, GetPref("log_append"))
    If $logfile = -1 Then
        ErrMsg(-1, "LogArray", "Unable to open file " & $logpath)
        return 0
    EndIf
    ; Writes date/time and results to log file from prefs.
    Local $write_success = FileWrite($logfile, GetDateTime() & $result & @CRLF)
    If $write_success = 0 Then
        ErrMsg(0, "LogArray", "Error in writing to file " & $logpath)
        return 0
    EndIf
    FileClose($logfile)
    return 1
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;
;; Convenience Utils ;;
;;;;;;;;;;;;;;;;;;;;;;;

; Checks errors calls ErrMsg, makes code a little easier to read
; returns true if error occurred, false otherwise
Func CheckError($error, $loc, $message = "")
    If $error Then
        ErrMsg($error, $loc, $message)
        return true
    Else
        return false
    EndIf
EndFunc

; Wrapper for Error messages
; Optional message param will be added to end
Func ErrMsg($error, $loc, $message = "")
    Local $m
    If $message == "" Then
        $m = "Error occured in " & $loc & ". Error code: " & $error
    Else
        $m = "Error occured in " & $loc & ". Error code: " & $error & @CRLF & $message
    EndIf
    MsgBox(0x10, "Error at " & $loc, $m)
EndFunc

; Convenience Wrapper for dialogs
Func DbgMsg($message)
    MsgBox(0, "", $message)
EndFunc

; Get formatted date and time
Func GetDateTime()
    return @MON & "/" & @MDAY & "/" & @YEAR & @CRLF & @HOUR & ":" & @MIN & ":" & @SEC & @CRLF
EndFunc


;;;;;;;;;;;;;;;;;;;;;;
;; STUCT UTILS      ;;
;;;;;;;;;;;;;;;;;;;;;;

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
        If CheckError(@error, "ClearArray", "Error:" & _HandleStructError(@error)) Then
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
        If CheckError(@error, "SetArray", "Error: " & _HandleStructError(@error)) Then
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

; Convenience wrappers for Struct utilities
; Allows us to not pass the struct on each call
Func ClearTicketArray($ticket)
    return ClearArray($ticket_struct, $ticket)
EndFunc

Func GetTicketArray($ticket)
    return GetArray($ticket_struct, $ticket)
EndFunc

Func SetTicketArray($ticket, ByRef $array)
    return SetArray($ticket_struct, $ticket, $array)
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


