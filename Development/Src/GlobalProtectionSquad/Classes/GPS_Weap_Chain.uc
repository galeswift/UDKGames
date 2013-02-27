class GPS_Weap_Chain extends GPS_Weap_InstantHit
	abstract;

// How much time between chaining that we want
var float DelayBetweenChain;

// How many times we can chain
var int MaxChains;

// The emitter to show when chaining
var ParticleSystem ChainEmitter;

// The color of the emitter
var Color ChainColor;

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
	ChainEmitter = ParticleSystem'GPS_FX.Effects.P_WP_ChainGun'
	ChainColor=(R=255, G=100, B=100)
}
