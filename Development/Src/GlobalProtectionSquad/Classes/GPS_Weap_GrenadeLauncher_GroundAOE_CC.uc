class GPS_Weap_GrenadeLauncher_GroundAOE_CC extends GPS_Weap_GrenadeLauncher_GroundAOE;

// Movement modification
var float ModifiedMovementPercentage;

// Overwritten to fire 3 shots
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;

	CustomProjectile = super.ProjectileFire();

	if (GPS_Proj_GroundAOE_CC(CustomProjectile) != none)
	{
		GPS_Proj_GroundAOE_CC(CustomProjectile).SetGunOwner(self);
	}

	return CustomProjectile;
}

DefaultProperties
{
	WeaponProjectiles(0)=class'GPS_Proj_GroundAOE_CC'
	HitColor=(R=0, G=0, B=255)

	MaxHits=10
	DelayBetweenDamage=0.5
	ModifiedMovementPercentage=0.5
}
