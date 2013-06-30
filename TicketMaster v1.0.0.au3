#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>

#include "TMGUI.au3"
#include "TMUtils.au3"
#include "TMStructUtils.au3"

#CS
Notes:
ARRAYS:
All arrays are 1-based index. Position [0] contains the length of the array.

REGARDING NUMBERS:
All entered numbers have a max value of 4294967295. I will have to change this
when implementing tickets that take series of longer numbers or text.
But for most tickets, this shouldn't cause an issue and will keep memory
usage low without resorting to multidimensional arrays.

ADDING NEW TICKETS:
1. Make new Global Const TICKET variable
2. Add to $ALL_TICKETS array
3. Add to $struct_vars
4. Add to RouteArray

TODO:

Future releases:
- Make multiline input
-- When switching ticket types on multiline, switch data contained in the ticket type
- Save multiline input to log file before starting ticket processes
- have preferences window to select location of log file

!!!- Start implementing preferences


#CE

; Options...
Opt("GUICoordMode", 0) 	; coords are relative to the start of last control (upper left corner)
Opt("GUIOnEventMode", 1)  ; enable the OnEvent function notifications

; Main Struct setup. Contains all arrays used for tickets.
Global Const $MAX_INDEX = 128
Local $struct_vars = StringReplace("uint s99[%d];uint xfer[%d];uint nvm[%d];uint mo[%d];uint dp[%d];uint open[%d]", "%d", $MAX_INDEX)
Global $ticket_struct = DllStructCreate($struct_vars)

; MsgBox(0, "", DllStructGetSize($ticket_struct))

; TICKET CONSTANTS
; Use these whenever you need to describe a ticket
Global Const $TICKET_99 = "99 Session Logout"
Global Const $TICKET_XFER = "Transfer"
Global Const $TICKET_NVM = "Nevermind"
Global Const $TICKET_MO = "Master Off"
Global Const $TICKET_DP = "DP"
Global Const $TICKET_OPEN = "Open Tickets"
; Constants listing all ticket types. Used mainly to populate list control 
Local Const $ALL_TICKETS[6] = [$TICKET_99, $TICKET_XFER, $TICKET_NVM, $TICKET_MO, $TICKET_DP, $TICKET_OPEN]
Local Const $ALL_TICKETS_STRING = _ArrayToString($ALL_TICKETS)

Global $LAST_TICKET_SELECTED = false


; Start the application
TMStart()


; EVENTS
Func OnAppExit()
    ; TODO: Log all arrays before exiting.
    Exit
EndFunc

Func OnListChange()
    Local $ticket = GUICtrlRead($list_main)

    ; return if nothing is selected
    If $ticket == "" Then
        return
    EndIf

    ; If relevant, save the information from the last selected ticket and reset information
    If $LAST_TICKET_SELECTED Then
        ;_ArrayDisplay(ParseInput($input_main))
        SetArray($ticket_struct, $LAST_TICKET_SELECTED, ParseInput($input_main))
    EndIf
    
    ; Enable input if it's disabled
    If GUICtrlGetState($input_main) == 144 Then     ;144 is the state when input_main is disabled... ($GUI_DISABLE = 128)
        GUICtrlSetState($input_main, $GUI_ENABLE)
    EndIf

    ; Clear input
    GUICtrlSetData($input_main, "")

    ; Fill input with stored information
    Local $cur_ticket_info = GetArray($ticket_struct, $ticket)
    ;_ArrayDisplay($cur_ticket_info)
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

