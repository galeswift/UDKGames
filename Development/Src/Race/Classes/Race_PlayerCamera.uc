/**
 * Copyright © 1998-2006 Epic Games, Inc. All Rights Reserved.
 */
class Race_PlayerCamera extends Camera
	config(Camera);

// NOTE FOR REFERENCE
// >> IS LOCAL->WORLD (no transpose)
// << IS WORLD->LOCAL (has the transpose)

/** Race global macros */
`include( Race\Classes\RaceGlobalMacros.uci )
//`include( Core\Globals.uci )

const CLIP_EXTENT_SCALE = 1.2;

/** resets camera interpolation. Set on first frame and teleports to prevent long distance or wrong camera interpolations. */
var					bool	bResetCameraInterpolation;

/** Last actual camera origin position, for lazy cam interpolation. It's only applied to player's origin, not view offsets, for faster/smoother response */
var		transient	vector	LastActualCameraOrigin;

/** obstruction pct from origin to worstloc origin */
var		float	WorstLocBlockedPct;
/** camera extent scale to use when calculating penetration for this segment */
var()	float	WorstLocPenetrationExtentScale;

/** Time to transition from blocked location to ideal position, after camera collision with geometry. */
var()	float	PenetrationBlendOutTime;
/** Time to transition from ideal location to blocked position, after camera collision with geometry. (used only by predictive feelers) */
var()	float	PenetrationBlendInTime;
/** Percentage of distance blocked by collision. From worst location, to desired location. */
var private float	PenetrationBlockedPct;
/** camera extent scale to use when calculating penetration for this segment */
var()	float	PenetrationExtentScale;


/**
 * Last pawn relative offset, for slow offsets interpolation.
 * This is because this offset is relative to the Pawn's rotation, which can change abruptly (when snapping to cover).
 * Used to adjust the camera origin (evade, lean, pop up, blind fire, reload..)
 */
var		transient	vector	LastActualOriginOffset;
var		transient	rotator	LastActualCameraOriginRot;
/** origin offset interpolation speed */
var()				float	OriginOffsetInterpSpeed;

/** View relative offset. This offset is relative to Controller's rotation, mainly used for Pitch positioning. */
var		transient	vector	LastViewOffset;
/** last CamFOV for cam interpolation */
var		transient	float	LastCamFOV;

/** Should the FOV be forced? */
var bool bUseForcedCamFOV;
/** Forced FOV angle for scripting/etc */
var float ForcedCamFOV;


/*********** CAMERA VARIABLES ***********/
/******* CAMERA MODES *******/
/** Base camera position when walking */
var(Camera)	editinline	Race_CameraMode		RaceCamDefault;
/** Death camera mode */
var(Camera) editinline		Race_CameraMode		RaceCamDeath;
///** Vehicle camera mode */
var(Camera) editinline		Race_CameraMode		RaceCamVehicle;

/** Default camera mode to use instead of CamDefault.  Can be set at runtime (ie via Kismet) */
var private Race_CameraMode					CustomDefaultCamMode;

/******* CAMERA MODIFIERS *******/
/** Camera modifier for screen shakes */
var(Camera) editinline	Race_CamMod_ScreenShake	Race_CamMod_ScreenShake;

//
// Player camera mode system
//

/** Current Cam Mode */
var()			Race_CameraMode	CurrentCamMode;

//
// Focus Point adjustment
//

/** last offset adjustement, for smooth blend out */
var transient	float	LastHeightAdjustment;
/** last adjusted pitch, for smooth blend out */
var transient	float	LastPitchAdjustment;
/** last adjusted Yaw, for smooth blend out */
var transient	float	LastYawAdjustment;
/** pitch adjustment when keeping target is done in 2 parts.  this is the amount to pitch in part 2 (post view offset application) */
var transient	float	LeftoverPitchAdjustment;

/**  move back pct based on move up */
var(Focus)			float		Focus_BackOffStrength;
/** Z offset step for every try */
var(Focus)			float		Focus_StepHeightAdjustment;
/** number of tries to have focus in view */
var(Focus)			int			Focus_MaxTries;
/** time it takes for fast interpolation speed to kick in */
var(Focus)			float		Focus_FastAdjustKickInTime;
/** Last time focus point changed (location) */
var					float		LastFocusChangeTime;
/** Last focus point location */
var					vector		LastFocusPointLoc;

/** Camera focus point definition */
struct CamFocusPoint
{
	/** focus point location in world space */
	var()	vector		FocusLoc;
	/** Interpolation speed (X=slow/focus loc moving, Y=fast/focus loc steady/blending out) */
	var()	vector2d	InterpSpeedRange;
	/** FOV where target is considered in focus, no correction is made */
	var()	vector2d	InFocusFOV;
	/** If FALSE, focus only if point roughly in view; if TRUE, focus no matter where player is looking */
	var()	bool		bAlwaysFocus;
	/** If TRUE, camera adjusts to keep player in view, if FALSE it stays in place */
	var()	bool		bAdjustCamera;
	/** If TRUE, ignore world trace to find a good spot */
	var()	bool		bIgnoreTrace;
	/** Bone name to focus on */
	var()	Name		FocusBoneName;
};
/** current focus point */
var(Focus)	CamFocusPoint	FocusPoint;
/** do we have a focus point set? */
var		bool			bFocusPointSet;

/** Vars for code-driven camera turns */
var	private	float			TurnCurTime;
var	private	bool			bDoingACameraTurn;
var	private int				TurnStartAngle;
var	private	int				TurnEndAngle;
var	private float			TurnTotalTime;
var	private	float			TurnDelay;
var	private	bool			bTurnAlignTargetWhenFinished;
/** Saved data for camera turn "align when finished" functionality */
var private transient int	LastPostCamTurnYaw;

/** toggles debug mode */
var()	bool				bCamDebug;

/** direct look vars */
var		transient	int		DirectLookYaw;
var		transient	bool	bDoingDirectLook;
var()				float	DirectLookInterpSpeed;

