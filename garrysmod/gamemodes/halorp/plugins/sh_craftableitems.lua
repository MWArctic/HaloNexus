local item_prefix = "am"


items = {}
local Item = nil
function createItem(data) 
	local self = data or {}
	Item = self
	Item.Push = function () 
	table.insert(items, Item)
	end
	return self
end


 


items.Bloodthorn = createItem()
Item.Name = "Bloodthorn"
Item.Desc = "A thorny root that is known to cause slight bleeding."

Item.weight = 0.5
 
items.HellFlower = createItem()
Item.Name = "Hell Flower"
Item.Desc = "The Name comes from the bright blood colored Petals."
Item.weight = 0

item_prefix = item_prefix .. "_"
function PLUGIN:PluginLoaded()
  
		for k, v in pairs(items) do

			print(item_prefix..string.lower(v.Name).."_id")
			local ITEM = nut.item.register((item_prefix..string.lower(v.Name).."_id"), "base_consume", nil, nil, true)
			ITEM.name        = v.Name
            ITEM.desc         = v.Desc or "%20NO DESC SET%20"
            ITEM.category    = "Misc"
            ITEM.model     = v.Model or "models/props_lab/clipboard.mdl"
			ITEM.isStackable     = true
			ITEM.maxQuantity = 1024
			ITEM.weight = v.weight or 1
			ITEM.Icon = Material("icons/"..item_prefix..string.lower(v.Name).."_id.png")
		end


end



if (CLIENT) then



end