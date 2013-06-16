#include <Array.au3>
#include <GUIConstantsEx.au3>

; KNOWN BUGS
; DP check does a Master Off ticket and freezes after the first one (waits for call script dialog)

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
Global $paused = False

GUICreate("Ticket Master", 170, 250)

$in_store = GUICtrlCreateInput("", 5, 10, 40, 20)
$in_extra = GUICtrlCreateInput("", 47, 10, 118, 20)
$button_add = GUICtrlCreateButton("Add", 405, 35, 40, 22)
$button_go = GUICtrlCreateButton("Go", 5, 35, 40, 22)
$button_show = GUICtrlCreateButton("Show", 45, 35, 40, 22)
$button_clear = GUICtrlCreateButton("Clear", 85, 35, 40, 22)
$button_pop = GUICtrlCreateButton("Pop", 125, 35, 40, 22)
$radio_99 = GUICtrlCreateRadio("1. 99 Session Logout", 5, 65)
$radio_open = GUICtrlCreateRadio("2. Open Tickets", 5, 85)
$radio_xfer = GUICtrlCreateRadio("3. Transfer", 5, 105)
$radio_nvm = GUICtrlCreateRadio("4. Nevermind", 5, 125)
$radio_masteroff = GUICtrlCreateRadio("5. Master Off", 5, 145)
$radio_gs = GUICtrlCreateRadio("6. GS Passwd", 5, 165)
$radio_ad = GUICtrlCreateRadio("7. AD Passwd", 5, 185)
$radio_dp = GUICtrlCreateRadio("8. DP", 5, 205)
GUICtrlSetState($radio_99, $GUI_CHECKED)

Local $accel_keys[4][2] = [["{ENTER}", $button_add], ["^{NUMPADDOT}", $button_show], ["^{NUMPAD0}", $button_go], ["{NUMPADSUB}", $button_pop]]
GUISetAccelerators($accel_keys)
HotKeySet("^{SPACE}", "GiveInputFocus")
HotKeySet("^{NUMPAD1}", "SelectRadio99")
HotKeySet("^{NUMPAD2}", "SelectRadioOpen")
HotKeySet("^{NUMPAD3}", "SelectRadioXfer")
HotKeySet("^{NUMPAD4}", "SelectRadioNvm")
HotKeySet("^{NUMPAD5}", "SelectRadioMO")
HotKeySet("^{NUMPAD6}", "SelectRadioGS")
HotKeySet("^{NUMPAD7}", "SelectRadioAD")
HotKeySet("^{NUMPAD8}", "SelectRadioDP")

GUISetState(@SW_SHOW)

Do
   $msg = GUIGetMsg()
   
   If $msg = $button_add Then
	  Add()
   EndIf
   
   If $msg = $button_go Then
	  If $s99_array[0] <> 0 Then
		 Go("99")
	  EndIf
	  If $xfer_array[0] <> 0 Then
		 Go("xfer")
	  EndIf
	  If $nvm_array[0] <> 0 Then
		 Go("nvm")
	  EndIf
	  If $masteroff_array[0] <> 0 Then
		 Go("masteroff")
	  EndIf
	  If $gs_array[0] <> 0 Then
		 Go("gs")
	  EndIf
	  If $ad_array[0] <> 0 Then
		 Go("ad")
	  EndIf
	  If $dp_array[0] <> 0 Then
		 Go("dp")
	  EndIf
	  If $open_array[0] <> 0 Then
		 Go("open")
	  EndIf
   EndIf
   
   If $msg = $button_show Then
	  ; Display contents of chosen array
	  _ArrayDisplay(CheckRadios())
   EndIf
   
   If $msg = $button_clear Then
	  ; Clear the array based on the radio button selected
	  ClearArrays()
   EndIf
   
   If $msg = $button_pop Then
	  PopArray()
   EndIf
   
Until $msg = $GUI_EVENT_CLOSE


