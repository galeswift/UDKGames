class GPS_Proj_Morter extends GPS_Proj_Base;

var int ShotsFired;
var int ShotCapacity;
var vector RealStartLoc;

/** How spread apart the shells should be */
var float       BaseSpreadDist;

/**
 * Give a little bounce
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	bBlockedByInstigator = true;

	// this is the location where the projectile is spawned
	RealStartLoc = Location;
	SpawnTurret(HitNormal);
	ImpactedActor = Wall;
	SetPhysics(PHYS_None);
}

simulated function SpawnTurret(vector HitNormal)
{
	// Turret should spawn a few feet from the wall
	//Location = Location HitNormal;
	
	SetTimer(5.0, false, 'ShootTurret');
	
}

simulated function ShootTurret()
{	
   	local vector AimDir, SpawnLocation;
	local Projectile Proj;

	if (Role == ROLE_Authority)
	{
		if (ShotsFired > ShotCapacity)
		{
			ClearTimer('ShootTurret');
			Destroy();
		}
		else
		{
			// aim down but from a random x,y close to the point
			AimDir = vect(0, 0, -1);
			SpawnLocation = GetSpawnLocation(RealStartLoc);
			//AimDir = vect(0,0,-1);
			// special center shard - Disabled for now.
			Proj = Spawn(class'GPS_Proj_Rocket',,, SpawnLocation);
			if (Proj != None)
			{
				Proj.Init(AimDir);
			}
			ShotsFired++;
			SetTimer(0.25, false, 'ShootTurret');
		}
	}
}

simulated function vector GetSpawnLocation(vector StartLocation)
{
	local int xDir,yDir,zDir;
	local float Rand;
	local float Mag;
	local vector result;

	result = vect(0,0,0);

	if (Role == ROLE_Authority)
	{
		zDir = 1000;

		Rand = FRand();

		if( Rand < 0.333f )
		{
			xDir = -1;
		}
		else if( Rand < 0.666f )
		{
			xDir = 0;
		}
		else
		{
			xDir = 1;
		}
		
		Rand = FRand();

		if( Rand < 0.333f )
		{
			yDir = -1;
		}
		else if( Rand < 0.666f )
		{
			yDir = 0;
		}
		else
		{
			yDir = 1;
		}
		
		Mag = ((abs(xDir) + abs(yDir)) > 1 )? 0.7 : 1.0;
		result = StartLocation + (0.1+ 20*FRand())*Mag*xDir*BaseSpreadDist*vect(1,0,0) + (0.1 + 20*FRand())*Mag*yDir*BaseSpreadDist*vect(0,1,0) + zDir*vect(0,0,1);
	}
	return result;
}

DefaultProperties
{
	ShotCapacity = 20;

	BaseSpreadDist = 20;

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
