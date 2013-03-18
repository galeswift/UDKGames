class GPS_Attachment_BeamGun extends UTAttachment_LinkGun;

simulated function UpdateBeam(byte FireModeNum)
{
	local byte RealFireModeNum;
	// the weapon sets a FiringMode of 2 instead of 1 when using altfire on a teammate (so team color it)
	// FiringMode == 3 when using altfire (not on a teammate) while others linked up to this gun
	RealFireModeNum = (FireModeNum >= 2) ? byte(1) : FireModeNum;

	Super.UpdateBeam(FireModeNum);

	BeamEmitter[RealFireModeNum].SetColorParameter('BeamColor', GPS_Weap_Beam(PawnOwner.Weapon).BeamColor);
}

DefaultProperties
{
	MuzzleFlashPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Primary_MF'
	MuzzleFlashAltPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF'

	BeamTemplate[0]=ParticleSystem'GPS_FX.Effects.P_WP_BeamGun'
	BeamSockets[0]=MussleFlashSocket02
}
