
--[[
	
	Developed by Bobblehead.
	
	Copyright (c) Bobblehead 2016
	
]]--

local function InstallDisable(pnl)
	function pnl:SetDisabled(b)
		self.Label:SetTextColor(b and Color(85,85,85) or Color(10,10,10))
		self.TextArea:SetTextColor(b and Color(85,85,85) or Color(10,10,10))
		self.Slider.Knob:SetDisabled(b)
		self.TextArea:SetEnabled(!b)
	end
end

local PANEL = {}
function PANEL:Init()
	local yoff = 13
	
		
	//Timer setting
	self.timebox = vgui.Create("DPanel",self)
	self.timebox:SetVisible(LocalPlayer():UsecPermission("TimedDoor"))
	self.timecheck = vgui.Create("DCheckBox",self)
	self.timecheck:SetVisible(LocalPlayer():UsecPermission("TimedDoor"))
	self.timelabel = vgui.Create("DLabel",self)
	self.timelabel:SetVisible(LocalPlayer():UsecPermission("TimedDoor"))
		self.timebox:SetPos(30,yoff)
		self.timebox:SetSize(385,65)
		function self.timebox.Paint(this,w,h)
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawOutlinedRect(0,0,w,h)
			if self.timecheck:GetChecked() then
				surface.SetDrawColor(Color(200,200,200))
			else
				surface.SetDrawColor(Color(100,100,100))
			end
			surface.DrawRect(1,1,w-2,h-2)
		end
		self.timecheck:SetPos(10,yoff)
		self.timelabel:SetPos(40,yoff-11)
		self.timelabel:SetText("Timed Door")
		self.timelabel:SetFont("TargetID")
		self.timelabel:SizeToContents()
		self.timelabel:SetTextColor(Color(255,255,255))
		
	self.closeslid = vgui.Create("DNumSlider",self.timebox)
		self.closeslid:Dock(TOP)
		self.closeslid:DockPadding(10,0,0,0)
		self.closeslid:SetText("Door Close Delay")
		self.closeslid:SetDark(true)
		self.closeslid:SetMinMax(LocalPlayer():UsecLimit("MinimumOpenTime"),30)
		self.closeslid:SetDecimals(1)
		self.closeslid:SetValue(0)
		InstallDisable(self.closeslid)
		self.closeslid:SetDisabled(true)
		
	self.openslid = vgui.Create("DNumSlider",self.timebox)
		self.openslid:Dock(TOP)
		self.openslid:DockPadding(10,-5,0,0)
		self.openslid:SetText("Door Open Delay")
		self.openslid:SetDark(true)
		self.openslid:SetMinMax(0,30)
		self.openslid:SetDecimals(1)
		self.openslid:SetValue(0)
		InstallDisable(self.openslid)
		self.openslid:SetDisabled(true)
	
	function self.timecheck.OnChange(this,b)
		self.closeslid:SetDisabled(!b)
		self.openslid:SetDisabled(!b)
	end
		
	if LocalPlayer():UsecPermission("TimedDoor") then
		yoff = yoff + 82
	end
		
	// Toggle setting
	self.toggbox = vgui.Create("DPanel",self)
	self.toggbox:SetVisible(LocalPlayer():UsecPermission("ToggleDoor"))
	self.toggcheck = vgui.Create("DCheckBox",self)
	self.toggcheck:SetVisible(LocalPlayer():UsecPermission("ToggleDoor"))
	-- self.toggcheck:SetChecked(LocalPlayer():UsecPermission("ToggleDoor") and not LocalPlayer():UsecPermission("TimedDoor"))
	self.togglabel = vgui.Create("DLabel",self)
	self.togglabel:SetVisible(LocalPlayer():UsecPermission("ToggleDoor"))
	
		self.toggbox:SetPos(30,yoff)
		self.toggbox:SetSize(385,70)
		function self.toggbox.Paint(this,w,h)
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawOutlinedRect(0,0,w,h)
			if self.toggcheck:GetChecked() then
				surface.SetDrawColor(Color(200,200,200))
			else
				surface.SetDrawColor(Color(100,100,100))
			end
			surface.DrawRect(1,1,w-2,h-2)
		end
		self.toggcheck:SetPos(10,yoff)
		self.togglabel:SetPos(40,yoff-11)
		self.togglabel:SetText("Toggled Door")
		self.togglabel:SetFont("TargetID")
		self.togglabel:SizeToContents()
		self.togglabel:SetTextColor(Color(255,255,255))
		
	self.toggchoice = vgui.Create("DComboBox",self.toggbox)
		self.toggchoice:Dock(TOP)
		self.toggchoice:DockMargin(10,10,10,10)
		self.toggchoice:AddChoice("This keypad opens and closes the door.",0,true)
		self.toggchoice:AddChoice("This keypad can only OPEN the door.",1)
		self.toggchoice:AddChoice("This keypad can only CLOSE the door.",2)
		timer.Simple(FrameTime(),function()
			self.toggchoice:SetDisabled(true)
		end)
	
	self.toggclose = vgui.Create("DCheckBoxLabel",self.toggbox)
		self.toggclose:Dock(TOP)
		self.toggclose:DockMargin(10,0,10,10)
		self.toggclose:SetDark(true)
		self.toggclose:SetText("Allow anyone to close this door.")
		self.toggclose:SetDisabled(true)
		function self.toggchoice.OnSelect(this,index,choice,num)
			self.toggclose:SetDisabled(num == 1)
		end
		
	function self.toggcheck.OnChange(this,b)
		self.toggchoice:SetDisabled(!b)
		local _,num = self.toggchoice:GetSelected()
		self.toggclose:SetDisabled(!b or (num == 1))
	end
		
	if LocalPlayer():UsecPermission("ToggleDoor") then
		yoff = yoff + 87
	end
	
	//Hotkey setting
	self.keybox = vgui.Create("DPanel",self)
	self.keybox:SetVisible(LocalPlayer():UsecPermission("KeybindOutput"))
	self.keycheck = vgui.Create("DCheckBox",self)
	self.keycheck:SetVisible(LocalPlayer():UsecPermission("KeybindOutput"))
	self.keylabel = vgui.Create("DLabel",self)
	self.keylabel:SetVisible(LocalPlayer():UsecPermission("KeybindOutput"))
		
		self.keybox:SetPos(30,yoff)
		self.keybox:SetSize(385,60)
		function self.keybox.Paint(this,w,h)
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawOutlinedRect(0,0,w,h)
			if self.keycheck:GetChecked() then
				surface.SetDrawColor(Color(200,200,200))
			else
				surface.SetDrawColor(Color(100,100,100))
			end
			surface.DrawRect(1,1,w-2,h-2)
		end
		self.keycheck:SetPos(10,yoff)
		self.keylabel:SetPos(40,yoff-11)
		self.keylabel:SetText("Hotkey Output")
		self.keylabel:SetFont("TargetID")
		self.keylabel:SizeToContents()
		self.keylabel:SetTextColor(Color(255,255,255))
		
		self.akey = vgui.Create( "DBinder", self.keybox )
			self.akey:Dock(LEFT)
			self.akey:DockMargin(50,20,5,5)
			self.akey:SetWide(120)
			self.akey:SetDisabled(true)
		self.fkey = vgui.Create( "DBinder", self.keybox )
			self.fkey:Dock(RIGHT)
			self.fkey:DockMargin(5,20,50,5)
			self.fkey:SetWide(120)
			self.fkey:SetDisabled(true)
		
		self.aklbl = vgui.Create("DLabel",self.keybox)
			self.aklbl:SetPos(62,6)
			self.aklbl:SetText("Access Granted Key")
			self.aklbl:SizeToContents()
			self.aklbl:SetDark(true)
			
		self.fklbl = vgui.Create("DLabel",self.keybox)
			self.fklbl:SetPos(230,6)
			self.fklbl:SetText("Access Denied Key")
			self.fklbl:SizeToContents()
			self.fklbl:SetDark(true)
			
	function self.keycheck.OnChange(this,b)
		if b then
			self.permcheck:SetValue(false)
		end
		
		self.akey:SetDisabled(!b)
		self.fkey:SetDisabled(!b)
		self.aklbl:SetTextColor(!b and Color(85,85,85) or Color(10,10,10))
		self.fklbl:SetTextColor(!b and Color(85,85,85) or Color(10,10,10))
	end
	
	if LocalPlayer():UsecPermission("KeybindOutput") then
		yoff = yoff + 77
	end
	
	
	//Payment setting
	self.paybox = vgui.Create("DPanel",self)
	self.paybox:SetVisible(LocalPlayer():UsecPermission("PaidDoor"))
	self.paycheck = vgui.Create("DCheckBox",self)
	self.paycheck:SetVisible(LocalPlayer():UsecPermission("PaidDoor"))
	self.paylabel = vgui.Create("DLabel",self)
	self.paylabel:SetVisible(LocalPlayer():UsecPermission("PaidDoor"))
	
		self.paybox:SetPos(30,yoff)
		self.paybox:SetSize(385,60)
		function self.paybox.Paint(this,w,h)
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawOutlinedRect(0,0,w,h)
			if self.paycheck:GetChecked() then
				surface.SetDrawColor(Color(200,200,200))
			else
				surface.SetDrawColor(Color(100,100,100))
			end
			surface.DrawRect(1,1,w-2,h-2)
		end
		self.paycheck:SetPos(10,yoff)
		self.paylabel:SetPos(40,yoff-11)
		self.paylabel:SetText("Paid Use")
		self.paylabel:SetFont("TargetID")
		self.paylabel:SizeToContents()
		self.paylabel:SetTextColor(Color(255,255,255))
	
	self.price = vgui.Create("DNumSlider",self.paybox)
		self.price:Dock(TOP)
		self.price:DockPadding(10,0,0,0)
		self.price:SetText("Price Per Use")
		self.price:SetDark(true)
		local limit = LocalPlayer():UsecLimit("MaximumPrice")
		self.price:SetMinMax(0,limit==-1 and 1000000 or limit)
		self.price:SetDecimals(0)
		self.price:SetValue(0)
		InstallDisable(self.price)
		self.price:SetDisabled(true)
	
	self.authpay = vgui.Create("DCheckBoxLabel",self.paybox)
		self.authpay:Dock(TOP)
		self.authpay:DockMargin(10,0,0,0)
		self.authpay:SetText("Only charge unauthorized users.")
		self.authpay:SetDark(true)
		self.authpay:SetDisabled(true)
		
	function self.paycheck.OnChange(this,b)
		self.price:SetDisabled(!b)
		self.authpay:SetDisabled(!b)
	end
	
	if LocalPlayer():UsecPermission("PaidDoor") then
		yoff = yoff + 77
	end
	
	self.passbox = vgui.Create("DPanel",self)
	self.passbox:SetVisible(usec.Config.AllowPasscode)
	-- self.passcheck = vgui.Create("DCheckBox",self)
	-- self.passcheck:SetVisible(usec.Config.AllowPasscode)
	self.passlabel = vgui.Create("DLabel",self)
	self.passlabel:SetVisible(usec.Config.AllowPasscode)
		
		self.passbox:SetPos(30,yoff)
		self.passbox:SetSize(385,60)
		function self.passbox.Paint(this,w,h)
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawOutlinedRect(0,0,w,h)
			if !self.permcheck:GetChecked() then
				surface.SetDrawColor(Color(200,200,200))
			else
				surface.SetDrawColor(Color(100,100,100))
			end
			surface.DrawRect(1,1,w-2,h-2)
		end
		-- self.passcheck:SetPos(10,yoff)
		self.passlabel:SetPos(40,yoff-11)
		self.passlabel:SetText("Secondary Passcode")
		self.passlabel:SetFont("TargetID")
		self.passlabel:SizeToContents()
		self.passlabel:SetTextColor(Color(255,255,255))
	
	self.pw = vgui.Create("DTextEntry",self.passbox)
		self.pw:Dock(TOP)
		self.pw:DockMargin(10,10,10,5)
		self.pw:SetNumeric(true)
		-- self.pw:SetDisabled(true)
		function self.pw:OnChange() //restrict password to 4 digits only.
			local text = self:GetValue()
			if text:len()>=4 and not usec.IsPW(text) then
				self:SetText(text:sub(1,text:len()-1))
				TextEntryLoseFocus()
			end
			if text:find("%D") then
				self:SetText("0000")
				TextEntryLoseFocus()
			end
		end
		function self.pw:OnLoseFocus()
			self:SetText(Format("%04d",tonumber(self:GetValue())))
		end
		timer.Simple(.07, function()
			if self.pw:IsValid() then 
				self.pw:SetDisabled(self.permcheck:GetChecked())
			end
		end)
	
	self.pwlbl = vgui.Create("DLabel",self.passbox)
		self.pwlbl:Dock(TOP)
		self.pwlbl:SetText("This passcode is for users who are not pre-authorized.")
		self.pwlbl:SetDark(true)
		self.pwlbl:DockMargin(11,0,10,10)
	
	if usec.Config.AllowPasscode then
		yoff = yoff + 77
	end
	
	self.permbox = vgui.Create("DPanel",self)
	self.permbox:SetVisible(LocalPlayer():UsecPermission("PermanentKeypad"))
	self.permcheck = vgui.Create("DCheckBox",self)
	self.permcheck:SetVisible(LocalPlayer():UsecPermission("PermanentKeypad"))
	self.permlabel = vgui.Create("DLabel",self)
	self.permlabel:SetVisible(LocalPlayer():UsecPermission("PermanentKeypad"))
		
		self.permbox:SetPos(30,yoff)
		self.permbox:SetSize(385,60)
		function self.permbox.Paint(this,w,h)
			surface.SetDrawColor(Color(0,0,0))
			surface.DrawOutlinedRect(0,0,w,h)
			if self.permcheck:GetChecked() then
				surface.SetDrawColor(Color(200,200,200))
			else
				surface.SetDrawColor(Color(100,100,100))
			end
			surface.DrawRect(1,1,w-2,h-2)
		end
		self.permcheck:SetPos(10,yoff)
		self.permlabel:SetPos(40,yoff-11)
		self.permlabel:SetText("Permanent Keypad")
		self.permlabel:SetFont("TargetID")
		self.permlabel:SizeToContents()
		self.permlabel:SetTextColor(Color(255,255,255))
		
	self.permid = vgui.Create("DTextEntry",self.permbox)
		self.permid:Dock(TOP)
		self.permid:DockMargin(10,10,10,5)
		self.permid:SelectAllOnFocus()
		timer.Simple(.07, function()
			if self.permid:IsValid() then 
				self.permid:SetDisabled(!self.permcheck:GetChecked())
			end
		end)
	
	self.permhelp = vgui.Create("DLabel",self.permbox)
		self.permhelp:Dock(TOP)
		self.permhelp:SetText("This is a unique identifier for saving the keypad.")
		self.permhelp:SetDark(true)
		self.permhelp:DockMargin(11,0,10,10)
	
	function self.permcheck.OnChange(this,b)
		if b then
			self.keycheck:SetValue(false)
		end
		
		self.permid:SetDisabled(!b)
		self.pw:SetDisabled(b)
		self.permhelp:SetTextColor(!b and Color(85,85,85) or Color(10,10,10))
		self.pwlbl:SetTextColor(b and Color(85,85,85) or Color(10,10,10))
	end
		
	if LocalPlayer():UsecPermission("PermanentKeypad") then
		yoff = yoff + 77
	end
	
	
	
end

function PANEL:Paint() end

vgui.Register("DDoorOptions",PANEL,"DPanel")