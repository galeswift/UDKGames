class PT_PC extends UDKPlayerController;


state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local PT_Game PTGame;

		GetAxes(Rotation,X,Y,Z);
		
		PTGame = PT_Game(WorldInfo.Game);
		//DrawDebugLine(Pawn.Location, Pawn.Location + X*500, 255, 100, 100, false);
		//DrawDebugLine(Pawn.Location, Pawn.Location + Y*500, 100, 255, 100, false);
		//DrawDebugLine(Pawn.Location, Pawn.Location + Z*500, 100, 100, 255, false);

		Pawn.Acceleration = PlayerInput.aStrafe * X + PlayerInput.aForward*Z;
		Pawn.Acceleration = Pawn.AccelRate * Normal(Pawn.Acceleration);

		if ( Pawn.Acceleration == vect(0,0,0) )
		{
			if( PTGame != none && PTGame.MainCamera != none )
			{
				Pawn.Velocity = PTGame.MainCamera.Velocity;
			}
			else 
			{
				Pawn.Velocity = vect(0,0,0);
			}
		}

		// Update rotation.
		UpdateRotation( DeltaTime );

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
		else
			ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
	}

	event BeginState(Name PreviousStateName)
	{
		Pawn.SetPhysics(PHYS_Flying);
	}
}

function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
	return Pawn.Rotation;
}

function UpdateRotation( float DeltaTime )
{
	SetRotation(Pawn.Rotation);
}

/**
* return whether viewing in first person mode
*/
function bool UsingFirstPersonCamera()
{
	return false;
}

DefaultProperties
{
}
