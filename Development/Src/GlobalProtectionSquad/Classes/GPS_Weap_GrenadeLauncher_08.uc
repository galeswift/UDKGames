class GPS_Weap_GrenadeLauncher_08 extends GPS_Weap_GrenadeLauncher;

// Overwritten to fire 20 shots, needs to be bouncy
simulated function Projectile ProjectileFire()
{
	local int i;
	local int xDir,yDir;
	local float Rand;
   	local vector RealStartLoc, AimDir, YAxis,ZAxis;
	local Projectile Proj;
	local class<Projectile> ShardProjectileClass;
	local float Mag;

	if (Role == ROLE_Authority)
	{
		// this is the location where the projectile is spawned
		RealStartLoc = GetPhysicalFireStartLoc();
		// get fire aim direction
		GetAxes(GetAdjustedAim(RealStartLoc),AimDir, YAxis, ZAxis);

		// one shard in each of 9 zones (except center)
		ShardProjectileClass = GetProjectileClass();
				
		i=0;

		while( i < 20 )
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

			Mag = ((abs(xDir) + abs(yDir)) > 1 )? 0.7 : 1.0;
			Proj = Spawn(ShardProjectileClass,,, RealStartLoc);
			if (Proj != None)
			{
				Proj.Init(AimDir + (0.1+ 0.9*FRand())*Mag*xDir*0.3*YAxis + (0.1 + 0.9*FRand())*Mag*yDir*0.3*ZAxis );
			}

			i++;
		}
	}

	return super.ProjectileFire();
}

DefaultProperties
{
	BaseClipCapacity=1
	BaseDamage=200
	BaseReloadTime=6.0
	WeaponProjectiles(0)=class'GPS_Proj_Grenade'
	FuseLength=10.0
	BaseDamageRadius=8.0
}
