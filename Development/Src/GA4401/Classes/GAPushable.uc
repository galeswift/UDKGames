/** 
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class GAPushable extends InterpActor
	placeable;

var() float AmountToPush;

/** Base cylinder component for collision */
var() editconst const CylinderComponent	CylinderComponent;

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
	local Pawn P;
	local bool bFoundPawn;
	bFoundPawn=false;

	ForEach TouchingActors(class'Pawn', P)
	{
		bFoundPawn=true;
		Touch(P, None, Location, Normal(Location-P.Location) );
	}

	if( !bFoundPawn )
	{
		SetDefaultCollision();
		ClearTimer( nameof(RecheckValidTouch) );
	}
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local vector targetVect;
	local vector toCube;
	local vector destVect;
	local vector hitLoc, traceNormal,extent;
	local Pawn P;

	// If touched by a player pawn, let him pick this up.
	P = Pawn(Other);
	if( P != None && ValidTouch(P) )
	{
		toCube = normal(Location - Other.Location);
	
		// Move along X
		if( abs(vect(1,0,0) dot toCube ) > abs(vect(0,1,0) dot toCube ) )
		{
			toCube.X = toCube.X > 0 ? 1 : -1;
			toCube.Y = 0;
		}
		else
		{
            toCube.X = 0;
			toCube.Y = toCube.Y > 0 ? 1 : -1;
		}

		targetVect = toCube * AmountToPush;
		targetVect.Z = 0;
		
		
		if( FastTrace(Location, Location + targetVect) )
		{  
			destVect = Location + targetVect;
			extent.X = CylinderComponent.CollisionRadius;
			extent.Y = CylinderComponent.CollisionRadius;
			extent.Z = CylinderComponent.CollisionHeight;
			Trace(hitLoc, traceNormal, destVect + vect(0,0,-10000), destVect,,extent );
			targetVect = Location + targetVect;
			targetVect.Z = hitLoc.Z;

			SetLocation( targetVect);
		}
		else
		{
			SetCollisionType(COLLIDE_BlockAll);
			SetTimer( 0.1, true, nameof(RecheckValidTouch) );
		}
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
		CollisionRadius=+168.000000
		CollisionHeight=+130.000000
		bAlwaysRenderIfSelected=true
	End Object
	CylinderComponent=CollisionCylinder
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)
	Physics=PHYS_Projectile
	bCollideWorld=false
	bAlwaysRelevant=true
	bCollideActors=true
	bBlockActors=true
	bMovable=true
	bStatic=false
	bNoDelete=false

	AmountToPush=256
}