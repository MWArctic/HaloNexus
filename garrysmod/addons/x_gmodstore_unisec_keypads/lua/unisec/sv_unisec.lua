
--[[
	
	Developed by Bobblehead.
	
	Copyright (c) Bobblehead 2016
	
]]--

util.AddNetworkString("usec_sync")
util.AddNetworkString("usec_keypad")
util.AddNetworkString("usec_paid_door")
util.AddNetworkString("usec_doors")
util.AddNetworkString("usec_c4anim")
util.AddNetworkString("usec_crack")
util.AddNetworkString("usec_init")

if usec.Config.UseWorkshop then
	resource.AddWorkshop("719497720")
else
	resource.AddFile("materials/gmaps/reverse.png")
	resource.AddFile("materials/gmaps/skip.png")
	resource.AddFile("materials/unisec/accessgranted.png")
	resource.AddFile("materials/unisec/accessdenied.png")
	resource.AddFile("materials/unisec/fingerprint.png")
	resource.AddFile("materials/unisec/unisecopyright_white.png")
	resource.AddFile("materials/unisec/cracker.vmt")
	resource.AddFile("resource/fonts/agencyb.ttf")
	resource.AddFile("resource/fonts/agencyr.ttf")
	resource.AddFile("resource/fonts/ocrastd.ttf")
end

ServerLog("Successfully Loaded Unisec!\n")
print("Successfully loaded Unisec!")

net.Receive("usec_c4anim",function(len,ply)
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass():find("cracker") then
		wep.IsCracking = false
		wep:SendWeaponAnim(ACT_VM_DRAW)
	end
end)
net.Receive("usec_crack",function(len,ply)
	local wep = net.ReadEntity()
	if not ply:Alive() then return end
	if ply:GetActiveWeapon() != wep then return end
	if engine.ActiveGamemode() == "darkrp" and ply:isArrested() then return end
	
	if IsValid(wep) and wep:GetClass():find("cracker") then
		wep.IsCracking = false
		wep:SendWeaponAnim(ACT_VM_DRAW)
		local ent = net.ReadEntity()
		local pw = net.ReadString()
		
		if ply:GetShootPos():DistToSqr(ent:GetPos()) > usec.Config.CrackerDistance^2 then return end
		
		local passcode = usec.Config.CrackerUseRealPW and ent:GetPW() or ent:GetCrackerPW()
		if ent:IsValid() and pw == passcode then
			if usec.Config.CrackerResetPW then
				ent:SetPW(usec.RandomPW())
			end
			ent:AccessGranted()
			ent:LogAccess()
			wep.Keypads[ent:EntIndex()] = CurTime()
		end
	end
	
end)

net.Receive("usec_paid_door",function(len,ply)
	local door = net.ReadEntity()
	local paid = net.ReadBool()
	local price,creator = door:GetPrice(),door:GetUCreator()
	
	local tr = ply:GetEyeTrace()
	local keypad = tr.Entity
	
	if keypad:GetClass() != "uni_keypad" then
		return
	end

	if DarkRP then
		if paid and ply:canAfford(price) then
			ply:addMoney(-price)
			if creator:IsValid() and not creator:IsWorld() then
				creator:addMoney(price)
			end
			DarkRP.notify(ply,NOTIFY_GENERIC,3,"You paid $"..price.." to use the keypad.")
			door:AccessGranted()
			door:LogAccess(ply,true)
		elseif not paid then
			door:AccessDenied()
		else
			DarkRP.notify(ply,1,4,"You don't have $"..price.."!")
			door:AccessDenied()
		end
	end
end);

net.Receive("usec_keypad",function(len,ply)
	local keypad = net.ReadEntity()
	
	if not IsValid(keypad) then return end
	if not (ply == keypad:GetUCreator() or ply:UsecPermission("EditUnowned")) then return end
	local mp = ply:UsecLimit("MaximumPrice")
	local open = ply:UsecLimit("MinimumOpenTime")
	local was = keypad:GetPermanent() and keypad:GetPermID() or false
	
	local allow = net.ReadTable()
	
	local timed = net.ReadBool()
	local timer = net.ReadFloat()
	local delay = net.ReadFloat()
	
	local paid = net.ReadBool()
	local price = net.ReadFloat()
	local authpay = net.ReadBool()
	
	local toggle = net.ReadBool()
	local togglemode = net.ReadUInt(3)
	local allclose = net.ReadBool()
	
	local pass = net.ReadString()
	
	local perm = net.ReadBool()
	local permid = net.ReadString()
	
	local hkey = net.ReadBool()
	local akey = net.ReadUInt(8)
	local fkey = net.ReadUInt(8)
	
	keypad:SetFilter(allow)
	
	keypad:SetTimed(timed)
	keypad:SetTimer(math.max(open==-1 and .1 or open,timer))
	keypad:SetDelay(delay)
	
	keypad:SetPaid(paid);
	keypad:SetPrice(math.ceil(math.min(price,mp==-1 and 100000000 or mp)))
	keypad:SetAuthPay(authpay)
	
	keypad:SetToggle(toggle)
	keypad:SetToggleMode(togglemode)
	keypad:SetAllClose(allclose)
	
	keypad:SetPW(pass)
	
	keypad:SetHotkeys(hkey)
	keypad:SetKeyAccess(akey)
	keypad:SetKeyFail(fkey)
	
	keypad:SetPermanent(perm)
	keypad:SetPermID(permid)
	if was then
		usec.DeleteKeypad(was)
	end
	if perm then
		usec.WriteKeypad(keypad)
	end
	
	
end)

