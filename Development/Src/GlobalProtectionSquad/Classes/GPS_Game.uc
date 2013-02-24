class GPS_Game extends UTDeathMatch;

DefaultProperties
{	
	bDelayedStart=false

	PlayerControllerClass=class'GPS_PlayerController'
	ConsolePlayerControllerClass=class'GPS_PlayerController'
	DefaultPawnClass=class'GlobalProtectionSquad.GPS_Pawn'

	DefaultInventory.Empty()	
	DefaultInventory.Add(class'GPS_Weap_AssaultRifle_16')
	DefaultInventory.Add(class'GPS_Weap_Sniper_13')	
	DefaultInventory.Add(class'GPS_Weap_RocketLauncher_05')	
	DefaultInventory.Add(class'GPS_Weap_Shotgun_07')		
	DefaultInventory.Add(class'GPS_Weap_MissileLauncher_03')		
}
