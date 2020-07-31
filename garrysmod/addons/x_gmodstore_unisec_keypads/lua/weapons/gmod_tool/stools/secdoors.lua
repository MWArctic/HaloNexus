
--[[
	
	Developed by Bobblehead.
	
	Copyright (c) Bobblehead 2016
	
]]--

TOOL.Category		= usec.Config.ToolCategory
TOOL.Name			= "#tool.secdoors.name"
TOOL.Command		= nil
TOOL.ConfigName		= nil


TOOL.ClientConVar[ "inverse" ] = "0"
TOOL.ClientConVar[ "pw" ] = "1234"

if(CLIENT) then
	TOOL.Information = {
		{name = "left",stage=1},
		{name = "right",stage=1},
		{name = "left2",stage=2,icon="gui/lmb.png"},
		{name = "reload"},
	}
	
end

/*---------------------------------------------------------
   Name:	LeftClick
   Desc:	Select
---------------------------------------------------------*/  
function TOOL:LeftClick( trace )
	if game.SinglePlayer() and SERVER then self:GetOwner():GetActiveWeapon():CallOnClient("PrimaryAttack") end
	
	local ent,pos = trace.Entity, trace.HitPos
	if (!pos) then return false end
	
	if SERVER then
		local keypads,doors = table.Count(self:GetOwner():UsecGetKeypads()), table.Count(self:GetOwner():UsecGetDoors())
		local keypadlimit, doorlimit = self:GetOwner():UsecLimit("Keypads"), self:GetOwner():UsecLimit("Doors")
		
		if self:GetStage() == 1 then
			if (IsValid(ent) and (ent:GetClass() == "prop_physics" or self:GetOwner():UsecPermission("TargetNonProp"))) then //if we click a prop, designate fading door.
				
				self.Target = ent
				
				ent.usec_inversefade = self:GetClientNumber("inverse") == 1
				
				self:SetStage(2)
			end
		else
			if IsValid(self.Target) then
				if self.Target.usec_inversefade then
					self.Target:Fade(false)
				end
				if ent:GetClass() == "uni_keypad" then //If we click a keypad, link or unlink.
					local key = table.KeyFromValue(ent:GetDoors(),self.Target)
					if key then
						table.remove(ent:GetDoors(),key)
						ent:SetDoors(ent:GetDoors())
						self.Target.usec_inversefade = false
						self.Target:Fade(false)
					elseif doors+1 <= doorlimit or doorlimit == -1 then
						table.insert(ent:GetDoors(),self.Target)
						ent:SetDoors(ent:GetDoors())
						constraint.NoCollide(ent,self.Target,0,0)
					else
						DarkRP.notify(self:GetOwner(),1,5,Format(usec.Config.LimitFailMessage,"Door"))
					end
					if #ent:GetDoors() < 1 then
						ent.usec_oldcol = ent:GetColor()
						ent:SetColor(Color(255,0,0))
					else
						ent:SetColor(ent.usec_oldcol or Color(255,255,255))
					end
					
				else //Create new keypad.
					if doors+1 > doorlimit and doorlimit != -1 then
						DarkRP.notify(self:GetOwner(),1,5,Format(usec.Config.LimitFailMessage,"Door"))
						self:SetStage(1)
						return
					end
					if keypads+1 > keypadlimit and keypadlimit != -1 then
						DarkRP.notify(self:GetOwner(),1,5,Format(usec.Config.LimitFailMessage,"Keypads"))
						self:SetStage(1)
						return 
					end
					
					
					local kp = ents.Create("uni_keypad")
						kp:SetAngles(trace.HitNormal:Angle())
						kp:SetPos(pos-kp:GetUp()*2)
						kp:SetCreator(self:GetOwner())
						kp:SetUCreator(self:GetOwner())
						kp:SetColor(Color(255,255,255))
						kp:Spawn()
						kp:SetTimer(math.max(self:GetOwner():UsecLimit("MinimumOpenTime"),2.5))
						kp:SetTimed(self:GetOwner():UsecPermission("TimedDoor"))
						kp:SetToggle(self:GetOwner():UsecPermission("ToggleDoor") and not self:GetOwner():UsecPermission("TimedDoor"))
						kp:SetPW(tostring(self:GetClientNumber("pw")))
						
						local tar = self.Target
						timer.Simple(.1,function()
							if IsValid(kp) then
								kp:SetDoors({tar})
								if IsValid(kp:GetUCreator()) then
									net.Start("usec_init")
										net.WriteEntity(kp)
									net.Send(kp:GetUCreator())
								end
							end
						end)
						
						
					-- cleanup.Add(self:GetOwner(), "Keypads", kp)
					local const
					if (IsValid(ent) and ent:GetClass() == "prop_physics") then //if we click a prop, weld.
						const = constraint.Weld(ent,kp,trace.PhysicsBone,0,0,true,false)
					else
						-- const = constraint.Weld(game.GetWorld(),kp,trace.PhysicsBone,0,0,false,false) //This crashed the game.
						const = constraint.NoCollide(kp,self.Target,0,0)
					end
					kp:GetPhysicsObject():EnableMotion(false)
					
					
					undo.Create( "unisec_keypad" )
						undo.AddEntity( kp )
						undo.AddEntity( const )
						undo.SetPlayer( self:GetOwner() )
					undo.Finish()
					
					
					local a = IsValid(kp) and self:GetOwner():AddCleanup( "keypads", kp )
					a = IsValid(const) and self:GetOwner():AddCleanup( "keypads", const )
					a = IsValid(const2) and self:GetOwner():AddCleanup( "keypads", cons2 )
				end
				
				self.Target = nil
			end
			
			self:SetStage(1)
		end
	end
	
	
	
	
	return true

