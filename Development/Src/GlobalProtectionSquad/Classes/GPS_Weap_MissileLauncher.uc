class GPS_Weap_MissileLauncher extends GPS_Weap_Base;

var float BaseIgniteTime;

// Overwritten to have the missile shoot straight for a little if needed
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;

	CustomProjectile = super.ProjectileFire();

	if (GPS_Proj_Missile(CustomProjectile) != none)
	{
		GPS_Proj_Missile(CustomProjectile).SetIgniteTime(BaseIgniteTime);
	}

	return CustomProjectile;
}

DefaultProperties
{
	FireInterval(0)=1.0
	WeaponProjectiles(0)=class'GPS_Proj_Missile'
	BaseSpeed = 750		
	BaseAcceleration=750
	BaseDamage=40.0
	BaseDamageRadius=0
	BaseMaxSpeed=3000.0
	BaseIgniteTime=0.0;
}
