ITEM.name = "Evan's Big Chungus Cosplay Suit Mask" --< Item Name
ITEM.desc = "Cum stains on the face " --< Item Description
ITEM.category = "Outfit" --< Category, used in stuff like AdminSpawnMenu and Business tab, keep this as is
ITEM.model = "models/maxofs2d/cube_tool.mdl" --<The World Model, ie the model of the item when you drop it or while its in your inventory
ITEM.width = 1  --<Keep this as is
ITEM.height = 1  --<Keep this as is
ITEM.outfitCategory = "HEAD"
ITEM.Icon = Material("models/props_c17/paper01", "smooth")
ITEM.isStackable = false
ITEM.maxQuantity =  1
ITEM.Attributes = {
    ARMOR   =   532,
    CRIT    =   126,
    ENDURANCE = 64,
}




ITEM:hook("Equip", function(item)
    item:setData("soulbound",true) 
    print("SOULBOUND")
end)

function ITEM:getDesc()
    local d = ""
    if self:getData("soulbound") then
        d = '<color="255,125,100">-Soulbound</color>\n'
    end
    for i,v in pairs(self.Attributes) do
        d=d..'<color="100,255,100">+'..v..'</color> '..i.."\n"
    end
return d
end