--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561198018770455)

SHARED FILE
]]--
function THIRDPERSON.registerPermission( permission, description, default_access )
	if (THIRDPERSON.permissionsSupport) then
		if ( CAMI ) and not ( ulx or sam or THIRDPERSON.detectRealxAdmin() ) then
			-- Common Admin Mod Interface (CAMI) - https://github.com/glua/CAMI
			-- ULX, SAM, and xAdmin support CAMI, however proper categorization is easily implemented otherwise.
			local CAMI_PRIVILEGE = {
				["Name"] 		= permission,
				["MinAccess"] 	= default_access,
				["Description"] = description,
			};

			CAMI.RegisterPrivilege( CAMI_PRIVILEGE );
		end
		if ulx and SERVER then
			local access = {};
			access.user 	  = ULib.ACCESS_ALL;
			access.admin 	  = ULib.ACCESS_ADMIN;
			access.superadmin = ULib.ACCESS_SUPERADMIN;

			ULib.ucl.registerAccess( permission, access[ default_access ], description, "!ThirdPerson" );
		end
		if sam then
			sam.permissions.add( permission, "!ThirdPerson", default_access );
		end
		if THIRDPERSON.detectRealxAdmin() then
			xAdmin.RegisterPermission( permission, permission, "!ThirdPerson" );
		end
		if evolve and SERVER then
			table.insert( evolve.privileges, permission );

			if THIRDPERSON.evolve.firstrun == true then
				local access = {};
				access.user 	  = "guest";
				access.admin 	  = "admin";
				access.superadmin = "superadmin";

				table.insert( evolve.ranks[ access[ default_access ] ].Privileges, permission );

				if default_access == "user" then
					table.insert( evolve.ranks.respected.Privileges, permission );
					table.insert( evolve.ranks.admin.Privileges, permission );
					table.insert( evolve.ranks.superadmin.Privileges, permission );
				end
				if default_access == "admin" then
					table.insert( evolve.ranks.superadmin.Privileges, permission );
				end
			end
		end
		if serverguard and SERVER then
			if THIRDPERSON.serverguard.firstrun == true then
				function registerSGPerm( unique, permission )
					local permissions = serverguard.ranks:GetData( unique, "Permissions", {} );
					permissions[ permission ] = true;

					serverguard.ranks:SetData( unique, "Permissions", permissions );
					serverguard.netstream.Start( nil, "sgNetworkRankData", { unique, "Permissions", permissions } );
					serverguard.ranks:SaveTable( unique );
				end
				
				local access = {};
				access.user 	  = "user";
				access.admin 	  = "admin";
				access.superadmin = "superadmin";

				registerSGPerm( access[ default_access ], permission );
				
				if default_access == "user" then
					registerSGPerm( "admin", permission );
					registerSGPerm( "superadmin", permission );
				end
				if default_access == "admin" then
					registerSGPerm( "superadmin", permission );
				end
			end
		end
	end
end

-- In place due to an unrelated copycat admin mod known as xAdmin that is free on GitHub
-- !ThirdPerson does not support that admin mod because of how lacking in
-- features it is (no permissions support). 
-- !ThirdPerson supports the xAdmin that is available on gmodstore.
function THIRDPERSON.detectRealxAdmin()
	if ( xAdmin ) then
		if ( xAdmin["RegisterPermission"] ~= nil and xAdmin["RegisterCategory"] ~= nil and xAdmin["Config"] ~= nil and xAdmin.Config["Name"] ~= nil ) then
			return true;
		end
	end

	return false;
end

