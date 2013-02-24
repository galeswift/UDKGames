class GPS_VehicleFactory_Mech extends GPS_VehicleFactory;

DefaultProperties
{
	Begin Object Name=SVehicleMesh
		SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'
		//Translation=(X=-40.0,Y=0.0,Z=-70.0) // -60 seems about perfect for exact alignment, -70 for some 'lee way'
	End Object

	Components.Remove(Sprite)

	Begin Object Name=CollisionCylinder
		CollisionHeight=+120.0
		CollisionRadius=+200.0
		Translation=(X=0.0,Y=0.0,Z=-40.0)
	End Object

	VehicleClassPath="GlobalProtectionSquad.GPS_Vehicle_Mech"
	VehicleClass=class'GlobalProtectionSquad.GPS_Vehicle_Mech'
	DrawScale=3.0
}
