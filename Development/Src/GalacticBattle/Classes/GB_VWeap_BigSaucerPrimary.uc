//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GB_VWeap_BigSaucerPrimary extends UTVehicleWeapon;

/** Crosshair variables */
var float AltCrosshairBounceInTime;
var float AltCrosshairBounceOutTime;
var int TargetRotYaw;

struct CHSlot
{
	var float u,v,ul,vl;
	var float xOfst,yOfst;
	var float gx,gy;
	var float FadeTime;
};

var CHSlot CrosshairSlots[16];


/** the amount of time the same target must be kept for the shot to go off */
var float PaintTime;

/** How long after the shot does it take to recharge (should be the time of the effect) */
var float RechargeTime;

/** units/sec player can move their aim and not reset the paint timer */
var float TargetSlack;
/** current target location */
var vector TargetLocation;

/** Ambient sound played while acquiring the target */
var SoundCue AcquireSound;

/** Energy related code */
var float CurrentEnergy;
var float MaxEnergy;
var float BeamFireCost;


/** Physics grabber code */
var()				float			HoldDistanceMin;
var()				float			HoldDistanceMax;
var()				float			ThrowImpulse;
var					float			SuckUpSpeed;
var					RB_Handle		PhysicsGrabber;
var					float			HoldDistance;
var					Quat			HoldOrientation;
var					UTPawn			GrabbedPawn;
var					GB_PawnGrabber		PawnGrabber;
replication
{
	if( bNetDirty )
		CurrentEnergy;
}

simulated function SendToFiringState( byte FireModeNum )
{
	// make sure fire mode is valid
	if( FireModeNum >= FiringStatesArray.Length )
	{
		WeaponLog("Invalid FireModeNum", "Weapon::SendToFiringState");
		return;
	}

	// Ignore a none fire type
	if( WeaponFireTypes[FireModeNum] == EWFT_None )
	{
		return;
	}
	else if( CurrentEnergy < BeamFireCost )
	{
		return;
	}

	// set current fire mode
	SetCurrentFireMode(FireModeNum);

	// Initialize the max range of the weapon used for aiming traces
	AimTraceRange = MaxRange();

	// Send our weapon into the correct state, but only for our primary weapon.
	if( FireModeNum == 0 )
	{
		GotoState(FiringStatesArray[FireModeNum]);
	}
}

/** Overridden so that we release our attached actor when we let go of the button */
simulated function StopFire(byte FireModeNum)
{
	local vector					StartShot, PokeDir;
	local Rotator					Aim;
	local PhysAnimTestActor			PATActor;

	Super.StopFire( FireModeNum );

	if ( Role < ROLE_Authority )
		return;


	// Poke them before letting go!
	if( FireModeNum == 1 && PhysicsGrabber.GrabbedComponent != none )
	{
		HoldDistance = default.HoldDistance;

		// Do ray check and grab actor
		StartShot	= Instigator.GetWeaponStartTraceLocation();
		Aim			= GetAdjustedAim( StartShot );
		PokeDir = Vector(Aim);

		PhysicsGrabber.GrabbedComponent.AddImpulse(PokeDir * ThrowImpulse, , PhysicsGrabber.GrabbedBoneName, true);

		PATActor = PhysAnimTestActor(PhysicsGrabber.GrabbedComponent.Owner);
		if(PATActor != None)
		{
			PATActor.EndGrab();
		}

		PhysicsGrabber.ReleaseComponent();
	}
	else if( FireModeNum == 1 )
	{

		if( GrabbedPawn != none )
		{
			GrabbedPawn.SetBase(none);
			GrabbedPawn = none;
		}

		if( PawnGrabber != none )
		{
			PawnGrabber.Destroy();
			PawnGrabber = none;
		}
	}
}

