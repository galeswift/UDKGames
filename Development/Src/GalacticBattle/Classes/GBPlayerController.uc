//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GBPlayerController extends UTPlayerController;

/** Stubbed out so that we always load our pawn's default family info */
function LoadCharacterFromProfile(UTProfileSettings Profile)
{
}

// Player walking on planets
state PlayerSphereWalking
{
ignores SeePlayer, HearNoise, Bump;

	event bool NotifyHitWall(vector HitNormal, actor HitActor)
	{
		`log(self@"NotifyHitWall");
		Pawn.SetPhysics(PHYS_Spider);
		Pawn.SetBase(HitActor, HitNormal);
		return true;
	}

	event NotifyFallingHitWall(vector HitNormal, actor Wall)
	{
		`log(self@"NotifyFallingHitWall");
		Pawn.SetPhysics(PHYS_Spider);
		Pawn.SetBase(Wall, HitNormal);
		return;
	}

	// if spider mode, update rotation based on floor
	function UpdateRotation( float DeltaTime )
	{
		local rotator ViewRotation;
		local vector MyFloor, CrossDir, FwdDir, OldFwdDir, OldX, RealFloor;

		if( GBPawn(Pawn) == none )
		{
			super.UpdateRotation(DeltaTime);
			return;
		}

		//if ( (Pawn.Base == None) || (Pawn.Floor == vect(0,0,0)) )
		//   MyFloor = vect(0,0,1);
		//else
			MyFloor = -GBPawn(Pawn).GetGravityDir();

		if ( VSizeSq(MyFloor-OldFloor) > 0.0001f )
		{
			// smoothly change floor
			RealFloor = MyFloor;
			MyFloor = Normal(6*DeltaTime * MyFloor + (1 - 6*DeltaTime) * OldFloor);
			if ( (RealFloor Dot MyFloor) > 0.999 )
				MyFloor = RealFloor;

			// translate view direction
			CrossDir = Normal(RealFloor Cross OldFloor);
			FwdDir = CrossDir Cross MyFloor;
			OldFwdDir = CrossDir Cross OldFloor;
			ViewX = MyFloor * (OldFloor Dot ViewX)
						+ CrossDir * (CrossDir Dot ViewX)
						+ FwdDir * (OldFwdDir Dot ViewX);
			ViewX = Normal(ViewX);

			ViewZ = MyFloor * (OldFloor Dot ViewZ)
						+ CrossDir * (CrossDir Dot ViewZ)
						+ FwdDir * (OldFwdDir Dot ViewZ);
			ViewZ = Normal(ViewZ);
			OldFloor = MyFloor;
			ViewY = Normal(MyFloor Cross ViewX);

			//`log(self@"UpdateRotation, ViewX:"@ViewX@"ViewY:"@ViewY@"ViewZ:"@ViewZ);
		}

		if ( (PlayerInput.aTurn != 0) || (PlayerInput.aLookUp != 0) )
		{
			// adjust Yaw based on aTurn
			if ( PlayerInput.aTurn != 0 )
				ViewX = Normal(ViewX + 2 * ViewY * Sin(0.0005*DeltaTime*PlayerInput.aTurn));

			// adjust Pitch based on aLookUp
			if ( PlayerInput.aLookUp != 0 )
			{
				OldX = ViewX;
				ViewX = Normal(ViewX + 2 * ViewZ * Sin(0.0005*DeltaTime*PlayerInput.aLookUp));
				ViewZ = Normal(ViewX Cross ViewY);

				// bound max pitch
				if ( (ViewZ Dot MyFloor) < 0.707   )
				{
					OldX = Normal(OldX - MyFloor * (MyFloor Dot OldX));
					if ( (ViewX Dot MyFloor) > 0)
						ViewX = Normal(OldX + MyFloor);
					else
						ViewX = Normal(OldX - MyFloor);

					ViewZ = Normal(ViewX Cross ViewY);
				}
			}

			// calculate new Y axis
			ViewY = Normal(MyFloor Cross ViewX);
		}

		ViewRotation =  OrthoRotation(ViewX,ViewY,ViewZ);
		SetRotation(ViewRotation);
		ViewShake(deltaTime);
		Pawn.FaceRotation(ViewRotation, deltaTime );
	}

	event bool NotifyLanded(vector HitNormal, Actor FloorActor)
	{
		`log(self@"NotifyLanded");
		Pawn.SetPhysics(PHYS_Spider);
		return bUpdating;
	}

	event NotifyPhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		if ( NewVolume.bWaterVolume )
			GotoState(Pawn.WaterMovementState);
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		Pawn.Acceleration = NewAccel;

		if( bPressedJump )
		{
			Pawn.DoJump( bUpdating );
			bPressedJump = false;
		}
	}

	function PlayerMove( float DeltaTime )
	{
		local vector NewAccel;
		local rotator OldRotation, ViewRotation;
		local bool    bSaveJump;

		GroundPitch = 0;
		ViewRotation = Rotation;

		// Update rotation.
		SetRotation(ViewRotation);
		OldRotation = Rotation;
		UpdateRotation( DeltaTime );

		// Update acceleration.
		NewAccel = PlayerInput.aForward*Normal(ViewX - OldFloor * (OldFloor Dot ViewX)) + PlayerInput.aStrafe*ViewY;
		NewAccel = Pawn.AccelRate * Normal(NewAccel);
		// if falling, make sure we have acceleration so notifyhitwall is called
		if( GBPawn(Pawn) != none && Pawn.Physics == PHYS_Falling )
		{
			Pawn.Acceleration += GBPawn(Pawn).GetGravityDir()*0.01f;
		}

		if ( bPressedJump && Pawn.CannotJumpNow() )
		{
			bSaveJump = true;
			bPressedJump = false;
		}
		else
			bSaveJump = false;

		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		else
			ProcessMove(DeltaTime, NewAccel, DCLICK_None, OldRotation - Rotation);
		bPressedJump = bSaveJump;
	}

	event BeginState(Name PreviousStateName)
	{
		OldFloor = vect(0,0,1);
		GetAxes(Rotation,ViewX,ViewY,ViewZ);
		`log(self@"Begin Spider, ViewX:"@ViewX@"ViewY:"@ViewY@"ViewZ:"@ViewZ);
		DoubleClickDir = DCLICK_None;
		Pawn.ShouldCrouch(false);
		bPressedJump = false;
		if (Pawn.Physics != PHYS_Falling)
			Pawn.SetPhysics(PHYS_Spider);
		GroundPitch = 0;
		Pawn.bCrawler = true;
		Pawn.SetCollisionSize(Pawn.Default.CylinderComponent.CollisionHeight, Pawn.Default.CylinderComponent.CollisionHeight);
	}

	event EndState(Name NextStateName)
	{
		GroundPitch = 0;
		if ( Pawn != None )
		{
			Pawn.SetCollisionSize(Pawn.Default.CylinderComponent.CollisionRadius, Pawn.Default.CylinderComponent.CollisionHeight);
			Pawn.ShouldCrouch(false);
			Pawn.bCrawler = Pawn.Default.bCrawler;
		}
	}
}

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	super.DisplayDebug(HUD, out_YL, out_YPos);

	HUD.Canvas.SetDrawColor(255,0,0);
	HUD.Canvas.DrawText("Pawn.Floor"@Pawn.Floor@"OldFloor"@OldFloor@"LastGravityDir:"@GBPawn(Pawn).LastGravityDir);
	out_YPos += out_YL;
	HUD.Canvas.DrawText("ViewX:"@ViewX@"ViewY:"@ViewY@"ViewZ:"@ViewZ);
	out_YPos += out_YL;
	HUD.Canvas.DrawText("Controller"@Rotation@"Pawn"@Pawn.Rotation);
	out_YPos += out_YL;
}

DefaultProperties
{
	OldFloor=(z=1)
	// we want to get the hit wall notification when falling (for landing upside down)
	bNotifyFallingHitWall=true
	MinHitWall=-100.0f
}