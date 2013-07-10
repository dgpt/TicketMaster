#CS
Holds Prefs UI and various related things.
#CE


; Need to declare pref_struct immediately so other functions can access it
;; Mainly so we don't have to inject pref_struct into GetPref.
; Preference struct variable names need to match names in the config file
; Hard-coding array lengths for now... Change it if necessary.
Local Const $pref_struct_vars = "char log_path[255]; uint log_append; uint ie_attach; uint dialog_sleep_time;"
Global $pref_struct = DllStructCreate($pref_struct_vars)

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
            If @error Then
                MsgBox(0, "", "Error in LoadPreferences. error: " & _HandleStructError(@error))
                return 0
            EndIf
        Next
    Next
EndFunc

; Easier way to get prefs from $pref_struct (also handles errors)
Func GetPref($pref)
    Local $result = DllStructGetData($pref_struct, $pref)
    If @error Then
        MsgBox(0, "", "Error in GetPreference. error: " & _HandleStructError(@error))
        return 0
    EndIf
    return $result
EndFunc

