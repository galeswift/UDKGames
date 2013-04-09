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

// How often to remove entries from the hit list
var float ChainDecayTimer;

// If true, chains come from the heavens
var bool bChainFromSky;

simulated function DoInstantHitBehavior(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	Super.ProcessInstantHit(FiringMode, Impact, NumHits);
}
simulated function ProcessInstantHit(byte FiringMode, ImpactInfo Impact, optional int NumHits)
{
	local GPS_Handler_Chain ChainHandler;

	// This deals damage initially
	DoInstantHitBehavior( FiringMode, Impact, NumHits );

	if( Impact.HitActor != none )
	{
		ChainHandler = Spawn(class'GPS_Handler_Chain', Instigator,,Impact.HitLocation);
		ChainHandler.Init( Impact, self );
		ChainHandler.SpawnChainEffects(GetPhysicalFireStartLoc(), Impact.HitLocation);
	}
}

DefaultProperties
{
	BaseClipCapacity=20
	ChainDecayTimer=0.0f
	DelayBetweenChain=0.3f
	MaxChains=10
	BaseDamage=40
	ChainEmitter = ParticleSystem'GPS_FX.Effects.P_WP_ChainGun'
	ChainColor=(R=255, G=100, B=100)
}
