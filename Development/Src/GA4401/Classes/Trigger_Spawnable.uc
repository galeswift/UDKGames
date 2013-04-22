/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class Trigger_Spawnable extends Trigger_Dynamic;

/**
 * Dynamic Trigger
 * Can be attached and moved in the level. More expensive than (static) triggers, use only when necessary.
 *
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
 
 simulated event Tick(float deltaTime)
 {
	Super.Tick(deltaTime);
	
	if( Base == none )
	{
		Destroy();
	}
 }

defaultproperties
{
	bNoDelete=false
	
	Begin Object NAME=CollisionCylinder 
		CollisionRadius=+90.0
		CollisionHeight=+100.0
		
	End Object
}
