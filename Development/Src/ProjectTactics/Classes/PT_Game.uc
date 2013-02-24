class PT_Game extends UDKGame;

/** Default inventory added via AddDefaultInventory() */
var array< class<Inventory> >	DefaultInventory;

/** Grab our main view camera when we start */
var CameraActor MainCamera;


/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{
	local CameraActor C;
	Super.StartMatch();

	foreach AllActors(class'CameraActor', C )
	{
		MainCamera = C;
		break;
	}
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

	DefaultInventory.Add(class'UTWeap_RocketLauncher_Content')
	DefaultInventory.Add(class'UTWeap_LinkGun')	
	DefaultInventory.Add(class'UTWeap_ShockRifle')
}