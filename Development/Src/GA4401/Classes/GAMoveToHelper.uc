class GAMoveToHelper extends Actor;

// We will lock onto this actor
var() Actor TargetActor;

// If we don't have an actor specified, we will move towards this location
var() vector TargetLocation;

// We will set our target destination to be offset from this value
var() vector TargetOffset;

// If true, we will offset the target location based on the target's facing.  Only valid if we have a facing actor
var() bool bOffsetUsesTargetFacing;

// Initial speed applied to the target actor
var() float MoveInitialSpeed;

// We will cap this actor's move speed for this value
var() float MoveMaxSpeed;

// How long to wait until we start moving
var() float MoveDelay;

// Acceleration applied to the velocity of the actor
var() float MoveAcceleration;

// Modifiers to apply to the target
var() editinline GAMovementModifier MovementModifier;

var actor ActorThatIsMoving;
function Init(SeqAct_MoveTowards Action)
{
	TargetActor = Action.TargetActor;
	TargetLocation = Action.TargetLocation;
	TargetOffset = Action.TargetOffset;
	bOffsetUsesTargetFacing = Action.bOffsetUsesTargetFacing;
	MoveInitialSpeed = Action.MoveInitialSpeed;
	MoveMaxSpeed = Action.MoveMaxSpeed;
	MoveDelay = Action.MoveDelay;
	MoveAcceleration = Action.MoveAcceleration;

	ActorThatIsMoving = Actor(Action.Targets[0]);
	ActorThatIsMoving.SetPhysics(PHYS_Projectile);

	if( ActorThatIsMoving.Owner != none &&
		ActorThatIsMoving.Owner.IsA('GAMoveToHelper') )
	{
		ActorThatIsMoving.Owner.Destroy();
	}
	
	ActorThatIsMoving.SetOwner(self);

	if( TargetActor != none )
	{
		TargetLocation = TargetActor.Location;
	}
	ActorThatIsMoving.Velocity = normal(TargetLocation - ActorThatIsMoving.Location) * MoveInitialSpeed;
}

simulated function Tick(float DeltaTime)
{
	local vector TargetVelocity;
	Super.Tick(deltaTime);

	if( ActorThatIsMoving == none )
	{
		Destroy();
	}

	MoveDelay -= DeltaTime;

	if( MoveDelay > 0 )
	{
		return;
	}

	if( TargetActor != none )
	{
		TargetLocation = TargetActor.Location;
	}
	MoveInitialSpeed += MoveAcceleration * DeltaTime;

	if( MoveInitialSpeed > MoveMaxSpeed )
	{
		MoveMaxSpeed = MoveMaxSpeed;
	}

	TargetLocation += TargetOffset;

	if( bOffsetUsesTargetFacing )
	{
		TargetOffset = TargetOffset >> ActorThatIsMoving.Rotation;
	}

	TargetVelocity = normal(TargetLocation - ActorThatIsMoving.Location) * MoveInitialSpeed;
	ActorThatIsMoving.Velocity = TargetVelocity;

	if( ActorThatIsMoving.Physics == PHYS_RigidBody && ActorThatIsMoving.CollisionComponent != None )
	{
		ActorThatIsMoving.CollisionComponent.SetRBLinearVelocity( TargetVelocity );
	}
}

DefaultProperties
{
}
