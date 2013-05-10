class SeqAct_GetDirection extends SeqAct_SetSequenceVariable;

var() vector VectorA, VectorB;
var() bool bFlattenZ;
var vector Result;
var float Distance;

event Activated()
{
	Super.Activated();
	PublishLinkedVariableValues();

	Distance = VSize(VectorA-VectorB);
	if( bFlattenZ )
	{
		Result = normal(vect(1,1,0) * (VectorA - VectorB));
	}
	else
	{
		Result = normal(VectorA - VectorB);
	}
	PopulateLinkedVariableValues();
}


DefaultProperties
{
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Target",PropertyName=VectorA)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Source",PropertyName=VectorB)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Float',LinkDesc="Distance",PropertyName=Distance)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Result",bWriteable=true,PropertyName=Result)

	ObjName="Get Direction"
	ObjCategory="Math"
}
