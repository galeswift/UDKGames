class GPS_Handler_Chain extends Actor;

// How many times we can still chain
var int ChainsLeft;

// The weapon that fired us
var GPS_Weap_Chain WeaponOwner;

// Our light that we are showing
var UTLinkBeamLight BeamLight;

// The last actor we hit
var ImpactInfo PrevImpact;

// All actors we've hit
var array<Actor> PrevHitList;

// Called from our weapon
function Init( ImpactInfo Impact, GPS_Weap_Chain ChainOwner )
{
	WeaponOwner = ChainOwner;
	PrevImpact = Impact;
	ChainsLeft = ChainOwner.MaxChains;
	
	if( ChainOwner.ChainDecayTimer > 0.0f )
	{
		SetTimer(ChainOwner.ChainDecayTimer,true,'DecayChainList');
	}

	PrimeNextChain();
}

function DecayChainList()
{
	PrevHitList.Remove(0,1);
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
			WeaponOwner.ProcessInstantHit(0, CurrentImpactInfo);

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

	if( WeaponOwner.bChainFromSky )
	{
		EndLocation = StartLocation;
		EndLocation.Z += 5000;
	}
	
	ChainPSC = WorldInfo.MyEmitterPool.SpawnEmitter(WeaponOwner.ChainEmitter,StartLocation);
	ChainPSC.SetVectorParameter('LinkBeamEnd', EndLocation);
	ChainPSC.SetColorParameter('BeamColor',WeaponOwner.ChainColor);

	ChainPSC.ActivateSystem();
	WorldInfo.PlaySound(WeaponOwner.WeaponFireSnd[0],,,,StartLocation);

	BeamLight = spawn(class'UTLinkBeamLight');
	BeamLight.SetLocation((StartLocation + EndLocation) * 0.5f);
	BeamLight.BeamLight.SetLightProperties(, WeaponOwner.ChainColor);
	BeamLight.LifeSpan = 0.2f;
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

}
