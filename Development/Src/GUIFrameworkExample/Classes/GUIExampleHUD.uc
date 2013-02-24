//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GUIExampleHUD extends GUICompatibleHUD;

var bool bPauseMenuIsOpen;


// Open menu with Esc key.
exec function ShowMenu()
{
    TogglePauseMenu();
}

function TogglePauseMenu()
{
    if (bPauseMenuIsOpen) // stop pause
    {
        MenuScene.bDrawGUIComponents = False;
        MenuScene.bCaptureMouseInput = False;
		MenuScene.bCaptureKeyInput = False;
		MenuScene.MenuClosed();
        PlayerOwner.SetPause(False);
        bPauseMenuIsOpen = False;
    }
    else // start pause
    {
        PlayerOwner.SetPause(True);
        MenuScene.bDrawGUIComponents = True;
        MenuScene.bCaptureMouseInput = True;
		MenuScene.bCaptureKeyInput = True;
		MenuScene.MenuOpened();
        bPauseMenuIsOpen = True;
    }
}

DefaultProperties
{
    MenuSceneClass=class'AdvancedExampleMenuScene' // Use our own MenuScene with the buttons.
}