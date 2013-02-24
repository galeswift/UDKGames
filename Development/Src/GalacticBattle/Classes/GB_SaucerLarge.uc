class GB_SaucerLarge extends UTAirVehicle;

/** This is the primary beam emitter - Short Burst Firre*/
var ParticleSystem 			BigBeamTemplate_ShortBurst;
var ParticleSystem			BigBeamTemplate_Charged;
var ParticleSystemComponent BigBeamEmitter;
var name					BigBeamEndpointVarName;
var name					BigBeamSocket;
var SoundCue 				BigBeamFireSound;

var vector LastCameraPosition;
var float LastPullBackDistance;
var float LastDropDownDistance;

/** radius to allow players under this Saucer to gain entry */
var float CustomEntryHeight;

/** Extra large radius because our saucer is so large */
var float CustomEntryRadius;

/** The vehicle that is deployed when you enter the 5th seat */
var UTVehicle DeployedVehicle;

simulated function VehicleWeaponFired( bool bViaReplication, vector HitLocation, int SeatIndex )
{
	local vector BigBeamSocketPosition;
	local rotator BigBeamSocketRotation;
	local vector BeamScale;

	if (SeatIndex == 0 )
	{
		if( Role == ROLE_Authority )
		{
			MaxSpeed = 0.0f;
		}

		if (BigBeamEmitter == None)
		{
			BigBeamEmitter = new(Outer) class'UTParticleSystemComponent';
			BigBeamEmitter.SetAbsolute(false, true, false);
			BigBeamEmitter.bAutoActivate = FALSE;
			BigBeamEmitter.SetTemplate(BigBeamTemplate_Charged);
			Mesh.AttachComponentToSocket(BigBeamEmitter, BigBeamSocket);
		}

		Mesh.GetSocketWorldLocationAndRotation(BigBeamSocket, BigBeamSocketPosition, BigBeamSocketRotation);
		BigBeamEmitter.SetRotation(rotator(HitLocation - BigBeamSocketPosition));

		// Set the end point.
		BigBeamEmitter.SetVectorParameter(BigBeamEndpointVarName, HitLocation);

		// Finally activate the system
		BigBeamEmitter.ActivateSystem();

		PlaySound(BigBeamFireSound);

		if(Seats[0].Gun != None)
		{
			Seats[0].Gun.ShakeView();
		}
		CauseMuzzleFlashLight(0);
	}
	else
	{
		Super.VehicleWeaponFired(bViaReplication, HitLocation, SeatIndex);
	}
}

simulated function VehicleWeaponStoppedFiring( bool bViaReplication, int SeatIndex )
{
	Super.VehicleWeaponStoppedFiring( bViaReplication, SeatIndex );

	MaxSpeed = default.MaxSpeed;
}

/**
  * Let pawns standing under me get in
  */
function bool InCustomEntryRadius(Pawn P)
{
	local bool Result;

	Result = ( (P.Location.Z < Location.Z) && (VSize2D(P.Location - Location) < CustomEntryHeight) && FastTrace(P.Location, Location) );
	Result = Result || VSize2D(P.Location - Location) < CustomEntryRadius;

	return Result;
}

/**
 * This function returns the aim for the weapon
 */
function rotator GetWeaponAim(UTVehicleWeapon VWeapon)
{
	local vector SocketLocation, CameraLocation, RealAimPoint, DesiredAimPoint, HitLocation, HitRotation, DirA, DirB;
	local rotator CameraRotation, SocketRotation, ControllerAim, AdjustedAim;
	local float DiffAngle, MaxAdjust;
	local Controller C;
	local PlayerController PC;
	local Quat Q;

	if ( VWeapon != none )
	{
		C = Seats[VWeapon.SeatIndex].SeatPawn.Controller;

		PC = PlayerController(C);
		if (PC != None)
		{
			PC.GetPlayerViewPoint(CameraLocation, CameraRotation);
			DesiredAimPoint = CameraLocation + Vector(CameraRotation) * VWeapon.GetTraceRange();
			if (Trace(HitLocation, HitRotation, DesiredAimPoint, CameraLocation) != None)
			{
				DesiredAimPoint = HitLocation;
			}
		}
		return CameraRotation;
	}
}

