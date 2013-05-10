class SeqEvent_MouseInput extends SequenceEvent;

var Actor HitActor;
var Vector HitLocation;
var Vector HitNormal;
var Vector MouseWorldOrigin;
var Vector MouseWorldDirection;

event Activated()
{
	local MouseInterfaceInteractionInterface MouseInteractionInterface;

	// Type cast the originator to ensure that it is a mouse interaction interface
	MouseInteractionInterface = MouseInterfaceInteractionInterface(Originator);

	if (MouseInteractionInterface != None)
	{
		// Get the appropriate values so we can push them out when the event is activated
		MouseWorldOrigin = MouseInteractionInterface.GetMouseWorldOrigin();
		MouseWorldDirection = MouseInteractionInterface.GetMouseWorldDirection();
		HitLocation = MouseInteractionInterface.GetHitLocation();
		HitNormal = MouseInteractionInterface.GetHitNormal();
	}
}


/**
 * Return the version number for this class.  Child classes should increment this method by calling Super then adding
 * a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
 * link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
 * Super.GetObjClassVersion() should be incremented by 1.
 *
 * @return	the version number for this specific class.
 */
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}

defaultproperties
{
	ObjName="Mouse Input"
	ObjCategory="Input"
	
	bPlayerOnly=false
	MaxTriggerCount=0

	OutputLinks.Empty
	OutputLinks.Add((LinkDesc="Left Pressed"))
	OutputLinks.Add((LinkDesc="Left Held"))
	OutputLinks.Add((LinkDesc="Left Released"))
	OutputLinks.Add((LinkDesc="Right Pressed"))
	OutputLinks.Add((LinkDesc="Right Held"))
	OutputLinks.Add((LinkDesc="Right Released"))
	OutputLinks.Add((LinkDesc="Middle Pressed"))
	OutputLinks.Add((LinkDesc="Middle Released"))
	OutputLinks.Add((LinkDesc="Scroll Up"))
	OutputLinks.Add((LinkDesc="Scroll Down"))
	OutputLinks.Add((LinkDesc="Mouse Over"))
	OutputLinks.Add((LinkDesc="Mouse Out"))


	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="HitLocation",bWriteable=true,PropertyName=HitLocation)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Vector',LinkDesc="HitNormal",bWriteable=true,PropertyName=HitNormal)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Vector',LinkDesc="MouseWorldOrigin",bWriteable=true,PropertyName=MouseWorldOrigin)
	VariableLinks(4)=(ExpectedType=class'SeqVar_Vector',LinkDesc="MouseWorldDirection",bWriteable=true,PropertyName=MouseWorldDirection)
	VariableLinks(5)=(ExpectedType=class'SeqVar_Object',LinkDesc="Clicked Actor",bWriteable=true,PropertyName=HitActor)
}