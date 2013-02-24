//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GBPawn extends UTPawn;

var vector LastGravityDir;

simulated event PossessedBy( Controller C, bool bVehicleTransition )
{
	Super.PossessedBy( C, bVehicleTransition );

	if( C != none && !bVehicleTransition )
	{
		if( Frand() < 0.5f )
		{
			C.PlaySound( SoundCue'A_GirSounds.Sounds.okeygCue',,,,Location );
		}
		else
		{
			C.PlaySound( SoundCue'A_GirSounds.Sounds.likedookgCue',,,,Location );
		}
	}
}

function vector GetGravityDir()
{
	// todo: this should return direction to closest/strongest gravity source
	return LastGravityDir;
}

function float GetGravityStrength()
{
	// default unreal physics is gravity of 520*(0,0,-1)
	// todo: modify this based on distance from planet
	return 520.0f;
}

event Tick( float DeltaTime )
{
	local vector GravityDir;
	//local Actor HitAct;
	//local vector HitLoc, HitNorm;
	local float GravityStrength;

	super.Tick(DeltaTime);

	if( Physics == PHYS_Spider )
	{
		if( VSizeSq(Floor-vect(0,0,0)) > 0.0001f )
		{
			LastGravityDir = -Floor;
		}
	}

	if( Physics == PHYS_Falling )
	{
		GravityDir = GetGravityDir();
		GravityStrength = GetGravityStrength();
		//`log(self@"falling, applying gravity"@GravityDir@GravityStrength);
		Velocity += GravityDir*GravityStrength*DeltaTime;
		// update acceleration so it is non zero, so we will get hitwall events
		Acceleration += GravityDir*0.01f;
	}
}

DefaultProperties
{

	Begin Object Name=CollisionCylinder
		CollisionHeight=+0060.000000
	End Object

	Begin Object  Name=MyLightEnvironment
		AmbientGlow=(R=0.0,G=0.0,B=0.0,A=1.0)
	End Object

//	DefaultFamily=class'GalacticBattle.GB_FamilyInfo_Gir'
//	DefaultMesh=SkeletalMesh'GB_CH_Gir.Meshes.SK_Gir'
//	DefaultHeadPortrait=Texture'CH_IronGuard_Headshot.T_IronGuard_HeadShot_DM'

	DefaultTeamMaterials[0]=MaterialInterface'EngineMaterials.DefaultMaterial'
	DefaultTeamHeadMaterials[0]=MaterialInterface'EngineMaterials.DefaultMaterial'
	//DefaultTeamHeadPortrait[0]=Texture'CH_IronGuard_Headshot.T_IronGuard_HeadShot_Red'

	DefaultTeamMaterials[1]=MaterialInterface'EngineMaterials.DefaultMaterial'
	DefaultTeamHeadMaterials[1]=MaterialInterface'EngineMaterials.DefaultMaterial'
	//DefaultTeamHeadPortrait[1]=Texture'CH_IronGuard_Headshot.T_IronGuard_HeadShot_Blue'

	LandMovementState=PlayerSphereWalking
	LastGravityDir=(z=-1)
	//WalkableFloorZ=10.0
}