var() float					WorstLocInterpSpeed;
var transient vector		LastWorstLocationLocal;

/** Last rotation of the camera, cached before camera modifiers are applied. Used by focus point code. */
var transient rotator		LastPreModifierCameraRot;

/** interp speed for Camera rotational interpolation that is used while spectating in network games */
var() private float			SpectatorCameraRotInterpSpeed;



/**
 * Struct defining a feeler ray used for camera penetration avoidance.
 */
struct PenetrationAvoidanceFeeler
{
	/** rotator describing deviance from main ray */
	var() Rotator	AdjustmentRot;
	/** how much this feeler affects the final position if it hits the world */
	var() float		WorldWeight;
	/** how much this feeler affects the final position if it hits a Pawn (setting to 0 will not attempt to collide with pawns at all) */
	var() float		PawnWeight;
	/** extent to use for collision when firing this ray */
	var() vector	Extent;
};
var() array<PenetrationAvoidanceFeeler> PenetrationAvoidanceFeelers;

var array<Actor> HiddenActors;

/** CameraBlood emitter attached to this camera */
//var transient Emit_CameraBlood CameraBloodEmitter;

enum EAltDefaultCameraModes
{
	DefaultCam_Normal,
	DefaultCam_CorpserEncounter,
};

function PostBeginPlay()
{
	super.PostBeginPlay();

	// Setup camera modes
	if ( RaceCamDefault == None )
	{
		RaceCamDefault					    = new(Outer) class'Race_CameraMode_Default';
		RaceCamDeath						= new(Outer) class'Race_Cam_Death';
		RaceCamVehicle						= new(Outer) class'Race_Cam_Vehicle';
	}

	// Setup camera modifiers
	if( Race_CamMod_ScreenShake == None )
	{
		Race_CamMod_ScreenShake = new(Outer) class'Race_CamMod_ScreenShake';
	}
	Race_CamMod_ScreenShake.Init();
	Race_CamMod_ScreenShake.AddCameraModifier( Self );
}

// reset the camera to a good state
function Reset()
{
	bResetCameraInterpolation = true;
	bUseForcedCamFOV = false;
}

/**
 * Camera Shake
 * Plays camera shake effect
 *
 * @param	Duration			Duration in seconds of shake
 * @param	newRotAmplitude		view rotation amplitude (pitch,yaw,roll)
 * @param	newRotFrequency		frequency of rotation shake
 * @param	newLocAmplitude		relative view offset amplitude (x,y,z)
 * @param	newLocFrequency		frequency of view offset shake
 * @param	newFOVAmplitude		fov shake amplitude
 * @param	newFOVFrequency		fov shake frequency
 */
final function CameraShake
(
	float	Duration,
	vector	newRotAmplitude,
	vector	newRotFrequency,
	vector	newLocAmplitude,
	vector	newLocFrequency,
	float	newFOVAmplitude,
	float	newFOVFrequency
)
{
	Race_CamMod_ScreenShake.StartNewShake( Duration, newRotAmplitude, newRotFrequency, newLocAmplitude, newLocFrequency, newFOVAmplitude, newFOVFrequency );
}


/**
 * Play a camera shake
 */
final function PlayCameraShake( const out RaceScreenShakeStruct ScreenShake )
{
	Race_CamMod_ScreenShake.AddScreenShake( ScreenShake );
}

/**
 * Query ViewTarget and outputs Point Of View.
 *
 * @param	OutVT		ViewTarget to use.
 * @param	DeltaTime	Delta Time since last camera update (in seconds).
 */
function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
	local Pawn P;
	//local float Time;
	//clock(Time);

	// Make sure we have a valid target
	if( OutVT.Target == None )
	{
		`log("Camera::UpdateCamera ViewTarget.Target == None");
		return;
	}

	// Default Camera Behavior
	P = Pawn(OutVT.Target);
	if( CameraStyle == 'default' && P != None )
	{
		PlayerUpdateCamera(P, DeltaTime, OutVT);
	}
	else if ( CameraStyle == 'Spectating' )
	{
		UpdateSpectatingCamera(DeltaTime, OutVT);
	}
	else if (CameraStyle == 'FaceCam')
	{
		UpdateDebugFaceCam(P, DeltaTime, OutVT);
	}
	else
	{
		//`log("got here, camerastyle"@CameraStyle@P);
		super.UpdateViewTarget(OutVT, DeltaTime);
	}

	// if we had to reset camera interpolation, then turn off flag once it's been processed.
	if( bResetCameraInterpolation )
	{
		bResetCameraInterpolation = FALSE;
	}

	// set camera's loc and rot, to handle cases where we are not locked to view target
	SetRotation(OutVT.POV.Rotation);
	SetLocation(OutVT.POV.Location);

	//// update any attached camera blood
	//if (CameraBloodEmitter != None)
	//{
	//	CameraBloodEmitter.UpdateLocation(OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV);
	//}

	//unclock(Time);
	//`log(GetFuncName()@"took"@Time);
}

final function UpdateSpectatingCamera(float DeltaTime, out TViewTarget OutVT)
{
	OutVT.Target.GetActorEyesViewPoint(OutVT.POV.Location, OutVT.POV.Rotation);
}


/** debug-only camera, used to see character's face for testing FaceFX and stuff */
function UpdateDebugFaceCam(Pawn P, float DeltaTime, out TViewTarget OutVT)
{
	local RacePawn RP;
	local vector HeadPos, CamPos, Unused;
	local rotator Rot;

	RP = RacePawn(P);

	if (RP != None)
	{
		RP.GetActorEyesViewPoint(Unused, Rot);

		HeadPos = RP.Mesh.GetBoneLocation('b_Head', 0);
		CamPos = HeadPos + vector(Rot) * 48.f;

		Rot = rotator(HeadPos - CamPos);

		OutVT.POV.Location = CamPos;
		OutVT.POV.Rotation = Rot;
	}
}

/**
 * Player Update Camera code
 */
