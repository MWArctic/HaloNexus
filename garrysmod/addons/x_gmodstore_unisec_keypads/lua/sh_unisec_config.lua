
--[[
	
	Developed by Bobblehead.
	
	Copyright (c) Bobblehead 2016
	
	Please, PLEASE don't leak my script.
	I worked VERY hard on Unisec. If you know someone who needs it but can't afford it, please just ask me and we can work out a deal like adults.
	I'm just trying to make some money to get myself through college.
	If you do leak this script, you will be banned from ScriptFodder. I will know that it was you. Scriptfodder has tools for that.
	
]]--
usec.Config.ToolCategory = "Construction"	--The category of the tool in the spawnmenu
usec.Config.ToolName = "Keypad Doors"		--The name of the tool


--Flickering doors are a feature, not a bug. You can disable them here.
usec.Config.NoStuck = true			--Whether to flicker and buzz if there is something in the way of the door.
usec.Config.NoStuckAttempts = 30	--How many times to flicker and try to close.
usec.Config.NoStuckInterval = .3	--How many seconds between flickers.
usec.Config.NoStuckSound = Sound("buttons/button18.wav") --Sound played when flickering.


usec.Config.CrackerBlipEnabled = true	--Whether to make the keypad cracker blip occasionally and loudly while cracking.
usec.Config.CrackerBlipInterval = 2		--How often to blip, if enabled.
usec.Config.CrackerBlipVolume = 90		--How loudly to blip, if enabled. 75 is quiet, 100 is loud.
usec.Config.CrackerResetPW = false		--Whether to make the keypad cracker randomize the passcode on a successful crack.
usec.Config.CrackerUseRealPW = false	--Whether to use the real passcode of the keypad when cracking it.
usec.Config.CrackerSlot = 3				--Which weapon slot to put the keypad cracker in.
usec.Config.CrackerTimeout = 120		--How long after cracking a keypad that it can be cracked instantly again. 0 to disable.
usec.Config.CrackerMultiKeypad = false	--If set to true, then a player who cracks a keypad will have instant access to ALL keypads linked to all the doors that are unlocked by the cracked keypad. Makes it easier to escape after raiding if the door closes behind you.
usec.Config.CrackerDistance = 42		--How far away the player can get from the keypad while cracking it.

usec.Config.LockpickAllowed = true		--Whether players can lockpick fading doors directly.

usec.Config.UseDelay = .4	--How long the "Access Granted" message is visible and the keypad is unusable on a non-timed keypad.

usec.Config.AlwaysShowCable = false			--Whether to show cables between fading doors and keypads
usec.Config.ShowCableInCracker = false		--Whether to show cables between fading doors and keypads while holding the keypad cracker.
usec.Config.ShowCableInAdminCracker = true	--Whether to show cables between fading doors and keypads while holding the ADMIN keypad cracker.

usec.Config.AllowPasscode = true	--Whether to require passcodes on doors for unauthorized users.
usec.Config.ShowCursor = true		--Whether to show the cursor when the number pad is visible.

usec.Config.LimitFailMessage = "%s limit reached. Donate to increase the limit!" --The message to display when a limit is reached. `%s` is replaced with "Keypad" or "Door" depending on which limit is hit.

usec.Config.MaxLogs = 1000	--How many usage logs to keep per keypad before old ones get tossed out.

usec.Config.UseWorkshop = true	--If true, players will download the materials for this script from the workshop. False will be fastdl.


--The following is a list of limits for each usergroup. You can add your own usergroups.
--For example, you can set `["donator"] = 10` and all groups ABOVE that on the chain will get 10.
usec.Config.Limits = {
	
	--How many keypads a player can have. -1 means no limit. 0 means none allowed.
	Keypads = {
		["user"] = 3,
		["donator"] = 5,
		["admin"] = -1,
	},
	
	--How many fading doors a player can have. -1 means no limit. 0 means none allowed.
	Doors = { 
		["user"] = 5,
		["donator"] = 10,
		["admin"] = -1,
	},
	
	--Minimum time in seconds a timed fading door must remain open. -1 means no limit.
	MinimumOpenTime = { 
		["user"] = 2.5,
	},
	
	--Time between digit checks while cracking the code. Larger numbers can make it take more time to crack a code.
	CrackerSpeed = {
		["user"] = 1,
		["donator"] = .5,
	},
	
	--Maximum price to charge for paid entry. -1 means no limit. Do not exceed 58462725.
	MaximumPrice = {
		["user"] = 2000,
		["donator"] = 5000,
		["admin"] = -1,
	},
}

--These permissions follow the inheritance chain. Just replace the quoted text with the lowest usergroup you want to have permission.
--If you don't want anyone to have permission, use a non-existant usergroup, such as "disallowed".
usec.Config.Permissions = {
	ToggleDoor = "user",		--Who can create toggling doors.
	TimedDoor = "user",			--Who can create timed doors.
	KeybindOutput = "user",		--Who can bind the keypad to output to a key
	PaidDoor = "donator",		--Who can create paid doors.
	PermanentKeypad = "admin",	--Who can create permanent keypads. Doesn't work yet, please ignore it.
	TargetNonProp = "admin",	--Who can create a door from non-props, such as entities or map doors.
	EditUnowned = "admin",		--Who can view and edit keypads which they don't own.
}

--Some language settings for the tool for easy access:
if CLIENT then
	language.Add("undone_unisec_door",			 "Undone Door")
	language.Add("undone_unisec_keypad",		 "Undone Keypad")
	language.Add("tools.secdoors.inverse3",		 "Start faded")
	language.Add("tools.secdoors.inverse3.help", "If checked, the door will have the opposite status of a regular door.")
	language.Add("tools.secdoors.pw.help",		 "4-digit passcode for all keypads created.")
	language.Add("tool.secdoors.desc",			 "Create doors and keypads.")
	language.Add("tool.secdoors.left",			 "Click a prop to create a fading door.")
	language.Add("tool.secdoors.left2",			 "Now click somewhere to create a keypad, or click an existing keypad to link/unlink.")
	language.Add("tool.secdoors.right",			 "Right click a prop to create a fading door and keypad simultaneously.")
	language.Add("tool.secdoors.reload",		 "Reload to edit a keypad's settings.")
	language.Add("tool.secdoors.name",			 usec.Config.ToolName)
end