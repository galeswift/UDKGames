//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GBProj_SaucerRocket extends UTProj_Rocket;

defaultproperties
{
	Speed=5000.0
	MaxSpeed=5000.0
	MomentumTransfer=50000
	Damage=80
	DamageRadius=180.0
	MyDamageType=class'UTDmgType_LeviathanRocket'

	ProjFlightTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_MissileTrailIgnited'
	ProjExplosionTemplate=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_MissileExplosion'
}
