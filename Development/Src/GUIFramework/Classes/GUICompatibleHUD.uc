//=============================================================================
// GUICompatibleHUD
//
// $wotgreal_dt: 07/10/2012 12:04:08 AM$
//
// Receives mouse movement and translates it to coordinates. Draws GUIComponents
// to allow the creation of a menu.
//=============================================================================
class GUICompatibleHUD extends UTHUDBase;

var(HUD) Font PlayerFont; // General purpose font used by the game.
var(HUD) editinline GUIMenuScene MenuScene; // Handles buttons and similar.
var(HUD) editconst class<GUIMenuScene> MenuSceneClass; // The custom MenuScene class that we use as template.


simulated event PostBeginPlay()
{
    RemoveMovies(); // Die, bitches!!!

    super(UDKHUD).PostBeginPlay();

    if (MenuScene == None)
    {
        MenuScene = new(self) MenuSceneClass;
    }

    MenuScene.InitMenuScene();
}

simulated event PostRender()
{
    local float     XL, YL, YPos;

    super.PostRender();
    // Now we can't call the HUD's PostRender directly because it messes up
    // LastHUDRenderTime and RenderDelta.



    // Pre calculate most common variables
    if ( SizeX != Canvas.SizeX || SizeY != Canvas.SizeY )
    {
        PreCalcValues();
    }

    // Set PRI of view target
    if ( PlayerOwner != None )
    {
        // draw any debug text in real-time
        PlayerOwner.DrawDebugTextList(Canvas,RenderDelta);
    }

    if ( bShowDebugInfo )
    {
        Canvas.Font = class'Engine'.Static.GetTinyFont();
        Canvas.DrawColor = ConsoleColor;
        Canvas.StrLen("X", XL, YL);
        YPos = 0;

        ShowDebugInfo(YL, YPos);
    }
    else if ( bShowHud )
    {
        if ( !bShowScores )
        {
            DrawHud();

            DisplayConsoleMessages();
            DisplayLocalMessages();
            DisplayKismetMessages();
        }
    }

    if ( bShowBadConnectionAlert )
    {
        DisplayBadConnectionAlert();
    }


    if (MenuScene != None)
        MenuScene.RenderScene(Canvas);
}


// Called before anything else messes with the HUD, so we get clean results.
function DrawHud()
{
    CheckViewPortAspectRatio();

    Canvas.Font = PlayerFont;

    super.DrawHUD();
}


// By TheAgent.
function CheckViewPortAspectRatio()
{
    local vector2D ViewportSize;
    local bool bIsWideScreen;
    local PlayerController PC;

    foreach LocalPlayerControllers(class'PlayerController', PC)
    {
		if(PC.Player != none)
			LocalPlayer(PC.Player).ViewportClient.GetViewportSize(ViewportSize);
        break;
    }

    bIsWideScreen = (ViewportSize.Y > 0.f) && (ViewportSize.X/ViewportSize.Y > 1.7);

    if ( bIsWideScreen ) // Otherwise these are checked against 1024x768 by default.
    {
        RatioX = (ViewX != 0 ? float(ViewX) : Canvas.ClipX) / 1280.f;
        RatioY = (ViewY != 0 ? float(ViewY) : Canvas.ClipY) / 720.f;
    }
    else
    {
        RatioX = (ViewX != 0 ? float(ViewX) : Canvas.ClipX) / 1024.f;
        RatioY = (ViewY != 0 ? float(ViewY) : Canvas.ClipY) / 768.f;
    }
}

// Stub this to prevent Scaleform menus to open up. We use our own GUI after all.
function TogglePauseMenu();

event Destroyed()
{
    PlayerFont = None;

    if (MenuScene != None)
    {
        MenuScene.DeleteMenuScene();
        MenuScene = none;
    }
}

DefaultProperties
{
    MenuSceneClass=class'GUIMenuScene'
    PlayerFont=Font'EngineFonts.SmallFont'
}