
--[[
	
	Developed by Bobblehead.
	
	Copyright (c) Bobblehead 2016
	
]]--

AddCSLuaFile()

SWEP.PrintName				= "Unisec Keypad Cracker"
SWEP.Author					= "Bobblehead"
SWEP.Purpose				= "Cracking keypads and fading doors."
SWEP.Instructions			= "Left click to crack a keypad."
SWEP.Category				= "Unisec"

SWEP.Slot					= usec.Config.CrackerSlot - 1
SWEP.SlotPos				= 3

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= false

SWEP.ViewModel				= Model( "models/weapons/v_c4.mdl" )
SWEP.WorldModel				= Model( "models/weapons/w_c4.mdl" )
SWEP.ViewModelFOV			= 54
SWEP.UseHands				= true

SWEP.DrawCrosshair			= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DrawAmmo				= false


if CLIENT then
	SWEP.WepSelectIcon 			= surface.GetTextureID( "unisec/cracker" )
end

function SWEP:PrintWeaponInfo( x, y, alpha ) end

function SWEP:Initialize()
	
	
	self:SetHoldType( "pistol" )
	self.IsCracking = false
	self.Keypads = {}
	if usec.Config.CrackerBlipEnabled then
		timer.Create("usec_cracker_sound"..self:EntIndex(),usec.Config.CrackerBlipInterval,0,function() 
			if IsValid(self) and self.IsCracking then 
				self:EmitSound("buttons/blip2.wav",usec.Config.CrackerBlipVolume) 
			end 
		end)
	end
	
end

function SWEP:Deploy()
	self.IsCracking = false
	return true
end
function SWEP:Holster()
	self.IsCracking = false
	return true
end

function SWEP:PrimaryAttack()
	if game.SinglePlayer() then
		self:CallOnClient("PrimaryAttack")
	end
	self:SetNextPrimaryFire( CurTime() + 0.1 )

	-- self:EmitSound( Sound("ambient/water/drip"..math.random(1,4)..".wav") )
	
	if SERVER then
		local trace = util.TraceLine(util.GetPlayerTrace(self:GetOwner()))
		local ent = trace.Entity
		if IsValid(ent) and ent:GetClass() == "uni_keypad" and (16384*trace.Fraction) < usec.Config.CrackerDistance then
			local kp = self.Keypads[ent:EntIndex()]
			if kp and kp + usec.Config.CrackerTimeout > CurTime() then
				self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
				timer.Create("usec_open_cracker"..self:EntIndex(),1.7,1, function()
					self:SendWeaponAnim( ACT_VM_DRAW )
					ent:AccessGranted()
					ent:LogAccess()
				end)
			else
			
				//Check for access to other keypads that toggle this door.
				if usec.Config.CrackerMultiKeypad then
					for _,otherkp in pairs(ents.FindByClass("uni_keypad"))do
						for _,door in pairs(ent:GetDoors()) do
							if table.HasValue(otherkp:GetDoors(),door) then
								kp = self.Keypads[otherkp:EntIndex()]
								if kp and kp + usec.Config.CrackerTimeout > CurTime() then
									self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
									timer.Create("usec_open_cracker"..self:EntIndex(),1.7,1, function()
										self:SendWeaponAnim( ACT_VM_DRAW )
										ent:AccessGranted()
										ent:LogAccess()
									end)
									return
								end
							end
						end
					end
				end
					
				self:StartCrack(ent)
			end
		end
	end
	
end

function SWEP:StartCrack(ent)
	-- self:EmitSound( Sound("buttons/button16.wav") )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	timer.Create("usec_open_cracker"..self:EntIndex(),1,1, function()
		local trace = util.TraceLine(util.GetPlayerTrace(self:GetOwner()))
		local ent = trace.Entity
		if IsValid(ent) and ent:GetClass() == "uni_keypad" and (16384*trace.Fraction) < 42 then
			ent:SetCrackerPW(usec.RandomPW())
			local passcode = usec.Config.CrackerUseRealPW and ent:GetPW() or ent:GetCrackerPW()
			self.IsCracking = true
			net.Start("usec_crack")
				net.WriteEntity(ent)
				net.WriteString(passcode)
			net.Send(self:GetOwner())
		else
			self:SendWeaponAnim( ACT_VM_DRAW )
		end
	end)
end

