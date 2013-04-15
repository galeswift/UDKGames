class GPS_Pickup extends Trigger;

/* If true, this pickup will reward the player immediately as opposed to the end of the mission */
var bool bRewardImmediately;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);

	
}

DefaultProperties
{
	bRewardImmediately=true
}
