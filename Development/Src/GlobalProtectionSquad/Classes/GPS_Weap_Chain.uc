class GPS_Weap_Chain extends GPS_Weap_InstantHit
	abstract;

var float DelayBetweenChain;
var int MaxChains;

simulated function DoInstantHitBehavior(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	Super.ProcessInstantHit(FiringMode, Impact, NumHits);
}
simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	local GPS_Chain_Handler ChainHandler;

	// This deals damage initially
	DoInstantHitBehavior( FiringMode, Impact, NumHits );

	if( Impact.HitActor != none )
	{
		ChainHandler = Spawn(class'GPS_Chain_Handler', Instigator,,Impact.HitLocation);
		ChainHandler.Init( Impact, self );
		ChainHandler.SpawnChainEffects(GetPhysicalFireStartLoc(), Impact.HitLocation);
	}
}

DefaultProperties
{
	DelayBetweenChain=0.3f
	MaxChains=10
	BaseDamage=20
}
