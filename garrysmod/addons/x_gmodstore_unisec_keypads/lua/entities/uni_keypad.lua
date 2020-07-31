
--[[
	
	Developed by Bobblehead.
	
	Copyright (c) Bobblehead 2016
	
]]--

if WireLib then
	DEFINE_BASECLASS( "base_wire_entity" )
else
	ENT.Base = "base_anim"
end

if SERVER then
	AddCSLuaFile()
end

ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.PrintName = "Unisec Keypad"
ENT.Author = "Bobblehead"
ENT.Category = "Unisec"
ENT.Spawnable = false
ENT.AdminSpawnable = false


AccessorFunc(ENT,"Filter","Filter")
AccessorFunc(ENT,"Doors","Doors")
AccessorFunc(ENT,"AccessLog","AccessLog")
AccessorFunc(ENT,"Faded","Faded",FORCE_BOOL)

AccessorFunc(ENT,"Timed","Timed",FORCE_BOOL)
AccessorFunc(ENT,"Timer","Timer",FORCE_NUMBER)
AccessorFunc(ENT,"Delay","Delay",FORCE_NUMBER)

-- AccessorFunc(ENT,"Paid","Paid",FORCE_BOOL)
-- AccessorFunc(ENT,"Price","Price",FORCE_NUMBER)
AccessorFunc(ENT,"AuthPay","AuthPay",FORCE_BOOL)

AccessorFunc(ENT,"Toggle","Toggle",FORCE_BOOL)
AccessorFunc(ENT,"ToggleMode","ToggleMode",FORCE_NUMBER)
AccessorFunc(ENT,"AllClose","AllClose",FORCE_BOOL)

AccessorFunc(ENT,"PW","PW",FORCE_STRING)
AccessorFunc(ENT,"CrackerPW","CrackerPW",FORCE_STRING)

AccessorFunc(ENT,"PermID","PermID",FORCE_STRING)

AccessorFunc(ENT,"Hotkeys","Hotkeys",FORCE_BOOL)
AccessorFunc(ENT,"KeyAccess","KeyAccess",FORCE_NUMBER)
AccessorFunc(ENT,"KeyFail","KeyFail",FORCE_NUMBER)

	


function ENT:Initialize()
	
	if self.BaseClass then
		self.BaseClass.Initialize(self)
	end
	
	self:SetModel("models/props_lab/keypad.mdl")
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		-- self:GetPhysicsObject():SetMass(1)
		
		self:SetUseType(SIMPLE_USE)
		self:SetPW(usec.RandomPW())
		if WireLib then
			self.Outputs = WireLib.CreateOutputs(self, {"Granted", "Denied"})
		end
	end
	
	self:DrawShadow(false)
	-- self:SetMoveType(MOVETYPE_NONE)
	
	self:SetFilter({})
	self.Doors = {}
	self:SetAccessLog({})
	
	self:SetTimed(true)
	-- self:SetTimer(math.max(usec.Config.MinimumOpenTime,2.5))
	self:SetDelay(0)
	
	self:SetPaid(false)
	self:SetPrice(0)
	self:SetAuthPay(true)
	
	self:SetToggle(false)
	self:SetToggleMode(0)
	self:SetAllClose(true)
	self:SetKeypadInput("")
	
	self:SetPermanent(false)
	self:SetPermID("")
	
	self:SetHotkeys(false)
	self:SetKeyAccess(KEY_NONE)
	self:SetKeyFail(KEY_NONE)
	
	
end

