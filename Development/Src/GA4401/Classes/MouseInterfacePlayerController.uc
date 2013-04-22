class MouseInterfacePlayerController extends PlayerController;

// Mouse event enum
enum EMouseEvent
{
	LeftMouseButton,
	RightMouseButton,
	MiddleMouseButton,
	ScrollWheelUp,
	ScrollWheelDown,
};

// Handle mouse inputs
function HandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent)
{
	local MouseInterfaceHUD MouseInterfaceHUD;

	// Type cast to get our HUD
	MouseInterfaceHUD = MouseInterfaceHUD(myHUD);

	if (MouseInterfaceHUD != None)
	{
		// Detect what kind of input this is
		if (InputEvent == IE_Pressed)
		{
			// Handle pressed event
			switch (MouseEvent)
			{
			case LeftMouseButton:
				MouseInterfaceHUD.PendingLeftPressed = true;
				break;

			case RightMouseButton:
				MouseInterfaceHUD.PendingRightPressed = true;
				break;

			case MiddleMouseButton:
				MouseInterfaceHUD.PendingMiddlePressed = true;
				break;

			case ScrollWheelUp:
				MouseInterfaceHUD.PendingScrollUp = true;
				break;

			case ScrollWheelDown:
				MouseInterfaceHUD.PendingScrollDown = true;
				break;

			default:
				break;
			}
		}
		else if (InputEvent == IE_Released)
		{
			// Handle released event
			switch (MouseEvent)
			{
			case LeftMouseButton:
				MouseInterfaceHUD.PendingLeftReleased = true;
				break;

			case RightMouseButton:
				MouseInterfaceHUD.PendingRightReleased = true;
				break;

			case MiddleMouseButton:
				MouseInterfaceHUD.PendingMiddleReleased = true;
				break;

			default:
				break;
			}
		}
	}
}

// Hook used for the left and right mouse button when pressed
exec function StartFire(optional byte FireModeNum)
{
	HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Pressed);
	Super.StartFire(FireModeNum);
}

// Hook used for the left and right mouse button when released
exec function StopFire(optional byte FireModeNum)
{
	HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Released);
	Super.StopFire(FireModeNum);
}

// Called when the middle mouse button is pressed
exec function MiddleMousePressed()
{
	HandleMouseInput(MiddleMouseButton, IE_Pressed);
}

// Called when the middle mouse button is released
exec function MiddleMouseReleased()
{
	HandleMouseInput(MiddleMouseButton, IE_Released);
}

// Called when the middle mouse wheel is scrolled up
exec function MiddleMouseScrollUp()
{
	HandleMouseInput(ScrollWheelUp, IE_Pressed);
}

// Called when the middle mouse wheel is scrolled down
exec function MiddleMouseScrollDown()
{
	HandleMouseInput(ScrollWheelDown, IE_Pressed);
}

// Null this function
function UpdateRotation(float DeltaTime);

// Override this state because StartFire isn't called globally when in this function
auto state PlayerWaiting
{
	exec function StartFire(optional byte FireModeNum)
	{
		Global.StartFire(FireModeNum);
	}
}

defaultproperties
{	
	// Set the input class to the mouse interface player input
	InputClass=class'MouseInterfacePlayerInput'
}