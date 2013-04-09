class GPS_Weap_GrenadeLauncher extends GPS_Weap_Base;

var float FuseLength;

// Overwritten to fire 3 shots
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;

	CustomProjectile = super.ProjectileFire();

	if (GPS_Proj_Grenade(CustomProjectile) != none && FuseLength > 0.0)
	{
		GPS_Proj_Grenade(CustomProjectile).SetFuse(FuseLength);
	}

	return CustomProjectile;
}

DefaultProperties
{
	FireInterval(0)=1.2
	WeaponProjectiles(0)=class'GPS_Proj_Grenade_Impact'

	BaseDamage = 100
	BaseDamageRadius = 7.0
	BaseSpeed=700

	FuseLength=0.0
}
