 print ("Now Playing: I really fucking hate my life.")
hook.Add("CanPlayerDropItem","fuckingdontletthemdropshit",function(client, itemObject) 
	if itemObject:getData("soulbound",false) then
		client:notify("You can not drop items that are bound to your character.")
		return false
	end
	
end)

 local item_prefix = "hl"


ARMORS = {}
local Item = nil
local function createItem(data) 
	local self = data or {}
	Item = self
	Item.Push = function () 
	table.insert(ARMORS, Item)
	end
	return self
end


 

 
ARMORS.Bloodthorn = createItem()
Item.Name = "Bloodthorn"
Item.Desc = "A thorny root that is known to cause slight bleeding."

Item.weight = 0.5
Item.slot = "head"

ARMORS.HellFlower = createItem()
Item.Name = "Hell Flower"
Item.Desc = "The Name comes from the bright blood colored Petals."
Item.weight = 0
Item.slot = "head"
item_prefix = item_prefix .. "_"
function PLUGIN:PluginLoaded()
  
		for k, v in pairs(ARMORS) do

			print(item_prefix..string.lower(v.Name).."_id")
			local ITEM = nut.item.register((item_prefix..string.lower(v.Name).."_id"), "outfit", nil, nil, true)
			ITEM.name        = v.Name
            ITEM.desc         = v.Desc or "%20NO DESC SET%20"
            ITEM.category    = "Misc"
            ITEM.model     = v.Model or "models/props_lab/clipboard.mdl"
			ITEM.isStackable     = true
			ITEM.maxQuantity = 1024
			ITEM.weight = v.weight or 1
			ITEM.Icon = Material("icons/"..item_prefix..string.lower(v.Name).."_id.png")
			ITEM.outfit = v.slot
		
		end


end




