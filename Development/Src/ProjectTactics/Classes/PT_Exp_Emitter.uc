class PT_Exp_Emitter extends Emitter;

/** Who we are flying to */
var Actor MyTarget;

/** How fast we fly towards the target */
var float FlySpeed;

simulated function SetTarget(Actor Target )
{
	MyTarget = Target;
}

event Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );
	if( MyTarget != none )
	{
		Velocity = normal(MyTarget.Location  - Location) * FlySpeed/VSize(MyTarget.Location  - Location);
	}
	//Velocity += Acceleration * DeltaTime;
	Velocity = ClampLength( Velocity, FlySpeed);
	SetLocation(Location + Velocity * DeltaTime);
	
	if( VSizeSq(MyTarget.Location - Location) < 100 * 100 )
	{
		Destroy();
	}
}

event Destroyed()
{
	Super.Destroyed();
}

DefaultProperties
{
	bDestroyOnSystemFinish=true
	bNoDelete=false
	FlySpeed=500000
	bHardAttach=false
	DrawScale=6
}
