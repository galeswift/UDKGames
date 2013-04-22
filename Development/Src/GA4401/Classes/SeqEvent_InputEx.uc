// extend UIEvent if this event should be UI Kismet Event instead of a Level Kismet Event
class SeqEvent_InputEx extends SeqEvent_Input;
/**
 * Called once this event is toggled via SeqAct_Toggle.
 */
event Toggled()
{
	bTrapInput = !bTrapInput;
}

defaultproperties
{
	ObjName="Key/Button Pressed EX"
	ObjCategory="Input"
}
