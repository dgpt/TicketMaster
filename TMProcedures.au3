#include <IE.au3>
#include <WinAPI.au3>
#include <Constants.au3>

;;;;;;;;;;;;;;;;;;;;;;;;
;;  Ticket Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; "Public" Methods

; Load IE to gwi7/rep
; Should be called once per session
Func TicketInit()
    Global $ie_obj = _IECreate("gwi7/rep", GetPref("ie_attach"))
    Global $ie_hwnd = _IEPropertyGet($ie_obj, "hwnd")
    WinSetState($ie_hwnd, "", @SW_MAXIMIZE)
EndFunc

; sets up ticket, calls given function to do details
Func TicketCreate($store, $type)
    Local $ticket = _TicketOpen($store)
    CheckError(@error, "TicketCreate", "Failed to open ticket")
    ;Call($type)
EndFunc

; Exits gracefully
Func TicketExit()

EndFunc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Low-Level Ticket Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Func _TicketOpen($store)

; Opens up a new ticket, assigns to given store.
; If an error occurs, close all opened windows.
; Return:
;   Success: IE Object for New Ticket
;   Failure: 0
; @error:
;   0: No Error
;   1: Could not find ticket
;   2: Error creating dialog object
;   3: Error creating form object
;   4: Error creating input object
;   5: Error creating newTicket object
;   9: Unknown Error

    ; Set constants - used multiple times
    ; If these are wrong, the program will stall.
    Local Const $dialog_title = "Dialog - Select Customer"
    Local Const $dialog_toplink_id = "uxCustomerSelect_uxListView_Customers_ctrl0_uxLinkButton_Select"
    Local Const $newTicket_title = "New Incident Ticket"
    ; Activate main window, send <C-N> to make a new ticket (only supported in IE)
    WinActivate($ie_hwnd)
    Send("^n")
    ; Wait for dialog pop up
    WinWaitActive($dialog_title)
    ; Create reference to new ticket
    Local $newTicket = _IEAttach($newTicket_title)
    If CheckError(@error, "_TicketOpen", "Error occurred while trying to create newTicket object.") Then
        SetError(5)
        return 0
    EndIf
    ; Create objects for dialog window, form, and text input
    ; Handle all possible errors
    ; Quit opened new ticket win
    Local $dialog_obj = _IEAttach($dialog_title)
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
