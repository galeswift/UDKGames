class GPS_Proj_GroundAOE_CC extends GPS_Proj_GroundAOE;

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	local GPS_Handler_GroundAOE_CC GroundAOECCHandler;
	
	GroundAOECCHandler = Spawn(class'GPS_Handler_GroundAOE_CC', Instigator,,Location);
	GroundAOECCHandler.Init( Location, mGunOwner );
	Destroy();
}

DefaultProperties
{
}
