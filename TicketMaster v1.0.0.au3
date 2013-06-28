#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>

#include "TMGUI.au3"

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

Local Const $MAX_INDEX = 128
Local $struct_vars = StringReplace("int s99[%d];int open[%d];int xfer[%d]", "%d", $MAX_INDEX)
Global $ticket_struct = DllStructCreate($struct_vars)

; Holds string data for all tickets that show up in $main_list (seperate with |)
Global Const $TICKET_99 = "99 Session Logout"
Global Const $TICKET_XFER = "Transfer"
Global Const $TICKET_NVM = "Nevermind"
Global Const $TICKET_MO = "Master Off"
Global Const $TICKET_DP = "DP"
Global Const $TICKET_OPEN = "Open Tickets"
Local Const $ALL_TICKETS[6] = [$TICKET_99, $TICKET_XFER, $TICKET_NVM, $TICKET_MO, $TICKET_DP, $TICKET_OPEN]
Local Const $ALL_TICKETS_STRING = _ArrayToString($ALL_TICKETS)


TMStart()


; EVENTS
Func OnAppExit()
    Exit
EndFunc

Func OnListChange()
    Local $item = GUICtrlRead($list_main)
    If $item == "" Then
        return
    EndIf
    If GUICtrlGetState($input_main) == 144 Then     ;144 is the state when input_main is disabled... ($GUI_DISABLE = 128)
        GUICtrlSetState($input_main, $GUI_ENABLE)
    EndIf

EndFunc

; UTILS

