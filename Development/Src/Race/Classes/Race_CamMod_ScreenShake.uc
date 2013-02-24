/**
 * Copyright © 1998-2006 Epic Games, Inc. All Rights Reserved.
 */
class Race_CamMod_ScreenShake extends Race_CameraModifier
	config(Camera);

/**
 * Race_CamMod_ScreenShake
 * Screen Shake Camera modifier
 *
 */

/** Active ScreenShakes array */
var		Array<RaceScreenShakeStruct>	Shakes;

/** Always active ScreenShake for testing purposes */
var()	RaceScreenShakeStruct			TestShake;

/** Alpha to use while targeting. */
var()	protected float				TargetingAlpha;

final function RemoveScreenShake(Name ShakeName)
{
	local int Idx;
	Idx = Shakes.Find('ShakeName',ShakeName);
	if (Idx != INDEX_NONE)
	{
		Shakes.Remove(Idx,1);
	}
}

/** Add a new screen shake to the list */
final function AddScreenShake( RaceScreenShakeStruct NewShake )
{
	local int ShakeIdx, NumShakes;

	NumShakes = Shakes.Length;

	// search for existng shake of same name
	if (NewShake.ShakeName != '')
	{
		for (ShakeIdx=0; ShakeIdx<NumShakes; ++ShakeIdx)
		{
			if (Shakes[ShakeIdx].ShakeName == NewShake.ShakeName)
			{
				// found matching shake, reinit with new params!
				Shakes[ShakeIdx] = InitializeShake(NewShake);
				return;
			}
		}
	}

	// Initialize new screen shake and add it to the list of active shakes
	Shakes[NumShakes] = InitializeShake( NewShake );
}

/** Initialize screen shake structure */
final function RaceScreenShakeStruct InitializeShake( RaceScreenShakeStruct NewShake )
{
	NewShake.TimeToGo	= NewShake.TimeDuration;

	if( !IsZero( NewShake.RotAmplitude ) )
	{
		NewShake.RotSinOffset.X		= InitializeOffset( NewShake.RotParam.X );
		NewShake.RotSinOffset.Y		= InitializeOffset( NewShake.RotParam.Y );
		NewShake.RotSinOffset.Z		= InitializeOffset( NewShake.RotParam.Z );
	}

	if( !IsZero( NewShake.LocAmplitude ) )
	{
		NewShake.LocSinOffset.X		= InitializeOffset( NewShake.LocParam.X );
		NewShake.LocSinOffset.Y		= InitializeOffset( NewShake.LocParam.Y );
		NewShake.LocSinOffset.Z		= InitializeOffset( NewShake.LocParam.Z );
	}

	if( NewShake.FOVAmplitude != 0 )
	{
		NewShake.FOVSinOffset		= InitializeOffset( NewShake.FOVParam );
	}

	return NewShake;
}

/** Initialize sin wave start offset */
final static function float InitializeOffset( ERaceShakeParam Param )
{
	Switch( Param )
	{
		case ERSP_OffsetRandom	: return FRand() * 2 * Pi;	break;
		case ERSP_OffsetZero		: return 0;					break;
	}

	return 0;
}

/**
 * ComposeNewShake
 * Take Screen Shake parameters and create a new ScreenShakeStruct variable
 *
 * @param	Duration			Duration in seconds of shake
 * @param	newRotAmplitude		view rotation amplitude (pitch,yaw,roll)
 * @param	newRotFrequency		frequency of rotation shake
 * @param	newLocAmplitude		relative view offset amplitude (x,y,z)
 * @param	newLocFrequency		frequency of view offset shake
 * @param	newFOVAmplitude		fov shake amplitude
 * @param	newFOVFrequency		fov shake frequency
 */
final function RaceScreenShakeStruct ComposeNewShake
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
	local RaceScreenShakeStruct	NewShake;

	NewShake.TimeDuration	= Duration;

	NewShake.RotAmplitude	= newRotAmplitude;
	NewShake.RotFrequency	= newRotFrequency;

	NewShake.LocAmplitude	= newLocAmplitude;
	NewShake.LocFrequency	= newLocFrequency;

	NewShake.FOVAmplitude	= newFOVAmplitude;
	NewShake.FOVFrequency	= newFOVFrequency;

	return NewShake;
}

/**
 * StartNewShake
 *
 * @param	Duration			Duration in seconds of shake
 * @param	newRotAmplitude		view rotation amplitude (pitch,yaw,roll)
 * @param	newRotFrequency		frequency of rotation shake
 * @param	newLocAmplitude		relative view offset amplitude (x,y,z)
 * @param	newLocFrequency		frequency of view offset shake
 * @param	newFOVAmplitude		fov shake amplitude
 * @param	newFOVFrequency		fov shake frequency
 */
