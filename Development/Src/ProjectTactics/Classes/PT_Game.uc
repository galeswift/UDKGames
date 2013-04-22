class PT_Game extends UDKGame;

/** Default inventory added via AddDefaultInventory() */
var array< class<Inventory> >	DefaultInventory;

/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{
	Super.StartMatch();
}

function AddDefaultInventory( pawn PlayerPawn )
{
	local int i;

	for (i=0; i<DefaultInventory.Length; i++)
	{
		// Ensure we don't give duplicate items
		if (PlayerPawn.FindInventoryType( DefaultInventory[i] ) == None)
		{
			// Only activate the first weapon
			PlayerPawn.CreateInventory(DefaultInventory[i], (i > 0));
		}
	}

	PlayerPawn.AddDefaultInventory();
}

defaultproperties
{
	DefaultPawnClass=class'ProjectTactics.PT_Pawn'
	PlayerControllerClass=class'ProjectTactics.PT_PC'

	DefaultInventory.Add(class'PT_WeapCharge')
	DefaultInventory.Add(class'PT_WeapRocketLauncher')
	DefaultInventory.Add(class'PT_WeapLinkGun')	
	DefaultInventory.Add(class'PT_WeapShockRifle')

	HUDType=class'ProjectTactics.PT_HUD'
}