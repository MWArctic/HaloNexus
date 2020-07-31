--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561198018770455)

CLIENTSIDE FILE
]]--

function THIRDPERSON.getCrosshairColor()
	if THIRDPERSON.hasPermission( LocalPlayer(), "thirdperson_crosshaircolor" ) then
		local r = cvars.Number( "thirdperson_crosshair_color_r" );
		local g = cvars.Number( "thirdperson_crosshair_color_g" );
		local b = cvars.Number( "thirdperson_crosshair_color_b" );
		local a = cvars.Number( "thirdperson_crosshair_color_a" );

		return Color( r, g, b, a );
	else
		local colors = string.Explode( ",", string.gsub( THIRDPERSON.default.CrosshairColor, "%s+", "" ) );

		local r = tonumber( colors[1] );
		local g = tonumber( colors[2] );
		local b = tonumber( colors[3] );
		local a = tonumber( colors[4] );
		
		return Color( r, g, b, a );
	end
end

function THIRDPERSON.resetSetting( pl, cmd, setting )
	setting = setting[1];

	if ( setting == nil or ( THIRDPERSON.permissions[ "thirdperson_" .. setting ] == nil and setting ~= "all" and setting ~= "crosshaircolor" ) ) then
		if ( THIRDPERSON.broadcastChat ) then
			chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Please provide a valid setting to reset. If all, use the argument 'all'." );
		end
		return;
	end

	function resetCrosshairColor()
		local colors = string.Explode( ",", string.gsub( THIRDPERSON.default.CrosshairColor, "%s+", "" ) );

		local r = tonumber( colors[1] );
		local g = tonumber( colors[2] );
		local b = tonumber( colors[3] );
		local a = tonumber( colors[4] );
		
		RunConsoleCommand( "thirdperson_crosshair_color_r", r );
		RunConsoleCommand( "thirdperson_crosshair_color_g", g );
		RunConsoleCommand( "thirdperson_crosshair_color_b", b );
		RunConsoleCommand( "thirdperson_crosshair_color_a", a );
	end

	if setting == "all" then
		for permission, configuration in pairs( THIRDPERSON.permissions ) do
			if permission == "thirdperson_view" then
				continue;
			end
			local value = THIRDPERSON.default[ configuration ];
			if type( value ) == "boolean" then
				RunConsoleCommand( permission, THIRDPERSON.boolToNumber( value ) );
			else
				RunConsoleCommand( permission, value );
			end
		end

		resetCrosshairColor();

		if ( THIRDPERSON.broadcastChat ) then
			chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "All Third-Person settings have been reset to their default values." );
		end
	elseif setting == "crosshaircolor" then
		resetCrosshairColor();
		if ( THIRDPERSON.broadcastChat ) then
			chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "The ", Color(243, 156, 18), "crosshaircolor", Color(255, 255, 255), " setting has been reset to its default value." );
		end
	else
		local value = THIRDPERSON.default[ THIRDPERSON.permissions[ "thirdperson_" .. setting ] ];

		if type( value ) == "boolean" then
			RunConsoleCommand( "thirdperson_" .. setting, THIRDPERSON.boolToNumber( value ) );
		else
			RunConsoleCommand( "thirdperson_" .. setting, value );
		end

		if ( THIRDPERSON.broadcastChat ) then
			chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "The ", Color(243, 156, 18), setting, Color(255, 255, 255), " setting has been reset to its default value." );
		end
	end
end

local function autoCompleteReset()
	local tbl = { "thirdperson_reset all", "thirdperson_reset crosshaircolor" };

	for configuration, type in pairs( THIRDPERSON.configuration ) do
		configuration = string.gsub( configuration, "thirdperson_", "" );
		table.insert( tbl, "thirdperson_reset " .. configuration );
	end

	return tbl;
end

concommand.Add( "thirdperson_reset", THIRDPERSON.resetSetting, autoCompleteReset );

