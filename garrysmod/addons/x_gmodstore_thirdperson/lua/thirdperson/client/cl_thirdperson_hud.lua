--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561198018770455)

CLIENTSIDE FILE
]]--

-- Globals --
THIRDPERSON.crosshairs = {
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
};
--

local function crosshairThirdPerson()
	if THIRDPERSON.client.thirdperson_crosshair == nil then
		return;
	end

	local crosshair = string.lower( THIRDPERSON.client.thirdperson_crosshair );
	local weapon = LocalPlayer():GetActiveWeapon();

	if ( not THIRDPERSON.client.thirdperson_view && not THIRDPERSON.persistentCrosshair ) or THIRDPERSON.runChecks( weapon ) or weapon.IsFAS2Weapon or weapon.CW20Weapon or weapon.IsTFAWeapon then
		return;
	end

	local p = LocalPlayer():GetEyeTrace().HitPos:ToScreen();
	local x, y = p.x, p.y;

	surface.SetDrawColor( THIRDPERSON.getCrosshairColor() );

	if crosshair == "1" then
		local trace = {};
		trace.start = LocalPlayer():GetShootPos();
		trace.endpos = trace.start + LocalPlayer():GetAimVector() * 9000;
		trace.filter = LocalPlayer();
		local tr = util.TraceLine( trace );

		local size = 15 + 20 * ( 1 - ( math.min( ( tr.HitPos - trace.start ):Length(), 1024 ) / 1024 ) );
		local offset = size * 0.5;
		local offset2 = offset - size * 0.1;

		surface.DrawLine( x - offset, y, x - offset2, y );
		surface.DrawLine( x + offset, y, x + offset2, y );
		surface.DrawLine( x, y - offset, x, y - offset2 );
		surface.DrawLine( x, y + offset, x, y + offset2 );

		surface.DrawLine( x - 0.5, y, x + 0.5, y );
	elseif crosshair == "2" then
		draw.RoundedBox( 6, x, y, 6, 6, Color( 0, 0, 0 ) );
		draw.RoundedBox( 5, x, y, 5, 5, THIRDPERSON.getCrosshairColor() );
	elseif crosshair == "3" then
		surface.DrawLine( x - 15, y, x, y );
		surface.DrawLine( x + 15, y, x, y );
		surface.DrawLine( x, y - 15, x, y );
		surface.DrawLine( x, y + 15, x, y );
	elseif crosshair == "4" then
		surface.DrawLine( x - 15, y, x - 5, y );
		surface.DrawLine( x + 15, y, x + 5, y );
		surface.DrawLine( x, y - 15, x, y - 5 );
		surface.DrawLine( x, y + 15, x, y + 5 );
	elseif crosshair == "5" then
		surface.DrawLine( x + 10, y + 10, x - 10, y - 10 );
		surface.DrawLine( x - 10, y + 10, x + 10, y - 10 );
	elseif crosshair == "6" then
		surface.DrawLine( x , y - 18, x + 7, y - 12 );
		surface.DrawLine( x , y, x + 7, y - 6 );
		surface.DrawLine( x + 11, y - 6, x + 18, y );
		surface.DrawLine( x + 11, y - 12, x + 18, y - 18 );
	else
		return;
	end
end

hook.Add( "HUDPaint", "Crosshair", crosshairThirdPerson );

-- 76561222104720366

local function hideDefaultCrosshairThirdPerson( name )

	if THIRDPERSON.client.thirdperson_crosshair ~= nil and THIRDPERSON.client.thirdperson_crosshair ~= "None" then
		-- QuickInfo HUD around crosshair --																																																															// 76561198018770455
		if ( name == "CHUDQuickInfo" ) then
			return false;
		end
		-- --

		-- Crosshair --
		if ( name == "CHudCrosshair" ) then
			if table.HasValue( THIRDPERSON.crosshairs, string.lower( THIRDPERSON.client.thirdperson_crosshair ) ) then
				local weapon = LocalPlayer():GetActiveWeapon();

				if ( not THIRDPERSON.client.thirdperson_view && not THIRDPERSON.persistentCrosshair ) or THIRDPERSON.runChecks( weapon ) or weapon.IsFAS2Weapon or weapon.CW20Weapon or weapon.IsTFAWeapon then
					return true;
				end

				return false;
			end
		end
		-- --
	end
end

hook.Add( "HUDShouldDraw", "thirdperson_hidedefaultcrosshair", hideDefaultCrosshairThirdPerson );