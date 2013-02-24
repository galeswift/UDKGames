//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RacePawn extends UTPawn;

var rotator PCRotationWhenKilled;
var vector LocationWhenKilled;

struct CustomCameraAnimPropertiesStruct
{
	/**
	* true if the camera system should only do single-ray penetration checks while this
	* anim is playing.  basically disables predictive camera zooming.
	*/
	var bool bSingleRayPenetrationOnly;

	/**
	* true if the camera bone code apply the entirety of the camera bone motion to
	* the camera.  basically disables camera bone motion dampening, useful for special
	* camera moves.
	*/
	var bool bApplyFullMotion;

};

var		CustomCameraAnimPropertiesStruct		CustomCameraAnimProperties;

simulated function bool IsPlayingCustomCameraAnim()
{
	return false;
}

simulated function GetCameraNoRenderCylinder(out float CylRad, out float HalfCylHeight, bool IsViewTarget, bool IsHidden)
{
	// todo: copy from gears
}

DefaultProperties
{

}