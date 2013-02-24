class GPS_Proj_Turret_Hack extends GPS_Proj_Base;

var int ShotsFired;
var int ShotCapacity;
var vector RealStartLoc;

var vector Target;

/**
 * Give a little bounce
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	bBlockedByInstigator = true;

	// check to make sure we didn't hit a pawn
	if ( Pawn(Wall) == none )
	{
		// this is the location where the projectile is spawned
		RealStartLoc = Location;
		SpawnTurret(HitNormal);
		ImpactedActor = Wall;
		SetPhysics(PHYS_None);
	
		//SetTimer(1.5, false, 'ShootTurret');
	}
}

simulated function SpawnTurret(vector HitNormal)
{
	// Turret should spawn a few feet from the wall
	//Location = Location HitNormal;
	
	SetTimer(0.5, false, 'ShootTurret');
	//ShootTurret();
	
}

simulated function ShootTurret()
{	
   	local vector AimDir;
	local Projectile Proj;

	if (Role == ROLE_Authority)
	{
		// get fire aim direction
		FindBestTarget();
		AimDir = Normal(Target - RealStartLoc);
		//`log("AimDir: " $ AimDir);

		// special center shard - Disabled for now.
		Proj = Spawn(class'GPS_Proj_Grenade_Impact',,, RealStartLoc);
		if (Proj != None)
		{
			Proj.Init(AimDir);
		}
	}

	if (ShotsFired > ShotCapacity)
	{
		ClearTimer('ShootTurret');
		Destroy();
	}
	else
	{
		ShotsFired++;
		SetTimer(0.5, false, 'ShootTurret');
	}
}

function FindBestTarget()
{
	local GPS_GameCrowdAgent A;
	local GPS_GameCrowdAgent BestTarget;
	local float BestScore;
	local float CurrentScore;

	BestScore = 999999;

	foreach DynamicActors(class'GPS_GameCrowdAgent', A )
	{
		CurrentScore = -1000.0 * (normal(A.Location - Location) dot Normal(Location + Velocity)) + VSize(A.Location - Location);

		// Find the best actor that's closest to us, and visible
		if( CurrentScore < BestScore &&
			FastTrace( A.Location, Location ) &&
			A.Health > 0 )
		{			
			BestScore = CurrentScore;
			BestTarget = A;
		}
	}

	if( BestTarget != none )
	{
		Target = BestTarget.Location;
	}
	else
	{
		Target = Location + Velocity * 10;
	}
}


DefaultProperties
{
	ShotCapacity = 20;

	ProjFlightTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_Smoke_Trail'

	ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'

	MomentumTransfer=50000
	MyDamageType=class'UTDmgType_Grenade'
	LifeSpan=0.0
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	ExplosionDecal=MaterialInstanceTimeVarying'WP_RocketLauncher.Decals.MITV_WP_RocketLauncher_Impact_Decal01'
	DecalWidth=128.0
	DecalHeight=128.0
	bCollideWorld=true
	bBounce=true
	TossZ=+245.0
	Physics=PHYS_Falling
	CheckRadius=36.0

	ImpactSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_GrenadeFloor_Cue'

	bNetTemporary=False
	bWaitForEffects=false

	CustomGravityScaling=0.5

	bRotationFollowsVelocity=false
}
