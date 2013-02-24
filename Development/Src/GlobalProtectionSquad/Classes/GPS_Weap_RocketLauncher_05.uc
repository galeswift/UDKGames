class GPS_Weap_RocketLauncher_05 extends GPS_Weap_RocketLauncher;

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
	BaseClipCapacity=4
	BaseDamage = 65.0
	BaseDamageRadius = 6.0
	BaseReloadTime=1.5
	BaseBurstAmount=4
	BaseBurstTime=0.1
}
