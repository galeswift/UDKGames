class GPS_Weap_SuperBeam extends GPS_Weap_InstantHit;

/** How big the beam should be */
var vector BeamScale;

/** How long it takes to charge up this beam */
var float BeamDuration;

simulated function InstantFire()
{
	if (Role == ROLE_Authority)
	{
		SetFlashLocation(Instigator.GetWeaponStartTraceLocation() + vector(GetAdjustedAim(Instigator.GetWeaponStartTraceLocation())) * GetTraceRange());
	}
}


/**
  * returns true if should pass trace through this hitactor
  */
simulated static function bool PassThroughDamage(Actor HitActor)
{
	return HitActor.IsA('GPS_GameCrowdAgent');
}


// Lock the player's input and movement while this weapon is firing
simulated state WeaponFiring
{
	simulated function BeginState(name PreviousStateName)
	{
		// Update the fire interval for this beam
		FireInterval[CurrentFireMode] = BeamDuration;
		Super.BeginState(PreviousStateName);

		if(PlayerController(Instigator.Controller) != none )
		{
			PlayerController(Instigator.Controller).ClientIgnoreMoveInput(true);
			PlayerController(Instigator.Controller).ClientIgnoreLookInput(true);
		}

		SetTimer( FireInterval[CurrentFireMode] * 0.8f, false, 'ProcessHits');
	}
	simulated event EndState( Name NextStateName )
	{
		Super.EndState(NextStateName);
		if(PlayerController(Instigator.Controller) != none )
		{
			PlayerController(Instigator.Controller).ClientIgnoreMoveInput(false);
			PlayerController(Instigator.Controller).ClientIgnoreLookInput(false);
		}
	}

	function ProcessHits()
	{
		local int Idx;
		local vector			StartTrace, EndTrace;
		local Array<ImpactInfo>	ImpactList;

		// define range to use for CalcWeaponFire()
		StartTrace = Instigator.GetWeaponStartTraceLocation();
		EndTrace = StartTrace + vector(GetAdjustedAim(StartTrace)) * GetTraceRange();
		CalcWeaponFire(StartTrace, EndTrace, ImpactList);
		// Process all Instant Hits on local player and server (gives damage, spawns any effects).
		for (Idx = 0; Idx < ImpactList.Length; Idx++)
		{
			ProcessInstantHit(CurrentFireMode, ImpactList[Idx]);
		}
	}

	simulated function bool DoOverrideNextWeapon()
	{
		return true;
	}

	/**
	 * hook to override Previous weapon call.
	 */
	simulated function bool DoOverridePrevWeapon()
	{
		return true;
	}

}
DefaultProperties
{
	AttachmentClass=class'GPS_Attachment_SuperBeamGun'
	BaseClipCapacity=1
	BaseDamage=400
	BeamDuration=2.1
	InstantHitDamageTypes(0)=class'GPS_DmgType_FinalBeam'
	BeamScale=(X=10,Y=0,Z=0)
}
