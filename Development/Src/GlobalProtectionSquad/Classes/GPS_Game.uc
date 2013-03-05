class GPS_Game extends UTDeathMatch;

function AddDefaultInventory( pawn PlayerPawn )
{
	if( GPS_PlayerController( PlayerPawn.Controller ) != none )
	{
		GPS_PlayerController( PlayerPawn.Controller ).AddDefaultInventory();
	}
}

DefaultProperties
{	
	bDelayedStart=false
	HUDType=class'GPS_HUD'
	PlayerControllerClass=class'GPS_PlayerController'
	ConsolePlayerControllerClass=class'GPS_PlayerController'
	DefaultPawnClass=class'GlobalProtectionSquad.GPS_Pawn'
	bUseClassicHUD=true
	DefaultInventory.Empty()
}
