ITEM.name = "Brick"
ITEM.model = Model("models/props_junk/CinderBlock01a.mdl")
ITEM.desc = "My friend is %Friend|no one%."
function ITEM:getDesc(self) 
return self and self.desc or "fixed items haha"
end 