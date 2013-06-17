#include <Array.au3>
#include <GUIConstantsEx.au3>

; Options...
Opt("GUICoordMode", 0) 	; coords are relative to the start of last control (upper left corner)
Opt("GUIOnEventMode", 1)  ; enable the OnEvent function notifications

; Set global arrays
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

$main_window = GUICreate("Ticket Master", 170, 250)
$combo = GUICtrlCreateCombo("Select a ticket", 10, 10)
GUISetState(@SW_SHOW)

While 1
   Sleep(800)
WEnd
