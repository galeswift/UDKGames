class GPS_Weap_GrenadeLauncher_GroundAOE extends GPS_Weap_GrenadeLauncher;

// GroundAOE effects when using GroundAOE projectiles
var ParticleSystem GroundAOEEmitter;
var ParticleSystem GroundAOEHitEmitter;

// How much time between dot damage
var float DelayBetweenDamage;

// How many times we can damage
var int MaxHits;

// The color of the emitter
var Color HitColor;

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
	//GroundAOEEmitter = ParticleSystem'GPS_FX.Effects.P_WP_DOT'
	GroundAOEEmitter=ParticleSystem'GPS_FX.Effects.P_WP_GroundAOE'
	GroundAOEHitEmitter = ParticleSystem'GPS_FX.Effects.P_WP_DOT_Tick'
	HitColor=(R=255, G=0, B=0)

	MaxHits=10
	DelayBetweenDamage=0.5
}
