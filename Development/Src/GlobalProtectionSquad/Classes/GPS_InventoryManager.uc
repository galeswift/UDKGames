class GPS_InventoryManager extends UTInventoryManager;

simulated function ChangedWeapon()
{
	Super.ChangedWeapon();

	Instigator.ClientMessage("Switched to "@Instigator.Weapon.Class);
}

DefaultProperties
{
}
