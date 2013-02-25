class SeqAct_TraceEx extends SequenceAction;

var Actor HitObject;
var vector HitLocation;
var float Distance;
event Activated()
{
	
	local PlayerController	P;
	local vector CameraLoc;
	local rotator CameraRot;
	local vector HitNormal;

	super.Activated();
	
	ForEach GetWorldInfo().LocalPlayerControllers(class'PlayerController', P)
	{
		P.GetPlayerViewPoint(CameraLoc, CameraRot);
	}

	PublishLinkedVariableValues();
	HitObject = GetWorldInfo().Trace(HitLocation, HitNormal, CameraLoc + vector(CameraRot) * Distance, CameraLoc, true,,,1);
	PopulateLinkedVariableValues();
}

DefaultProperties
{
	ObjName="TraceEx"
	ObjCategory="Misc"

	VariableLinks.Empty
	VariableLinks(0)=(LinkDesc="HitObject",ExpectedType=class'SeqVar_Object',bWriteable=TRUE,PropertyName=HitObject)
	VariableLinks(1)=(LinkDesc="Distance",ExpectedType=class'SeqVar_Float',bWriteable=TRUE,PropertyName=Distance)
	VariableLinks(2)=(LinkDesc="HitLoc",ExpectedType=class'SeqVar_Vector',bWriteable=TRUE,PropertyName=HitLocation)

	OutputLinks(0)=(LinkDesc="Not Obstructed")
	OutputLinks(1)=(LinkDesc="Obstructed")
}
