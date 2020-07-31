

AddCSLuaFile()

SWEP.PrintName				= "Admin Keypad Cracker"
SWEP.Author					= "Bobblehead"
SWEP.Purpose				= "Checking keypads and fading doors."
SWEP.Instructions			= "Left click a keypad to crack it instantly."
SWEP.Category				= "Unisec"

SWEP.Slot					= usec.Config.CrackerSlot - 1
SWEP.SlotPos				= 2

SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

SWEP.ViewModel				= Model( "models/weapons/v_c4.mdl" )
SWEP.WorldModel				= Model( "models/weapons/w_c4.mdl" )
SWEP.ViewModelFOV			= 54
SWEP.UseHands				= true

SWEP.DrawCrosshair			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DrawAmmo				= false
SWEP.AdminOnly				= true

if CLIENT then
	SWEP.WepSelectIcon 			= surface.GetTextureID( "unisec/cracker" )
end

function SWEP:PrintWeaponInfo( x, y, alpha ) end

function SWEP:SetupDataTables()
	-- self:NetworkVar( "String", 0, "Mode" )
	-- self:NetworkVar( "Int", 0, "NavEdit" )
end

function SWEP:Initialize()
	
	
	self:SetHoldType( "pistol" )
	
	self.LastReload = CurTime()
	
end

function SWEP:Deploy()

	return true
end
function SWEP:Holster()

	return true
end

function SWEP:PrimaryAttack()
	if game.SinglePlayer() then
		self:CallOnClient("PrimaryAttack")
	end
	self:SetNextPrimaryFire( CurTime() + 0.1 )

	-- self:EmitSound( Sound("ambient/water/drip"..math.random(1,4)..".wav") )
	
	if SERVER then
		local ent = self:GetOwner():GetEyeTrace().Entity
		if IsValid(ent) then
			self:EmitSound( Sound("buttons/button16.wav") )
			ent:AccessGranted()
			self:ShootEffects( self )
			timer.Simple(3,function()
				self:SendWeaponAnim(ACT_VM_DRAW)
			end)
		end
	end
	
end

function SWEP:DrawHUD()
	draw.WordBox( 8, ScrW()/2 - 101, ScrH()-160, "Left click a keypad to crack it instantly.", "ChatFont", Color(0,0,0,150), Color(255,255,255) )
end