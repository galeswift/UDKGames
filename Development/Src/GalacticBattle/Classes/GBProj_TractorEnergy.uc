//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GBProj_TractorEnergy extends UTProj_CicadaRocket;

var Actor TargetActor;

replication
{
	if( bNetDirty )
		TargetActor;
}

simulated function vector GetTarget()
{
	return TargetActor.Location;
}


function ArmMissile(vector InitAccel, vector InitVelocity)
{
	local float Dist;

	Velocity = InitVelocity;
	InitialAcceleration = InitAccel;

	IgniteTime = (FRand() * 0.1) + 0.1f;

	// Seed the acceleration/timer on a server
	ReplicatedEvent('InitialAcceleration');
}


simulated function Ignite()
{
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PlaySound(IgniteSound, true);
		ProjEffects.SetTemplate(ProjIgnitedFlightTemplate);
	}

	SetCollision(true, true);
	GotoState('Homing');
}


state Homing
{
	simulated function Timer()
	{
		// do normal guidance to target.
		Acceleration = 16.0 * AccelRate * Normal(GetTarget() - Location);

		if ( (VSize(GetTarget() - Location) < 300) )
		{
			Explode(Location, vect(0,0,1));
		}
	}

	simulated function BeginState(name PreviousStateName)
	{
		Timer();
		SetTimer(0.1, true);
	}
}

DefaultProperties
{
	MomentumTransfer=0
	Damage=0
	DamageRadius=0

	AccelRate=600
	MaxSpeed=2000.0

	IgniteSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_MissileIgnite'

	DrawScale = 2.0f
	ExplosionLightClass=class'UTGame.UTCicadaRocketExplosionLight'
	ProjFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'
	ProjIgnitedFlightTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'
	ProjExplosionTemplate=none
	ExplosionSound=none
	bWaitForEffects=false
}