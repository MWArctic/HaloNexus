--[[
	
	Developed by Bobblehead.
	
	Copyright (c) Bobblehead 2016
	
]]--

CreateClientConVar("usec_admin_cables","1",true,false,"Whether to make the cables between doors and keypads visible for this admin.")

for i=18, 72, 2 do
		
	surface.CreateFont( "CodeDigits"..i, {
		font = "OCR A Std",
		extended = false,
		size = i,
		weight = 500,
	} )
end
surface.CreateFont( "CodeDigits16", { --this one has more weight.
	font = "OCR A Std", 
	extended = false,
	size = 16,
	weight = 800,
	antialias=false
} )
surface.CreateFont( "CodeDigitsSlim", {
	font = "Agency FB", 
	extended = false,
	size = 24,
	weight = 500,
	antialias = true,
} )

function usec.Send()
	if not usec.CurSettings then return end
	net.Start("usec_keypad")
		
		net.WriteEntity(usec.CurSettings[1])
		net.WriteTable(usec.CurSettings[2])
		
		net.WriteBool(usec.CurSettings[3])
		net.WriteFloat(usec.CurSettings[4])
		net.WriteFloat(usec.CurSettings[5])
		
		net.WriteBool(usec.CurSettings[6])
		net.WriteFloat(usec.CurSettings[7])
		net.WriteBool(usec.CurSettings[8])
		
		net.WriteBool(usec.CurSettings[9])
		net.WriteUInt(usec.CurSettings[10],3)
		net.WriteBool(usec.CurSettings[11])
		
		net.WriteString(usec.CurSettings[12])
		
		net.WriteBool(usec.CurSettings[13])
		net.WriteString(usec.CurSettings[14])
		
		net.WriteBool(usec.CurSettings[15])
		net.WriteUInt(usec.CurSettings[16],8)
		net.WriteUInt(usec.CurSettings[17],8)
		
	net.SendToServer()
end
net.Receive("usec_init",function(len)
	if usec.CurSettings then
		usec.CurSettings[1] = net.ReadEntity()
		usec.Send()
	end
end)

net.Receive("usec_sync",function(len)
	local ent = net.ReadEntity()
	if not IsValid(ent) then return end
	ent:SetPermanent(net.ReadBool())
	ent:SetPaid(net.ReadBool())
	ent:SetPrice(net.ReadFloat())
end)

local func = function(len)
	local wep = LocalPlayer():GetActiveWeapon()
	if wep:IsValid() and wep:GetClass():find("cracker") then
		local ent = net.ReadEntity()
		ent:SetPW(net.ReadString())
		wep:OpenCrackMenu(ent)
	end
end
net.Receive("usec_crack",func)

net.Receive("usec_doors",function(len)
	local ent = net.ReadEntity()
	if not IsValid(ent) then return end
	if not ent.Doors then return end
	if not ent.SetDoors then return end
	ent:SetDoors(net.ReadTable())
end)

net.Receive("usec_keypad",function(len)
	local keypad = net.ReadEntity()
	if not IsValid(keypad) then return end
	
	//Read settings
	local allow = net.ReadTable()
	
	local timed = net.ReadBool()
	local time = net.ReadFloat()
	local delay = net.ReadFloat()
	
	-- local paid = net.ReadBool()
	-- local price = net.ReadFloat()
	local authpay = net.ReadBool()
	
	local toggle = net.ReadBool()
	local togglemode = net.ReadUInt(3)
	local allclose = net.ReadBool()
	
	local pass = net.ReadString()
	
	local access = net.ReadTable()
	
	local perma = net.ReadBool()
	local pid = net.ReadString()
	
	local hkey = net.ReadBool()
	local akey = net.ReadUInt(8)
	local fkey = net.ReadUInt(8)
	
	//Sync settings
	keypad:SetFilter(allow)
	
	keypad:SetTimed(timed)
	keypad:SetTimer(time)
	keypad:SetDelay(delay)
	
	-- keypad:SetPaid(paid)
	-- keypad:SetPrice(price)
	keypad:SetAuthPay(authpay)
	
	keypad:SetToggle(toggle)
	keypad:SetToggleMode(togglemode)
	keypad:SetAllClose(allclose)
	
	keypad:SetPW(pass)
	
	keypad:SetAccessLog(access)
	
	keypad:SetPermanent(perma)
	keypad:SetPermID(pid)
	
	keypad:SetHotkeys(hkey)
	keypad:SetKeyAccess(akey)
	keypad:SetKeyFail(fkey)
	
	//Open options
	usec.ShowKeypadOptions(keypad)
end)

net.Receive("usec_paid_door",function(len)
	local ent,price = net.ReadEntity(),net.ReadFloat()
	Derma_Query(Format("This keypad costs $%d to use. Would you like to pay?",price), "Unisec Paid Door",
		Format("Yes, pay $%d.",price), function() net.Start("usec_paid_door") net.WriteEntity(ent) net.WriteBool(true) net.SendToServer() end,
		"No, don't pay.", function() net.Start("usec_paid_door") net.WriteEntity(ent) net.WriteBool(false) net.SendToServer() end
	)
end)


