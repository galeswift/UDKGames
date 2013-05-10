class SeqAct_MoveTowards extends SequenceAction;

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

event Activated()
{
	local GAMoveToHelper MoveToHelper;

	MoveToHelper = GetWorldInfo().Spawn(class'GAMoveToHelper');
	MoveToHelper.Init(self);
	Super.Activated();
}

DefaultProperties
{
	bCallHandler=false
	ObjName="Move To"
	ObjCategory="Actor"
	MoveInitialSpeed=300.f
}