final function PlayerUpdateCamera(Pawn P, float DeltaTime, out TViewTarget OutVT)
{
	// give pawn chance to hijack the camera and do it's own thing.
	if( P.CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV) )
	{
		//`log("P.CalcCamera returned TRUE somehow"@P@P.Controller);
		ApplyCameraModifiers(DeltaTime, OutVT.POV);
		return;
	}
	else
	{
		UpdateCameraMode(P, DeltaTime);
		PlayerUpdateCameraScript(P, DeltaTime, OutVT);

		// prints local space camera offset (from pawnloc).  useful for determining camera anim test offsets
		//`log("***"@((OutVT.POV.Location - P.Location) << P.Controller.Rotation));
	}
}

/** internal camera updating code */
final protected function PlayerUpdateCameraScript(Pawn P, float DeltaTime, out TViewTarget OutVT)
{
	local RacePawn RP;
	local RacePawn EffectiveRP;
	local RacePlayerController RPC;
	local vector		HijackedCamLoc;
	local rotator	HijackedCamRot;
	local bool		bHijacked;
	local rotator	IdealCameraOriginRot;
	local vector		IdealCameraOrigin;
	local vector ActualCameraOrigin;
	local rotator ActualCameraOriginRot;
	local vector IdealViewOffset;
	local float TurnInterpPct;
	local float TurnAngle;
	local float InterpSpeed;
	local vector ActualViewOffset;
	local bool bDirectLook;
	local bool bMoving;	
	local rotator BaseRot;													
	local int StopDirectLookThresh;
	local bool bLockedToViewTarget;
	local float PitchInterpSpeed, YawInterpSpeed, RollInterpSpeed, Scale;
	local vector DesiredCamLoc;
	local vector WorstLocation;
	local bool bSingleRayPenetrationCheck;
	local Pawn TempP;
	local RacePawn TempRP, HiddenRP;
	local bool bInsideTargetCylinder;
	local float CylRadSq, HalfCylHeight, CylMaxZ, CylMinZ;

	RPC = RacePlayerController(P.Controller);

	// this can legitimately be NULL if the target isn't a RacePawn (such as a vehicle or turret)
	RP = RacePawn(P);

	// "effective" RP is the RacePawn that's connected to the camera, be it 
	// in a vehicle or turret or whatever.
	EffectiveRP = RP;
	if (EffectiveRP == none)
	{
		if (Vehicle(P) != none)
		{
			EffectiveRP = RacePawn(Vehicle(P).Driver);
		}
	}

	// Get pos/rot for camera origin (base location where offsets, etc are applied from)

	if ( CurrentCamMode.bCanHijackCamera && CurrentCamMode.HijackCamera(P, DeltaTime, HijackedCamLoc, HijackedCamRot, self) )
	{
		bHijacked = TRUE;
	}
	
	if (CurrentCamMode.LockedToViewTarget(P))
	{
		P.GetActorEyesViewPoint(IdealCameraOrigin, IdealCameraOriginRot);

		if (RP != none)
		{
			if (CurrentCamMode == RaceCamDeath)
			{
				// note that in death cam, we stick with the results of getactoreyesviewpoint
				IdealCameraOriginRot = RP.PCRotationWhenKilled;
				IdealCameraOriginRot.Pitch = 0;
			}
		}
		//DrawDebugSphere(IdealCameraOrigin, 15, 16, 255, 0, 255, FALSE);
	}
	else
	{
		// use this camera's rotation
		IdealCameraOriginRot = Rotation;
		IdealCameraOrigin = P.GetPawnViewLocation();
	}

	// First, update the camera origin.
	// This is the point in world space where camera offsets are applied.
	// We apply lazy cam on this location, so we can have a smooth / slow interpolation speed there,
	// And a different speed for offsets.
	if( bResetCameraInterpolation )
	{
		// if this is the first time we update, then do not interpolate.
		ActualCameraOrigin = IdealCameraOrigin;
	}
	else
	{
		// Apply lazy cam effect to the camera origin point
		ActualCameraOrigin	= VInterpTo(LastActualCameraOrigin, IdealCameraOrigin, DeltaTime, CurrentCamMode.LazyCamSpeed);
	}
	LastActualCameraOrigin = ActualCameraOrigin;

	// smooth out CameraOriginRot if necessary
	if (RPC != none && RPC.bIsSpectating && !bResetCameraInterpolation)
	{
		ActualCameraOriginRot = RInterpTo(LastActualCameraOriginRot, IdealCameraOriginRot, DeltaTime, SpectatorCameraRotInterpSpeed);
	}
	else
	{
		ActualCameraOriginRot = IdealCameraOriginRot;
	}
	LastActualCameraOriginRot = ActualCameraOriginRot;

	// do any pre-viewoffset focus point adjustment
	//UpdateFocusPoint(P);

	// doing adjustment before view offset application in order to rotate around target
	// also doing before origin offset application to avoid pops in cover
	// using last viewoffset here, since we have a circular dependency with the data.  focus point adjustment
	// needs viewoffset, but viewoffset is dependent on results of adjustment.  this introduces a bit of error,
	// but I believe it won't be noticeable.
	//AdjustToFocusPointKeepingTargetInView(P, DeltaTime, ActualCameraOrigin, ActualCameraOriginRot, LastViewOffset);

	// Get the camera-space offset from the camera origin
	IdealViewOffset = CurrentCamMode.GetViewOffset(P, DeltaTime, ActualCameraOriginRot);
	//`CamDLog("IdealViewOffset out of GetViewOffset is "@IdealViewOffset);

	// get the desired FOV
	OutVT.POV.FOV = GetRaceCamFOV(P);

	OutVT.POV.Rotation = ActualCameraOriginRot;

	// handle camera turns
	if ( bDoingACameraTurn )
	{
		TurnCurTime += DeltaTime;

		TurnInterpPct = (TurnCurTime - TurnDelay) / TurnTotalTime;
		TurnInterpPct = Clamp(TurnInterpPct, 0.f, 1.f);
		if (TurnInterpPct == 1.f)
		{
			// turn is finished!
			EndTurn();
		}

		// swing as a square, feels better for 180s
		TurnAngle = TurnStartAngle + ( class'ARaceGenericDefines'.static.FInOutRamp(TurnInterpPct, 2) * (TurnEndAngle - TurnStartAngle) );

		// rotate view orient
		OutVT.POV.Rotation.Yaw += TurnAngle;
		LastPostCamTurnYaw = OutVT.POV.Rotation.Yaw;
	}

	//
	// View relative offset
	//

	// Interpolate FOV
	if( !bResetCameraInterpolation && CurrentCamMode.BlendTime > 0.f )
	{
		InterpSpeed = 1.f / CurrentCamMode.BlendTime;
		OutVT.POV.FOV = FInterpTo(LastCamFOV, OutVT.POV.FOV, DeltaTime, InterpSpeed);
	}
	LastCamFOV = OutVT.POV.FOV;

	// View relative offset.
	if( !bResetCameraInterpolation && CurrentCamMode.BlendTime > 0.f )
	{
		InterpSpeed = 1.f / CurrentCamMode.BlendTime;
		ActualViewOffset = VInterpTo(LastViewOffset, IdealViewOffset, DeltaTime, InterpSpeed);
	}
	else
	{
		ActualViewOffset = IdealViewOffset;
	}
	LastViewOffset = ActualViewOffset;
	//`CamDLog("ActualViewOffset post interp is "@ActualViewOffset);

	// dealing with special optional behaviors
	if (!bDoingACameraTurn)
	{
		// are we in direct look mode?
		bDirectLook = CurrentCamMode.UseDirectLookMode(P);	
		if ( bDirectLook )
		{
			// the 50 is arbitrary, but any real motion is way above this
			bMoving = (VSizeSq(P.Velocity) > 50.f) ? TRUE : FALSE;
			BaseRot = (bMoving) ? rotator(P.Velocity) : P.Rotation;

			if ( (DirectLookYaw != 0.f) || bDoingDirectLook )
			{
				// new goal rot
				BaseRot.Yaw = NormalizeRotAxis(BaseRot.Yaw + DirectLookYaw);
				OutVT.POV.Rotation = RInterpTo(OutVT.POV.Rotation, BaseRot, DeltaTime, DirectLookInterpSpeed);

				if (DirectLookYaw == 0.f)
				{
					StopDirectLookThresh = bMoving ? 1000 : 50;

					// interpolating out of direct look
					if ( Abs(OutVT.POV.Rotation.Yaw - BaseRot.Yaw) < StopDirectLookThresh )
					{
						// and we're done!
						bDoingDirectLook = FALSE;
					}
				}
				else
				{
					bDoingDirectLook = TRUE;
				}
			}
		}

		bLockedToViewTarget = CurrentCamMode.LockedToViewTarget(P);
		if ( !bLockedToViewTarget )
		{
			// handle following if necessary
			if ( (VSizeSq(P.Velocity) > 50.f) &&
				CurrentCamMode.ShouldFollowTarget(P, PitchInterpSpeed, YawInterpSpeed, RollInterpSpeed) )
			{
				if (CurrentCamMode.FollowingCameraVelThreshold > 0.f)
				{
					Scale = Min(1.f, (VSize(P.Velocity) / CurrentCamMode.FollowingCameraVelThreshold));
				}
				else
				{
					Scale = 1.f;
				}

				PitchInterpSpeed *= Scale;
				YawInterpSpeed *= Scale;
				RollInterpSpeed *= Scale;

				BaseRot = rotator(P.Velocity);

				// doing this per-axis allows more aggressive pitch tracking, but looser yaw tracking
				OutVT.POV.Rotation = class'ARaceGenericDefines'.static.RInterpToWithPerAxisSpeeds(OutVT.POV.Rotation, BaseRot, DeltaTime, PitchInterpSpeed, YawInterpSpeed, RollInterpSpeed);
			}
		}
	}

	// apply viewoffset (in camera space)
	DesiredCamLoc = ActualCameraOrigin + class'ARaceGenericDefines'.static.LocalToWorld(ActualViewOffset, OutVT.POV.Rotation);
	
	// try to have a focus point in view
	//AdjustToFocusPoint(P, DeltaTime, DesiredCamLoc, OutVT.POV.Rotation);

	// Set new camera position
	OutVT.POV.Location = DesiredCamLoc;

	// cache this up, for potential later use
	LastPreModifierCameraRot = OutVT.POV.Rotation;

	// apply post processing modifiers
	ApplyCameraModifiers(DeltaTime, OutVT.POV);

	if ( !bHijacked )
	{
		//
		// find "worst" location, or location we will shoot the penetration tests from
		//
		WorstLocation = CurrentCamMode.GetCameraWorstCaseLoc(P);

		// conv to local space for interpolation
		WorstLocation = class'ARaceGenericDefines'.static.WorldToLocal((WorstLocation - P.Location), P.Rotation);

		if (!bResetCameraInterpolation)
		{
			WorstLocation = VInterpTo(LastWorstLocationLocal, WorstLocation, DeltaTime, WorstLocInterpSpeed);
		}
		LastWorstLocationLocal = WorstLocation;

		// rotate back to world space
		WorstLocation = class'ARaceGenericDefines'.static.LocalToWorld(WorstLocation, P.Rotation) + P.Location;

		//clock(Time);

		//
		// test for penetration
		//
		//DrawDebugSphere(WorstLocation, 4, 16, 255, 255, 0, FALSE);

		// adjust worst location origin to prevent any penetration
		if (CurrentCamMode.bValidateWorstLoc)
		{
			PreventCameraPenetration(P, IdealCameraOrigin, WorstLocation, DeltaTime, WorstLocBlockedPct, WorstLocPenetrationExtentScale, TRUE);
		}
		else
		{
			WorstLocBlockedPct = 0.f;
		}

		//DrawDebugSphere(WorstLocation, 16, 10, 255, 255, 0, FALSE);

		// adjust final desired camera location, to again, prevent any penetration
		bSingleRayPenetrationCheck = ( !CurrentCamMode.bDoPredictiveAvoidance || ( RP != none && RP.CustomCameraAnimProperties.bSingleRayPenetrationOnly && RP.IsPlayingCustomCameraAnim()) ) ? TRUE : FALSE;
		PreventCameraPenetration(P, WorstLocation, OutVT.POV.Location, DeltaTime, PenetrationBlockedPct, PenetrationExtentScale, bSingleRayPenetrationCheck);

		//unclock(Time);
		//`log("preventcamerapenetration time:"@Time);
		if ( PCOwner.IsLocalPlayerController() )
		{
			TempP = PCOwner.WorldInfo.PawnList;
			while( TempP != none )												
			//for (APawn *TempP = GWorld->GetWorldInfo()->PawnList; TempP != NULL; TempP = TempP->NextPawn)
			{
				TempRP = RacePawn(TempP);
				if (TempRP != none)
				{
					if (TempRP.Health <= 0 || TempRP.bHidden || TempRP.bDeleteMe)
					{
						// if not alive, we must'nt hide!
						HiddenActors.RemoveItem(TempRP);
					}
					else
					{
						TempRP.GetCameraNoRenderCylinder(CylRadSq, HalfCylHeight, (TempRP==EffectiveRP), HiddenActors.Find(TempRP)!=-1);
						CylRadSq *= CylRadSq;

						if ( VSizeSq2D(OutVT.POV.Location - TempRP.Location) < CylRadSq )
						{
							CylMaxZ = TempRP.Location.Z + HalfCylHeight;
							CylMinZ = TempRP.Location.Z - HalfCylHeight;

							if ( (OutVT.POV.Location.Z < CylMaxZ) && (OutVT.POV.Location.Z > CylMinZ) )
							{
								bInsideTargetCylinder = TRUE;
							}
						}

						// only want to see this when transition state, not every frame
						if (bInsideTargetCylinder)
						{
							HiddenActors.AddItem(TempRP);
						}
						else
						{
							HiddenActors.RemoveItem(TempRP);
						}

						// debug
						//{
						//	FVector CylTop = TempWPEffectiveLoc;
						//	CylTop.Z += HalfCylHeight;
						//	FVector CylBottom = TempWPEffectiveLoc;
						//	CylBottom.Z -= HalfCylHeight;
						//	DrawDebugCylinder(CylTop, CylBottom, appSqrt(CylRadSq), 16, 255, 255, 0, FALSE);
						//}
					}
				}
				TempP = TempP.NextPawn;
			}

			//`log("data"@WP@CylRadSq@HalfCylHeight@CylMaxZ@CylMinZ@"camloc"@OutVT.POV.Location@VSizeSq2D(OutVT.POV.Location - WP.Location));
		}
	}
	else
	{
		OutVT.POV.Location = HijackedCamLoc;
		OutVT.POV.Rotation = HijackedCamRot;

		if ( RP != none && PCOwner.Pawn == none && (Role == ROLE_Authority) )
		{
			// this guy gets hidden
			HiddenActors.AddItem(RP);
			HiddenRP = RP;
		}

		if ( PCOwner.IsLocalPlayerController() )
		{
			TempP = PCOwner.WorldInfo.PawnList;
			while( TempP != none )												
			//for (APawn *TempP = GWorld->GetWorldInfo()->PawnList; TempP != NULL; TempP = TempP->NextPawn)
			{
				if (TempP != HiddenRP)
				{
					// don't unhide the guy we want hidden (eg the player)
					TempRP = RacePawn(TempP);
					if (TempRP != none)
					{
						HiddenActors.RemoveItem(TempRP);
					}
				}
				TempP = TempP.NextPawn;
			}
		}
	}
}

