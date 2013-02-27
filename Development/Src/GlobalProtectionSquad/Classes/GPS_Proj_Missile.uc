class GPS_Proj_Missile extends GPS_Proj_Base;

var float SpiralForceMag;
var float InwardForceMag;
var float ForwardForceMag;
var float DesiredDistanceToAxis;
var float DesiredDistanceDecayRate;
var float InwardForceMagGrowthRate;

var float CurSpiralForceMag;
var float CurInwardForceMag;
var float CurForwardForceMag;

var float DT;

var vector AxisOrigin;
var vector AxisDir;

var vector Target;

var SoundCue IgniteSound;

var float IgniteTime;
var repnotify vector InitialAcceleration;


replication
{
	if ( bNetInitial && Role == ROLE_Authority )
		IgniteTime, InitialAcceleration, Target;
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
			FastTrace( A.Location, Location, vect(10,10,10) ) &&
			A.Health > 0 )
		{			
			BestScore = CurrentScore;
			BestTarget = A;
		}
	}

	if( BestTarget != none )
	{
		Target = BestTarget.SkeletalMeshComponent.Bounds.Origin;
	}
	else
	{
		Target = Location + Velocity * 10;
	}
}

simulated function ReplicatedEvent(name VarName)
{
	if ( VarName == 'InitialAcceleration' )
	{
		Acceleration = InitialAcceleration;
	}
}

function Init( Vector Direction )
{	
	super.Init( Direction );

	// Seed the acceleration/timer on a server
	ReplicatedEvent('InitialAcceleration');
}

simulated function SetIgniteTime(float BaseIgniteTime)
{
	IgniteTime = (FRand() * 0.2) + BaseIgniteTime;
	
	if( IgniteTime > 0.0f )
	{
		SetTimer(IgniteTime , false, 'Ignite');
	}
	else
	{
		Ignite();
	}
}


simulated function Ignite()
{
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PlaySound(IgniteSound, true);
	}

	SetCollision(true, true);
	
	GotoState('Homing');	
}

state Homing
{
	simulated function Timer()
	{
		FindBestTarget();

		// do normal guidance to target.
		Acceleration = 16.0 * AccelRate * Normal(Target - Location);
	}

	simulated function BeginState(name PreviousStateName)
	{
		Timer();
		SetTimer(0.1, true);
	}
}

defaultproperties
{
	SpiralForceMag=800.0
	InwardForceMag=25.0
	ForwardForceMag=15000.0
	DesiredDistanceToAxis=250.0
	DesiredDistanceDecayRate=500.0
	InwardForceMagGrowthRate=0.0
	DT=0.1
	MomentumTransfer=40000
	Damage=50
	DamageRadius=220.0
	MyDamageType=class'UTDmgType_CicadaRocket'
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=7.0
	RotationRate=(Roll=50000)
	DrawScale=0.5
	bCollideWorld=True
	bCollideActors=false
	bNetTemporary=False	
	IgniteSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_MissileIgnite'

	ExplosionLightClass=class'UTGame.UTCicadaRocketExplosionLight'
	ProjFlightTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketTrail'
	ProjExplosionTemplate=ParticleSystem'WP_RocketLauncher.Effects.P_WP_RocketLauncher_RocketExplosion'
	
	ExplosionSound=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Impact_Cue'
	bWaitForEffects=true
	IgniteTime=0.7
}