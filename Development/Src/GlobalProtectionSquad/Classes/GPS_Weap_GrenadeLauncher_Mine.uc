class GPS_Weap_GrenadeLauncher_Mine extends GPS_Weap_GrenadeLauncher;

// Mine effects when using Mine projectiles
var ParticleSystem MineEmitter;
var ParticleSystem MineExplosionEmitter;

// How close to the mine to trigger
var float TriggerRadius;

// Overwritten to fire 3 shots
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;

	CustomProjectile = super.ProjectileFire();

	if (GPS_Proj_Mine(CustomProjectile) != none)
	{
		GPS_Proj_Mine(CustomProjectile).SetGunOwner(self);
	}

	return CustomProjectile;
}

DefaultProperties
{
	WeaponProjectiles(0)=class'GPS_Proj_Mine'
	MineEmitter=ParticleSystem'GPS_FX.Effects.P_WP_GroundAOE'
	MineExplosionEmitter = ParticleSystem'GPS_FX.Effects.P_WP_DOT_Tick'

	TriggerRadius=300
}