/**
 * Initiates a camera rotation.
 * @param		StartAngle		Starting Yaw offset (in Rotator units)
 * @param		EndAngle		Finishing Yaw offset (in Rotator units)
 * @param		TimeSec			How long the rotation should take
 * @param		DelaySec		How long to wait before starting the rotation
 */
final simulated function BeginTurn(int StartAngle, int EndAngle, float TimeSec, optional float DelaySec, optional bool bAlignTargetWhenFinished)
{
	bDoingACameraTurn = TRUE;
	TurnTotalTime = TimeSec;
	TurnDelay = DelaySec;
	TurnCurTime = 0.f;
	TurnStartAngle = StartAngle;
	TurnEndAngle = EndAngle;
	bTurnAlignTargetWhenFinished = bAlignTargetWhenFinished;
}

/**
 * Stops a camera rotation.
 */
final simulated function EndTurn()
{
	// todo: port from native
}

/**
 * Adjusts a camera rotation.  Useful for situations where the basis of the rotation
 * changes.
 * @param	AngleOffset		Yaw adjustment to apply (in Rotator units)
 */
final function AdjustTurn(int AngleOffset)
{
	TurnStartAngle += AngleOffset;
	TurnEndAngle += AngleOffset;
}

///** Create a new camera focus point structure from code */
//simulated function CamFocusPoint MakeFocusPoint
//(
//	Vector			InLocation,
//	Vector2d		InterpSpeedRange,
//	Vector2d		InFocusFOV,
//	optional bool	InbAlwaysFocus,
//	optional bool	InbAdjustCamera,
//	optional bool	InbIgnoreTrace,
//	optional Name	InFocusBoneName
//)
//{
//	local CamFocusPoint	NewFocusPoint;

