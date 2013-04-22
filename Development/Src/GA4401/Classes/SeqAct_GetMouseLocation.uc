class SeqAct_GetMouseLocation extends SequenceAction;

/** The location of the mouse in the world itself */
var() editconst Vector Location;

// Location in the world, lined up with the screen
var() editconst Vector LocationOnScreen;

/**
 * Called when this event is activated.
 */
event Activated()
{
	local PlayerController PC;

	foreach GetWorldInfo().LocalPlayerControllers(class'PlayerController', PC )
	{
		Location = MouseInterfaceHUD(PC.myHUD).GetMouseWorldLocation();
		LocationOnScreen = MouseInterfaceHUD(PC.myHUD).CachedMouseWorldOrigin;
	}

	Super.Activated();
}

defaultproperties
{
	ObjName="Get Mouse Location"
	ObjCategory="Input"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Location",bWriteable=true,PropertyName=Location)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Location",bWriteable=true,PropertyName=LocationOnScreen)
}
