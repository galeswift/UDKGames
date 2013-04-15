class GPS_PlayerController extends UTPlayerController;

/* This is the 'save' data for the player */
var GPS_PlayerSaveData SaveData;

/* The loadout used to populate the player weapon list */
var GPS_WeaponList DefaultWeaponList;

/* Keeps track of our pickups, kills, etc */
var GPS_MissionManager MissionManager;

/* Save game path */
const SaveGamePath = "../../UDKGame/Saves/GPS_Save.bin";

simulated event PostBeginPlay()
{
	local int Version;
	Super.PostBeginPlay();

	Version = DefaultWeaponList.Version;
	SaveData = new class'GPS_PlayerSaveData';
	if( !class'Engine'.static.BasicLoadObject(SaveData,SaveGamePath, false, Version) )
	{
		SaveData.Init(DefaultWeaponList);
		class'Engine'.static.BasicSaveObject(SaveData,SaveGamePath, false, Version,true);
	}

	if( MissionManager == none )
	{
		MissionManager = Spawn(class'GPS_MissionManager', self);
	}
}

function int GetLevel()
{
	local int i;
	local int result;
	result = 0;
	for( i=0 ; i<DefaultWeaponList.ExpTable.Length ; i++ )
	{
		if( SaveData.CurrentExp >= DefaultWeaponList.ExpTable[i] )
		{
			result++;
		}
	}

	return result;
}

function NotifyKilledEnemy(Actor KilledActor, int ExpReward)
{
	MissionManager.NotifyKilledEnemy(KilledActor);
	SaveData.GiveExp( ExpReward );
	class'Engine'.static.BasicSaveObject(SaveData,SaveGamePath, false, DefaultWeaponList.Version,true);
}

function AddDefaultInventory()
{
	local int i;

	for( i=0 ; i<SaveData.MAX_WEAPONS ; i++ )
	{
		// Ensure we don't give duplicate items
		if (Pawn.FindInventoryType( SaveData.EquippedWeaponList[i].Weapon ) == None)
		{
			// Only activate the first weapon
			Pawn.CreateInventory(SaveData.EquippedWeaponList[i].Weapon, (i > 0));
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
	DefaultWeaponList=GPS_WeaponList'GPS_Misc.GPS_WeaponUnlockListDefault'
}