/**
 * ChangeSeat, this controller to change from it's current seat to a new one if (A) the new
 * set is empty or (B) the controller looking to move has Priority over the controller already
 * there.
 *
 * If the seat is filled but the new controller has priority, the current seat holder will be
 * bumped and swapped in to the seat left vacant.
 *
 * @param	ControllerToMove		The Controller we are trying to move
 * @param	RequestedSeat			Where are we trying to move him to
 *
 * @returns true if successful
 */
function bool ChangeSeat(Controller ControllerToMove, int RequestedSeat)
{
	local int OldSeatIndex;
	local Pawn OldPawn, BumpPawn;
	local Controller BumpController;

	if( RequestedSeat == 5 && ( DeployedVehicle == none || DeployedVehicle.Health <= 0  ) )
	{
		if( FastTrace( Location + vect(0,0,1) * -1250, Location, vect(12,12,12) ) )
		{
			// Spawn a new cicada for us, and put us in it!
			DeployedVehicle = Spawn( class'UTVehicle_Cicada_Content', self, , Location + vect(0,0,1) * -1250 , Rotation );

			if( DeployedVehicle != none )
			{
				// get the seat index of the pawn looking to move.
				OldSeatIndex = GetSeatIndexForController(ControllerToMove);

				if (OldSeatIndex == -1)
				{
					// Couldn't Find the controller, should never happen
					`Warn("[Vehicles] Attempted to switch" @ ControllerToMove @ "to a seat in" @ self @ " when he is not already in the vehicle");
					return false;
				}

				OldPawn = Seats[OldSeatIndex].StoragePawn;

				// Leave the current seat and take over the new one
				Seats[OldSeatIndex].SeatPawn.DriverLeave(true);
				if (OldSeatIndex == 0)
				{
					// Reset the controller's AI if needed
					if (ControllerToMove.RouteGoal == self)
					{
						ControllerToMove.RouteGoal = None;
					}
					if (ControllerToMove.MoveTarget == self)
					{
						ControllerToMove.MoveTarget = None;
					}
				}

				DeployedVehicle.DriverEnter(OldPawn);
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	else
	{
		// Make sure we are looking to switch to a valid seat
		if ( (RequestedSeat >= Seats.Length) || (RequestedSeat < 0) )
		{
			return false;
		}

		// get the seat index of the pawn looking to move.
		OldSeatIndex = GetSeatIndexForController(ControllerToMove);
		if (OldSeatIndex == -1)
		{
			// Couldn't Find the controller, should never happen
			`Warn("[Vehicles] Attempted to switch" @ ControllerToMove @ "to a seat in" @ self @ " when he is not already in the vehicle");
			return false;
		}

		// If someone is in the seat, see if we can bump him
		if (!SeatAvailable(RequestedSeat))
		{
			// Get the Seat holder's controller and check it for Priority
			BumpController = GetControllerForSeatIndex(RequestedSeat);
			if (BumpController == none)
			{
				`warn("[Vehicles]" @ ControllertoMove @ "Attempted to bump a phantom Controller in seat in" @ RequestedSeat @ " (" $ Seats[RequestedSeat].SeatPawn $ ")");
				return false;
			}

			if ( !HasPriority(ControllerToMove,BumpController) )
			{
				// Nope, same or great priority on the seat holder, deny the move
				if ( PlayerController(ControllerToMove) != None )
				{
					PlayerController(ControllerToMove).ClientPlaySound(VehicleLockedSound);
				}
				return false;
			}

			// If we are bumping someone, free their seat.
			if (BumpController != None)
			{
				BumpPawn = Seats[RequestedSeat].StoragePawn;
				Seats[RequestedSeat].SeatPawn.DriverLeave(true);

				// Handle if we bump the driver
				if (RequestedSeat == 0)
				{
					// Reset the controller's AI if needed
					if (BumpController.RouteGoal == self)
					{
						BumpController.RouteGoal = None;
					}
					if (BumpController.MoveTarget == self)
					{
						BumpController.MoveTarget = None;
					}
				}
			}
		}

		OldPawn = Seats[OldSeatIndex].StoragePawn;

		// Leave the current seat and take over the new one
		Seats[OldSeatIndex].SeatPawn.DriverLeave(true);
		if (OldSeatIndex == 0)
		{
			// Reset the controller's AI if needed
			if (ControllerToMove.RouteGoal == self)
			{
				ControllerToMove.RouteGoal = None;
			}
			if (ControllerToMove.MoveTarget == self)
			{
				ControllerToMove.MoveTarget = None;
			}
		}

		if (RequestedSeat == 0)
		{
			DriverEnter(OldPawn);
		}
		else
		{
			PassengerEnter(OldPawn, RequestedSeat);
		}


		// If we had to bump a pawn, seat them in this controller's old seat.
		if (BumpPawn != None)
		{
			if (OldSeatIndex == 0)
			{
				DriverEnter(BumpPawn);
			}
			else
			{
				PassengerEnter(BumpPawn, OldSeatIndex);
			}
		}
		return true;
	}
}

DefaultProperties
{

	BigBeamTemplate_ShortBurst=ParticleSystem'VH_Leviathan.Effects.P_VH_Leviathan_BigBeam'
	BigBeamTemplate_Charged = ParticleSystem'FX_Saucer.FX_GiantBeam'

	BigBeamSocket=LaserBeamSocket
	BigBeamEndpointVarName=BigBeamDest
	BigBeamFiresound=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_CannonFire'

	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_GiantSaucer.SkeletalMeshes.SK_BattleSaucer'
		PhysicsAsset=PhysicsAsset'VH_GiantSaucer.SkeletalMeshes.SK_BattleSaucer_Physics'
		AnimTreeTemplate = AnimTree'VH_GiantSaucer.AT_BattleSaucer'
		Scale = .3
	End Object

	Begin Object Class=UTVehicleSimChopper Name=SimObject
		MaxThrustForce=20000.0
		MaxReverseForce=20000.0
		DirectionChangeForce = 20000
		LongDamping=0.6
		MaxStrafeForce=6800.0
		LatDamping=0.7
		MaxRiseForce=10000.0
		UpDamping=.7
		TurnTorqueFactor=200000.0
		TurnTorqueMax=200000.0
		TurnDamping=1.0
		MaxYawRate=100000.0
		PitchTorqueFactor=450.0
		PitchTorqueMax=60.0
		PitchDamping=0.3
		RollTorqueTurnFactor=700.0
		RollTorqueStrafeFactor=100.0
		RollTorqueMax=300.0
		RollDamping=0.1
		MaxRandForce=30.0
		RandForceInterval=0.5
		StopThreshold=600
		bShouldCutThrustMaxOnImpact=true
		bFullThrustOnDirectionChange = true
	End Object
	SimObj=SimObject
	Components.Add(SimObject)

	bHasCustomEntryRadius=true

	Seats.Empty
	Seats(0)={(	GunClass=class'GB_VWeap_BigSaucerPrimary',
				CameraTag=ViewSocket,
				CameraEyeHeight=0,
				CameraOffset=0,
				CameraBaseOffset=(X=-0,Z=0.0),
				SeatIconPos=(X=0.48,Y=0.25),
				)}



	Seats(1)={( GunClass=class'GB_VWeap_SaucerTurretRocket',
				GunSocket=(S_Gun1),
				CameraTag=ViewSocket,
				TurretVarPrefix="Door1",
				CameraEyeHeight=50,
				CameraOffset=0,
				CameraBaseOffset=(X=-30,Z=-15),
				TurretControls=(SkelControl_Gun1),
				GunPivotPoints=(BoneOuterDoor01),
				MuzzleFlashLightClass=class'UTGame.UTTurretMuzzleFlashLight',
				SeatIconPos=(X=0.235,Y=0.15),
				ViewPitchMin=-10402,
				DriverDamageMult=0.0,
				WeaponEffects=((SocketName=S_Gun1,Offset=(X=0,Y=0,Z=0),Scale3D=(X=5.0,Y=8.0,Z=8.0)))
				)}
//
//
//	Seats(2)={( GunClass=class'GB_VWeap_SaucerTurretRocket',
//				GunSocket=(RF_TurretBarrel,RF_TurretBarrel,RF_TurretBarrel),
//				TurretVarPrefix="RFTurret",
//				SeatOffset=(X=4,Z=72),
//				CameraEyeHeight=50,
//				CameraOffset=-25,
//				CameraBaseOffset=(Z=-15),
//				bSeatVisible=true,
//				SeatBone=RT_Front_TurretPitch,
//				TurretControls=(RT_Front_TurretYaw,RT_Front_TurretPitch),
//				GunPivotPoints=(Rt_Front_TurretYaw,Rt_Front_TurretYaw),
//				CameraTag=RF_TurretCamera,
//				MuzzleFlashLightClass=class'UTGame.UTRocketMuzzleFlashLight',
//				ViewPitchMin=-10402,
//				SeatIconPos=(X=0.635,Y=0.15),
//				DriverDamageMult=0.1,
//				WeaponEffects=((SocketName=RF_TurretBarrel,Offset=(X=-30),Scale3D=(X=5.0,Y=8.0,Z=8.0)))
//				)}
//
//	Seats(3)={( GunClass=class'GB_VWeap_SaucerTurretStinger',
//				GunSocket=(LR_TurretBarrel),
//				TurretVarPrefix="LRTurret",
//				CameraEyeHeight=50,
//				CameraOffset=-25,
//				CameraBaseOffset=(Z=-15),
//				bSeatVisible=true,
//				SeatBone=LT_Rear_TurretPitch,
//				SeatOffset=(X=4,Z=72),
//				TurretControls=(LT_Rear_TurretYaw,LT_Rear_TurretPitch),
//				GunPivotPoints=(Lt_Rear_TurretYaw,Lt_Rear_TurretYaw),
//				CameraTag=LR_TurretCamera,
//				MuzzleFlashLightClass=class'UTStingerTurretMuzzleFlashLight',
//				SeatIconPos=(X=0.235,Y=0.75),
//				ViewPitchMin=-10402,
//				DriverDamageMult=0.1,
//				WeaponEffects=((SocketName=LR_TurretBarrel,Offset=(X=-30),Scale3D=(X=5.0,Y=8.0,Z=8.0)))
//				)}
//
//	Seats(4)={( GunClass=class'GB_VWeap_SaucerTurretShock',
//				GunSocket=(RR_TurretBarrel),
//				TurretVarPrefix="RRTurret",
//				TurretControls=(RT_Rear_TurretYaw,RT_Rear_TurretPitch),
//				CameraEyeHeight=50,
//				CameraOffset=-25,
//				CameraBaseOffset=(Z=-15),
//				bSeatVisible=true,
//				SeatOffset=(X=4,Z=72),
//				SeatIconPos=(X=0.635,Y=0.75),
//				SeatBone=RT_Rear_TurretPitch,
//				GunPivotPoints=(Rt_Rear_TurretPitch,Rt_Rear_TurretPitch),
//				CameraTag=RR_TurretCamera,
//				ViewPitchMin=-10402,
//				DriverDamageMult=0.1,
//				WeaponEffects=((SocketName=RR_TurretBarrel,Offset=(X=-30),Scale3D=(X=5.0,Y=8.0,Z=8.0)))
//				)}

	DrivingPhysicalMaterial = PhysicalMaterial'VH_GiantSaucer.PHYS_GiantSaucer_Driving'
	DefaultPhysicalMaterial = PhysicalMaterial'VH_GiantSaucer.PHYS_GiantSaucer'

	ViewPitchMin=-14000.0,
	ViewPitchMax=-8000.0,

	AirSpeed=2000.0
	GroundSpeed=1600.0

	UprightLiftStrength=30.0
	UprightTorqueStrength=30.0

	bStayUpright=true
	StayUprightRollResistAngle=5.0
	StayUprightPitchResistAngle=5.0
	StayUprightStiffness=30000
	StayUprightDamping=1000


	// Sounds
	// Engine sound.
	Begin Object Class=AudioComponent Name=RaptorEngineSound
		SoundCue=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_EngineLoop'
	End Object
	EngineSound=RaptorEngineSound
	Components.Add(RaptorEngineSound);

	CollisionSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Collide'
	EnterVehicleSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Start'
	ExitVehicleSound=SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_Stop'

	// Scrape sound.
	Begin Object Class=AudioComponent Name=BaseScrapeSound
		SoundCue=SoundCue'A_Gameplay.A_Gameplay_Onslaught_MetalScrape01Cue'
	End Object
	ScrapeSound=BaseScrapeSound
	Components.Add(BaseScrapeSound);

	CustomEntryHeight=240.0
	CustomEntryRadius = 1200.0

	Health = 10000

}