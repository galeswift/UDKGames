class GPS_PlayerSaveData extends Object
	dependson(GPS_WeaponList);

// How many weapons we are allows to equip at one time
const MAX_WEAPONS=2;

// List of weapons that are assigned;
var WeaponUnlockInfo EquippedWeaponList[MAX_WEAPONS];

// The player's list of currently unlocked weapons
var array<WeaponUnlockInfo> WeaponUnlockList;

// How much exp the player has earned so far
var int CurrentExp;

function Init(GPS_WeaponList WeaponUnlockListDefault)
{
	local int i;

	WeaponUnlockList.Remove(0, WeaponUnlockList.Length);
	WeaponUnlockList.Length = WeaponUnlockListDefault.UnlockList.Length;

	for(i=0 ; i<WeaponUnlockListDefault.UnlockList.Length ; i++)
	{
		`log(" Adding weapon "$WeaponUnlockListDefault.UnlockList[i].Weapon);
		WeaponUnlockList[i].bUnlocked = WeaponUnlockListDefault.UnlockList[i].bUnlocked;
		WeaponUnlockList[i].Weapon = WeaponUnlockListDefault.UnlockList[i].Weapon;
	}
	
	AddWeaponsToLoadout();
}

function AddWeaponsToLoadout()
{
	local int equippedWeaponIndex;
	local int i;

	equippedWeaponIndex=0;

	for(i=0 ; i<WeaponUnlockList.Length ; i++)
	{
		if( WeaponUnlockList[i].bUnlocked && equippedWeaponIndex < MAX_WEAPONS)
		{
			EquippedWeaponList[equippedWeaponIndex].Weapon = WeaponUnlockList[i].Weapon;
			EquippedWeaponList[equippedWeaponIndex].bUnlocked = WeaponUnlockList[i].bUnlocked;
			equippedWeaponIndex++;
		}
	}
}

function GiveExp( int ExpReward )
{
	CurrentExp += ExpReward;
}

DefaultProperties
{
}
