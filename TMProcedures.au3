#include <IE.au3>
#include <WinAPI.au3>
#include <Constants.au3>


; Load IE to gwi7/rep
; Should be called once per session
Func TicketInit()
    Global $ie_obj = _IECreate("gwi7/rep", GetPref("ie_attach"))
    Global $ie_hwnd = _IEPropertyGet($ie_obj, "hwnd")
    WinSetState($ie_hwnd, "", @SW_MAXIMIZE)
    _TicketOpen(11000000)
    CheckError(@error, "TicketInit")
EndFunc

; sets up ticket, calls given function to do details
Func TicketCreate($store, $type)
    _TicketOpen($store)
    Call($type)
EndFunc

; Exits gracefully
Func TicketExit()

EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Low-Level Ticket Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Opens up a new ticket, assigns to given store.
; Return:
;   Success: 1
;   Failure: 0
; @error:
;   1: Could not find ticket
;   2: Error creating dialog object
;   3: Error creating form object
;   4: Error creating input object
;   5: Unknown Error
Func _TicketOpen($store)
    ; Set constants - used multiple times
    Local Const $dialog_title = "Dialog - Select Customer"
    Local Const $isupport_toplink_id = "uxCustomerSelect_uxListView_Customers_ctrl0_uxLinkButton_Select"
    ; Activate main window, send <C-N> to make a new ticket (only supported in IE)
    WinActivate($ie_hwnd)
    Send("^n")
    ; Wait for dialog pop up
    WinWaitActive($dialog_title)
    ; Create objects for dialog window, form, and text input
    ; Handle all possible errors
    Local $dialog_obj = _IEAttach($dialog_title)
    If CheckError(@error, "_TicketOpen", "Error occurred while trying to create dialog object.") Then
        SetError(2)
        return 0
    EndIf
    Local $dialog_form = _IEFormGetObjByName($dialog_obj, "frmSelectCustomer") 
    If CheckError(@error, "_TicketOpen", "Error occurred while trying to create form object.") Then
        SetError(3)
        return 0
    EndIf
    Local $dialog_input = _IEFormElementGetObjByName($dialog_form, "uxCustomerSelect$uxTextBox_SearchText")
    If CheckError(@error, "_TicketOpen", "Error occurred while trying to create input object.") Then
        SetError(4)
        return 0
    EndIf
    ; Enter store info in input
    _IEFormElementSetValue($dialog_input, $store)
    ; Allow iSupport to load the search...
    Sleep(GetPref("dialog_sleep_time"))
    ; Get object for top link to click on
    Local $dialog_toplink = _IEGetObjById($dialog_obj, $isupport_toplink_id)
    ; Check if $store is in the top link, if so click it
    ; Otherwise, try one more time before error-ing out
    If StringInStr(_IEPropertyGet($dialog_toplink, "outertext"), $store) Then
        _IEAction($dialog_toplink, "click")
        return 1
    Else
        Sleep(GetPref("dialog_sleep_time"))
        $dialog_toplink = _IEGetObjById($dialog_obj, $isupport_toplink_id)
        If StringInStr(_IEPropertyGet($dialog_toplink, "outertext"), $store) Then
            _IEAction($dialog_toplink, "click")
            return 1
        Else
            SetError(1)
            return 0
        EndIf
    EndIf
    ; Code shouldn't get down here, so return 0 and throw an error if it does
    SetError(5)
    return 0
EndFunc
