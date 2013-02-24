//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Race_CameraMode extends CameraMode
	config(Camera);

/**
 * Contains all the information needed to define a camera
 * mode.
 */

/** Pawn relative offset. It's relative from Pawn's location, aligned to Pawn's rotation */
var() vector PawnRelativeOffset;

/** FOV for camera to use */
var() config float FOVAngle;

/** Blend Time to and from this view mode */
var() float BlendTime;

/**
 * True if, while in this mode, the camera should be tied to the viewtarget rotation.
 * This is typical for the normal walking-around camera, since the controls rotate the controller
 * and the camera follows.  This can be false if you want free control of the camera, independent
 * of the viewtarget's orient -- we use this for vehicles.  Note that if this is false,
 */
var() protected bool bLockedToViewTarget;

/**
 * True if, while in this mode, looking around should be directly mapped to stick position
 * as opposed to relative to previous camera positions.
 */
var() protected bool bDirectLook;

/**
 * True if, while in this mode, the camera should interpolate towards a following position
 * in relation to the target and it's motion.  Ignored if bLockedToViewTarget is set to true.
 */
var() protected bool bFollowTarget;

/*
 * How fast the camera should track to follow behind the viewtarget.  0.f for no following.
 * Only used if bLockedToViewTarget is FALSE
 */
var() float		FollowingInterpSpeed_Pitch;
var() float		FollowingInterpSpeed_Yaw;
var() float		FollowingInterpSpeed_Roll;

/** Actual following interp speed gets scaled from FollowingInterpSpeed to zero between velocities of this value and zero. */
var() float		FollowingCameraVelThreshold;

/** Lazy cam interpolation speed */
var() float		LazyCamSpeed;

/** Adjustment vector to apply to camera view offset when target is strafing to the left */
var() vector	StrafeLeftAdjustment;
/** Adjustment vector to apply to camera view offset when target is strafing to the right */
var() vector	StrafeRightAdjustment;
/** Velocity at (and above) which the full adjustment should be applied. */
var() float		StrafeOffsetScalingThreshold;
/** Interpolation speed for interpolating to a NONZERO strafe offsets.  Higher is faster/tighter interpolation. */
var() float		StrafeOffsetInterpSpeedIn;
/** Interpolation speed for interpolating to a ZERO strafe offset.  Higher is faster/tighter interpolation. */
var() float		StrafeOffsetInterpSpeedOut;
/** Strafe offset last tick, used for interpolation. */
var protected transient vector LastStrafeOffset;

/** Adjustment vector to apply to camera view offset when target is moving forward */
var() vector	RunFwdAdjustment;
/** Adjustment vector to apply to camera view offset when target is moving backward */
var() vector	RunBackAdjustment;
/** Velocity at (and above) which the full adjustment should be applied. */
var() float		RunOffsetScalingThreshold;
/** Interpolation speed for interpolating to a NONZERO offset.  Higher is faster/tighter interpolation. */
var() float		RunOffsetInterpSpeedIn;
/** Interpolation speed for interpolating to a ZERO offset.  Higher is faster/tighter interpolation. */
var() float		RunOffsetInterpSpeedOut;
/** Run offset last tick, used for interpolation. */
var protected transient vector LastRunOffset;

/** offset from viewtarget, to calculate worst camera location. Is also mirrored like player. */
var() vector	WorstLocOffset;

/** True if this camera mode will try to do a HijackCamera call, false otherwise */
var const bool	bCanHijackCamera;

/** True to turn do predictive camera avoidance, false otherwise */
var() bool		bDoPredictiveAvoidance;

/** TRUE to do a raytrace from camera base loc to worst loc, just to be sure it's cool.  False to skip it */
var() bool		bValidateWorstLoc;

/** contains offsets from camera target to camera loc */
var() ViewOffsetData	ViewOffset;

/** viewoffset adjustment vectors for each possible viewport type, so the game looks the same in each */
//var() ViewOffsetData	ViewOffset_ViewportAdjustments[ERaceCam_ViewportTypes.EnumCount];
var() ViewOffsetData	ViewOffset_ViewportAdjustments[6];


/** Called when Camera mode becomes active */
function OnBecomeActive( Pawn P, Camera CameraOwner );
/** Called when camera mode becomes inactive */
function OnBecomeInActive( Pawn P, Camera CameraOwner );

