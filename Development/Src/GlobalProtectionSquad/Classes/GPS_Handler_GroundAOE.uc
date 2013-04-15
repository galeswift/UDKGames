class GPS_Handler_GroundAOE extends Actor;

// How many times we can still damage
var int HitsLeft;

// The weapon that fired us
var GPS_Weap_GrenadeLauncher_GroundAOE WeaponOwner;

// Save the effects so we can turn them off
var ParticleSystemComponent GroundAOEPSC;
var ParticleSystemComponent GroundAOEHITPSC;

// All actors we've hit
//var array<Actor> PrevHitList;

// Called from our weapon
function Init( vector HitLocation, GPS_Weap_GrenadeLauncher_GroundAOE GroundAOEOwner )
{
	WeaponOwner = GroundAOEOwner;
	HitsLeft = GroundAOEOwner.MaxHits;
	SetLocation(HitLocation);

	GroundAOEPSC = WorldInfo.MyEmitterPool.SpawnEmitter(WeaponOwner.GroundAOEEmitter, HitLocation + vect(0,0,20));
	
	//GroundAOEPSC.SetScale(2.8f);

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

function EndGroundAOE()
{
	ClearTimer('DoNextDamage');
	GroundAOEPSC.DeactivateSystem();
	Destroy();
}

function DoNextDamage()
{
	local array<Actor> CurrentTargets;
	local int i;

	if( HitsLeft > 0 )
	{
		CurrentTargets = FindTargets();

		for ( i = 0; i < CurrentTargets.Length; i++ )
		{
			// Do damage to this target
			CurrentTargets[i].TakeDamage(WeaponOwner.BaseDamage, none, GPS_GameCrowdAgent(CurrentTargets[i]).SkeletalMeshComponent.Bounds.Origin, vect(0,0,0), class'UTDamageType');

			// Spawn the particle effect
			SpawnHitEffects(CurrentTargets[i], GPS_GameCrowdAgent(CurrentTargets[i]).SkeletalMeshComponent.Bounds.Origin);
		}

		PrimeNextHit();	

		HitsLeft--;
	}
	else
	{
		EndGroundAOE();
	}
}

function SpawnHitEffects( Actor Target, vector HitLocation )
{	
	GroundAOEHITPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(WeaponOwner.GroundAOEHitEmitter,GPS_GameCrowdAgent(Target).SkeletalMeshComponent, 'Center', true);
	GroundAOEHITPSC.SetScale(0.05f);
	GroundAOEHITPSC.SetColorParameter('Color',WeaponOwner.HitColor);
	WorldInfo.PlaySound(WeaponOwner.WeaponFireSnd[0],,,,HitLocation);
}

function array<Actor> FindTargets()
{
	local GPS_GameCrowdAgent A;
	local array<Actor> Result;

	foreach DynamicActors(class'GPS_GameCrowdAgent', A )
	{
		`log("VSize(A.Location - Location): " $ VSize(A.Location - Location) $ " WeaponOwner.BaseDamageRadius: " $ WeaponOwner.BaseDamageRadius);
		// Find the actors that are close to us, not already being hurt and visible
		if( //FastTrace( A.Location, Location, vect(10,10,10) ) &&
			A.Health > 0 &&
			VSize(A.Location - Location) < WeaponOwner.BaseDamageRadius)
		{			
			Result[Result.Length] = A;
		}
	}

	return Result;
}

DefaultProperties
{

}