function ENT:SetupDataTables()
	self:NetworkVar("String",0,"KeypadInput")
	self:NetworkVar("Int",1,"Price")
	self:NetworkVar("Bool",0,"Paid")
	self:NetworkVar("Bool",1,"Permanent")
	self:NetworkVar("Entity",0,"UCreator")
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Use(activator,ply,type,val)
	if CLIENT then return end
	if IsValid(activator) and IsValid(ply) and activator:IsPlayer() and ply:IsPlayer() then
	
		//Fingerprint Scan:
		local mx,my = self:Get2DTrace(ply)
		if self:GetSkin() == 0 and usec.InBounds(mx,my,30,30,140,140) then
			
			if self:CanUse(ply) then
			
				if self:GetPaid() then
				
					if !(self:GetUCreator() == ply) and !self:GetAuthPay() then
						self:RequestMoney(ply)
						
					else
						self:AccessGranted()
						self:LogAccess(ply)
						
					end
					
				else
					self:AccessGranted()
					self:LogAccess(ply)
					
				end
				
			elseif self:GetPaid() and self:GetAuthPay() then
				self:RequestMoney(ply)
				
			elseif self:GetToggle() and self:GetAllClose() then
				
				if self:GetToggleMode() != 1 then
					local success = false
					for k,v in pairs(self:GetDoors())do
						if v:GetFaded() then
							success = true
						end
					end
					if success then 
						self:AccessGranted(true)
						self:LogAccess(ply)
					else
						self:AccessDenied()
					end
					
				else
					self:AccessDenied()
					
				end
				
			else
				self:AccessDenied()
				
			end
		
		elseif self:GetSkin() == 2 and usec.Config.AllowPasscode and !self:GetPermanent() then
			local w,spacer,ox,oy = 35,8,39,180
			for c=0, 3 do
				for r=0, 6, 3 do
					local num = r+c+1
					if c==3 then if r!=6 then continue else r,c,num = 9,1,0 end end //Get 0 in there.
					if usec.InBounds(mx,my,ox +c*w +c*spacer, oy +r/3*w +r/3*spacer, w, w) then
						self:Keypad(num)
					end
				end
			end
		
		end
	end
	
end

function ENT:OnRemove()
	if SERVER then
	
		if self:GetHotkeys() then
			numpad.Deactivate(self:GetUCreator(),self:GetKeyAccess(),true)
			numpad.Deactivate(self:GetUCreator(),self:GetKeyFail(),true)
		end
		Wire_TriggerOutput(self, "Denied", 0)
		Wire_TriggerOutput(self, "Granted", 0)
		
		for k,v in pairs(self:GetDoors())do
			if v:GetFaded() then
				v.usec_inversefade = false
			end
			v:Fade(false)
			timer.Destroy("usec_fade"..v:EntIndex())
		end
		timer.Destroy("usec_keypadskin"..self:EntIndex())
		constraint.RemoveAll(self)
	end
end


