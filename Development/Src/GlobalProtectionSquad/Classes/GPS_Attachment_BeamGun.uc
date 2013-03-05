class GPS_Attachment_BeamGun extends UTAttachment_LinkGun;

DefaultProperties
{
	MuzzleFlashPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Primary_MF'
	MuzzleFlashAltPSCTemplate=ParticleSystem'WP_LinkGun.Effects.P_FX_LinkGun_3P_Beam_MF'

	TeamBeamEndpointTemplates[0]=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_Red'
	TeamBeamEndpointTemplates[1]=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_Blue'
	TeamBeamEndpointTemplates[2]=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact'
	HighPowerBeamEndpointTemplate=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Beam_Impact_Gold'

	BeamTemplate[0]=ParticleSystem'GPS_FX.Effects.P_WP_BeamGun'
	BeamSockets[0]=MussleFlashSocket02
}
