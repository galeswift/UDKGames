class GPS_WeaponListForPlayer extends Object
	config(GPSPlayerData);

// How many weapons we are allows to equip at one time
const MAX_WEAPONS=2;

// How many weapons we are allows to equip at one time
const MAX_WEAPONS_ALL_UNLOCKED=136;

// The archetype that has all the weapons for the player
var GPS_WeaponList WeaponUnlockListDefault;

// List of weapons that are assigned;
var WeaponUnlockInfo EquippedWeaponList[MAX_WEAPONS];

// List of weapons that are assigned;
var WeaponUnlockInfo EquippedWeaponList_AllUnlocked[MAX_WEAPONS_ALL_UNLOCKED];

// The player's list of currently unlocked weapons
var config array<WeaponUnlockInfo> WeaponUnlockList;

// If the version mismatches, then we need to reinitializ the array
var config int Version;

function Init(bool bUnlockAll=false)
{
	local int i;

	if( Version != WeaponUnlockListDefault.Version || bUnlockAll )
	{   
		WeaponUnlockList.Remove(0, WeaponUnlockList.Length);
		WeaponUnlockList.Length = WeaponUnlockListDefault.UnlockList.Length;

		for(i=0 ; i<WeaponUnlockListDefault.UnlockList.Length ; i++)
		{
			`log(" Adding weapon "$WeaponUnlockListDefault.UnlockList[i].Weapon);
			WeaponUnlockList[i].bUnlocked = WeaponUnlockListDefault.UnlockList[i].bUnlocked || bUnlockAll;
			WeaponUnlockList[i].Weapon = WeaponUnlockListDefault.UnlockList[i].Weapon;
		}
		if (!bUnlockAll)
		{
			Version = WeaponUnlockListDefault.Version;
			SaveConfig();
		}
	}

	AddWeaponsToLoadout(bUnlockAll);
}

function AddWeaponsToLoadout(bool bUnlockAll=false)
{
	local int equippedWeaponIndex;
	local int i;

	equippedWeaponIndex=0;

	for(i=0 ; i<WeaponUnlockList.Length ; i++)
	{
		// Load up the player
		if (bUnlockAll)
		{
			if( WeaponUnlockList[i].bUnlocked && equippedWeaponIndex < MAX_WEAPONS_ALL_UNLOCKED)
			{
				EquippedWeaponList_AllUnlocked[equippedWeaponIndex].Weapon = WeaponUnlockList[i].Weapon;
				EquippedWeaponList_AllUnlocked[equippedWeaponIndex].bUnlocked = WeaponUnlockList[i].bUnlocked;
				equippedWeaponIndex++;
			}
		}
		else
		{
			if( WeaponUnlockList[i].bUnlocked && equippedWeaponIndex < MAX_WEAPONS)
			{
				EquippedWeaponList[equippedWeaponIndex].Weapon = WeaponUnlockList[i].Weapon;
				EquippedWeaponList[equippedWeaponIndex].bUnlocked = WeaponUnlockList[i].bUnlocked;
				equippedWeaponIndex++;
			}
		}
	}
}

DefaultProperties
{
	WeaponUnlockListDefault=GPS_WeaponList'GPS_Misc.GPS_WeaponUnlockListDefault'
}
