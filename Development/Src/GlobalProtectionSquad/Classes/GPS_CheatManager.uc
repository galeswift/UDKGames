class GPS_CheatManager extends UTCheatManager
	config(Cheats);

enum CheatFlags
{
	CF_None,
	CF_Beastmaster,
};

var config byte CheatFlagStatus[CheatFlags.CF_MAX];

exec function GiveAllWeapons()
{	
	local int i;

	Pawn.InvManager.DiscardInventory();

	for( i=0 ; i<GPS_PlayerController(Outer).DefaultWeaponList.UnlockList.Length ; i++ )
	{
		// Ensure we don't give duplicate items
		if (Pawn.FindInventoryType( GPS_PlayerController(Outer).DefaultWeaponList.UnlockList[i].Weapon ) == None)
		{
			// Only activate the first weapon
			Pawn.CreateInventory( GPS_PlayerController(Outer).DefaultWeaponList.UnlockList[i].Weapon, (i > 0));
		}
	}
}

exec function ToggleCheat(CheatFlags Flag)
{
	if(	CheatFlagStatus[Flag] == 0 )
	{
		CheatFlagStatus[Flag] = 1;
	}
	else
	{   
		CheatFlagStatus[Flag] = 0;
	}

	SaveConfig();
}

function bool IsCheatOn(CheatFlags Flag)
{
	return CheatFlagStatus[Flag] == 1;
}

DefaultProperties
{
}