//	NewFocusPoint.FocusLoc			= InLocation;
//	NewFocusPoint.InterpSpeedRange	= InterpSpeedRange;
//	NewFocusPoint.InFocusFOV		= InFocusFOV;
//	NewFocusPoint.bAlwaysFocus		= InbAlwaysFocus;
//	NewFocusPoint.bAdjustCamera		= InbAdjustCamera;
//	NewFocusPoint.bIgnoreTrace		= InbIgnoreTrace;
//	NewFocusPoint.FocusBoneName		= InFocusBoneName;

//	return NewFocusPoint;
//}

/** Set a new camera focus point */
//simulated function SetFocusPoint( CamFocusPoint NewFocusPoint )
//{
//	// if replacing a bAdjustCamera focus point with a !bAdjustCamera focus point,
//	// do a clear first so the !bAdjustCamera one will work relative to where the first
//	// one was at the time of the interruption
//	// &fixme, bFocusPoiuntSet reliable?  can be interpolating afterwards?
//	if ( ((LastPitchAdjustment != 0) || (LastYawAdjustment != 0))
//		// && !NewFocusPoint.bAdjustCamera
//		 && FocusPoint.bAdjustCamera )
//	{
//		ClearFocusPoint(TRUE);
//	}

//	bFocusPointSet			= TRUE;
//	FocusPoint				= NewFocusPoint;
//	LastFocusChangeTime		= WorldInfo.TimeSeconds;
//	LastFocusPointLoc		= FocusPoint.FocusLoc;
//}

