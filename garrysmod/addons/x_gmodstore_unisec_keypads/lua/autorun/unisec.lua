
--[[
	
	Developed by Bobblehead.
	
	Copyright (c) Bobblehead 2016
	
]]--

usec = {}
usec.Config = {}

include("sh_unisec_config.lua")
include("unisec/sh_unisec.lua")

if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("sh_unisec_config.lua")
	AddCSLuaFile("unisec/cl_unisec.lua")
	AddCSLuaFile("unisec/vgui_dooroptions.lua")
	AddCSLuaFile("unisec/sh_unisec.lua")
	
	include("unisec/sv_unisec.lua")
	include("unisec/sv_permadoor.lua")
else
	include("unisec/cl_unisec.lua")
	include("unisec/vgui_dooroptions.lua")
end