class SeqAct_CombineStrings extends SeqAct_SetSequenceVariable;

var string LeftString, RightString, Target;
var() string SeparatorString;
event Activated()
{
	PublishLinkedVariableValues();
	Target = LeftString $ SeparatorString $ RightString;
	PopulateLinkedVariableValues();
}

defaultproperties
{
	ObjName="Combine Strings"
	SeparatorString=" "
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_String',LinkDesc="LeftString",PropertyName=LeftString)
	VariableLinks(1)=(ExpectedType=class'SeqVar_String',LinkDesc="RigtString",PropertyName=RightString)
	VariableLinks(2)=(ExpectedType=class'SeqVar_String',LinkDesc="Target",bWriteable=true,PropertyName=Target)
}