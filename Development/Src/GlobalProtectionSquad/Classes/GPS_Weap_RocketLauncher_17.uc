class GPS_Weap_RocketLauncher_17 extends GPS_Weap_RocketLauncher;

// Overwritten to fire 6 shots
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;	
	local Rotator ProjectileRotation;
	local int i;
	local int YawStart;
	local int YawIncrement;

	YawIncrement = 300;
	YawStart = 0 - YawIncrement*2.5;
	for (i = 0; i < 6; i++)
	{
		CustomProjectile = Super.ProjectileFire();  
		ProjectileRotation = Rotator(CustomProjectile.Velocity);
		ProjectileRotation.Yaw += YawStart + YawIncrement*i;

		CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);
	}

	return CustomProjectile;
}

DefaultProperties
{
	BaseClipCapacity=2
	BaseDamage = 300.0
	BaseDamageRadius = 10.0
	BaseReloadTime=3.0
	BaseAccuracy = ACCURACY_S_PLUS
}
