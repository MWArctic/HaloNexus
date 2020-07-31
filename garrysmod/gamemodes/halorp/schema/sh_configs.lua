WEAPON_REQSKILLS = {}

local function addRequire(itemID, reqAttribs)
	WEAPON_REQSKILLS[itemID] =  reqAttribs
end

nut.currency.symbol = "C"
nut.currency.singular = "Commonwealth Chip"
nut.currency.plural = "Commonwealth Chips"

addRequire("ak47", {gunskill = 3})
addRequire("healvial", {medical = 3})

-- Lists of item to drop when player dies.
-- The number represents the chance of drop of the item.
DROPITEM = {
	["item_class_to_drop"] = 1,
}

-- Adding Schema Specific Configs.
nut.config.setDefault("font", "Bitstream Vera Sans")

nut.config.add("schemaVars", 25, "A Variable for schema", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("deathWeapon", false, "Drop weapon when player dies?", nil, {
	category = "penalty"
})

nut.config.crosshair = false
nut.config.drawVignette = false