local ENTITY = FindMetaTable("Entity")
--Make any entity fade out. Attempt is for no-stick and is optional.
function ENTITY:Fade(b,attempt)
	if !IsValid(self) then return end
	if self:GetClass():find("func_door") then  end
	if self.usec_inversefade then b = not b end
	if b then
		--Cancel nostick
		if timer.Exists("usec_fade_retry"..self:EntIndex()) then
			timer.Remove("usec_fade_retry"..self:EntIndex())
			timer.Remove("usec_fade_retry_blip"..self:EntIndex())
			self:SetMaterial(self.usec_oldMat)
			self.usec_oldMat = nil
			self:SetFaded(false)
		end
		
		--Fade the door.
		if self:GetFaded() then return end
		self:SetNotSolid(true)
		-- self:SetSolid(SOLID_NONE)
		-- self:SetCustomCollisionCheck( true )
		-- self:CollisionRulesChanged()
		self.usec_oldMat = self:GetMaterial()
		self:SetMaterial("sprites/heatwave")
		self:SetFaded(true)
		self:EmitSound("buttons/button6.wav")
		self:DrawShadow(false)
		
	elseif self:GetFaded() then
	
		--Attempt to no-stick.
		if usec.Config.NoStuck then
			attempt = attempt or 1
			if attempt < usec.Config.NoStuckAttempts then
			
				-- local filter = {self}
				-- for k,v in pairs(constraint.GetAllConstrainedEntities( self )) do
				--	table.insert(filter,v)
				-- end
				local filter = {}
				for k,v in pairs(ents.GetAll()) do
				    if not v:IsPlayer() then
				        table.insert(filter,v)
				    end
				end
				
				-- table.insert(filter,self)
				local tr = util.TraceEntity( { start = self:GetPos(), endpos = self:GetPos()+Vector(0,0,1), filter = filter, ignoreworld=true }, self )
				if tr.HitNonWorld then
				-- if IsValid(tr.Entity) then
					-- if not IsValid(constraint.Find( self, tr.Entity, "NoCollide", 0, 0 )) then
						local c = self.usec_inversefade and not b or b
						timer.Create("usec_fade_retry"..self:EntIndex(),usec.Config.NoStuckInterval,1,function() if self:IsValid() then self:Fade(c,attempt+1) end end)
						self:EmitSound(usec.Config.NoStuckSound)
						self:SetMaterial(self.usec_oldMat)
						timer.Create("usec_fade_retry_blip"..self:EntIndex(),math.min(usec.Config.NoStuckInterval,.1),1,function() if self:IsValid() then self:SetMaterial("sprites/heatwave") end end)
						return
					-- end
				-- end
				end
			end
		end
		
		--Unfade the door.
		self:SetNotSolid(false)
		-- self:SetSolid(SOLID_VPHYSICS)
		self:SetMaterial(self.usec_oldMat)
		self:DrawShadow(true)
		self.usec_oldMat = nil
		self:SetFaded(false)
		
	end
end

function usec.fadeActivate(self)
	self:Fade(true)
end
function usec.fadeDeactivate(self)
	self:Fade(false)
end


local meta = FindMetaTable("Player")
function meta.UsecGetKeypads(ply)
	local kp = {}
	for k,v in pairs(ents.FindByClass("uni_keypad"))do
		if v:GetUCreator() == ply then
			kp[v:EntIndex()] = v
		end
	end
	return kp
end
function meta.UsecGetDoors(ply)
	local doors = {}
	for k,v in pairs(ply:UsecGetKeypads())do
		for k2,door in pairs(v:GetDoors())do
			doors[door:EntIndex()] = door
		end
	end
	return doors
end

hook.Add("EntityRemoved","usec_keypad_door_removal",function(ent)
	for k,v in pairs(ents.FindByClass("uni_keypad")) do
		local key = table.KeyFromValue(v:GetDoors() or {},ent)
		if key then
			table.remove(v:GetDoors(),key)
			if #v:GetDoors() < 1 then
				v.usec_oldcol = ent:GetColor()
				v:SetColor(Color(255,0,0))
			end
		end
		
	end
end)

hook.Add("DoPlayerDeath","usec_CloseCracker",function(ply)
	ply:SendLua("local f = LocalPlayer().usec_crackframe if IsValid(f) then f:Close() end")
end)
hook.Add("playerArrested","usec_CloseCracker",function(ply)
	ply:SendLua("local f = LocalPlayer().usec_crackframe if IsValid(f) then f:Close() end")
end)

hook.Add("ShowTeam","usec_KeypadSettings",function(ply)
	local trace = ply:GetEyeTrace()
	if trace.Entity:GetClass() == "uni_keypad" and trace.HitPos:Distance(ply:GetShootPos()) < 100 then
		trace.Entity:OpenSettings(ply)
	end
end)