class GPS_Proj_GroundAOE extends GPS_Proj_Grenade_Impact;

var GPS_Weap_GrenadeLauncher_GroundAOE mGunOwner;

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	local GPS_Handler_GroundAOE GroundAOEHandler;
	
	GroundAOEHandler = Spawn(class'GPS_Handler_GroundAOE', Instigator,,Location);
	GroundAOEHandler.Init( Location, mGunOwner );
	Destroy();
}

/**
 * Sets the gun who owns this handler
 */
simulated function SetGunOwner(GPS_Weap_GrenadeLauncher_GroundAOE pGunOwner)
{
	mGunOwner = pGunOwner;  
}

DefaultProperties
{
}