local function toggleThirdPerson()
	if THIRDPERSON.client.thirdperson_view then
		RunConsoleCommand( "thirdperson_view", "0" );

		if THIRDPERSON.hasPermission( LocalPlayer(), "thirdperson_view" ) then
			if ( THIRDPERSON.broadcastChat ) then
				chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Third-person mode has been disabled." );
			end
		else
			if ( THIRDPERSON.broadcastChat ) then
				chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 50 ,50), "Error: ", Color(255, 255, 255), "You do not have permission to change your third-person state." );
			end
		end
	else
		RunConsoleCommand( "thirdperson_view", "1" );

		if THIRDPERSON.hasPermission( LocalPlayer(), "thirdperson_view" ) then
			if ( THIRDPERSON.broadcastChat ) then
				chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 255, 255), "Third-person mode has been enabled. Use ", Color(243, 156, 18), THIRDPERSON.menuCommands[1], Color(255, 255, 255), " for settings." );
			end
		else
			if ( THIRDPERSON.broadcastChat ) then
				chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(255, 50 ,50), "Error: ", Color(255, 255, 255), "You do not have permission to change your third-person state." );
			end
		end
	end
end

concommand.Add( "thirdperson_toggle", toggleThirdPerson ); -- ConCommand. Changing this *will* break the addon.

