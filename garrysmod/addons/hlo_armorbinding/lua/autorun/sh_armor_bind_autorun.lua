
AddCSLuaFile("sh_armor_bind.lua")
AddCSLuaFile("cl_armor_bind.lua")
include("sh_armor_bind.lua")
include(        "cl_armor_bind.lua")

steamworks.DownloadUGC( 284860008, function( name )
	print (name .. "MOUNTED")
	game.MountGMA( name )
end) 