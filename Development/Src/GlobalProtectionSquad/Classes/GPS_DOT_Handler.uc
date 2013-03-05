class GPS_DOT_Handler extends Actor;

// How many times we can still damage
var int HitsLeft;

// The weapon that fired us
var GPS_Weap_DOT WeaponOwner;

// Our light that we are showing
var UTLinkBeamLight BeamLight;

// The actor we are DOTing
var Actor DOTTarget;

// Save the effects so we can move them with the target
var ParticleSystemComponent DOTPSC;
var ParticleSystemComponent DOTHITPSC;


// Called from our weapon
function Init( Actor DOTActor, GPS_Weap_DOT DOTOwner )
{
	WeaponOwner = DOTOwner;
	DOTTarget = DOTActor;
	HitsLeft = DOTOwner.MaxHits;

	DOTPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(WeaponOwner.DOTEmitter,GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent, 'Center', true);
	DOTPSC.SetScale(0.2f);

	PrimeNextHit();
}

function PrimeNextHit()
{
	if( WeaponOwner.DelayBetweenDamage > 0.0f )
	{
		SetTimer( WeaponOwner.DelayBetweenDamage, false, 'DoNextDamage');
	}
	else
	{
		DoNextDamage();
	}
}

function EndDOT()
{
	ClearTimer('DoNextDamage');
	DOTPSC.DeactivateSystem();
	Destroy();
}

function DoNextDamage()
{
	if( HitsLeft > 0 )
	{
		HitsLeft--;

		// Do damage to this target
		DOTTarget.TakeDamage(WeaponOwner.BaseDamage, none, GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent.Bounds.Origin, vect(0,0,0), class'UTDamageType');

		// Spawn the particle effect
		SpawnDOTEffects(GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent.Bounds.Origin);

		PrimeNextHit();	
	}
	else
	{
		EndDOT();
	}
}

function SpawnDOTEffects( vector HitLocation )
{	
	DOTHITPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(WeaponOwner.DOTHitEmitter,GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent, 'Center', true);
	DOTHITPSC.SetScale(0.05f);
	WorldInfo.PlaySound(WeaponOwner.WeaponFireSnd[0],,,,HitLocation);
}

function Tick( float DeltaTime )
{
	if ( GPS_GameCrowdAgent(DOTTarget).IsDead() )
	{
		EndDOT();
	}
}

DefaultProperties
{

}
