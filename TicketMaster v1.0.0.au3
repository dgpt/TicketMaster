#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>

#CS
Notes:


TODO:

Future releases:
- Make multiline input
-- When switching ticket types on multiline, switch data contained in the ticket type
- Save multiline input to log file before starting ticket processes
- have preferences window to select location of log file

#CE

; Options...
Opt("GUICoordMode", 0) 	; coords are relative to the start of last control (upper left corner)
Opt("GUIOnEventMode", 1)  ; enable the OnEvent function notifications

; Set arrays
Global $s99_array[1] = [0]
Global $open_array[1] = [0]
Global $xfer_array[1] = [0]
Global $nvm_array[1] = [0]
Global $masteroff_array[1] = [0]
Global $gs_array[1] = [0]
Global $gs_eid_array[1] = [0]
Global $ad_array[1] = [0]
Global $ad_eid_array[1] = [0]
Global $dp_array[1] = [0]

; Holds string data for all tickets that show up in $main_list (seperate with |)
Global Const $ALL_TICKETS = "99 Session Logout|Transfer|Nevermind|Master Off|DP|Open Tickets"

; Create GUI Components
Local Const $BUTTON_WIDTH = 50

Global $window_main = GUICreate("Ticket Master", 200, 250)
Global $input_main = GUICtrlCreateInput("", 10, 10, 70, 150, $ES_MULTILINE)
Global $list_main = GUICtrlCreateList("", 80, 0, 100, 150)
GUICtrlSetData(-1, $ALL_TICKETS)
Global $button_go = GUICtrlCreateButton("Go", 0, 155, $BUTTON_WIDTH)
Global $button_
GUISetState(@SW_SHOW)


; Bind Events!
GUISetOnEvent($GUI_EVENT_CLOSE, "AppExit")

While 1
   Sleep(800)
WEnd

Func AppExit()
    Exit
EndFunc

