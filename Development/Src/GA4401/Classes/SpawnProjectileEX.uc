class SpawnProjectileEX extends SequenceAction;

/** Class of projectile to spawn */
var() class<Projectile> ProjectileClass;

var() Actor InstigatorActor;
var() vector SpawnLoc, TargetLoc, TargetDir;

event Activated()
{
	local Controller InstigatorController;
	local Pawn InstigatorPawn;

	local Projectile Proj;

	Super.Activated();
	//PublishLinkedVariableValues();

	// get the instigator
	if (InstigatorActor != none )
	{
		InstigatorController = Controller(InstigatorActor);
		if (InstigatorController != None)
		{
			InstigatorPawn = InstigatorController.Pawn;
		}
		else
		{
			InstigatorPawn = Pawn(InstigatorActor);
			if (InstigatorPawn != None)
			{
				InstigatorController = InstigatorPawn.Controller;
			}

		}
	}

	// spawn a projectile at the requested location and point it at the requested target
	Proj = GetWorldInfo().Spawn(ProjectileClass,InstigatorActor,, SpawnLoc);

	if (InstigatorController != None)
	{
		Proj.Instigator = InstigatorPawn;
		Proj.InstigatorController = InstigatorController;
	}

	if( TargetLoc != vect(0,0,0) )
	{
		Proj.Init(Normal(TargetLoc - SpawnLoc));
	}
	else
	{
		Proj.Init(TargetDir);
	}
}

defaultproperties
{
	bCallHandler=false
	ObjName="Spawn Projectile EX"
	VariableLinks.Empty()
	VariableLinks(0)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Spawn Location",PropertyName=SpawnLoc)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Target Location",PropertyName=TargetLoc)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Vector',LinkDesc="Target Direction",PropertyName=TargetDir)
	VariableLinks(3)=(ExpectedType=class'SeqVar_Object',LinkDesc="Instigator",PropertyName=InstigatorActor)
}
