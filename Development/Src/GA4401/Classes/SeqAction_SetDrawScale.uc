// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAction_SetDrawScale extends SequenceAction;

var() Vector DrawScaleVect;
var() float  DrawScaleFloat;

/**
 * Called when this event is activated.
 */
event Activated()
{
	local int i;

	Super.Activated();

	PublishLinkedVariableValues();

	for( i=0 ; i<Targets.Length; i++ )
	{
		if( Actor(Targets[i]) != none )
		{
			Actor(Targets[i]).SetDrawScale( DrawScaleFloat );
			Actor(Targets[i]).SetDrawScale3D( DrawScaleVect );
		}
	}
}


defaultproperties
{
	ObjName="Set DrawScale"
	ObjCategory="Actor"
	DrawScaleFloat=1.0f
	DrawScaleVect=(X=1.0,Y=1.0,Z=1.0)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="DrawScale Vector",PropertyName=DrawScaleVect)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Float',LinkDesc="DrawScale Float",PropertyName=DrawScaleFloat)
}
