;------------------------------------------------------------------------------------------
; ahk settings
;------------------------------------------------------------------------------------------
#Persistent
#MaxThreadsPerHotkey 2 ;we need that for NumpadSub; without at least 2 threads it won't be able to interupt itself to switch modes while the select mode is scanning for the char selection screen
#SingleInstance Force
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

global scriptName := SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", False, -1) -1)

gosub InitMenu
SetTimer, CheckMode, 1000

global gInQueuePlayed := false
SetTimer, WatchInQueue, 3663
WatchInQueue:

	if(global Mode == 1)
	{
		if(global gInQueue == true)
		{
			if(gCurrentMenuItem.name == "main_menu")
			{
				SoundPlay, % A_WorkingDir . "\soundfiles\sound-notification6_de.mp3"

				if(global gInQueuePlayed == false)
				{
					global gInQueuePlayed := true
					PlayUtterance("server_full_waiting_in_queue")
					Sleep, 3000
				}

				tValue := true

				tRGBColor := GetColorAtUiPos(9799, 450)
				if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
				{
					;tValue := true
				}
				else
				{
					tValue := false
				}

				tRGBColor := GetColorAtUiPos(10194, 450)
				if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
				{
					;tValue := true
				}
				else
				{
					tValue := false
				}

				tRGBColor := GetColorAtUiPos(445, 450)
				if (IsColorRange(tRGBColor.r, 0) = true and IsColorRange(tRGBColor.g, 20) = true and IsColorRange(tRGBColor.b, 0) = true)
				{
					;tValue := true
				}
				else
				{
					tValue := false
				}

				if(tValue == false)
				{
					global gInQueue := false
					global gInQueuePlayed := false
					gosub InitMenu

					sleep, 2000
					InitLogin()
				}
			}
		}
	}

return

;------------------------------------------------------------------------------------------
; globals
;------------------------------------------------------------------------------------------
global gManualOverride := false

global gCurrentMenuItem
global gMainMenu

global gNumberOfCharsOnCurrentRealm := -1
global gCharUIPositions
global gEnterCharacterNameFlag := false
global gDeleteCharacterNameFlag := false

global gIgnoreKeyPress := false

global gIsInitializing
global gIsChecking

global tPopupClosed

global Mode := -1
global gInQueue := false

SwitchToMode_1()


;------------------------------------------------------------------------------------------
;generic class for menu entries
;------------------------------------------------------------------------------------------
class baseMenuEntryObject
{
    name := "generic Name"
    type := ""
    parent := ""
    p := ""
    n := ""
    childs := []

    onSelect()
    {
		if (this.childs not or this.childs.MaxIndex() < 1)
		{
			PlayUtterance(this.name)
			if(this.type != "")
			{
				tSleepTime := StrLen(this.type) * 220
				Sleep, %tSleepTime%
				PlayUtterance(this.type)
			}
			return
		}
		this.childs[1].onEnter()
    }

    onEnter()
    {
		gCurrentMenuItem := this
		PlayUtterance(this.name)
			if(this.type != "")
			{
				tSleepTime := StrLen(this.type) * 220
				Sleep, %tSleepTime%
				PlayUtterance(this.type)
			}
    }

	onAction()
	{
		;MsgBox % this.name " generic"
	}
}


;------------------------------------------------------------------------------------------
; general keybinds, subs, functions
;------------------------------------------------------------------------------------------
!Esc::
	PlayUtterance("script_exited")
	sleep 1000
	ExitApp
return

;------------------------------------------------------------------------------------------
!f1::
	Thread, Interrupt, 0

	gManualOverride := true

	if(Mode = 1 or Mode = -1)
	{
		SwitchToMode0()
	}
	else if(Mode = 0)
	{
		SwitchToMode1()
		InitLogin()
	}
return

;------------------------------------------------------------------------------------------
CheckMode:
	if(gIsChecking = true)
	{
		return
	}

	gIsChecking := true

	if(gManualOverride = true)
	{
		return
	}

	if(gIsInitializing = true)
	{
		return
	}

	if(IsWoWWindowFocus() != true and Mode != -1)
	{
		SwitchToMode_1()
	}
	else
	{
		if(IsIngame() = true and Mode != 0)
		{
			SwitchToMode0()
		}
		else if(Mode != 1 and IsGlue() = true)
		{
			SwitchToMode1()
			if(gIsInitializing != true)
			{
				InitLogin()
			}
		}
		else if(Mode = 0 and IsIngame() != true and IsGlue() != true)
		{
			SwitchToMode_1()
		}
	}

	gIsChecking := false
return

;------------------------------------------------------------------------------------------
AcceptContract()
{
	tmp := UiToScreenNEW(9999, 195)
	MouseMove, tmp.X, tmp.Y, 0
	sleep, 2000
	Loop 5
		Click, WheelDown

	sleep, 1000
	ty := 439
	Loop, 34
	{
		tmp := UiToScreenNEW(9950, ty)
		MouseMove, tmp.X, tmp.Y, 0
		WaitForX(1, 200)
		Send {Click}
		ty := ty + 3
	}

}

;------------------------------------------------------------------------------------------
InitLogin()
{
	gIsInitializing := true

	StartOver:

	WaitForX(4, 500)
	if(IsOutdatedAddonsWarning() = true)
	{
		tmpScreen := UiToScreenNEW(740,410)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 1000
		tmpScreen := UiToScreenNEW(640,440)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
	}
	WaitForX(4, 500)


	if(IsOutdatedAddonsWarning() = true)
	{
		tmpScreen := UiToScreenNEW(740,410)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 1000
		tmpScreen := UiToScreenNEW(640,440)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
	}
	if(IsContract() = true)
	{
		AcceptContract()
	}

	if(IsRealmQueue() == true)
	{
		gosub InitQueueMenu
		return
	}

	if(IsCharSelectionScreen() = true)
	{
		WaitForX(4, 500)

		if(IsOutdatedAddonsWarning() = true)
		{
			tmpScreen := UiToScreenNEW(740,410)
			MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
			Send {Click}
			Sleep, 1000
			tmpScreen := UiToScreenNEW(640,440)
			MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
			Send {Click}
		}
		if(IsContract() = true)
		{
			AcceptContract()
		}

		if(IsDeleteCharPopup() = true)
		{
			tmpScreen := UiToScreenNEW(10195, 437)
			MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
			Send {Click}
		}

		tTimeout := 0
		while(IsCharSelectionScreen() = true and (Is11Popup() = true or Is12Popup() = true))
		{
			gosub CheckMode
			if(Mode != 1)
			{
				return
			}

			ClosePopUps()

			tTimeout := tTimeout + 1
			WaitForX(1, 500)
			if(tTimeout > 60)
			{
				PlayUtterance("fail_connection_restart")
				sleep 2000
				gIgnoreKeyPress := false
				SwitchToMode_1()
				Pause
				return
			}
		}
		if(IsContract() = true)
		{
			AcceptContract()
		}

		gosub CheckMode
		if(Mode != 1)
		{
			return
		}

		UpdateCharacterMenu()

		gosub CheckMode
		if(Mode != 1)
		{
			return
		}

		gCurrentMenuItem := gMainMenu
		gMainMenu.onEnter()
	}
	else if(IsLoginScreen() = true)
	{
		tPopupClosed := false

		tTimeout := 0
		while(IsLoginScreen() = true)
		{
			gosub CheckMode
			if(Mode != 1)
			{
				return
			}

			tTimeout := tTimeout + 1
			WaitForX(1, 500)
			if(tTimeout > 120)
			{
				PlayUtterance("fail_connection_restart")
				sleep 2000
				gIgnoreKeyPress := false
				SwitchToMode_1()
				Pause
			return
			}


			if(IsLoginScreenInitialStart() != true)
			{
				ClosePopUps()

				if(IsReconnect() = true)
				{
					;click on reconnect
					;MsgBox Reconnect
					tPopupClosed := true
					tmpScreen := UiToScreenNEW(9917, 441)
					MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
					Send {Click}
				}
			}
		}
	}
	else if(IsRealmSelectionScreen() = true)
	{
		tmpScreen := UiToScreenNEW(-403, 606)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click} ;cancel

		tTimeout := 0
		while(IsRealmSelectionScreen() = true)
		{
			gosub CheckMode
			if(Mode != 1)
			{
				return
			}

			tTimeout := tTimeout + 1
			WaitForX(1, 500)
			if(tTimeout > 60)
			{
				PlayUtterance("fail_connection_restart")
				sleep 2000
				gIgnoreKeyPress := false
				SwitchToMode_1()
				Pause
			return
			}
		}
	}
	else if(IsCharCreationScreen() = true)
	{
		tmpScreen := UiToScreenNEW(-160, 749)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click} ;back

		tTimeout := 0
		while(IsCharCreationScreen() = true)
		{
			gosub CheckMode
			if(Mode != 1)
			{
				return
			}

			tTimeout := tTimeout + 1
			WaitForX(1, 500)
			if(tTimeout > 60)
			{
				PlayUtterance("fail_connection_restart")
				sleep 2000
				gIgnoreKeyPress := false
				SwitchToMode_1()
				Pause
			return
			}
		}
	}
	else if(IsRealmQueue() == true)
	{
		gosub InitQueueMenu
		return
	}

	if(IsCharSelectionScreen() != true)
	{
		if(IsRealmQueue() == true)
		{
			gosub InitQueueMenu
			return
		}
		else
		{
			gosub CheckMode
			if(Mode != 1)
			{
				return
			}
			goto, StartOver
			;InitLogin()
		}
	}
	else if(gNumberOfCharsOnCurrentRealm = -1)
	{
		gosub CheckMode
		if(Mode != 1)
		{
			return
		}
		UpdateCharacterMenu()

		gosub CheckMode
		if(Mode != 1)
		{
			return
		}

		gCurrentMenuItem := gMainMenu
		gMainMenu.onEnter()
	}
	gIsInitializing := false
}

;------------------------------------------------------------------------------------------
ClosePopUps()
{
	if(Is11Popup() = true and tPopupClosed != true)
	{
		;click 1 line 1 button popup away
		;MsgBox 1L 1B
		tPopupClosed := true
		tmpScreen := UiToScreenNEW(9915, 397)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 200
	}

	if(Is21Popup() = true and tPopupClosed != true)
	{
		;click 2 lines 1 button popup away
		;MsgBox 2L 1B
		tPopupClosed := true
		tmpScreen := UiToScreenNEW(9915, 405)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 200
	}

	if(Is12Popup() = true and tPopupClosed != true)
	{
		;click 1 line 2 buttons popup away
		;MsgBox 1L 2B
		tPopupClosed := true
		tmpScreen := UiToScreenNEW(10196, 397)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 200
	}

	if(Is22Popup() = true and tPopupClosed != true)
	{
		;click 2 lines 2 buttons popup away (right button)
		;MsgBox 2L 2B
		tPopupClosed := true
		tmpScreen := UiToScreenNEW(10196, 405)
		MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
		Send {Click}
		Sleep, 200
	}
}

