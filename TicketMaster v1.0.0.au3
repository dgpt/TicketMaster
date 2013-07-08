#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>

#include "TMGUI.au3"
#include "TMUtils.au3"
#include "TMProcedures.au3"
#include "TMPrefs.au3"

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
3. Add to $ticket_struct_vars
4. Add to RouteArray

TODO:
- Create preferences GUI
- Start with automations
- Start with IE automation, provide usage with Chrome as well.


#CE

; Options...
Opt("GUICoordMode", 0) 	; coords are relative to the start of last control (upper left corner)
Opt("GUIOnEventMode", 1)  ; enable the OnEvent function notifications

;;;;;;;;;;;;;;;;;;;
;; Structs       ;;
;;;;;;;;;;;;;;;;;;;

; Main Struct setup. Contains all arrays used for tickets.
; Max length for arrays
Local Const $MAX_TICKET_INT = 128
Local Const $ticket_struct_vars = StringReplace("uint s99[%d];uint xfer[%d];uint nvm[%d];uint mo[%d];uint dp[%d];uint open[%d]", "%d", $MAX_TICKET_INT)
Global $ticket_struct = DllStructCreate($ticket_struct_vars)


;;;;;;;;;;;;;;;;;;;;;;
;; Ticket Constants ;;
;;;;;;;;;;;;;;;;;;;;;;

; Use these whenever you need to describe a ticket
Global Const $TICKET_99 = "99 Session Logout"
Global Const $TICKET_XFER = "Transfer"
Global Const $TICKET_NVM = "Nevermind"
Global Const $TICKET_MO = "Master Off"
Global Const $TICKET_DP = "DP"
Global Const $TICKET_OPEN = "Open Tickets"
; Constants listing all ticket types.
Global Const $ALL_TICKETS[6] = [$TICKET_99, $TICKET_XFER, $TICKET_NVM, $TICKET_MO, $TICKET_DP, $TICKET_OPEN]
Local Const $ALL_TICKETS_STRING = _ArrayToString($ALL_TICKETS)



; Start the application
TMStart()

; Loop through arrays, call proper ticket procedure
Func ProcessTickets()
    TicketInit()
EndFunc
