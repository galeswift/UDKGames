class GPS_Weap_Shotgun extends GPS_Weap_Base;

/** Spread type */
enum ESpreadType
{
	SPREAD_Random,
	SPREAD_Horizontal,
	SPREAD_Vertical,
};

/** How spread apart the shotgun shells should be */
var float       BaseSpreadDist;

/** Shotgun specific settings */
var int         BaseShotCount;
var ESpreadType BaseSpreadType;

simulated function CustomFire()
{
	local int i;
	local int xDir,yDir;
	local float Rand;
   	local vector RealStartLoc, AimDir, YAxis,ZAxis;
	local Projectile Proj;
	local class<Projectile> ShardProjectileClass;
	local float Mag;

	IncrementFlashCount();

	if (Role == ROLE_Authority)
	{
		// this is the location where the projectile is spawned
		RealStartLoc = GetPhysicalFireStartLoc();
		// get fire aim direction
		GetAxes(GetAdjustedAim(RealStartLoc),AimDir, YAxis, ZAxis);

		// one shard in each of 9 zones (except center)
		ShardProjectileClass = GetProjectileClass();
				
		i=0;

		while( i< BaseShotCount )
		{
			Rand = FRand();

			if( Rand < 0.333f )
			{
				xDir = -1;
			}
			else if( Rand < 0.666f )
			{
				xDir = 0;
			}
			else
			{
				xDir = 1;
			}
			
			Rand = FRand();

			if( Rand < 0.333f )
			{
				yDir = -1;
			}
			else if( Rand < 0.666f )
			{
				yDir = 0;
			}
			else
			{
				yDir = 1;
			}
			
			// See what kind of spread we have 
			if( BaseSpreadType == SPREAD_Vertical )
			{
				xDir = 0;
			}
			else if( BaseSpreadType == SPREAD_Horizontal )
			{
				yDir = 0;
			}

			Mag = ((abs(xDir) + abs(yDir)) > 1 )? 0.7 : 1.0;
			Proj = Spawn(ShardProjectileClass,,, RealStartLoc);
			if (Proj != None)
			{
				Proj.Init(AimDir + (0.1+ 0.9*FRand())*Mag*xDir*BaseSpreadDist*YAxis + (0.1 + 0.9*FRand())*Mag*yDir*BaseSpreadDist*ZAxis );
			}

			i++;
		}
	}
}

DefaultProperties
{
	WeaponFireTypes(0)=EWFT_Custom	
	WeaponProjectiles(0)=class'GPS_Proj_ShotgunShell'	

	FireInterval(0)=1.0
	BaseClipCapacity=8
	BaseSpreadDist = 0.3f
	BaseShotCount=25
	BaseReloadTime=4.0
	BaseSpreadType=SPREAD_Random
}
