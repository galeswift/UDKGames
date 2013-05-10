class GAEntity extends InterpActor
	placeable;

/** Base cylinder component for collision */
var() editconst const CylinderComponent	CylinderComponent;

var() int EntityTeam;

simulated event PostBeginPlay()
{
	SetDefaultCollision();
	Super.PostBeginPlay();
}

/*
	Validate touch (if valid return true to let other pick me up and trigger event).
*/
function bool ValidTouch( Pawn Other )
{
	// make sure its a live player
	if (Other == None )
	{
		return false;
	}
	else if (Other.Controller == None)
	{
		// re-check later in case this Pawn is in the middle of spawning, exiting a vehicle, etc
		// and will have a Controller shortly
		SetTimer( 0.2, true, nameof(RecheckValidTouch) );
		return false;
	}
	// make sure not touching through wall
	else if ( !FastTrace(Other.Location, Location) )
	{
		SetTimer( 0.5, true, nameof(RecheckValidTouch) );
		return false;
	}

	return true;
}

/**
Pickup was touched through a wall.  Check to see if touching pawn is no longer obstructed
*/
function RecheckValidTouch()
{
	CheckTouching();
}

// Make sure no pawn already touching (while touch was disabled in sleep).
function CheckTouching()
{
	local GAEntity P;
	local bool bFoundPawn;
	bFoundPawn=false;

	ForEach TouchingActors(class'GAEntity', P)
	{
		if( P.EntityTeam != EntityTeam )
		{
			bFoundPawn=true;
			Touch(P, None, Location, Normal(Location-P.Location) );
		}
	}

	if( !bFoundPawn )
	{
		SetDefaultCollision();
		ClearTimer( nameof(RecheckValidTouch) );
	}
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	if( GAEntity(Other) == none || GAEntity(Other).EntityTeam != EntityTeam )
	{
		SetCollisionType(COLLIDE_BlockAll);
		SetTimer( 0.1, true, nameof(RecheckValidTouch) );
	}
}


function SetDefaultCollision()
{
	SetCollisionType(COLLIDE_TouchAll);
}

defaultproperties
{
	Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollideActors=true
		CollisionRadius=+40.000000
		CollisionHeight=+60.000000
		bAlwaysRenderIfSelected=true
	End Object
	CylinderComponent=CollisionCylinder
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
	bCollideWorld=true
	bAlwaysRelevant=true
	bCollideActors=true
	bBlockActors=true
	bMovable=true
	bStatic=false
	bNoDelete=false
	Physics=PHYS_Projectile
}