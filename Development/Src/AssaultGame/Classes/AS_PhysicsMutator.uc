class AS_PhysicsMutator extends UTMutator;

function InitMutator( string Options, out string ErrorMessage )
{
	super.InitMutator( options, ErrorMessage );
	WorldInfo.RBPhysicsGravityScaling = 0.1;
}

function bool CheckReplacement( Actor Other )
{
	// return true to keep this actor
	return true;
}

DefaultProperties
{
	GroupNames[0]="GAMESPEED"
}