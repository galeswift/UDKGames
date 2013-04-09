class GPS_Proj_DOT extends GPS_Proj_Base;

var GPS_Weap_DOT mGunOwner;

simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local GPS_Handler_DOT DOTHandler;
	
	if (Other != Instigator)
	{
		if (!Other.bStatic && DamageRadius == 0.0)
		{
			DOTHandler = Spawn(class'GPS_Handler_DOT', Instigator,,HitLocation);
			DOTHandler.Init( Other, mGunOwner );
			DOTHandler.SpawnDOTEffects(HitLocation);
			Destroy();
		}
	}
}

/**
 * Sets the gun who owns this handler
 */
simulated function SetGunOwner(GPS_Weap_DOT pGunOwner)
{
	mGunOwner = pGunOwner;  
}

defaultproperties
{

}
