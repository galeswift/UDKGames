//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GBVehicleFactory_Calamity extends UTVehicleFactory;

defaultproperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'VH_GiantSaucer.SkeletalMeshes.SK_BattleSaucer'
		Translation=(X=-40.0,Y=0.0,Z=70.0) // -60 seems about perfect for exact alignment, -70 for some 'lee way'
		Scale = 0.3
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+350.0
		CollisionRadius=+2000.0
		Translation=(X=0.0,Y=0.0,Z=-40.0)
	End Object

	VehicleClassPath="GalacticBattle.GB_SaucerLarge"
	DrawScale=1.3
}
