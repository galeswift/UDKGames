class GPS_Weap_GrenadeLauncher_GroundAOE extends GPS_Weap_GrenadeLauncher;

// GroundAOE effects when using GroundAOE projectiles
var ParticleSystem GroundAOEEmitter;

// How much time between dot damage
var float DelayBetweenDamage;

// How many times we can damage
var int MaxHits;

// Overwritten to fire 3 shots
simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;

	CustomProjectile = super.ProjectileFire();

	if (GPS_Proj_GroundAOE(CustomProjectile) != none)
	{
		GPS_Proj_GroundAOE(CustomProjectile).SetGunOwner(self);
	}

	return CustomProjectile;
}

DefaultProperties
{
	WeaponProjectiles(0)=class'GPS_Proj_GroundAOE'
	GroundAOEEmitter=ParticleSystem'GPS_FX.Effects.P_WP_GroundAOE'

	MaxHits=10
	DelayBetweenDamage=0.5
}
