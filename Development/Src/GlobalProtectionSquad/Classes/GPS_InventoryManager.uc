class GPS_InventoryManager extends UTInventoryManager;

/**
 * Switches to Previous weapon
 * Network: Client
 */
simulated function PrevWeapon()
{
	local int Adjust;

	if ( UTWeapon(Pawn(Owner).Weapon) != None && UTWeapon(Pawn(Owner).Weapon).DoOverridePrevWeapon() )
		return;

	Adjust = -1;

	if( PlayerController(Instigator.Controller).bRun != 0)
	{
		Adjust *= 10;
	}

	AdjustWeapon(Adjust);
}

/**
 *	Switches to Next weapon
 *	Network: Client
 */
simulated function NextWeapon()
{
	local int Adjust;
	
	if ( UTWeapon(Pawn(Owner).Weapon) != None && UTWeapon(Pawn(Owner).Weapon).DoOverrideNextWeapon() )
		return;

	Adjust = 1;

	if( PlayerController(Instigator.Controller).bRun != 0 )
	{
		Adjust *= 10;
	}

	AdjustWeapon(Adjust);
}

/**
 * This function returns a sorted list of weapons, sorted by their InventoryWeight.
 *
 * @Returns the index of the current Weapon
 */
simulated function GetWeaponList(out array<UTWeapon> WeaponList, optional bool bFilter, optional int GroupFilter, optional bool bNoEmpty)
{
	local Inventory Inv;

	Inv = InventoryChain;
	while( Inv != none )
	{
		if( UTWeapon(Inv) != none )
		{
			WeaponList[WeaponList.Length] = UTWeapon(Inv);
		}

		Inv = Inv.Inventory;

		if( Inv == InventoryChain )
		{
			Inv = none;
		}
	}
}

simulated function ChangedWeapon()
{
	Super.ChangedWeapon();

	Instigator.ClientMessage("Switched to "@Instigator.Weapon.Class);

	GPS_HUD(Instigator.GetALocalPlayerController().myHUD).HideReloadTimer();
}

DefaultProperties
{
}
