class GB_Weap_Binding extends UTWeap_PhysicsGun;

var array<GB_LocalGravityActor> LocalGravityActors;

function GB_LocalGravityActor GetLocalGravityActor( PrimitiveComponent Component )
{
	local int i;
	local GB_LocalGravityActor      Result;

	// See if this actor is already being traced
	for(i=0 ; i<LocalGravityActors.Length ; i++ )
	{
		if( LocalGravityActors[i].GravityComponent == Component )
		{
			Result = LocalGravityActors[i];
		}
	}

	return Result;
}

function RemoveLocalGravityActor( PrimitiveComponent Component )
{
	local int i;
	
	// See if this actor is already being traced
	for(i=0 ; i<LocalGravityActors.Length ; i++ )
	{
		if( LocalGravityActors[i].GravityComponent == Component )
		{
			LocalGravityActors[i].Destroy();
			LocalGravityActors.Remove(i,1);
			break;
		}
	}

}

function AssignLocalGravityActor( PrimitiveComponent InComponent )
{	
	local GB_LocalGravityActor NewGravActor;

	if( GetLocalGravityActor( InComponent ) == none )
	{
		// Make one now
		NewGravActor = spawn(class'GB_LocalGravityActor',self,,InComponent.Owner.Location);
		NewGravActor.SetGravityComponent(InComponent);
		LocalGravityActors[LocalGravityActors.Length] = NewGravActor;
	}
}

simulated function StartFire(byte FireModeNum)
{
	local vector					StartShot, EndShot;
	local vector					HitLocation, HitNormal, Extent;
	local actor						HitActor;
	local TraceHitInfo				HitInfo;
	local Rotator					Aim;
	local PrimitiveComponent CurrentComponent;
	local GB_LocalGravityActor      CurrentGravActor;
	local int i;
	if ( Role < ROLE_Authority )
		return;

	// Do ray check and grab actor
	StartShot	= Instigator.GetWeaponStartTraceLocation();
	Aim			= GetAdjustedAim( StartShot );
	EndShot		= StartShot + (10000.0 * Vector(Aim));
	Extent		= vect(0,0,0);
	HitActor	= Trace(HitLocation, HitNormal, EndShot, StartShot, True, Extent, HitInfo, TRACEFLAG_Bullet);

	// POKE
	if(FireModeNum == 0)
	{
		Instigator.SetPhysics(PHYS_Spider);
		if( HitActor != None &&
			HitActor != WorldInfo &&
			HitInfo.HitComponent != None )
		{
			HitInfo.HitComponent.BodyInstance.CustomGravityFactor = 0.0f;
			CurrentComponent = HitInfo.HitComponent;

			if( CurrentComponent != none )
			{
				AssignLocalGravityActor(CurrentComponent);
				CurrentGravActor = GetLocalGravityActor(CurrentComponent);
				CurrentGravActor.Select( !CurrentGravActor.IsSelected() );
			}
		}	
	}
	// Set binding
	else
	{
		// Do another trace here
		StartShot = CurrentComponent.Owner.Location;
		EndShot = HitLocation;

		// if it's not a trigger or a volume, use it!
		if ( HitActor != CurrentComponent.Owner &&  (HitActor.bBlockActors || HitActor.bWorldGeometry) && (Volume(HitActor) == None && Trigger(HitActor)==None))
		{
			for( i=0 ; i<LocalGravityActors.Length ; i++ )
			{
				if( LocalGravityActors[i].IsSelected() )
				{
					LocalGravityActors[i].SetLocalGravityVec(-HitNormal);
					LocalGravityActors[i].SetActive(true);
					LocalGravityActors[i].Select(false);
				}
			}
		}
	}
	Super.StartFire( FireModeNum );
}

defaultproperties
{
	HoldDistanceMin=0.0
	HoldDistanceMax=7500.0
	WeaponImpulse=0.0
	ThrowImpulse=100000.0

	// Weapon SkeletalMesh
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
	End Object

	// Weapon SkeletalMesh
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object

	AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_3P'
	End Object
	WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'
	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

	MaxDesireability=0.65
	AIRating=0.65
	CurrentRating=0.65
	bSplashJump=false
	bRecommendSplashDamage=false
	bSniping=true

	FireOffset=(X=20,Y=5)
	PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)


	FireCameraAnim(1)=CameraAnim'Camera_FX.ShockRifle.C_WP_ShockRifle_Alt_Fire_Shake'
	
	MuzzleFlashSocket=MF
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'
	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	LockerRotation=(Pitch=32768,Roll=16384)

	IconCoordinates=(U=728,V=382,UL=162,VL=45)

	WeaponColor=(R=160,G=0,B=255,A=255)

	InventoryGroup=4
	GroupWeight=0.5

	IconX=400
	IconY=129
	IconWidth=22
	IconHeight=48
}