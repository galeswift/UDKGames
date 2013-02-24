class ARaceGenericDefines extends Object;

/** Supported viewport configurations. */
enum ERaceCam_ViewportTypes
{
	CVT_16to9_Full,
	CVT_16to9_VertSplit,
	CVT_16to9_HorizSplit,
	CVT_4to3_Full,
	CVT_4to3_HorizSplit,
	CVT_4to3_VertSplit,
};


struct ViewOffsetData
{
	/** View point offset for high player view pitch */
	var() vector OffsetHigh;
	/** View point offset for medium (horizon) player view pitch */
	var() vector OffsetMid;
	/** View point offset for low player view pitch */
	var() vector OffsetLow;
};

/** Shake start offset parameter */
enum ERaceShakeParam
{
	ERSP_OffsetRandom,	// Start with random offset (default)
	ERSP_OffsetZero,		// Start with zero offset
};

/** Shake vector params */
struct RaceShakeParams
{
	var() ERaceShakeParam	X, Y, Z;

	var transient const byte Padding;
};

struct RaceScreenShakeStruct
{
	/** Time in seconds to go until current screen shake is finished */
	var()	float	TimeToGo;
	/** Duration in seconds of current screen shake */
	var()	float	TimeDuration;

	/** view rotation amplitude */
	var()	vector	RotAmplitude;
	/** view rotation frequency */
	var()	vector	RotFrequency;
	/** view rotation Sine offset */
	var		vector	RotSinOffset;
	/** rotation parameters */
	var()	RaceShakeParams	RotParam;

	/** view offset amplitude */
	var()	vector	LocAmplitude;
	/** view offset frequency */
	var()	vector	LocFrequency;
	/** view offset Sine offset */
	var		vector	LocSinOffset;
	/** location parameters */
	var()	RaceShakeParams	LocParam;

	/** FOV amplitude */
	var()	float	FOVAmplitude;
	/** FOV frequency */
	var()	float	FOVFrequency;
	/** FOV Sine offset */
	var		float	FOVSinOffset;
	/** FOV parameters */
	var()	ERaceShakeParam	FOVParam;

	/**
	 * Unique name for this shake.  Only 1 instance of a shake with a particular
	 * name can be playing at once.  Subsequent calls to add the shake will simply
	 * restart the existing shake with new parameters.  This is useful for animating
	 * shake parameters.
	 */
	var()	Name		ShakeName;

	/** True to use TargetingDampening multiplier while player is targeted, False to use global defaults (see TargetingAlpha). */
	var()	bool		bOverrideTargetingDampening;

	/** Amplitude multiplier to apply while player is targeting.  Ignored if bOverrideTargetingDampening == FALSE */
	var()	float		TargetingDampening;

	structdefaultproperties
	{
		TimeDuration=1.f
		RotAmplitude=(X=100,Y=100,Z=200)
		RotFrequency=(X=10,Y=10,Z=25)
		LocAmplitude=(X=0,Y=3,Z=5)
		LocFrequency=(X=1,Y=10,Z=20)
		FOVAmplitude=2
		FOVFrequency=5
		ShakeName=""
	}
};

static function vector WorldToLocal(vector WorldVect, rotator SystemRot)
{
	//return FRotationMatrix(SystemRot).Transpose().TransformNormal( WorldVect );
    return WorldVect << SystemRot;
}

static function vector LocalToWorld(vector LocalVect, rotator SystemRot)
{
	//return FRotationMatrix(SystemRot).TransformNormal( LocalVect );
	return LocalVect >> SystemRot;
}

/**
* Smoothing function for interpolants.  Accelerates and decelerates along an
* exponential curve.  
* @param	f		The float you want the ramp function applied to.
* @param	exp		Exponent of the ramp function.  Higher = sharper accel/decel.
* @return			The float after the ramp has been applied.
*/
static function float FInOutRamp(float f, float exp)
{
	if (f < 0.5f)
	{
		return ( 0.5f * ((2.f * f)**exp) );
	}
	else
	{
		return ( ( -0.5f * ( (2.f * (f-1.f))**exp) ) + 1 );
	}
}

/**
* Just like the regular RInterpTo(), but with per axis interpolation speeds specification
*/
static function rotator RInterpToWithPerAxisSpeeds( rotator Current, rotator Target, FLOAT DeltaTime, FLOAT PitchInterpSpeed, FLOAT YawInterpSpeed, FLOAT RollInterpSpeed )
{
	local rotator DeltaMove;

	// if DeltaTime is 0, do not perform any interpolation (Location was already calculated for that frame)
	if( DeltaTime == 0.f || Current == Target )
	{
		return Current;
	}

	// Delta Move, Clamp so we do not over shoot.
	DeltaMove = Normalize(Target - Current);

	DeltaMove.Pitch *= Clamp(DeltaTime * PitchInterpSpeed, 0.f, 1.f);
	DeltaMove.Yaw *= Clamp(DeltaTime * YawInterpSpeed, 0.f, 1.f);
	DeltaMove.Roll *= Clamp(DeltaTime * RollInterpSpeed, 0.f, 1.f);

	return Normalize(Current + DeltaMove);
}

DefaultProperties
{
}
