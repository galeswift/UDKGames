class GAProjectileGrenade extends GAProjectile;

/**
 * Set the initial velocity and cook time
 */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function Init(vector Direction)
{
	if( ExplosionTimer > 0.0 )
	{
		SetTimer(ExplosionTimer,false);                  //Grenade begins unarmed
	}
	else
	{
		ClearTimer();
	}

	RandSpin(SpinRate);
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
		Velocity = BounceAmount*(( Velocity dot HitNormal ) * HitNormal * -2.0 + Velocity);   // Reflect off Wall w/damping
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

	TriggerEventClass(class'SeqEvent_HitWall', self);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
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


defaultproperties
{
	ProjFlightTemplate=none
	ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	ExplosionLightClass=class'UTGame.UTRocketExplosionLight'

	speed=700
	MaxSpeed=1000.0
	Damage=100.0
	DamageRadius=200
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
	bUpdateSimulatedPosition=true
	CustomGravityScaling=0.5
	BounceAmount=.7
	SpinRate = 100000
	ExplosionTimer = 2.5
}