Func CheckRadios()
   If BitAND(GUICtrlRead($radio_99), $GUI_CHECKED) Then
	  return $s99_array
   ElseIf BitAND(GUICtrlRead($radio_open), $GUI_CHECKED) Then
	  return $open_array
   ElseIf BitAND(GUICtrlRead($radio_xfer), $GUI_CHECKED) Then
	  return $xfer_array
   ElseIf BitAND(GUICtrlRead($radio_nvm), $GUI_CHECKED) Then
	  return $nvm_array
   ElseIf BitAND(GUICtrlRead($radio_masteroff), $GUI_CHECKED) Then
	  return $masteroff_array
   ElseIf BitAND(GUICtrlRead($radio_gs), $GUI_CHECKED) Then
	  ; Include memo field in show (transform into 2d array)
	  Local $dim1 = UBound($gs_array)
	  If $dim1 > 0 Then
		 Local $enum1 = 0
		 Local $temp[$dim1][2]
		 for $store in $gs_array
			$temp[$enum1][0] = $store
			$temp[$enum1][1] = $gs_eid_array[$enum1]
			$enum1 += 1
		 Next
		 return $temp
	  EndIf
   ElseIf BitAND(GUICtrlRead($radio_ad), $GUI_CHECKED) Then
	  ; include memo field in show (transform into 2d array)
	  Local $dim2 = UBound($ad_array)
	  Local $enum2 = 0
	  Local $temp[$dim2][2]
	  for $store in $ad_array
		 $temp[$enum2][0] = $store
		 $temp[$enum2][1] = $ad_eid_array[$enum2]
		 $enum2 += 1
	  Next
	  return $temp
   ElseIf BitAND(GUICtrlRead($radio_dp), $GUI_CHECKED) Then
	  return $dp_array
   Else
	  return 0
   EndIf
EndFunc

Func ClearArrays() 
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
   GUICtrlSetData($in_store, "")
   GUICtrlSetData($in_extra, "")
   GUICtrlSetState($in_store, $GUI_FOCUS)
EndFunc

Func PopArray()
   If BitAND(GUICtrlRead($radio_gs), $GUI_CHECKED) Then
	  ; Check if array has one element, if so set it and its dependent array to 0
	  If UBound($gs_array) = 1 Then
		 $gs_array[0] = 0
		 $gs_eid_array[0] = 0
	  Else
		 _ArrayPop($gs_array)
		 _ArrayPop($gs_eid_array)
	  EndIf
   ElseIf BitAND(GUICtrlRead($radio_ad), $GUI_CHECKED) Then
	  If UBound($ad_array) = 1 Then
		 $ad_array[0] = 0
		 $ad_eid_array[0] = 0
	  Else
		 _ArrayPop($ad_array)
		 _ArrayPop($ad_eid_array)
	  EndIf
   Else
	  _ArrayPop(CheckRadios())
   EndIf
EndFunc

Func Add()
   ;add whats' in $in_store to $storeArray if the first element is not 0, otherwise make the first element contents of $in_store
   ;clear contents of $in_store
   If WinGetState("Ticket Master") = 15 Then
	  Local $r = GUICtrlRead($in_store, 1)
	  Local $extra = GUICtrlRead($in_extra, 1)
	  If BitAND(GUICtrlRead($radio_99), $GUI_CHECKED) Then
		 If $s99_array[0] = 0 Then
			$s99_array[0] = $r
		 Else
			_ArrayAdd($s99_array, $r)
		 EndIf
	  ElseIf BitAND(GUICtrlRead($radio_open), $GUI_CHECKED) Then
		 If $open_array[0] = 0 Then
			$open_array[0] = $r
		 Else
			_ArrayAdd($open_array, $r)
		 EndIf
	  ElseIf BitAND(GUICtrlRead($radio_xfer), $GUI_CHECKED) Then
		 If $xfer_array[0] = 0 Then
			$xfer_array[0] = $r
		 Else
			_ArrayAdd($xfer_array, $r)
		 EndIf
	  ElseIf BitAND(GUICtrlRead($radio_nvm), $GUI_CHECKED) Then
		 If $nvm_array[0] = 0 Then
			$nvm_array[0] = $r
		 Else
			_ArrayAdd($nvm_array, $r)
		 EndIf
	  ElseIf BitAND(GUICtrlRead($radio_masteroff), $GUI_CHECKED) Then
		 If $masteroff_array[0] = 0 Then
			$masteroff_array[0] = $r
		 Else
			_ArrayAdd($masteroff_array, $r)
		 EndIf
	  ElseIf BitAND(GUICtrlRead($radio_gs), $GUI_CHECKED) Then
		 If $gs_array[0] = 0 Then
			$gs_array[0] = $r
			$gs_eid_array[0] = $extra
		 Else
			_ArrayAdd($gs_array, $r)
			_ArrayAdd($gs_eid_array, $extra)
		 EndIf
	  ElseIf BitAND(GUICtrlRead($radio_ad), $GUI_CHECKED) Then
		 If $ad_array[0] = 0 Then
			$ad_array[0] = $r
			$ad_eid_array[0] = $extra
		 Else
			_ArrayAdd($ad_array, $r)
			_ArrayAdd($ad_eid_array, $extra)
		 EndIf
	  ElseIf BitAND(GUICtrlRead($radio_dp), $GUI_CHECKED) Then
		 If $dp_array[0] = 0 Then
			$dp_array[0] = $r
		 Else
			_ArrayAdd($dp_array, $r)
		 EndIf
	  EndIf
	  GUICtrlSetData($in_store, "")
	  GUICtrlSetData($in_extra, "")
	  GUICtrlSetState($in_store, $GUI_FOCUS)
   EndIf
