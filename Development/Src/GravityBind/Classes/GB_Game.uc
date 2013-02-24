/**
  * Example game type for UDK mod making
 * Copyright 1998-2009 Epic Games, Inc. All Rights Reserved.
 */
class GB_Game extends UTDeathmatch;

/** 
  * Send an announcement to the killer for every kill
  */
function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> DamageType )
{
	`log("SUPER FUN KILL by "$Killer);
	if ( PlayerController(Killer) != None )
	{
		PlayerController(Killer).ReceiveLocalizedMessage( class'UTKillingSpreeMessage', 5, Killer.PlayerReplicationInfo, None );
	}
	Super.Killed(Killer, KilledPlayer, KilledPawn, DamageType);
}

/**
  * Don't override this gametype if chosen as DefaultGameType in .ini or on command line
  */
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return default.class;
}

defaultproperties
{
	DefaultInventory.Empty()
	DefaultInventory.Add(class'GB_Weap_Binding')
	DefaultInventory.Add(class'GB_Weap_Grapple')
}