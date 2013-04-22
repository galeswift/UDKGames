class GAProjectileRocket extends GAProjectile;

DefaultProperties
{
	ProjFlightTemplate=none
	ProjExplosionTemplate=none
	ExplosionDecal=none

	DecalWidth=128.0
	DecalHeight=128.0
	speed=1350.0
	MaxSpeed=1350.0
	Damage=100.0
	DamageRadius=220.0
	MomentumTransfer=85000
	MyDamageType=class'UTDmgType_Rocket'
	LifeSpan=8.0
	AmbientSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Travel_Cue'
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	RotationRate=(Roll=50000)
	bCollideWorld=true
	CheckRadius=42.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTRocketLight'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'

	bWaitForEffects=true
	bAttachExplosionToVehicles=false
}