simulated function StartFire(byte FireModeNum)
{
	local vector					StartShot, EndShot;
	local vector					HitLocation, HitNormal, Extent;
	local actor						HitActor;
	local float						HitDistance;
	local Quat						PawnQuat, InvPawnQuat, ActorQuat;
	local TraceHitInfo				HitInfo;
	local SkeletalMeshComponent		SkelComp;
	local Rotator					Aim;
	local PhysAnimTestActor			PATActor;


	Super.StartFire( FireModeNum );

	AltCrosshairBounceInTime = default.AltCrosshairBounceInTime;

	if( FireModeNum ==1  )
	{
		if ( Role < ROLE_Authority )
			return;


		// Do ray check and grab actor
		StartShot	= Instigator.GetWeaponStartTraceLocation();
		Aim			= GetAdjustedAim( StartShot );
		EndShot		= StartShot + (GetTraceRange() * Vector(Aim));
		Extent		= vect(20,20,20);
		HitActor	= Trace(HitLocation, HitNormal, EndShot, StartShot, True, Extent, HitInfo);
		HitDistance = VSize(HitLocation - StartShot);

		if( HitActor != None &&
			HitActor != WorldInfo &&
			HitInfo.HitComponent != None &&
			HitDistance > HoldDistanceMin &&
			HitDistance < HoldDistanceMax )
		{
			HoldDistance = HitDistance;

			if( Pawn(HitActor) != none && Pawn(HitActor).Health <= 0 )
			{
				return;
			}
			else if( UTPawn(HitActor) != none )
			{
				if( PawnGrabber == none )
				{
					PawnGrabber = Spawn( class'GB_PawnGrabber',,, HitActor.Location );
				}

				GrabbedPawn = UTPawn(hitActor );
				GrabbedPawn.SetBase( PawnGrabber );
				GrabbedPawn.SetPhysics( PHYS_Flying );
				return;
			}

			PATActor = PhysAnimTestActor(HitActor);
			if(PATActor != None)
			{
				if( !PATActor.PreGrab() )
				{
					return;
				}
			}

			// If grabbing a bone of a skeletal mesh, dont constrain orientation.
			PhysicsGrabber.GrabComponent(HitInfo.HitComponent, HitInfo.BoneName, HitLocation, PlayerController(Instigator.Controller).bRun!=0);

			// if we succesfully grabbed something, store some details.
			if (PhysicsGrabber.GrabbedComponent != None)
			{
				HoldDistance	= HitDistance;
				PawnQuat		= QuatFromRotator( Rotation );
				InvPawnQuat		= QuatInvert( PawnQuat );

				if ( HitInfo.BoneName != '' )
				{
					SkelComp = SkeletalMeshComponent(HitInfo.HitComponent);
					ActorQuat = SkelComp.GetBoneQuaternion(HitInfo.BoneName);
				}
				else
				{
					ActorQuat = QuatFromRotator( PhysicsGrabber.GrabbedComponent.Owner.Rotation );
				}

				HoldOrientation = QuatProduct(InvPawnQuat, ActorQuat);
			}
		}
	}
}

reliable client function ClientHasFired()
{
	GotoState('WeaponRecharge');
}

simulated state WeaponBeamFiring
{
	simulated function BeginState( Name PreviousStateName )
	{
		Super.BeginState(PreviousStateName);

		if (Role == ROLE_Authority)
		{
			SetTimer(PaintTime,false,'FireWeapon');
		}

		InstantFire();
	}

	function FireWeapon()
	{
		local UTEmit_LeviathanExplosion Blast;
		local actor HitActor;
		local vector HitLocation, HitNormal, SpawnLoc;

		HitActor = Trace(HitLocation, HitNormal, TargetLocation + Vect(0,0,64), TargetLocation, false);
		SpawnLoc = (HitActor == None) ? TargetLocation + Vect(0,0,32) : 0.5 * (TargetLocation + HitLocation);
		Blast = Spawn(class'GB_Emit_SaucerWeaponExplosion', Instigator,, SpawnLoc);
		Blast.InstigatorController = Instigator.Controller;

		if ( !Instigator.IsLocallyControlled() )
		{
			ClientHasFired();
		}
		GotoState('WeaponRecharge');
	}

	/**
	 * When leaving the state, shut everything down
	 */
	simulated function EndState(Name NextStateName)
	{
		ClearTimer('FireWeapon');
		Super.EndState(NextStateName);
	}

	simulated function bool IsFiring()
	{
		return true;
	}

	simulated function SetFlashLocation(vector HitLocation)
	{
		if (ROLE == ROLE_Authority)
		{
			Global.SetFlashLocation(HitLocation);
			TargetLocation = HitLocation;

			CurrentEnergy = 0.0f;
		}
	}
}

