class GPS_Pawn extends UTPawn;

/** Created on PostBeginPlay, allows crowd agent to chase towards us */
var GPS_SpawnableGameCrowdDestination MyGCD;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if( MyGCD == none )
	{		
		MyGCD = Spawn( class'GPS_SpawnableGameCrowdDestination',self,,Location,Rotation);
		MyGCD.SetBase( self );
		`log(self@"Spawned MyGCD "$MyGCD );
	}
}

simulated function Destroyed()
{
	super.Destroyed();

	if( MyGCD != none )
	{
		MyGCD.Destroy();
	}
}

DefaultProperties
{
	InventoryManagerClass=class'GPS_InventoryManager'
}