EndFunc

Func Go($operation)
   Local $progress = 0
   Local $progcount = 0
   Local $progpos = WinGetPos("Ticket Master")
   Local $progx = $progpos[0] - ($progpos[2] / 2)
   Local $progy = $progpos[1]
   Select
	  Case $operation = "99"
		 $progress = 0
		 ProgressOn("Processing Tickets", "99 - Session Logouts", "Store: ", $progx, $progy, 16)
		 For $s In $s99_array
			ProgressSet(($progcount / UBound($s99_array)) * 100, "Store: " & $s)
			Store99($s)
			$progcount += 1
			ProgressSet(($progcount / UBound($s99_array)) * 100, "Store: " & $s)
		 Next
		 Global $s99_array[1] = [0]
		 ProgressSet(100, "Complete!", "Complete")
		 Sleep(1000)
		 ProgressOff()
		 
	  Case $operation = "open"
		 $progress = 0
		 ProgressOn("Processing Tickets", "Opening Blank Tickets", "Store: ", $progx, $progy, 16)
		 For $s in $open_array
			ProgressSet(($progcount / UBound($open_array)) * 100, "Store: " & $s)
			OpenTicket($s)
			StartNewTicket()
			$progcount += 1
			ProgressSet(($progcount / UBound($open_array)) * 100, "Store: " & $s)
		 Next
		 Global $open_array[1] = [0]
		 ProgressSet(100, "Complete!", "Complete")
		 Sleep(1000)
		 ProgressOff()
	  
	  Case $operation = "xfer"
		 $progress = 0
		 ProgressOn("Processing Tickets", "Transfer Tickets", "Store: ", $progx, $progy, 16)
		 For $s in $xfer_array
			ProgressSet(($progcount / UBound($xfer_array)) * 100, "Store: " & $s)
			Xfer($s)
			$progcount += 1
			ProgressSet(($progcount / UBound($xfer_array)) * 100, "Store: " & $s)
		 Next
		 Global $xfer_array[1] = [0]
		 ProgressSet(100, "Complete!", "Complete")
		 Sleep(1000)
		 ProgressOff()
	  
	  Case $operation = "nvm"
		 $progress = 0
		 ProgressOn("Processing Tickets", "Nevermind Tickets", "Store: ", $progx, $progy, 16)
		 For $s in $nvm_array
			ProgressSet(($progcount / UBound($nvm_array)) * 100, "Store: " & $s)
			Nvm($s)
			$progcount += 1
			ProgressSet(($progcount / UBound($nvm_array)) * 100, "Store: " & $s)
		 Next
		 Global $nvm_array[1] = [0]
		 ProgressSet(100, "Complete!", "Complete")
		 Sleep(1000)
		 ProgressOff()
		 
	  Case $operation = "masteroff"
		 $progress = 0
		 ProgressOn("Processing Tickets", "Master Off Tickets", "Store: ", $progx, $progy, 16)
		 For $s in $masteroff_array
			ProgressSet(($progcount / UBound($masteroff_array)) * 100, "Store: " & $s)
			MasterOff($s)
			$progcount += 1
			ProgressSet(($progcount / UBound($masteroff_array)) * 100, "Store: " & $s)
		 Next
		 Global $masteroff_array[1] = [0]
		 ProgressSet(100, "Complete!", "Complete")
		 Sleep(1000)
		 ProgressOff()
		 
	  Case $operation = "gs"
		 $progress = 0
		 ProgressOn("Processing Tickets", "Green Screen Passwords", "Store: ", $progx, $progy, 16)
		 For $i = 0 To UBound($gs_array) - 1
			ProgressSet(($progcount / UBound($gs_array)) * 100, "Store: " & $gs_array[$i])
			GreenScreen($gs_array[$i], $gs_eid_array[$i])
			$progcount += 1
			ProgressSet(($progcount / UBound($gs_array)) * 100, "Store: " & $gs_array[$i])
		 Next
		 Global $gs_array[1] = [0]
		 Global $gs_eid_array[1] = [0]
		 ProgressSet(100, "Complete!", "Complete")
		 Sleep(1000)
		 ProgressOff()
	  
	  Case $operation = "ad"
		 $progress = 0
		 ProgressOn("Processing Tickets", "AD Passwords", "Store: ", $progx, $progy, 16)
		 For $i = 0 To UBound($ad_array) - 1
			ProgressSet(($progcount / UBound($ad_array)) * 100, "Store: " & $ad_array[$i])
			ActiveDir($ad_array[$i], $ad_eid_array[$i])
			$progcount += 1
			ProgressSet(($progcount / UBound($ad_array)) * 100, "Store: " & $ad_array[$i])
		 Next
		 Global $ad_array[1] = [0]
		 Global $ad_eid_array[1] = [0]
		 ProgressSet(100, "Complete!", "Complete")
		 Sleep(1000)
		 ProgressOff()
			
	  Case $operation = "dp"
		 $progress = 0
		 ProgressOn("Processing Tickets", "DP Tickets", "Store: ", $progx, $progy, 16)
		 For $s in $dp_array
			ProgressSet(($progcount / UBound($dp_array)) * 100, "Store: " & $s)
			DP($s)
			$progcount += 1
			ProgressSet(($progcount / UBound($dp_array)) * 100, "Store: " & $s)
		 Next
		 Global $dp_array[1] = [0]
		 ProgressSet(100, "Complete!", "Complete")
		 Sleep(1000)
		 ProgressOff()
		 
   EndSelect
   
