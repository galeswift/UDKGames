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

reliable client function AddDamageFor(Actor A, int DamageAmount)
{
	GPS_Hud(myHud).AddDamageFor(A, DamageAmount);
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
	CheatClass=class'GPS_CheatManager'
	CameraClass=class'GPS_PlayerCamera'
}
