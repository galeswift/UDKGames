/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class GB_VWeap_SaucerTurretShock extends GB_VWeap_SaucerTurretBase
		HideDropDown;


simulated function Projectile ProjectileFire()
{
	local UTProj_LeviathanShockBall ShockBall;

	ShockBall = UTProj_LeviathanShockBall(Super.ProjectileFire());
	if (ShockBall != None)
	{
		ShockBall.InstigatorWeapon = self;
		AimingTraceIgnoredActors[AimingTraceIgnoredActors.length] = ShockBall;
	}
	return ShockBall;
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponProjectiles(0)=class'UTProj_LeviathanShockBall'
	FireInterval(0)=0.5
	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	FireTriggerTags=(TurretShockMF)
	VehicleClass=class'UTVehicle_Leviathan_Content'
}
