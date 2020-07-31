
local string = string
local table = table
local teamtable = {}

function usec.CreatePermaDoors()
	
	for k,v in pairs(team.GetAllTeams())do
		teamtable[v.Name]=k
	end
	
	local map = game.GetMap():gsub("_","-"):sub(1,14)
	local dir = "usec/"..map
	local dirs = dir.."/"
	file.CreateDir("usec")
	file.CreateDir(dir)
	local files = file.Find(dirs.."*.txt","DATA")
	for k,v in pairs(files) do
		local filetbl = util.JSONToTable(file.Read(dirs..v,"DATA"))
		
		if not filetbl then continue end
		local kp = ents.Create("uni_keypad")
			kp:SetAngles(filetbl.ang)
			kp:SetPos(filetbl.pos)
			kp:SetCreator(Entity(0))
			kp:SetUCreator(Entity(0))
			kp:SetColor(Color(255,255,255))
			kp:Spawn()
			kp:GetPhysicsObject():EnableMotion(false)
			
			
			local filter = {}
			for k,v in pairs(filetbl.filter)do
				local t = teamtable[v]
				if team.Valid(t) then
					filter[t] = true
				else
					print("Permanent keypad tried to use a team which doesn't exist: ","Door: "..filetbl.permid,"Team: "..v)
				end
			end
			kp:SetFilter(filter)
			
			kp:SetTimed(filetbl.timed)
			kp:SetTimer(filetbl.timer)
			kp:SetDelay(filetbl.delay)
			
			kp:SetToggle(filetbl.toggle)
			kp:SetToggleMode(filetbl.toggmode)
			kp:SetAllClose(filetbl.allclose)
			
			kp:SetPaid(filetbl.paid)
			kp:SetPrice(filetbl.price)
			kp:SetAuthPay(filetbl.auth)
			
			kp:SetPW("0000")
			
			kp:SetPermanent(true)
			kp:SetPermID(filetbl.permid)
			
		
		local doors = kp:GetDoors()
		for i,door in pairs(filetbl.doors) do
			
			if door.map then
				local ent = ents.GetMapCreatedEntity(door.id)
				if IsValid(ent) then
					constraint.NoCollide(kp,ent,0,0)
					table.insert(doors,ent)
				end
			else
				
				local d = ents.FindInBox(door.pos+Vector(-2,-2,-2),door.pos+Vector(2,2,2))[1]
				if d and d:IsValid() and d:GetClass() == "prop_physics" then
					constraint.NoCollide(kp,d,0,0)
					table.insert(doors,d)
				else
					local ent = ents.Create("prop_physics")
						ent:SetPos(door.pos)
						ent:SetAngles(door.ang)
						ent:SetModel(door.mdl)
						ent:SetMaterial(door.mat)
						ent:SetColor(door.col)
						ent:Spawn()
						ent:Activate()
						ent:GetPhysicsObject():EnableMotion(false)
					constraint.NoCollide(kp,ent,0,0)
					table.insert(doors,ent)
				end
				
			end
			
		end
			
	end
end
hook.Add("InitPostEntity","usec_permakeypads",usec.CreatePermaDoors)
hook.Add("PostCleanupMap","usec_preservedoors",usec.CreatePermaDoors)

hook.Add("PlayerInitialSpawn","usec_doornetwork",function(ply)
	timer.Simple(3,function()
		for k,v in pairs(ents.FindByClass("uni_keypad"))do
			net.Start("usec_sync")
				net.WriteEntity(v)
				net.WriteBool(v:GetPermanent())
				net.WriteBool(v:GetPaid())
				net.WriteFloat(v:GetPrice())
			net.Send(ply)
		end
	end)
end)


function usec.WriteKeypad(kp)
	
	local map = game.GetMap():gsub("_","-"):sub(1,14)
	local dir = "usec/"..map
	local dirs = dir.."/"
	
	local id = kp:GetPermID()
	local filename = id:lower():gsub("[\\/:%*%?\"<>| _%u]","-")
	local filetbl = {}
	filetbl.pos = kp:GetPos()
	filetbl.ang = kp:GetAngles()
	
	local filter = {}
	for k,v in pairs(kp:GetFilter()) do
		if isnumber(k) then
			table.insert(filter,team.GetName(k))
			
		end
	end
	filetbl.filter = filter
	
	filetbl.timed = kp:GetTimed()
	filetbl.timer = kp:GetTimer()
	filetbl.delay = kp:GetDelay()
	
	filetbl.paid = kp:GetPaid()
	filetbl.price = kp:GetPrice()
	filetbl.auth = kp:GetAuthPay()
	
	filetbl.toggle = kp:GetToggle()
	filetbl.toggmode = kp:GetToggleMode()
	filetbl.allclose = kp:GetAllClose()
	
	filetbl.permid = kp:GetPermID()
	
	filetbl.doors = {}
	for k,door in pairs(kp:GetDoors()) do
		local d = {}
		if not IsValid(door) then continue end
		if door:CreatedByMap() then
			d.map = true
			d.id = door:MapCreationID()
		else
			d.map = false
			d.pos = door:GetPos()
			d.ang = door:GetAngles()
			d.mdl = door:GetModel()
			d.mat = door:GetMaterial()
			d.col = door:GetColor()
		end
		table.insert(filetbl.doors, d)
	end
	
	file.Write(dirs..filename..".txt",util.TableToJSON(filetbl))
end

function usec.DeleteKeypad(id)
	
	local map = game.GetMap():gsub("_","-"):sub(1,14)
	local dir = "usec/"..map
	local dirs = dir.."/"
	
	local filename = id:lower():gsub("[\\/:%*%?\"<>| _%u]","-")
	if file.Exists(dirs..filename..".txt","DATA") then
		file.Delete(dirs..filename..".txt")
	end
end