class GPS_Proj_GrenadeBurst extends GPS_Proj_Grenade;

/** How spread apart the grenades should be */
var float SpreadDist;

/**
 * Set the initial velocity and cook time
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0+FRand()*0.5,false);                  //Grenade begins unarmed
	RandSpin(100000);
}

function Init(vector Direction)
{
	super.Init(Direction);

	SetRotation(Rotator(Direction));

	Velocity = Speed * Direction;
	TossZ = TossZ + (FRand() * TossZ / 2.0) - (TossZ / 4.0);
	Velocity.Z += TossZ;
	Acceleration = AccelRate * Normal(Velocity);
}

/**
 * Explode
 */
simulated function Timer()
{
	Explode(Location, vect(0,0,1));
	GrenadeBurst();
}

/**
 * Give a little bounce
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	bBlockedByInstigator = true;

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PlaySound(ImpactSound, true);
	}

	// check to make sure we didn't hit a pawn

	if ( Pawn(Wall) == none )
	{
		Velocity = 0.75*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
		Speed = VSize(Velocity);

		if (Velocity.Z > 400)
		{
			Velocity.Z = 0.5 * (400 + Velocity.Z);
		}
		// If we hit a pawn or we are moving too slowly, explod

		if ( Speed < 20 || Pawn(Wall) != none )
		{
			ImpactedActor = Wall;
			SetPhysics(PHYS_None);
		}
	}
	else if ( Wall != Instigator ) 	// Hit a different pawn, just explode
	{
		Explode(Location, HitNormal);
	}
}

/**
 * When a grenade enters the water, kill effects/velocity and let it sink
 */
simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( WaterVolume(NewVolume) != none )
	{
		Velocity *= 0.25;
	}

	Super.PhysicsVolumeChange(NewVolume);
}

simulated function GrenadeBurst()
{
	local int i,j;
   	local vector RealStartLoc, AimDir, XDir, YDir;
	local Projectile Proj;
	local class<Projectile> ShardProjectileClass;
	local float Mag;

	if (Role == ROLE_Authority)
	{
		// this is the location where the projectile is spawned
		RealStartLoc = Location;
		// get fire aim direction
		//GetAxes(BurstDirection, AimDir, YDir, ZDir);
		AimDir = vect(0, 0, -1.5);
		XDir = vect(0, 4, 0);
		YDir = vect(4, 0, 0);

		// special center shard - Disabled for now.
		Proj = Spawn(class'GPS_Proj_Grenade_Impact',,, RealStartLoc);
		if (Proj != None)
		{
			Proj.Init(AimDir);
		}

		// one shard in each of 9 zones (except center)
		ShardProjectileClass = class'GPS_Proj_Grenade_Impact';
		for ( i=-1; i<2; i++)
		{
			for ( j=-1; j<2; j++ )
			{
				if ( (i != 0) || (j != 0) )
				{
					Mag = (abs(i)+abs(j) > 1) ? 0.7 : 1.0;
					Proj = Spawn(ShardProjectileClass,,, RealStartLoc);
					if (Proj != None)
					{
						Proj.Init(AimDir + (0.3 + 0.7*FRand())*Mag*i*SpreadDist*XDir + (0.3 + 0.7*FRand())*Mag*j*SpreadDist*YDir );
					}
				}
			}
	    }
	}
}


defaultproperties
{
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

	SpreadDist = 0.1f
}
