Func TMInit()
    ; GUI Constants
    Local Const $WINDOW_WIDTH = 200, $WINDOW_HEIGHT = 250
    Local Const $BUTTON_WIDTH = 70, $BUTTON_HEIGHT = 40
    Local Const $LIST_WIDTH = 100, $LIST_HEIGHT = 165
    Local Const $INPUT_WIDTH = 70, $INPUT_HEIGHT = 215

    ; Create Window
    Global $window_main = GUICreate("Ticket Master", $WINDOW_WIDTH, $WINDOW_HEIGHT)

    ;Menus
    ;File
    Global $menu_file = GUICtrlCreateMenu("&File")
    Global $mi_save = GUICtrlCreateMenuItem("&Save", $menu_file)
    Global $mi_load = GUICtrlCreateMenuItem("&Load", $menu_file)

    ;Application
    Global $menu_app = GUICtrlCreateMenu("&Application")
    Global $mi_go = GUICtrlCreateMenuItem("&Go", $menu_app)
    Global $mi_clear = GUICtrlCreateMenuItem("Clear All Lists", $menu_app)
    GUICtrlCreateMenuItem("", $menu_app)        ; separator
    Global $mi_pref = GUICtrlCreateMenuItem("&Preferences", $menu_app)

    ;Help
    Global $menu_help = GUICtrlCreateMenu("&Help")

    ;Other components
    Global $list_main = GUICtrlCreateList("", 10, 10, $LIST_WIDTH, $LIST_HEIGHT)
    GUICtrlSetData($list_main, $ALL_TICKETS_STRING)
    Global $input_main = GUICtrlCreateInput("", 110, 0, $INPUT_WIDTH, $INPUT_HEIGHT, $ES_MULTILINE + $ES_WANTRETURN + $ES_AUTOVSCROLL)
    GUICtrlSetState($input_main, $GUI_DISABLE)  ; Disable input until a ticket category is selected
    Global $button_go = GUICtrlCreateButton("Go", -95, 175, $BUTTON_WIDTH, $BUTTON_HEIGHT)

    ; Bind Events!
    ;GUI Events
    GUISetOnEvent($GUI_EVENT_CLOSE, "OnAppExit")
    ;GUI Ctrl Events
    GUICtrlSetOnEvent($list_main, "OnListChange")


    ; Show GUI
    GUISetState(@SW_SHOW)
EndFunc

Func TMStart()
    TMInit()

    While 1
        Sleep(800)
    WEnd
EndFunc
