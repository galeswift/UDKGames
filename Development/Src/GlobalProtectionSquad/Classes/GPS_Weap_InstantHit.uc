class GPS_Weap_InstantHit extends GPS_Weap_Base
	abstract;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	InstantHitDamage[0] = BaseDamage;
	InstantHitDamage[1] = BaseDamage;
}

simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	Super.ProcessInstantHit(FiringMode, Impact, NumHits);
}

DefaultProperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	WeaponRange=100000
}
