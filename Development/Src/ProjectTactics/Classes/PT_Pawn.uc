class PT_Pawn extends UDKPawn;

/** The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

/* GetPawnViewLocation()
Called by PlayerController to determine camera position in first person view.  Returns
the location at which to place the camera
*/
simulated function Vector GetPawnViewLocation()
{
	// We use this location to determine where we shoot from.
	return Mesh.Bounds.Origin + vector(Rotation) * GetCollisionRadius() * 1.1 + vect(0,0,-0.9) * GetCollisionHeight();
}

DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
		InvisibleUpdateTime=1
		MinTimeBetweenFullUpdates=.2
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment
	
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
		bCauseActorAnimEnd=true
	End Object

	// Weapon SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=PawnMesh
		SkeletalMesh=SkeletalMesh'WP_LinkGun.Mesh.SK_WP_LinkGun_3P'
		AnimSets(0)=AnimSet'WP_LinkGun.Anims.K_WP_LinkGun_1P_Base'
		Animations=MeshSequenceA
		Scale=5.0
		LightEnvironment=MyLightEnvironment
		Rotation=(Yaw=-16384)
	End Object
	Mesh=PawnMesh
	Components.Add(PawnMesh)

	Begin Object Name=CollisionCylinder
		CollisionRadius=+00100.000000
		CollisionHeight=+0030.000000
		Translation=(X=150.0)
	End Object

	// Flags
	bCanFly=true

	InventoryManagerClass=class'PT_InventoryManager'

	// Locomotion
	WalkingPhysics=PHYS_Flying
	LandMovementState=PlayerFlying
	AccelRate=+8192.000000
}