/** Get Pawn's relative offset (from location based on pawn's rotation */
event vector GetPawnRelativeOffset( Pawn P )
{
	//local vector	FinalOffset;
	//local RacePawn	RP;

	//RP = RacePawn(P);

	//FinalOffset = PawnRelativeOffset;

	//// if target is a RacePawn and pawn is facing left, then mirror Y axis.
	//if( (RP != None) && RP.bIsMirrored )
	//{
	//	FinalOffset.Y = -FinalOffset.Y;
	//}
	//return FinalOffset;
	return PawnRelativeOffset;
}

/**
 * Tells player camera if this CameraMode wants to override the camera location used
 */
simulated event bool HijackCamera(Pawn P, float DeltaTime, out vector CamLoc, out rotator CamRot, Race_PlayerCamera RPC)
{
	return false;
}

/**
 * Calculates and returns the ideal view offset for the specified camera mode.
 * The offset is relative to the Camera's pos/rot and calculated by interpolating
 * 2 ideal view points based on the player view pitch.
 *
 * @param	ViewedPawn			Camera target pawn
 * @param	DeltaTime			Delta time since last frame.
 * @param	ViewRotation		Rot of the camera
 */

final simulated function vector GetViewOffset
(
		Pawn				ViewedPawn,
		float				DeltaTime,
		const out Rotator	ViewRotation
)
{
	local vector out_Offset,MidOffset, LowOffset, HighOffset,ExtraOffset;
	local vector2d ViewportSize;
	local ERaceCam_ViewportTypes ViewportConfig;
	local GameViewportClient VPClient;
	local PlayerController PlayerOwner;
	local LocalPlayer LP;
	local float Aspect,Pitch, Pct;

	// figure out which viewport config we're in.  16:9 full is default to fall back on
	ViewportConfig = CVT_16to9_Full;

	PlayerOwner = PlayerController(ViewedPawn.Controller);
	if( PlayerOwner != none )
	{
		LP = LocalPlayer(PlayerOwner.Player);
	}
	else
	{
		LP = none;
	}

	if( LP != none )
	{
		VPClient = LP.ViewportClient;
	}
	else
	{
		VPClient = none;
	}

	if ( VPClient != none  )
	{
		VPClient.GetViewportSize(ViewportSize);

		Aspect =  ViewportSize.X / ViewportSize.Y;

		// for PC, let's try just choosing the set of offsets for the aspect closest
		// to the one we're using.  if this fails, we can try setting up offsets for
		// every supported aspect ratio, but that will be time consuming.
		if ( Aspect > ((16.f/9.f + 4.f/3.f) / 2.f) )
		{
			ViewportConfig = CVT_16to9_Full;
		}
		else
		{
			ViewportConfig = CVT_4to3_Full;
		}
	}

	// find our 3 offsets
	GetBaseViewOffsets( ViewedPawn, ViewportConfig, DeltaTime, LowOffset, MidOffset, HighOffset );

	// apply viewport-config adjustments
	LowOffset += ViewOffset_ViewportAdjustments[ViewportConfig].OffsetLow;
	MidOffset += ViewOffset_ViewportAdjustments[ViewportConfig].OffsetMid;
	HighOffset += ViewOffset_ViewportAdjustments[ViewportConfig].OffsetHigh;

	// calculate final offset based on camera pitch
	Pitch = float(ViewRotation.Pitch & 65535);
	Pct = 0.f;
	if( Pitch >= 0.f )
	{
		Pct			= Pitch / ViewedPawn.default.ViewPitchMax;
		out_Offset	= VLerp( MidOffset, LowOffset, Pct );
	}
	else
	{
		Pct			= Pitch / ViewedPawn.default.ViewPitchMin;
		out_Offset	= VLerp( MidOffset, HighOffset, Pct );
	}

	// note, this offset isn't really pawn-relative anymore, should
	// get folded into regular viewoffset stuff
	ExtraOffset = GetPawnRelativeOffset(ViewedPawn);
	out_Offset += ExtraOffset;
	return out_Offset;
}