//final simulated protected function UpdateFocusLocation(vector NewFocusLoc)
//{
//	if (FocusPoint.FocusLoc != NewFocusLoc)
//	{
//		LastFocusChangeTime	= WorldInfo.TimeSeconds;
//		FocusPoint.FocusLoc = NewFocusLoc;
//		LastFocusPointLoc = NewFocusLoc;
//	}
//}

/** Clear focus point */
//simulated function ClearFocusPoint(optional bool bLeaveCameraRotation)
//{
//	local RacePlayerController RPC;

//	bFocusPointSet = FALSE;

//	// note that bAdjustCamera must be true to leave camera rotation.
//	// otherwise, there will be a large camera jolt as the player and camera
//	// realign themselves (which they have to do, since the camera rotated away from
//	// the player)
//	if ( bLeaveCameraRotation && FocusPoint.bAdjustCamera )
//	{
//		LastPitchAdjustment = 0;
//		LastYawAdjustment = 0;
//		LeftoverPitchAdjustment = 0;
//		if (PCOwner != None)
//		{
//			PCOwner.SetRotation(LastPreModifierCameraRot);
//		}
//	}

//	RPC = RacePlayerController(PCOwner);
//	if (RPC != None)
//	{
//		RPC.CameraLookAtFocusActor = None;
//	}
//}


//final simulated protected event UpdateFocusPoint( Pawn P )
//{
//	local vector	FocusLocation;
//	local WarPC		WPC;
//	local WarPawn	WP;
//	local SkeletalMeshComponent ComponentIt;

//	WP = WarPawn(P);
//	WPC = WarPC(P.Controller);

//	if (bDoingACameraTurn)
//	{
//		ClearFocusPoint();
//	}
//	else if ( (CurrentCamMode == WarCamDeath) && (WP != None) && (WP.Mesh != None) )
//	{
//		// note these take priority over other pois
//		SetFocusPoint( MakeFocusPoint(WP.GetDeathCamLookatPos(), vect2d(6,6), vect2d(2,2), , , TRUE) );
//	}
//	// FIXMELAURENT -- move this out of this function, so the actor is responsible for setting/unsetting focus points
//	else if( WPC != None && WPC.CameraLookAtFocusActor != None )
//	{
//		// If controller has a focus point set, just update the location
//		FocusLocation = WPC.CameraLookAtFocusActor.Location;
//		if( FocusPoint.FocusBoneName != 'None' )
//		{
//			foreach WPC.CameraLookAtFocusActor.ComponentList(class'SkeletalMeshComponent',ComponentIt)
//			{
//				FocusLocation = ComponentIt.GetBoneLocation(FocusPoint.FocusBoneName);
//				break;
//			}
//		}
//		UpdateFocusLocation(FocusLocation);
//	}
//	else if( WP != None && WP.IsDoingASpecialMove() && WP.SpecialMoveClasses[WP.SpecialMove].default.bCameraFocusOnPawn )
//	{
//		// if evading, or doing a special move, then track head of player.
//		SetFocusPoint( MakeFocusPoint(WP.Mesh.GetBoneLocation(WP.NeckBoneName), vect2d(3,3), vect2d(8,11)) );
//	}
//	else
//	{
//		// Otherwise, clear focus point
//		ClearFocusPoint();
//	}

//}

///** use this if you keep the same focus point, but move the camera basis around underneath it */
//simulated function AdjustFocusPointInterpolation(rotator Delta)
//{
//	Delta = Normalize(Delta);
//	LastYawAdjustment -= Delta.Yaw;
//	LastPitchAdjustment -= Delta.Pitch;
//}

//simulated final protected native function vector GetEffectiveFocusLoc(const out vector CamLoc, const out vector FocusLoc, const out vector ViewOffset);

/**
 * This is a simplified version of AdjustToFocusPoint that keeps the camera target in frame.
 * CamLoc passed in should be the camera origin, before the view offset is applied.
 */
//final simulated native protected function AdjustToFocusPointKeepingTargetInView( Pawn P, float DeltaTime, out vector CamLoc, out rotator CamRot, const out vector ViewOffset );


/**
 * Adjust Camera location and rotation, to try to have a FocusPoint (point in world space) in view.
 * Also supports blending in and out from that adjusted location/rotation.
 *
 * @param	P			Pawn currently being viewed.
 * @param	DeltaTime	seconds since last rendered frame.
 * @param	CamLoc		(out) cam location
 * @param	CamRot		(out) cam rotation
 */
//final simulated native protected function AdjustToFocusPoint( Pawn P, float DeltaTime, out vector CamLoc, out rotator CamRot );

/**
 * Evaluates the current situation and returns the camera mode
 * that best matches, ie targeting/crouched/etc.
 *
 * @return 	  	new camera mode to use
 */
