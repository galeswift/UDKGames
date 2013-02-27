class GPS_PlayerController extends UTPlayerController;

/* This is the 'save' data for the player */
var GPS_WeaponListForPlayer WeaponList;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	WeaponList = new class'GPS_WeaponListForPlayer';
	WeaponList.Init();
}

function AddDefaultInventory()
{
	local int i;

	for( i=0 ; i<WeaponList.MAX_WEAPONS ; i++ )
	{
		// Ensure we don't give duplicate items
		if (Pawn.FindInventoryType( WeaponList.EquippedWeaponList[i].Weapon ) == None)
		{
			// Only activate the first weapon
			Pawn.CreateInventory(WeaponList.EquippedWeaponList[i].Weapon, (i > 0));
		}
	}
}

exec function GiveAllWeapons()
{	
	local int i;

	WeaponList = new class'GPS_WeaponListForPlayer';
	WeaponList.Init(true);

	for( i=0 ; i<WeaponList.MAX_WEAPONS_ALL_UNLOCKED ; i++ )
	{
		// Ensure we don't give duplicate items
		if (Pawn.FindInventoryType( WeaponList.EquippedWeaponList_AllUnlocked[i].Weapon ) == None)
		{
			// Only activate the first weapon
			Pawn.CreateInventory(WeaponList.EquippedWeaponList_AllUnlocked[i].Weapon, (i > 0));
		}
	}
}

/**
 * Reset Camera Mode to default
 */
event ResetCameraMode()
{
	SetCameraMode('ThirdPerson');
}
DefaultProperties
{
	CameraClass=class'GPS_PlayerCamera'
}
