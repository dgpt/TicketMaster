#include <IE.au3>
#include <WinAPI.au3>
#include <Constants.au3>

;;;;;;;;;;;;;;;;;;;;;;;;
;;  Ticket Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; "Public" Methods

Func TicketInit()

#CS
Load IE to gwi7/rep
Should be called once per session

Returns:
    Success: 1
    Failure: 0
#CE

    Global $ie_obj = _IECreate("gwi7/rep", GetPref("ie_attach"))
    If CheckError(@error, "TicketInit", "Failed to create main IE object") Then
        return 0
    EndIf
    Global $ie_hwnd = _IEPropertyGet($ie_obj, "hwnd")
    WinActivate($ie_hwnd)
    Send("^1")
    ;WinSetState($ie_hwnd, "", @SW_MAXIMIZE)
    return 1
EndFunc

Func TicketCreate($store, ByRef $type)

#CS
'Skeleton' method for creating tickets
Sets up ticket, calls given function to do details

@error:
    0: No error
    1: Ticket failed to open
    2: Timed out while loading ticket in iSupport
#CE

    Local $ticket = _TicketOpen($store)
    If CheckError(@error, "TicketCreate", "Failed to open ticket") Then
        SetError(1)
        return 0
    EndIf
 
    ; Make sure the ticket has loaded into iSupport before continuing
    ; Give it 5 seconds before throwing an error and returning.
    ; Use this nifty while loop to make it happen faster.
    Local $loop_stopper = 0
    Local $loop_limit = GetPref("ticket_load_time")
    Local $loop_inc = 100
    While StringInStr(_IEPropertyGet($ticket, "title"), $store) == 0
        If $loop_stopper >= $loop_limit Then
            SetError(2)
            return 0
        EndIf
        Sleep($loop_inc)
        $loop_stopper += $loop_inc
    WEnd

    ; According to AutoIt documentation, Call() does not support ByRef params.
    ; But... it seems to work fine, so let's roll with it.
    Call("_TicketType_" & $type, $ticket, GetPref("link_" & $type))
    
    Sleep(1000)
    WinActivate($ie_hwnd)
    Send("^1")
EndFunc

Func TicketExit()
; Shows all errors that occurred
EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; High-Level Ticket Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Names of these functions are based off of $ticket_struct variable names
; prefixed with '_TicketType_', so we can call them easily.

Func _TicketType_s99(ByRef $ticket, ByRef $type)
    _TicketSelectTemplate($ticket, $type)
EndFunc

Func _TicketType_xfer(ByRef $ticket, ByRef $type)
    _TicketSelectTemplate($ticket, $type)
EndFunc

Func _TicketType_nvm(ByRef $ticket, ByRef $type)
    _TicketSelectTemplate($ticket, $type)
EndFunc

Func _TicketType_mo(ByRef $ticket, ByRef $type)
    _TicketSelectTemplate($ticket, $type)
EndFunc

; NOT COMPLETE
; Need to close the ticket
Func _TicketType_dp(ByRef $ticket, ByRef $type)
    _TicketSelectTemplate($ticket, $type)
EndFunc

Func _TicketType_tcu(ByRef $ticket, ByRef $type)
    _TicketSelectTemplate($ticket, $type)
EndFunc

Func _TicketType_gco(ByRef $ticket, ByRef $type)
    _TicketSelectTemplate($ticket, $type)
EndFunc

Func _TicketType_proc(ByRef $ticket, ByRef $type)
    _TicketSelectTemplate($ticket, $type)
EndFunc

Func _TicketType_open(ByRef $ticket, ByRef $type)
    ; Do nothing
EndFunc



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Low-Level Ticket Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func _TicketOpen($store)

#CS
Opens up a new ticket, assigns to given store.
If an error occurs, close all opened windows.
Input:
    $store - store number
Return:
    Success: IE Object for New Ticket
    Failure: 0
@error:
    0: No Error
    1: Could not find ticket
    2: Error creating dialog object
    3: Error creating form object
    4: Error creating input object
    5: Error creating newTicket object
    6: Timeout waiting for Dialog window
    9: Unknown Error
