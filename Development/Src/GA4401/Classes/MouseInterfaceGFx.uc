class MouseInterfaceGFx extends GFxMoviePlayer;

var MouseInterfaceHUD MouseInterfaceHUD;

function Init(optional LocalPlayer LocalPlayer)
{
	// Initialize the ScaleForm movie
	Super.Init(LocalPlayer);

	Start();
    Advance(0);
}

event UpdateMousePosition(float X, float Y)
{
	local MouseInterfacePlayerInput MouseInterfacePlayerInput;

	if (MouseInterfaceHUD != None && MouseInterfaceHUD.PlayerOwner != None)
	{
		MouseInterfacePlayerInput = MouseInterfacePlayerInput(MouseInterfaceHUD.PlayerOwner.PlayerInput);

		if (MouseInterfacePlayerInput != None)
		{
			MouseInterfacePlayerInput.SetMousePosition(X, Y);
		}
	}
}

defaultproperties
{    
    bDisplayWithHudOff=false
    TimingMode=TM_Game
	MovieInfo=SwfMovie'MouseInterfaceContent.MouseInterfaceCursor'
	bPauseGameWhileActive=false
}