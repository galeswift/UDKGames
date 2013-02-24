class GPS_Weap_GrenadeLauncher_13 extends GPS_Weap_GrenadeLauncher;

// Overwritten to fire 3 shots
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;	
	local Rotator ProjectileRotation;

	CustomProjectile = Super.ProjectileFire();  
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw += 1500;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	CustomProjectile = super.ProjectileFire();
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw -= 1500;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	// Normal Shot
	CustomProjectile = super.ProjectileFire();

	return CustomProjectile;
}

DefaultProperties
{
	BaseClipCapacity=2
	BaseDamage=600
	FireInterval(0)=0.5
	BaseReloadTime=4.0
	BaseDamageRadius=9.0
}
