print("ARMOR LOADED")
local model = ClientsideModel( "models/snowzgmod/payday2/armour/armourrthigh.mdl" )
local armorpices = {
"models/snowzgmod/payday2/armour/armourrthigh.mdl",
"models/snowzgmod/payday2/armour/armourlthigh.mdl",
"models/snowzgmod/payday2/armour/armourvest.mdl"
}
model:SetNoDraw( true )
function PrintBones(ent)
    for i=0, ent:GetBoneCount()-1 do
        print(i,ent:GetBoneName(i))
    end
end
hook.Add( "PostPlayerDraw" , "manual_model_draw_example" , function( ply )

	if not IsValid(ply) or not ply:Alive() then return end

			

			
	local pos = ply:GetPos()
	local ang = ply:GetAngles()
		
	


	model:SetPos(pos)
	model:SetAngles(ang)

	model:SetRenderOrigin(pos)

	model:SetRenderAngles(ang)
	for armorslot = 1,#armorpices do
	model:SetModel(armorpices[armorslot])
	model:SetupBones()
		for i = 0,ply:GetBoneCount() do
			local bone = ply:GetBoneName(i)
			if bone ~= "__INVALIDBONE__" then
			local playerbone = model:LookupBone( bone )
				if playerbone then
				model:SetBoneMatrix( playerbone, ply:GetBoneMatrix(  i  ))
				end
			end
		end
			
			model:DrawModel()
	end

	

	


end )