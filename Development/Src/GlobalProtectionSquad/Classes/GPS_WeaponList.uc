class GPS_WeaponList extends Object;

struct WeaponUnlockInfo
{
	var() class<GPS_Weap_Base> Weapon;
	var() bool bUnlocked;
};

var() array<WeaponUnlockInfo> UnlockList;
var() int Version;

DefaultProperties
{
	Version=1
}
