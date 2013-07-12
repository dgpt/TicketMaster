#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>

#include "TMGUI.au3"
#include "TMUtils.au3"
#include "TMProcedures.au3"
#include "TMPrefs.au3"

#CS
FOR OPTIMAL RESULTS:
Keep main iSupport page in the first tab spot
This script assumes that main iSupport page is first
and will switch to that page before creating a new ticket.

Most of the automation takes place in the background,
When creating a new ticket or finishing a ticket, however, it requires the window to be active.


Notes:
ARRAYS:
All arrays have a 1-based index. Position [0] contains the length of the array.

REGARDING NUMBERS:
All entered numbers have a max value of 4294967295. I will have to change this
when implementing tickets that take series of longer numbers or text.
But for most tickets, this shouldn't cause an issue and will keep memory
usage low without resorting to multidimensional arrays.

ADDING NEW TICKETS:
TicketMaster File
1. Make new Global Const TICKET variable
2. Add to $ALL_TICKETS array
3. Add to $ticket_struct_vars
Utils
4. Add to RouteArray
TMConfig.ini
5. Add 'link_' + var name = ticket link text
Prefs
6. Add var name to pref struct
TMProcedures
7. Add '_TicketType_' + var name High-Level Procedure


___________________________________________________________________________________
TODO:
- Create preferences GUI
- provide support for Chrome. (Future release, will have to build a new module)

TICKET CREATION:
- Gather up all errors with error code + store number. Display all errors at the end.
- Watch for 'error' isupport pages, report those with errors.

#CE

; Options...
Opt("GUICoordMode", 0) 	; coords are relative to the start of last control (upper left corner)
Opt("GUIOnEventMode", 1)  ; enable the OnEvent function notifications

;;;;;;;;;;;;;;;;;;;
;; Structs       ;;
;;;;;;;;;;;;;;;;;;;

; Main Struct setup. Contains all arrays used for tickets.
; Max length for arrays
Local Const $MAX_TICKET_INT = 90
Local Const $ticket_struct_vars = StringReplace("uint s99[%d]; uint xfer[%d]; uint nvm[%d]; uint mo[%d]; uint dp[%d]; uint open[%d]; uint tcu[%d]; uint gco[%d]; uint proc[%d]", "%d", $MAX_TICKET_INT)
Global $ticket_struct = DllStructCreate($ticket_struct_vars)
;DbgMsg("$ticket_struct size: " & DllStructGetSize($ticket_struct) & " bytes.")


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
Global Const $TICKET_TCU = "TC AD Unlock"
Global Const $TICKET_GCO = "Gear Card Offset"
Global const $TICKET_PROC = "Procedural Request"
; Constants listing all ticket types.
Global Const $ALL_TICKETS[9] = [$TICKET_99, $TICKET_XFER, $TICKET_NVM, $TICKET_MO, $TICKET_DP, $TICKET_TCU, $TICKET_GCO, $TICKET_PROC, $TICKET_OPEN]
Local Const $ALL_TICKETS_STRING = _ArrayToString($ALL_TICKETS)



; Start the application
TMStart()

; Loop through arrays, call proper ticket procedure
Func ProcessTickets()
    TicketInit()
    For $ticket In $ALL_TICKETS
        Local $array = GetTicketArray($ticket)
        For $i = 1 To $array[0]
            ; Make sure we are sending a 3-digit store number to avoid
            ; unwanted tickets being created.
            If StringRegExp($array[$i], "\d{3}") Then
                TicketCreate($array[$i], RouteArray($ticket))
            EndIf
        Next
    Next
    TicketExit()
EndFunc