/** returns camera mode desired FOV */
event float GetDesiredFOV( Pawn ViewedPawn )
{
//	local WarWeapon WW;
//
//	WW = WarWeapon(ViewedPawn.Weapon);
//
//	if (WW != None)
//	{
//		return WW.GetAdjustedFOV(FOVAngle);
//	}
//	else
//	{
		return FOVAngle;
//	}
}

/**
 * Notification from InventoryManager when my player's weapon changes
 */
function WeaponChanged(Controller C, Weapon OldWeapon, Weapon NewWeapon);

/** Returns ideal camera origin for this camera mode */
simulated function Vector GetIdealCameraOrigin( Race_PlayerCamera Cam, Pawn ViewPawn )
{
	//local RacePawn RP;
	//RP = RacePawn(ViewPawn);
	//if( RP != none )
	//{
	//	//@fixme, this is a bit of a hack, but RacePawn::GetPawnViewLocation does some
	//	// stuff with the neck bone, which screws up some offsets we've already figured out.
	//	// ideally, we'll adjust those values and just call GetPawnViewLocation() here.
	//	return ViewPawn.GetIdealCameraOrigin();
	//}

	return ViewPawn.GetPawnViewLocation();
}

/** Returns ideal camera rotation */
simulated function Rotator GetIdealCameraRotation( Race_PlayerCamera Cam, Pawn ViewPawn )
{
	return Cam.Rotation;
}

/** returns View relative offsets */
simulated function GetBaseViewOffsets
(
	Pawn					ViewedPawn,
	ERaceCam_ViewportTypes	ViewportConfig,
	float					DeltaTime,
	out Vector				out_Low,
	out Vector				out_Mid,
	out Vector				out_High
)
{
	local vector StrafeOffset, RunOffset, X, Y, Z, NormalVel, UnusedVec, TotalOffset;
    local float VelMag, YDot, XDot, Speed;
	//local RacePawn RP;
	local rotator CamRot;

	// calculate strafe and running offsets
	VelMag = VSize(ViewedPawn.Velocity);

	if (VelMag > 0.f)
	{
		GetAxes(ViewedPawn.Rotation, X, Y, Z);
		NormalVel = ViewedPawn.Velocity / VelMag;

		if (StrafeOffsetScalingThreshold > 0.f)
		{
			YDot = Y dot NormalVel;
			if (YDot < 0.f)
			{
				StrafeOffset = StrafeLeftAdjustment * -YDot;
			}
			else
			{
				StrafeOffset = StrafeRightAdjustment * YDot;
			}
			StrafeOffset *= Clamp(VelMag / StrafeOffsetScalingThreshold, 0.f, 1.f);
		}

		if (RunOffsetScalingThreshold > 0.f)
		{
			XDot = X dot NormalVel;
			if (XDot < 0.f)
			{
				RunOffset = RunBackAdjustment * -XDot;
			}
			else
			{
				RunOffset = RunFwdAdjustment * XDot;
			}
			RunOffset *= Clamp(VelMag / RunOffsetScalingThreshold, 0.f, 1.f);
		}
	}

	// interpolate StrafeOffset and RunOffset to avoid little pops
	Speed = StrafeOffset == vect(0,0,0) ? StrafeOffsetInterpSpeedOut : StrafeOffsetInterpSpeedIn;
	StrafeOffset = VInterpTo(LastStrafeOffset, StrafeOffset, DeltaTime, Speed);
	LastStrafeOffset = StrafeOffset;

	Speed = RunOffset == vect(0,0,0) ? RunOffsetInterpSpeedOut : RunOffsetInterpSpeedIn;
	RunOffset = VInterpTo(LastRunOffset, RunOffset, DeltaTime, Speed);
	LastRunOffset = RunOffset;

	// Controllers are not valid for other players in MP mode
	if( ViewedPawn.Controller != none )
	{
		ViewedPawn.Controller.GetPlayerViewPoint(UnusedVec, CamRot);
	}
	// so just use the Pawn's data to determine where to place the camera's starting loc / rot
	else
	{
		CamRot = ViewedPawn.Rotation;
	}

	TotalOffset = StrafeOffset + RunOffset;
	TotalOffset = class'ARaceGenericDefines'.static.WorldToLocal(TotalOffset, ViewedPawn.Rotation);
	TotalOffset = class'ARaceGenericDefines'.static.LocalToWorld(TotalOffset, CamRot);

	out_Low		= ViewOffset.OffsetLow;
	out_Mid 	= ViewOffset.OffsetMid;
	out_High	= ViewOffset.OffsetHigh;

	//RP = RacePawn(ViewedPawn);
	//if (RP && RP.bIsMirrored)
	//{
	//	out_Low.Y = -out_Low.Y;
	//	out_Mid.Y = -out_Mid.Y;
	//	out_High.Y = -out_High.Y;
	//}

	out_Low		+= TotalOffset;
	out_Mid 	+= TotalOffset;
	out_High	+= TotalOffset;
}

