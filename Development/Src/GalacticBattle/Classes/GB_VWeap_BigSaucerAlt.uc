//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GB_VWeap_BigSaucerAlt extends UTVehicleWeapon;

var()				float			WeaponImpulse;
var()				float			HoldDistanceMin;
var()				float			HoldDistanceMax;
var()				float			ThrowImpulse;
var()				float			ChangeHoldDistanceIncrement;

var					RB_Handle		PhysicsGrabber;
var					float			HoldDistance;
var					Quat			HoldOrientation;


simulated function PostBeginPlay()
{
	Super.PostbeginPlay();

	if ( WorldInfo.IsConsoleBuild() )
	{
		ChangeVisibility(false);
	}
}

/**
 * This function is called from the pawn when the visibility of the weapon changes
 */
simulated function ChangeVisibility(bool bIsVisible)
{
	if ( WorldInfo.IsConsoleBuild() )
	{
		bIsVisible = false;
	}
	Super.ChangeVisibility(bIsVisible);
}

simulated function StartFire(byte FireModeNum)
{
	local vector					StartShot, EndShot, PokeDir;
	local vector					HitLocation, HitNormal, Extent;
	local actor						HitActor;
	local float						HitDistance;
	local Quat						PawnQuat, InvPawnQuat, ActorQuat;
	local TraceHitInfo				HitInfo;
	local SkeletalMeshComponent		SkelComp;
	local Rotator					Aim;
	local PhysAnimTestActor			PATActor;

	if ( Role < ROLE_Authority )
		return;

	// Do ray check and grab actor
	StartShot	= Instigator.GetWeaponStartTraceLocation();
	Aim			= GetAdjustedAim( StartShot );
	EndShot		= StartShot + (10000.0 * Vector(Aim));
	Extent		= vect(0,0,0);
	HitActor	= Trace(HitLocation, HitNormal, EndShot, StartShot, True, Extent, HitInfo);
	HitDistance = VSize(HitLocation - StartShot);

	// POKE
	if(FireModeNum == 0)
	{
		PokeDir = Vector(Aim);

		if ( PhysicsGrabber.GrabbedComponent == None )
		{
			// `log("HitActor:"@HitActor@"Hit Bone:"@HitInfo.BoneName);
			if( HitActor != None &&
				HitActor != WorldInfo &&
				HitInfo.HitComponent != None )
			{
				PATActor = PhysAnimTestActor(HitActor);
				if(PATActor != None)
				{
					if( !PATActor.PrePokeActor(PokeDir) )
					{
						return;
					}
				}

				HitInfo.HitComponent.AddImpulse(PokeDir * WeaponImpulse, HitLocation, HitInfo.BoneName);
			}
		}
		else
		{
			PhysicsGrabber.GrabbedComponent.AddImpulse(PokeDir * ThrowImpulse, , PhysicsGrabber.GrabbedBoneName);
			PhysicsGrabber.ReleaseComponent();
		}
	}
	// GRAB
	else
	{
		if( HitActor != None &&
			HitActor != WorldInfo &&
			HitInfo.HitComponent != None &&
			HitDistance > HoldDistanceMin &&
			HitDistance < HoldDistanceMax )
		{
			PATActor = PhysAnimTestActor(HitActor);
			if(PATActor != None)
			{
				if( !PATActor.PreGrab() )
				{
					return;
				}
			}

			// If grabbing a bone of a skeletal mesh, dont constrain orientation.
			PhysicsGrabber.GrabComponent(HitInfo.HitComponent, HitInfo.BoneName, HitLocation, PlayerController(Instigator.Controller).bRun!=0);

			// If we succesfully grabbed something, store some details.
			if (PhysicsGrabber.GrabbedComponent != None)
			{
				HoldDistance	= HitDistance;
				PawnQuat		= QuatFromRotator( Rotation );
				InvPawnQuat		= QuatInvert( PawnQuat );

				if ( HitInfo.BoneName != '' )
				{
					SkelComp = SkeletalMeshComponent(HitInfo.HitComponent);
					ActorQuat = SkelComp.GetBoneQuaternion(HitInfo.BoneName);
				}
				else
				{
					ActorQuat = QuatFromRotator( PhysicsGrabber.GrabbedComponent.Owner.Rotation );
				}

				HoldOrientation = QuatProduct(InvPawnQuat, ActorQuat);
			}
		}
	}
}

simulated function StopFire(byte FireModeNum)
{
	local PhysAnimTestActor	PATActor;

	if ( PhysicsGrabber.GrabbedComponent != None )
	{
		PATActor = PhysAnimTestActor(PhysicsGrabber.GrabbedComponent.Owner);
		if(PATActor != None)
		{
			PATActor.EndGrab();
		}

		PhysicsGrabber.ReleaseComponent();
	}
}

simulated function bool DoOverridePrevWeapon()
{
	HoldDistance += ChangeHoldDistanceIncrement;
	HoldDistance = FMin(HoldDistance, HoldDistanceMax);
	return true;
}

simulated function bool DoOverrideNextWeapon()
{
	HoldDistance -= ChangeHoldDistanceIncrement;
	HoldDistance = FMax(HoldDistance, HoldDistanceMin);
	return true;
}

simulated function Tick( float DeltaTime )
{
	local vector	NewHandlePos, StartLoc;
	local Quat		PawnQuat, NewHandleOrientation;
	local Rotator	Aim;

	if ( PhysicsGrabber.GrabbedComponent == None )
	{
		GotoState( 'Active' );
		return;
	}

	PhysicsGrabber.GrabbedComponent.WakeRigidBody( PhysicsGrabber.GrabbedBoneName );

	// Update handle position on grabbed actor.
	StartLoc		= Instigator.GetWeaponStartTraceLocation();
	Aim				= GetAdjustedAim( StartLoc );
	NewHandlePos	= StartLoc + (HoldDistance * Vector(Aim));
	PhysicsGrabber.SetLocation( NewHandlePos );

	// Update handle orientation on grabbed actor.
	PawnQuat				= QuatFromRotator( Rotation );
	NewHandleOrientation	= QuatProduct(PawnQuat, HoldOrientation);
	PhysicsGrabber.SetOrientation( NewHandleOrientation );
}

defaultproperties
{
	HoldDistanceMin=0.0
	HoldDistanceMax=750.0
	WeaponImpulse=200.0
	ThrowImpulse=100.0
	ChangeHoldDistanceIncrement=50.0

	Begin Object Class=RB_Handle Name=RB_Handle0
		LinearDamping=1.0
		LinearStiffness=50.0
		AngularDamping=1.0
		AngularStiffness=50.0
	End Object
	Components.Add(RB_Handle0)
	PhysicsGrabber=RB_Handle0

	WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Projectile
}
