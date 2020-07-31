if (CLIENT) then

local PANEL = {}



function PANEL:setItemType(itemTypeOrID)
	local item = nut.item.list[itemTypeOrID]
	if (type(itemTypeOrID) == "number") then
		item = nut.item.instances[itemTypeOrID]
		self.itemID = itemTypeOrID
	end
	assert(item, "invalid item type or ID "..tostring(item))

	self.nutToolTip = true
	self.itemTable = item
	if self.itemTable:getData("equip") == not self.SLOT then
		self:Remove()
		return
	end
	self:SetModel(item.model, item.skin)
	self:updateTooltip()
	self:SetText("")
	
	if (item.exRender) then
		self.Icon:SetVisible(false)
		self.ExtraPaint = function(self, x, y)
			local paintFunc = item.paintIcon

			if (paintFunc and type(paintFunc) == "function") then
				paintFunc(item, self)
			else
				local exIcon = ikon:getIcon(item.uniqueID)
				if (exIcon) then
					surface.SetMaterial(exIcon)
					surface.SetDrawColor(color_white)
					surface.DrawTexturedRect(0, 0, x, y)
				else
					ikon:renderIcon(
						item.uniqueID,
						item.width,
						item.height,
						item.model,
						item.iconCam
					)
				end
			end
		end
	elseif (item.icon) then
		self.Icon:SetVisible(false)
		self.ExtraPaint = function(self, w, h)
			drawIcon(item.icon, self, w, h)
		end
	else
		renderNewIcon(self, item)
	end

end

function PANEL:updateTooltip()
	self:SetTooltip(
		"<font=nutItemBoldFont>"..self.itemTable:getName().."</font>\n"..
		"<font=nutItemDescFont>"..self.itemTable:getDesc()
	)
end

function PANEL:getItem()
	return self.itemTable
end

-- Updates the parts of the UI that could be changed by data changes.
function PANEL:ItemDataChanged(key, oldValue, newValue)
	self:updateTooltip()
end

function PANEL:Init()
	self:Droppable("inv")
	self:SetSize(NS_ICON_SIZE-20, NS_ICON_SIZE-20)
	self:DockPadding(10, 10, 10, 10)
	self.SLOT = false
end

function PANEL:PaintOver(w, h)
	local itemTable = nut.item.instances[self.itemID]

	if (itemTable and itemTable.paintOver) then
		local w, h = self:GetSize()

		itemTable.paintOver(self, itemTable, w, h)
		
	end
end

function PANEL:PaintBehind(w, h)
	surface.SetDrawColor(0, 0, 0, 85)
	surface.DrawRect(2, 2, w - 4, h - 4)
end

function PANEL:ExtraPaint(w, h)
end

function PANEL:Paint(w, h)
	self:PaintBehind(w, h)
	self:ExtraPaint(w, h)
	local yyyy = self.itemTable:GetIcon()
	if yyyy then
		surface.SetDrawColor(color_white)
		surface.SetMaterial(yyyy)
		surface.DrawTexturedRect(0, 0, w, h)
	end
end

function PANEL:openActionMenu()
	local itemTable = self.itemTable

	assert(itemTable, "attempt to open action menu for invalid item")
	itemTable.player = LocalPlayer()

	local menu = DermaMenu()
	local blackoutMenu = function(s,w,h)
		surface.SetDrawColor(0, 0, 0,200)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(69, 66, 165,255)
		surface.DrawOutlinedRect(0, 0, w, h)
		return true 
		 end
		

		 menu.Paint = blackoutMenu
	local override = hook.Run("OnCreateItemInteractionMenu", self, menu, itemTable)
	if (override) then
		if (IsValid(menu)) then
			menu:Remove()
		end
		return
	end

	for k, v in SortedPairs(itemTable.functions) do
		if (isfunction(v.onCanRun) and not v.onCanRun(itemTable)) then
			continue
		end

		-- TODO: refactor custom menu options as a method for items
		if (v.isMulti) then
			local subMenu, subMenuOption =
				menu:AddSubMenu(L(v.name or k), function()
					
					itemTable.player = LocalPlayer()
					local send = true

					if (v.onClick) then
						send = v.onClick(itemTable)
					end

					local snd = v.sound or SOUND_INVENTORY_INTERACT
					if (snd) then
						if (type(snd) == 'table') then
							LocalPlayer():EmitSound(unpack(snd))
						elseif (type(snd) == 'string') then
							surface.PlaySound(snd)
						end
					end

					if (send != false) then
						netstream.Start("invAct", k, itemTable.id, self.invID)
					end
					itemTable.player = nil
				end)
				subMenuOption:SetTextColor(color_white)
			subMenuOption:SetImage(v.icon or "icon16/brick.png")

			if (not v.multiOptions) then return end

			local options = isfunction(v.multiOptions)
				and v.multiOptions(itemTable, LocalPlayer())
				or v.multiOptions
			for _, sub in pairs(options) do
				subMenu:AddOption(L(sub.name or "subOption"), function()
					itemTable.player = LocalPlayer()
						local send = true

						if (v.onClick) then
							send = v.onClick(itemTable, sub.data)
						end

						local snd = v.sound or SOUND_INVENTORY_INTERACT
						if (snd) then
							if (type(snd) == 'table') then
								LocalPlayer():EmitSound(unpack(snd))
							elseif (type(snd) == 'string') then
								surface.PlaySound(snd)
							end
						end

						if (send != false) then
							netstream.Start(
								"invAct",
								k,
								itemTable.id,
								self.invID,
								sub.data
							)
						end
					itemTable.player = nil
				end)
			end
		else
		local mne= 	menu:AddOption(L(v.name or k), function()
				-- TODO: refactor this action click function
				itemTable.player = LocalPlayer()
					local send = true

					if (v.onClick) then
						send = v.onClick(itemTable)
					end

					local snd = v.sound or SOUND_INVENTORY_INTERACT
					if (snd) then
						if (type(snd) == 'table') then
							LocalPlayer():EmitSound(unpack(snd))
						elseif (type(snd) == 'string') then
							surface.PlaySound(snd)
						end
					end

					if (send != false) then
						netstream.Start("invAct", k, itemTable.id, self.invID)
					end
				itemTable.player = nil
			end)mne:SetImage(v.icon or "icon16/brick.png") mne:SetTextColor(color_white)
		end
	end

	menu:Open()
	itemTable.player = nil
end
NS_ICON_SIZE = 122
vgui.Register("nutItemIcon", PANEL, "DLabel")


local PANEL = {}


function PANEL:InventoryItemDataChanged(item, key, oldValue, newValue)
	self:populateItems()
	self:updateWeight()
	hook.Call("NutListChanged")
	print("hook Change")
end

vgui.Register("nutListInventoryPanelWithHookCall", PANEL, "nutListInventoryPanel")



end


