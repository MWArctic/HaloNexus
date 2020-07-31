ITEM.name = "Consume Base"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.isStackable = true
ITEM.desc = "CONSUNM ITEM DESC NOT SET"
ITEM.category = "Misc"
ITEM.isStackable = true
ITEM.maxQuantity = 1024
function ITEM:getDesc()
	return self.desc
end

function ITEM:paintOver(item, w, h)
	--local quantity = item:getQuantity()
	
	--nut.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "nutChatFont")
end



