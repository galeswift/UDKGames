// extend UIAction if this action should be UI Kismet Action instead of a Level Kismet Action
class SeqAct_AddVector extends SeqAct_SetSequenceVariable;

var vector VectorA, VectorB, Result;

event Activated()
{
	Super.Activated();
	PublishLinkedVariableValues();
	Result = VectorA + VectorB;
	PopulateLinkedVariableValues();
}

defaultproperties
{
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Vector',LinkDesc="VectorA",PropertyName=VectorA)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="VectorB",PropertyName=VectorB)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Result",bWriteable=true,PropertyName=Result)

	ObjName="Add Vector"
	ObjCategory="Math"
}