EndFunc

;; Basic Ticket Procedures

Func OpenTicket($store)
   WinActivate("iSupport Help Desk - Windows Internet Explorer")
   Send("^n")
   WinWaitActive("Dialog - Select Customer - Windows Internet Explorer")
   Send($store)
   Sleep(1800)
   Send("{TAB 2}")
   Send("{ENTER}")
EndFunc

Func OpenTemplate($store)
   WinWaitActive("Incident Ticket for GC " & $store & " - Windows Internet Explorer")
   Sleep(1000)
   ; Select template icon
   MouseClick("left", 295, 120)
   WinWaitActive("Dialog - Use Incident Template - Windows Internet Explorer")
EndFunc

Func FocusTemplate()
   ; Click to focus window, short sleep to avoid zoom out while scrolling (movements can blend)
   MouseClick("left", 1126, 483)
   Sleep(300)
EndFunc

Func CloseTicket()
   ; To be used at the end of ticket creation (assumes window is active)
   ; Short sleep to allow isupport to keep up, Select Add'l Info
   Sleep(300)
   MouseClick("left", 229, 395)
   Sleep(300)
   ; Ticket Type
   MouseClick("left", 220, 430)
   ; Tier
   MouseClick("left", 162, 462)
   ; Mark closed
   MouseClick("left", 336, 180)
   Send("c")
   Send("{ENTER}")
   Sleep(300)
   ; Save and Close (change to MouseClick)
   MouseClick("left", 36, 115)
   Sleep(300)
EndFunc
   

