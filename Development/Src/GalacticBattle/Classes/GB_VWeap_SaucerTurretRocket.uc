/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class GB_VWeap_SaucerTurretRocket extends GB_VWeap_SaucerTurretBase
		HideDropDown;

var int RocketBurstSize;
var float RocketBurstInterval;
var int RemainingRockets;

simulated function FireAmmunition()
{
	if (CurrentFireMode == 0)
	{
		// Use ammunition to fire
		ConsumeAmmo( CurrentFireMode );

		RemainingRockets = RocketBurstSize;
		ActuallyFire();

		if (AIController(Instigator.Controller) != None)
		{
			AIController(Instigator.Controller).NotifyWeaponFired(self,CurrentFireMode);
		}
	}
}

simulated function ActuallyFire()
{
	RemainingRockets--;

	// if this is the local player, play the firing effects
	PlayFiringSound();

	`log(" Spaned Projectile was "$	ProjectileFire() );

	if ( RemainingRockets > 0 )
	{
		SetTimer(RocketBurstInterval, false, 'ActuallyFire');
	}

}
/*
 * Create the projectile, but also increment the flash count for remote client effects.
 */
simulated function Projectile ProjectileFire()
{
	local Projectile Result;

	Result = Super.ProjectileFire();

//	DrawDebugSphere( Result.Location, 40, 20, 255, 255, 100, true );

	`log(" Physical Fire Start Loc is "$Result.Location );
	return Result;
}


defaultproperties
{
	RocketBurstSize=4
	RocketBurstInterval=0.15
	WeaponFireTypes(0)=EWFT_Projectile
	FireInterval(0)=2.0
	WeaponFireSnd[0]=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_Fire_Cue'
	FireTriggerTags=(TurretRocketMF,TurretRocketMF,TurretRocketMF)

	WeaponProjectiles(0)=class'GBProj_SaucerRocket'
	VehicleClass=class'GB_SaucerLarge'
}
