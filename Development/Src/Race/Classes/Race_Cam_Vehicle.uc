/**
 * Copyright © 2004-2005 Epic Games, Inc. All Rights Reserved.
 * Camera mode for when player is in a vehicle.
 */
class Race_Cam_Vehicle extends Race_CameraMode_Default
	config(Camera);

/** returns View relative offsets */
simulated function GetBaseViewOffsets(Pawn ViewedPawn, ERaceCam_ViewportTypes ViewportConfig, float DeltaTime, out Vector out_Low, out Vector out_Mid, out Vector out_High)
{
	// todo: port from native
}

simulated function vector GetCameraWorstCaseLoc(Pawn TargetPawn)
{
	local RaceVehicle RV;
	RV = RaceVehicle(TargetPawn);

	if (RV != None)
	{
		// driving, use seat 0
		return RV.GetCameraWorstCaseLoc(0);
	}
	else
	{
		return super.GetCameraWorstCaseLoc(TargetPawn);
	}
}


/** Returns true if mode should be using direct-look mode, false otherwise */
simulated function bool UseDirectLookMode(Pawn CameraTarget)
{
	return bDirectLook;
}

/** Returns true if mode should lock camera to view target, false otherwise */
simulated function bool LockedToViewTarget(Pawn CameraTarget)
{
	return (bLockedToViewTarget) ? FALSE : bFollowTarget;
}

simulated function bool ShouldFollowTarget(Pawn CameraTarget, out float PitchInterpSpeed, out float YawInterpSpeed, out float RollInterpSpeed)
{
	if (LockedToViewTarget(CameraTarget))
	{
		// no following when locked
		return false;
	}
	
	if (bFollowTarget)
	{
		PitchInterpSpeed = FollowingInterpSpeed_Pitch;
		YawInterpSpeed = FollowingInterpSpeed_Yaw;
		RollInterpSpeed = FollowingInterpSpeed_Roll;
		return true;
	}

	return false;
}

defaultproperties
{
	BlendTime=0.2f

	// defaults, in case the vehicle's data doesn't work out
	ViewOffset={(
		OffsetHigh=(X=-128,Y=0,Z=24),
		OffsetLow=(X=-160,Y=0,Z=32),
		OffsetMid=(X=-160,Y=0,Z=0),
	)}

	bDirectLook=FALSE
	bLockedToViewTarget=TRUE
	bFollowTarget=FALSE
	FollowingInterpSpeed_Pitch=5.f
	FollowingInterpSpeed_Yaw=1.5f
	FollowingInterpSpeed_Roll=5.f
	FollowingCameraVelThreshold=1000.f
}