simulated state WeaponRecharge
{
	simulated function BeginState( Name PreviousStateName )
	{
		Super.BeginState(PreviousStateName);
		SetTimer(RechargeTime,false,'Charged');
		TimeWeaponFiring(0);
	}

	simulated function EndState(Name NextStateName)
	{
		ClearTimer('RefireCheckTimer');
		ClearFlashLocation();
		Super.EndState(NextStateName);
	}

	simulated function bool IsFiring()
	{
		return true;
	}

	simulated function Charged()
	{
		GotoState('Active');
	}
}


function bool CanAttack(Actor Other)
{
	local bool bResult;

	bResult = Super.CanAttack(Other);

	if ( !bResult &&
		UTBot(Instigator.Controller) != None && Other == Instigator.Controller.Enemy &&
		FastTrace(UTBot(Instigator.Controller).LastSeenPos, InstantFireStartTrace()) )
	{
		bResult = true;
	}

	return bResult;
}

simulated function GetCrosshairScaling(Hud HUD)
{
	local float Perc;
	if ( AltCrosshairBounceInTime > 0)
	{
		Perc = AltCrosshairBounceInTime / default.AltCrosshairBounceInTime;

		if (Perc > 0.75)
		{
			CrossHairScaling = 1.0 + (1.0 - (Perc / 0.25));
		}
		else
		{
			CrossHairScaling = 1.0 + (1.0 * (Perc / 0.75));
		}
	}
	else
	{
		CrosshairScaling = 1.0;
	}

}

