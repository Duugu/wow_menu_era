IMPORTANT SET UP STEPS. DO THIS:
1. Copy the folder "wow menu era" from the downloaded .zip file to some local location on your computer.
2. Go to the folder "wow menu era"" that you've just copied.
3. (Optional) Create a shortcut to the appropiate script (wow-menu EN EU.ahk or wow-menu EN US.ahk, depending on your language/region combination) on you desktop, to easily start the script if you start playing the game.
4. Go to the folder "Copy The Content Of This Folder To Interface" in you "wow menu era" folder. There should be 3 folders in there.
5. Copy all 3 folders ("DialogFrame", "GLUES", "HELPFRAME").
6. Go to the "Interface" folder ("C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface").
7. Insert the just copied 3 folders in that "Interface" folder.
8. You are done!
Caution: You need to really carefully follow the instructions above. Do NOT just copy the full "wow_menu" folder from the downloaded .zip file to "Interface". That won't work.

----------------------------------------------------------------------------------------

1. What is the script doing?

The script has two modes: "Login" and "Play". You can switch between them with ALT + F1.
In "Login" mode, you can select characters and enter the game world with them, create new characters, switch to another server or delete characters.
In "Play" mode, you can use the NUMPAD 7 to do a right click at your feet in the game world. NUMPAD 8 is doing a left click at your feet in the game world. NUMPAD 9 is to auto align to the current audio beacon in the game world
Use ALT + ESCAPE to unload/end the script.

2. Usage

Start the script by launching the correct file for your language and region:
- If you are playing on US servers: wow-menu era EN US.ahk
- If you are playing on EU servers in English: wow-menu era EN EU.ahk
- If you are playing on EU servers in German: wow-menu era DE EU.ahk
The script starts in "Login" mode. It gets active only after you started WoW and the WoW window gets the focus.
Then it tries to detect the character selection page, or it waits until you are logged in to WoW and the character selection page is loaded. As long as the script is doing any recognition or waits, you will hear a sound. The sound means that you have to wait.
Don't press any key, don't switch the window and don't do anything else while the sound is playing. Never. Nowhere in the menu. Raise your hands in the air while the sound is playing.
Once you get to the character selection page, the audio menu opens. It says "Main Menu." You can navigate to the submenu with options using the RIGHT ARROW key. The use DOWN and UP keys to choose menu options in that submenu.
To log in with a character, you first need to select that character, and then log in with the selected character.
There are no character names recognized or read out. The script only reads "1, 2, 3 to 10" for the character slots. You have to remember what character is in each slot (just take a note for every new character you're creating).
Newly created chars always end up in the next free slot. If you already have 3 characters and you create a new one, it will be in slot 4.
After logging in, the script automatically switches to "Play" mode. When logging out it automatically switches to "Login" mode. If that doesn't work, you can use ALT + F1 to manually switch.

3. Requirements:

- The script is only working with WoW Era on Windows. No Mac, no Retail.
- Do not move the script file and its folder. Create a shortcut to the script file, if you would like to access it more easily.
- The script requires that you are playing in fullscreen mode. (This is the default).
- The script requires the same screen resolution in WoW as the Windows screen resolution is (this is the default).

----------------------------------------------------------------------------------------

RELEASE NOTES

Release notes:
	4.2
		- Update for Classic Era servers
	3.13
		- Better Social contract detection.
	3.12
		- Added support for auto pause if dial targeting is enabled.
		- Social contract will be auto accepted again.
	3.11
		- Fixed an issue with ultra wide screens with higher ratio than 1.77.
	3.10
		- Tried to fix an issue with the social contract not auto-accepted on first login. No sure if that worked out, as I can't test it.
	3.9
		- Fixed an issue with the EN US script.
	3.8
		- Added the missing sound file for US East Eranikus.
	3.7
		- Server lists for US and EU updated.
		- Missing Bloodelfs re-added to the character creation menu.
		- Added server types to the server names.
	3.6
		- Fixed a bug with creating a new character and class Mage.
	3.5
		- Updated the US East server list.
	3.4
		- Fixed a bug with the US EN version of the script
	3.3
		- Tried to fix the auto accept for the contract. I can't test the fix, as I already have accepted the contract. Any feedback would be welcome.
		- action for numpad 7 and 8 changed:
			- numpad7: right click in front of you (was right click at your feet)
			- numpad8: left click at your feet (to use area of effect spells that need to be targeted on the ground via left clicking in the game world)

	3.2
		- Social contract on first login will be auto accepted
		- Loading outdated addons will be auto accepted
		- Removed Shazzrah from the english EU server list
	3.1
		- Updated list for US west, US east and EU English with new servers
	3.0
		- Initial release for WotLK