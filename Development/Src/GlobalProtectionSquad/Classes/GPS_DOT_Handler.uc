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
var ParticleSystemComponent SpreadPSC;

var int NumSpreadTargets;

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
	local Actor NextTarget;
	local GPS_DOT_Handler DOTHandler;
	local GPS_GameCrowdAgent A;
	local Vector AOEVect;
	local int iTempNumSpreadTargets;

	if( HitsLeft > 0 )
	{
		HitsLeft--;

		// Do damage to this target
		DOTTarget.TakeDamage(WeaponOwner.BaseDamage, none, GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent.Bounds.Origin, vect(0,0,0), class'UTDamageType');
		if (WeaponOwner.bSpreadEachHit && !WeaponOwner.bAOE)
		{
			if (WeaponOwner.NumSpreadTargets > NumSpreadTargets)
			{
				NumSpreadTargets++;
				NextTarget = FindBestSpreadTarget();
				if (NextTarget != none)
				{
					DOTHandler = Spawn(class'GPS_DOT_Handler', DOTTarget,,GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin);
					DOTHandler.NumSpreadTargets = NumSpreadTargets;
					DOTHandler.Init( NextTarget, WeaponOwner );
					DOTHandler.SpawnDOTEffects(GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin);
					DOTHandler.SpawnSpreadEffects(GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent.Bounds.Origin, GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin);
				}
				else
				{				
					EndDOT();
				}
			}
			else
			{				
				EndDOT();
			}
		}

		if (WeaponOwner.bAOE)
		{
			if (WeaponOwner.bSpreadEachHit)
			{
				if (WeaponOwner.NumSpreadTargets > NumSpreadTargets)
				{
					iTempNumSpreadTargets = NumSpreadTargets + 1;
				}				
				else
				{				
					EndDOT();
				}
			}

			AOEVect.X = WeaponOwner.iAOERadius;
			AOEVect.Y = WeaponOwner.iAOERadius;
			AOEVect.Z = WeaponOwner.iAOERadius;
			foreach DynamicActors(class'GPS_GameCrowdAgent', A )
			{
				if( FastTrace( A.Location, GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent.Bounds.Origin, AOEVect ) &&
					A.Health > 0 && A != GPS_GameCrowdAgent(DOTTarget))
				{			
					A.TakeDamage(WeaponOwner.BaseDamage, none, A.SkeletalMeshComponent.Bounds.Origin, vect(0,0,0), class'UTDamageType');
					SpawnSpreadEffects(GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent.Bounds.Origin, A.SkeletalMeshComponent.Bounds.Origin);
					if (WeaponOwner.bSpreadEachHit)
					{				
						DOTHandler = Spawn(class'GPS_DOT_Handler', DOTTarget,,A.SkeletalMeshComponent.Bounds.Origin);
						DOTHandler.NumSpreadTargets = iTempNumSpreadTargets;
						DOTHandler.Init( A, WeaponOwner );
						DOTHandler.SpawnDOTEffects(A.SkeletalMeshComponent.Bounds.Origin);
					}
				}
			}
		}

		// Spawn the particle effect
		SpawnDOTEffects(GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent.Bounds.Origin);

		PrimeNextHit();	
	}
	else if (WeaponOwner.bSpreadWhenDone && WeaponOwner.NumSpreadTargets > NumSpreadTargets)
	{
		NumSpreadTargets++;
		NextTarget = FindBestSpreadTarget();
		if (NextTarget != none)
		{
			DOTHandler = Spawn(class'GPS_DOT_Handler', DOTTarget,,GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin);
			DOTHandler.NumSpreadTargets = NumSpreadTargets;
			DOTHandler.Init( NextTarget, WeaponOwner );
			DOTHandler.SpawnDOTEffects(GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin);
			DOTHandler.SpawnSpreadEffects(GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent.Bounds.Origin, GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin);
		}
		EndDOT();
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

function SpawnSpreadEffects( vector StartLocation, vector EndLocation )
{
	SpreadPSC = WorldInfo.MyEmitterPool.SpawnEmitter(WeaponOwner.SpreadEmitter,StartLocation);
	SpreadPSC.SetVectorParameter('LinkBeamEnd', EndLocation);
	SpreadPSC.SetColorParameter('BeamColor',WeaponOwner.DOTColor);

	SpreadPSC.ActivateSystem();
	WorldInfo.PlaySound(WeaponOwner.WeaponFireSnd[0],,,,StartLocation);

	BeamLight = spawn(class'UTLinkBeamLight');
	BeamLight.SetLocation((StartLocation + EndLocation) * 0.5f);
	BeamLight.BeamLight.SetLightProperties(, WeaponOwner.DOTColor);
	BeamLight.LifeSpan = 0.2f;
}

function Tick( float DeltaTime )
{
	local Actor NextTarget;
	local GPS_DOT_Handler DOTHandler;

	if ( GPS_GameCrowdAgent(DOTTarget).IsDead() )
	{
		if (WeaponOwner.bSpreadIfDead && WeaponOwner.NumSpreadTargets > NumSpreadTargets)
		{
			NumSpreadTargets++;
			NextTarget = FindBestSpreadTarget();
			if (NextTarget != none)
			{
				DOTHandler = Spawn(class'GPS_DOT_Handler', DOTTarget,,GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin);
				DOTHandler.NumSpreadTargets = NumSpreadTargets;
				DOTHandler.Init( NextTarget, WeaponOwner );
				DOTHandler.SpawnDOTEffects(GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin);
				DOTHandler.SpawnSpreadEffects(GPS_GameCrowdAgent(DOTTarget).SkeletalMeshComponent.Bounds.Origin, GPS_GameCrowdAgent(NextTarget).SkeletalMeshComponent.Bounds.Origin);
			}
		}
		EndDOT();
	}
}

function Actor FindBestSpreadTarget()
{
	local GPS_GameCrowdAgent A;
	local GPS_GameCrowdAgent BestTarget;
	local float BestScore;
	local float CurrentScore;

	BestScore = 999999;

	foreach DynamicActors(class'GPS_GameCrowdAgent', A )
	{
		CurrentScore = -1000.0 * (normal(A.Location - Location) dot Normal(Location + Velocity)) + VSize(A.Location - Location);
		
		// Find the best actor that's closest to us and visible
		if( CurrentScore < BestScore &&
			FastTrace( A.Location, Location, vect(10,10,10) ) &&
			A.Health > 0 &&
			A != GPS_GameCrowdAgent(DOTTarget))
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
