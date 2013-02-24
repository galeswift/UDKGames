class GPS_Weap_GrenadeLauncher_10 extends GPS_Weap_GrenadeLauncher;

// Overwritten to fire straight (little to no arc)
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;

	CustomProjectile = super.ProjectileFire();

	if (GPS_Proj_Grenade(CustomProjectile) != none)
	{
		GPS_Proj_Grenade(CustomProjectile).CustomGravityScaling = 0.1f;
	}

	return CustomProjectile;
}

DefaultProperties
{
	BaseClipCapacity=5
	BaseDamage=450
	FireInterval(0)=0.5
	BaseReloadTime=3.0
	BaseDamageRadius=9.0
}