;------------------------------------------------------------------------------------------
InitQueueMenu:
	if(gMainMenu.childs[1].name != "switch_server")
	{
		LoadData()

		global gMainMenuBackup := gMainMenu


		global gMainMenu := new baseMenuEntryObject
		gMainMenu.name := "main_menu"
		gMainMenu.parent := ""
		gMainMenu.childs := []


		;MsgBox % gMainMenuBackup.childs[4].name

		;menu item 1
		tMainItemN := 1
		gMainMenu.childs[tMainItemN] := gMainMenuBackup.childs[4]
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "switch_server"
		UpdateChilds(gMainMenu.childs[1])

		UpdateChilds(gMainMenu)

		gCurrentMenuItem := gMainMenu
		gMainMenu.onEnter()
	}

	gIgnoreKeyPress := false
return

;------------------------------------------------------------------------------------------
InitMenu:
	global gInQueue == false
	global gCharUIPositions := {1:{x:-45,y:106},2:{x:-45,y:162},3:{x:-45,y:218},4:{x:-45,y:274},5:{x:-45,y:330},6:{x:-45,y:386},7:{x:-45,y:442},8:{x:-45,y:498},9:{x:-45,y:554},10:{x:-45,y:610}}

	global tRealmLangs := {1:{name:"USA_West",x:450,y:636},2:{name:"USA_East",x:9827,y:636},3:{name:"Oceanic",x:9899,y:636}}

	global tServerNames := {}
	;west
	tServerNames[1] := {1:{name:"Angerforge",x:9795,y:192,type:"pvp"},2:{name:"Atiesh",x:9795,y:212,type:"pve"},3:{name:"Azursong",x:9795,y:232,type:"pve"},4:{name:"Grobbulus",x:9795,y:252,type:"rp_pvp"},5:{name:"Myzrael",x:9795,y:272,type:"pve"},6:{name:"Old_Blanchy",x:9795,y:292,type:"pve"},7:{name:"Skyfury",x:9795,y:312,type:"pvp"},8:{name:"Whitemane",x:9795,y:332,type:"pvp"}}
	;east
	tServerNames[2] := {1:{name:"Ashkandi",x:9795,y:192,type:"pve"},2:{name:"Benediction",x:9795,y:212,type:"pvp"},3:{name:"Bloodsail_Buccaneers",x:9795,y:232,type:"rp_pve"},4:{name:"Earthfury",x:9795,y:252,type:"pvp"},5:{name:"Eranikus",x:9795,y:272,type:"pvp"},6:{name:"Faerlina",x:9795,y:292,type:"pvp"},7:{name:"Maladath",x:9795,y:312,type:"pve"},8:{name:"Mankrik",x:9795,y:332,type:"pve"},9:{name:"Pagle",x:9795,y:352,type:"pve"},10:{name:"Sulfuras",x:9795,y:372,type:"pvp"},11:{name:"Westfall",x:9795,y:392,type:"pve"},12:{name:"Windseeker",x:9795,y:412,type:"pve"}}
	;oceanic
	tServerNames[3] := {1:{name:"Argual",x:9795,y:192,type:"pvp"},2:{name:"Remulos",x:9795,y:212,type:"pve"},3:{name:"Yojamba",x:9795,y:232,type:"pvp"}}

	global tGenders := {1:{name:"male",x:112,y:520},2:{name:"female",x:156,y:520}}
	global tRaces := {}
	tRaces[1] := {name:"human",x:85,y:85,classes:{1:"warrior",2:"paladin",3:"NV",4:"rogue",5:"priest",6:"deathknight",7:"NV",8:"mage",9:"warlock",10:"NV"}}
	tRaces[2] := {name:"dwarf",x:85,y:145,classes:{1:"warrior",2:"paladin",3:"hunter",4:"rogue",5:"priest",6:"deathknight",7:"NV",8:"NV",9:"NV",10:"NV"}}
	tRaces[3] := {name:"nightelf",x:85,y:205,classes:{1:"warrior",2:"NV",3:"hunter",4:"rogue",5:"priest",6:"deathknight",7:"NV",8:"NV",9:"NV",10:"druid"}}
	tRaces[4] := {name:"gnome",x:85,y:265,classes:{1:"warrior",2:"NV",3:"NV",4:"rogue",5:"NV",6:"deathknight",7:"NV",8:"mage",9:"warlock",10:"NV"}}
	tRaces[5] := {name:"draenei",x:85,y:315,classes:{1:"warrior",2:"paladin",3:"hunter",4:"NV",5:"priest",6:"deathknight",7:"shaman",8:"mage",9:"NV",10:"NV"}}
	tRaces[6] := {name:"orc",x:185,y:85,classes:{1:"warrior",2:"NV",3:"hunter",4:"rogue",5:"NV",6:"deathknight",7:"shaman",8:"NV",9:"warlock",10:"NV"}}
	tRaces[7] := {name:"undead",x:185,y:145,classes:{1:"warrior",2:"NV",3:"NV",4:"rogue",5:"priest",6:"deathknight",7:"NV",8:"mage",9:"warlock",10:"NV"}}
	tRaces[8] := {name:"tauren",x:185,y:205,classes:{1:"warrior",2:"NV",3:"hunter",4:"NV",5:"NV",6:"deathknight",7:"shaman",8:"NV",9:"NV",10:"druid"}}
	tRaces[9] := {name:"troll",x:185,y:265,classes:{1:"warrior",2:"NV",3:"hunter",4:"rogue",5:"priest",6:"deathknight",7:"shaman",8:"mage",9:"NV",10:"NV"}}
	tRaces[10] := {name:"bloodelf",x:185,y:315,classes:{1:"NV",2:"paladin",3:"hunter",4:"rogue",5:"priest",6:"deathknight",7:"NV",8:"mage",9:"warlock",10:"NV"}}

	LoadData()

	;build the audio menu
	;main
	gMainMenu := new baseMenuEntryObject
	gMainMenu.name := "main_menu"
	gMainMenu.parent := ""
	gMainMenu.childs := []

		;menu item 1
		tMainItemN := 1
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "select_char"
		;UpdateCharacterMenu()

		;menu item 2
		tMainItemN := 2
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "login_with_selected_char"
		gMainMenuchilds2Action(this){
			tRGBColor := GetColorAtUiPos(9918, 705)
			if (IsColorRange(tRGBColor.r, 139) = true and IsColorRange(tRGBColor.g, 139) = true and IsColorRange(tRGBColor.b, 139) = true)
			{
				gMainMenu.childs[1].onEnter()
			}
			else
			{
				tmp := UiToScreenNEW(9918, 700)
				MouseMove, tmp.X, tmp.Y, 0
				Send {Click}
			}
		}
		gMainMenu.childs[tMainItemN].onAction := Func("gMainMenuchilds2Action").Bind(gMainMenu.childs[tMainItemN])

		;menu item 3
		tMainItemN := 3
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "create_char"
		gMainMenu.childs[tMainItemN].childs := []
			Loop, 2
			{
				tGenderNumber := A_Index
				gMainMenu.childs[tMainItemN].childs[tGenderNumber] := new baseMenuEntryObject
				gMainMenu.childs[tMainItemN].childs[tGenderNumber].parent := gMainMenu.childs[tMainItemN]
				gMainMenu.childs[tMainItemN].childs[tGenderNumber].name := tGenders[tGenderNumber].name
				gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs := []
				Loop % tRaces.MaxIndex()
				{
					tRaceNumber := A_Index
					gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber] := new baseMenuEntryObject
					gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].parent := gMainMenu.childs[tMainItemN].childs[tGenderNumber]
					gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].name := tRaces[tRaceNumber].name
					gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs := []
					Loop % tRaces[tRaceNumber].classes.MaxIndex()
					{
						tClassNumber := A_Index
						gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber] := new baseMenuEntryObject
						gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber].parent := gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber]
						gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber].name := tRaces[tRaceNumber].classes[tClassNumber]