Func StartNewTicket()
   Send("^{TAB}")
   WinActivate("iSupport Help Desk - Windows Internet Explorer")
EndFunc

Func CloseCallScript()
   ; Get rid of Call Script
   WinWaitActive("Call Script - Dialog - Windows Internet Explorer")
   WinActivate("Call Script - Dialog - Windows Internet Explorer")
   ; Click Cancel
   MouseClick("left", 1011, 604)
EndFunc

;; Specific Operations

Func Store99($store)
   OpenTicket($store)
   OpenTemplate($store)
   ; Select 99 template
   MouseClick("left", 855, 532)
   StartNewTicket()
EndFunc

Func Xfer($store)
   OpenTicket($store)
   OpenTemplate($store)
   ; Select xfer template
   MouseClick("left", 803, 482)
   StartNewTicket()
EndFunc

Func Nvm($store)
   OpenTicket($store)
   OpenTemplate($store)
   ; Select nvm template
   MouseClick("left", 800, 507)
   StartNewTicket()
EndFunc

Func MasterOff($store)
   OpenTicket($store)
   OpenTemplate($store)
   ; Click to focus window, short sleep to avoid zoom out while scrolling (movements can blend)
   ;MouseClick("left", 1126, 483)
   ;Sleep(300)
   ;MouseWheel("down", 1)
   ;Sleep(300)
   ; Select MO template
   MouseClick("left", 872, 584)
   StartNewTicket()
EndFunc

Func GreenScreen($store, $eid)
   OpenTicket($store)
   OpenTemplate($store)
   FocusTemplate()
   ; Scroll down to gs login template (Sleep is important)
   MouseWheel("down", 23)
   Sleep(300)
   ; Select GS password template
   MouseClick("left", 875, 573)
   ; Activate window, wait for template to load
   WinActivate("Incident Ticket for GC " & $store & " - Windows Internet Explorer")
   Sleep(2000)
   ; Click to focus inner text field, send enter, send employee id
   MouseClick("left", 389, 540)
   Send("{ENTER}")
   Send($eid)
   CloseTicket()
   StartNewTicket()
EndFunc

Func ActiveDir($store, $eid)
   OpenTicket($store)
   OpenTemplate($store)
   FocusTemplate()
   ; scroll to ad template
   MouseWheel("down", 14)
   Sleep(300)
   ; select AD template
   MouseClick("left", 915, 547)
   ; Activate window, wait for template to load
   WinActivate("Incident Ticket for GC " & $store & " - Windows Internet Explorer")
   Sleep(2000)
   ; Call script pops up here
   CloseCallScript()
   ; Click to focus inner text field, send enter, send employee id
   MouseClick("left", 389, 540)
   Send("{ENTER}")
   Send($eid)
   CloseTicket()
   StartNewTicket()
EndFunc
   
   

Func DP($store)
   OpenTicket($store)
   OpenTemplate($store)
   ; Select DP template
   MouseClick("left", 818, 583)
   CloseCallScript()
   StartNewTicket()
EndFunc


; Utility Functions
;~ ; Mostly used for Radio Button Select hotkeys (ctrl+numpad1-8)
Func GiveInputFocus()
   WinActivate("Ticket Master")
   GUICtrlSetState($in_store, $GUI_FOCUS)
EndFunc

Func SelectRadio99()
   GUICtrlSetState($radio_99, $GUI_CHECKED)
EndFunc

Func SelectRadioOpen()
   GUICtrlSetState($radio_open, $GUI_CHECKED)
EndFunc

Func SelectRadioXfer()
   GUICtrlSetState($radio_xfer, $GUI_CHECKED)
EndFunc

Func SelectRadioNvm()
   GUICtrlSetState($radio_nvm, $GUI_CHECKED)
EndFunc

Func SelectRadioMO()
   GUICtrlSetState($radio_masteroff, $GUI_CHECKED)
EndFunc

Func SelectRadioGS()
   GUICtrlSetState($radio_gs, $GUI_CHECKED)
EndFunc

Func SelectRadioAD()
   GUICtrlSetState($radio_ad, $GUI_CHECKED)
EndFunc

Func SelectRadioDP()
   GUICtrlSetState($radio_dp, $GUI_CHECKED)
EndFunc