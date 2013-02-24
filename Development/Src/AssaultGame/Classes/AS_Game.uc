class AS_Game extends UTDeathmatch;

defaultproperties
{
	DefaultInventory.Empty()
	DefaultInventory.Add(class'AS_BasicGun')	
	DefaultInventory.Add(class'AS_AdvancedGun')
	PlayerControllerClass=class'AS_PlayerController'
	ConsolePlayerControllerClass=class'AS_PlayerController'	
}