if(tRaces[tRaceNumber].classes[tClassNumber] != "NV")
{
						gMainMenuchildsGenericCreateCharAction(this, genderNumber, raceNumber, classNumber)
						{
							gNumberOfCharsOnCurrentRealm := GetNumberOfChars()

							if(gNumberOfCharsOnCurrentRealm < 9)
							{
								gIgnoreKeyPress := true
								tmp := UiToScreenNEW(-230, 616)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}

								;wait for create screen
								tTimeout := 0
								while(IsCharCreationScreen() != true)
								{
									gosub CheckMode
									if(Mode != 1)
									{
										return
									}

									tTimeout := tTimeout + 1
									WaitForX(1, 500)
									if(tTimeout > 60)
									{
										PlayUtterance("fail_connection_restart")
										sleep 2000
										gIgnoreKeyPress := false
										SwitchToMode_1()
										Pause
									return
									}
								}

								tmp := UiToScreenNEW(tRaces[raceNumber].x, tRaces[raceNumber].y)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
								WaitForX(2, 500)

								tClassPositions := {1:{x:80,y:465},2:{x:135,y:465},3:{x:180,y:465},4:{x:80,y:515},5:{x:135,y:515},6:{x:180,y:515}}
								tmp := UiToScreenNEW(tClassPositions[classNumber].x, tClassPositions[classNumber].y)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
								WaitForX(2, 500)

								tmp := UiToScreenNEW(tGenders[genderNumber].x, tGenders[genderNumber].y)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
								WaitForX(2, 500)

								;random style
								tmp := UiToScreenNEW(90, 737)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}

								;enter char name and press enter or esc to abort
								gEnterCharacterNameFlag := true

								PlayUtterance("enter_name_press_enter_or_esc")

								gIgnoreKeyPress := false
							}
							else
							{
								PlayUtterance("max_chars_on_server")
							}
							gIgnoreKeyPress := false

						}
						gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber].onAction := Func("gMainMenuchildsGenericCreateCharAction").Bind(gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber].childs[tClassNumber], tGenderNumber, tRaceNumber, tClassNumber)
}
					}
					UpdateChilds(gMainMenu.childs[tMainItemN].childs[tGenderNumber].childs[tRaceNumber])
				}
				UpdateChilds(gMainMenu.childs[tMainItemN].childs[tGenderNumber])
			}
			;we need to run the helper UpdateChilds once for every new sub menu, to set up prev/next menu item for all menu items on the given menu level
			UpdateChilds(gMainMenu.childs[tMainItemN])

		;menu item 4
		tMainItemN := 4
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "switch_server"
		gMainMenu.childs[tMainItemN].childs := []
			Loop % tRealmLangs.MaxIndex()
			{
				tLangNumber := A_Index
				gMainMenu.childs[tMainItemN].childs[tLangNumber] := new baseMenuEntryObject
				gMainMenu.childs[tMainItemN].childs[tLangNumber].parent := gMainMenu.childs[tMainItemN]
				gMainMenu.childs[tMainItemN].childs[tLangNumber].name := tRealmLangs[tLangNumber].name
				gMainMenu.childs[tMainItemN].childs[tLangNumber].type := tRealmLangs[tLangNumber].type
				;if(tLangNumber = 2)
				;{
				gMainMenu.childs[tMainItemN].childs[tLangNumber].childs := []
					Loop % tServerNames[tLangNumber].MaxIndex()
					{
						tRealmNumber := A_Index
						gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber] := new baseMenuEntryObject
						gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber].parent := gMainMenu.childs[tMainItemN].childs[tLangNumber ]
						gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber].name := tServerNames[tLangNumber][tRealmNumber].name
						gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber].type := tServerNames[tLangNumber][tRealmNumber].type
						gMainMenuchilds4ChildsXChildsYAction(this, langNumber, serverNumber)
						{
							gIgnoreKeyPress := true

							PlayUtterance("switching_to_server")
							sleep 1500


							if(IsRealmQueue() == true)
							{
								;from queue
								;click on "select realm"
								tmp := UiToScreenNEW(10194, 450)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}

								;wait for realm selection screen
								tTimeout := 0
								while(IsRealmSelectionScreen() != true)
								{
									gosub CheckMode
									if(Mode != 1)
									{
										return
									}

									tTimeout := tTimeout + 1
									WaitForX(1, 500)
									if(tTimeout > 60)
									{
										PlayUtterance("fail_connection_restart")
										sleep 2000
										gIgnoreKeyPress := false
										SwitchToMode_1()
										Pause
									return
									}
								}
							}
							else
							{
								;from css
								;test if on char selection screen
								if(IsCharSelectionScreen() != true)
								{
									;if not > init to char sel
									;Send {Esc}
									InitLogin()
								}

								;click on "select realm"
								tmp := UiToScreenNEW(-191, 51)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}

								;wait for realm selection screen
								tTimeout := 0
								while(IsRealmSelectionScreen() != true)
								{
									gosub CheckMode
									if(Mode != 1)
									{
										return
									}

									tTimeout := tTimeout + 1
									WaitForX(1, 500)
									if(tTimeout > 60)
									{
										PlayUtterance("fail_connection_restart")
										sleep 2000
										gIgnoreKeyPress := false
										SwitchToMode_1()
										Pause
									return
									}
								}
							}


							;click on lang tab
							tmp := UiToScreenNEW(tRealmLangs[langNumber].x, tRealmLangs[langNumber].y)
							MouseMove, tmp.X, tmp.Y, 0
							Send {Click}
							WaitForX(1, 500)

							;click on sort by type
							tmp := UiToScreenNEW(9985, 168)
							MouseMove, tmp.X, tmp.Y, 0
							Send {Click}
							WaitForX(1, 500)

							;click on sort by name
							tmp := UiToScreenNEW(9735, 168)
							MouseMove, tmp.X, tmp.Y, 0
							Send {Click}
							WaitForX(1, 500)

							if(IsRealmListScrollbar() == true)
							{
								;click on server with scrollable list
								tmp := UiToScreenNEW(9735, 368)
								MouseMove, tmp.X, tmp.Y, 0
								WaitForX(1, 500)

								Loop % (4)
								{
									Loop % (20)
									{
										Click, WheelUp
										Sleep, 30
									}
									WaitForX(1, 20)
								}


								tNumberOfFullPages := (Ceil(ObjMaxIndex(tServerNames[langNumber]) / 17) - 1)
								tServerOnPageNumber := (Ceil(serverNumber / 17))

								tEntryNumberInList := 0
								tNumberOfDownEntries := 0
								if(tServerOnPageNumber > tNumberOfFullPages)
								{
									tNumberOfDownEntries := ((tServerOnPageNumber - 2) * 17) + (serverNumber - (tNumberOfFullPages * 17))

									tEntryNumberInList := 17 ;serverNumber - (tNumberOfFullPages * 17)


								}
								else
								{
									;full pages down
									tEntryNumberInList := serverNumber - ((tServerOnPageNumber - 1) * 17)
									tNumberOfDownEntries := ((tServerOnPageNumber - 1) * 17)

								}

								Loop % tNumberOfDownEntries
								{
									Click, WheelDown
									Sleep, 30

								}

								WaitForX(1, 100)


								;tmp := UiToScreenNEW(tServerNames[langNumber][serverNumber].x,tServerNames[langNumber][serverNumber].y)
								tmp := UiToScreenNEW(tServerNames[langNumber][serverNumber].x,(tServerNames[langNumber][tEntryNumberInList].y))
								if(tServerOnPageNumber > tNumberOfFullPages && serverNumber == ObjMaxIndex(tServerNames[langNumber]))
								{
									MouseMove, tmp.X, tmp.Y + 10, 0
								}
								else
								{
									MouseMove, tmp.X, tmp.Y, 0
								}

								WaitForX(1, 100)
								Send {Click}
								WaitForX(1, 500)
							}
							else
							{
								WaitForX(1, 500)
								;click on server with no scrollable list
								tmp := UiToScreenNEW(tServerNames[langNumber][serverNumber].x,tServerNames[langNumber][serverNumber].y)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
							}

							;click on ok
							tmp := UiToScreenNEW(10165, 606)
							MouseMove, tmp.X, tmp.Y, 0
							Send {Click}



							WaitForX(4, 500)
							if(IsHighPopServerWarning() = true)
							{
								tmp := UiToScreenNEW(9810, 436)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
								WaitForX(1, 500)
							}

							MouseMove, tmp.X, tmp.Y - 100, 0

							WaitForX(4, 500)

							;click away any hc warning
							if(IsRealmQueue() != true)
							{
								WaitForX(4, 500)
								tmp := UiToScreenNEW(9942, 442)
								MouseMove, tmp.X, tmp.Y, 0
								Send {Click}
							}

							;test if on char selection screen
							tTimeout := 0
							twiccounter := 20
							while(IsCharSelectionScreen() != true)
							{
								gosub CheckMode
								if(Mode != 1)
								{
									return
								}

								;test if queue
								if(IsRealmQueue() == true)
								{
									PlayUtterance("server_full_waiting_in_queue")
									Sleep, 4500
									gosub InitQueueMenu
									return
								}
								else
								{
									if(IsCharCreationScreen() = true)
									{
										;not chars > back to char sel
										tmp := UiToScreenNEW(-160, 749)
										MouseMove, tmp.X, tmp.Y, 0
										Send {Click}
										WaitForX(1, 500)
									}

									tTimeout := tTimeout + 1
									WaitForX(1, 500)
									if(tTimeout > 20)
									{
										PlayUtterance("fail_connection_restart")
										sleep 2000
										gIgnoreKeyPress := false
										SwitchToMode_1()
										Pause
									return
									}
								}
							}

							;update number of characters
							UpdateCharacterMenu()

							PlayUtterance("switched_to_Server")
							sleep 1200

							gosub InitMenu
							UpdateCharacterMenu()

							;jump to char selection
							gMainMenu.childs[1].onEnter()

							gIgnoreKeyPress := false

						}
						gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber].onAction := Func("gMainMenuchilds4ChildsXChildsYAction").Bind(gMainMenu.childs[tMainItemN].childs[tLangNumber].childs[tRealmNumber], tLangNumber, tRealmNumber)
					}
				UpdateChilds(gMainMenu.childs[tMainItemN].childs[tLangNumber])
				;}
			}
			UpdateChilds(gMainMenu.childs[4])

		;menu item 5
		tMainItemN := 5
		gMainMenu.childs[tMainItemN] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].parent := gMainMenu
		gMainMenu.childs[tMainItemN].name := "delete_char"
		gMainMenuchilds5Action(this){
			tRGBColor := GetColorAtUiPos(-280, 724)
			;MsgBox % tRGBColor.r tRGBColor.g tRGBColor.b
			if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
			{
				;gMainMenu.childs[5].onEnter()
				;enter char name and press enter or esc to abort
				tmp := UiToScreenNEW(-280, 724)
				MouseMove, tmp.X, tmp.Y, 0
				Send {Click}

				gDeleteCharacterNameFlag := true
				PlayUtterance("enter_delete_and_press_enter_or_esc_to_cancel")
				gIgnoreKeyPress := false
			}
		}
		gMainMenu.childs[tMainItemN].onAction := Func("gMainMenuchilds5Action").Bind(gMainMenu.childs[tMainItemN])

		UpdateChilds(gMainMenu)

	;gCurrentMenuItem = gMainMenu
	;gMainMenu.onEnter()

	gIgnoreKeyPress := false
return

;------------------------------------------------------------------------------------------
; Checks
;------------------------------------------------------------------------------------------
IsHardcoreCharCreationWarning()
{

}

;------------------------------------------------------------------------------------------
IsRealmQueue()
{
	rReturnValue := true

	tmpUI := UiToScreenNEW(9799, 450)

		MouseMove, tmpUI.X, tmpUI.Y, 0
		sleep, 100


	tRGBColor := GetColorAtUiPos(9799, 450)

	;MsgBox % tRGBColor.r . " " . tRGBColor.g . " " . tRGBColor.b

	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		;rReturnValue := true
	}
	else
	{
		rReturnValue := false
	}

	tmpUI := UiToScreenNEW(10194, 450)

		MouseMove, tmpUI.X, tmpUI.Y, 0
		sleep, 100


	tRGBColor := GetColorAtUiPos(10194, 450)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		;rReturnValue := true
	}
	else
	{
		rReturnValue := false
	}

	tmpUI := UiToScreenNEW(445, 450)

		MouseMove, tmpUI.X, tmpUI.Y, 0
		sleep, 100


	tRGBColor := GetColorAtUiPos(445, 450)
	if (IsColorRange(tRGBColor.r, 0) = true and IsColorRange(tRGBColor.g, 20) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		;rReturnValue := true
	}
	else
	{
		rReturnValue := false
	}

	if(rReturnValue == true)
	{
		global gInQueue := true
		gIsInitializing = false
	}
	else
	{
		global gInQueuePlayed := false
		global gInQueue := false
	}

	return rReturnValue

}

;------------------------------------------------------------------------------------------
IsColorRange(aTestColorValue, aCompareColorValue)
{
	if(aTestColorValue >= (aCompareColorValue - 2) and aTestColorValue <= (aCompareColorValue + 2))
	{
		return true
	}
	else
	{
		return false
	}
}

