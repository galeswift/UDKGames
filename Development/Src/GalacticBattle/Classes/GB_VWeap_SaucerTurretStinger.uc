/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */

class GB_VWeap_SaucerTurretStinger extends GB_VWeap_SaucerTurretBase
		HideDropDown;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	FireInterval(0)=+0.1
	Spread(0)=0.0675
	InstantHitDamage(0)=40
	InstantHitDamageTypes(0)=class'UTDmgType_LeviathanShard'
	WeaponFireSnd[0]=SoundCue'A_Weapon_Stinger.Weapons.A_Weapon_Stinger_FireAltCue'
	FireTriggerTags=(TurretStingerMF)
	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_PrimeAltImpact',Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')
	VehicleClass=class'UTVehicle_Leviathan_Content'
	bFastRepeater=true
	bInstantHit=true
	AimError=600
}
