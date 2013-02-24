class GPS_PlayerController extends UTPlayerController;

/**
 * Reset Camera Mode to default
 */
event ResetCameraMode()
{
	SetCameraMode('ThirdPerson');
}
DefaultProperties
{
	CameraClass=class'GPS_PlayerCamera'
}
