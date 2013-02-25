// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAct_SetAcceleration extends SequenceAction;

var() Vector AccelerationDir;
var() float  AccelerationMag;
/** If TRUE given Acceleration is relative to actor rotation. Otherwise, Acceleration is in world space. */
var() bool	bAccelerationRelativeToActorRotation;


/**
 * Called when this event is activated.
 */
event Activated()
{
	local int i;
	local vector A;
	Super.Activated();

	PublishLinkedVariableValues();

	for( i=0 ; i<Targets.Length; i++ )
	{
		if( Actor(Targets[i]) != none )
		{
			A = normal(AccelerationDir) * AccelerationMag;
			if( bAccelerationRelativeToActorRotation )
			{
				A = A >> Actor(Targets[i]).Rotation;
			}

			Actor(Targets[i]).Acceleration = A;
		}
	}
}


defaultproperties
{
	ObjName="Set Acceleration"
	ObjCategory="Actor"
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Acceleration Dir",PropertyName=AccelerationDir)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Float',LinkDesc="Acceleration Mag",PropertyName=AccelerationMag)
}
