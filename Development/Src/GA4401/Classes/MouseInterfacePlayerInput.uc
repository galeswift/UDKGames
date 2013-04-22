class MouseInterfacePlayerInput extends PlayerInput;

var PrivateWrite IntPoint MousePosition;

event PlayerInput(float DeltaTime)
{
	local MouseInterfaceHUD MouseInterfaceHUD;

	// Handle mouse movement
	// Check that we have the appropriate HUD class
	MouseInterfaceHUD = MouseInterfaceHUD(MyHUD);
	if (MouseInterfaceHUD != None)
	{
		if (!MouseInterfaceHUD.UsingScaleForm)
		{
			// If we are not using ScaleForm, then read the mouse input directly
			// Add the aMouseX to the mouse position and clamp it within the viewport width
			MousePosition.X = Clamp(MousePosition.X + aMouseX, 0, MouseInterfaceHUD.SizeX);
			// Add the aMouseY to the mouse position and clamp it within the viewport height
			MousePosition.Y = Clamp(MousePosition.Y - aMouseY, 0, MouseInterfaceHUD.SizeY);
		}
	}

	Super.PlayerInput(DeltaTime);
}

function SetMousePosition(int X, int Y)
{
	if (MyHUD != None)
	{
		MousePosition.X = Clamp(X, 0, MyHUD.SizeX);
		MousePosition.Y = Clamp(Y, 0, MyHUD.SizeY);
	}
}

defaultproperties
{
}