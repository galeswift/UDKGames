class GPS_Weap_AssaultRifle_09 extends GPS_Weap_AssaultRifle;

// Overwritten to fire burts
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;	
	local Rotator ProjectileRotation;

	CustomProjectile = Super.ProjectileFire();  
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw += 65535/13;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	CustomProjectile = super.ProjectileFire();
	ProjectileRotation = Rotator(CustomProjectile.Velocity);
	ProjectileRotation.Yaw -= 65535/13;

	CustomProjectile.Velocity = VSize(CustomProjectile.Velocity) * vector(ProjectileRotation);

	return CustomProjectile;
}

DefaultProperties
{
	BaseDamage=12.0
	BaseClipCapacity=105
	BaseAccuracy=ACCURACY_B_PLUS
	BaseRange=180.0
}