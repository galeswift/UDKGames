class GPS_Weap_GrenadeLauncher_16 extends GPS_Weap_GrenadeLauncher;

// Overwritten to fire 3 shots
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;	
	local Rotator ProjectileRotation;

	CustomProjectile = Super.ProjectileFire();  
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw += 1000;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	CustomProjectile = super.ProjectileFire();
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw -= 1000;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	return CustomProjectile;
}

DefaultProperties
{
	BaseClipCapacity=2
	BaseDamage=1100
	FireInterval(0)=1.0
	BaseReloadTime=3.0
	BaseDamageRadius=16.0
}
