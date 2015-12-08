;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Description
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
; Checks each platform for willpay and probable data. Hopefully it can eventually illuminate other problems at tote
;

;~~~~~~~~~~~~~~~~~~~~~
;Compile Options
;~~~~~~~~~~~~~~~~~~~~~
SetBatchLines -1 ;Go as fast as CPU will allow
The_ProjectName = Reg Repointer
The_VersionName = v0.0.1

#NoEnv ;No Enviornment variables
#NoTrayIcon ;Do not show a tray icon
#SingleInstance Off ;Allow multiple instances


;Dependencies
;#Include %A_ScriptDir%\Functions
;none

;Variables
A_LF := "`n" ;Newline

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
;PREP AND STARTUP
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

;~~~~~~~~~~~~~~~~~~~~~
;GUI
;~~~~~~~~~~~~~~~~~~~~~
Sb_BuildGUI()

;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
;MAIN PROGRAM STARTS HERE
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/
Return ;Do not run without user pressing any buttons

CheckButton:
GUI, Submit, NoHide
;always clear all existing retrieve value textboxes
Sb_ClearGUI()
Sb_GuiMessage("Working...")

;Copy Value from Users Input, remove leading/trailing spaces
UserInput_Machine = %MachineName%
;Grab DDS values from the remote machine
Value_DDS := Fn_ReadReg(UserInput_Machine,"SOFTWARE\TVG\DdsControl","Machine")
Value_DDS2 := Fn_ReadReg(UserInput_Machine,"SOFTWARE\TVG\DdsControl","BackupMachine")
If (ErrorLevel = 1) {
	;Show blank values
	Sb_ClearGUI()
	Sb_GuiMessage("Errors Encountered")
	Msgbox, There was an error reading the value, machine may be off or doesn't have those
} else {
	;Show retrieved values
	GuiControl, text, DDS, %Value_DDS%
	GuiControl, text, DDS2, %Value_DDS2%
	Sb_GuiMessage("Check Successful")
}
Return


ChangeButton:
;Note DDS and DDS2 Store values typed in by the User
Sb_GuiMessage("Working...")

GUI, Submit, NoHide
;Remove spaces from UserInput
DDS := StrReplace(DDS, " ", "")
DDS2 := StrReplace(DDS2, " ", "")
UserInput_Machine := StrReplace(MachineName, " ", "")

