class GPS_Chain_Handler extends Actor;

var int ChainsLeft;
var GPS_Weap_Chain WeaponOwner;
var ParticleSystem ChainEmitter;
var ImpactInfo PrevImpact;
var array<Actor> PrevHitList;

// Called from our weapon
function Init( ImpactInfo Impact, GPS_Weap_Chain ChainOwner )
{
	WeaponOwner = ChainOwner;
	PrevImpact = Impact;
	ChainsLeft = ChainOwner.MaxChains;

	PrimeNextChain();
}

function PrimeNextChain()
{
	if( WeaponOwner.DelayBetweenChain > 0.0f )
	{
		SetTimer( WeaponOwner.DelayBetweenChain, false, 'DoNextChain');
	}
	else
	{
		DoNextChain();
	}
}

function EndChain()
{
	ClearTimer('DoNextChain');
	Destroy();
}

function DoNextChain()
{
	local Actor NextTarget;
	local ImpactInfo CurrentImpactInfo;
	if( ChainsLeft > 0 )
	{
		ChainsLeft--;

		PrevHitList[PrevHitList.Length] = PrevImpact.HitActor;

		NextTarget = FindBestChainTarget();

		if( NextTarget != none )
		{
			CurrentImpactInfo.HitActor = NextTarget;

			// Do damage to this target
			WeaponOwner.DoInstantHitBehavior(0, CurrentImpactInfo);

			// Spawn the particle effect
			SpawnChainEffects(GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin, GPS_GameCrowdAgent(PrevImpact.HitActor).SkeletalMeshComponent.Bounds.Origin);

			// Save this info for next time
			PrevImpact = CurrentImpactInfo;

			PrimeNextChain();	
		}
		else
		{
			EndChain();
		}
	}
	else
	{
		EndChain();
	}
}

function SpawnChainEffects( vector StartLocation, vector EndLocation )
{
	local ParticleSystemComponent ChainPSC;

	ChainPSC = WorldInfo.MyEmitterPool.SpawnEmitter(ChainEmitter,StartLocation);
	ChainPSC.SetVectorParameter('LinkBeamEnd', EndLocation);
	ChainPSC.ActivateSystem();
	WorldInfo.PlaySound(WeaponOwner.WeaponFireSnd[0],,,,StartLocation);
}

function Actor FindBestChainTarget()
{
	local GPS_GameCrowdAgent A;
	local GPS_GameCrowdAgent BestTarget;
	local float BestScore;
	local float CurrentScore;

	BestScore = 999999;

	foreach DynamicActors(class'GPS_GameCrowdAgent', A )
	{
		CurrentScore = -1000.0 * (normal(A.Location - Location) dot Normal(Location + Velocity)) + VSize(A.Location - Location);
		
		// Find the best actor that's closest to us, visible, and we haven't done before
		if( PrevHitList.Find(A) == INDEX_NONE &&
			CurrentScore < BestScore &&
			FastTrace( A.Location, Location, vect(10,10,10) ) &&
			A.Health > 0 )
		{			
			BestScore = CurrentScore;
			BestTarget = A;
		}
	}

	return BestTarget;
}

DefaultProperties
{
	ChainEmitter = ParticleSystem'GPS_FX.Effects.P_WP_ChainGun'
}