IsWoWWindowFocus()
{
	rReturnValue := false
	SetTitleMatchMode, 3
	If(WinActive("World of Warcraft") || WinActive("WORLD OF WARCRAFT"))
	{
		rReturnValue := true
	}

	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsIngame()
{
	rReturnValue := false

	tmpUI := ScreenToUiNEW(1, 1)

	tRGBColor := GetColorAtUiPos(tmpUI.x, tmpUI.y)
	/*
	if (tRGBColor.r = 0 and tRGBColor.g = 0 and tRGBColor.b = 0)
	{
		rReturnValue := true
	}
	*/
	if (IsColorRange(tRGBColor.r, 0) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 255) = true)
	{
		rReturnValue := true
	}

	tmpUI := ScreenToUiNEW(1, A_ScreenHeight-2)

	tRGBColor := GetColorAtUiPos(tmpUI.x, tmpUI.y)
	/*
	if (tRGBColor.r = 0 and tRGBColor.g = 0 and tRGBColor.b = 0)
	{
		rReturnValue := true
	}
	*/
	if (IsColorRange(tRGBColor.r, 0) and IsColorRange(tRGBColor.g, 0) and IsColorRange(tRGBColor.b, 255))
	{
		rReturnValue := true
	}


	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsGlue()
{
	rReturnValue := false

	if(IsLoginScreen() = true or IsCharSelectionScreen() = true or IsRealmSelectionScreen() = true or IsCharCreationScreen() = true)
	{
		rReturnValue := true
	}

	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsLoginScreenInitialStart()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(38,72)
	tRGBColorQuit := GetColorAtUiPos(-23, 717)
	tRGBColorCreate := GetColorAtUiPos(28, 550)
	if ((IsColorRange(tRGBColorLogo.r, 198) = true and IsColorRange(tRGBColorLogo.g, 227) = true and IsColorRange(tRGBColorLogo.b, 0) = true) = true and (IsColorRange(tRGBColorQuit.r, 255) = true and IsColorRange(tRGBColorQuit.g, 0) = true and IsColorRange(tRGBColorQuit.b, 0) = true) = true and (IsColorRange(tRGBColorCreate.r, 255) = true and IsColorRange(tRGBColorCreate.g, 0) = true and IsColorRange(tRGBColorCreate.b, 0) = true) = false)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsLoginScreen()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(38,72)
	tRGBColorQuit := GetColorAtUiPos(-23, 717)
	if ((IsColorRange(tRGBColorLogo.r, 198) = true and IsColorRange(tRGBColorLogo.g, 227) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorQuit.r, 255) = true and IsColorRange(tRGBColorQuit.g, 0) = true and IsColorRange(tRGBColorQuit.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsCharSelectionScreen()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(38,72)
	tRGBColorAddons := GetColorAtUiPos(49, 722)

	if (((IsColorRange(tRGBColorLogo.r, 198) = true and IsColorRange(tRGBColorLogo.g, 227) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorAddons.r, 255) = true and IsColorRange(tRGBColorAddons.g, 0) = true and IsColorRange(tRGBColorAddons.b, 0) = true)) or (((IsColorRange(tRGBColorLogo.r, 50) = true and IsColorRange(tRGBColorLogo.g, 57) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorAddons.r, 64) = true and IsColorRange(tRGBColorAddons.g, 0) = true and IsColorRange(tRGBColorAddons.b, 0) = true))))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsCharCreationScreen()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(38,72)
	tRGBColorRCBackdrop := GetColorAtUiPos(45, 395)
	if ((IsColorRange(tRGBColorLogo.r, 198) = true and IsColorRange(tRGBColorLogo.g, 227) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorRCBackdrop.r, 0) = true and IsColorRange(tRGBColorRCBackdrop.g, 0) = true and IsColorRange(tRGBColorRCBackdrop.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsRealmSelectionScreen()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorTitleBackdrop := GetColorAtUiPos(9952, 126)
	tRGBColorListBackdrop := GetColorAtUiPos(404, 145)
	if ((IsColorRange(tRGBColorTitleBackdrop.r, 0) = true and IsColorRange(tRGBColorTitleBackdrop.g, 56) = true and IsColorRange(tRGBColorTitleBackdrop.b, 0) = true) and (IsColorRange(tRGBColorListBackdrop.r, 40) = true and IsColorRange(tRGBColorListBackdrop.g, 0) = true and IsColorRange(tRGBColorListBackdrop.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;------------------------------------------------------------------------------------------
IsRealmListScrollbar()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorScrollbarBackdrop := GetColorAtUiPos(-335, 324)
	if ((IsColorRange(tRGBColorScrollbarBackdrop.r, 15) = true and IsColorRange(tRGBColorScrollbarBackdrop.g, 0) = true and IsColorRange(tRGBColorScrollbarBackdrop.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}


;-----------------------------------------------------------------------------------------------------------------------------------------------------
;-----------------------------------------------------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------
IsContract()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(38,72)
	tRGBColorAddons := GetColorAtUiPos(49, 722)
	tRGBColorTitleBackdrop := GetColorAtUiPos(9852, 284)

	if ((IsColorRange(tRGBColorLogo.r, 50) = true and IsColorRange(tRGBColorLogo.g, 57) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorAddons.r, 64) = true and IsColorRange(tRGBColorAddons.g, 0) = true and IsColorRange(tRGBColorAddons.b, 0) = true) and (IsColorRange(tRGBColorTitleBackdrop.r, 0) = true and IsColorRange(tRGBColorTitleBackdrop.g, 0) = true and IsColorRange(tRGBColorTitleBackdrop.b, 0) = true))
	{
		rReturnValue := true
	}
	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsOutdatedAddonsWarning()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLogo := GetColorAtUiPos(38,72)
	tRGBColorAddons := GetColorAtUiPos(49, 722)
	tRGBColorTitleBackdrop := GetColorAtUiPos(830,410)

	if ((((IsColorRange(tRGBColorLogo.r, 198) = true and IsColorRange(tRGBColorLogo.g, 227) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorAddons.r, 255) = true and IsColorRange(tRGBColorAddons.g, 0) = true and IsColorRange(tRGBColorAddons.b, 0) = true)) or (((IsColorRange(tRGBColorLogo.r, 50) = true and IsColorRange(tRGBColorLogo.g, 57) = true and IsColorRange(tRGBColorLogo.b, 0) = true) and (IsColorRange(tRGBColorAddons.r, 64) = true and IsColorRange(tRGBColorAddons.g, 0) = true and IsColorRange(tRGBColorAddons.b, 0) = true)))) and (IsColorRange(tRGBColorTitleBackdrop.r, 0) = true and IsColorRange(tRGBColorTitleBackdrop.g, 40) = true and IsColorRange(tRGBColorTitleBackdrop.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsHighPopServerWarning()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9810, 436) ;(9799, 436)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsDisconnected()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(560,405)
	if (tRGBColor.r > 90 and tRGBColor.g < 40 and tRGBColor.b < 40)
	{
		rReturnValue := true
	}
	;MsgBox % rReturnValue
	gIgnoreKeyPress := false
	return rReturnValue
}

;-----------------------------------------------------------------------------------------------------------------------------------------------------
IsDeleteButtonEnabled()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9796, 437)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;-----------------------------------------------------------------------------------------------------------------------------------------------------
IsDeleteButtonDisabled()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9796, 437)
	if (IsColorRange(tRGBColor.r, 139) = true and IsColorRange(tRGBColor.g, 139) = true and IsColorRange(tRGBColor.b, 139) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;-----------------------------------------------------------------------------------------------------------------------------------------------------
IsDeleteCancelButton()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(10195, 437)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
/*
;------------------------------------------------------------------------------------------
IsEnterCredentials()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tmyAccount := false

	tRGBColor := GetColorAtUiPos(32,590)
	if (tRGBColor.r > 190 and tRGBColor.g < 40 and tRGBColor.b < 40)
	{
		tmyAccount := true
	}

	tmp := UiToScreen(510,396)

	tRGBColor := GetColorAtUiPos(510.4,396)
	if (tRGBColor.r < 90 and tRGBColor.g < 90 and tRGBColor.b < 90 and tmyAccount = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
*/

;------------------------------------------------------------------------------------------
Is12Popup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLeft := GetColorAtUiPos(9802, 397)
	tRGBColorRight := GetColorAtUiPos(10196, 397)
	if((IsColorRange(tRGBColorLeft.r, 255) = true and IsColorRange(tRGBColorLeft.g, 0) = true and IsColorRange(tRGBColorLeft.b, 0) = true) and (IsColorRange(tRGBColorRight.r, 255) = true and IsColorRange(tRGBColorRight.g, 0) = true and IsColorRange(tRGBColorRight.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;------------------------------------------------------------------------------------------
Is22Popup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorLeft := GetColorAtUiPos(9802, 405)
	tRGBColorRight := GetColorAtUiPos(10196, 405)
	if((IsColorRange(tRGBColorLeft.r, 255) = true and IsColorRange(tRGBColorLeft.g, 0) = true and IsColorRange(tRGBColorLeft.b, 0) = true) and (IsColorRange(tRGBColorRight.r, 255) = true and IsColorRange(tRGBColorRight.g, 0) = true and IsColorRange(tRGBColorRight.b, 0) = true))
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;------------------------------------------------------------------------------------------
Is11Popup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9915, 397)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true and Is12Popup() != true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}
;------------------------------------------------------------------------------------------
Is21Popup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9915, 405)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true and Is22Popup() != true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsDeleteCharPopup()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColorBackdrop := GetColorAtUiPos(450, 331)
	tRGBColorEditbox := GetColorAtUiPos(10057, 400)
	if (IsColorRange(tRGBColorBackdrop.r, 0) = true and IsColorRange(tRGBColorBackdrop.g, 40) = true and IsColorRange(tRGBColorBackdrop.b, 0) = true) and (IsColorRange(tRGBColorEditbox.r, 3) = true and IsColorRange(tRGBColorEditbox.g, 17) = true and IsColorRange(tRGBColorEditbox.b, 3) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}


;------------------------------------------------------------------------------------------
IsReconnect()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(9917, 441)
	if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
IsConnectingToGame()
{
	gIgnoreKeyPress := true
	rReturnValue := false

	tRGBColor := GetColorAtUiPos(570,394)
	if (tRGBColor.r > 100 and tRGBColor.g < 40 and tRGBColor.b < 40)
	{
		rReturnValue := true
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
; functions
;------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------
ScreenToUiNEW(x, y)
{
	tA_ScreenWidth := A_ScreenWidth
	tHalfUIBarWidth   := 0
	ar := GetAR()
	if (ar > 1.77)
	{
		tA_ScreenWidth := A_ScreenHeight * 1.7777777777777777777777
		tHalfUIBarWidth := (A_ScreenWidth - tA_ScreenWidth) / 2
	}

	fUIx := 0
	oneThirdSW := tA_ScreenWidth / 3

	if(x >= (oneThirdSW * 2)) ;anchor right
	{
		fUIx := (GetUiX() * (((tA_ScreenWidth - x) / (tA_ScreenWidth / 100)) / 100)) * -1
	}
	else if(x < oneThirdSW * 2 and x > oneThirdSW) ;anchor center
	{
		fUIx := ((GetUiX() / 100) * ((x - (tA_ScreenWidth / 2)) / (tA_ScreenWidth / 100))) + 10000
	}
	else if(x <= oneThirdSW) ;anchor left
	{
		fUIx := GetUiX() * (x / tA_ScreenWidth)
	}

	Array := {X: (fUIx), Y: (768 * (y / A_ScreenHeight))}
	return Array
}

;------------------------------------------------------------------------------------------
UiToScreenNEW(x, y)
{
	tA_ScreenWidth := A_ScreenWidth
	tHalfUIBarWidth   := 0
	ar := GetAR()
	if (ar > 1.77)
	{
		tA_ScreenWidth := A_ScreenHeight * 1.7777777777777777777777
		tHalfUIBarWidth := (A_ScreenWidth - tA_ScreenWidth) / 2
	}

	fSx := 0

	if(x >= 7000) ;anchor center
	{
		fSx := (((x - 10000) / (GetUiX() / 100)) * (tA_ScreenWidth / 100)) + (tA_ScreenWidth / 2)
	}
	else if(x <= 0) ;anchor right
	{
		fSx := tA_ScreenWidth - ((tA_ScreenWidth / 100) * ((x * -1) / (GetUiX() / 100)))
	}
	else if(x < 7000) ;anchor left
	{
		fSx := (x / (GetUiX() / 100)) * (tA_ScreenWidth / 100)
	}

	fSy := (A_ScreenHeight * (y / 768))

	if (GetAR() < 1)
	{

		PixelGetColor, color, 2, 2, RGB,
		v1blue := (color & 0xFF)
		v1green := ((color & 0xFF00) >> 8)
		v1red := ((color & 0xFF0000) >> 16)
		if (v1blue < 255 || v1green > 0 || v1red > 0)
		{
			fSy := (y * 1.334) + ((A_ScreenHeight - (768 * 1.334)) / 2)
		}
	}

	Array := {X: (fSx + tHalfUIBarWidth), Y: (fSy)}

	return Array
}

SwitchToMode_1()
{
		mode := -1
		PlayUtterance("paused")
		sleep, 1500
}

;------------------------------------------------------------------------------------------
SwitchToMode0()
{
		mode := 0
		PlayUtterance("switched_to_play_mode")
		sleep, 1500
}

;------------------------------------------------------------------------------------------
SwitchToMode1()
{
	global gInQueuePlayed := false
	gNumberOfCharsOnCurrentRealm := -1
	mode = 1
	PlayUtterance("switched_to_login_mode")
	sleep, 1500
}

;------------------------------------------------------------------------------------------
GetAR()
{
	ar := A_ScreenWidth / A_ScreenHeight
	return ar
}

;------------------------------------------------------------------------------------------
PlayUtterance(menuName)
{
	soundFiles := {US_realms:"00001_sku_en_eu.mp3"
		,USA_West:"00002_sku_en_eu.mp3"
		,Anathema:"00003_sku_en_eu.mp3"
		,Arcanite_Reaper:"00004_sku_en_eu.mp3"
		,Atiesh:"00005_sku_en_eu.mp3"
		,Azursong:"00006_sku_en_eu.mp3"
		,Bigglesworth:"00007_sku_en_eu.mp3"
		,Biaumeux:"00008_sku_en_eu.mp3"
		,Fairbanks:"00009_sku_en_eu.mp3"
		,Grobbulus:"00010_sku_en_eu.mp3"
		,Kurinnaxx:"00011_sku_en_eu.mp3"
		,Myzrael:"00012_sku_en_eu.mp3"
		,Old_Blanchy:"00013_sku_en_eu.mp3"
		,Rattlegore:"00014_sku_en_eu.mp3"
		,Smolderweb:"00015_sku_en_eu.mp3"
		,Thunderfury:"00016_sku_en_eu.mp3"
		,Whitemane:"00017_sku_en_eu.mp3"
		,USA_East:"00018_sku_en_eu.mp3"
		,Ashkandi:"00019_sku_en_eu.mp3"
		,Benediction:"00020_sku_en_eu.mp3"
		,Bloodsail_Buccaneers:"00021_sku_en_eu.mp3"
		,Deviate_Delight:"00022_sku_en_eu.mp3"
		,Earthfury:"00023_sku_en_eu.mp3"
		,Faerlina:"00024_sku_en_eu.mp3"
		,Heartseeker:"00025_sku_en_eu.mp3"
		,Herod:"00026_sku_en_eu.mp3"
		,Incendius:"00027_sku_en_eu.mp3"
		,Kirtonos:"00028_sku_en_eu.mp3"
		,Krmocrush:"00029_sku_en_eu.mp3"
		,Mankrik:"00030_sku_en_eu.mp3"
		,Netherwind:"00031_sku_en_eu.mp3"
		,Pagle:"00032_sku_en_eu.mp3"
		,Skeram:"00033_sku_en_eu.mp3"
		,Stalagg:"00034_sku_en_eu.mp3"
		,Sulfuras:"00035_sku_en_eu.mp3"
		,Thalnos:"00036_sku_en_eu.mp3"
		,Westfall:"00037_sku_en_eu.mp3"
		,Windseeker:"00038_sku_en_eu.mp3"
		,Oceanic:"00039_sku_en_eu.mp3"
		,Argual:"00040_sku_en_eu.mp3"
		,Felstriker:"00041_sku_en_eu.mp3"
		,Remulos:"00042_sku_en_eu.mp3"
		,Yojamba:"00043_sku_en_eu.mp3"
		,Latin_America:"00044_sku_en_eu.mp3"
		,Loatheb:"00045_sku_en_eu.mp3"
		,Brasil:"00046_sku_en_eu.mp3"
		,Sul_thraze:"00047_sku_en_eu.mp3"
		,EU_realms:"00048_sku_en_eu.mp3"
		,english:"00049_sku_en_eu.mp3"
		,Ashbringer:"00050_sku_en_eu.mp3"
		,Bloodfang:"00051_sku_en_eu.mp3"
		,Dragonfang:"00052_sku_en_eu.mp3"
		,Dreadmist:"00053_sku_en_eu.mp3"
		,Earthshaker:"00054_sku_en_eu.mp3"
		,Firemaw:"00055_sku_en_eu.mp3"
		,Flamelash:"00056_sku_en_eu.mp3"
		,Gandling:"00057_sku_en_eu.mp3"
		,Gehennas:"00058_sku_en_eu.mp3"
		,Golemagg:"00059_sku_en_eu.mp3"
		,Hydraxian_Waterlords:"00060_sku_en_eu.mp3"
		,Judgement:"00061_sku_en_eu.mp3"
		,Mirage_Raceway:"00062_sku_en_eu.mp3"
		,Mograine:"00063_sku_en_eu.mp3"
		,Nethergarde_Keep:"00064_sku_en_eu.mp3"
		,Noggenfogger:"00065_sku_en_eu.mp3"
		,Stonespine:"00066_sku_en_eu.mp3"
		,Pyrewood_Village:"00067_sku_en_eu.mp3"
		,Ten_Storms:"00068_sku_en_eu.mp3"
		,Razorgore:"00069_sku_en_eu.mp3"
		,Zandalar_Tribe:"00070_sku_en_eu.mp3"
		,Shazzrah:"00071_sku_en_eu.mp3"
		,Skullflame:"00072_sku_en_eu.mp3"
		,german:"00073_sku_en_eu.mp3"
		,celebras:"00074_sku_en_eu.mp3"
		,dragons_call:"00075_sku_en_eu.mp3"
		,everlook:"00076_sku_en_eu.mp3"
		,heartstriker:"00077_sku_en_eu.mp3"
		,lakeshire:"00078_sku_en_eu.mp3"
		,lucifron:"00079_sku_en_eu.mp3"
		,patchwerk:"00080_sku_en_eu.mp3"
		,razorfen:"00081_sku_en_eu.mp3"
		,transcendence:"00082_sku_en_eu.mp3"
		,venoxis:"00083_sku_en_eu.mp3"
		,french:"00084_sku_en_eu.mp3"
		,Amnennar:"00085_sku_en_eu.mp3"
		,Auberdine:"00086_sku_en_eu.mp3"
		,Finkle:"00087_sku_en_eu.mp3"
		,Sulfuron:"00088_sku_en_eu.mp3"
		,spanish:"00089_sku_en_eu.mp3"
		,Mandokir:"00090_sku_en_eu.mp3"
		,NV:"00001_nv_en.mp3"
		,Skyfury:"00002_Skyfury_en.mp3"
		,Maladath:"00003_Maladath_en.mp3"
		,Thekal:"00004_Thekal_en.mp3"
		,Giantstalker:"00005_Giantstalker_en.mp3"
		,deathknight:"00006_deathknight_en.mp3"
		,Angerforge:"00001_1409_en.mp3"
		,jin_do:"00004_1409_en.mp3"
		,Eranikus:"00001_1509_en.mp3"}


	soundFiles1 := {1:"00091_sku_en_eu.mp3"
		,2:"00092_sku_en_eu.mp3"
		,3:"00093_sku_en_eu.mp3"
		,4:"00094_sku_en_eu.mp3"
		,5:"00095_sku_en_eu.mp3"
		,5:"00096_sku_en_eu.mp3"
		,6:"00097_sku_en_eu.mp3"
		,7:"00098_sku_en_eu.mp3"
		,8:"00099_sku_en_eu.mp3"
		,9:"00100_sku_en_eu.mp3"
		,10:"00101_sku_en_eu.mp3"
		,11:"00102_sku_en_eu.mp3"
		,12:"00103_sku_en_eu.mp3"
		,13:"00104_sku_en_eu.mp3"
		,14:"00105_sku_en_eu.mp3"
		,15:"00106_sku_en_eu.mp3"
		,16:"00107_sku_en_eu.mp3"
		,17:"00108_sku_en_eu.mp3"
		,18:"00109_sku_en_eu.mp3"
		,19:"00110_sku_en_eu.mp3"
		,20:"00111_sku_en_eu.mp3"
		,21:"00112_sku_en_eu.mp3"
		,22:"00113_sku_en_eu.mp3"
		,23:"00114_sku_en_eu.mp3"
		,24:"00115_sku_en_eu.mp3"
		,25:"00116_sku_en_eu.mp3"
		,selected:"00117_sku_en_eu.mp3"
		,fail_restart:"00118_sku_en_eu.mp3"
		,char_created:"00119_sku_en_eu.mp3"
		,fail_name:"00120_sku_en_eu.mp3"
		,creating_wait:"00121_sku_en_eu.mp3"
		,aborting_creation:"00122_sku_en_eu.mp3"
		,fail_connection_restart:"00123_sku_en_eu.mp3"
		,fail_unknown_restart:"00124_sku_en_eu.mp3"
		,enter_name_press_enter_or_esc:"00125_sku_en_eu.mp3"
		,max_chars_on_server:"00126_sku_en_eu.mp3"
		,switching_to_server:"00127_sku_en_eu.mp3"
		,switched_to_Server:"00128_sku_en_eu.mp3"
		,character:"00129_sku_en_eu.mp3"
		,characters:"00130_sku_en_eu.mp3"
		,on_this_server:"00131_sku_en_eu.mp3"
		,enter_delete_and_press_enter:"00132_sku_en_eu.mp3"
		,char_deleted:"00133_sku_en_eu.mp3"
		,switched_to_play_mode:"00134_sku_en_eu.mp3"
		,switched_to_login_mode:"00135_sku_en_eu.mp3"
		,current_mode:"00136_sku_en_eu.mp3"
		,play_mode:"00137_sku_en_eu.mp3"
		,login_mode:"00138_sku_en_eu.mp3"
		,wow_window_not_focus:"00139_sku_en_eu.mp3"
		,wow_window_not_available:"00140_sku_en_eu.mp3"
		,unknown_resolution:"00141_sku_en_eu.mp3"
		,fail:"00142_sku_en_eu.mp3"
		,char_number:"00143_sku_en_eu.mp3"
		,main_menu:"00144_sku_en_eu.mp3"
		,select_char:"00145_sku_en_eu.mp3"
		,login_with_selected_char:"00146_sku_en_eu.mp3"
		,login:"00147_sku_en_eu.mp3"
		,delete_char:"00148_sku_en_eu.mp3"
		,create_char:"00149_sku_en_eu.mp3"
		,male:"00150_sku_en_eu.mp3"
		,female:"00151_sku_en_eu.mp3"
		,warrior:"00152_sku_en_eu.mp3"
		,priest:"00153_sku_en_eu.mp3"
		,hunter:"00154_sku_en_eu.mp3"
		,shaman:"00155_sku_en_eu.mp3"
		,mage:"00156_sku_en_eu.mp3"
		,paladin:"00157_sku_en_eu.mp3"
		,rogue:"00158_sku_en_eu.mp3"
		,warlock:"00159_sku_en_eu.mp3"
		,druid:"00160_sku_en_eu.mp3"
		,human:"00161_sku_en_eu.mp3"
		,dwarf:"00162_sku_en_eu.mp3"
		,gnome:"00163_sku_en_eu.mp3"
		,nightelf:"00164_sku_en_eu.mp3"
		,orc:"00165_sku_en_eu.mp3"
		,troll:"00166_sku_en_eu.mp3"
		,tauren:"00167_sku_en_eu.mp3"
		,bloodelf:"00168_sku_en_eu.mp3"
		,draenei:"00169_sku_en_eu.mp3"
		,switch_server:"00170_sku_en_eu.mp3"
		,enter_world:"00171_sku_en_eu.mp3"
		,language:"00172_sku_en_eu.mp3"
		,server_type:"00173_sku_en_eu.mp3"
		,english:"00174_sku_en_eu.mp3"
		,german:"00175_sku_en_eu.mp3"
		,french:"00176_sku_en_eu.mp3"
		,spanish:"00177_sku_en_eu.mp3"
		,russian:"00178_sku_en_eu.mp3"
		,ok:"00179_sku_en_eu.mp3"
		,cancel:"00180_sku_en_eu.mp3"
		,celebras:"00181_sku_en_eu.mp3"
		,dragons_call:"00182_sku_en_eu.mp3"
		,everlook:"00183_sku_en_eu.mp3"
		,heartstriker:"00184_sku_en_eu.mp3"
		,lakeshire:"00185_sku_en_eu.mp3"
		,lucifron:"00186_sku_en_eu.mp3"
		,patchwerk:"00187_sku_en_eu.mp3"
		,razorfen:"00188_sku_en_eu.mp3"
		,transcendence:"00189_sku_en_eu.mp3"
		,venoxis:"00190_sku_en_eu.mp3"
			,pvp:"00191_sku_en_eu.mp3"
			,pve:"00002_1409_en.mp3"
			,rp_pve:"00003_1409_en.mp3"
			,rp_pvp:"00194_sku_en_eu.mp3"
		,enter_name:"00195_sku_en_eu.mp3"
		,create:"00196_sku_en_eu.mp3"
		,generate_random_character:"00197_sku_en_eu.mp3"
		,alliance:"00198_sku_en_eu.mp3"
		,horde:"00199_sku_en_eu.mp3"
		,wait:"sound-notification6_de.mp3" ;,wait:"00200_sku_en_eu.mp3"
		,undead:"00201_sku_en_eu.mp3"
		,empty:"00202_sku_en_eu.mp3"
		,paused:"00203_sku_en_eu.mp3"
		,fail_delete_retype_delete_and_press_enter_or_escape:"2306221.mp3"
		,aborting_deletion:"2306222.mp3"
		,enter_delete_and_press_enter_or_esc_to_cancel:"2306223.mp3"
		,script_exited:"2306224.mp3"
		,move_character_up:"2306225.mp3"
		,move_character_down:"2306226.mp3"}

	soundFiles2 := {Anathema:"00003_sku_en_eu.mp3"
		,Amnennar:"00085_sku_en_eu.mp3"
		,Anathema:"00003_sku_en_eu.mp3"
		,Angerforge:"00001_1409_en.mp3"
		,Arcanite_Reaper:"00004_sku_en_eu.mp3"
		,Argual:"00040_sku_en_eu.mp3"
		,arugal:"00001_230723_en_Arugal.mp3 "
		,Ashbringer:"00050_sku_en_eu.mp3"
		,Ashkandi:"00019_sku_en_eu.mp3"
		,Atiesh:"00005_sku_en_eu.mp3"
		,Auberdine:"00086_sku_en_eu.mp3"
		,azuresong:"00002_230723_en_Azuresong.mp3 "
		,Azursong:"00006_sku_en_eu.mp3"
		,Benediction:"00020_sku_en_eu.mp3"
		,Biaumeux:"00008_sku_en_eu.mp3"
		,Bigglesworth:"00007_sku_en_eu.mp3"
		,blaumeux:"00003_230723_en_Blaumeux.mp3 "
		,Bloodfang:"00051_sku_en_eu.mp3"
		,Bloodsail_Buccaneers:"00021_sku_en_eu.mp3"
		,bonescythe:"00004_230723_en_Bonescythe.mp3 "
		,Brasil:"00046_sku_en_eu.mp3"
		,bugglesworth:"00005_230723_en_Bugglesworth.mp3 "
		,celebras:"00074_sku_en_eu.mp3"
		,classic_aera:"00003_230723_de_Classic-Ära.mp3 "
		,classic_era:"00006_230723_en_Classic_Era.mp3 "
		,deathknight:"00006_deathknight_en.mp3"
		,Deviate_Delight:"00022_sku_en_eu.mp3"
		,Dragonfang:"00052_sku_en_eu.mp3"
		,dragons_call:"00007_230723_en_Dragons_Call.mp3 "
		,Dreadmist:"00053_sku_en_eu.mp3"
		,dreadnaugth:"00008_230723_en_Dreadnaugth.mp3 "
		,Earthfury:"00023_sku_en_eu.mp3"
		,Earthshaker:"00054_sku_en_eu.mp3"
		,english:"00049_sku_en_eu.mp3"
		,Eranikus:"00001_1509_en.mp3}"
		,EU_realms:"00048_sku_en_eu.mp3"
		,everlook:"00076_sku_en_eu.mp3"
		,Faerlina:"00024_sku_en_eu.mp3"
		,Fairbanks:"00009_sku_en_eu.mp3"
		,Felstriker:"00041_sku_en_eu.mp3"
		,Finkle:"00087_sku_en_eu.mp3"
		,Firemaw:"00055_sku_en_eu.mp3"
		,Flamelash:"00056_sku_en_eu.mp3"
		,french:"00084_sku_en_eu.mp3"
		,Gandling:"00057_sku_en_eu.mp3"
		,Gehennas:"00058_sku_en_eu.mp3"
		,german:"00073_sku_en_eu.mp3"
		,Giantstalker:"00005_Giantstalker_en.mp3"
		,Golemagg:"00059_sku_en_eu.mp3"
		,Grobbulus:"00010_sku_en_eu.mp3"
		,Heartseeker:"00025_sku_en_eu.mp3"
		,heartstriker:"00077_sku_en_eu.mp3"
		,Herod:"00026_sku_en_eu.mp3"
		,hydraxian_waterlords:"00009_230723_en_Hydraxian_Waterlords.mp3 "
		,Incendius:"00027_sku_en_eu.mp3"
		,ironfoe:"00010_230723_en_Ironfoe.mp3 "
		,jin_do:"00004_1409_en.mp3"
		,Judgement:"00061_sku_en_eu.mp3"
		,kingsfall:"00011_230723_en_Kingsfall.mp3 "
		,Kirtonos:"00028_sku_en_eu.mp3"
		,Krmocrush:"00029_sku_en_eu.mp3"
		,kromcrush:"00012_230723_en_Kromcrush.mp3 "
		,Kurinnaxx:"00011_sku_en_eu.mp3"
		,lakeshire:"00078_sku_en_eu.mp3"
		,Latin_America:"00044_sku_en_eu.mp3"
		,Loatheb:"00045_sku_en_eu.mp3"
		,lucifron:"00079_sku_en_eu.mp3"
		,Maladath:"00003_Maladath_en.mp3"
		,Mandokir:"00090_sku_en_eu.mp3"
		,Mankrik:"00030_sku_en_eu.mp3"
		,Mirage_Raceway:"00062_sku_en_eu.mp3"
		,mograin:"00013_230723_en_Mograin.mp3 "
		,Mograine:"00063_sku_en_eu.mp3"
		,Myzrael:"00012_sku_en_eu.mp3"
		,Nethergarde_Keep:"00064_sku_en_eu.mp3"
		,Netherwind:"00031_sku_en_eu.mp3"
		,Noggenfogger:"00065_sku_en_eu.mp3"
		,NV:"00001_nv_en.mp3"
		,Oceanic:"00039_sku_en_eu.mp3"
		,Old_Blanchy:"00013_sku_en_eu.mp3"
		,Pagle:"00032_sku_en_eu.mp3"
		,patchwerk:"00080_sku_en_eu.mp3"
		,pve:"00002_1409_en.mp3"
		,pvp:"00191_sku_en_eu.mp3"
		,Pyrewood_Village:"00067_sku_en_eu.mp3"
		,quel_serrar:"00014_230723_en_Quel_Serrar.mp3 "
		,Rattlegore:"00014_sku_en_eu.mp3"
		,razorfen:"00081_sku_en_eu.mp3"
		,Razorgore:"00069_sku_en_eu.mp3"
		,Remulos:"00042_sku_en_eu.mp3"
		,rp_pve:"00003_1409_en.mp3"
		,rp_pvp:"00194_sku_en_eu.mp3"
		,russian:"00015_230723_en_Russian.mp3 "
		,russisch:"00002_230723_de_Russisch.mp3 "
		,saisonbedingt:"00001_230723_de_Saisonbedingt.mp3 "
		,seasonal:"00016_230723_en_Seasonal.mp3 "
		,Shazzrah:"00071_sku_en_eu.mp3"
		,Skeram:"00033_sku_en_eu.mp3"
		,Skullflame:"00072_sku_en_eu.mp3"
		,Skyfury:"00002_Skyfury_en.mp3"
		,Smolderweb:"00015_sku_en_eu.mp3"
		,spanish:"00089_sku_en_eu.mp3"
		,Stalagg:"00034_sku_en_eu.mp3"
		,Stonespine:"00066_sku_en_eu.mp3"
		,sul_thraze:"00017_230723_en_Sul_thraze.mp3 "
		,Sulfuras:"00035_sku_en_eu.mp3"
		,Sulfuron:"00088_sku_en_eu.mp3"
		,Ten_Storms:"00068_sku_en_eu.mp3"
		,Thalnos:"00036_sku_en_eu.mp3"
		,Thekal:"00004_Thekal_en.mp3"
		,Thunderfury:"00016_sku_en_eu.mp3"
		,transcendence:"00082_sku_en_eu.mp3"
		,USA_East:"00018_sku_en_eu.mp3"
		,venoxis:"00083_sku_en_eu.mp3"
		,Westfall:"00037_sku_en_eu.mp3"
		,Whitemane:"00017_sku_en_eu.mp3"
		,Windseeker:"00038_sku_en_eu.mp3"
		,Yojamba:"00043_sku_en_eu.mp3"
		,hardcore :"00001_270823__hardcore.mp3"
		,normal :"00002_270823__normal.mp3"
		,nek_rosh :"00003_270823__nek_rosh.mp3"
		,stitches :"00004_270823__stitches.mp3"
		,server_full_waiting_in_queue :"00005_270823__server_full_waiting_in_queue.mp3"
		,defias_pillager :"00006_270823__defias_pillager.mp3"
		,skull_rock :"00007_270823__skull_rock.mp3"
		,Zandalar_Tribe:"00070_sku_en_eu.mp3"}

	;MsgBox % menuName "`n" soundFiles[menuName] "`n" soundFiles1[menuName] "`n" soundFiles2[menuName] "`n"

	if(soundFiles[menuName] != "")
	{
		SoundPlay, % A_WorkingDir . "\soundfiles\" . soundFiles[menuName]
	}
	else if(soundFiles1[menuName] != "")
	{
		SoundPlay, % A_WorkingDir . "\soundfiles\" . soundFiles1[menuName]
	}
	else if(soundFiles2[menuName] != "")
	{
		SoundPlay, % A_WorkingDir . "\soundfiles\" . soundFiles2[menuName]
	}
}

;------------------------------------------------------------------------------------------
UpdateChilds(menuObj)
{
	Loop % menuObj.childs.MaxIndex()
	{
		if (A_Index = 1)
		{
			menuObj.childs[1].n := menuObj.childs[2]
		}
		else if (A_Index = menuObj.childs.MaxIndex())
		{
			menuObj.childs[A_Index].p := menuObj.childs[A_Index - 1]
		}
		else
		{
			menuObj.childs[A_Index].p := menuObj.childs[A_Index - 1]
			menuObj.childs[A_Index].n := menuObj.childs[A_Index + 1]
		}
	}
}

;------------------------------------------------------------------------------------------
GetUiX()
{
	ar := GetAR()

	if (ar < 1.34)
	{
		return 960
	}
	else if (ar < 1.49)
	{
		return 1024
	}
	else if (ar < 1.59)
	{
		return 1152
	}
	else if (ar < 1.77)
	{
		return 1228.8
	}
	else
	{
		return 1365.33
	}
}

;------------------------------------------------------------------------------------------
GetNumberOfChars()
{
	gIgnoreKeyPress := true
	rReturnValue := 0

	tCharSlots := {1:{x:-45,y:100},2:{x:-45,y:155},3:{x:-45,y:210},4:{x:-45,y:270},5:{x:-45,y:330},6:{x:-45,y:380},7:{x:-45,y:450},8:{x:-45,y:510},9:{x:-45,y:560},10:{x:-45,y:610}}

	loop 9
	{
		gosub CheckMode
		if(Mode != 1)
		{
			break
		}

		tmp := UiToScreenNEW(tCharSlots[A_Index].x,tCharSlots[A_Index].y)
		MouseMove, tmp.X, tmp.Y, 0

		WaitForX(1, 150)
		tRGBColor := GetColorAtUiPos(tCharSlots[A_Index].x,tCharSlots[A_Index].y)
		if (tRGBColor.r > 250 and tRGBColor.g > 250 and tRGBColor.b > 250)
		{
			rReturnValue := rReturnValue + 1
		}
		else
		{
			gIgnoreKeyPress := false
			return rReturnValue
		}
	}

	gIgnoreKeyPress := false
	return rReturnValue
}

;------------------------------------------------------------------------------------------
GetColorAtUiPos(x, y)
{
	rReturnValue := {red:-1,green:-1,blue:-1}

	tmp := UiToScreenNEW(x, y)

	if (tmp.X > 0 and tmp.Y > 0)
	{
		PixelGetColor, color, tmp.X, tmp.Y, RGB,

		v1blue := (color & 0xFF)
		v1green := ((color & 0xFF00) >> 8)
		v1red := ((color & 0xFF0000) >> 16)

		rReturnValue := {r:v1red,g:v1green,b:v1blue}
	}

	return rReturnValue
}

;------------------------------------------------------------------------------------------
gMainMenuchilds1ChildsXGenericAction(this, charNumber) ;unfortunately this ugly helper is required as ahk can't directly assign funcs to variables/objects :(
{
	tmp := UiToScreenNEW(gCharUIPositions[charNumber].x, gCharUIPositions[charNumber].y)
	MouseMove, tmp.X, tmp.Y, 0
	Send {Click}

	PlayUtterance(charNumber)
	sleep 600
	PlayUtterance("selected")
	sleep 1000

	gMainMenu.childs[2].onEnter()
}
UpdateCharacterMenu()
{
	WaitForX(1, 100)

	gNumberOfCharsOnCurrentRealm := GetNumberOfChars()

	tMainItemN := 1

	gMainMenu.childs[tMainItemN].childs := []
	if(gNumberOfCharsOnCurrentRealm = 0)
	{
		gMainMenu.childs[tMainItemN].childs[1] := new baseMenuEntryObject
		gMainMenu.childs[tMainItemN].childs[1].parent := gMainMenu.childs[tMainItemN]
		gMainMenu.childs[tMainItemN].childs[1].name := "empty"
	}
	else
	{
		Loop, 9
		{
			if(Mode != 1)
			{
				break
				return
			}
			if(A_Index <= gNumberOfCharsOnCurrentRealm)
			{
				gMainMenu.childs[tMainItemN].childs[A_Index] := new baseMenuEntryObject
				gMainMenu.childs[tMainItemN].childs[A_Index].parent := gMainMenu.childs[tMainItemN]
				gMainMenu.childs[tMainItemN].childs[A_Index].name := A_Index
				gMainMenu.childs[tMainItemN].childs[A_Index].onAction := Func("gMainMenuchilds1ChildsXGenericAction").Bind(gMainMenu.childs[tMainItemN].childs[A_Index], A_Index)
			}
		}
	}

	UpdateChilds(gMainMenu.childs[tMainItemN])
}

;------------------------------------------------------------------------------------------
WaitForX(waitCycles, ms)
{
	gIgnoreKeyPress = true
	loop % waitCycles
	{
		gosub CheckMode
		if (mode != 1)
		{
			break
			return
		}

		PlayUtterance("wait")
		sleep ms
	}
	gIgnoreKeyPress = false
}

;------------------------------------------------------------------------------------------
EnterCharacterNameHandler()
{
	gIgnoreKeyPress := true
	WaitForX(6, 500)

	tFoundSuccessOrFail := false

	while tFoundSuccessOrFail != true
	{
		if(mode != 1)
		{
			return
		}

		if(A_Index > 40)
		{
			gEnterCharacterNameFlag := false
			gIgnoreKeyPress := false
			PlayUtterance("fail_connection_restart")
			sleep 2000
			gIgnoreKeyPress := false
			SwitchToMode_1()
			Pause
			return
		}
		WaitForX(1, 500)

		;silently click the hardcore warning away
		sleep, 1000
		ty := 555
		Loop, 34
		{
			tmp := UiToScreenNEW(9942, ty)
			MouseMove, tmp.X, tmp.Y, 0
			WaitForX(1, 200)
			Send {Click}
			ty := ty + 3
		}

		if(IsCharSelectionScreen() = true)
		{
			;char created, we're back to char selection screen
			gEnterCharacterNameFlag := false
			PlayUtterance("char_created")
			sleep 1000
			PlayUtterance("selected")
			sleep 600

			tFoundSuccessOrFail := true
			WaitForX(4, 500)

			UpdateCharacterMenu()
			gMainMenu.childs[2].onEnter()

			gIgnoreKeyPress := false
			return
		}
		else
		{
			if(gEnterCharacterNameFlag != false)
			{
				tNoSuccessButtonCheck := false
				tNoSuccessBackdropCheck := false

				If(IsCharCreationScreen() = true and (Is11Popup() = true or Is21Popup() = true))
				{
					tNoSuccessButtonCheck := true
				}

				if((tNoSuccessButtonCheck = true) and IsCharSelectionScreen() = false)
				{
					;char name not available or no char name > retry
					tFoundSuccessOrFail := true

					Send {Enter}
					WaitForX(1, 300)
					send ^a
					WaitForX(1, 100)
					send ^{Backspace}
					WaitForX(1, 100)

					PlayUtterance("fail_name")
				}
			}
		}
	}
	gIgnoreKeyPress := false
}

;------------------------------------------------------------------------------------------
DeleteCharacterNameHandler()
{
	gIgnoreKeyPress := true
	WaitForX(6, 500)

	tFoundSuccessOrFail := false

	while tFoundSuccessOrFail != true
	{
		if(mode != 1)
		{
			return
		}

		if(A_Index > 40)
		{
			gDeleteCharacterNameFlag := false
			gIgnoreKeyPress := false
			PlayUtterance("fail_connection_restart")
			sleep 2000
			gIgnoreKeyPress := false
			SwitchToMode_1()
			Pause
			return
		}
		WaitForX(1, 500)

		if(gDeleteCharacterNameFlag = true)
		{
			if(IsDeleteButtonDisabled() = true)
			{
				WaitForX(1, 300)
				send ^a
				WaitForX(1, 100)
				send ^{Backspace}
				WaitForX(1, 100)

				PlayUtterance("fail_delete_retype_delete_and_press_enter_or_escape")
				sleep 3000
				tFoundSuccessOrFail := true

			}
			else if(IsDeleteButtonEnabled() = true)
			{
				gDeleteCharacterNameFlag := false
				tmpScreen := UiToScreenNEW(9796, 437)
				MouseMove, floor(tmpScreen.X), floor(tmpScreen.Y), 0
				PlayUtterance("char_deleted")
				Send {Click}
				sleep 1500

				tFoundSuccessOrFail := true
				WaitForX(4, 500)

				UpdateCharacterMenu()
				gMainMenu.childs[1].onEnter()

				gIgnoreKeyPress := false
				return
			}
			else
			{
				tFoundSuccessOrFail := true
				WaitForX(4, 500)

				UpdateCharacterMenu()
				gMainMenu.childs[1].onEnter()

				gIgnoreKeyPress := false
				return
			}
		}
		else
		{
			tFoundSuccessOrFail := true
			WaitForX(4, 500)

			UpdateCharacterMenu()
			gMainMenu.childs[1].onEnter()

			gIgnoreKeyPress := false
			return
		}
	}
	gIgnoreKeyPress := false
}

;------------------------------------------------------------------------------------------
; Select modus Keybinds
;------------------------------------------------------------------------------------------
#If mode = 1
	;------------------------------------------------------------------------------------------
	Right::
		if(mode != 1)
		{
			send {Right}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if (gCurrentMenuItem not)
		{
			return
		}
		if (gCurrentMenuItem.childs[1] not)
		{
			gCurrentMenuItem.onEnter()
			return
		}
		gCurrentMenuItem.onSelect()
	return

	;------------------------------------------------------------------------------------------
	Left::
		if(mode != 1)
		{
			send {Left}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if (gCurrentMenuItem not)
		{
			return
		}
		if (gCurrentMenuItem.parent not)
		{
			gCurrentMenuItem.onEnter()
			return
		}

		gCurrentMenuItem.parent.onEnter()
	return

	;------------------------------------------------------------------------------------------
	Up::
		gosub CheckMode
		if(mode != 1)
		{
			send {Up}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if (gCurrentMenuItem not)
		{
			return
		}
		if (gCurrentMenuItem.p not)
		{
			gCurrentMenuItem.onEnter()
			return
		}
		gCurrentMenuItem.p.onEnter()
	return

	;------------------------------------------------------------------------------------------
	Down::
		gosub CheckMode
		if(mode != 1)
		{
			send {Down}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if (gCurrentMenuItem not)
		{
			return
		}
		if (gCurrentMenuItem.n not)
		{
			gCurrentMenuItem.onEnter()
			return
		}
		gCurrentMenuItem.n.onEnter()
	return

	;------------------------------------------------------------------------------------------
	Enter::
		gosub CheckMode
		if(mode != 1)
		{
			send {Enter}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if(gEnterCharacterNameFlag = true)
		{
			PlayUtterance("creating_wait")

			send {Enter}
			EnterCharacterNameHandler()
		}
		else if(gDeleteCharacterNameFlag = true)
		{
			;send {Enter}
			DeleteCharacterNameHandler()
		}
		else
		{
			if (gCurrentMenuItem not)
			{
				return
			}
			gCurrentMenuItem.onAction()
		}
	return

	;------------------------------------------------------------------------------------------
	Escape::
		gosub CheckMode
		if(mode != 1)
		{
			send {Esc}
			return
		}

		if (gIgnoreKeyPress = true)
		{
			;return
		}

		if(gEnterCharacterNameFlag = true)
		{
			gEnterCharacterNameFlag := false

			PlayUtterance("aborting_creation")
			sleep 1500

			tmp := UiToScreenNEW(-160, 749)
			MouseMove, tmp.X, tmp.Y, 0
			Send {Click}

			tTimeout := 0
			while(IsCharSelectionScreen() != true)
			{
				gosub CheckMode
				if(Mode != 1)
				{
					return
				}

				tTimeout := tTimeout + 1
				WaitForX(1, 500)
				if(tTimeout > 60)
				{
					PlayUtterance("fail_connection_restart")
					sleep 2000
					gIgnoreKeyPress := false
					SwitchToMode_1()
					Pause
				return
				}
			}

			gMainMenu.childs[3].onEnter()
		}

		if(gDeleteCharacterNameFlag = true)
		{
			gDeleteCharacterNameFlag := false

			PlayUtterance("aborting_deletion")

			sleep 1000

			if (IsDeleteCancelButton() = true)
			{
				tmp := UiToScreenNEW(10195, 437)
				MouseMove, tmp.X, tmp.Y, 0
				Send {Click}
			}

			tTimeout := 0
			while(IsCharSelectionScreen() != true)
			{
				gosub CheckMode
				if(Mode != 1)
				{
					return
				}

				tTimeout := tTimeout + 1
				WaitForX(1, 500)
				if(tTimeout > 60)
				{
					PlayUtterance("fail_connection_restart")
					sleep 2000
					gIgnoreKeyPress := false
					SwitchToMode_1()
					Pause
				return
				}
			}

			gMainMenu.childs[1].onEnter()
		}
	return
#If

;------------------------------------------------------------------------------------------
; Play modus keybinds; set view 2-5 and mouse position to view 2-5; we don't use view 1 (first person) and 3
;------------------------------------------------------------------------------------
#If mode = 0
	;------------------------------------------------------------------------------------------
	;view 2
	Numpad7::
		gosub CheckMode
		if(mode = 0)
		{
			WinGetPos, X, Y, Width, Height, Program Manager
			Width := Width / 2
			Height := Height / 2 - (Height / 10)
			CoordMode, Mouse, Screen
			MouseMove, %Width%, %Height%
			Send ^{Numpad7}
			Sleep, 500
			SendEvent {Click, right}
		}
	return

	;------------------------------------------------------------------------------------------
	;view 4
	Numpad8::
		gosub CheckMode
		if(mode = 0)
		{
			WinGetPos, X, Y, Width, Height, Program Manager
			Width := Width / 2
			Height := Height / 2 - (Height / 20)
			CoordMode, Mouse, Screen
			MouseMove, %Width%, %Height%
			Send ^{Numpad8}
			Sleep, 500
			SendEvent {Click, left}
		}
	return

	;------------------------------------------------------------------------------------------
	;view 5
	Numpad9::
	i::
		Send i
		gosub CheckMode
		if(mode = 0)
		{
			tmpUI := ScreenToUiNEW(1, 20)
			tRGBColor := GetColorAtUiPos(tmpUI.x, tmpUI.y)
			if (IsColorRange(tRGBColor.r, 255) = true and IsColorRange(tRGBColor.g, 0) = true and IsColorRange(tRGBColor.b, 0) = true)
			{
				WinGetPos, X, Y, Width, Height, Program Manager
				Width := Width / 2
				Height := 5
				CoordMode, Mouse, Screen
				MouseMove, %Width%, %Height%
				Sleep, 250
				SendEvent {Click, right}
				Sleep, 1
				MouseMove, %Width%, %Height%
			}
		}
	return
#If

;------------------------------------------------------------------------------------------
; load data helpers
;------------------------------------------------------------------------------------------
LoadData()
{
	global data := {}
	data.gCharUIPositions := {} ;gCharUIPositions
	data.tRealmLangs := {} ;tRealmLangs
	data.tServerNames := {} ;tServerNames
	data.tGenders := {} ;tGenders
	data.tRaces := {} ;tRaces

	tFirstLine := 1
	Loop
	{
		FileReadLine, line, %A_ScriptDir%\serverlist.ini, %A_Index%
		if(ErrorLevel || InStr(line, "[" . scriptName . "]") > 0)
		{
			tFirstLine := A_Index + 1
			break
		}
	}

	Loop
	{
		FileReadLine, line, %A_ScriptDir%\serverlist.ini, %tFirstLine%
		if(ErrorLevel || InStr(line, "[") > 0)
		{
			break
		}

		tArray := StrSplit(line, "=")

		if(tArray[1] == "gCharUIPositions")
		{
			tValues :=  StrSplit(tArray[2], ",")
			data[tArray[1]][tValues[1]] := {}
			data[tArray[1]][tValues[1]].x := tValues[2]
			data[tArray[1]][tValues[1]].y := tValues[3]
		}
		else if(tArray[1] == "tRealmLangs")
		{
			tValues :=  StrSplit(tArray[2], ",")
			data[tArray[1]][tValues[1]] := {}
			data[tArray[1]][tValues[1]].name := tValues[2]
			data[tArray[1]][tValues[1]].x := tValues[3]
			data[tArray[1]][tValues[1]].y := tValues[4]
		}
		else if(tArray[1] == "tServerNames")
		{
			tValues := StrSplit(tArray[2], ",")
			if(data[tArray[1]][tValues[1]].MaxIndex() == "")
			{
				data[tArray[1]][tValues[1]] := {}
			}
			data[tArray[1]][tValues[1]][tValues[2]] := {}
			data[tArray[1]][tValues[1]][tValues[2]].name := tValues[3]
			data[tArray[1]][tValues[1]][tValues[2]].x := tValues[4]
			data[tArray[1]][tValues[1]][tValues[2]].y := tValues[5]
			data[tArray[1]][tValues[1]][tValues[2]].type := tValues[6]

		}
		else if(tArray[1] == "tGenders")
		{
			tValues := StrSplit(tArray[2], ",")
			data[tArray[1]][tValues[1]] := {}
			data[tArray[1]][tValues[1]].name := tValues[2]
			data[tArray[1]][tValues[1]].x := tValues[3]
			data[tArray[1]][tValues[1]].y := tValues[4]
		}
		else if(tArray[1] == "tRaces")
		{
			tValues := StrSplit(tArray[2], ",")
			data[tArray[1]][tValues[1]] := {}
			data[tArray[1]][tValues[1]].name := tValues[2]
			data[tArray[1]][tValues[1]].x := tValues[3]
			data[tArray[1]][tValues[1]].y := tValues[4]
			data[tArray[1]][tValues[1]].classes := {}
			tValuesClasses := StrSplit(tValues[5], ";")
			Loop % tValuesClasses.MaxIndex()
			{
				data[tArray[1]][tValues[1]].classes[A_Index] := tValuesClasses[A_Index]
			}
		}

		tFirstLine := tFirstLine + 1
	}

	gCharUIPositions := data.gCharUIPositions
	tRealmLangs := data.tRealmLangs
	tServerNames := data.tServerNames
	tGenders := data.tGenders
	tRaces := data.tRaces
}

;------------------------------------------------------------------------------------------
isArray(arrOrObj)
{
	if(ObjMinIndex(arrOrObj) == 1 || ObjCount(arrOrObj) > 0)
	{
		return 5
	}
}

;------------------------------------------------------------------------------------------
join(strArray, depth)
{
	s := ""
	tcount := 0
	for i,v in strArray
	{
		if(isArray(v) == 5)
		{
			Loop, %depth%
			{
				s := s . "`t"
			}
			s := s . i . "`n" . join(v, depth + 1) . "`n"
		}
		else
		{
			;s := s . "`n"
			if(tcount == 0)
			{
				Loop, %depth%
				{
					s := s . "`t"
				}
			}
			s := s . i . " = " . v . ", "

		}
		tcount := tcount + 1
	}
	return s
}