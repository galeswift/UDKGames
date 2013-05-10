class GPS_Handler_Mine extends Actor;

// How many times we can still damage
var int HitsLeft;

// The weapon that fired us
var GPS_Weap_GrenadeLauncher_Mine WeaponOwner;

// Save the effects so we can turn them off
var ParticleSystemComponent MinePSC;
var ParticleSystemComponent MineExplosionPSC;

// All actors we've hit
//var array<Actor> PrevHitList;

// Called from our weapon
function Init( vector HitLocation, GPS_Weap_GrenadeLauncher_Mine MineOwner )
{
	WeaponOwner = MineOwner;
	SetLocation(HitLocation);

	MinePSC = WorldInfo.MyEmitterPool.SpawnEmitter(WeaponOwner.MineEmitter, HitLocation + vect(0,0,20));
	
	MinePSC.SetScale(0.5f);
}

function EndMine()
{
	MinePSC.DeactivateSystem();
	Destroy();
}

function DoDamage()
{
	local array<Actor> CurrentTargets;
	local int i;
	local ImpactInfo CurrentImpactInfo;

	CurrentTargets = FindTargets();

	for ( i = 0; i < CurrentTargets.Length; i++ )
	{
		// Do damage to this target
		CurrentImpactInfo.HitActor = CurrentTargets[i];
		WeaponOwner.ProcessInstantHit(WeaponOwner.CurrentFireMode, CurrentImpactInfo);

		// Spawn the particle effect
		SpawnExplosionEffect();
	}

	EndMine();
}

function SpawnExplosionEffect()
{	
	MineExplosionPSC = WorldInfo.MyEmitterPool.SpawnEmitter(WeaponOwner.MineExplosionEmitter,Location);
	MineExplosionPSC.SetScale(1.5f);
	//MineExplosionPSC.SetColorParameter('Color',WeaponOwner.HitColor);
	WorldInfo.PlaySound(WeaponOwner.WeaponFireSnd[0],,,,Location);
}

function Tick( float DeltaTime )
{
	if ( ShouldTriggerMine() )
	{
		DoDamage();
	}
}

function array<Actor> FindTargets()
{
	local GPS_GameCrowdAgent A;
	local array<Actor> Result;

	foreach DynamicActors(class'GPS_GameCrowdAgent', A )
	{
		//`log("VSize(A.Location - Location): " $ VSize(A.Location - Location) $ " WeaponOwner.BaseDamageRadius: " $ WeaponOwner.BaseDamageRadius);
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

function bool ShouldTriggerMine()
{
	local GPS_GameCrowdAgent A;

	foreach DynamicActors(class'GPS_GameCrowdAgent', A )
	{
		//`log("VSize(A.Location - Location): " $ VSize(A.Location - Location) $ " WeaponOwner.BaseDamageRadius: " $ WeaponOwner.TriggerRadius);
		// Find the actors that are close to us, not already being hurt and visible
		if( //FastTrace( A.Location, Location, vect(10,10,10) ) &&
			A.Health > 0 &&
			VSize(A.Location - Location) < WeaponOwner.TriggerRadius)
		{			
			return true;
		}
	}

	return false;
}

DefaultProperties
{

}