local function InstallOutlinedButton(pnl, out, fill, text)
	out = out or Color(0,0,0)
	fill = fill or Color(0,0,0,200)
	text = text or Color(200,200,200,255)
	pnl.Paint = function(self,w,h)
		
		if ( self.Depressed || self.m_bSelected ) then
			local cout = table.Copy(out)
			cout.r = cout.r * .6
			cout.g = cout.g * .6
			cout.b = cout.b * .6
			surface.SetDrawColor(cout)
			local tcol = table.Copy(text)
			tcol.r = tcol.r * .6
			tcol.g = tcol.g * .6
			tcol.b = tcol.b * .6
			self:SetTextColor(tcol)
			surface.SetDrawColor(out)
			surface.DrawOutlinedRect(0,0,w,h-5)
			local col = table.Copy(fill)
			col.r = col.r * .6
			col.g = col.g * .6
			col.b = col.b * .6
			surface.SetDrawColor(col)
		elseif ( self.Hovered ) then
			local cout = table.Copy(out)
			cout.r = cout.r * .8
			cout.g = cout.g * .8
			cout.b = cout.b * .8
			surface.SetDrawColor(cout)
			surface.DrawOutlinedRect(0,0,w,h-5)
			local col = table.Copy(fill)
			col.r = col.r * .8
			col.g = col.g * .8
			col.b = col.b * .8
			surface.SetDrawColor(col)
			self:SetTextColor(text)
		else
			surface.SetDrawColor(out)
			surface.DrawOutlinedRect(0,0,w,h-5)
			surface.SetDrawColor(fill)
			self:SetTextColor(text)
		end
		surface.DrawRect(1,1,w-2,h-7)
		
	end
end

