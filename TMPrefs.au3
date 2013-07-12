#CS
Holds Prefs UI and various related things.
#CE


; Need to declare pref_struct immediately so other functions can access it
;; Mainly so we don't have to inject pref_struct into GetPref.
; Preference struct variable names need to match names in the config file
Local Const $MAX_PREF_CHAR = 60
Local Const $pref_struct_vars = StringReplace("char log_path[200]; uint log_append; uint ie_attach; uint dialog_sleep_time; uint dialog_load_time; uint ticket_load_time; char link_s99[%d]; char link_xfer[%d]; char link_nvm[%d]; char link_mo[%d]; char link_dp[%d]; char link_tcu[%d]; char link_gco[%d]; char link_proc[%d]; char link_open", "%d", $MAX_PREF_CHAR)
Global $pref_struct = DllStructCreate($pref_struct_vars)
;DbgMsg("$pref_struct size: " & DllStructGetSize($pref_struct) & " bytes.")

Func PrefInit()
    Local Const $config_path = "TMConfig.ini"
    LoadPrefs($pref_struct, $config_path)
EndFunc

Func PrefOpen()
    ; UI Constants
    Local Const $WINDOW_WIDTH = 200, $WINDOW_HEIGHT = 200
    Local $window_pref = GUICreate("Preferences", $WINDOW_WIDTH, $WINDOW_HEIGHT, -1, -1, $WS_SYSMENU, -1, $window_main)
    GUISwitch($window_pref)

    ; Bind Events
    GUISetOnEvent($GUI_EVENT_CLOSE, "OnPrefExit")


    GUISetState(@SW_SHOWNORMAL)
EndFunc


;;;;;;;;;;;;;;;;;;;;;;;;;
;; Preference Events   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

Func OnPrefExit()
    GUIDelete()
    GUISwitch($window_main)
EndFunc


;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Preference Utilities ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

; Loop through sections in given INI file,
; Load all prefs.
;; IMPORTANT: Struct names must match section names
Func LoadPrefs(ByRef $struct, $config_path)
    Local $section_names = IniReadSectionNames($config_path)
    For $j = 1 To $section_names[0]
        Local $prefs = IniReadSection($config_path, $section_names[$j])
        For $i = 1 To $prefs[0][0]
            DllStructSetData($struct, $prefs[$i][0], $prefs[$i][1])
            If CheckError(@error, "LoadPrefs", _HandleStructError(@error)) Then
                return 0
            EndIf
        Next
    Next
EndFunc

; Easier way to get prefs from $pref_struct (also handles errors)
Func GetPref($pref)
    Local $result = DllStructGetData($pref_struct, $pref)
    If CheckError(@error, "GetPref", _HandleStructError(@error)) Then
        return 0
    EndIf
    return $result
EndFunc