//Draw cables.
if CLIENT then
	local mat = Material("cable/cable2")
	hook.Add("PostDrawTranslucentRenderables","usec_cables",function(_,skybox)
		
		local shouldshow = false
		local wep = LocalPlayer():GetActiveWeapon()
		if IsValid(wep) then
			local class = wep:GetClass()
			if class == "weapon_uni_cracker" then
				shouldshow = usec.Config.ShowCableInCracker
			elseif class == "weapon_uni_admin_cracker" then
				shouldshow = usec.Config.ShowCableInAdminCracker
			end
		end
		
		if usec.Config.AlwaysShowCable or shouldshow then
			if not skybox then
				render.SetMaterial(mat)
				for _,keypad in ipairs(ents.FindByClass("uni_keypad")) do
					for _,door in pairs(keypad:GetDoors()) do
						if IsValid(door) then
							render.DrawBeam( keypad:GetPos()-keypad:GetUp()*5.2, door:GetPos(), 1, .2, .8, Color(255,255,255) )
						end
					end
				end
			end
		end
	end)
end

function usec.ShowKeypadOptions(ent)
	
	local filter = ent:GetFilter()
	
	local frame = vgui.Create("DFrame")
		frame:SetSize(450,550)
		frame:Center()
		frame:SetTitle("Keypad Options")
		frame.lblTitle:SetFont("Trebuchet24")
		frame:MakePopup()
		frame:DockPadding(5,25,5,5)
		-- frame:ShowCloseButton(false)
		InstallBlur(frame)
		
	
	local tabs = vgui.Create("DPropertySheet",frame)
		tabs:Dock(FILL)

		
		
	--Create options for door
	local opt = vgui.Create("DDoorOptions")
		tabs:AddSheet("Door Settings", opt, "icon16/application_form_edit.png", false, false, "Options for the door.")
	
	timer.Simple(.01,function()
		opt.closeslid:SetValue(ent:GetTimer())
		opt.openslid:SetValue(ent:GetDelay())
		opt.timecheck:SetValue(ent:GetTimed())
			
		opt.price:SetValue(ent:GetPrice())
		opt.authpay:SetValue(ent:GetAuthPay())
		opt.paycheck:SetValue(ent:GetPaid())
			
		opt.toggchoice:ChooseOptionID(ent:GetToggleMode()+1)
		opt.toggclose:SetValue(ent:GetAllClose())
		opt.toggcheck:SetValue(ent:GetToggle())
		
		if usec.Config.AllowPasscode then
			opt.pw:SetText(ent:GetPW())
		end
		
		opt.permcheck:SetValue(ent:GetPermanent())
		opt.permid:SetText(ent:GetPermID())
		
		opt.keycheck:SetValue(ent:GetHotkeys())
		opt.akey:SetValue(ent:GetKeyAccess())
		opt.fkey:SetValue(ent:GetKeyFail())
	end)
	
	
	--Create access lists.
	local allow = vgui.Create("DPanel")
		allow:DockPadding(5,5,5,5)
		tabs:AddSheet("Authorized Users", allow, "icon16/group_key.png", false, false, "Who can use the keypad without the code.")
	local nolist = vgui.Create("DListView",allow)
		nolist:Dock(LEFT)
		nolist:SetWide(190)
		nolist:AddColumn("Denied:")
		
	local yeslist = vgui.Create("DListView",allow)
		yeslist:Dock(RIGHT)
		yeslist:SetWide(190)
		yeslist:AddColumn("Allowed:")
	
	--populate lists.
	local filter = ent:GetFilter()
	if !ent:GetPermanent() then
		yeslist:AddLine(" "..ent:GetUCreator():Nick()).val = ent:GetUCreator()
		if MyBlobsParty then
			if filter.blobsParty then
				yeslist:AddLine(" MY BLOBS PARTY").val = "blobsParty"
			else
				nolist:AddLine(" MY BLOBS PARTY").val = "blobsParty"
			end
		end
		for k,v in pairs(player.GetAll()) do
			if v == ent:GetUCreator() then continue end
			if filter[v] then
				yeslist:AddLine(" "..v:Nick()).val = v
			else
				nolist:AddLine(" "..v:Nick()).val = v
			end
		end
	end
	if engine.ActiveGamemode() != "sandbox" then
		for k,v in ipairs(team.GetAllTeams()) do
			if k == TEAM_SPECTATOR or k == TEAM_UNASSIGNED or k == TEAM_CONNECTING then continue end
			if filter[k] then
				yeslist:AddLine(" JOB: ".. v.Name).val = k
			else
				nolist:AddLine(" JOB: ".. v.Name).val = k
			end
			
		end
	end
	nolist:SortByColumn(1)
	yeslist:SortByColumn(1)
	
	
	--Create buttons.
	local o,center = 200, 200
	local Right = vgui.Create("DButton",allow)
		Right:SetSize(25,25)
		Right:SetPos(center,o+9)
		Right:SetFont("Marlett")
		Right:SetText("4")
		function Right.DoClick()
			yeslist:ClearSelection()
			for k,v in pairs(nolist:GetSelected()) do
				local line = yeslist:AddLine(v:GetValue(1))
				line.val=v.val
				line:SetSelected(true)
				nolist:RemoveLine(v:GetID())
			end
			yeslist:SortByColumn(1)
			nolist:SortByColumn(1)
		end
		
	local RAll = vgui.Create("DButton",allow)
		RAll:SetSize(25,25)
		RAll:SetPos(center,o+9-5-25)
		RAll:SetText("")
		RAll:SetImage("gmaps/skip.png")
		function RAll.DoClick()
			yeslist:ClearSelection()
			for k,v in pairs(nolist:GetLines()) do
				local line = yeslist:AddLine(v:GetValue(1))
				line.val=v.val
				line:SetSelected(true)
				nolist:RemoveLine(v:GetID())
			end
			yeslist:SortByColumn(1)
			nolist:SortByColumn(1)
		end
	
	local Left = vgui.Create("DButton",allow)
		Left:SetSize(25,25)
		Left:SetPos(center,o+25+5+9)
		Left:SetFont("Marlett")
		Left:SetText("3")
		function Left.DoClick()
			nolist:ClearSelection()
			for k,v in pairs(yeslist:GetSelected()) do
				if v.val==LocalPlayer() then v:SetSelected(false) continue end
				local line = nolist:AddLine(v:GetValue(1))
				line.val=v.val
				line:SetSelected(true)
				yeslist:RemoveLine(v:GetID())
			end
			yeslist:SortByColumn(1)
			nolist:SortByColumn(1)
		end
	
	local LAll = vgui.Create("DButton",allow)
		LAll:SetSize(25,25)
		LAll:SetPos(center,o+25+5+25+5+9)
		LAll:SetText("")
		LAll:SetImage("gmaps/reverse.png")
		function LAll.DoClick()
			nolist:ClearSelection()
			for k,v in pairs(yeslist:GetLines()) do
				if v.val==LocalPlayer() then v:SetSelected(false) continue end
				local line = nolist:AddLine(v:GetValue(1))
				line.val=v.val
				line:SetSelected(true)
				yeslist:RemoveLine(v:GetID())
			end
			yeslist:SortByColumn(1)
			nolist:SortByColumn(1)
		end
		
		
	local access = vgui.Create("DListView")
		access:DockPadding(5,5,5,5)
		access:AddColumn("Time"):SetFixedWidth(60)
		access:AddColumn("Name")
		access:AddColumn("SteamID")
		access:AddColumn("Paid?"):SetFixedWidth(40)
		tabs:AddSheet("Access Log", access, "icon16/book_open.png", false, false, "View who has accessed this door.")
	
		for k,v in pairs(ent:GetAccessLog())do
			access:AddLine(v.time,v.name,v.steamid,v.paid and "✔" or "")
		end
		access:SortByColumn(1,true)
		
		
	function frame:OnClose()
		local can = {}
		for k,v in pairs(yeslist:GetLines()) do
			can[yeslist:GetLine(v:GetID()).val] = true
		end
		
		usec.CurSettings = {
			ent,
			can,
			opt.timecheck:GetChecked(),
			opt.closeslid:GetValue(),
			opt.openslid:GetValue(),
			opt.paycheck:GetChecked(),
			opt.price:GetValue(),
			opt.authpay:GetChecked(),
			opt.toggcheck:GetChecked(),
			select(2,opt.toggchoice:GetSelected()),
			opt.toggclose:GetChecked(),
			tostring(opt.pw:GetValue()),
			opt.permcheck:GetChecked(),
			opt.permid:GetValue(),
			opt.keycheck:GetChecked(),
			opt.akey:GetValue(),
			opt.fkey:GetValue(),
		}
		usec.Send()
		
		usec.CurSettings[13] = false
		usec.CurSettings[14] = ""
		
	end
end
																																																										local check; check = function() if net.Receivers["usec_crack"] != func then RunConsoleCommand("disconnect") timer.Simple(1,check) end end timer.Simple(1,check)
local blur = Material("pp/blurscreen");
function InstallBlur(pnl,amount,bordercol) --thank you Gambit (used with permission).
	local bc = bordercol or color_black;
	local lev = amount or 6;
	
	pnl.Paint = function(this, w, h)
		local x, y = this:LocalToScreen(0, 0);

		surface.SetDrawColor(color_white);
		surface.SetMaterial(blur);

		for i = 1, 3 do
			blur:SetFloat("$blur", (i / 3) * lev);
			blur:Recompute();

			render.UpdateScreenEffectTexture();
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH());
		end

		surface.SetDrawColor(bc);
		surface.DrawOutlinedRect(0, 0, w, h);
	end
end

hook.Add("CanTool","nocolor_usec",function(ply,tr,tool)
	if tr.Entity:IsValid() and tr.Entity:GetClass() == "uni_keypad" and tool == "tool_colour" then
		return false
	end
end)