local blur = Material("pp/blurscreen");
function SWEP:OpenCrackMenu(ent)
	if not ent:IsValid() then return end
	if not ent:GetClass() == "uni_keypad" then return end
	
	local frame = vgui.Create("DFrame")
		frame:SetSize(400,500)
		frame:Center()
		frame:SetTitle("Keypad Cracker v1.2")
		frame.lblTitle:SetFont("CodeDigits24")
		frame.lblTitle:SetTextColor(Color(255,0,0))
		frame.btnMinim:SetVisible(false)
		frame.btnMaxim:SetVisible(false)
		frame.btnClose:SetText("x")
		InstallOutlinedButton(frame.btnClose,Color(255,0,0),Color(0,0,0,200),Color(255,0,0))
		
		frame:MakePopup()
		frame:DockPadding(5,25,5,5)
		-- frame:ShowCloseButton(false)
		local bc = Color(255,0,0);
		local lev = 6;
		
		frame.Paint = function(this, w, h)
			local x, y = this:LocalToScreen(0, 0);

			surface.SetDrawColor(color_white);
			surface.SetMaterial(blur);

			for i = 1, 3 do
				blur:SetFloat("$blur", (i / 3) * lev);
				blur:Recompute();

				render.UpdateScreenEffectTexture();
				surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH());
			end
			surface.SetDrawColor(Color(0,0,0,200))
			surface.DrawRect(1,1,w-2,h-2)

			surface.SetDrawColor(bc);
			surface.DrawOutlinedRect(0, 0, w, h);
			
			for i=1,4 do
				local w,spacer = 63,10
				surface.SetDrawColor(Color(255,0,0))
				surface.DrawOutlinedRect(spacer + i*w + (i-1)*spacer -15, 200, w,68 )
				surface.SetDrawColor(Color(0,0,0,200))
				surface.DrawRect(spacer + i*w + (i-1)*spacer -15 +1, 200 +1, w-2,68-2 )
			end
			
		end
		function frame.OnClose()
			if self:IsValid() then
				net.Start("usec_c4anim")
				net.SendToServer()
			end
			ent:SetPW("")
		end
		function frame.Think(this)
			if self.Owner:GetShootPos():DistToSqr(ent:GetPos()) > usec.Config.CrackerDistance^2 then
				this:Close() 
			end
		end
	
	local access = vgui.Create("DLabel",frame)
		access:SetText("ACCESS")
		access:SetFont("CodeDigits72")
		access:SizeToContents()
		access:SetPos(115,85)
		access:CenterHorizontal()
		access:SetContentAlignment(5)
		access:SetTextColor(Color(0,255,0))
		access:SetVisible(false)
	local granted = vgui.Create("DLabel",frame)
		granted:SetText("GRANTED")
		granted:SetFont("CodeDigits72")
		granted:SizeToContents()
		granted:SetPos(115,310)
		granted:CenterHorizontal()
		granted:SetContentAlignment(5)
		granted:SetTextColor(Color(0,255,0))
		granted:SetVisible(false)
		
	local d = {}
	local high = {}
	local low = {}
	-- local pw = string.Explode("",ent:GetPW())
	for i=1,4 do
		local w,spacer = 62,10
		local te = vgui.Create("DTextEntry",frame)
			te:SetPos(3+ i*w + (i-1)*spacer, 205)
			te:SetSize(w,72)
			-- te:SetText(pw[i])
			te:SetText(math.random(0,4))
			te:SetFont("CodeDigits72")
			te:SetTextInset(10,10)
			te:SetUpdateOnType(true)
			te:ApplySchemeSettings()
			-- te:SetNumeric(true)
			function te:AllowInput(text)
				if string.len(self:GetValue()) > 1 then return true end
				if ( !string.find( "0123456789", text, 1, true ) ) then return true end
			end
			function te:OnChange()
				high[i]:SetVisible(false)
				low[i]:SetVisible(false)
				local new = self:GetValue()
				if new:len() > 1 then
					self:SetText(string.Left(new,1))
				end
			end
			function te:Paint()
				self:DrawTextEntryText(Color(255,0,0),Color(255,0,0,0),Color(255,0,0))
			end
			function te:OnFocusChanged(gained)
				if gained then
					self:SelectAll()
				end
			end
			
		d[i] = te
		
		local hi = vgui.Create("DLabel",frame)
			hi:SetPos(spacer + i*w + (i-1)*(spacer+2)-10, 180)
			hi:SetFont("CodeDigitsSlim")
			hi:SetTextColor(Color(255,0,0))
			hi:SetText("TOO HIGH")
			hi:SizeToContents()
			hi:SetVisible(false)
		high[i] = hi
		
		
		local lo = vgui.Create("DLabel",frame)
			lo:SetPos(spacer + i*w + (i-1)*(spacer+2)-8, 267)
			lo:SetFont("CodeDigitsSlim")
			lo:SetTextColor(Color(255,0,0))
			lo:SetText("TOO LOW")
			lo:SizeToContents()
			lo:SetVisible(false)
		low[i] = lo
		
	end
	
	
	local check = vgui.Create("DButton",frame)
		check:Dock(BOTTOM)
		check:DockMargin(5,5,5,0)
		check:SetTall(70)
		check:SetText("Check Code")
		check:SetFont("CodeDigits56")
		InstallOutlinedButton(check,  Color(255,0,0), Color(0,0,0,200), Color(255,0,0))
		function check.DoClick(this)
			local pw = string.Explode("",ent:GetPW())
			local count = 0
			local speed = LocalPlayer():UsecLimit("CrackerSpeed")
			for j=1, 4 do
				high[j]:SetVisible(false)
				low[j]:SetVisible(false)
				surface.PlaySound(Sound("buttons/button24.wav"))
				
				local i = j
				timer.Create("usec_test"..i, (i-.5)*speed, 1, function()
					if !frame:IsValid() then return end
					if !ent:IsValid() then return end
					local val = d[i]:GetValue() or ""
					if val == pw[i] then //Success
						count = count + 1
						high[i]:SetVisible(false)
						low[i]:SetVisible(false)
						surface.PlaySound(Sound("buttons/button17.wav"))
						
					else
						if val > pw[i] then //Too high
							high[i]:SetVisible(true)
							low[i]:SetVisible(false)
							surface.PlaySound(Sound("buttons/button15.wav"))
						else //Too low.
							high[i]:SetVisible(false)
							low[i]:SetVisible(true)
							surface.PlaySound(Sound("buttons/button16.wav"))
						end
					end
				end)
			end
			timer.Create("usec_cracker_success"..self:EntIndex(),4*speed+.3,1, function()
				if !frame:IsValid() then return end
				if !ent:IsValid() then return end
				if count >= 4 then
					surface.PlaySound(Sound("buttons/button19.wav"))
					access:SetVisible(true)
					granted:SetVisible(true)
					timer.Simple(1, function()
						if frame:IsValid() then
							frame:Close()
							net.Start("usec_crack")
								net.WriteEntity(self)
								net.WriteEntity(ent)
								net.WriteString(table.concat(pw, ""))
							net.SendToServer()
						end
					end)
				end
			end)
		end
		
	LocalPlayer().usec_crackframe = frame
	
end

function SWEP:DrawHUD()
	draw.WordBox( 8, ScrW()/2 - 101, ScrH()-160, "Left click a keypad to crack it.", "ChatFont", Color(0,0,0,150), Color(255,255,255) )
end