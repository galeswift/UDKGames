class GPS_Weap_DOT extends GPS_Weap_Base
	abstract;

// How much time between dot damage
var float DelayBetweenDamage;

// How many times we can damage
var int MaxHits;

// The emitter to show when DOTing
var ParticleSystem DOTEmitter;
var ParticleSystem DOTHitEmitter;
var ParticleSystem SpreadEmitter;

// The color of the emitter
var Color DOTColor;

var bool bSpreadIfDead;
var bool bSpreadWhenDone;
var bool bSpreadEachHit;
var int NumSpreadTargets;
var bool bAOE;
var int iAOERadius;

simulated function Projectile ProjectileFire()
{
	local Projectile CustomProjectile;

	CustomProjectile = super.ProjectileFire();

	if (GPS_Proj_DOT(CustomProjectile) != none)
	{
		GPS_Proj_DOT(CustomProjectile).SetGunOwner(self);
	}

	return CustomProjectile;
}

DefaultProperties
{
	WeaponProjectiles(0)=class'GPS_Proj_DOT'
	BaseClipCapacity=20
	DelayBetweenDamage=1.5f
	MaxHits=10
	BaseDamage=40
	DOTEmitter = ParticleSystem'GPS_FX.Effects.P_WP_DOT'
	DOTHitEmitter = ParticleSystem'GPS_FX.Effects.P_WP_DOT_Tick'
	SpreadEmitter = ParticleSystem'GPS_FX.Effects.P_WP_ChainGun'
	DOTColor=(R=50, G=255, B=50)
}
