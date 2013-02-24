//=============================================================================
// GUICompatiblePlayerController
//
// $wotgreal_dt: 11.09.2012 19:19:49$
//
// Adds special handling that takes the GUI components and mouse cursor into
// account.
//=============================================================================
class GUICompatiblePlayerController extends GamePlayerController;


// Mouse event enum
enum EMouseEvent
{
    LeftMouseButton,
    RightMouseButton,
    MiddleMouseButton,
    ScrollWheelUp,
    ScrollWheelDown,
};

var GUIScriptedTextureHandler ActiveHandler;
var bool bUseActiveHandler;

// Returns the currently active MenuScene.
final function GUIMenuScene GetActiveMenuScene()
{
    if (!bUseActiveHandler)
    {
        if (GUICompatibleHUD(myHUD) != None)
            return GUICompatibleHUD(myHUD).MenuScene;
    }
    else
    {
        if (ActiveHandler != None)
            return ActiveHandler.MenuScene;
    }
}


// Check if mouse movement should affect the cursor location or the camera rotation.
function UpdateRotation(float DeltaTime)
{
    local GUICompatibleHUD GUIHUD;
    GUIHUD = GUICompatibleHUD(myHUD);

    if (GUIHUD == None || (GUIHUD != None && GUIHUD.MenuScene != None && !GUIHUD.MenuScene.bCaptureMouseInput))
        super.UpdateRotation(DeltaTime);
}

// Handle mouse inputs
function HandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent)
{
    local GUIMenuScene MenuScene;

    MenuScene = GetActiveMenuScene();

    if (MenuScene != None)
    {
        // Detect what kind of input this is
        if (InputEvent == IE_Pressed)
        {
            // Handle pressed event
            switch (MouseEvent)
            {
                case LeftMouseButton:
                    MenuScene.PendingLeftPressed = true;
                    break;

                case RightMouseButton:
                    MenuScene.PendingRightPressed = true;
                    break;

                case MiddleMouseButton:
                    MenuScene.PendingMiddlePressed = true;
                    break;

                case ScrollWheelUp:
                    MenuScene.PendingScrollUp = true;
                    break;

                case ScrollWheelDown:
                    MenuScene.PendingScrollDown = true;
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
                    MenuScene.PendingLeftReleased = true;
                    break;

                case RightMouseButton:
                    MenuScene.PendingRightReleased = true;
                    break;

                case MiddleMouseButton:
                    MenuScene.PendingMiddleReleased = true;
                    break;

                default:
                    break;
            }
        }
    }
}

// Called by GUIScriptedTextureHandler if it wants it's MenuScene to be the one to receive inputs.
function SetHandlerActive(GUIScriptedTextureHandler Handler, bool bNewActive)
{
    if (Handler != None)
    {
        if (bNewActive)
        {
            ActiveHandler = Handler;
            bUseActiveHandler = True;
        }
        else
        {
            ActiveHandler = None;
            bUseActiveHandler = False;
        }
    }
}


/*
// Hook used for the left and right mouse button when pressed
exec function StartFire(optional byte FireModeNum)
{
    local GUICompatibleHUD GUIHUD;
    GUIHUD = GUICompatibleHUD(myHUD);

    if (GUIHUD != None && GUIHUD.MenuScene != None && GUIHUD.MenuScene.bCaptureMouseInput)
        HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Pressed);
    else
        Super.StartFire(FireModeNum);
}

// Hook used for the left and right mouse button when released
exec function StopFire(optional byte FireModeNum)
{
    local GUICompatibleHUD GUIHUD;
    GUIHUD = GUICompatibleHUD(myHUD);

    if (GUIHUD != None && GUIHUD.MenuScene != None && GUIHUD.MenuScene.bCaptureMouseInput)
        HandleMouseInput((FireModeNum == 0) ? LeftMouseButton : RightMouseButton, IE_Released);
    else
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

// Override this state because StartFire isn't called globally when in this function
auto state PlayerWaiting
{
    exec function StartFire(optional byte FireModeNum)
    {
        Global.StartFire(FireModeNum);
    }
}
*/

defaultproperties
{
  InputClass = class'GUICompatiblePlayerInput'
}
