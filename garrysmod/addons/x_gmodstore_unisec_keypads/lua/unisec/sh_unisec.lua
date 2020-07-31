 
--[[
	
	Developed by Bobblehead.
	
	Copyright (c) Bobblehead 2016
	
]]--
local ENTITY = FindMetaTable("Entity")
AccessorFunc(ENTITY,"fadeActive","Faded",FORCE_BOOL)
-- function ENTITY:SetFaded(b)
	-- self.usec_faded = b
	-- self:SetNWBool("usec_faded",b)
-- end
-- function ENTITY:GetFaded()
	-- if SERVER then
		-- return self.usec_faded or false
	-- else
		-- return self:GetNWBool("usec_faded",false)
	-- end
-- end

-- //This way it still collides with world.
-- hook.Add("ShouldCollide","usec_FadedCollisions",function(ent1,ent2) 
	-- if IsValid(ent1) and ent1:GetFaded() then
		-- return ent2:IsWorld()
	-- elseif IsValid(ent2) and ent2:GetFaded() then
		-- return ent1:IsWorld()
	-- end
-- end)

function usec.RandomPW()
	return Format("%04d",math.random(0,9999))
end

function usec.IsPW(pw)
	if pw then
		local i=0
		for letter in string.gmatch(pw,".") do
			if not pw:match("%d") then
				return false
			end
			i=i+1
		end
		if i!=4 then return false end
		
		return true
	else
		return false
	end
end

function usec.InBounds(mx,my,x1,y1,w,h)
	return (mx > x1 and mx < x1+w and my > y1 and my < y1+w)
end


local meta = FindMetaTable("Player")

function meta.UsecLimit(ply,limit)
	assert(usec.Config.Limits[limit]!=nil, "Tried to get a limit which does not exist: "..limit.."\n")
	
	if usec.Config.Limits[limit][ply:GetUserGroup()] then
		return usec.Config.Limits[limit][ply:GetUserGroup()]
	end
	
	local copy = {}
	local i = 0
	for k,v in pairs(usec.Config.Limits[limit]) do
		i=i+1
		copy[i]={k,v}
	end
	table.sort(copy,function(a,b) return (a[2] == -1) and (a[2] < b[2]) end)
	
	
	local adminfunc = ply.CheckGroup and ply.CheckGroup or ply.IsUserGroup
	for k,v in ipairs(copy) do
		if adminfunc(ply,v[1]) then
			return v[2]
		end
	end
	
	return -1
	
end
function meta.UsecPermission(ply,perm)
	assert(usec.Config.Permissions[perm]!=nil, "Tried to get a permission which does not exist: "..perm.."\n")
	local adminfunc = ply.CheckGroup and ply.CheckGroup or ply.IsUserGroup
	
	return adminfunc(ply,usec.Config.Permissions[perm])
	
end
if not meta.CheckGroup then
	timer.Simple(.01,function()
		if serverguard then
			function meta:CheckGroup(rank)
				local rankData = serverguard.ranks:GetRank(rank);

				if (rankData) then
					return serverguard.player:GetImmunity(self) >= rankData.immunity;
				end;
				
				return false
			end;
		end
		if xAdmin then
            function meta:CheckGroup(group)
				return self:CanTargetGroup(group)
            end
        end
	end)
end

hook.Add("canLockpick", "usec_lockpick", function( ply, ent, trace)
	if usec.Config.LockpickAllowed then
		for k,v in pairs(ents.FindByClass("uni_keypad"))do
			if table.HasValue(v:GetDoors(),ent) then
				ply.usec_picking = v
				return true
			end
		end
	end
end)
hook.Add("onLockpickCompleted", "usec_lockpick", function(ply, success, ent)
	if IsValid(ply.usec_picking) then
		if success then
			ply.usec_picking:AccessGranted()
			ply.usec_picking:LogAccess()
		end
	end
	ply.usec_picking = false
end)

//Error prevent:
Wire_TriggerOutput = Wire_TriggerOutput or function() end
