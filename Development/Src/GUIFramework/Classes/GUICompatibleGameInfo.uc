//=============================================================================
// GUICompatibleGameInfo
//
// $wotgreal_dt: 16.04.2011 20:57:21$
//
// Adds support for our own HUD and PlayerController class.
// Extend your own GameInfo from this but feel free to change this class itself
// to extend from something else than UDKGame.
//=============================================================================
class GUICompatibleGameInfo extends UDKGame;

DefaultProperties
{
    //bUseClassicHUD = True
    HUDType = class'GUICompatibleHUD'
    PlayerControllerClass = class'GUICompatiblePlayerController'
}