function THIRDPERSON.runChecks( weapon )
	-- Zoom Compatibility --
	if LocalPlayer():KeyDown( IN_ZOOM ) and LocalPlayer():GetCanZoom() then
		return true;
	end
	-- --

	-- Observer Mode Compatibility --
	if LocalPlayer():GetObserverMode() ~= OBS_MODE_NONE then
		return true;
	end
	-- --

	-- Vehicle & Sit Anywhere Compatibility --
	if LocalPlayer():InVehicle() && ( LocalPlayer():GetVehicle():GetClass() ~= "prop_vehicle_prisoner_pod" ) then
		return true;
	end
	-- --

	-- Spectator Team  --
	if LocalPlayer():Team() == TEAM_SPECTATOR then
		return true;
	end
	-- --

	if IsValid( weapon ) then
		-- Weapon Scoping Support --
		if THIRDPERSON.client.thirdperson_scoping then

			-- General Iron Sights and M9K Support --
			if ( weapon.GetIronsights and weapon:GetIronsights() ) and not LocalPlayer():KeyDown( IN_SPEED ) then
				return true;
			end
			-- --

			-- FA:S 2 Support --
			if weapon.IsFAS2Weapon and weapon.dt and ( weapon.dt.Status == FAS_STAT_ADS or weapon.dt.Status == FAS_STAT_CUSTOMIZE ) then
				return true;
			end
			-- --

			-- Customizable Weaponry 2.0 Support --
			if weapon.CW20Weapon and weapon.dt then
				if weapon.dt.State == CW_CUSTOMIZE then
					return true;
				end
				if weapon.dt.State == CW_AIMING then
					return true;
				end
			end
			-- --

			-- TFA Support --
			if ( weapon.IsTFAWeapon and weapon:GetIronSights() ) then
				return true;
			end
			-- --

		end
		-- --

		-- gPhone Support --
		if weapon:GetClass() == "gmod_gphone" or weapon.PrintName == "gPhone" then
			return true;
		end
		-- --

		-- ARCPhone and General Phone Support --
		if weapon.PrintName == "Phone" then
			return true;
		end
		-- --

	    -- Lockpicking & Keypad Cracking Support --																																																															// 76561198018770455
		if THIRDPERSON.LockpickKeypadcrack then
			if ( weapon.IsDarkRPLockpick or weapon:GetClass() == "lockpick" or weapon:GetClass() == "pro_lockpick" ) then
				if ( weapon.dt and weapon:GetIsLockpicking() ) then
					return true;
				end
			end
		
			if weapon:GetClass() == "keypad_cracker" and weapon.dt and weapon.IsCracking then
				return true;
			end
		end
		-- --

		-- Configurable Weapons Support --
		if ( THIRDPERSON.weapons[ weapon:GetClass() ] == true ) then
			return true;
		elseif ( THIRDPERSON.weapons[ weapon:GetClass() ] ~= nil && type( THIRDPERSON.weapons[ weapon:GetClass() ] ) == "function" ) then
			local customWeaponCheck = THIRDPERSON.weapons[ weapon:GetClass() ];
			if ( customWeaponCheck( weapon ) == true ) then
				return true;
			end
		end
		-- --

		-- Entity Support --
		if THIRDPERSON.client.thirdperson_entityview then
			local ent = {};
			ent.entity = LocalPlayer():GetEyeTrace().Entity;

			if ent.entity:IsValid() then
				ent.distance = LocalPlayer():EyePos():Distance( ent.entity:GetPos() );
				ent.class = ent.entity:GetClass();
			else
				ent.entity = nil;
				ent.distance = nil;
				ent.class = nil;
			end

			if THIRDPERSON.entities[ ent.class ] ~= nil then
				if ent.distance <= THIRDPERSON.entities[ ent.class ] then
					return true;
				end
			end
		end
		-- --

		-- Three's Builder Support (https://www.gmodstore.com/market/view/5501) --
		if ( ThreesBuilder and ThreesBuilder.IsBuilding ) then
			return true;
		end
		-- --

		-- Gamemode Prophunt Enhanced Support (https://github.com/prop-hunt-enhanced/prop-hunt-enhanced) --
		if ( PHE and (gmod.GetGamemode().Name == "Prop Hunt: ENHANCED" or gmod.GetGamemode().Name == "Prop Hunt: ENHANCED PLUS") ) then
			if ( LocalPlayer():GetNWBool("isBlind") ) then
				return true;
			end
		end
		-- --

		-- Gamemode Prop Hunt support (https://github.com/andrewtheis/prophunt; https://github.com/kowalski7cc/prophunt-hidenseek-original) --
		if ( gmod.GetGamemode().Name == "Prop Hunt" ) then
			if ( blind ) then
				return true;
			end
		end
		-- --
	else
		return false;
	end
end
    
local function DrawThirdPerson( pl )
	if THIRDPERSON.client.thirdperson_view and ( LocalPlayer():Alive() and LocalPlayer():IsValid() ) then

		-- Weapon Scope Compatibility --																																																															// 76561222104720366
		local weapon = pl:GetActiveWeapon();

		if THIRDPERSON.runChecks( weapon ) then
			return;
		end
		-- --

		return true;
	end
end
    
hook.Add( "ShouldDrawLocalPlayer", "DrawThirdperson", DrawThirdPerson );
    
local function viewThirdPerson( pl, pos, angles, fov )
	if THIRDPERSON.client.thirdperson_view and ( pl:Alive() and pl:IsValid() ) and not THIRDPERSON.runChecks( pl:GetActiveWeapon() ) then
		local offsets = {};

		if THIRDPERSON.client.thirdperson_horizontalview < -50 then
			offsets.right = -50;
		elseif THIRDPERSON.client.thirdperson_horizontalview > 50 then
			offsets.right = 50;
		else
			offsets.right = THIRDPERSON.client.thirdperson_horizontalview;
		end

		if THIRDPERSON.client.thirdperson_verticalview < -50 then
			offsets.up = -50;
		elseif THIRDPERSON.client.thirdperson_verticalview > 50 then
			offsets.up = 50;
		else
			offsets.up = THIRDPERSON.client.thirdperson_verticalview;
		end

		if THIRDPERSON.client.thirdperson_distance < 0 then
			offsets.distance = 0;
		elseif THIRDPERSON.client.thirdperson_distance > THIRDPERSON.maxDistance then
			offsets.distance = THIRDPERSON.maxDistance;
		else
			offsets.distance = THIRDPERSON.client.thirdperson_distance;
		end

		local view = {};
		local trace = {};

		view.origin = pos - ( angles:Forward() * offsets.distance ) + ( angles:Right() * offsets.right ) + ( angles:Up() * offsets.up );

		if THIRDPERSON.client.thirdperson_preventwallcollisions == true then
			trace.start  = pos;
			trace.endpos = view.origin;
			trace.filter = pl;
			
			local trace = util.TraceLine( trace )
			
			if trace.Fraction <	1.0 then
				view.origin = trace.HitPos + trace.HitNormal * 5;
			end
		end

		view.angles = angles;
		view.fov = fov;
		return view;
	end
end
    
hook.Add( "CalcView", "viewThirdperson", viewThirdPerson );

local function correctBulletsThirdPerson( entity, data )
	if entity:IsValid() and THIRDPERSON.client.thirdperson_view and THIRDPERSON.client.thirdperson_bulletcorrection and THIRDPERSON.client.thirdperson_crosshair == "None" then
		if not data then
			return;
		end

		local weapon = entity:GetActiveWeapon();

		if weapon.IsFAS2Weapon then
			return;
		end

		if weapon.CW20Weapon then
			return;
		end

		local offset = Vector( 0, 0, 0 );
		if data.Dir:GetNormal() ~= entity:GetAimVector():GetNormal() then
			offset = ( data.Dir:GetNormal() - entity:GetAimVector():GetNormal() );
		end
		
		local cm = ( viewThirdPerson( entity, entity:EyePos(), entity:EyeAngles(), 10, 0, 0 ) );

		if not cm then
			return;
		end
		
		local trace = util.TraceLine( { start = cm.origin, endpos = cm.origin + ( ( cm.angles:Forward() + offset ) * 100000 ), filter = entity, mask = MASK_SHOT } )

		if not ( trace.Hit and trace.HitPos ) then
			return;
		end
		
		data.Dir = ( trace.HitPos - data.Src ):GetNormal();
		
		return true;
	end
end

hook.Add( "EntityFireBullets", "thirdperson_bulletcorrections", correctBulletsThirdPerson );

local function chatThirdPerson( pl, text, teamChat, isDead )
	if ( pl != LocalPlayer() ) then
		return;
	end

	if ( string.lower( text ) == "!thirdperson entity" ) then

		if ( not LocalPlayer():IsAdmin() ) then
			if ( THIRDPERSON.broadcastChat ) then
				chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(192, 57, 43), "Admin: ", Color(255, 255, 255), "You do not have access to this command." );
			end
			return true;
		end

		local ent = {};
		ent.entity = LocalPlayer():GetEyeTrace().Entity;

		if ent.entity:IsValid() then
			ent.distance = LocalPlayer():EyePos():Distance( ent.entity:GetPos() );
			ent.class = ent.entity:GetClass();
		else
			ent.entity = nil;
			ent.distance = nil;
			ent.class = nil;
		end

		if ( ent.entity == nil or ent.class == nil or ent.distance == nil ) then
			chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(192, 57, 43), "Admin: ", Color(255, 255, 255), "No entities were found. Please look directly at the entity before running the command." );
			return true;
		else
			chat.AddText( Color(80, 215, 23), "[!ThirdPerson] ", Color(192, 57, 43), "Admin: ", Color(255, 255, 255), "The entity you are looking at is: ", Color(61, 61, 61), ent.class, Color(255, 255, 255), " (distance: " .. math.Round( ent.distance ) ..")" );
			return true;
		end
	end
end

hook.Add( "OnPlayerChat", "chatThirdPersonClient", chatThirdPerson );

THIRDPERSON.bindDown = false;

function THIRDPERSON.bindThirdPerson()
	if ( THIRDPERSON.client.thirdperson_bind ~= "none" and THIRDPERSON.client.thirdperson_bind ~= nil ) then
		local bind = input.GetKeyCode( THIRDPERSON.client.thirdperson_bind );

		local validBind = ( bind >= KEY_FIRST and bind <= KEY_LAST )
		if ( not LocalPlayer():IsTyping() and bind and bind ~= KEY_ESCAPE and ( ( validBind and input.IsKeyDown( bind ) ) or ( input.IsMouseDown( bind ) and not validBind ) ) ) then
			if ( not THIRDPERSON.bindDown ) then 
				RunConsoleCommand( "thirdperson_toggle" );
			end
			THIRDPERSON.bindDown = true;
		else
			THIRDPERSON.bindDown = false;
		end
	end
end

hook.Add( "Think", "THIRDPERSON.bindThirdPerson", THIRDPERSON.bindThirdPerson );