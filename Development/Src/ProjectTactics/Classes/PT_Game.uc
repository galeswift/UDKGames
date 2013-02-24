class PT_Game extends UDKGame;

/** Default inventory added via AddDefaultInventory() */
var array< class<Inventory> >	DefaultInventory;

/** Grab our main view camera when we start */
var CameraActor MainCamera;

/** Grab our main mover as well */
var Actor MainMover;

/** The main playable blocking volume */
var PT_PlayVolume MainVolume;

/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{
	local Actor A;
	Super.StartMatch();

	foreach AllActors(class'Actor', A )
	{
		if( CameraActor(A) != none && CameraActor(A).Tag == 'MainCamera')
		{
			MainCamera = CameraActor(A);
		}
		else if( A.Tag == 'MainMover' )
		{
			MainMover = A;
		}
		else if( PT_PlayVolume(A) != none )
		{
			MainVolume = PT_PlayVolume(A);
		}
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

	DefaultInventory.Add(class'PT_WeapRocketLauncher')
	DefaultInventory.Add(class'PT_WeapLinkGun')	
	DefaultInventory.Add(class'PT_WeapShockRifle')
	DefaultInventory.Add(class'PT_WeapCharge')
	HUDType=class'ProjectTactics.PT_HUD'
}