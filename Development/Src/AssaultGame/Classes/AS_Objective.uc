// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class AS_Objective extends SequenceAction;

enum EObjectiveType
{
	ASO_Capture,
	ASO_Destroy,
	ASO_Interact,
};

var() EObjectiveType ObjectiveType;

event Activated()
{
}

defaultproperties
{
	ObjName="AS_Objective"
	ObjCategory="AssaultGame Actions"
}
