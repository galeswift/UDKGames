class GPS_Weap_Base extends UTWeap_LinkGun;

// Accuracy Enum
enum EAccuracy
{
	ACCURACY_S_PLUS,    // = 0
	ACCURACY_A_PLUS,    // = 1
	ACCURACY_A,         // = 2
	ACCURACY_A_MINUS,   // = 3
	ACCURACY_B_PLUS,    // = 4
	ACCURACY_B,         // = 5
	ACCURACY_B_MINUS,   // = 6
	ACCURACY_C,         // = 7
	ACCURACY_D,         // = 8
	ACCURACY_E,         // = 9
};

/** Base projectile properties */
var float       BaseDamage;
var float       BaseDamageRadius;
var float       BaseSpeed;
var float       BaseMaxSpeed;
var float       BaseAcceleration;
var float       BaseProjScale;
var float       BaseClipCapacity;
var float       BaseReloadTime;
var EAccuracy   BaseAccuracy;
var float       BaseRange;
var int         BaseBurstAmount;        // How many shots are in a burst
var float       BaseBurstTime;        // The time between each projectile leaving the gun
var float       BaseZoom;

var array<float> BurstList;

/** If this is greater than 1, we'll queue up another shot */
var int CurrentBurstCount;      

/** If greater than 0, how much time is left before we're done reloading */
var float CurrentReloadTime;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	AmmoCount = BaseClipCapacity;
}

function RechargeAmmo()
{
}

// No ammo consumption on weapons
simulated function WeaponEmpty()
{
	if( ShouldReload() )
	{
		GoToState( 'Reloading' );
	}
}

simulated function bool ShouldReload()
{
	return AmmoCount <= 0 || CurrentReloadTime > 0.0f;
}

state Active
{
	simulated event BeginState(name PreviousStateName)
	{
		if( ShouldReload() )
		{
			GotoState('Reloading');
		}
	}
}


state Reloading
{
	simulated event BeginState(name PreviousStateName)
	{
		CurrentReloadTime = BaseReloadTime;
	}

	simulated function StartFire(byte FireModeNum) 
	{
	}

	simulated function WeaponEmpty()
	{
	}

	simulated event Tick(float DeltaTime)
	{		
		CurrentReloadTime-=DeltaTime;

		`log(" Reloading, time left is "$CurrentReloadTime);

		if( CurrentReloadTime <= 0 )
		{
			CurrentReloadTime = 0;
			GotoState('Active');
		}
	}

	simulated event EndState(name NextStateName)
	{
		AmmoCount = BaseClipCapacity;
	}
}

// Called by the GPS_Proj_Base projectile to get the damage dealt by this weapon
function ModifyProjectileProperties( GPS_Proj_Base Proj)
{
	Proj.Damage         = BaseDamage;
	Proj.DamageRadius   = BaseDamageRadius*33;
	Proj.Speed          = BaseSpeed;
	Proj.MaxSpeed       = BaseMaxSpeed;
	Proj.AccelRate      = BaseAcceleration;
	
	Proj.SetDrawScale(BaseProjScale);
}

// Overwritten to fire burts
simulated function FireAmmunition()
{
	local int i;

	if( Role == ROLE_Authority )
	{
		for( i=0 ; i<BaseBurstAmount-1 ; i++ )
		{
			BurstList[BurstList.Length] = WorldInfo.TimeSeconds + BaseBurstTime * (i+1);		
		}
	}

	super.FireAmmunition();
}

simulated function Tick( float DeltaTime )
{
	ProcessBurstList();

	super.Tick( DeltaTime );
}

function ProcessBurstList()
{
	local int i;
	
	for( i=0 ; i<BurstList.Length ; i++ )
	{
		if( WorldInfo.TimeSeconds >= BurstList[i] )
		{
			BurstList.Remove(0,1);
			Super.FireAmmunition();
			i--;
		}		
	}
}

/** Called when zooming starts
 * @param PC - cast of Instigator.Controller for convenience
 */
simulated function StartZoom(UTPlayerController PC)
{
	ZoomedTargetFOV = class'GPS_PlayerController'.default.DefaultFOV/BaseZoom;
	
	super.StartZoom( PC );
}

DefaultProperties
{
	WeaponProjectiles(0)=class'GPS_Proj_Base'
	WeaponProjectiles(1)=none

	bZoomedFireMode(0)=0
	bZoomedFireMode(1)=1

	FiringStatesArray(0)=WeaponFiring
	FiringStatesArray(1)=WeaponFiring

	ZoomedTargetFOV=12.0
	ZoomedRate=90.0

	BaseProjScale=1.0
	BaseDamage=20.0
	BaseDamageRadius=0
	BaseSpeed=2000
	BaseMaxSpeed=2000
	BaseAcceleration=0
	BaseReloadTime=1.0
	BaseAccuracy=1.0
	BaseRange=100.0
	BaseBurstAmount=1
	BaseBurstTime=0.1
	BaseZoom=1.0	
	BaseClipCapacity=100
}
