/**
 * Copyright � 2004-2005 Epic Games, Inc. All Rights Reserved.
 */
class Race_Cam_Death extends Race_CameraMode_Default
	config(Camera);


/**
* Returns the "worst case" camera location for this camera mode.
* This is the position that the camera ray is shot from, so it should be
* a guaranteed safe place to put the camera.
*/
simulated event vector GetCameraWorstCaseLoc(Pawn TargetPawn)
{
	local RacePawn RP;

	RP = RacePawn(TargetPawn);

	if ( RP != None )
	{
		return RP.LocationWhenKilled;
	}
	else
	{
		return TargetPawn.Location;
	}
}

defaultproperties
{
	ViewOffset={(
		OffsetHigh=(X=-100,Y=0,Z=125),
		OffsetLow=(X=-100,Y=0,Z=125),
		OffsetMid=(X=-100,Y=0,Z=125),
		)}
	ViewOffset_ViewportAdjustments(CVT_16to9_HorizSplit)={(
		OffsetHigh=(X=0,Y=0,Z=-40),
		OffsetLow=(X=0,Y=0,Z=-40),
		OffsetMid=(X=0,Y=0,Z=-40),
		)}
	ViewOffset_ViewportAdjustments(CVT_16to9_VertSplit)={(
		OffsetHigh=(X=0,Y=0,Z=0),
		OffsetLow=(X=0,Y=0,Z=0),
		OffsetMid=(X=0,Y=0,Z=0),
		)}
	ViewOffset_ViewportAdjustments(CVT_4to3_Full)={(
		OffsetHigh=(X=20,Y=0,Z=15),
		OffsetLow=(X=20,Y=0,Z=15),
		OffsetMid=(X=20,Y=0,Z=15),
		)}
	ViewOffset_ViewportAdjustments(CVT_4to3_HorizSplit)={(
		OffsetHigh=(X=0,Y=0,Z=-40),
		OffsetLow=(X=0,Y=0,Z=-40),
		OffsetMid=(X=0,Y=0,Z=-40),
		)}
	ViewOffset_ViewportAdjustments(CVT_4to3_VertSplit)={(
		OffsetHigh=(X=0,Y=0,Z=0),
		OffsetLow=(X=0,Y=0,Z=0),
		OffsetMid=(X=0,Y=0,Z=0),
		)}

	BlendTime=0.5f

	bDoPredictiveAvoidance=FALSE
	bValidateWorstLoc=FALSE

	WorstLocOffset=(X=0,Y=0,Z=64)
}
