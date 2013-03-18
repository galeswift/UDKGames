class GPS_Weap_Beam_02 extends GPS_Weap_Beam;

var float InterpProgress;
simulated function UpdateBeam(float DeltaTime)
{
	Super.UpdateBeam(DeltaTime);
	InterpProgress +=DeltaTime/3.0f;
	
	if(InterpProgress >= 1.0f )
	{
		InterpProgress = 0.0f;
	}
	BeamColor.R = Lerp(0,255,InterpProgress);
	BeamColor.B = Lerp(0,255,InterpProgress);
}

DefaultProperties
{
	WeaponRange=5000
	BeamColor=(R=10, G=100, B=10)
}
