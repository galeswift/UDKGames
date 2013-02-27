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

	Pawn.InvManager.DiscardInventory();

	for( i=0 ; i<WeaponList.WeaponUnlockListDefault.UnlockList.Length ; i++ )
	{
		// Ensure we don't give duplicate items
		if (Pawn.FindInventoryType( WeaponList.WeaponUnlockListDefault.UnlockList[i].Weapon ) == None)
		{
			// Only activate the first weapon
			Pawn.CreateInventory( WeaponList.WeaponUnlockListDefault.UnlockList[i].Weapon, (i > 0));
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
