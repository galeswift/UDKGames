//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GB_PawnGrabber extends Actor
	placeable
	dependson(GBProj_TractorEnergy);

var ParticleSystemComponent GrabbedEmitter;
var Vehicle MyOwner;

replication
{
	if( bNetDirty )
		MyOwner;
}

simulated function SpawnEnergyAbsorbEffects()
{
	local GBProj_TractorEnergy P;
	local Vector Aim, AccelAdjustment, CrossVec;
	local vector TargetVect;
	local int i;
	local vector SpawnLocation;

	if( Role < Role_Authority )
	{
		return;
	}

	for( i=0 ; i< 5 ; i++ )
	{
		if (Role==ROLE_Authority)
		{
			SpawnLocation = Location;
			SpawnLocation = SpawnLocation + vect(1,1,1) * 150 * (FRand() * 2 - 1);
			P = Spawn(class'GBProj_TractorEnergy',,, SpawnLocation );

			if ( P != None )
			{
				TargetVect = normal( MyOwner.location - Location );
				P.Init( TargetVect );
			}
		}

		if (P!=none)
		{
			// make sure that a player still gets kill credit for the rockets even if he/she switches to the turret while firing
			if (P.InstigatorController == None)
			{
				P.InstigatorController = MyOwner.Controller;
			}

			// Set their initial velocity

			Aim = TargetVect;

			CrossVec = Vect(0,0,1) * ( FRand() > 0.5f ? 1 : -1);
			CrossVec *= -1;

			CrossVec = Normal(Aim Cross CrossVec);
			AccelAdjustment = 0.5 * CrossVec * MyOwner.AccelRate;

			P.Target = MyOwner.Location;
			P.TargetActor = MyOwner;

			P.DesiredDistanceToAxis = 64;
			P.bFinalTarget = true;

			CrossVec *= -1;
			P.ArmMissile(AccelAdjustment, 0.67 * (TargetVect + 0.5*CrossVec) * P.Speed );
		}
	}
}

simulated function Tick( float DeltaTime )
{
	super.Tick( DeltaTime );
	GrabbedEmitter.SetVectorParameter('LinkBeamEnd',MyOwner.Location);
}


DefaultProperties
{
	Begin Object class=ParticleSystemComponent Name=LinkEmitter
		Template = ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam'
		scale = 4.0
	End Object

	RemoteRole = ROLE_SimulatedProxy;
	bAlwaysRelevant = true;
	NetUpdateFrequency = 100.0f
	bUpdateSimulatedPosition = true

	Components.Add(LinkEmitter);
	GrabbedEmitter = LinkEmitter;
}