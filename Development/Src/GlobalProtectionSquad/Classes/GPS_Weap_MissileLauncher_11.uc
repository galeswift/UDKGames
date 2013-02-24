class GPS_Weap_MissileLauncher_11 extends GPS_Weap_MissileLauncher;

// Overwritten to fire 2 shots
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;	
	local Rotator ProjectileRotation;

	CustomProjectile = Super.ProjectileFire();  
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw += 500;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	CustomProjectile = Super.ProjectileFire();  
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw -= 500;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	return CustomProjectile;
}
DefaultProperties
{
	BaseClipCapacity=20
	BaseDamage = 100.0
	BaseDamageRadius = 1.0
	BaseReloadTime=5.0
	BaseAccuracy = ACCURACY_B_MINUS
	FireInterval(0)=0.1 
	BaseIgniteTime=0.5;
}
