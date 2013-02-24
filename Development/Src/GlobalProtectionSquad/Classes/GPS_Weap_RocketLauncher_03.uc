class GPS_Weap_RocketLauncher_03 extends GPS_Weap_RocketLauncher;

// Overwritten to fire 3 shots
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;	
	local Rotator ProjectileRotation;

	CustomProjectile = Super.ProjectileFire();  
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw += 250;
	ProjectileRotation.Pitch -= 250;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	CustomProjectile = super.ProjectileFire();
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw -= 250;
	ProjectileRotation.Pitch -= 250;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	CustomProjectile = super.ProjectileFire();
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Pitch += 250;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	return CustomProjectile;
}

DefaultProperties
{
	BaseClipCapacity=2
	BaseDamage = 100.0
	BaseDamageRadius = 6.0
	BaseReloadTime=1.5
	BaseAccuracy = ACCURACY_B
}