final simulated function Race_CameraMode FindBestCameraMode(Pawn P)
{
	local Race_CameraMode	NewCamMode;
	//local bool			bShouldZoom, bGrenade;
	local RacePawn		RP;

	if ( P.Health <= 0 )
	{
		// target pawn is dead
		NewCamMode = RaceCamDeath;
	}
	else if( RaceVehicle(P) != None )
	{
		// target pawn is a vehicle
		NewCamMode = RaceCamVehicle;
	}
	else
	{
		RP = RacePawn(P);
		if (RP != None)
		{
			NewCamMode = (CustomDefaultCamMode != None) ? CustomDefaultCamMode : RaceCamDefault;			
		}
	}

	if (NewCamMode == None)
	{
		`log("Could not find appropriate camera mode, using CamDefault!");
		NewCamMode = RaceCamDefault;
	}

	return NewCamMode;
}


/**
 * Update Camera modes. Pick Best, handle transitions
 */
final protected function UpdateCameraMode( Pawn P, float fDeltaTime )
{
	local Race_CameraMode	NewCamMode;

	// Pick most suitable camera mode
	NewCamMode = FindBestCameraMode(P);
//	if( NewCamMode == None )
//	{
//		`CamDLog("FindBestCameraMode returned none!!");
//	}

	// set new racecam
	if( NewCamMode != CurrentCamMode )
	{
		if( CurrentCamMode != None )
		{
			CurrentCamMode.OnBecomeInActive( P, self );
		}
		if( NewCamMode != None )
		{
			NewCamMode.OnBecomeActive( P, self );
		}

		CurrentCamMode = NewCamMode;
	}
}

/**
* Returns desired camera fov.
*/
final simulated function float GetRaceCamFOV(Pawn CameraTargetPawn)
{
	local float FOV;

	FOV = bUseForcedCamFOV ? ForcedCamFOV : CurrentCamMode.GetDesiredFOV(CameraTargetPawn);

	return FOV;
}

/**
 * Handles traces to make sure camera does not penetrate geometry and tries to find
 * the best location for the camera.
 * Also handles interpolating back smoothly to ideal/desired position.
 *
 * @param	WorstLocation		Worst location (Start Trace)
 * @param	DesiredLocation		Desired / Ideal position for camera (End Trace)
 * @param	DeltaTime			Time passed since last frame.
 * @param	DistBlockedPct		percentage of distance blocked last frame, between WorstLocation and DesiredLocation. To interpolate out smoothly
 * @param	CameraExtentScale	Scale camera extent. (box used for collision)
 * @param	bSingleRayOnly		Only fire a single ray.  Do not send out extra predictive feelers.
 */
final function PreventCameraPenetration(Pawn P, const out vector WorstLocation, out vector DesiredLocation, float DeltaTime, out float DistBlockedPct, float CameraExtentScale, optional bool bSingleRayOnly)
{	
	local float HardBlockedPct, SoftBlockedPct,NewBlockPct,DistBlockedPctThisFrame,Weight ;
	local vector BaseRay, BaseRayLocalFwd, BaseRayLocalRight, BaseRayLocalUp, RayTarget, RotatedRay, CheckExtent, outHitLoc, outHitNorm;
	local int NumRaysToShoot, RayIdx;
	local PenetrationAvoidanceFeeler Feeler;
	local array<Actor> pHitList;
	local TraceHitInfo outHitInfo;
	local actor outActor, currentActor;
	local int i;	
	local Pawn ThePawn;

	HardBlockedPct = DistBlockedPct;
	SoftBlockedPct = DistBlockedPct;
	BaseRay = DesiredLocation - WorstLocation;	
	GetAxes(rotator(BaseRay), BaseRayLocalFwd, BaseRayLocalRight, BaseRayLocalUp);
	//CheckDist = VSize(BaseRay);
	DistBlockedPctThisFrame = 1.f;
		
	NumRaysToShoot = (bSingleRayOnly) ? Min(1, PenetrationAvoidanceFeelers.Length) : PenetrationAvoidanceFeelers.Length;

	for (RayIdx=0; RayIdx<NumRaysToShoot; ++RayIdx)
	{		
		Feeler = PenetrationAvoidanceFeelers[RayIdx];

		// calc ray target		
		RotatedRay = BaseRay >> Feeler.AdjustmentRot;			
		RayTarget = WorstLocation + RotatedRay;

		// cast for world and pawn hits separately.  this is so we can safely ignore the 
		// camera's target pawn
		
		CheckExtent = Feeler.Extent * CameraExtentScale;
		
		if ( (Feeler.PawnWeight >= 1.f) || (Feeler.WorldWeight >= 1.f) )
		{
			// for weight 1.0 rays, do multiline check to make sure we hits we throw out aren't
			// masking real hits behind (these are important rays).
			foreach P.TraceActors( class'Actor', outActor, outHitLoc, outHitNorm, RayTarget, WorstLocation, CheckExtent,  outHitInfo )
			{
				pHitList[pHitList.Length] = outActor;
			}			
		}
		else
		{
			// for weight 1.0 rays, do multiline check to make sure we hits we throw out aren't
			// masking real hits behind (these are important rays).

			outActor = P.Trace( outHitLoc, outHitNorm, RayTarget, WorstLocation,true,CheckExtent,outHitInfo );

			if( outActor != none )
			{
				pHitList[pHitList.Length] = outActor;
			}
		}

		//DrawDebugLine(WorstLocation, RayTarget, Feeler.Weight*255, 255, 0, TRUE);
		//DrawDebugCoordinateSystem(WorstLocation, BaseRay.Rotation(), 32.f, TRUE);
		//DrawDebugLine(WorstLocation, WorstLocation + BaseRay, Feeler.Weight*255, 255, 0, TRUE);

		for( i=0 ; i<pHitList.Length; i++ )
		{
			currentActor = pHitList[i];
			if (currentActor != none)
			{				
				// experimenting with not colliding with pawns
				ThePawn = Pawn(currentActor);
				if( ThePawn != none )
				{
					if ( P != none && (P.DrivenVehicle == ThePawn) )
					{
						// ignore hits on the vehicle we're driving
						continue;
					}

					// * ignore ragdoll hits (can still his the collision cylinder, which is bad)
					
					if ( ThePawn.Physics == PHYS_RigidBody )
					{
						continue;
					}	

					Weight = Feeler.PawnWeight;
				}
				else
				{
					// ignore KActorSpawnables, since they're only used for small, inconsequential things (for now anyway)
					if ( KActorSpawnable(currentActor) != none )
					{
						continue;
					}

					Weight = Feeler.WorldWeight;
				}

				NewBlockPct	= 1.0f;
				NewBlockPct += (1.f - NewBlockPct) * (1.f - Weight);
				DistBlockedPctThisFrame = Min(NewBlockPct, DistBlockedPctThisFrame);
			}
		}

		if (RayIdx == 0)
		{
			// don't interpolate toward this one, snap to it
			HardBlockedPct = DistBlockedPctThisFrame;
		}
		else
		{
			SoftBlockedPct = DistBlockedPctThisFrame;
		}
	}

	if (DistBlockedPct < DistBlockedPctThisFrame)
	{
		// interpolate smoothly out
		DistBlockedPct = DistBlockedPct + DeltaTime / PenetrationBlendOutTime * (DistBlockedPctThisFrame - DistBlockedPct);
	}
	else
	{
		if (DistBlockedPct > HardBlockedPct)
		{
			DistBlockedPct = HardBlockedPct;
		}
		else if (DistBlockedPct > SoftBlockedPct)
		{
			// interpolate smoothly in
			DistBlockedPct = DistBlockedPct - DeltaTime / PenetrationBlendInTime * (DistBlockedPct - SoftBlockedPct);
		}
	}

	if( DistBlockedPct < 1.f ) 
	{
		DesiredLocation	= WorstLocation + (DesiredLocation - WorstLocation) * DistBlockedPct;
	}
}


/**
 * Give Cams a chance to change player view rotation
 */
function ProcessViewRotation(float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot)
{
	if( CurrentCamMode != None )
	{
		CurrentCamMode.ProcessViewRotation(DeltaTime, ViewTarget.Target, out_ViewRotation, out_DeltaRot);
	}
}

/**
* Sets the new color scale
*/
simulated function SetColorScale( vector NewColorScale )
{
	if( bEnableColorScaling == TRUE )
	{
		// set the default color scale
		bEnableColorScaling = TRUE;
		ColorScale = NewColorScale;
		bEnableColorScaleInterp = false;
	}
}

/**
 * Begin using this camera mode as the default (noncover, nontargeting) camera mode.
 */
simulated function StartCustomDefaultCameraMode(EAltDefaultCameraModes Mode)
{
	switch (Mode)
	{
		default:
			CustomDefaultCamMode = None;
	}
}

/**
 * Stop using this camera mode as the default mode.
 */
simulated function ClearCustomDefaultCameraMode()
{
	CustomDefaultCamMode = None;
}

///**
// * @param BloodEmitter If None, remove any blood.  If set, remove only that blood.
// */
//simulated function RemoveCameraBlood(Emit_CameraBlood BloodEmitter)
//{
//	if (CameraBloodEmitter == BloodEmitter)
//	{
//		CameraBloodEmitter = None;
//	}
//}

//simulated function ClearCameraBlood()
//{
//	if (CameraBloodEmitter != None)
//	{
//		CameraBloodEmitter.Destroy();
//		CameraBloodEmitter = none;
//	}
//}

defaultproperties
{
	PenetrationBlendOutTime=0.15f
	PenetrationBlendInTime=0.1f
	PenetrationBlockedPct=1.f
	PenetrationExtentScale=1.f

	WorstLocPenetrationExtentScale=1.f
	WorstLocInterpSpeed=8

	bResetCameraInterpolation=TRUE	// set to true by default, so first frame is never interpolated

	DefaultFOV=70.f

	OriginOffsetInterpSpeed=8

	Focus_BackOffStrength=0.33f
	Focus_StepHeightAdjustment= 64
	Focus_MaxTries=4
	Focus_FastAdjustKickInTime=0.5

	bDoingACameraTurn=FALSE
	bCamDebug=FALSE

	DirectLookInterpSpeed=6.f
	SpectatorCameraRotInterpSpeed=14.f

	// ray 0 is the main ray
	PenetrationAvoidanceFeelers(0)=(AdjustmentRot=(Pitch=0,Yaw=0,Roll=0),WorldWeight=1.f,PawnWeight=1.f,Extent=(X=14,Y=14,Z=14))

	// horizontally offset
	PenetrationAvoidanceFeelers(1)=(AdjustmentRot=(Pitch=0,Yaw=3072,Roll=0),WorldWeight=0.75f,PawnWeight=0.75f,Extent=(X=0,Y=0,Z=0))
	PenetrationAvoidanceFeelers(2)=(AdjustmentRot=(Pitch=0,Yaw=-3072,Roll=0),WorldWeight=0.75f,PawnWeight=0.75f,Extent=(X=0,Y=0,Z=0))
	PenetrationAvoidanceFeelers(3)=(AdjustmentRot=(Pitch=0,Yaw=6144,Roll=0),WorldWeight=0.5f,PawnWeight=0.5f,Extent=(X=0,Y=0,Z=0))
	PenetrationAvoidanceFeelers(4)=(AdjustmentRot=(Pitch=0,Yaw=-6144,Roll=0),WorldWeight=0.5f,PawnWeight=0.5f,Extent=(X=0,Y=0,Z=0))

	// vertically offset
	PenetrationAvoidanceFeelers(5)=(AdjustmentRot=(Pitch=3640,Yaw=0,Roll=0),WorldWeight=1.f,PawnWeight=1.f,Extent=(X=0,Y=0,Z=0))
	PenetrationAvoidanceFeelers(6)=(AdjustmentRot=(Pitch=-3640,Yaw=0,Roll=0),WorldWeight=0.5f,PawnWeight=0.5f,Extent=(X=0,Y=0,Z=0))
}