if CLIENT then
	local metal = CreateMaterial("Keypad_MetalPlate5", "UnlitGeneric",{ 
		["$basetexture"] = "phoenix_storms/metalfloor_2-3"
	})
	local scan = Material("models/props_combine/stasisshield_sheet") //This material draws funky in opaque and it's a cool effect.
	
	local fprint = Material("unisec/fingerprint.png","unlitgeneric")
	local checkmark = Material("unisec/accessgranted.png","unlitgeneric")
	local xmark = Material("unisec/accessdenied.png","unlitgeneric")
	local logo = Material("unisec/unisecopyright_white.png","unlitgeneric")


	function ENT:Draw() //Draw 3d2d controls
		 self:DrawModel()
		 
		local mx,my = self:Get2DTrace(LocalPlayer())
		local skin = self:GetSkin()
		
		local ang = self:GetAngles()
		ang:RotateAroundAxis(self:GetForward(), 90)
		ang:RotateAroundAxis(self:GetUp(), 90)
		local pos = self:GetPos()+self:GetUp()*5.48
		pos = pos + self:GetForward()*1.05
		pos = pos + self:GetRight()*3
		
		cam.Start3D2D(pos,ang,.03)
			draw.NoTexture()
			
			//Draw metal
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(metal)
			surface.DrawTexturedRect(0,0,200,366)
			
			//Disabled overlay
			if self:GetColor().g == 0 then
				surface.SetDrawColor(Color(255,0,0,100))
				surface.DrawRect(0,0,200,366)
			end
			
			//Border
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawRect(28,28,144,144)
			
			//Scanner
			surface.SetMaterial(scan)
			surface.DrawTexturedRect(30,30,140,140)
			-- surface.SetDrawColor(Color(0,0,0,50))
			-- surface.DrawRect(36,36,128,128)
			surface.SetDrawColor(Color(0,0,0))
			
			//Scanner highlight
			if usec.InBounds(mx,my,30,30,140,140) then
				surface.SetDrawColor(Color(255,255,255,100))
				surface.DrawRect(30,30,140,140)
				surface.SetDrawColor(Color(0,0,0))
			end
			
			if skin == 0 then
				//Passive Appearance
				
				if self:GetPaid() then
					//Price
					draw.SimpleText( "$"..string.Comma(self:GetPrice()), "CodeDigits24", 100,90, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					draw.SimpleText( "Paid Entry", "CodeDigits16", 100,110, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					//Fingerprint
					surface.SetMaterial(fprint)
					surface.DrawTexturedRect(68,68,64,64)
				end
				
				//Logo
				surface.SetMaterial(logo)
				-- surface.SetDrawColor(Color(0,48,255))
				surface.DrawTexturedRect(70,145,64,64/5.3)
			elseif skin == 1 then
				//Access Granted
				-- surface.SetDrawColor(Color(0,100,0))
				surface.SetMaterial(checkmark)
				surface.DrawTexturedRect(40,40,120,120)
			else
				//Access Denied
				surface.SetMaterial(xmark)
				surface.DrawTexturedRect(40,40,120,120)
				
				if usec.Config.AllowPasscode and !self:GetPermanent() then
					//Keypad numbers
					local w,spacer,ox,oy = 35,8,39,180
					surface.SetTextColor(Color(0,0,0))
					surface.SetFont("CodeDigits36")
					for c=0, 3 do
						for r=0, 6, 3 do
							local num = r+c+1
							if c==3 then if r!=6 then continue else r,c,num = 9,1,0 end end //Get 0 in there.
							surface.SetDrawColor(Color(0,0,0))
							surface.DrawRect(ox +c*w +c*spacer, oy +r/3*w +r/3*spacer, w, w)
							if usec.InBounds(mx,my,ox +c*w +c*spacer, oy +r/3*w +r/3*spacer, w, w) then
								surface.SetDrawColor(Color(255,255,255))
							else
								surface.SetDrawColor(Color(200,200,200))
							end
							surface.DrawRect(ox +c*w +c*spacer+1, oy +r/3*w +r/3*spacer+1, w-2, w-2)
							
							surface.SetTextPos(ox +c*w +c*spacer+6, oy +r/3*w +r/3*spacer+2)
							surface.DrawText(num)
						end
					end
					
					//Asterisks
					for i=1, self:GetKeypadInput():len() do
						surface.SetFont("CodeDigits30")
						surface.SetTextPos(40+i*20,145)
						surface.DrawText("*")
					end
					
					//Cursor
					if usec.Config.ShowCursor and mx > -1 and my > -1 then 
						surface.SetDrawColor(Color(0,0,0))
						surface.DrawRect(mx-4,my-1,8,2)
						surface.DrawRect(mx-1,my-4,2,8)
					end
				end
			end
			
			
			
		cam.End3D2D()
		
		//Draw backside
		ang:RotateAroundAxis(self:GetUp(),180)
		pos = pos - self:GetForward()*1.05
		pos = pos - self:GetRight()*6
		cam.Start3D2D(pos,ang,.03)
			surface.SetDrawColor(Color(255,255,255))
			surface.SetMaterial(metal)
			surface.DrawTexturedRect(0,0,200,366)
		cam.End3D2D()
	end
end

function ENT:Get2DTrace(ply)
	local trace = util.TraceLine(util.GetPlayerTrace(ply))
	local mx,my = -1,-1
	if trace.Entity == self and (16384*trace.Fraction) < 42 then
		local vec = trace.HitPos
		vec = self:WorldToLocal(vec)
		if vec.x > 1 then //Not from behind.
			mx,my = vec.y,vec.z
			mx = ((mx+3)/3) * 200/2
			my = ((-my+5.45)/5.45) * 365/2
		end
	end
	return mx,my
end

function ENT:Keypad(num)
	self:EmitSound("buttons/button15.wav")
	local new = self:GetKeypadInput()..num
	if new:len() >= 4 then
		if new == self:GetPW() then
			Wire_TriggerOutput(self, "Denied", 0)
			self:AccessGranted()
			self:LogAccess()
		elseif new:len() == 4 then
			if self:GetHotkeys() and usec.Config.AllowPasscode then
				numpad.Activate(self:GetUCreator(),self:GetKeyFail(),true)
			end
			Wire_TriggerOutput(self, "Denied", 1)
			
			self:EmitSound("buttons/button11.wav")
			self:SetKeypadInput(new)
			timer.Create("usec_keypadskin"..self:EntIndex(),1,1,function()
				if self:GetHotkeys() then
					numpad.Deactivate(self:GetUCreator(),self:GetKeyFail(),true)
				end
				Wire_TriggerOutput(self, "Denied", 0)
				self:Clear()
			end)
		end
	else
		self:SetKeypadInput(new)
	end
end

function ENT:SetDoors(d)
	
	for k,v in pairs(self.Doors)do
		v.fadeActivate = nil
		v.fadeDeactivate = nil
	end
	
	self.Doors = d
	
	for k,v in pairs(d)do
		v.fadeActivate = usec.fadeActivate
		v.fadeDeactivate = usec.fadeDeactivate
	end
	
	if SERVER then
		net.Start("usec_doors")
			net.WriteEntity(self)
			net.WriteTable(d)
		net.Broadcast()
	end
end

function ENT:AccessGranted(closeonly)
	self:EmitSound("buttons/bell1.wav")
	self:SetKeypadInput("")
	self:SetSkin(1)
	timer.Destroy("usec_keypadskin"..self:EntIndex())
	
	if self:GetTimed() then
		timer.Create("usec_keypad_delay"..self:EntIndex(), self:GetDelay() or 0, 1,function() self:ActivateDoor(closeonly) end)
	else
		self:ActivateDoor(closeonly)
	end
	
end

function ENT:AccessDenied()
	self:EmitSound("buttons/button18.wav")
	self:SetSkin(2)
	
	if self:GetHotkeys() and not usec.Config.AllowPasscode then
		numpad.Activate(self:GetUCreator(),self:GetKeyFail(),true)
	end
	Wire_TriggerOutput(self, "Denied", 1)
	
	timer.Create("usec_keypadskin"..self:EntIndex(),(!self:GetPermanent() and usec.Config.AllowPasscode) and 10 or usec.Config.UseDelay,1,function()
		if IsValid(self) then
			if self:GetHotkeys() and not usec.Config.AllowPasscode then
				numpad.Deactivate(self:GetUCreator(),self:GetKeyFail(),true)
			end
			Wire_TriggerOutput(self, "Denied", 0)
			self:Clear()
		end 
	end)
	
	
end
function ENT:Clear()
	self:SetKeypadInput("") 
	self:SetSkin(0) 
end

function ENT:ActivateDoor(closeonly)
	if CLIENT then return end
	for k,door in pairs(self:GetDoors()) do
		if self:GetToggle() then
			if self:GetToggleMode() == 0 then
				if door.usec_inversefade then
					door:Fade((door:GetFaded()) and (not closeonly))
				else
					door:Fade((not door:GetFaded()) and (not closeonly))
				end
			elseif self:GetToggleMode() == 1 and not closeonly then
				door:Fade(true)
			else
				door:Fade(false)
			end
		else
			door:Fade(true)
		end
		
		if self:GetTimed() then
			timer.Create("usec_fade"..door:EntIndex(),self:GetTimer(),1,function() 
				if IsValid(door) then
					door:Fade(false)
				end
			end)
		end
	end
	if self:GetHotkeys() then
		numpad.Activate(self:GetUCreator(),self:GetKeyAccess(),true)
	end
	Wire_TriggerOutput(self, "Granted", 1)
	
	timer.Create("usec_keypadskin"..self:EntIndex(),self:GetTimed() and self:GetTimer() or usec.Config.UseDelay,1,function()
		if IsValid(self) then
			self:SetSkin(0) 
			if self:GetHotkeys() then
				numpad.Deactivate(self:GetUCreator(),self:GetKeyAccess(),true)
			end
			Wire_TriggerOutput(self, "Granted", 0)
		end
	end)
	
end

function ENT:OpenSettings(ply)
	if ply == self:GetUCreator() or ply:UsecPermission("EditUnowned") then
		net.Start("usec_keypad")
			net.WriteEntity(self)
			net.WriteTable(self:GetFilter())
			
			net.WriteBool(self:GetTimed())
			net.WriteFloat(self:GetTimer())
			net.WriteFloat(self:GetDelay())
			
			-- net.WriteBool(self:GetPaid())
			-- net.WriteFloat(self:GetPrice())
			net.WriteBool(self:GetAuthPay())
			
			net.WriteBool(self:GetToggle())
			net.WriteUInt(self:GetToggleMode(),3)
			net.WriteBool(self:GetAllClose())
			
			net.WriteString(self:GetPW())
			
			net.WriteTable(self:GetAccessLog())
			
			net.WriteBool(self:GetPermanent())
			net.WriteString(self:GetPermID())
			
			net.WriteBool(self:GetHotkeys())
			net.WriteUInt(self:GetKeyAccess(),8)
			net.WriteUInt(self:GetKeyFail(),8)
		net.Send(ply)
	end
end

function ENT:LogAccess(ply,paid)
	local access = {}
	if ply then
		access.time = os.date("%H:%M:%S",os.time())
		access.name = ply:Nick()
		access.steamid = ply:SteamID()
		access.paid = tobool(paid)
	else
		access.time = os.date("%H:%M:%S",os.time())
		access.name = "UNAUTHORIZED USER"
		access.steamid = "N/A"
		access.paid = false
	end
	
	table.insert(self:GetAccessLog(),access)
	if #self:GetAccessLog() > usec.Config.MaxLogs then
		table.remove(self:GetAccessLog())
	end
end

local function isInBlobParty(ply)
	for a,b in pairs(BlobsParties) do
		for c,d in pairs(b.members) do
			if d == ply then
				return true
			end
		end
	end
	
	return false
end
function ENT:CanUse(ply)
	local filter = self:GetFilter()
	local blob = false
	if BlobsParties and filter["blobsParty"] and isInBlobParty(ply) then
		blob = true
	end
	return (filter[ply] or filter[ply:Team()] or self:GetUCreator() == ply or blob)
end

function ENT:RequestMoney(ply)
	net.Start("usec_paid_door")
		net.WriteEntity(self)
		net.WriteFloat(self:GetPrice())
	net.Send(ply)
end


//Standard keypad support
ENT.IsKeypad = true
function ENT:Process(b) 
	if SERVER then
		if b then
			self:AccessGranted()
			self:LogAccess()
		else
			self:AccessDenied()
		end
	end
end
function ENT:GetHoveredElement() return nil end
function ENT:SendCommand() end

-- if SERVER then
	-- hook.Add("DarkRPDBInitialized", "aFPPInit", function()
		-- if FPP then
			-- FPP.AddDefaultBlocked({"Physgun1", "Spawning1", "Toolgun1"}, "uni_keypad")
		-- end
	-- end)
-- end