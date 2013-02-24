//=============================================================================
// GUICompatiblePlayerInput
//
// $wotgreal_dt: 11.09.2012 19:36:02$
//
// Captures mouse movement and translates them to cursor location for the Canvas.
//=============================================================================
class GUICompatiblePlayerInput extends PlayerInput within GUICompatiblePlayerController
    config(Input);

var() globalconfig bool bUseHardwareCursor;
var bool bForcedSoftwareCursor; // If Gamepad is used, we can't use the hardware cursor.

var() globalconfig float ControlStickSensitivityHor;
var() globalconfig float ControlStickSensitivityVert;

event PlayerInput(float DeltaTime)
{
    local GUIMenuScene ActiveMenuScene;
    local GameViewportClient Viewport;
    local vector2D CurPos;

    ActiveMenuScene = GetActiveMenuScene();


    // Handle mouse
    // Ensure we have a valid HUD
    if (ActiveMenuScene != None && ActiveMenuScene.bCaptureMouseInput)
    {
        if (bUseHardwareCursor && !bForcedSoftwareCursor)
        {
            Viewport = LocalPlayer(Player).ViewportClient;
            CurPos = Viewport.GetMousePosition();

            ActiveMenuScene.MousePos.X = CurPos.X;
            ActiveMenuScene.MousePos.Y = CurPos.Y;
        }
        else
        {

            // Add the aMouseX to the mouse position and clamp it within the viewport width
            ActiveMenuScene.MousePos.X = Clamp(ActiveMenuScene.MousePos.X + aMouseX + ((aStrafe + aTurn) * abs(ControlStickSensitivityHor)), 0, ActiveMenuScene.GetScreenSizeX());
            // Add the aMouseY to the mouse position and clamp it within the viewport height
            ActiveMenuScene.MousePos.Y = Clamp(ActiveMenuScene.MousePos.Y - aMouseY + ((-aBaseY + aLookUp) * abs(ControlStickSensitivityVert)), 0, ActiveMenuScene.GetScreenSizeY());
        }
    }

    Super.PlayerInput(DeltaTime);
}

//Jumping while in the Paused menu caused the game to continue again
exec function Jump()
{
    if( !IsPaused() )
        super.Jump();
}

exec function SetControlStickSensitivity(float NewHor, optional float NewVert, optional bool bInvertHor, optional bool bInvertVert)
{
    ControlStickSensitivityHor = 10*NewHor;
    ControlStickSensitivityVert = NewVert != 0 ? 10*NewVert : 10*NewHor;

    if (bInvertHor)
        ControlStickSensitivityHor *= -1;
    if (bInvertVert)
        ControlStickSensitivityVert *= -1;

    SaveConfig();
}

exec function ToggleHardwareCursor()
{
    SetHardwareCursorEnabled(!bUseHardwareCursor);
}

final function SetHardwareCursorEnabled(bool bEnabled)
{
    bUseHardwareCursor = bEnabled;
    SaveConfig();
}

/**
 * Process an input key event routed through unrealscript from another object. This method is assigned as the value for the
 * OnRecievedNativeInputKey delegate so that native input events are routed to this unrealscript function.
 *
 * @param   ControllerId    the controller that generated this input key event
 * @param   Key             the name of the key which an event occured for (KEY_Up, KEY_Down, etc.)
 * @param   EventType       the type of event which occured (pressed, released, etc.)
 * @param   AmountDepressed for analog keys, the depression percent.
 *
 * @return  true to consume the key event, false to pass it on.
 */
function bool InputKey( int ControllerId, name Key, EInputEvent Event, float AmountDepressed = 1.f, bool bGamepad = FALSE )
{
    local GUIMenuScene ActiveMenuScene;

    bForcedSoftwareCursor = bGamepad;

    ActiveMenuScene = GetActiveMenuScene();

    // Handle mouse events separately and redirect them to the Menu Scene.
    if (ActiveMenuScene != None && ActiveMenuScene.bCaptureMouseInput)
    {
        if (Key == 'LeftMouseButton')
        {
            HandleMouseInput(LeftMouseButton, Event);
            return True;
        }

        if (Key == 'RightMouseButton')
        {
            HandleMouseInput(RightMouseButton, Event);
            return True;
        }

        if (Key == 'MiddleMouseButton')
        {
            HandleMouseInput(MiddleMouseButton, Event);
            return True;
        }

        if (Key == 'MouseScrollUp')
        {
            HandleMouseInput(ScrollWheelUp, IE_Pressed);
            return True;
        }

        if (Key == 'MouseScrollDown')
        {
            HandleMouseInput(ScrollWheelDown, IE_Pressed);
            return True;
        }
    }

    if (ActiveMenuScene != None)
    {
        return  ActiveMenuScene.InputKey(ControllerId,Key,Event,AmountDepressed,bGamepad);
    }

    return false;
}

/**
 * Process a character input event (typing) routed through unrealscript from another object. This method is assigned as the value for the
 * OnRecievedNativeInputKey delegate so that native input events are routed to this unrealscript function.
 *
 * @param   ControllerId    the controller that generated this character input event
 * @param   Unicode         the character that was typed
 *
 * @return  True to consume the character, false to pass it on.
 */
function bool InputChar( int ControllerId, string Unicode )
{
    local bool bConsume;

    local GUIMenuScene ActiveMenuScene;

    ActiveMenuScene = GetActiveMenuScene();

    if (ActiveMenuScene != None)
    {
        if (ActiveMenuScene.ClickedSelection != none)
        {
            if (ActiveMenuScene.ClickedSelection.bReceiveText)
                bConsume = ActiveMenuScene.ClickedSelection.InputChar(ControllerId,Unicode);
        }
    }

    return bConsume;
}

defaultproperties
{
    OnReceivedNativeInputKey=InputKey
    OnReceivedNativeInputChar=InputChar
}
