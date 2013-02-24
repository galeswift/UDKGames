/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class GB_VWeap_SaucerTurretBeam extends GB_VWeap_SaucerTurretBase
		HideDropDown;

defaultproperties
{
	WeaponFireTypes(0)=EWFT_InstantHit

	BulletWhip=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_WhipCue'
	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	FireInterval(0)=+0.30
	Spread(0)=0.0
	bInstantHit=true
	AimError=600

	InstantHitDamage(0)=35
	InstantHitMomentum(0)=60000.0
	ShotCost(0)=0

	DefaultImpactEffect=(ParticleTemplate=ParticleSystem'VH_Hellbender.Effects.P_VH_Hellbender_PrimeAltImpact',Sound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue')

	FireTriggerTags=(TurretBeamMF_L,TurretBeamMF_R)

	InstantHitDamageTypes(0)=class'UTDmgType_LeviathanBeam'
	VehicleClass=class'GB_SaucerLarge'
}
