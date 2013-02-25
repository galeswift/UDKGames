class SeqAct_GetCameraInfo extends SequenceAction;

/** The location of the actor */
var() editconst Vector Location;
/** A normalized vector in the direction of the actor's rotation */
var() editconst	Vector RotationVector;
/** A vector that holds floating point versions of the FRotator rotation */
var() editconst	Vector CameraFacing;

/** The player that we want to get the camera info from */
var() Actor Player;

static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 1;
}

/**
 * Called when this event is activated.
 */
event Activated()
{
	local Controller	P;
	local vector CameraLoc;
	local rotator CameraRot;

	PublishLinkedVariableValues();

	ForEach GetWorldInfo().AllControllers(class'Controller', P)
	{
		if( Player == none || Player == P.Pawn )
		{
			P.GetPlayerViewPoint(CameraLoc, CameraRot);
			break;
		}
	}

	// Push out the location a bit so projectiles don't collide with the player

	RotationVector = vector(CameraRot);
	Location = CameraLoc + RotationVector * 72;
	CameraFacing = Location + RotationVector * 512;

	PopulateLinkedVariableValues();
	Super.Activated();
}

defaultproperties
{
	ObjName="Get Location and Rotation"
	ObjCategory="Camera"
	VariableLinks(0)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Location",bWriteable=true,PropertyName=Location)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Rotation Vector",bWriteable=true,PropertyName=RotationVector)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Camera Facing",bWriteable=true,PropertyName=CameraFacing)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Object',LinkDesc="Player",bWriteable=true,PropertyName=Player)
}