simulated function Tick( float DeltaTime )
{
	local vector	NewHandlePos, StartLoc;
	local Quat		PawnQuat, NewHandleOrientation;
	local Rotator	Aim;
	local Vehicle V;
	local Pawn P;

	Super.Tick( DeltaTime );

	if ( PhysicsGrabber.GrabbedComponent != None )
	{
		PhysicsGrabber.GrabbedComponent.WakeRigidBody( PhysicsGrabber.GrabbedBoneName );

		// Update handle position on grabbed actor.
		StartLoc		= Instigator.Location;
		Aim				= GetAdjustedAim( StartLoc );
		HoldDistance -= DeltaTime * SuckUpSpeed;
		NewHandlePos	= StartLoc + (HoldDistance * Vector(Aim));
		PhysicsGrabber.SetLocation( NewHandlePos );

		// Update handle orientation on grabbed actor.
		PawnQuat				= QuatFromRotator( Rotation );
		NewHandleOrientation	= QuatProduct(PawnQuat, HoldOrientation);
		PhysicsGrabber.SetOrientation( NewHandleOrientation );

		if( VSize(PhysicsGrabber.Location - Location) < 1500 )
		{
			`log(" PhysicsGrabber.Location is "$PhysicsGrabber.Location );

			V = Vehicle(PHysicsGrabber.GrabbedComponent.Owner);
			if( V != none )
			{
				UTVehicle(V).ExplosionDamage = 0;
				UTVehicle(V).ExplosionRadius = 0;
				V.Died( Instigator.Controller, class'UTDmgType_Encroached',  V.Location );
				CurrentEnergy += 1000.0f;
			}
			else
			{
				PHysicsGrabber.GrabbedComponent.Owner.Destroy();
				CurrentEnergy += 250.0f;
			}


			PhysicsGrabber.ReleaseComponent();
		}
	}
	else if( GrabbedPawn != none && PawnGrabber != none )
	{
		// Update handle position on grabbed actor.
		StartLoc		= Instigator.Location;
		Aim				= GetAdjustedAim( StartLoc );
		HoldDistance 	-= DeltaTime * SuckUpSpeed;
		NewHandlePos	= StartLoc + (HoldDistance * vector(Aim));
		PawnGrabber.SetLocation( NewHandlePos );

		`log("HoldDistance is "$ HoldDistance$" PawnGrabber.Location is "$PawnGrabber.Location );
		if( VSize(PawnGrabber.Location - Location) < 400 )
		{
			GrabbedPawn.Died( Instigator.Controller, class'UTDmgType_Encroached',  GrabbedPawn.Location );
			CurrentEnergy += 500.0f;
						PawnGrabber.Destroy();
			PawnGrabber = none;
			GrabbedPawn = none;
		}
	}
}

simulated function DrawBrackets(UTHud H, float CX, float CY)
{
	local float X,Y;
	local Color TileColor;
	local float Perc;

   	Perc = 1.0 - (AltCrosshairBounceInTime / default.AltCrosshairBounceInTime);

	TileColor = H.WhiteColor;
	TileColor.A = 255 * Perc;

	Y = CY - 48 * H.ResolutionScale;
	X = 60 * H.ResolutionScale * Perc;
	H.DrawShadowedStretchedTile(CrosshairImage,CX-X-24*H.ResolutionScale,Y,24,96,305,256,24,64,TileColor,true);
	H.DrawShadowedStretchedTile(CrosshairImage,CX+X,Y,24,96,330,256,24,64,TileColor,true);
	AltCrosshairBounceInTime = FMax(AltCrosshairBounceInTime - H.RenderDelta, 0.0);

}

simulated function DrawWeaponCrosshair( Hud HUD )
{
	local float CX,CY, CenterSize, XAdj, Alpha, X, Y,U,V;
	local UTHud H;
	local int i;
	local Color Gray;

	H = UTHUD(Hud);

    if( CurrentEnergy >= BeamFireCost )
    {
        H.bGreenCrosshair = true;
    }
    else
    {
        H.bGreenCrosshair = false;
    }

	super.DrawWeaponCrosshair( H );

	CenterSize = 20.0*HUD.Canvas.ClipX/1024;

	CX = H.Canvas.ClipX * 0.5;
	CY = H.Canvas.ClipY * 0.5;

	DrawBrackets(H, CX,CY);

	XAdj= (CenterSize + 10 * H.ResolutionScale) * -1;

	Gray.R=128;
	Gray.G=128;
	Gray.B=128;
	Gray.A=255;

	for (i=0;i<16;i++)
	{
		X = CX + XAdj + CrossHairSlots[i].xOfst * H.ResolutionScale;
		Y = CY + CrossHairSlots[i].yOfst * H.ResolutionScale;
		if (i < (16 * CurrentEnergy/MaxEnergy) )
		{
			if (CrossHairSlots[i].FadeTime > 0)
			{
				U = Abs(CrosshairSlots[i].UL) * H.ResolutionScale * 3.1;
				V = Abs(CrosshairSlots[i].VL) * H.ResolutionScale * 3.1;
				Alpha = CrossHairSlots[i].FadeTime / FireInterval[1];
				H.Canvas.SetPos(X+CrosshairSlots[i].gx * H.ResolutionScale - (U * 0.5), Y + CrossHairSlots[i].gy * H.ResolutionScale - (V*0.5));
				H.Canvas.DrawColor = H.WhiteColor;
				H.Canvas.DrawColor.A = 255 * Alpha;
				H.Canvas.DrawTile(CrosshairImage, U, V, 48,322, 25,24);
				CrossHairSlots[i].FadeTime -= H.RenderDelta;

			}

			H.Canvas.DrawColor.R = 100;
			H.Canvas.DrawColor.G = 255;
            H.Canvas.DrawColor.B = 100;
			H.Canvas.DrawColor.A = 255;


		}
		else
		{
			H.Canvas.DrawColor = Gray;
		}

		H.Canvas.SetPos(X, Y);
		H.Canvas.DrawTile(CrosshairImage, Abs(CrossHairSlots[i].UL * H.ResolutionScale), Abs(CrossHairSlots[i].VL * H.ResolutionScale),
					CrossHairSlots[i].U,CrossHairSlots[i].V,CrossHairSlots[i].UL,CrossHairSlots[i].VL);
		XAdj *= -1;
	}
}

defaultproperties
{
	// The primary fire button doesn't go through the normal path of weapon code.  This weapon hijacks that, and sends this weapon into the WeaponBeamFiring state.
 	//WeaponFireTypes(0)=EWFT_Projectile
 	WeaponFireTypes(1)=EWFT_Custom

	VehicleClass=class'GB_SaucerLarge'

	FiringStatesArray[0]=WeaponBeamFiring

	// Laser properties
	WeaponFireSnd[0]=SoundCue'A_Vehicle_Leviathan.SoundCues.A_Vehicle_Leviathan_TurretFire'
	FireInterval(0)=+0.3
	RechargeTime=3.0
	ShotCost(0)=0
	ShotCost(1)=0
	Spread[0]=0.015
	bCanDestroyBarricades=true

	bInstantHit = true
	bFastRepeater=false
	bRecommendSplashDamage = true
	bLockedAimWhileFiring = true

	PaintTime=2.0
	TargetSlack=50.0

	FireTriggerTags=(DriverMF_L,DriverMF_R)

	// Physics gun Properties
	HoldDistanceMin=0.0
	HoldDistanceMax=10000.0
	ThrowImpulse=20000.0

	Begin Object Class=RB_Handle Name=RB_Handle0
		LinearDamping=10.0
		LinearStiffness=5000.0
		AngularDamping=10.0
		AngularStiffness=5000.0
	End Object
	Components.Add(RB_Handle0)
	PhysicsGrabber=RB_Handle0


	AltCrosshairBounceInTime=0.5
	AltCrosshairBounceOutTime=0.33

	CrosshairSlots(0)=(u=24,ul=12,v=322,vl=10,xofst=-24,yofst=-21,gx=7,gy=5)
	CrosshairSlots(1)=(u=36,ul=-12,v=322,vl=10,xofst=12,yofst=-21,gx=5,gy=5)

	CrosshairSlots(2)=(u=24,ul=9,v=332,vl=11,xofst=-24,yofst=-11,gx=4,gy=6)
	CrosshairSlots(3)=(u=33,ul=-9,v=332,vl=11,xofst=15,yofst=-11,gx=5,gy=6)

	CrosshairSlots(4)=(u=24,ul=9,v=343,vl=12,xofst=-24,yofst=0,gx=4,gy=6)
	CrosshairSlots(5)=(u=33,ul=-9,v=343,vl=12,xofst=15,yofst=0,gx=5,gy=6)

	CrosshairSlots(6)=(u=24,ul=12,v=355,vl=10,xofst=-24,yofst=12,gx=7,gy=5)
	CrosshairSlots(7)=(u=36,ul=-12,v=355,vl=10,xofst=12,yofst=12,gx=5,gy=5)


	CrosshairSlots(8)=(u=36,ul=12,v=322,vl=10,xofst=-12,yofst=-21,gx=6,gy=5)
	CrosshairSlots(9)=(u=48,ul=-12,v=322,vl=10,xofst=0,yofst=-21,gx=7,gy=5)

	CrosshairSlots(10)=(u=33,ul=10,v=332,vl=11,xofst=-14,yofst=-11,gx=5,gy=6)
	CrosshairSlots(11)=(u=43,ul=-10,v=332,vl=11,xofst=5,yofst=-11,gx=6,gy=6)

	CrosshairSlots(12)=(u=33,ul=10,v=343,vl=12,xofst=-14,yofst=0,gx=5,gy=6)
	CrosshairSlots(13)=(u=33,ul=-9,v=343,vl=12,xofst=5,yofst=0,gx=5,gy=6)

	CrosshairSlots(14)=(u=36,ul=12,v=355,vl=10,xofst=-12,yofst=12,gx=6,gy=6)
	CrosshairSlots(15)=(u=48,ul=-12,v=355,vl=10,xofst=0,yofst=12,gx=7,gy=6)

	MaxEnergy = 10000
	SuckUpSpeed = 1500.0f
	BeamFireCost = 1000.0f
}