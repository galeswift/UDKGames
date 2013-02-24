class AS_AdvancedGunProjectile extends UTProj_Rocket;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{   
	local Pawn TargetPawn;
	local Pawn OldPawn;
	local Controller OldController;

	TargetPawn = Pawn(Other);
	OldController = Instigator.Controller;
	OldPawn = Instigator;
	
	if( TargetPawn == None )
	{
		Shutdown();
		return;
	}

	if( TargetPawn != None )
	{
		// detach TargetPawn from its controller and kill its controller.
		TargetPawn.DetachFromController( TRUE );

		// detach player from current pawn and possess targetpawn
		if( Instigator != None )
		{			
			Instigator.DetachFromController();
		}

		OldController.Possess(TargetPawn, FALSE);

		// Spawn default controller for our ex-pawn (AI)
		if( OldPawn != None )
		{
			OldPawn.SpawnDefaultController();
		}
	}
	
	Shutdown();
}

DefaultProperties
{
	Damage=0
}