function THIRDPERSON.hasPermission( pl, permission )
	if (THIRDPERSON.permissionsSupport) then
		if CAMI then
			-- ULX, xAdmin, SAM, and any other admin mods that support CAMI
			local hasAccess = false;
			CAMI.PlayerHasAccess( pl, permission, function( bool, err )
				hasAccess = bool;
			end );
			
			return hasAccess;
		end
		if serverguard then
			if serverguard.player:HasPermission( pl, permission ) then
				return true;
			end
		end
		if evolve then
			if pl:EV_HasPrivilege( permission ) then
				return true;
			end
		end
	end
	if (THIRDPERSON.permissionsSupport == false) || (not ulx and not serverguard and not evolve and not THIRDPERSON.detectRealxAdmin() and not sam and not CAMI) then
		if pl:IsAdmin() and ( table.HasValue( THIRDPERSON.access.User, permission ) or table.HasValue( THIRDPERSON.access.Admin, permission ) ) then
			return true;
		end
		if pl:IsSuperAdmin() and ( table.HasValue( THIRDPERSON.access.User, permission ) or table.HasValue( THIRDPERSON.access.Admin, permission ) or table.HasValue( THIRDPERSON.access.SuperAdmin, permission ) ) then
			return true;
		end
		if table.HasValue( THIRDPERSON.access.User, permission ) then
			return true;
		end
	end
	
	return false;
end

function THIRDPERSON.boolToNumber( bool )
	if bool == true then
		return 1;
	elseif bool == false then
		return 0;
	end
end

function THIRDPERSON.sharedInit()
	if (THIRDPERSON.permissionsSupport) then
		if ( SERVER ) then
			if not file.Exists( "thirdperson", "DATA" ) then
				file.CreateDir( "thirdperson" );
			end

			if evolve then
				if THIRDPERSON.getData( "evolve" ) == false then
					THIRDPERSON.writeData( "evolve", true );
					THIRDPERSON.evolve.firstrun = true;
				end
			else
				if THIRDPERSON.getData( "evolve" ) == true then
					THIRDPERSON.writeData( "evolve", false );
				end
			end

			if serverguard then
				if THIRDPERSON.getData( "serverguard" ) == false then
					THIRDPERSON.writeData( "serverguard", true );
					THIRDPERSON.serverguard.firstrun = true;
				end
			else
				if THIRDPERSON.getData( "serverguard" ) == true then
					THIRDPERSON.writeData( "serverguard", false );
				end
			end
		end

		if ( THIRDPERSON.detectRealxAdmin() and xAdmin.Config.AddonID == 6310 ) then
			xAdmin.RegisterCategory( "!ThirdPerson", "!ThirdPerson", "xadmin/002-settings.png" );
		end
	end
	
	-- Register Permissions --
	THIRDPERSON.registerPermission( "thirdperson_view", "Ability to use !ThirdPerson", "user" );
	THIRDPERSON.registerPermission( "thirdperson_preventwallcollisions", "Ability to turn on and off wall collisions in third-person.", "superadmin" );
	THIRDPERSON.registerPermission( "thirdperson_entityview", "Whether or not viewing certain entities should temporarily switch to first-person.", "user" );
	THIRDPERSON.registerPermission( "thirdperson_crosshair", "Ability to customize their crosshair while in third-person.", "user" );
	THIRDPERSON.registerPermission( "thirdperson_crosshaircolor", "Ability to change the color of their crosshair while in third-person.", "user" );
	THIRDPERSON.registerPermission( "thirdperson_scoping", "Ability to turn on and off first-person scoping while in third-person.", "user" );
	THIRDPERSON.registerPermission( "thirdperson_bulletcorrection", "Ability to turn on and off third-person bullet correction.", "user" );
	THIRDPERSON.registerPermission( "thirdperson_distance", "Ability to change third-person view distance.", "user" );
	THIRDPERSON.registerPermission( "thirdperson_viewangles", "Ability to change third-person vertical and horizontal views.", "user" );
	THIRDPERSON.registerPermission( "thirdperson_bind", "Ability to bind a key to !ThirdPerson.", "user" );
	-- --
end

hook.Add( "InitPostEntity", "thirdperson_shared_init", THIRDPERSON.sharedInit );