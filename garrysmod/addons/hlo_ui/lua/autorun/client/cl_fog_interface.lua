local o_box128 = Material("materials/o-box-128.png", "noclamp smooth")
local o_box64 = Material("materials/o-box-128.png", "noclamp smooth")
RARITY = RARITY or {
	COMMON = Color(255,255,255),
	UNCOMMON = Color(30,255,0),
	RARE = Color(30,54,255),
	EPIC = Color(163,53,238),
	LEGENDARY = Color(255,127,54),
}
surface.CreateFont( "preview-name", {
	font = "MicrogrammaDEEBolExt", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 24,
	weight = 500,
})
surface.CreateFont( "preview-desc", {
	font = "mynamejeff", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 18,
	weight = 500,
})
ATTRIBUTE_TRANSLATION = {
	armor 	= "Armor",
	health 	= "Health",
	reflect = "Reflect",
}
local redrawINV = nil
local PLAYER_INV_DB = nil
local function GetITEMS() 
	inventory,Inventory = LocalPlayer():getChar():getInv(),{}

	local  items = {}
	 local  data = {}  
	 local iteminstances  = {} 

		for i,v in pairs(inventory:getItems()) do 
	
			local item = nut.item.list[v.uniqueID]  
			items[item.uniqueID] = (items[item.uniqueID] and items[item.uniqueID] or 0) + 1
			data[item.uniqueID] = nut.item.list[v.uniqueID] 
			local tbl = iteminstances[item.uniqueID] or {}
			table.insert(tbl,v.id)
			iteminstances[item.uniqueID] = tbl
			--item.functions.drop
			
			
		end 
		return {items = items,data = data,instances = iteminstances}
end
NS_ICON_SIZE = 122
local outlineChar = Material("materials/halo/top-left.png", "noclamp smooth alphatest")
local outlineChar2 = Material("materials/halo/right-side.png", "noclamp smooth alphatest")


function GetEquippedInstance(slot)
	for i,v in pairs(LocalPlayer():getChar():getInv().items) do

		if v:getData("equip") and v.outfitCategory == slot then 
			return v
		end
	end
