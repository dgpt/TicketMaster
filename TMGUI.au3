;; Ticket Master GUI and Events

Func TMInit()
    ; GUI Constants
    Local Const $WINDOW_WIDTH = 230, $WINDOW_HEIGHT = 250
    Local Const $BUTTON_WIDTH = 70, $BUTTON_HEIGHT = 40
    Local Const $LIST_WIDTH = 100, $LIST_HEIGHT = 170
    Local Const $INPUT_WIDTH = 100, $INPUT_HEIGHT = 215

    ; Used for saving input state when switching between tickets
    Global $LAST_TICKET_SELECTED = false


    ; Create Window
    Global $window_main = GUICreate("Ticket Master", $WINDOW_WIDTH, $WINDOW_HEIGHT)

    ;Menus
    ;File
    Local $menu_file = GUICtrlCreateMenu("&File")
    Local $mi_save = GUICtrlCreateMenuItem("&Save", $menu_file)
    Local $mi_load = GUICtrlCreateMenuItem("&Load", $menu_file)

    ;Application
    Local $menu_app = GUICtrlCreateMenu("&Application")
    Local $mi_go = GUICtrlCreateMenuItem("&Go", $menu_app)
    Local $mi_clear = GUICtrlCreateMenuItem("Clear All Lists", $menu_app)
    GUICtrlCreateMenuItem("", $menu_app)        ; separator
    Local $mi_pref = GUICtrlCreateMenuItem("&Preferences", $menu_app)

    ;Help
    Local $menu_help = GUICtrlCreateMenu("&Help")

    ;Other components
    Global $list_main = GUICtrlCreateList("", 10, 10, $LIST_WIDTH, $LIST_HEIGHT)
    GUICtrlSetData($list_main, $ALL_TICKETS_STRING)
    Global $input_main = GUICtrlCreateInput("", 110, 0, $INPUT_WIDTH, $INPUT_HEIGHT, $ES_MULTILINE + $ES_WANTRETURN + $WS_VSCROLL)
    GUICtrlSetState($input_main, $GUI_DISABLE)  ; Disable input until a ticket category is selected
    Global $button_go = GUICtrlCreateButton("Go", -95, 175, $BUTTON_WIDTH, $BUTTON_HEIGHT)
    GUICtrlSetState($button_go, $GUI_DISABLE)   ; Disable button until ticket is selected

    ; Bind Events!
    ;GUI Events
    GUISetOnEvent($GUI_EVENT_CLOSE, "OnAppExit")
    ;GUI Ctrl Events
    ; Interface Events
    GUICtrlSetOnEvent($list_main, "OnListChange")
    GUICtrlSetOnEvent($button_go, "OnGo")
    ; Menu Events
    GUICtrlSetOnEvent($mi_go, "OnGo")
    GUICtrlSetOnEvent($mi_save, "OnSave")
    GUICtrlSetOnEvent($mi_pref, "OnPref")
    GUICtrlSetOnEvent($mi_clear,"OnClearAll")


    ; Show GUI
    GUISetState(@SW_SHOW)
EndFunc

Func TMStart()
    TMInit()
    PrefInit()

    While 1
        Sleep(800)
    WEnd
EndFunc

;;;;;;;;;;;;;;;;
;;   Events   ;;
;;;;;;;;;;;;;;;;

Func OnAppExit()
    ; TODO: Log all arrays before exiting.
    Exit
EndFunc

; Save input to ticket_struct, Clear out input field, fill with stored array
Func OnListChange()
    Local $ticket = GUICtrlRead($list_main)

    ; return if nothing is selected
    If $ticket == "" Then
        return
    EndIf

    ; If relevant, save the information from the last selected ticket and reset information
    If $LAST_TICKET_SELECTED Then
        ;_ArrayDisplay(ParseInput($input_main))
        SetTicketArray($LAST_TICKET_SELECTED, ParseInput($input_main))
    EndIf
    
    ; Enable input and button if input is disabled
    If GUICtrlGetState($input_main) == 144 Then     ;144 is the state when input_main is disabled... ($GUI_DISABLE = 128)
        GUICtrlSetState($input_main, $GUI_ENABLE)
        ; We can assume the button is disabled when the input is disabled
        GUICtrlSetState($button_go, $GUI_ENABLE)
    EndIf

    ; Clear input
    GUICtrlSetData($input_main, "")

    ; Fill input with stored information
    Local $cur_ticket_info = GetTicketArray($ticket)
    If $cur_ticket_info[0] > 0 Then
        Local $text = ""
        For $i = 1 To $cur_ticket_info[0]
            $text = $text & $cur_ticket_info[$i] & @CRLF
        Next
        GUICtrlSetData($input_main, $text)
    EndIf
    
    ; Keep track of last ticket
    $LAST_TICKET_SELECTED = $ticket
EndFunc

Func OnSave()
    ; Saving is irrelevant if input is disabled
    If GUICtrlGetState($input_main) <> 144 Then
        ; Save information for currently selected ticket before continuing.
        SetTicketArray(GUICtrlRead($list_main), ParseInput($input_main))
        Local $result[1] = [0]
        For $ticket in $ALL_TICKETS
            Local $array = GetTicketArray($ticket)
            If $array[0] > 0 Then
                $result[0] += 1
                _ArrayAdd($result, @CRLF & $ticket)
                _ArrayConcatenate($result, $array, 1)
            EndIf
        Next
        If $result[0] > 0 Then
            LogArray($result)
        EndIf
    EndIf
EndFunc

Func OnClearAll()
    If GUICtrlGetState($input_main) <> 144 Then
        For $ticket in $ALL_TICKETS
            Local $array = GetTicketArray($ticket)
            If $array[0] > 0 Then
                ClearTicketArray($ticket)
            EndIf
        Next
        GUICtrlSetData($input_main, "")
    EndIf
EndFunc

Func OnGo()
    OnSave()
    ProcessTickets()
EndFunc

Func OnPref()
    PrefOpen()
EndFunc
