/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class GB_VWeap_SaucerTurretBase extends UTVehicleWeapon
	abstract;


/*********************************************************************************************
 * State WeaponFiring
 * This is the default Firing State.  It's performed on both the client and the server.
 *********************************************************************************************/
simulated state WeaponFiring
{
	/**
	 * We override BeginFire() to keep shield clicks from resetting the fire delay
	 */
	simulated function BeginFire( Byte FireModeNum )
	{
		if ( CheckZoom(FireModeNum) )
		{
			return;
		}

		Global.BeginFire(FireModeNum);
	}
}

defaultproperties
{
 	WeaponFireTypes(0)=EWFT_InstantHit
 	WeaponFireTypes(1)=EWFT_None

	AmmoDisplayType=EAWDS_BarGraph

	ShotCost(0)=0
	bInstantHit=true
	ShotCost(1)=0
	bFastRepeater=true
}