end

 function SHOWF4MENU()



	PLAYER_INV_DB=GetITEMS() 

    local Background = vgui.Create( "DFrame" )

    Background:SetSize( 1200, 650 ) 
    Background:SetTitle( "HALO UI MENU" ) 
    Background:SetVisible( true ) 
    Background:SetDraggable( false ) 
    Background:ShowCloseButton( true ) 
    Background:MakePopup()
	Background:Center()
	function Background:Paint(w,h)
		
	end
	Background:SetBGColor(0, 25, 0, 0)
    Background:DockPadding(0, 20, 0, 0)
    local left = vgui.Create("DPanel", Background)
    left:SetText("LEFT")
	left:SetWide(360)
	left:DockPadding(30, 0, 30, 0)
	left:Dock(LEFT) 
	
	left:NoClipping(true)
	function left:Paint(w,h)
		draw.RoundedBox( 12,18, 24, w-40, h-40, Color(25,25,25,190) )
		surface.SetDrawColor(color_white)
		surface.SetMaterial(outlineChar)
		surface.DrawTexturedRect(-6, 0, w+12, h+12)
	end
	local DScrollPanel = vgui.Create( "DPanel", Background )
	DScrollPanel:Dock( FILL )
	DScrollPanel:NoClipping( true )
	function DScrollPanel:Paint(w,h)
		draw.RoundedBox( 12,18, 24, w-40, h-40, Color(25,25,25,190) )
		surface.SetDrawColor(color_white)
		surface.SetMaterial(outlineChar2)
		
		surface.DrawTexturedRect(-6, 0, w+12, h+12)

		
	end
	local grid = vgui.Create( "nutListInventoryPanelWithHookCall", DScrollPanel )
	grid:Dock(FILL)
	grid:SetTall(500) 
	grid:setInventory( LocalPlayer():getChar():getInv())
	NS_ICON_SIZE = 122
	grid:InvalidateLayout(true)
	grid:setColumns(6)
	grid.weight:SetTall(0)
	grid:DockMargin(30,30,30,30)
	redrawINV = function() 
	if true then return end
		PLAYER_INV_DB=GetITEMS() 
		grid:Clear()
		grid:Remove()
		grid = vgui.Create( "DGrid", DScrollPanel )

		grid:SetCols( 7 )
		grid:SetColWide( 122 )
		grid:SetRowHeight(122)
		grid:SetPos( 24, 12 )

		
	
		
	for i ,v in pairs(PLAYER_INV_DB.items) do
		local but = vgui.Create( "DButton" )
		but:SetText( i ) 
		but:SetSize( 106, 106 )
		but.Paint = function(s,w,h) 
			surface.SetDrawColor(0, 0, 0, 125)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(color_white) -- Icon
			surface.SetMaterial(PLAYER_INV_DB.data[i].Icon)
			surface.DrawTexturedRect(0, 0, w, h)
		end
		function but:DoClick()
			CreateContextMenuForItem(i,PLAYER_INV_DB)
		end
		grid:AddItem( but )

	end

	end
	redrawINV()
	local player = vgui.Create("DModelPanel", left)
    player:SetText("LEFT")
	player:Dock(FILL)
	player:SetText("")

	local stats = vgui.Create("DPanel", left)
    stats:SetText("LEFT")
    stats:SetTall(240)
	stats:Dock(BOTTOM)
	local function drawStat(v,width,y ,col,p )
		y=y+1
		col=col or color_white
		p = p or 0
		y = y*26
		surface.SetDrawColor( col )
		surface.DrawOutlinedRect( 6, 6 + y, width-12, 24 )
		col.a = 20
		surface.SetDrawColor( col )
		surface.DrawRect( 6, 6 + y, (width-12) * p, 24 )
		col.a = 255
		col.r = col.r - 25
		col.g = col.g - 25
		col.b = col.b - 25
		draw.SimpleText( v, "DermaDefault", 6 + width/2 - 6, 11  + y , col,TEXT_ALIGN_CENTER )

	end
	stats.Paint = function(v,x,y) 
		drawStat( "Armor: 32% ( 6463 )" ,x,-1,Color(180,170,190),0.32)
		drawStat( "Stamina: 430" ,x,0,Color(125,235,90),1)
		drawStat( "Medical Knowledge: 14" ,x,1,Color(175,90,190),1)


		drawStat( "Strength: 200" ,x,2,Color(255,125,125),1)
		drawStat( "Endurance: 24" ,x,3,Color(255,255,125),1)
		drawStat( "Reflect Chance: 6%" ,x,4,Color(176,175,225),0.06)
		drawStat( "Critical Attack: 12%" ,x,5,Color(255,125,90),0.12)
		drawStat( "Critical Resistance: 27%" ,x,6,Color(170,125,90),0.27)
	
	end

	color_transparent = color_transparent or COLOR(255,255,255,0)
	local equipped = vgui.Create("DPanel", left)
    equipped:SetText("LEFT")
	equipped:SetTall(200) 
	equipped:SetWide(68) 
	equipped:Dock(LEFT)
	equipped:DockMargin( 0, 36, 0, 0 )
	
	local equipped2 = vgui.Create("DPanel", left)
    equipped2:SetText("LEFT")
	equipped2:SetTall(200) 
	equipped2:SetWide(68) 
	equipped2:Dock(RIGHT)
	equipped2:DockMargin( 0, 36, 0, 0 )
	
	local nopaint = function() return  end
	equipped.Paint = nopaint
	equipped2.Paint = nopaint

	local scrollPlayerModel = false 
	local mousepos,nnnn = input.GetCursorPos()
	player.OnDepressed = function( s )
		scrollPlayerModel = true
		mousepos,nnnn = input.GetCursorPos()
	end
	player.OnReleased = function( s )
		scrollPlayerModel = false
	end


	local FOV = 35
	local modelPosy = 0

	player:SetFOV(FOV)
	player:SetModel( "models/player/alyx.mdl" ) -- you can only change colors on playermodels
	local model = ClientsideModel( "models/snowzgmod/payday2/armour/armourfull.mdl" )
	function player:LayoutEntity( Entity ) return end -- disables default rotation
	function player:PreDrawModel( ply )
		if scrollPlayerModel then
			
			local offsetAngle  = select(1,input.GetCursorPos()) - mousepos
		
			local angs = ply:GetAngles().y + (offsetAngle/2)
			ply:SetAngles(Angle(0,  angs,  0))
			input.SetCursorPos(mousepos,nnnn)
		end
	end
	function player:OnMouseWheeled(  scrollDelta )
		FOV = math.Clamp(FOV - scrollDelta,20,35)

		player:SetFOV(FOV)
		
		player:GetEntity():SetPos(Vector(0,0,-(35-FOV)^0.8))
	end
	function player:PostDrawModel( ply )
		
		local pos = ply:GetPos()
		local ang = ply:GetAngles()
			
		
	
	
		model:SetPos(pos)
		model:SetAngles(ang)
	
		model:SetRenderOrigin(pos)
	
		model:SetRenderAngles(ang)

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

	
		local hoverOver = nil
		
		-- ARMOR BUTTONS 
		local ArmorEquips = {"HEAD","LEFT\nSHOULDER","CHEST","LEGS","FEET" , "VISOR","RIGHT\nSHOULDER","UNDER\nARMOR","HANDS","ATTACHMENT"}
		
		 hook.Add("NutListChanged","inventoryPreview",function() 
			equipped2:Clear()
			equipped:Clear()
		for i = 1,#ArmorEquips do
			local item__ = GetEquippedInstance(ArmorEquips[i])
			
			local b = vgui.Create(item__ and "nutItemIcon" or "DLabel",i>=6 and equipped2 or  equipped)
			b:SetTall(64) 
			b:SetWide(64) 
			b:Dock(TOP)
			b:SetContentAlignment(5)
			b:DockMargin(0,0,0,5)
			if item__ then
			b.SLOT = true
			
		
			b:setItemType(GetEquippedInstance(ArmorEquips[i]):getID())
			
		
			b:SetEnabled(true)
			b:SetMouseInputEnabled(true)
 
			
				
	
	 
	
			function b:OnMousePressed( c )
				b:openActionMenu()
			end
			
		
			
		else
			function b:Paint( w, h )
				surface.SetMaterial( o_box64 ) 
				surface.SetDrawColor(185, 250, 255, 255)
				surface.DrawTexturedRect( 0, 0, w, h )
				b:SetText(ArmorEquips[i])
			end
			end

		
		end
	end)
	hook.Call("NutListChanged")
		function Background:PaintOver(w,h)
			if hoverOver then 
			local x,y = Background:CursorPos()
			x = x + 12
			y = y + 12
			local height = 36 + ( hoverOver.attributeCount *18)
			draw.NoTexture()
			surface.SetDrawColor(17, 20, 25, 135)
			surface.DrawTexturedRect( x, y,256, height )
			local yPOS = 0
			draw.DrawText("Hello there!", "preview-name", x+3,y+3, RARITY["RARE"], TEXT_ALIGN_LEFT)
			yPOS = yPOS + 26
			for i,v in pairs (hoverOver.attributes) do
			draw.DrawText("+"..v.." "..i, "preview-desc", x+3,y+3+yPOS, color_white, TEXT_ALIGN_LEFT)
			yPOS = yPOS + 18
			end
			
			end
		end


		function CreateContextMenuForItem(Item,Inventory)

			local blackoutMenu = function(s,w,h)
				surface.SetDrawColor(0, 0, 0,200)
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(69, 66, 165,255)
				surface.DrawOutlinedRect(0, 0, w, h)
				return true 
				 end
				
				local Menu = DermaMenu()
				Menu.Paint = blackoutMenu
			
				for i,v in pairs(Inventory.data[Item].functions) do
					
					if v.onCanRun(LocalPlayer()) then
					local b1 = Menu:AddOption( i )
					b1:SetTextColor(color_white)
					function b1:DoClick()
						print("NEW")
		
						local v = LocalPlayer():getChar():getInv().items[Inventory.instances[Item][1]]
						netstream.Start("invAct", "drop", v.id, v:getID(), v.id)
						
						redrawINV()
					end
					end
				end
				
				
				-- Open the menu
				Menu:Open()
		end



		return Background 


