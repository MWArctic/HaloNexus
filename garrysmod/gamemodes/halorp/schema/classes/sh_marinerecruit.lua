-- Set the 'nice' display name for the class.
CLASS.name = "Marine - Recruit"
-- Set the faction that the class belongs to.
CLASS.faction = FACTION_UNSC

-- Set what happens when the player has been switched to this class.
function CLASS:OnSet(client)

end

-- (class's numeric ID. ) We set a global variable to save this index for easier reference.
CLASS_MARINERECRUIT = CLASS.index