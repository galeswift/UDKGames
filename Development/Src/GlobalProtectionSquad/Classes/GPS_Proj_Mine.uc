class GPS_Proj_Mine extends GPS_Proj_Grenade_Impact;

var GPS_Weap_GrenadeLauncher_Mine mGunOwner;

simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	local GPS_Handler_Mine MineHandler;
	
	MineHandler = Spawn(class'GPS_Handler_Mine', Instigator,,Location);
	MineHandler.Init( Location, mGunOwner );
	Destroy();
}

/**
 * Sets the gun who owns this handler
 */
simulated function SetGunOwner(GPS_Weap_GrenadeLauncher_Mine pGunOwner)
{
	mGunOwner = pGunOwner;  
}

DefaultProperties
{
}