#CE

    ; Set constants
    ; If these are wrong, the program will stall.
    Local Const $dialog_title = "Dialog - Select Customer"
    Local Const $dialog_toplink_id = "uxCustomerSelect_uxListView_Customers_ctrl0_uxLinkButton_Select"
    Local Const $newTicket_title = "New Incident Ticket"
    ; Activate main window, send <C-N> to make a new ticket (only supported in IE)
    ; Instead of JS injection, because it doesn't work right in IE
    WinActivate($ie_hwnd)
    Send("^n")
    ; Wait for dialog pop up
    Local $dialog_hwnd = WinWaitActive($dialog_title, "", GetPref("dialog_load_time"))
    If $dialog_hwnd = 0 Then
        SetError(6)
        return 0
    EndIf
    ; Create reference to new ticket
    Local $newTicket = _IEAttach($newTicket_title)
    If CheckError(@error, "_TicketOpen", "Error occurred while trying to create newTicket object.") Then
        SetError(5)
        return 0
    EndIf
    ; Create objects for dialog window, form, and text input
    ; Handle all possible errors
    ; Quit opened new ticket win
    Local $dialog_obj = _IEAttach($dialog_hwnd, "HWND")
    If CheckError(@error, "_TicketOpen", "Error occurred while trying to create dialog object.") Then
        _IEQuit($newTicket)
        SetError(2)
        return 0
    EndIf
    Local $dialog_form = _IEFormGetObjByName($dialog_obj, "frmSelectCustomer") 
    If CheckError(@error, "_TicketOpen", "Error occurred while trying to create form object.") Then
        _IEQuit($dialog_obj)
        _IEQuit($newTicket)
        SetError(3)
        return 0
    EndIf
    Local $dialog_input = _IEFormElementGetObjByName($dialog_form, "uxCustomerSelect$uxTextBox_SearchText")
    If CheckError(@error, "_TicketOpen", "Error occurred while trying to create input object.") Then
        _IEQuit($dialog_obj)
        _IEQuit($newTicket)
        SetError(4)
        return 0
    EndIf
    ; Enter store info in input
    _IEFormElementSetValue($dialog_input, $store)
    ; Allow iSupport to load the search...
    Sleep(GetPref("dialog_sleep_time"))
    ; Get object for top link to click on
    Local $dialog_toplink = _IEGetObjById($dialog_obj, $dialog_toplink_id)
    ; Check if $store is in the top link, if so click it
    ; Otherwise, try one more time before error-ing out
    If StringInStr(_IEPropertyGet($dialog_toplink, "outertext"), $store) Then
        _IEAction($dialog_toplink, "click")
        SetError(0)
        return $newTicket
    Else
        Sleep(GetPref("dialog_sleep_time"))
        $dialog_toplink = _IEGetObjById($dialog_obj, $dialog_toplink_id)
        If StringInStr(_IEPropertyGet($dialog_toplink, "outertext"), $store) Then
            _IEAction($dialog_toplink, "click")
            SetError(0)
            return $newTicket
        Else
            _IEQuit($dialog_obj)
            _IEQuit($newTicket)
            SetError(1)
            return 0
        EndIf
    EndIf
    ; Code shouldn't get down here, so return 0 and throw an error if it does
    _IEQuit($dialog_obj)
    _IEQuit($newTicket)
    SetError(9)
    return 0
EndFunc

Func _TicketOpenTemplate(ByRef $ticket)

#CS
Opens template dialog in iSupport for given IE ticket obj
Input:
    IE Ticket Object
Returns:
    Success: IE object for Template dialog
    Failure: 0
#CE
    Local Const $template_title = "Dialog - Use Incident Template"
    _IENavigate($ticket, "javascript:useTemplate();", 0)
    Local $result = WinWait($template_title, "", 30)
    If $result = 0 Then
        return 0
    ElseIf IsHWnd($result) Then
;*******; TODO: Strange bug around here... I'll get a 'no match' error on _IEAttach, have no clue why.
        Local $template = _IEAttach($result, "HWND")
        If CheckError(@error, "_TicketOpenTemplate", "Unable to create IE object for Template Dialog") Then
            return 0
        EndIf
        _IELoadWait($template)
        return $template
    EndIf
EndFunc

Func _TicketSelectTemplate(ByRef $ticket, ByRef $type)
#CS
Opens template dialog, selects given template.
Loops through all links in template dialog to match the given type

Input:
    $ticket - reference to IE object for the current ticket
    $type - type of ticket. String of link text. (Get from preferences)

Returns:
    Success: 1
    Failure: 0
#CE
    Local $template_dialog = _TicketOpenTemplate($ticket)
    Local $link_collection = _IELinkGetCollection($template_dialog)
    For $link In $link_collection
        If $link.innerhtml == $type Then
            _IEAction($link, "click")
            return 1
        EndIf
    Next
    return 0
EndFunc

Func _TicketCloseCallScript()

EndFunc