end






 



local wave = Material("materials/ui_radar_compass.png", "noclamp smooth")
local radar = Material("materials/leradar.png", "noclamp smooth")
local helmet = Material("materials/helmet.png", "noclamp smooth")

local outline = Material("materials/bar-2-white.png", "noclamp smooth")
local bar = Material("materials/hp-bar-2.png", "noclamp smooth")

local ammo = Material("materials/bullet.png", "noclamp smooth")
local radardot = Material("materials/ui_radar_spot.png", "noclamp smooth")
local player = LocalPlayer()


surface.CreateFont( "PlayerNAME", {
	font = "MicrogrammaDEEBolExt", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 42, 
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})  
surface.CreateFont( "Ammo2", {
	font = "mynamejeff", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 42,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})
surface.CreateFont( "Ammo4", {
	font = "mynamejeff", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 24,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})
surface.CreateFont( "Ammo3", {
	font = "mynamejeff", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 36,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,  
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

local detectRange = 500
local detectRangeSQ = (detectRange*detectRange)-100000
local sin, cos = math.sin, math.cos
local function rotatePoint(cx, cy, ang, p) 
    local s, c = sin(ang), cos(ang)
    p.x = p.x - cx
    p.y = p.y - cy
    --Rotate Point

    return {
        x = ((p.x * c - p.y * s) + cx),
        y = ((p.x * s + p.y * c) + cy)
    }
end
local ScreenWidth, ScreenHeight = ScrW(), ScrH()
local minimap_Raidus = 340
local radar_raidus = 266
local radar_offset = 300
local orignal_minimap_radium_X, orignal_minimap_radium_Y = (0.15625 * ScrW())-5, ScreenHeight - 165
local minimap_radium_X = orignal_minimap_radium_X - (radar_offset / 2)
local minimap_radium_Y = orignal_minimap_radium_Y - (radar_offset / 2)

local minimap_tau = minimap_Raidus / 2
COLOR_HACKERBLUE = Color(0, 89, 179)
COLOR_BABYBLUE = Color(55, 125, 179)
COLOR_BABYBLUE_ALPHA =Color(55, 125, 179,100)
local minimap_pos_x, minimap_pos_y = minimap_radium_X - 35, ScrH() - 350
local poly = {
    {x = minimap_pos_x, y = minimap_pos_y},
    {x = minimap_pos_x + minimap_Raidus, y = minimap_pos_y},
    {x = minimap_pos_x + minimap_Raidus, y = minimap_pos_y + minimap_Raidus}
}
for i = 1, #poly do
    poly[i] = rotatePoint(minimap_pos_x + minimap_tau, minimap_pos_y + minimap_tau, -0.37, poly[i])
end
local LAST__ANGLE = Angle(0, 0, 0)
local GLOBAL_ALPHA = 0.7
local HP = 1

local ARMOR = 1
 local mp3 = nil
local n = sound.PlayFile(  "sound/low_health.wav", "noplay", function( station, errCode, errStr ) mp3=station end)

hook.Add("CanDrawAmmoHUD","disablePlaylist",function() return false end)
hook.Add("ShouldHideBars","disablePlaylist2",function() return true end)
hook.Add(
    "HUDPaint",
    "uihud_halo",
    function()
	player = LocalPlayer()
        surface.SetAlphaMultiplier(GLOBAL_ALPHA)
        surface.SetDrawColor(color_white)
		surface.SetMaterial(helmet)

		if player:Health() < 15 then mp3:Play() end 
        surface.DrawTexturedRect(0, 0, ScreenWidth, ScreenHeight)

        surface.SetMaterial(radar)
        surface.DrawTexturedRect(minimap_radium_X, minimap_radium_Y, radar_raidus, radar_raidus)

        draw.NoTexture()
        surface.SetAlphaMultiplier(1)
        local curAngle = Angle(0, player:GetAngles().y, 0)

        LAST__ANGLE = LerpAngle(FrameTime() * 20, LAST__ANGLE, curAngle)
        drawMinimap(LAST__ANGLE.y) 
        drawRadar(curAngle)
		
		
		HP = Lerp(20*FrameTime(),HP,player:Health()/player:GetMaxHealth())
		ARMOR = Lerp(20*FrameTime(),ARMOR,player:Armor()/255)
		draw.NoTexture()
  
		 surface.SetDrawColor(155, 155, 255, 255) 
		 
		 
		local hp_bar_width = 411*HP
		local offset_b = 1-HP
		
		surface.SetMaterial(outline)
			surface.DrawTexturedRectUV(ScreenWidth/2-230, 18, 459, 78,0,0,1,1)
        surface.SetMaterial(bar)
			surface.DrawTexturedRectUV(ScreenWidth/2-206+ ((411-hp_bar_width)/2), 40, 411*HP, 32,offset_b,0,1-offset_b,1)
		draw.SimpleText( player:Health(), "Ammo3", ScreenWidth/2-206 + (411/2), 38, color_white, TEXT_ALIGN_CENTER)
		--PLAYER NAME
		draw.SimpleText( string.upper(player:Nick()), "PlayerNAME", 10, ScrH()-70, color_white, TEXT_ALIGN_LEFT)
		if LocalPlayer():getChar() then
		local faction = nut.faction.indices[player:getChar():getFaction()]
		draw.SimpleText( "cR "..player:getChar():getMoney(), "Ammo2", ScreenWidth-10, ScrH()-42, COLOR_HACKERBLUE, TEXT_ALIGN_RIGHT)
		if faction then draw.SimpleText( faction.name .. " " .. nut.class.list[player:getChar():getClass()].name , "Ammo2", 10, ScrH()-42, COLOR_HACKERBLUE, TEXT_ALIGN_LEFT) end
		end
		--AMMO
		surface.SetAlphaMultiplier(0.2)
		
		local CLIP1 = player:GetActiveWeapon() and player:GetActiveWeapon().Clip1 and player:GetActiveWeapon():Clip1() or -1 
		if CLIP1 != -1 then 

		local maxclip = player:GetActiveWeapon():GetMaxClip1()
		draw.SimpleTextOutlined( player:GetActiveWeapon():GetPrintName() , "Ammo4", ScreenWidth-340 + (7*math.min(maxclip,30))-5, 24, color_white, TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP,2,COLOR_BABYBLUE)
		draw.SimpleTextOutlined( CLIP1 .. "/"..player:GetAmmoCount(player:GetActiveWeapon():GetPrimaryAmmoType())   , "Ammo2", ScreenWidth-340 + (7*math.min(maxclip,30)), 42, color_white, TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP,2,COLOR_BABYBLUE)
		surface.SetMaterial(ammo)
		surface.SetAlphaMultiplier(1)
		for i = 1, maxclip do 
		local n = math.floor(((i-1)/30)) * 25
		if player:GetActiveWeapon():Clip1() >= i  then
			surface.SetDrawColor(COLOR_BABYBLUE)
		else
			surface.SetDrawColor(COLOR_BABYBLUE_ALPHA)
		end
		surface.DrawTexturedRect(ScreenWidth-350 + (7*((n == 25) and i-30 or i)) ,52+n,6,24)
		
		end
		end
		  surface.SetAlphaMultiplier(1)
		 		 surface.SetDrawColor(155, 155, 255, 255)
		-- ARMOR 
		surface.SetMaterial(outline)
			surface.DrawTexturedRectUV(ScreenWidth/2-230, ScreenHeight-124, 459, 78,1,1,0,0)
        surface.SetMaterial(bar)
		hp_bar_width = 411*ARMOR
		offset_b = 1-ARMOR
	
	
		surface.DrawTexturedRectUV(ScreenWidth/2-206 + ((411-hp_bar_width)/2), ScreenHeight-100, 411*ARMOR, 32,1-offset_b,1,offset_b,0)
		if player:Armor() > 0 then draw.SimpleText( player:Armor(), "Ammo3", ScreenWidth/2-206 + (411/2), ScrH()-103, color_white, TEXT_ALIGN_CENTER) end
		
    end
)


radar_scan = {"player", "npc_"}
radar_scan_hostile = {["npc_vortigaunt"]=true}
radar_HOSTILE = Color(255,100,100) 
radar_FRIENDLY = Color(255, 242, 128) 

local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["DarkRP_LocalPlayerHUD"] = true,
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end

	-- Don't return anything here, it may break other addons that rely on this hook.
end )

local center = {x = minimap_radium_X + (radar_raidus / 2), y = minimap_radium_Y + (radar_raidus / 2)}
function drawRadar(curAngle)
    local entites = {}
    for i = 1, 1000 do
        local ent = ents.GetByIndex(i)
        if ent:IsValid() then
            local type = ent:GetClass()
            for k, v in ipairs(radar_scan) do
                if string.find(type, v) then
                    table.insert(entites, ent)
                end
            end
        end
    end 

    draw.NoTexture()
	local pPOS =  player:GetPos()
    for i, v in pairs(entites) do
		local e = v:GetPos()
		local distance = pPOS:DistToSqr(e)
		if distance < detectRangeSQ and distance!=0 then 
		local n = {x = 0,y=0}
		local p =  math.sqrt(distance)/detectRange

		 
		local angleP = math.deg(math.atan2( pPOS.y-e.y ,pPOS.x-e.x ))
		angleP = angleP - 90
		angleP = ( -angleP + curAngle.y)
		local legacyAngle = angleP
		angleP = math.rad(angleP)

		n.x = n.x + (((radar_raidus / 2)*p) * math.cos(angleP))
		n.y = n.y + (((radar_raidus / 2)*p) * math.sin(angleP))
		
		local anglediff = ((legacyAngle+90) + 180 + 360) % 360 - 180
		if radar_scan_hostile[v:GetClass()]  then
		
		if (p<0.17 or (anglediff <= 45 and anglediff>=-45)) then
      --  if (angleP < -1.1)then 
			surface.SetDrawColor(radar_HOSTILE)
			surface.SetMaterial(radardot) 
			surface.DrawTexturedRect(center.x-5 + n.x, center.y-5 + n.y, 12, 12)
			end
			else
			surface.SetDrawColor(radar_FRIENDLY)
			surface.SetMaterial(radardot) 
			surface.DrawTexturedRect(center.x-5 + n.x, center.y-5 + n.y, 12, 12)
		end
		end
    end
end
function drawMinimap(ang)
    -- Reset everything to known good
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(0)
    -- render.SetStencilCompareFunction( STENCIL_ALWAYS )
    render.SetStencilPassOperation(STENCIL_KEEP)
    -- render.SetStencilFailOperation( STENCIL_KEEP )
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()

    -- Enable stencils
    render.SetStencilEnable(true)
    -- Set everything up everything draws to the stencil buffer instead of the screen
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)

    -- Draw a weird shape to the stencil buffer
    draw.NoTexture()
    surface.SetDrawColor(color_white)
    surface.DrawPoly(poly)

    -- Only draw things that are in the stencil buffer
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilFailOperation(STENCIL_KEEP)

    -- Draw our clipped text
    surface.SetMaterial(wave)
    surface.SetDrawColor(COLOR_HACKERBLUE)
    surface.DrawTexturedRectRotated(
        minimap_tau + minimap_pos_x,
        minimap_tau + minimap_pos_y,
        minimap_Raidus,
        minimap_Raidus,
        -ang
    )

    -- Let everything render normally again
    render.SetStencilEnable(false)
end

print("Ha")