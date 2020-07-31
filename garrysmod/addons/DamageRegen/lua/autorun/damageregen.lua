if CLIENT then return end

local Health_Regen_Delay = CreateConVar( "regen_delay", 5, FCVAR_REPLICATED, "Delay from healing", 0,0 )


hook.Add("EntityTakeDamage", "damageTakenEvent", function(ply) 
    ply.HealthRegenTimer = CurTime() + Health_Regen_Delay:GetInt()
end)

hook.Add("PlayerTick", "heal_player", function(ply,mv) 


    if ply:Health() < ply:GetMaxHealth()*0.25 and (ply.HealthRegenNow or 0) < CurTime() and (ply.HealthRegenTimer or 0) < CurTime() then
        ply.HealthRegenNow = CurTime()+0.5
        ply:SetHealth(ply:Health()+1)
    end
    

end)
