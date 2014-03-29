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
#CS
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
#CE
    ; According to AutoIt documentation, Call() does not support ByRef params.
    ; But... it seems to work fine, so let's roll with it.
    Call("_TicketType_" & $type, $ticket, GetPref("link_" & $type))

    Sleep(1000)
    WinActivate($ie_hwnd)
    ;Send("^1")
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

Func _TicketType_outlook_outage(ByRef $ticket, ByRef $type)
    _TicketShortDescription($ticket, "Outlook Outage")
    _TicketDescription($ticket, "Store reported chainwide Exchange Server outage.")
    _TicketResolution($ticket, "Acknowledged report of known issue. The appropriate teams have resolved the issue.")
    _TicketAddlInfo($ticket, "1")
    _TicketStatus($ticket, "Closed")
    _TicketImpact($ticket, "Store")
    _TicketUrgency($ticket, 4)
    _TicketPriority($ticket, 2)
   ;_TicketCategory($ticket, "SUPPORT RETAIL SALES/OPERATIONS EMAIL DATA PROBLEM")
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
    ; Send("^n")
    _IENavigate($ie_obj, "javascript:SocialDashboard.OpenEntityWindow(16, 0);", 0)
    ; Wait for dialog pop up
    Local $dialog_hwnd = WinWait($dialog_title, "Dialog - Select Customer", GetPref("dialog_load_time"))
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

    ; Make sure dialog is loaded before continuing.
    _IELoadWait($dialog_obj)
    If CheckError(@error, "_TicketOpen", "Error occurred while waiting for dialog to load.") Then
        _IEQuit($dialog_obj)
        _IEQuit($newTicket)
        SetError(6)
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
    _IEAction($dialog_input, "focus")
    Send($store)
    ; Check if $store is in the top link, if so click it
    For $i = 0 to GetPref("dialog_sleep_time")
        Sleep(10)
        ; Get object for top link to click on
        Local $dialog_toplink = _IEGetObjById($dialog_obj, $dialog_toplink_id)
        If StringInStr(_IEPropertyGet($dialog_toplink, "outertext"), $store) Then
            _IEAction($dialog_toplink, "click")
            SetError(0)
            return $newTicket
        EndIf
    Next
    ; Code shouldn't get down here, so return 0 and throw an error if it does
    _IEQuit($dialog_obj)
    _IEQuit($newTicket)
    SetError(1)
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
    Local $result = WinWait($template_title)
    WinActivate($result)
    If $result = 0 Then
        return 0
    ElseIf IsHWnd($result) Then
        Local $template = _IEAttach($template_title)
        return $template
    EndIf
    return 0
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

Func _TicketShortDescription(ByRef $ticket, $text)
#CS
    Writes $text to $ticket's short description field
    Returns:
        Success: 1
        Failure: 0
#CE

    Local $desc = _IEGetObjById($ticket, "uxTextBox_ShortDescription")
    _IEPropertySet($desc, "innertext", $text)
    If CheckError(@error, "_TicketShortDescription", "Could not write short description. Write it manually or close the ticket.") Then
        return 0
    Else
        return 1
    EndIf
EndFunc

Func _TicketDescription(ByRef $ticket, $text)
#CS
    Writes $text to $ticket's description field
    Returns:
        Success: 1
        Failure: 0
#CE
    Local $desc = _IEGetObjById($ticket, "uxGwiEditor_Description_RadEditor2")

    $desc.control._contentArea.innerText = $text

EndFunc

Func _TicketResolution(ByRef $ticket, $text)
#CS
    Writes $text to $ticket's resolution field
    Returns:
        Success: 1
        Failure: 0
#CE
    Local $res = _IEGetObjById($ticket, "uxGwiEditor_Resolution_RadEditor2")

    $res.control._contentArea.innerText = $text
EndFunc

Func _TicketAddlInfo(ByRef $ticket, $tier)
    ; BAU id: CustomFields___cf1029_1
    ; Tiers id: CustomFields___cf1031_0 (1) CustomFields___cf1031_1 (2) CustomFields___cf1031_2 (3)

    Select
        Case $tier == "1"
            $tier = "CustomFields___cf1031_0"

        Case $tier == "2"
            $tier = "CustomFields___cf1031_1"

        Case $tier == "3"
            $tier = "CustomFields___cf1031_2"

        Case Else
            ErrMsg("Unknown Tier", "_TicketAddlInfo")
    EndSelect

    Local $t = _IEGetObjById($ticket, $tier)
    Local $b = _IEGetObjById($ticket, "CustomFields___cf1029_1")

    $t.checked = true;
    $b.checked = true;
EndFunc

Func _TicketCategory(ByRef $ticket, $cat)

    Local $c = _IEGetObjById($ticket, "uxHiddenField_CategoryText")
    $c.value = $cat
EndFunc

Func _TicketStatus(ByRef $ticket, $status)
#CS
    Status Values
    Accepted (Open)                - 1:17
    Work in Progress (Open)        - 1:18
    Resolved (open)                - 1:19
    Clarification (open)           - 1:20
    Pending UAT (open)             - 1:21
    Open                           - 1:1
    Open (In Progress) (Suspended) - 4:6
    Suspended                      - 4:3
    Closed                         - 2:2
#CE
    _IENavigate($ticket, "javascript:setStatus('Closed', 2, 2);", 0)
EndFunc

Func _TicketImpact(ByRef $ticket, $impact)
    ; 1 = individual
    ; 13 = store
    Local $select = _IEGetObjById($ticket, "uxUIP_Select_uxDropDownList_Impact")
    $select.value = "13"
EndFunc

Func _TicketUrgency(ByRef $ticket, $urgency)
    Local $select = _IEGetObjById($ticket, "uxUIP_Select_uxDropDownList_Urgency")
    $select.value = $urgency
EndFunc

Func _TicketPriority(ByRef $ticket, $priority)
    Local $select = _IEGetObjById($ticket, "uxUIP_Select_uxDropDownList_Priority")
    $select.value = $priority
EndFunc

#CS
WorkItem.HandleSave(close)
to save
#CE
