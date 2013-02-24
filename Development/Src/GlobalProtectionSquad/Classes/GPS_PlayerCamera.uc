class GPS_PlayerCamera extends GamePlayerCamera;

protected function GameCameraBase FindBestCameraType(Actor CameraTarget)
{
	return ThirdPersonCam;
}

defaultproperties
{
	ThirdPersonCameraClass=class'GPS_ThirdPersonCamera'
}
