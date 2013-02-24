/**
 * Copyright © 1998-2006 Epic Games, Inc. All Rights Reserved.
 */
class Race_CameraModifier extends CameraModifier
	config(Camera) ;

/* Priority of this actor - determines where it is added in the modifier list
	0 = highest priority, 255 = lowest */
var	byte Priority;
/* This modifier can only be used exclusively - no modifiers of same priority allowed */
var bool bExclusive;
/* Alpha proceeds from 0 to 1 over this time */
var() float AlphaInTime;
/* Alpha proceeds from 1 to 0 over this time */
var() float AlphaOutTime;

/* Alpha of offset to apply */
var transient float Alpha;
var transient float TargetAlpha;


/**
 * Directly modifies variables in the camera actor
 *
 * @param	Camera		reference to camera actor we are modifiying
 * @param	DeltaTime	Change in time since last update
 * @param	OutPOV		current Point of View, to be updated.
 * @return	bool		TRUE if should STOP looping the chain, FALSE otherwise
 */
function bool ModifyCamera
(
		Camera	Camera,
		float	DeltaTime,
	out TPOV	OutPOV
)
{
	// If pending disable and fully alpha'd out, truly disable this modifier
	if( bPendingDisable && Alpha <= 0.0 )
	{
		super.DisableModifier();
	}

	return false;
}

/** Responsible for updating alpha
 *
 * @param	Camera		- Camera that is being updated
 * @param	DeltaTime	- Amount of time since last update
 */
function UpdateAlpha( Camera Camera, float DeltaTime )
{
	local float Time;

	TargetAlpha = GetTargetAlpha( Camera );

	// Alpha out
	if( TargetAlpha == 0.0 )
	{
		Time = AlphaOutTime;
	}
	else
	{
		// Otherwise, alpha in
		Time = AlphaInTime;
	}

	if( Time <= 0.0 )
	{
		Alpha = TargetAlpha;
	}
	else if( Alpha > TargetAlpha )
	{
		Alpha = FMax( Alpha - (DeltaTime * (1.0 / Time)), TargetAlpha );
	}
	else
	{
		Alpha = FMin( Alpha + (DeltaTime * (1.0 / Time)), TargetAlpha );
	}
}

function float GetTargetAlpha( Camera Camera )
{
	if( bPendingDisable )
	{
		return 0.0;
	}
	return 1.0;
}

/** Handles adding by priority and avoiding adding the same modifier twice
 *
 * @param	Camera	- Camera that is being modified
 */
function bool AddCameraModifier( Camera Camera )
{
	local int BestIdx, ModifierIdx;
	local Race_CameraModifier Modifier;

	// Make sure we don't already have this modifier in the list
	for( ModifierIdx = 0; ModifierIdx < Camera.ModifierList.Length; ModifierIdx++ )
	{
		if ( Camera.ModifierList[ModifierIdx] == Self )
		{
			return false;
		}
	}

	// Make sure we don't already have a modifier of this type
	for( ModifierIdx = 0; ModifierIdx < Camera.ModifierList.Length; ModifierIdx++ )
	{
		if ( Camera.ModifierList[ModifierIdx].Class == Class )
		{
			`log("AddCameraModifier found existing modifier in list, replacing with new one" @ self);
			// hack replace old by new (delete??)
			Camera.ModifierList[ModifierIdx] = Self;
			return true;
		}
	}

	// Look through current modifier list and find slot for this priority
	BestIdx = 0;

	for( ModifierIdx = 0; ModifierIdx < Camera.ModifierList.Length; ModifierIdx++ )
	{
		Modifier = Race_CameraModifier(Camera.ModifierList[ModifierIdx]);
		if( Modifier == None ) {
			continue;
		}

		// If priority of current index has passed or equaled ours - we have the insert location
		if( Priority <= Modifier.Priority )
		{
			// Disallow addition of exclusive modifier if priority is already occupied
			if( bExclusive && Priority == Modifier.Priority )
			{
				return false;
			}

			break;
		}

		// Update best index
		BestIdx++;
	}

	// Insert self into best index
	Camera.ModifierList.Insert( BestIdx, 1 );
	Camera.ModifierList[BestIdx] = self;

	// Save camera
	CameraOwner = Camera;

	//debug
	if( bDebug )
	{
		`log( "AddModifier"@BestIdx@self );
		for( ModifierIdx = 0; ModifierIdx < Camera.ModifierList.Length; ModifierIdx++ )
		{
			`log( Camera.ModifierList[ModifierIdx]@"Idx"@ModifierIdx@"Pri"@Race_CameraModifier(Camera.ModifierList[ModifierIdx]).Priority );
		}
		`log( "****************" );
	}


	return true;
}

/**
 *	Set pending disable - modifier will auto disable itself when alpha reaches zero
 */
function DisableModifier()
{
	//debug
	`Log( self@"DisableModifier-SetPending", bDebug );
	bPendingDisable = true;
}

defaultproperties
{
	Priority=127
	//debug
//	bDebug=true
}
