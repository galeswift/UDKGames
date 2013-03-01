class GPS_Weap_Beam extends GPS_Weap_Base
	abstract;

DefaultProperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	FiringStatesArray(0)=WeaponBeamFiring
	BeamSockets[0]=MuzzleFlashSocket02
	BeamTemplate[0]=ParticleSystem'GPS_FX.Effects.P_WP_BeamGun'
	BeamPreFireAnim(0)=WeaponAltFireStart
	BeamFireAnim(0)=WeaponAltFire
	BeamPostFireAnim(0)=WeaponAltFireEnd

	// Damage is calculated off of firing mode 1
	InstantHitDamage(1)=300
	InstantHitDamageTypes(0)=class'UTDmgType_LinkBeam'
	MuzzleFlashPSCTemplate=ParticleSystem'GPS_FX.Effects.P_WP_BeamGun'
	MuzzleFlashAltPSCTemplate=ParticleSystem'GPS_FX.Effects.P_WP_BeamGun'
	AttachmentClass=class'GPS_Attachment_BeamGun'

	WeaponRange=2000
}
