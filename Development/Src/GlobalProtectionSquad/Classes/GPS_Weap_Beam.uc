class GPS_Weap_Beam extends GPS_Weap_Base
	abstract;

DefaultProperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	FiringStatesArray(0)=WeaponBeamFiring
	BeamSockets[0]=MuzzleFlashSocket02
	BeamTemplate[0]=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Altbeam'
	BeamPreFireAnim(0)=WeaponAltFireStart
	BeamFireAnim(0)=WeaponAltFire
	BeamPostFireAnim(0)=WeaponAltFireEnd

	// Damage is calculated off of firing mode 1
	InstantHitDamage(1)=300
	InstantHitDamageTypes(0)=class'UTDmgType_LinkBeam'
	MuzzleFlashPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Primary'
	MuzzleFlashAltPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_MF_Beam'
}