function StartNewShake
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
	local RaceScreenShakeStruct	NewShake;

	// check for a shake abort
	if (Duration == -1.f)
	{
		Shakes.Length = 0;
	}
	else
	{
		NewShake = ComposeNewShake
		(
			Duration,
			newRotAmplitude,
			newRotFrequency,
			newLocAmplitude,
			newLocFrequency,
			newFOVAmplitude,
			newFOVFrequency
		);

		AddScreenShake( NewShake );
	}
}

/** Update a ScreenShake */
function UpdateScreenShake(float DeltaTime, out RaceScreenShakeStruct Shake, out TPOV OutPOV)
{
	// todo: port from native
}


function float GetTargetAlpha( Camera Camera )
{
	//local RacePawn RP;
	local float SuperAlpha;
	local float ThisAlpha;

	SuperAlpha = super.GetTargetAlpha(Camera);
	ThisAlpha = 1.f;

	//if (SuperAlpha > 0.f)
	//{
	//	RP = RacePawn(CameraOwner.PCOwner.Pawn);
	//	if  (RP != None)
	//	{
	//		if (RP.bIsTargeting)
	//		{
	//			ThisAlpha = TargetingAlpha;
	//		}
	//	}
	//}

	return FMin(SuperAlpha, ThisAlpha);
}


/** @see CameraModifer::ModifyCamera */
function bool ModifyCamera
(
		Camera	Camera,
		float	DeltaTime,
	out TPOV	OutPOV
)
{
	local int					i;
	local RaceScreenShakeStruct CurrentScreenShake;
//	local AmbientShakeVolume	ShakeVolume;

	// Update the alpha
	UpdateAlpha(Camera, DeltaTime);

	// Call super where modifier may be disabled
	super.ModifyCamera(Camera, DeltaTime, OutPOV);

	// If no alpha, exit early
	if( Alpha <= 0.f )
	{
		return FALSE;
	}

	// Update Screen Shakes array
	if( Shakes.Length > 0 )
	{
		for(i=0; i<Shakes.Length; i++)
		{
			// compiler won't let us pass individual elements of a dynamic array as the value for an out parm, so use a local
			CurrentScreenShake = Shakes[i];
			UpdateScreenShake(DeltaTime, CurrentScreenShake, OutPOV);
			Shakes[i] = CurrentScreenShake;
		}

		// Delete any obsolete shakes
		for(i=Shakes.Length-1; i>=0; i--)
		{
			if( Shakes[i].TimeToGo <= 0 )
			{
				Shakes.Remove(i,1);
			}
		}
	}
	// Update Test Shake
	UpdateScreenShake(DeltaTime, TestShake, OutPOV);

	// Update Ambient Shake Volumes
	//ForEach Camera.ViewTarget.Target.TouchingActors(class'AmbientShakeVolume', ShakeVolume)
	//{
	//	if( ShakeVolume.bEnableShake )
	//	{
	//		// Set TimeToGo, so it ends up scaling shake by 1x
	//		ShakeVolume.AmbientShake.TimeToGo = ShakeVolume.AmbientShake.TimeDuration + DeltaTime;
	//		// Update ambient shake
	//		UpdateScreenShake(DeltaTime, ShakeVolume.AmbientShake, OutPOV);
	//	}
	//}

	return FALSE;
}


/**
 * Play a camera shake in world space to all LOCAL players, with distance based attenuation.
 * @param InnerRadius		Inside this radius, apply full camerashake
 * @param OuterRadius		Outside this radius, apply no camerashake
 */
simulated static function PlayWorldCameraShake(RaceScreenShakeStruct Shake, Actor ShakeInstigator, vector Epicenter, float InnerRadius, float OuterRadius)
{
	local RacePlayerController						PC;
	local RaceScreenShakeStruct                 	ScaledShake;
	local Vector									POVLoc;
	local float										DistPct;

	if (ShakeInstigator != None)
	{
		foreach ShakeInstigator.LocalPlayerControllers(class'RacePlayerController', PC)
		{
			POVLoc = (PC.Pawn != None) ? PC.Pawn.Location : PC.Location;

			DistPct		= (VSize(Epicenter - POVLoc) - InnerRadius) / (OuterRadius - InnerRadius);
			DistPct = 1.f - FClamp(DistPct, 0.f, 1.f);
			DistPct *= DistPct;							// using square ramp, feels nice

			ScaledShake = Shake;

//			`log("Shake scaled by"@DistPct@ShakeInstigator@VSize(Epicenter - POVLoc));

			ScaledShake.RotAmplitude *= DistPct;
			ScaledShake.LocAmplitude *= DistPct;
			ScaledShake.FOVAmplitude *= DistPct;

			PC.PlayCameraShake(ScaledShake);
		}
	}
}

defaultproperties
{
	TargetingAlpha=0.5f
}