end

/*---------------------------------------------------------
   Name:	RightClick
   Desc:	Creat Weld.
---------------------------------------------------------*/  
function TOOL:RightClick( trace )
	if game.SinglePlayer() and SERVER then self:GetOwner():GetActiveWeapon():CallOnClient("SecondaryAttack") end
	
	self:SetStage(1)
	
	self:LeftClick(trace)
	self:LeftClick(trace)
	
	return true
	
end

/*---------------------------------------------------------
   Name:	Reload
   Desc:	Clear Selection
---------------------------------------------------------*/  
function TOOL:Reload( trace )
	if game.SinglePlayer() and SERVER then self:GetOwner():GetActiveWeapon():CallOnClient("Reload") end
	if SERVER then
		
		if trace.Entity:GetClass() == "uni_keypad" and trace.HitPos:Distance(self:GetOwner():GetShootPos()) < 100 then
			trace.Entity:OpenSettings(self:GetOwner())
		end
	end
	self:SetStage(1)
	
	return false
	
end

function TOOL:Deploy()
	if game.SinglePlayer() and SERVER then self:GetOwner():GetActiveWeapon():CallOnClient("Deploy") end
	-- self:GetOwner().usec_toolhold = true
	self:SetStage(1)
end

function TOOL:Holster()
	if game.SinglePlayer() and SERVER then self:GetOwner():GetActiveWeapon():CallOnClient("Holster") end
	-- self:GetOwner().usec_toolhold = false
	self:SetStage(1)
end



function TOOL.BuildCPanel(CPanel)
	if usec.Config.AllowPasscode then
		local pw = vgui.Create("DTextEntry",CPanel)
			-- pw:Dock(TOP)
			-- pw:DockMargin(5,5,5,5)
			CPanel:AddPanel(pw)
			CPanel:ControlHelp("#tools.secdoors.pw.help")
			pw:SetNumeric(true)
			pw:SetConVar("secdoors_pw")
			pw:SetValue(GetConVarString("secdoors_pw") or "")
			-- pw:SetDisabled(true)
			function pw:OnChange() //restrict password to 4 digits only.
				local text = self:GetValue() or ""
				if text:len()>=4 and not usec.IsPW(text) then
					self:SetText(text:sub(1,text:len()-1))
					TextEntryLoseFocus()
				end
				if text:find("%D") then
					self:SetText("0000")
					TextEntryLoseFocus()
				end
			end
			pw.OnLoseFocus__Old = pw.OnLoseFocus
			function pw:OnLoseFocus()
				self:OnLoseFocus__Old()
				self:SetText(Format("%04d",tonumber(self:GetValue())))
			end
	end
	
	CPanel:AddControl( "CheckBox", { Label = "#tools.secdoors.inverse3", Command = "secdoors_inverse", Help = true } )
	
	CPanel:AddControl( "Header", { Description = [[This tool creates fading doors and links them to keypads.
	
	1. Click on a prop to designate a door.
	2. Click somewhere else to create a keypad.
	3. Press F2 on a keypad to modify its settings.
	
	You can link or unlink a door by clicking it and clicking a keypad. Keypads with no linked doors are colored red.
	
	Newly-placed keypads use the same settings as the last keypad you modified.]] } )
end