/**
 * Returns the "worst case" camera location for this camera mode.
 * This is the position that the camera ray is shot from, so it should be
 * a guaranteed safe place to put the camera.
 */
simulated event vector GetCameraWorstCaseLoc(Pawn TargetPawn)
{
	local RacePawn RP;
	local vector WorstLocation;

	RP = RacePawn(TargetPawn);

	if (RP != None)
	{
		WorstLocation = RP.Location + (WorstLocOffset >> RP.Rotation);
	}
	else
	{
		`log("Warning, using default WorstLocation in "@GetFuncName());
		WorstLocation = TargetPawn.Location;
	}

	return WorstLocation;
}

/** Returns true if mode should be using direct-look mode, false otherwise */
simulated function bool UseDirectLookMode(Pawn CameraTarget)
{
	return bDirectLook;
}

/** Returns true if mode should lock camera to view target, false otherwise */
simulated function bool LockedToViewTarget(Pawn CameraTarget)
{
	return bLockedToViewTarget;
}


/**
 * Returns true if this mode should do target following.  If true is returned, interp speeds are filled in.
 * If false is returned, interp speeds are not altered.
 */
simulated function bool ShouldFollowTarget(Pawn CameraTarget, out float PitchInterpSpeed, out float YawInterpSpeed, out float RollInterpSpeed)
{
	//local RacePlayerController RPC;

	if( LockedToViewTarget( CameraTarget ) )
	{
		// no following when locked
		return FALSE;
	}

	//RPC = RacePlayerController(CameraTarget.Controller);
	//if( RPC && RPC.bAssessMode )
	//{
	//	// no following when using tac/com
	//	return FALSE;
	//}

	if( bFollowTarget )
	{
		PitchInterpSpeed = FollowingInterpSpeed_Pitch;
		YawInterpSpeed	 = FollowingInterpSpeed_Yaw;
		RollInterpSpeed  = FollowingInterpSpeed_Roll;

		return TRUE;
	}

	return FALSE;
}


/**
 * Returns an offset, in pawn-local space, to be applied to the camera origin.
 */
simulated function vector GetCameraOriginOffset(Pawn TargetPawn)
{
	return vect(0.f,0.f,0.f);
}


simulated function Actor GetTraceOwner( Pawn TargetPawn )
{
	return TargetPawn;
}

defaultproperties
{
	BlendTime=0.67

	bLockedToViewTarget=TRUE
	bCanHijackCamera=FALSE
	bDoPredictiveAvoidance=TRUE
	bValidateWorstLoc=TRUE
	LazyCamSpeed=8

	StrafeLeftAdjustment=(X=0,Y=0,Z=0)
	StrafeRightAdjustment=(X=0,Y=0,Z=0)
	StrafeOffsetInterpSpeedIn=12.f
	StrafeOffsetInterpSpeedOut=20.f
	RunFwdAdjustment=(X=0,Y=0,Z=0)
	RunBackAdjustment=(X=0,Y=0,Z=0)
	RunOffsetInterpSpeedIn=6.f
	RunOffsetInterpSpeedOut=12.f

	WorstLocOffset=(X=-8,Y=1,Z=90)

	/** all offsets are hand-crafted for this mode, so they should theoretically be all zeroes for all modes */
	ViewOffset_ViewportAdjustments(CVT_16to9_Full)={(
		OffsetHigh=(X=0,Y=0,Z=0),
		OffsetLow=(X=0,Y=0,Z=0),
		OffsetMid=(X=0,Y=0,Z=0),
		)}
}