If (UserInput_Machine = "" || UserInput_Machine = " ") {
	Msgbox, You cannot against a blank machine name
	Return
}
TotalErrors := 0
;Only send if value is not blank
If (DDS != "") {
	Fn_ChangeReg(UserInput_Machine,"\SOFTWARE\TVG\DdsControl\","Machine",DDS)
}
TotalErrors += ErrorLevel
If (DDS2 != "") {
	Fn_ChangeReg(UserInput_Machine,"\SOFTWARE\TVG\DdsControl\","BackupMachine",DDS2)
}
TotalErrors += ErrorLevel

If (TotalErrors != 0) {
	Msgbox, % "There were " TotalErrors " Error(s) Encountered!"
	Sb_GuiMessage("Errors Encountered")
} else {
	Sb_GuiMessage("Change 100% successful")
}
Return



Fn_ChangeReg(para_machine,para_KeyLocation,para_Key,para_NewValue)
{
	;RegRead, Remote_Machine, \\%para_machine%:HKEY_LOCAL_MACHINE, SOFTWARE\TVG\IVR\STARTUP, IVRCallStatusServer

	;msgbox, % Remote_Machine
	RegWrite, REG_SZ, \\%para_machine%:HKEY_LOCAL_MACHINE%para_KeyLocation%, %para_Key%, %para_NewValue%

	;Returns 1 on Success or 0 on Fail
	Return % Errorlevel
}

Fn_ReadReg(para_Machine,para_KeyLoction,para_Key)
{
;RegRead, Remote_Machine, \\%Remote_Machine%:HKEY_LOCAL_MACHINE, SOFTWARE\TVG\IVR\STARTUP, IVRCallStatusServer
RegRead, ReturnValue, \\%para_Machine%:HKEY_LOCAL_MACHINE, %para_KeyLoction%, %para_Key%
Return % ReturnValue
}


;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; GUI
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

Sb_BuildGUI()
{
Global

/*
;first idea was to use a dropdownlist. Shelved
DDS_List := A_ScriptDir . "\MachineList.txt"
If (FileExist(Machine_List)) {
	Machine_Array := []
	Loop, Read, % Machine_List
	{
		Machine_Array[A_Index,"SystemName"] := Fn_QuickRegEx(A_LoopReadLine,"(\w+\d+)")
	}
	;Create small list of display options for dropdown selector
	DataFeed_List .= ShortName . "   " . SystemName . "|"
	;Add extra pipe to first item so it is the default selected by GUI
	If (A_Index = 1 && The_DefaultSystemName = "") {
	DataFeed_List .= "|"
	}
	If (makedefault) {
	DataFeed_List .= "|"
	}
}
*/


;Main Tab
Gui, Font, s13 w700, Arial
Gui, Add, text, x10 y40 r1, Machine
Gui, Add, Edit, r1 w580 vMachineName, VIAOPSIVR01
Gui, Add, text, r1, DDS Selection
Gui, Add, Edit, r1 w580 vDDS, ;blank
Gui, Add, text, r1, DDS Backup Selection
Gui, Add, Edit, r1 w580 vDDS2, ;blank

Gui, Font, ;Reset Font to normal
Gui, Add, Button, x380 y30 w100 h30 gCheckButton, Check
Gui, Add, Button, x480 y30 w100 h30 gChangeButton, Change

;Used for confirming success to user
Gui, Add, text, r1 x380 y10 w150 vMessageUser,

;Dropdown for type selection?
;Gui, Add, DropDownList, x2 y32 w200 vMachine_List, %DataFeed_List%

;Main View
Gui, Font, s19 w700, Arial ;Large Text
Gui, Add, Text, x10 y3 w100 +Right, %The_ProjectName%


;Set Version Number
Gui, Font, ;Reset Font to normal
Gui, Add, Text, x498 y3 w100 +Right, %The_VersionName%
GUI, Submit, NoHide



;Menu
Menu, FileMenu, Add, R&estart`tCtrl+R, Menu_File-Restart
Menu, FileMenu, Add, E&xit`tCtrl+Q, Menu_File-Quit
Menu, MenuBar, Add, &File, :FileMenu  ; Attach the sub-menu that was created above

Menu, HelpMenu, Add, &About, Menu_About
Menu, HelpMenu, Add, &Confluence`tCtrl+H, Menu_Confluence
Menu, MenuBar, Add, &Help, :HelpMenu

Gui, Menu, MenuBar

Gui, Show, w600 h240, % The_ProjectName
Return


;Menu Shortcuts
Menu_Confluence:
Run http://confluence.tvg.com/pages/viewpage.action?pageId=11468878
Return

Menu_About:
Msgbox, Checks selected SGR Datafile for up to date data.
Return

Menu_File-Restart:
Reload

Menu_File-Quit:
ExitApp
}





ShiftNotes:
Today:= %A_Now%
FormatTime, CurrentDateTime,, MMddyy
Run \\tvgops\pdxshares\wagerops\Daily Shift Notes\%CurrentDateTime%.xlsx
Return



Fn_GUI_UpdateProgress(para_Progress1, para_Progress2 = 0)
{
	;Calculate progress if two parameters input. otherwise set if only one entered
	If (para_Progress2 = 0)
	{
	GuiControl,, UpdateProgress, %para_Progress1%+
	}
	Else
	{
	para_Progress1 := (para_Progress1 / para_Progress2) * 100
	GuiControl,, UpdateProgress, %para_Progress1%
	}

}


DiableAllButtons()
{
GuiControl, disable, Update
}


EnableAllButtons()
{
GuiControl, enable, Update
}


EndGUI()
{
global

Gui, Destroy
}


GuiClose:
ExitApp


;/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\
; Functions
;\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/--\--/

Fn_QuickRegEx(para_Input,para_RegEx,para_ReturnValue := 1)
{
	RegExMatch(para_Input, para_RegEx, RE_Match)
	If (RE_Match%para_ReturnValue% != "")
	{
	ReturnValue := RE_Match%para_ReturnValue%
	Return %ReturnValue%
	}
Return "null"
}








;~~~~~~~~~~~~~~~~~~~~~
;Subroutines
;~~~~~~~~~~~~~~~~~~~~~

Sb_ClearGUI()
{
	GuiControl, text, DDS,
	GuiControl, text, DDS2,
	GuiControl, text, MessageUser,
	Sleep, 400 ;wait 400milliseconds so user can see there was a change
}

Sb_GuiMessage(para_message)
{
	GuiControl, text, MessageUser,
	Sleep, 400 ;wait 400milliseconds so user can see there was a change
	GuiControl, text, MessageUser, %para_message%
}


;~~~~~~~~~~~~~~~~~~~~~
;Timers
;~~~~~~~~~~~~~~~~~~~~~