class GPS_Proj_Grenade_Impact extends GPS_Proj_Grenade;

/**
 * Give a little bounce
 */
simulated event HitWall(vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{
	Explode(Location, HitNormal);
}

DefaultProperties
{
}
